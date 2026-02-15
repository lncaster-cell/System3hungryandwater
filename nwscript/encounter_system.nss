// encounter_system.nss
// Deterministic encounter checks in fixed windows.

const int ENCOUNTER_WINDOW_MS = 30000;
const int ENCOUNTER_CHANCE_MILLI = 180; // 18.0%

int HashRoll(int nSeed, int nLeft, int nRight)
{
    int x = nSeed * 1103515245 + 12345 + nLeft * 265443576 + nRight * 224682251;
    x = x ^ (x / 8192);
    x = x * 127412617;
    x = x ^ (x / 65536);

    if (x < 0)
    {
        x = -x;
    }
    return x % 1000;
}

int ShouldTriggerEncounter(object oPartyLeader, int nNowMs)
{
    if (!GetLocalInt(oPartyLeader, "TRAVEL_ACTIVE"))
    {
        return FALSE;
    }

    int nStartMs = GetLocalInt(oPartyLeader, "TRAVEL_START_MS");
    int nArrivalMs = GetLocalInt(oPartyLeader, "TRAVEL_ARRIVAL_MS");
    if (nNowMs < nStartMs || nNowMs >= nArrivalMs)
    {
        return FALSE;
    }

    int nSeed = GetLocalInt(oPartyLeader, "TRAVEL_SEED");
    int nRouteId = GetLocalInt(oPartyLeader, "TRAVEL_START_MS"); // cheap route surrogate
    int nBucket = nNowMs / ENCOUNTER_WINDOW_MS;

    int nRoll = HashRoll(nSeed, nRouteId, nBucket);
    if (nRoll < ENCOUNTER_CHANCE_MILLI)
    {
        // lightweight outputs saved locally for current window
        SetLocalInt(oPartyLeader, "ENCOUNTER_LAST_MS", nNowMs);
        SetLocalInt(oPartyLeader, "ENCOUNTER_SEVERITY_MILLI", 200 + (HashRoll(nSeed, nBucket, 777) % 801));
        SetLocalInt(oPartyLeader, "ENCOUNTER_KIND", HashRoll(nSeed, nBucket, 999) % 4);
        return TRUE;
    }

    return FALSE;
}
