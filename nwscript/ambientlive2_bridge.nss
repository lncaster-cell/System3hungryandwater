// ambientlive2_bridge.nss
// Interop bridge for state exchange with ambientlive2-compatible systems.

#include "system_core"

const string AL2_SCHEMA_VERSION = "1";

string AL2Key(string sField)
{
    return AL2SyncFieldKey(sField);
}

int AL2CanImportFrom(object oSyncBus, int nCurrentRevision)
{
    if (!GetIsObjectValid(oSyncBus))
    {
        return FALSE;
    }

    string sSchema = GetLocalString(oSyncBus, AL2Key("SCHEMA"));
    if (sSchema != AL2_SCHEMA_VERSION)
    {
        return FALSE;
    }

    int nIncomingRevision = GetLocalInt(oSyncBus, AL2Key("REVISION"));
    return nIncomingRevision > nCurrentRevision;
}

// Pushes full party snapshot to a shared sync object.
// Returns written revision, or -1 on validation failure.
int AL2ExportPartySnapshot(object oPartyLeader, object oSyncBus, int nNowMs, int nRevision)
{
    if (!GetIsObjectValid(oPartyLeader) || !GetIsObjectValid(oSyncBus))
    {
        return -1;
    }

    int nNextRevision = nRevision + 1;

    SetLocalString(oSyncBus, AL2Key("SCHEMA"), AL2_SCHEMA_VERSION);
    SetLocalInt(oSyncBus, AL2Key("REVISION"), nNextRevision);
    SetLocalInt(oSyncBus, AL2Key("TIMESTAMP_MS"), nNowMs);

    SetLocalInt(oSyncBus, AL2Key(KEY_PARTY_CITY_ID), GetLocalInt(oPartyLeader, KEY_PARTY_CITY_ID));
    SetLocalInt(oSyncBus, AL2Key(KEY_PARTY_SIZE), GetLocalInt(oPartyLeader, KEY_PARTY_SIZE));
    SetLocalInt(oSyncBus, AL2Key(KEY_CAMP_STATE), GetLocalInt(oPartyLeader, KEY_CAMP_STATE));

    SetLocalInt(oSyncBus, AL2Key(KEY_TRAVEL_ACTIVE), GetLocalInt(oPartyLeader, KEY_TRAVEL_ACTIVE));
    SetLocalInt(oSyncBus, AL2Key(KEY_TRAVEL_FROM_CITY), GetLocalInt(oPartyLeader, KEY_TRAVEL_FROM_CITY));
    SetLocalInt(oSyncBus, AL2Key(KEY_TRAVEL_TO_CITY), GetLocalInt(oPartyLeader, KEY_TRAVEL_TO_CITY));
    SetLocalInt(oSyncBus, AL2Key(KEY_TRAVEL_START_MS), GetLocalInt(oPartyLeader, KEY_TRAVEL_START_MS));
    SetLocalInt(oSyncBus, AL2Key(KEY_TRAVEL_ARRIVAL_MS), GetLocalInt(oPartyLeader, KEY_TRAVEL_ARRIVAL_MS));
    SetLocalInt(oSyncBus, AL2Key(KEY_TRAVEL_SEED), GetLocalInt(oPartyLeader, KEY_TRAVEL_SEED));

    SetLocalInt(oSyncBus, AL2Key(KEY_ENCOUNTER_LAST_MS), GetLocalInt(oPartyLeader, KEY_ENCOUNTER_LAST_MS));
    SetLocalInt(oSyncBus, AL2Key(KEY_ENCOUNTER_SEVERITY_MILLI), GetLocalInt(oPartyLeader, KEY_ENCOUNTER_SEVERITY_MILLI));
    SetLocalInt(oSyncBus, AL2Key(KEY_ENCOUNTER_ACTOR_TYPE), GetLocalInt(oPartyLeader, KEY_ENCOUNTER_ACTOR_TYPE));
    SetLocalInt(oSyncBus, AL2Key(KEY_ENCOUNTER_KIND), GetLocalInt(oPartyLeader, KEY_ENCOUNTER_KIND));
    SetLocalInt(oSyncBus, AL2Key(KEY_ENCOUNTER_STARTS_IN_COMBAT), GetLocalInt(oPartyLeader, KEY_ENCOUNTER_STARTS_IN_COMBAT));

    SetLocalInt(oSyncBus, AL2Key(KEY_BALANCE), GetLocalInt(oPartyLeader, KEY_BALANCE));

    return nNextRevision;
}

// Pulls full party snapshot from a shared sync object.
// Returns imported revision, or -1 when payload cannot be accepted.
int AL2ImportPartySnapshot(object oPartyLeader, object oSyncBus, int nCurrentRevision)
{
    if (!GetIsObjectValid(oPartyLeader) || !AL2CanImportFrom(oSyncBus, nCurrentRevision))
    {
        return -1;
    }

    int nIncomingRevision = GetLocalInt(oSyncBus, AL2Key("REVISION"));

    SetLocalInt(oPartyLeader, KEY_PARTY_CITY_ID, GetLocalInt(oSyncBus, AL2Key(KEY_PARTY_CITY_ID)));
    SetLocalInt(oPartyLeader, KEY_PARTY_SIZE, GetLocalInt(oSyncBus, AL2Key(KEY_PARTY_SIZE)));
    SetLocalInt(oPartyLeader, KEY_CAMP_STATE, GetLocalInt(oSyncBus, AL2Key(KEY_CAMP_STATE)));

    SetLocalInt(oPartyLeader, KEY_TRAVEL_ACTIVE, GetLocalInt(oSyncBus, AL2Key(KEY_TRAVEL_ACTIVE)));
    SetLocalInt(oPartyLeader, KEY_TRAVEL_FROM_CITY, GetLocalInt(oSyncBus, AL2Key(KEY_TRAVEL_FROM_CITY)));
    SetLocalInt(oPartyLeader, KEY_TRAVEL_TO_CITY, GetLocalInt(oSyncBus, AL2Key(KEY_TRAVEL_TO_CITY)));
    SetLocalInt(oPartyLeader, KEY_TRAVEL_START_MS, GetLocalInt(oSyncBus, AL2Key(KEY_TRAVEL_START_MS)));
    SetLocalInt(oPartyLeader, KEY_TRAVEL_ARRIVAL_MS, GetLocalInt(oSyncBus, AL2Key(KEY_TRAVEL_ARRIVAL_MS)));
    SetLocalInt(oPartyLeader, KEY_TRAVEL_SEED, GetLocalInt(oSyncBus, AL2Key(KEY_TRAVEL_SEED)));

    SetLocalInt(oPartyLeader, KEY_ENCOUNTER_LAST_MS, GetLocalInt(oSyncBus, AL2Key(KEY_ENCOUNTER_LAST_MS)));
    SetLocalInt(oPartyLeader, KEY_ENCOUNTER_SEVERITY_MILLI, GetLocalInt(oSyncBus, AL2Key(KEY_ENCOUNTER_SEVERITY_MILLI)));
    SetLocalInt(oPartyLeader, KEY_ENCOUNTER_ACTOR_TYPE, GetLocalInt(oSyncBus, AL2Key(KEY_ENCOUNTER_ACTOR_TYPE)));
    SetLocalInt(oPartyLeader, KEY_ENCOUNTER_KIND, GetLocalInt(oSyncBus, AL2Key(KEY_ENCOUNTER_KIND)));
    SetLocalInt(oPartyLeader, KEY_ENCOUNTER_STARTS_IN_COMBAT, GetLocalInt(oSyncBus, AL2Key(KEY_ENCOUNTER_STARTS_IN_COMBAT)));

    SetLocalInt(oPartyLeader, KEY_BALANCE, GetLocalInt(oSyncBus, AL2Key(KEY_BALANCE)));

    return nIncomingRevision;
}

void AL2ExportCity(object oModule, object oSyncBus, int nCityId)
{
    if (!GetIsObjectValid(oModule) || !GetIsObjectValid(oSyncBus) || nCityId <= 0)
    {
        return;
    }

    SetLocalInt(oSyncBus, AL2Key(CityXKey(nCityId)), GetLocalInt(oModule, CityXKey(nCityId)));
    SetLocalInt(oSyncBus, AL2Key(CityYKey(nCityId)), GetLocalInt(oModule, CityYKey(nCityId)));
}

void AL2ImportCity(object oModule, object oSyncBus, int nCityId)
{
    if (!GetIsObjectValid(oModule) || !GetIsObjectValid(oSyncBus) || nCityId <= 0)
    {
        return;
    }

    SetLocalInt(oModule, CityXKey(nCityId), GetLocalInt(oSyncBus, AL2Key(CityXKey(nCityId))));
    SetLocalInt(oModule, CityYKey(nCityId), GetLocalInt(oSyncBus, AL2Key(CityYKey(nCityId))));
}

void AL2ExportCityTradeParams(object oModule, object oSyncBus, int nCityId)
{
    if (!GetIsObjectValid(oModule) || !GetIsObjectValid(oSyncBus) || nCityId <= 0)
    {
        return;
    }

    SetLocalInt(oSyncBus, AL2Key(CityDemandMilliKey(nCityId)), GetLocalInt(oModule, CityDemandMilliKey(nCityId)));
    SetLocalInt(oSyncBus, AL2Key(CitySupplyMilliKey(nCityId)), GetLocalInt(oModule, CitySupplyMilliKey(nCityId)));
    SetLocalInt(oSyncBus, AL2Key(CityProsperityMilliKey(nCityId)), GetLocalInt(oModule, CityProsperityMilliKey(nCityId)));
    SetLocalInt(oSyncBus, AL2Key(CityTrafficMilliKey(nCityId)), GetLocalInt(oModule, CityTrafficMilliKey(nCityId)));
    SetLocalInt(oSyncBus, AL2Key(CityPopulationMilliKey(nCityId)), GetLocalInt(oModule, CityPopulationMilliKey(nCityId)));
}

void AL2ImportCityTradeParams(object oModule, object oSyncBus, int nCityId)
{
    if (!GetIsObjectValid(oModule) || !GetIsObjectValid(oSyncBus) || nCityId <= 0)
    {
        return;
    }

    SetLocalInt(oModule, CityDemandMilliKey(nCityId), GetLocalInt(oSyncBus, AL2Key(CityDemandMilliKey(nCityId))));
    SetLocalInt(oModule, CitySupplyMilliKey(nCityId), GetLocalInt(oSyncBus, AL2Key(CitySupplyMilliKey(nCityId))));
    SetLocalInt(oModule, CityProsperityMilliKey(nCityId), GetLocalInt(oSyncBus, AL2Key(CityProsperityMilliKey(nCityId))));
    SetLocalInt(oModule, CityTrafficMilliKey(nCityId), GetLocalInt(oSyncBus, AL2Key(CityTrafficMilliKey(nCityId))));
    SetLocalInt(oModule, CityPopulationMilliKey(nCityId), GetLocalInt(oSyncBus, AL2Key(CityPopulationMilliKey(nCityId))));
}


void AL2ExportLawPackage(object oModule, object oSyncBus, int nPackageId)
{
    if (!GetIsObjectValid(oModule) || !GetIsObjectValid(oSyncBus) || nPackageId <= 0)
    {
        return;
    }

    SetLocalInt(oSyncBus, AL2Key(LawPackageExistsKey(nPackageId)), GetLocalInt(oModule, LawPackageExistsKey(nPackageId)));
    SetLocalInt(oSyncBus, AL2Key(LawPackageGuardResponseMilliKey(nPackageId)), GetLocalInt(oModule, LawPackageGuardResponseMilliKey(nPackageId)));
    SetLocalInt(oSyncBus, AL2Key(LawPackageGuardSearchMilliKey(nPackageId)), GetLocalInt(oModule, LawPackageGuardSearchMilliKey(nPackageId)));
    SetLocalInt(oSyncBus, AL2Key(LawPackageGuardForceMilliKey(nPackageId)), GetLocalInt(oModule, LawPackageGuardForceMilliKey(nPackageId)));
    SetLocalInt(oSyncBus, AL2Key(LawPackageTradeTaxMilliKey(nPackageId)), GetLocalInt(oModule, LawPackageTradeTaxMilliKey(nPackageId)));
    SetLocalInt(oSyncBus, AL2Key(LawPackageContrabandMilliKey(nPackageId)), GetLocalInt(oModule, LawPackageContrabandMilliKey(nPackageId)));
    SetLocalInt(oSyncBus, AL2Key(LawPackageDemandDeltaMilliKey(nPackageId)), GetLocalInt(oModule, LawPackageDemandDeltaMilliKey(nPackageId)));
    SetLocalInt(oSyncBus, AL2Key(LawPackageSupplyDeltaMilliKey(nPackageId)), GetLocalInt(oModule, LawPackageSupplyDeltaMilliKey(nPackageId)));
    SetLocalInt(oSyncBus, AL2Key(LawPackageProsperityDeltaMilliKey(nPackageId)), GetLocalInt(oModule, LawPackageProsperityDeltaMilliKey(nPackageId)));
    SetLocalInt(oSyncBus, AL2Key(LawPackageTrafficDeltaMilliKey(nPackageId)), GetLocalInt(oModule, LawPackageTrafficDeltaMilliKey(nPackageId)));
    SetLocalInt(oSyncBus, AL2Key(LawPackagePopulationDeltaMilliKey(nPackageId)), GetLocalInt(oModule, LawPackagePopulationDeltaMilliKey(nPackageId)));
    SetLocalInt(oSyncBus, AL2Key(LawPackageRacialPressureMilliKey(nPackageId)), GetLocalInt(oModule, LawPackageRacialPressureMilliKey(nPackageId)));
}

void AL2ImportLawPackage(object oModule, object oSyncBus, int nPackageId)
{
    if (!GetIsObjectValid(oModule) || !GetIsObjectValid(oSyncBus) || nPackageId <= 0)
    {
        return;
    }

    SetLocalInt(oModule, LawPackageExistsKey(nPackageId), GetLocalInt(oSyncBus, AL2Key(LawPackageExistsKey(nPackageId))));
    SetLocalInt(oModule, LawPackageGuardResponseMilliKey(nPackageId), GetLocalInt(oSyncBus, AL2Key(LawPackageGuardResponseMilliKey(nPackageId))));
    SetLocalInt(oModule, LawPackageGuardSearchMilliKey(nPackageId), GetLocalInt(oSyncBus, AL2Key(LawPackageGuardSearchMilliKey(nPackageId))));
    SetLocalInt(oModule, LawPackageGuardForceMilliKey(nPackageId), GetLocalInt(oSyncBus, AL2Key(LawPackageGuardForceMilliKey(nPackageId))));
    SetLocalInt(oModule, LawPackageTradeTaxMilliKey(nPackageId), GetLocalInt(oSyncBus, AL2Key(LawPackageTradeTaxMilliKey(nPackageId))));
    SetLocalInt(oModule, LawPackageContrabandMilliKey(nPackageId), GetLocalInt(oSyncBus, AL2Key(LawPackageContrabandMilliKey(nPackageId))));
    SetLocalInt(oModule, LawPackageDemandDeltaMilliKey(nPackageId), GetLocalInt(oSyncBus, AL2Key(LawPackageDemandDeltaMilliKey(nPackageId))));
    SetLocalInt(oModule, LawPackageSupplyDeltaMilliKey(nPackageId), GetLocalInt(oSyncBus, AL2Key(LawPackageSupplyDeltaMilliKey(nPackageId))));
    SetLocalInt(oModule, LawPackageProsperityDeltaMilliKey(nPackageId), GetLocalInt(oSyncBus, AL2Key(LawPackageProsperityDeltaMilliKey(nPackageId))));
    SetLocalInt(oModule, LawPackageTrafficDeltaMilliKey(nPackageId), GetLocalInt(oSyncBus, AL2Key(LawPackageTrafficDeltaMilliKey(nPackageId))));
    SetLocalInt(oModule, LawPackagePopulationDeltaMilliKey(nPackageId), GetLocalInt(oSyncBus, AL2Key(LawPackagePopulationDeltaMilliKey(nPackageId))));
    SetLocalInt(oModule, LawPackageRacialPressureMilliKey(nPackageId), GetLocalInt(oSyncBus, AL2Key(LawPackageRacialPressureMilliKey(nPackageId))));
}

void AL2ExportCityLawState(object oModule, object oSyncBus, int nCityId)
{
    if (!GetIsObjectValid(oModule) || !GetIsObjectValid(oSyncBus) || nCityId <= 0)
    {
        return;
    }

    SetLocalInt(oSyncBus, AL2Key(CityOwnerKey(nCityId)), GetLocalInt(oModule, CityOwnerKey(nCityId)));
    SetLocalInt(oSyncBus, AL2Key(CityLawPackageKey(nCityId)), GetLocalInt(oModule, CityLawPackageKey(nCityId)));
    SetLocalInt(oSyncBus, AL2Key(CityLawRevisionKey(nCityId)), GetLocalInt(oModule, CityLawRevisionKey(nCityId)));
}

void AL2ImportCityLawState(object oModule, object oSyncBus, int nCityId)
{
    if (!GetIsObjectValid(oModule) || !GetIsObjectValid(oSyncBus) || nCityId <= 0)
    {
        return;
    }

    SetLocalInt(oModule, CityOwnerKey(nCityId), GetLocalInt(oSyncBus, AL2Key(CityOwnerKey(nCityId))));
    SetLocalInt(oModule, CityLawPackageKey(nCityId), GetLocalInt(oSyncBus, AL2Key(CityLawPackageKey(nCityId))));
    SetLocalInt(oModule, CityLawRevisionKey(nCityId), GetLocalInt(oSyncBus, AL2Key(CityLawRevisionKey(nCityId))));
}

void AL2ExportMerchantItem(object oMerchant, object oSyncBus, int nItemId)
{
    if (!GetIsObjectValid(oMerchant) || !GetIsObjectValid(oSyncBus) || nItemId < 0)
    {
        return;
    }

    SetLocalInt(oSyncBus, AL2Key(ListPriceKey(nItemId)), GetLocalInt(oMerchant, ListPriceKey(nItemId)));
    SetLocalInt(oSyncBus, AL2Key(ListStockKey(nItemId)), GetLocalInt(oMerchant, ListStockKey(nItemId)));
    SetLocalInt(oSyncBus, AL2Key(ListWholesalePriceKey(nItemId)), GetLocalInt(oMerchant, ListWholesalePriceKey(nItemId)));
    SetLocalInt(oSyncBus, AL2Key(ListWholesaleStockTonsKey(nItemId)), GetLocalInt(oMerchant, ListWholesaleStockTonsKey(nItemId)));
    SetLocalInt(oSyncBus, AL2Key(ListWholesaleLotTonsKey(nItemId)), GetLocalInt(oMerchant, ListWholesaleLotTonsKey(nItemId)));
}

void AL2ImportMerchantItem(object oMerchant, object oSyncBus, int nItemId)
{
    if (!GetIsObjectValid(oMerchant) || !GetIsObjectValid(oSyncBus) || nItemId < 0)
    {
        return;
    }

    SetLocalInt(oMerchant, ListPriceKey(nItemId), GetLocalInt(oSyncBus, AL2Key(ListPriceKey(nItemId))));
    SetLocalInt(oMerchant, ListStockKey(nItemId), GetLocalInt(oSyncBus, AL2Key(ListStockKey(nItemId))));
    SetLocalInt(oMerchant, ListWholesalePriceKey(nItemId), GetLocalInt(oSyncBus, AL2Key(ListWholesalePriceKey(nItemId))));
    SetLocalInt(oMerchant, ListWholesaleStockTonsKey(nItemId), GetLocalInt(oSyncBus, AL2Key(ListWholesaleStockTonsKey(nItemId))));
    SetLocalInt(oMerchant, ListWholesaleLotTonsKey(nItemId), GetLocalInt(oSyncBus, AL2Key(ListWholesaleLotTonsKey(nItemId))));
}
