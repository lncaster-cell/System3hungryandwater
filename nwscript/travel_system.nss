// travel_system.nss
// Timestamp-based travel without background ticks.

const int SPEED_DEFAULT_MILLI_UNITS_PER_MIN = 180000;

int AbsInt(int nValue)
{
    return nValue < 0 ? -nValue : nValue;
}

// City data is stored on module object:
// CITY_X_<id>, CITY_Y_<id>
void RegisterCity(int nCityId, int nXMilli, int nYMilli)
{
    object oModule = GetModule();
    SetLocalInt(oModule, "CITY_X_" + IntToString(nCityId), nXMilli);
    SetLocalInt(oModule, "CITY_Y_" + IntToString(nCityId), nYMilli);
}

void SetPartyCity(object oPartyLeader, int nCityId)
{
    SetLocalInt(oPartyLeader, "PARTY_CITY_ID", nCityId);
}

int StartTravel(object oPartyLeader, int nToCityId, int nNowMs, int nSpeedMilliPerMin, int nSeed)
{
    object oModule = GetModule();

    int nFromCityId = GetLocalInt(oPartyLeader, "PARTY_CITY_ID");
    if (nFromCityId <= 0 || nFromCityId == nToCityId)
    {
        return FALSE;
    }

    if (nSpeedMilliPerMin <= 0)
    {
        nSpeedMilliPerMin = SPEED_DEFAULT_MILLI_UNITS_PER_MIN;
    }

    int nFromX = GetLocalInt(oModule, "CITY_X_" + IntToString(nFromCityId));
    int nFromY = GetLocalInt(oModule, "CITY_Y_" + IntToString(nFromCityId));
    int nToX = GetLocalInt(oModule, "CITY_X_" + IntToString(nToCityId));
    int nToY = GetLocalInt(oModule, "CITY_Y_" + IntToString(nToCityId));

    int nDistance = AbsInt(nToX - nFromX) + AbsInt(nToY - nFromY); // Manhattan
    int nDurationMs = (nDistance * 60000) / nSpeedMilliPerMin;
    if (nDurationMs < 1)
    {
        nDurationMs = 1;
    }

    SetLocalInt(oPartyLeader, "TRAVEL_ACTIVE", TRUE);
    SetLocalInt(oPartyLeader, "TRAVEL_FROM_CITY", nFromCityId);
    SetLocalInt(oPartyLeader, "TRAVEL_TO_CITY", nToCityId);
    SetLocalInt(oPartyLeader, "TRAVEL_START_MS", nNowMs);
    SetLocalInt(oPartyLeader, "TRAVEL_ARRIVAL_MS", nNowMs + nDurationMs);
    SetLocalInt(oPartyLeader, "TRAVEL_SEED", nSeed);
    return TRUE;
}

int ResolveArrival(object oPartyLeader, int nNowMs)
{
    if (!GetLocalInt(oPartyLeader, "TRAVEL_ACTIVE"))
    {
        return FALSE;
    }

    int nArrivalMs = GetLocalInt(oPartyLeader, "TRAVEL_ARRIVAL_MS");
    if (nNowMs < nArrivalMs)
    {
        return FALSE;
    }

    int nToCityId = GetLocalInt(oPartyLeader, "TRAVEL_TO_CITY");
    SetLocalInt(oPartyLeader, "PARTY_CITY_ID", nToCityId);
    DeleteLocalInt(oPartyLeader, "TRAVEL_ACTIVE");
    return TRUE;
}
