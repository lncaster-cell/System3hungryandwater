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

void RegisterLawPackageImpact(int nPackageId, int nDemandDeltaMilli, int nSupplyDeltaMilli, int nProsperityDeltaMilli, int nTrafficDeltaMilli, int nPopulationDeltaMilli, int nRacialPressureMilli)
{
    if (nPackageId <= 0)
    {
        return;
    }

    object oModule = GetModule();
    SetLocalInt(oModule, LawPackageDemandDeltaMilliKey(nPackageId), nDemandDeltaMilli);
    SetLocalInt(oModule, LawPackageSupplyDeltaMilliKey(nPackageId), nSupplyDeltaMilli);
    SetLocalInt(oModule, LawPackageProsperityDeltaMilliKey(nPackageId), nProsperityDeltaMilli);
    SetLocalInt(oModule, LawPackageTrafficDeltaMilliKey(nPackageId), nTrafficDeltaMilli);
    SetLocalInt(oModule, LawPackagePopulationDeltaMilliKey(nPackageId), nPopulationDeltaMilli);
    SetLocalInt(oModule, LawPackageRacialPressureMilliKey(nPackageId), ClampLawMilli(nRacialPressureMilli));
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

int GetCityPopulationDeltaMilli(int nCityId)
{
    int nPackageId = GetCityLawPackageId(nCityId);
    return nPackageId <= 0 ? 0 : GetLocalInt(GetModule(), LawPackagePopulationDeltaMilliKey(nPackageId));
}

int GetCityDemandDeltaMilli(int nCityId)
{
    int nPackageId = GetCityLawPackageId(nCityId);
    return nPackageId <= 0 ? 0 : GetLocalInt(GetModule(), LawPackageDemandDeltaMilliKey(nPackageId));
}

int GetCitySupplyDeltaMilli(int nCityId)
{
    int nPackageId = GetCityLawPackageId(nCityId);
    return nPackageId <= 0 ? 0 : GetLocalInt(GetModule(), LawPackageSupplyDeltaMilliKey(nPackageId));
}

int GetCityProsperityDeltaMilli(int nCityId)
{
    int nPackageId = GetCityLawPackageId(nCityId);
    return nPackageId <= 0 ? 0 : GetLocalInt(GetModule(), LawPackageProsperityDeltaMilliKey(nPackageId));
}

int GetCityTrafficDeltaMilli(int nCityId)
{
    int nPackageId = GetCityLawPackageId(nCityId);
    return nPackageId <= 0 ? 0 : GetLocalInt(GetModule(), LawPackageTrafficDeltaMilliKey(nPackageId));
}

int GetCityRacialPressureMilli(int nCityId)
{
    int nPackageId = GetCityLawPackageId(nCityId);
    return nPackageId <= 0 ? 0 : GetLocalInt(GetModule(), LawPackageRacialPressureMilliKey(nPackageId));
}

void ApplyCityLawEconomyImpact(int nCityId)
{
    if (nCityId <= 0)
    {
        return;
    }

    object oModule = GetModule();

    int nDemand = GetLocalInt(oModule, CityDemandMilliKey(nCityId));
    nDemand = SaturatingAddInt(nDemand, GetCityDemandDeltaMilli(nCityId));
    SetLocalInt(oModule, CityDemandMilliKey(nCityId), ClampLawMilli(nDemand));

    int nSupply = GetLocalInt(oModule, CitySupplyMilliKey(nCityId));
    nSupply = SaturatingAddInt(nSupply, GetCitySupplyDeltaMilli(nCityId));
    SetLocalInt(oModule, CitySupplyMilliKey(nCityId), ClampLawMilli(nSupply));

    int nProsperity = GetLocalInt(oModule, CityProsperityMilliKey(nCityId));
    nProsperity = SaturatingAddInt(nProsperity, GetCityProsperityDeltaMilli(nCityId));
    SetLocalInt(oModule, CityProsperityMilliKey(nCityId), ClampLawMilli(nProsperity));

    int nTraffic = GetLocalInt(oModule, CityTrafficMilliKey(nCityId));
    nTraffic = SaturatingAddInt(nTraffic, GetCityTrafficDeltaMilli(nCityId));
    SetLocalInt(oModule, CityTrafficMilliKey(nCityId), ClampLawMilli(nTraffic));

    int nPopulation = GetLocalInt(oModule, CityPopulationMilliKey(nCityId));
    nPopulation = SaturatingAddInt(nPopulation, GetCityPopulationDeltaMilli(nCityId));
    SetLocalInt(oModule, CityPopulationMilliKey(nCityId), ClampLawMilli(nPopulation));
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
    SetLocalInt(oTarget, KEY_CITY_POPULATION_DELTA_MILLI, GetCityPopulationDeltaMilli(nCityId));
    SetLocalInt(oTarget, KEY_CITY_DEMAND_DELTA_MILLI, GetCityDemandDeltaMilli(nCityId));
    SetLocalInt(oTarget, KEY_CITY_SUPPLY_DELTA_MILLI, GetCitySupplyDeltaMilli(nCityId));
    SetLocalInt(oTarget, KEY_CITY_PROSPERITY_DELTA_MILLI, GetCityProsperityDeltaMilli(nCityId));
    SetLocalInt(oTarget, KEY_CITY_TRAFFIC_DELTA_MILLI, GetCityTrafficDeltaMilli(nCityId));
    SetLocalInt(oTarget, KEY_CITY_RACIAL_PRESSURE_MILLI, GetCityRacialPressureMilli(nCityId));
}

int ComputeGuardInterventionScoreMilli(int nCityId, int nThreatMilli)
{
    int nScore = nThreatMilli;
    nScore = nScore + GetCityGuardResponseMilli(nCityId);
    nScore = nScore + (GetCityGuardSearchMilli(nCityId) / 2);
    nScore = nScore + (GetCityGuardForceMilli(nCityId) / 2);
    return ClampLawMilli(nScore);
}
