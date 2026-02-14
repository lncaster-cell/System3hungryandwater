from src.hunger_thirst import HungerThirstEngine, NeedState


def test_lazy_decay_applies_on_read_only():
    engine = HungerThirstEngine()
    engine.register_entity(entity_id=1, now_ms=0)

    # 10 minutes pass without per-tick updates.
    snap = engine.snapshot_entity(1, now_ms=600_000)

    assert snap.hunger == 93.0
    assert snap.thirst == 88.0
    assert snap.hunger_state == NeedState.HEALTHY


def test_party_batch_snapshot_uses_shared_time():
    engine = HungerThirstEngine()
    engine.register_entity(1, now_ms=0)
    engine.register_entity(2, now_ms=0)
    engine.register_entity(3, now_ms=0)
    engine.set_party(leader_id=10, member_ids=[1, 2, 3])

    engine.set_activity_multiplier(2, now_ms=0, multiplier_milli=2_000)

    snaps = engine.snapshot_party(leader_id=10, now_ms=300_000)  # 5 min
    by_id = {s.entity_id: s for s in snaps}

    assert by_id[1].hunger == 96.5
    assert by_id[2].hunger == 93.0  # x2 decay
    assert by_id[3].thirst == 94.0


def test_consume_and_state_clamping():
    engine = HungerThirstEngine()
    engine.register_entity(1, now_ms=0, hunger_milli=5_000, thirst_milli=1_000)

    snap0 = engine.snapshot_entity(1, now_ms=0)
    assert snap0.hunger_state == NeedState.CRITICAL
    assert snap0.thirst_state == NeedState.CRITICAL

    engine.consume_food(1, now_ms=0, points_milli=500_000)
    engine.consume_water(1, now_ms=0, points_milli=500_000)

    snap1 = engine.snapshot_entity(1, now_ms=0)
    assert snap1.hunger == 100.0
    assert snap1.thirst == 100.0
    assert snap1.hunger_state == NeedState.HEALTHY
