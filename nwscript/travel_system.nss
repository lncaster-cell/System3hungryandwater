// travel_system.nss
// Timestamp-based travel without background ticks.

#include "system_core"

const int SPEED_DEFAULT_MILLI_UNITS_PER_MIN = 180000;

void RegisterCity(int nCityId, int nXMilli, int nYMilli)
{
    if (nCityId <= 0)
    {
        return;
    }

    object oModule = GetModule();
    SetLocalInt(oModule, CityXKey(nCityId), nXMilli);
    SetLocalInt(oModule, CityYKey(nCityId), nYMilli);
}

void SetPartyCity(object oPartyLeader, int nCityId)
{
    if (nCityId > 0)
    {
        SetLocalInt(oPartyLeader, KEY_PARTY_CITY_ID, nCityId);
    }
}

int ComputeTravelDurationMs(object oModule, int nFromCityId, int nToCityId, int nSpeedMilliPerMin)
{
    int nFromX = GetLocalInt(oModule, CityXKey(nFromCityId));
    int nFromY = GetLocalInt(oModule, CityYKey(nFromCityId));
    int nToX = GetLocalInt(oModule, CityXKey(nToCityId));
    int nToY = GetLocalInt(oModule, CityYKey(nToCityId));

    int nDistance = AbsInt(nToX - nFromX) + AbsInt(nToY - nFromY);
    int nDurationMs = (nDistance * 60000) / nSpeedMilliPerMin;
    return ClampMinInt(nDurationMs, 1);
}

int StartTravel(object oPartyLeader, int nToCityId, int nNowMs, int nSpeedMilliPerMin, int nSeed)
{
    int nFromCityId = GetLocalInt(oPartyLeader, KEY_PARTY_CITY_ID);
    if (nFromCityId <= 0 || nToCityId <= 0 || nFromCityId == nToCityId)
    {
        return FALSE;
    }

    if (nSpeedMilliPerMin <= 0)
    {
        nSpeedMilliPerMin = SPEED_DEFAULT_MILLI_UNITS_PER_MIN;
    }

    object oModule = GetModule();
    int nDurationMs = ComputeTravelDurationMs(oModule, nFromCityId, nToCityId, nSpeedMilliPerMin);

    SetLocalInt(oPartyLeader, KEY_TRAVEL_ACTIVE, TRUE);
    SetLocalInt(oPartyLeader, KEY_TRAVEL_FROM_CITY, nFromCityId);
    SetLocalInt(oPartyLeader, KEY_TRAVEL_TO_CITY, nToCityId);
    SetLocalInt(oPartyLeader, KEY_TRAVEL_START_MS, nNowMs);
    SetLocalInt(oPartyLeader, KEY_TRAVEL_ARRIVAL_MS, nNowMs + nDurationMs);
    SetLocalInt(oPartyLeader, KEY_TRAVEL_SEED, nSeed);
    return TRUE;
}

int ResolveArrival(object oPartyLeader, int nNowMs)
{
    if (!GetLocalInt(oPartyLeader, KEY_TRAVEL_ACTIVE))
    {
        return FALSE;
    }

    int nArrivalMs = GetLocalInt(oPartyLeader, KEY_TRAVEL_ARRIVAL_MS);
    if (nNowMs < nArrivalMs)
    {
        return FALSE;
    }

    SetLocalInt(oPartyLeader, KEY_PARTY_CITY_ID, GetLocalInt(oPartyLeader, KEY_TRAVEL_TO_CITY));
    DeleteLocalInt(oPartyLeader, KEY_TRAVEL_ACTIVE);
    DeleteLocalInt(oPartyLeader, KEY_TRAVEL_FROM_CITY);
    DeleteLocalInt(oPartyLeader, KEY_TRAVEL_TO_CITY);
    DeleteLocalInt(oPartyLeader, KEY_TRAVEL_START_MS);
    DeleteLocalInt(oPartyLeader, KEY_TRAVEL_ARRIVAL_MS);
    DeleteLocalInt(oPartyLeader, KEY_TRAVEL_SEED);
    return TRUE;
}
