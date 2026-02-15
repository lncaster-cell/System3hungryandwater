// city_law_system.nss
// City-specific law packages controlled by city owners.

#include "system_core"

const int LAW_MILLI_MIN = 0;
const int LAW_MILLI_MAX = 1000;

int ClampLawMilli(int nValue)
{
    if (nValue < LAW_MILLI_MIN)
    {
        return LAW_MILLI_MIN;
    }

    if (nValue > LAW_MILLI_MAX)
    {
        return LAW_MILLI_MAX;
    }

    return nValue;
}

void RegisterLawPackage(int nPackageId, int nGuardResponseMilli, int nGuardSearchMilli, int nGuardForceMilli, int nTradeTaxMilli, int nContrabandMilli)
{
    if (nPackageId <= 0)
    {
        return;
    }

    object oModule = GetModule();
    SetLocalInt(oModule, LawPackageExistsKey(nPackageId), TRUE);
    SetLocalInt(oModule, LawPackageGuardResponseMilliKey(nPackageId), ClampLawMilli(nGuardResponseMilli));
    SetLocalInt(oModule, LawPackageGuardSearchMilliKey(nPackageId), ClampLawMilli(nGuardSearchMilli));
    SetLocalInt(oModule, LawPackageGuardForceMilliKey(nPackageId), ClampLawMilli(nGuardForceMilli));
    SetLocalInt(oModule, LawPackageTradeTaxMilliKey(nPackageId), ClampLawMilli(nTradeTaxMilli));
    SetLocalInt(oModule, LawPackageContrabandMilliKey(nPackageId), ClampLawMilli(nContrabandMilli));
}

int AssignCityLawPackage(int nCityId, int nOwnerId, int nPackageId)
{
    if (nCityId <= 0 || nOwnerId <= 0 || nPackageId <= 0)
    {
        return FALSE;
    }

    object oModule = GetModule();
    if (!GetLocalInt(oModule, CityExistsKey(nCityId)) || !GetLocalInt(oModule, LawPackageExistsKey(nPackageId)))
    {
        return FALSE;
    }

    int nCurrentRevision = GetLocalInt(oModule, CityLawRevisionKey(nCityId));
    SetLocalInt(oModule, CityOwnerKey(nCityId), nOwnerId);
    SetLocalInt(oModule, CityLawPackageKey(nCityId), nPackageId);
    SetLocalInt(oModule, CityLawRevisionKey(nCityId), nCurrentRevision + 1);
    return TRUE;
}

int GetCityLawPackageId(int nCityId)
{
    if (nCityId <= 0)
    {
        return 0;
    }

    return GetLocalInt(GetModule(), CityLawPackageKey(nCityId));
}

int GetCityOwnerId(int nCityId)
{
    if (nCityId <= 0)
    {
        return 0;
    }

    return GetLocalInt(GetModule(), CityOwnerKey(nCityId));
}

int GetCityGuardResponseMilli(int nCityId)
{
    int nPackageId = GetCityLawPackageId(nCityId);
    return nPackageId <= 0 ? 0 : GetLocalInt(GetModule(), LawPackageGuardResponseMilliKey(nPackageId));
}

int GetCityGuardSearchMilli(int nCityId)
{
    int nPackageId = GetCityLawPackageId(nCityId);
    return nPackageId <= 0 ? 0 : GetLocalInt(GetModule(), LawPackageGuardSearchMilliKey(nPackageId));
}

int GetCityGuardForceMilli(int nCityId)
{
    int nPackageId = GetCityLawPackageId(nCityId);
    return nPackageId <= 0 ? 0 : GetLocalInt(GetModule(), LawPackageGuardForceMilliKey(nPackageId));
}

int GetCityTradeTaxMilli(int nCityId)
{
    int nPackageId = GetCityLawPackageId(nCityId);
    return nPackageId <= 0 ? 0 : GetLocalInt(GetModule(), LawPackageTradeTaxMilliKey(nPackageId));
}

int GetCityContrabandMilli(int nCityId)
{
    int nPackageId = GetCityLawPackageId(nCityId);
    return nPackageId <= 0 ? 0 : GetLocalInt(GetModule(), LawPackageContrabandMilliKey(nPackageId));
}

void ApplyCityLawContext(object oTarget, int nCityId)
{
    if (!GetIsObjectValid(oTarget) || nCityId <= 0)
    {
        return;
    }

    SetLocalInt(oTarget, KEY_CITY_GUARD_RESPONSE_MILLI, GetCityGuardResponseMilli(nCityId));
    SetLocalInt(oTarget, KEY_CITY_GUARD_SEARCH_MILLI, GetCityGuardSearchMilli(nCityId));
    SetLocalInt(oTarget, KEY_CITY_GUARD_FORCE_MILLI, GetCityGuardForceMilli(nCityId));
    SetLocalInt(oTarget, KEY_CITY_TRADE_TAX_MILLI, GetCityTradeTaxMilli(nCityId));
    SetLocalInt(oTarget, KEY_CITY_CONTRABAND_MILLI, GetCityContrabandMilli(nCityId));
}

int ComputeGuardInterventionScoreMilli(int nCityId, int nThreatMilli)
{
    int nScore = nThreatMilli;
    nScore = nScore + GetCityGuardResponseMilli(nCityId);
    nScore = nScore + (GetCityGuardSearchMilli(nCityId) / 2);
    nScore = nScore + (GetCityGuardForceMilli(nCityId) / 2);
    return ClampLawMilli(nScore);
}
