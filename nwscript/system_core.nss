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

const string KEY_ENCOUNTER_LAST_MS = "ENCOUNTER_LAST_MS";
const string KEY_ENCOUNTER_SEVERITY_MILLI = "ENCOUNTER_SEVERITY_MILLI";
const string KEY_ENCOUNTER_ACTOR_TYPE = "ENCOUNTER_ACTOR_TYPE";
const string KEY_ENCOUNTER_KIND = "ENCOUNTER_KIND";
const string KEY_ENCOUNTER_STARTS_IN_COMBAT = "ENCOUNTER_STARTS_IN_COMBAT";

const string KEY_BALANCE = "BALANCE";
const string KEY_TRADE_GUI_LINES = "TRADE_GUI_LINES";
const string KEY_TRADE_GUI_HEADER = "TRADE_GUI_HEADER";

const int TRADE_STORAGE_PERSONAL = 0;
const int TRADE_STORAGE_CAMP = 1;

int AbsInt(int nValue)
{
    return nValue < 0 ? -nValue : nValue;
}

int ClampMinInt(int nValue, int nMin)
{
    return nValue < nMin ? nMin : nValue;
}

string CityXKey(int nCityId)
{
    return "CITY_X_" + IntToString(nCityId);
}

string CityYKey(int nCityId)
{
    return "CITY_Y_" + IntToString(nCityId);
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
