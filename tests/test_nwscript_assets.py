from pathlib import Path


def test_nwscript_files_exist():
    root = Path(__file__).resolve().parents[1]
    files = [
        root / "nwscript" / "camp_system.nss",
        root / "nwscript" / "travel_system.nss",
        root / "nwscript" / "encounter_system.nss",
        root / "nwscript" / "trade_system.nss",
    ]
    for file in files:
        assert file.exists(), f"Missing NWScript file: {file}"


def test_nwscript_contains_core_entrypoints():
    root = Path(__file__).resolve().parents[1]
    checks = {
        "camp_system.nss": ["SetPartyCampState", "IsPartyCamped"],
        "travel_system.nss": ["RegisterCity", "StartTravel", "ResolveArrival"],
        "encounter_system.nss": ["ShouldTriggerEncounter"],
        "trade_system.nss": ["SetMerchantListing", "BuyOneLine"],
    }

    for name, symbols in checks.items():
        content = (root / "nwscript" / name).read_text(encoding="utf-8")
        for symbol in symbols:
            assert symbol in content, f"{symbol} not found in {name}"
