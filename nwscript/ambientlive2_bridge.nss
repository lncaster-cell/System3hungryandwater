// ambientlive2_bridge.nss
// Interop bridge for state exchange with ambientlive2-compatible systems.

#include "system_core"

const string AL2_SCHEMA_VERSION = "1";

string AL2Key(string sField)
{
    return "AL2_SYNC_" + sField;
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

void AL2ExportMerchantItem(object oMerchant, object oSyncBus, int nItemId)
{
    if (!GetIsObjectValid(oMerchant) || !GetIsObjectValid(oSyncBus) || nItemId < 0)
    {
        return;
    }

    SetLocalInt(oSyncBus, AL2Key(ListPriceKey(nItemId)), GetLocalInt(oMerchant, ListPriceKey(nItemId)));
    SetLocalInt(oSyncBus, AL2Key(ListStockKey(nItemId)), GetLocalInt(oMerchant, ListStockKey(nItemId)));
}

void AL2ImportMerchantItem(object oMerchant, object oSyncBus, int nItemId)
{
    if (!GetIsObjectValid(oMerchant) || !GetIsObjectValid(oSyncBus) || nItemId < 0)
    {
        return;
    }

    SetLocalInt(oMerchant, ListPriceKey(nItemId), GetLocalInt(oSyncBus, AL2Key(ListPriceKey(nItemId))));
    SetLocalInt(oMerchant, ListStockKey(nItemId), GetLocalInt(oSyncBus, AL2Key(ListStockKey(nItemId))));
}
