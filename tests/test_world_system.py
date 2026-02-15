import pytest

from src.hunger_thirst import HungerThirstEngine
from src.world_system import CampSystem, EncounterSystem, TradeOrder, TradeSystem, TravelSystem


def test_camp_lowers_need_decay_via_activity_multiplier():
    hunger = HungerThirstEngine()
    hunger.register_entity(1, now_ms=0)
    camp = CampSystem(hunger)

    camp.set_party_camp_state(party_id=10, member_ids=[1], now_ms=0, in_camp=True)
    snap = hunger.snapshot_entity(1, now_ms=600_000)

    # hunger loss: 700 * 10min * 0.55 = 3.85 => 96.15
    assert snap.hunger == 96.15
    # thirst loss: 1200 * 10min * 0.55 = 6.6 => 93.4
    assert snap.thirst == 93.4


def test_travel_route_and_arrival_resolution():
    travel = TravelSystem(default_speed_milli_units_per_min=120_000)
    travel.register_city(1, 0, 0)
    travel.register_city(2, 300_000, 0)
    travel.set_party_city(77, 1)

    route = travel.start_travel(party_id=77, to_city_id=2, now_ms=10_000, seed=42)

    assert route.arrival_ms == 160_000
    assert travel.resolve_arrival(77, now_ms=159_999) is False
    assert travel.get_party_city(77) == 1
    assert travel.resolve_arrival(77, now_ms=160_000) is True
    assert travel.get_party_city(77) == 2


def test_travel_projection_uses_camp_and_applies_no_camp_penalty():
    travel = TravelSystem(
        default_speed_milli_units_per_min=60_000,
        travel_minute_per_day=1,
        encounter_checks_per_day=2,
        no_camp_penalty_milli=250,
    )
    travel.register_city(1, 0, 0)
    travel.register_city(2, 300_000, 0)
    travel.set_party_city(8, 1)

    route = travel.start_travel(party_id=8, to_city_id=2, now_ms=0, seed=99)
    with_camp = travel.project_travel(route, has_personal_camp=True)
    no_camp = travel.project_travel(route, has_personal_camp=False)

    assert with_camp.travel_days == 5
    assert with_camp.wait_ms == 300_000
    assert with_camp.encounter_checks == 10
    assert with_camp.rest_scene == "camp"

    assert no_camp.travel_days == 7
    assert no_camp.wait_ms == 420_000
    assert no_camp.encounter_checks == 14
    assert no_camp.rest_scene == "inn"


def test_encounters_are_deterministic_and_bounded_by_route_time():
    travel = TravelSystem(default_speed_milli_units_per_min=100_000)
    travel.register_city(1, 0, 0)
    travel.register_city(2, 600_000, 0)
    travel.set_party_city(5, 1)
    route = travel.start_travel(5, 2, now_ms=0, seed=111)

    encounters = EncounterSystem(window_ms=30_000, chance_milli=350)
    events_a = encounters.events_between(route, from_ms=0, to_ms=route.arrival_ms)
    events_b = encounters.events_between(route, from_ms=0, to_ms=route.arrival_ms)

    assert events_a == events_b
    assert all(route.start_ms <= e.event_ms < route.arrival_ms for e in events_a)
    assert all(200 <= e.severity_milli <= 1000 for e in events_a)


def test_encounter_checks_generation_is_deterministic_and_bounded():
    travel = TravelSystem(default_speed_milli_units_per_min=100_000)
    travel.register_city(1, 0, 0)
    travel.register_city(2, 600_000, 0)
    travel.set_party_city(6, 1)
    route = travel.start_travel(6, 2, now_ms=0, seed=222)

    encounters = EncounterSystem(chance_milli=1000)
    events_a = encounters.events_for_checks(route, checks=10)
    events_b = encounters.events_for_checks(route, checks=10)

    assert len(events_a) == 10
    assert events_a == events_b
    assert all(route.start_ms <= e.event_ms < route.arrival_ms for e in events_a)


def test_personal_camp_supports_acquisition_stash_and_companions():
    hunger = HungerThirstEngine()
    camp = CampSystem(hunger)

    camp.acquire_personal_camp(player_id=1, source="quest_reward")
    camp.store_item(player_id=1, item_id=101, quantity=3)
    camp.store_item(player_id=1, item_id=101, quantity=2)
    camp.assign_companion_to_camp(player_id=1, companion_id=55)
    camp.assign_companion_to_camp(player_id=1, companion_id=7)

    assert camp.has_personal_camp(1) is True
    assert camp.stored_item_qty(1, 101) == 5
    assert camp.camp_companions(1) == (7, 55)


def test_trade_buy_is_atomic_and_updates_balances_stock_inventory():
    trade = TradeSystem()
    trade.set_balance(1, 2_000)
    trade.set_balance(99, 0)
    trade.set_merchant_listing(merchant_id=99, item_id=10, base_price=150, stock=5)
    trade.set_merchant_listing(merchant_id=99, item_id=20, base_price=100, stock=3)

    total = trade.buy(
        player_id=1,
        merchant_id=99,
        orders=[TradeOrder(item_id=10, quantity=2), TradeOrder(item_id=20, quantity=1)],
    )

    assert total == 400
    assert trade.balance(1) == 1_600
    assert trade.balance(99) == 400
    assert trade.player_item_qty(1, 10) == 2
    assert trade.player_item_qty(1, 20) == 1

    with pytest.raises(ValueError):
        trade.buy(player_id=1, merchant_id=99, orders=[TradeOrder(item_id=10, quantity=100)])

    # No balance changes after failed atomic operation.
    assert trade.balance(1) == 1_600
    assert trade.balance(99) == 400
