"""Optimized hunger/thirst simulation for player and party members.

Key design goals:
- Avoid per-frame/per-tick updates for every entity.
- Use integer math to prevent floating-point drift.
- Allow cheap batch updates for entire parties.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import IntEnum
from typing import Dict, Iterable, List, Mapping, MutableMapping, Optional, Sequence, Tuple


MILLI = 1000


class NeedState(IntEnum):
    """Discrete state derived from current need value (0..100)."""

    HEALTHY = 0
    LOW = 1
    CRITICAL = 2
    EMPTY = 3


@dataclass(slots=True)
class NeedConfig:
    """Configuration in fixed-point units."""

    max_value_milli: int = 100 * MILLI
    low_threshold_milli: int = 35 * MILLI
    critical_threshold_milli: int = 15 * MILLI
    # value loss per minute at activity multiplier 1.0
    hunger_loss_per_minute_milli: int = 700
    thirst_loss_per_minute_milli: int = 1200
    # hard caps for short-term activity bursts to avoid abuse/spikes
    min_activity_multiplier_milli: int = 500
    max_activity_multiplier_milli: int = 4000


@dataclass(slots=True)
class EntityNeeds:
    """Compact entity state using integer fields only."""

    hunger_milli: int
    thirst_milli: int
    activity_multiplier_milli: int = MILLI
    last_update_ms: int = 0


@dataclass(slots=True)
class NeedSnapshot:
    """Read model for networking/gameplay systems."""

    entity_id: int
    hunger: float
    thirst: float
    hunger_state: NeedState
    thirst_state: NeedState


class HungerThirstEngine:
    """High-performance hunger/thirst engine with lazy decay.

    Optimization strategy:
    - Each entity stores `last_update_ms`.
    - Decay is calculated only when the entity is accessed or modified.
    - Party updates can be executed in one pass with shared timestamp.
    - Integer fixed-point arithmetic keeps computation deterministic.
    """

    __slots__ = ("_cfg", "_entities", "_party_members")

    def __init__(self, config: Optional[NeedConfig] = None) -> None:
        self._cfg = config or NeedConfig()
        self._entities: MutableMapping[int, EntityNeeds] = {}
        self._party_members: MutableMapping[int, List[int]] = {}

    def register_entity(
        self,
        entity_id: int,
        now_ms: int,
        hunger_milli: Optional[int] = None,
        thirst_milli: Optional[int] = None,
    ) -> None:
        max_v = self._cfg.max_value_milli
        self._entities[entity_id] = EntityNeeds(
            hunger_milli=max_v if hunger_milli is None else self._clamp(hunger_milli, 0, max_v),
            thirst_milli=max_v if thirst_milli is None else self._clamp(thirst_milli, 0, max_v),
            last_update_ms=now_ms,
        )

    def unregister_entity(self, entity_id: int) -> None:
        self._entities.pop(entity_id, None)
        for members in self._party_members.values():
            if entity_id in members:
                members.remove(entity_id)

    def set_party(self, leader_id: int, member_ids: Sequence[int]) -> None:
        self._party_members[leader_id] = list(dict.fromkeys(member_ids))

    def set_activity_multiplier(self, entity_id: int, now_ms: int, multiplier_milli: int) -> None:
        entity = self._require_entity(entity_id)
        self._apply_decay(entity, now_ms)
        entity.activity_multiplier_milli = self._clamp(
            multiplier_milli,
            self._cfg.min_activity_multiplier_milli,
            self._cfg.max_activity_multiplier_milli,
        )

    def consume_food(self, entity_id: int, now_ms: int, points_milli: int) -> None:
        entity = self._require_entity(entity_id)
        self._apply_decay(entity, now_ms)
        entity.hunger_milli = self._clamp(entity.hunger_milli + points_milli, 0, self._cfg.max_value_milli)

    def consume_water(self, entity_id: int, now_ms: int, points_milli: int) -> None:
        entity = self._require_entity(entity_id)
        self._apply_decay(entity, now_ms)
        entity.thirst_milli = self._clamp(entity.thirst_milli + points_milli, 0, self._cfg.max_value_milli)

    def snapshot_entity(self, entity_id: int, now_ms: int) -> NeedSnapshot:
        entity = self._require_entity(entity_id)
        self._apply_decay(entity, now_ms)
        return self._snapshot(entity_id, entity)

    def snapshot_party(self, leader_id: int, now_ms: int) -> List[NeedSnapshot]:
        snapshots: List[NeedSnapshot] = []
        for entity_id in self._party_members.get(leader_id, []):
            entity = self._entities.get(entity_id)
            if entity is None:
                continue
            self._apply_decay(entity, now_ms)
            snapshots.append(self._snapshot(entity_id, entity))
        return snapshots

    def _apply_decay(self, entity: EntityNeeds, now_ms: int) -> None:
        dt_ms = now_ms - entity.last_update_ms
        if dt_ms <= 0:
            return

        # ((loss/minute) * dt_ms / 60000) scaled by activity multiplier.
        activity = entity.activity_multiplier_milli
        hunger_loss = (self._cfg.hunger_loss_per_minute_milli * dt_ms * activity) // (60_000 * MILLI)
        thirst_loss = (self._cfg.thirst_loss_per_minute_milli * dt_ms * activity) // (60_000 * MILLI)

        if hunger_loss:
            entity.hunger_milli = max(0, entity.hunger_milli - hunger_loss)
        if thirst_loss:
            entity.thirst_milli = max(0, entity.thirst_milli - thirst_loss)

        entity.last_update_ms = now_ms

    def _snapshot(self, entity_id: int, entity: EntityNeeds) -> NeedSnapshot:
        return NeedSnapshot(
            entity_id=entity_id,
            hunger=entity.hunger_milli / MILLI,
            thirst=entity.thirst_milli / MILLI,
            hunger_state=self._state(entity.hunger_milli),
            thirst_state=self._state(entity.thirst_milli),
        )

    def _state(self, value_milli: int) -> NeedState:
        if value_milli <= 0:
            return NeedState.EMPTY
        if value_milli <= self._cfg.critical_threshold_milli:
            return NeedState.CRITICAL
        if value_milli <= self._cfg.low_threshold_milli:
            return NeedState.LOW
        return NeedState.HEALTHY

    def _require_entity(self, entity_id: int) -> EntityNeeds:
        entity = self._entities.get(entity_id)
        if entity is None:
            raise KeyError(f"Entity {entity_id} is not registered")
        return entity

    @staticmethod
    def _clamp(value: int, min_v: int, max_v: int) -> int:
        if value < min_v:
            return min_v
        if value > max_v:
            return max_v
        return value
