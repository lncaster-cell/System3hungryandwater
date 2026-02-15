// encounter_system.nss
// Deterministic encounter checks in fixed windows.

#include "system_core"

const int ENCOUNTER_WINDOW_MS = 30000;
const int ENCOUNTER_CHANCE_MILLI = 180; // 18.0%

// Encounter actor type IDs
const int ENCOUNTER_ACTOR_MONSTER = 0;
const int ENCOUNTER_ACTOR_BANDIT = 1;
const int ENCOUNTER_ACTOR_HOSTILE_FACTION = 2;
const int ENCOUNTER_ACTOR_MERCHANT = 3;
const int ENCOUNTER_ACTOR_TRAVELER = 4;

int HashRoll(int nSeed, int nLeft, int nRight)
{
    int x = nSeed * 1103515245 + 12345 + nLeft * 265443576 + nRight * 224682251;
    x = x ^ (x / 8192);
    x = x * 127412617;
    x = x ^ (x / 65536);

    return AbsInt(x) % 1000;
}

int StartsInCombat(int nActorType)
{
    return nActorType == ENCOUNTER_ACTOR_MONSTER
        || nActorType == ENCOUNTER_ACTOR_BANDIT
        || nActorType == ENCOUNTER_ACTOR_HOSTILE_FACTION;
}

int GetTravelRouteFingerprint(object oPartyLeader)
{
    int nFromCity = GetLocalInt(oPartyLeader, KEY_TRAVEL_FROM_CITY);
    int nToCity = GetLocalInt(oPartyLeader, KEY_TRAVEL_TO_CITY);
    return (nFromCity * 1000003) + nToCity;
}

int ShouldTriggerEncounter(object oPartyLeader, int nNowMs)
{
    if (!GetLocalInt(oPartyLeader, KEY_TRAVEL_ACTIVE))
    {
        return FALSE;
    }

    int nStartMs = GetLocalInt(oPartyLeader, KEY_TRAVEL_START_MS);
    int nArrivalMs = GetLocalInt(oPartyLeader, KEY_TRAVEL_ARRIVAL_MS);
    if (nNowMs < nStartMs || nNowMs >= nArrivalMs)
    {
        return FALSE;
    }

    int nSeed = GetLocalInt(oPartyLeader, KEY_TRAVEL_SEED);
    int nRoute = GetTravelRouteFingerprint(oPartyLeader);
    int nBucket = nNowMs / ENCOUNTER_WINDOW_MS;

    int nLastEncounterBucket = GetLocalInt(oPartyLeader, KEY_ENCOUNTER_LAST_BUCKET);
    if (nLastEncounterBucket == nBucket)
    {
        return FALSE;
    }

    int nLastEncounterMs = GetLocalInt(oPartyLeader, KEY_ENCOUNTER_LAST_MS);
    if (nLastEncounterMs > 0 && (nLastEncounterMs / ENCOUNTER_WINDOW_MS) == nBucket)
    {
        return FALSE;
    }

    int nRoll = HashRoll(nSeed, nRoute, nBucket);

    if (nRoll >= ENCOUNTER_CHANCE_MILLI)
    {
        return FALSE;
    }

    int nActorType = HashRoll(nSeed, nBucket, 999) % 5;
    SetLocalInt(oPartyLeader, KEY_ENCOUNTER_LAST_BUCKET, nBucket);
    SetLocalInt(oPartyLeader, KEY_ENCOUNTER_LAST_MS, nNowMs);
    SetLocalInt(oPartyLeader, KEY_ENCOUNTER_SEVERITY_MILLI, 200 + (HashRoll(nSeed, nBucket, 777) % 801));
    SetLocalInt(oPartyLeader, KEY_ENCOUNTER_ACTOR_TYPE, nActorType);
    SetLocalInt(oPartyLeader, KEY_ENCOUNTER_KIND, nActorType); // Backward-compatible alias.
    SetLocalInt(oPartyLeader, KEY_ENCOUNTER_STARTS_IN_COMBAT, StartsInCombat(nActorType));

    return TRUE;
}
