// system_core.nss
// Shared lightweight helpers and canonical local variable keys.

const string KEY_PARTY_CITY_ID = "PARTY_CITY_ID";
const string KEY_PARTY_SIZE = "PARTY_SIZE";
const string KEY_CAMP_STATE = "CAMP_STATE";

const string KEY_TRAVEL_ACTIVE = "TRAVEL_ACTIVE";
const string KEY_TRAVEL_FROM_CITY = "TRAVEL_FROM_CITY";
const string KEY_TRAVEL_TO_CITY = "TRAVEL_TO_CITY";
const string KEY_TRAVEL_START_MS = "TRAVEL_START_MS";
const string KEY_TRAVEL_ARRIVAL_MS = "TRAVEL_ARRIVAL_MS";
const string KEY_TRAVEL_SEED = "TRAVEL_SEED";
const int INT_MAX_VALUE = 2147483647;
const int INT_MIN_VALUE = -2147483647 - 1;

const string KEY_ENCOUNTER_LAST_MS = "ENCOUNTER_LAST_MS";
const string KEY_ENCOUNTER_LAST_BUCKET = "ENCOUNTER_LAST_BUCKET";
const string KEY_ENCOUNTER_SEVERITY_MILLI = "ENCOUNTER_SEVERITY_MILLI";
const string KEY_ENCOUNTER_ACTOR_TYPE = "ENCOUNTER_ACTOR_TYPE";
const string KEY_ENCOUNTER_KIND = "ENCOUNTER_KIND";
const string KEY_ENCOUNTER_STARTS_IN_COMBAT = "ENCOUNTER_STARTS_IN_COMBAT";

const string KEY_BALANCE = "BALANCE";
const string KEY_TRADE_GUI_LINES = "TRADE_GUI_LINES";
const string KEY_TRADE_GUI_HEADER = "TRADE_GUI_HEADER";
const string KEY_TRADE_GUI_TAB = "TRADE_GUI_TAB";
const string KEY_TRADE_CITY_LINES = "TRADE_CITY_LINES";
const string KEY_TRADE_CITY_HEADER = "TRADE_CITY_HEADER";
const string KEY_RESOURCE_TRADE_MODE = "RESOURCE_TRADE_MODE";
const string KEY_CITY_GUARD_RESPONSE_MILLI = "CITY_GUARD_RESPONSE_MILLI";
const string KEY_CITY_GUARD_SEARCH_MILLI = "CITY_GUARD_SEARCH_MILLI";
const string KEY_CITY_GUARD_FORCE_MILLI = "CITY_GUARD_FORCE_MILLI";
const string KEY_CITY_TRADE_TAX_MILLI = "CITY_TRADE_TAX_MILLI";
const string KEY_CITY_CONTRABAND_MILLI = "CITY_CONTRABAND_MILLI";
const string KEY_CITY_POPULATION_MILLI = "CITY_POPULATION_MILLI";
const string KEY_CITY_POPULATION_DELTA_MILLI = "CITY_POPULATION_DELTA_MILLI";
const string KEY_CITY_DEMAND_DELTA_MILLI = "CITY_DEMAND_DELTA_MILLI";
const string KEY_CITY_SUPPLY_DELTA_MILLI = "CITY_SUPPLY_DELTA_MILLI";
const string KEY_CITY_PROSPERITY_DELTA_MILLI = "CITY_PROSPERITY_DELTA_MILLI";
const string KEY_CITY_TRAFFIC_DELTA_MILLI = "CITY_TRAFFIC_DELTA_MILLI";
const string KEY_CITY_RACIAL_PRESSURE_MILLI = "CITY_RACIAL_PRESSURE_MILLI";

const int TRADE_STORAGE_PERSONAL = 0;
const int TRADE_STORAGE_CAMP = 1;

const int TRADE_MODE_STANDARD = 0;
const int TRADE_MODE_RESOURCE = 1;

const int TRADE_GUI_TAB_GOODS = 0;
const int TRADE_GUI_TAB_CITY = 1;

int AbsInt(int nValue)
{
    if (nValue == INT_MIN_VALUE)
    {
        return INT_MAX_VALUE;
    }

    return nValue < 0 ? -nValue : nValue;
}

string CityExistsKey(int nCityId)
{
    return "CITY_EXISTS_" + IntToString(nCityId);
}

int ClampMinInt(int nValue, int nMin)
{
    return nValue < nMin ? nMin : nValue;
}

int SaturatingAddInt(int nLeft, int nRight)
{
    if (nRight > 0 && nLeft > (INT_MAX_VALUE - nRight))
    {
        return INT_MAX_VALUE;
    }

    if (nRight < 0 && nLeft < (INT_MIN_VALUE - nRight))
    {
        return INT_MIN_VALUE;
    }

    return nLeft + nRight;
}

string CityXKey(int nCityId)
{
    return "CITY_X_" + IntToString(nCityId);
}

string CityYKey(int nCityId)
{
    return "CITY_Y_" + IntToString(nCityId);
}

string CityDemandMilliKey(int nCityId)
{
    return "CITY_DEMAND_MILLI_" + IntToString(nCityId);
}

string CityOwnerKey(int nCityId)
{
    return "CITY_OWNER_" + IntToString(nCityId);
}

string CityLawPackageKey(int nCityId)
{
    return "CITY_LAW_PACKAGE_" + IntToString(nCityId);
}

string CityLawRevisionKey(int nCityId)
{
    return "CITY_LAW_REVISION_" + IntToString(nCityId);
}

string LawPackageExistsKey(int nPackageId)
{
    return "LAW_PACKAGE_EXISTS_" + IntToString(nPackageId);
}

string LawPackageGuardResponseMilliKey(int nPackageId)
{
    return "LAW_PACKAGE_GUARD_RESPONSE_MILLI_" + IntToString(nPackageId);
}

string LawPackageGuardSearchMilliKey(int nPackageId)
{
    return "LAW_PACKAGE_GUARD_SEARCH_MILLI_" + IntToString(nPackageId);
}

string LawPackageGuardForceMilliKey(int nPackageId)
{
    return "LAW_PACKAGE_GUARD_FORCE_MILLI_" + IntToString(nPackageId);
}

string LawPackageTradeTaxMilliKey(int nPackageId)
{
    return "LAW_PACKAGE_TRADE_TAX_MILLI_" + IntToString(nPackageId);
}

string LawPackageContrabandMilliKey(int nPackageId)
{
    return "LAW_PACKAGE_CONTRABAND_MILLI_" + IntToString(nPackageId);
}

string LawPackageDemandDeltaMilliKey(int nPackageId)
{
    return "LAW_PACKAGE_DEMAND_DELTA_MILLI_" + IntToString(nPackageId);
}

string LawPackageSupplyDeltaMilliKey(int nPackageId)
{
    return "LAW_PACKAGE_SUPPLY_DELTA_MILLI_" + IntToString(nPackageId);
}

string LawPackageProsperityDeltaMilliKey(int nPackageId)
{
    return "LAW_PACKAGE_PROSPERITY_DELTA_MILLI_" + IntToString(nPackageId);
}

string LawPackageTrafficDeltaMilliKey(int nPackageId)
{
    return "LAW_PACKAGE_TRAFFIC_DELTA_MILLI_" + IntToString(nPackageId);
}

string LawPackagePopulationDeltaMilliKey(int nPackageId)
{
    return "LAW_PACKAGE_POPULATION_DELTA_MILLI_" + IntToString(nPackageId);
}

string LawPackageRacialPressureMilliKey(int nPackageId)
{
    return "LAW_PACKAGE_RACIAL_PRESSURE_MILLI_" + IntToString(nPackageId);
}

string CitySupplyMilliKey(int nCityId)
{
    return "CITY_SUPPLY_MILLI_" + IntToString(nCityId);
}

string CityProsperityMilliKey(int nCityId)
{
    return "CITY_PROSPERITY_MILLI_" + IntToString(nCityId);
}

string CityTrafficMilliKey(int nCityId)
{
    return "CITY_TRAFFIC_MILLI_" + IntToString(nCityId);
}

string CityPopulationMilliKey(int nCityId)
{
    return "CITY_POPULATION_MILLI_" + IntToString(nCityId);
}

string PartyMemberSlotKey(int nIndex)
{
    return "PARTY_MEMBER_" + IntToString(nIndex);
}

string NeedActivityMilliKey()
{
    return "NEED_ACTIVITY_MILLI";
}

string ListPriceKey(int nItemId)
{
    return "LIST_PRICE_" + IntToString(nItemId);
}

string ListStockKey(int nItemId)
{
    return "LIST_STOCK_" + IntToString(nItemId);
}

string InventoryKey(int nItemId)
{
    return "INV_" + IntToString(nItemId);
}

string CampInventoryKey(int nItemId)
{
    return "CAMP_INV_" + IntToString(nItemId);
}

string TradeGuiLineKey(int nIndex)
{
    return "TRADE_GUI_LINE_" + IntToString(nIndex);
}

string TradeGuiCityLineKey(int nIndex)
{
    return "TRADE_CITY_LINE_" + IntToString(nIndex);
}

string ListWholesalePriceKey(int nItemId)
{
    return "LIST_WHOLESALE_PRICE_" + IntToString(nItemId);
}

string ListWholesaleStockTonsKey(int nItemId)
{
    return "LIST_WHOLESALE_STOCK_TONS_" + IntToString(nItemId);
}

string ListWholesaleLotTonsKey(int nItemId)
{
    return "LIST_WHOLESALE_LOT_TONS_" + IntToString(nItemId);
}

string CargoLedgerTonsKey(int nItemId)
{
    return "CARGO_LEDGER_TONS_" + IntToString(nItemId);
}

string AL2SyncFieldKey(string sField)
{
    return "AL2_SYNC_" + sField;
}
