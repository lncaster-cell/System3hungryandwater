"""Ultra-lightweight world mechanics: camp, travel, encounters, and trade.

The design follows the same principles as the hunger/thirst engine:
- lazy updates (no per-tick simulation loops),
- integer-only arithmetic for deterministic, cache-friendly calculations,
- compact data layouts suitable for large player counts.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import List, MutableMapping, Optional, Sequence, Tuple

from .hunger_thirst import HungerThirstEngine

MILLI = 1000


@dataclass(frozen=True, slots=True)
class City:
    city_id: int
    x_milli: int
    y_milli: int


@dataclass(slots=True)
class TradeOrder:
    item_id: int
    quantity: int


@dataclass(slots=True)
class InventoryPosition:
    quantity: int = 0


@dataclass(slots=True)
class MerchantListing:
    base_price: int
    stock: int


@dataclass(slots=True)
class TravelRoute:
    route_id: int
    party_id: int
    from_city_id: int
    to_city_id: int
    start_ms: int
    arrival_ms: int
    seed: int


@dataclass(frozen=True, slots=True)
class EncounterEvent:
    route_id: int
    event_ms: int
    severity_milli: int
    kind: int


class CampSystem:
    """Camp status with O(1) updates and direct need-engine coupling."""

    __slots__ = ("_hunger_engine", "_camped_party")

    def __init__(self, hunger_engine: HungerThirstEngine) -> None:
        self._hunger_engine = hunger_engine
        self._camped_party: MutableMapping[int, bool] = {}

    def set_party_camp_state(
        self,
        party_id: int,
        member_ids: Sequence[int],
        now_ms: int,
        in_camp: bool,
    ) -> None:
        self._camped_party[party_id] = in_camp
        multiplier = 550 if in_camp else MILLI
        for entity_id in member_ids:
            self._hunger_engine.set_activity_multiplier(entity_id, now_ms, multiplier)

    def is_camped(self, party_id: int) -> bool:
        return self._camped_party.get(party_id, False)


class TravelSystem:
    """Route planner and state transitions for player parties.

    Performance notes:
    - city coordinates are stored in milli units and Manhattan distance is used
      to avoid sqrt operations.
    - movement resolution is timestamp-only: a route is considered active until
      `now_ms >= arrival_ms`; no intermediate ticks are required.
    """

    __slots__ = (
        "_cities",
        "_party_city",
        "_routes",
        "_next_route_id",
        "_default_speed_milli_units_per_min",
    )

    def __init__(self, default_speed_milli_units_per_min: int = 180_000) -> None:
        self._cities: MutableMapping[int, City] = {}
        self._party_city: MutableMapping[int, int] = {}
        self._routes: MutableMapping[int, TravelRoute] = {}
        self._next_route_id = 1
        self._default_speed_milli_units_per_min = max(1, default_speed_milli_units_per_min)

    def register_city(self, city_id: int, x_milli: int, y_milli: int) -> None:
        self._cities[city_id] = City(city_id=city_id, x_milli=x_milli, y_milli=y_milli)

    def set_party_city(self, party_id: int, city_id: int) -> None:
        self._require_city(city_id)
        self._party_city[party_id] = city_id

    def get_party_city(self, party_id: int) -> Optional[int]:
        return self._party_city.get(party_id)

    def start_travel(
        self,
        party_id: int,
        to_city_id: int,
        now_ms: int,
        speed_milli_units_per_min: Optional[int] = None,
        seed: int = 0,
    ) -> TravelRoute:
        from_city_id = self._party_city.get(party_id)
        if from_city_id is None:
            raise KeyError(f"Party {party_id} location is unknown")
        if from_city_id == to_city_id:
            raise ValueError("Destination must differ from current city")

        from_city = self._require_city(from_city_id)
        to_city = self._require_city(to_city_id)

        speed = speed_milli_units_per_min or self._default_speed_milli_units_per_min
        if speed <= 0:
            raise ValueError("Speed must be positive")

        distance = abs(to_city.x_milli - from_city.x_milli) + abs(to_city.y_milli - from_city.y_milli)
        duration_ms = max(1, (distance * 60_000) // speed)

        route = TravelRoute(
            route_id=self._next_route_id,
            party_id=party_id,
            from_city_id=from_city_id,
            to_city_id=to_city_id,
            start_ms=now_ms,
            arrival_ms=now_ms + duration_ms,
            seed=seed,
        )
        self._next_route_id += 1
        self._routes[party_id] = route
        return route

    def resolve_arrival(self, party_id: int, now_ms: int) -> bool:
        route = self._routes.get(party_id)
        if route is None or now_ms < route.arrival_ms:
            return False
        self._party_city[party_id] = route.to_city_id
        del self._routes[party_id]
        return True

    def active_route(self, party_id: int) -> Optional[TravelRoute]:
        return self._routes.get(party_id)

    def _require_city(self, city_id: int) -> City:
        city = self._cities.get(city_id)
        if city is None:
            raise KeyError(f"City {city_id} is not registered")
        return city


class EncounterSystem:
    """Deterministic encounter generation for active travel routes.

    No mutable timers are stored. Events are derived from route parameters with
    an integer hash, allowing instant recalculation at any time window.
    """

    __slots__ = ("_window_ms", "_chance_milli")

    def __init__(self, window_ms: int = 30_000, chance_milli: int = 180) -> None:
        self._window_ms = max(1, window_ms)
        self._chance_milli = min(max(0, chance_milli), MILLI)

    def events_between(self, route: TravelRoute, from_ms: int, to_ms: int) -> List[EncounterEvent]:
        if to_ms <= from_ms:
            return []

        start = max(from_ms, route.start_ms)
        end = min(to_ms, route.arrival_ms)
        if end <= start:
            return []

        events: List[EncounterEvent] = []
        first_bucket = start // self._window_ms
        last_bucket = (end - 1) // self._window_ms

        for bucket in range(first_bucket, last_bucket + 1):
            roll = self._hash_roll(route.seed, route.route_id, bucket)
            if roll < self._chance_milli:
                event_ms = max(start, bucket * self._window_ms)
                severity = 200 + (self._hash_roll(route.seed ^ 0xABCDEF, route.party_id, bucket) % 801)
                kind = self._hash_roll(route.seed ^ 0x13579B, route.to_city_id, bucket) % 4
                events.append(
                    EncounterEvent(
                        route_id=route.route_id,
                        event_ms=event_ms,
                        severity_milli=severity,
                        kind=kind,
                    )
                )
        return events

    @staticmethod
    def _hash_roll(seed: int, left: int, right: int) -> int:
        x = (seed * 1103515245 + 12345 + left * 2654435761 + right * 2246822519) & 0xFFFFFFFF
        x ^= (x >> 13)
        x = (x * 1274126177) & 0xFFFFFFFF
        x ^= (x >> 16)
        return x % MILLI


class TradeSystem:
    """Integer-only market operations with predictable O(order_size) complexity."""

    __slots__ = ("_merchant_inventory", "_player_inventory", "_balances")

    def __init__(self) -> None:
        self._merchant_inventory: MutableMapping[int, MutableMapping[int, MerchantListing]] = {}
        self._player_inventory: MutableMapping[int, MutableMapping[int, InventoryPosition]] = {}
        self._balances: MutableMapping[int, int] = {}

    def set_balance(self, actor_id: int, amount: int) -> None:
        self._balances[actor_id] = max(0, amount)

    def balance(self, actor_id: int) -> int:
        return self._balances.get(actor_id, 0)

    def set_merchant_listing(self, merchant_id: int, item_id: int, base_price: int, stock: int) -> None:
        if base_price <= 0:
            raise ValueError("base_price must be positive")
        if stock < 0:
            raise ValueError("stock must be non-negative")
        inv = self._merchant_inventory.setdefault(merchant_id, {})
        inv[item_id] = MerchantListing(base_price=base_price, stock=stock)

    def player_item_qty(self, player_id: int, item_id: int) -> int:
        return self._player_inventory.get(player_id, {}).get(item_id, InventoryPosition(0)).quantity

    def buy(self, player_id: int, merchant_id: int, orders: Sequence[TradeOrder]) -> int:
        """Execute atomic purchase, returns total price."""
        merchant_inv = self._merchant_inventory.get(merchant_id)
        if merchant_inv is None:
            raise KeyError(f"Merchant {merchant_id} not found")

        total = 0
        normalized: List[Tuple[int, int, MerchantListing]] = []
        for order in orders:
            if order.quantity <= 0:
                raise ValueError("quantity must be positive")
            listing = merchant_inv.get(order.item_id)
            if listing is None:
                raise KeyError(f"Item {order.item_id} is not sold by merchant {merchant_id}")
            if listing.stock < order.quantity:
                raise ValueError(f"Insufficient stock for item {order.item_id}")
            line_cost = listing.base_price * order.quantity
            total += line_cost
            normalized.append((order.item_id, order.quantity, listing))

        if self.balance(player_id) < total:
            raise ValueError("Insufficient balance")

        self._balances[player_id] -= total
        self._balances[merchant_id] = self.balance(merchant_id) + total

        player_inv = self._player_inventory.setdefault(player_id, {})
        for item_id, qty, listing in normalized:
            listing.stock -= qty
            pos = player_inv.get(item_id)
            if pos is None:
                player_inv[item_id] = InventoryPosition(quantity=qty)
            else:
                pos.quantity += qty
        return total
