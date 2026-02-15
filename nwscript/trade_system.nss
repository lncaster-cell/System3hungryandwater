// trade_system.nss
// Integer-only atomic buy operation.

#include "system_core"

void SetBalance(object oActor, int nAmount)
{
    SetLocalInt(oActor, KEY_BALANCE, ClampMinInt(nAmount, 0));
}

int GetBalance(object oActor)
{
    return GetLocalInt(oActor, KEY_BALANCE);
}

void SetMerchantListing(object oMerchant, int nItemId, int nBasePrice, int nStock)
{
    if (nItemId < 0)
    {
        return;
    }

    SetLocalInt(oMerchant, ListPriceKey(nItemId), ClampMinInt(nBasePrice, 1));
    SetLocalInt(oMerchant, ListStockKey(nItemId), ClampMinInt(nStock, 0));
}

void SetResourceMerchantListing(object oMerchant, int nItemId, int nPricePerTon, int nStockTons, int nLotTons)
{
    if (nItemId < 0)
    {
        return;
    }

    SetLocalInt(oMerchant, ListWholesalePriceKey(nItemId), ClampMinInt(nPricePerTon, 1));
    SetLocalInt(oMerchant, ListWholesaleStockTonsKey(nItemId), ClampMinInt(nStockTons, 0));
    SetLocalInt(oMerchant, ListWholesaleLotTonsKey(nItemId), ClampMinInt(nLotTons, 1));
}

int ResolveTradeStorageMode(object oPlayer, int nRequestedMode)
{
    if (nRequestedMode == TRADE_STORAGE_CAMP && GetLocalInt(oPlayer, KEY_CAMP_STATE))
    {
        return TRADE_STORAGE_CAMP;
    }

    return TRADE_STORAGE_PERSONAL;
}

void AddTradeInventory(object oPlayer, int nItemId, int nQty, int nStorageMode)
{
    string sInventoryKey = InventoryKey(nItemId);
    if (nStorageMode == TRADE_STORAGE_CAMP)
    {
        sInventoryKey = CampInventoryKey(nItemId);
    }

    int nUpdatedQty = SaturatingAddInt(GetLocalInt(oPlayer, sInventoryKey), nQty);
    SetLocalInt(oPlayer, sInventoryKey, nUpdatedQty);
}

void AddCargoLedger(object oPlayer, int nItemId, int nTons)
{
    string sLedgerKey = CargoLedgerTonsKey(nItemId);
    int nUpdatedTons = SaturatingAddInt(GetLocalInt(oPlayer, sLedgerKey), nTons);
    SetLocalInt(oPlayer, sLedgerKey, nUpdatedTons);
}

void BuildMerchantTradeGui(object oPlayer, object oMerchant, int nStorageMode, int nItemIdList[], int nCount)
{
    int nResolvedStorage = ResolveTradeStorageMode(oPlayer, nStorageMode);

    string sStorageLabel = nResolvedStorage == TRADE_STORAGE_CAMP ? "Лагерь" : "Персонаж";
    string sHeader = "Торговля | Склад: " + sStorageLabel + " | Баланс: " + IntToString(GetBalance(oPlayer));
    SetLocalString(oPlayer, KEY_TRADE_GUI_HEADER, sHeader);

    SetLocalInt(oPlayer, KEY_RESOURCE_TRADE_MODE, TRADE_MODE_STANDARD);
    SetLocalInt(oPlayer, KEY_TRADE_GUI_TAB, TRADE_GUI_TAB_GOODS);
    SetLocalInt(oPlayer, KEY_TRADE_GUI_LINES, ClampMinInt(nCount, 0));

    int i = 0;
    while (i < nCount)
    {
        int nItemId = nItemIdList[i];
        int nPrice = GetLocalInt(oMerchant, ListPriceKey(nItemId));
        int nStock = GetLocalInt(oMerchant, ListStockKey(nItemId));

        string sLine = "ID:" + IntToString(nItemId)
            + " | Цена:" + IntToString(nPrice)
            + " | Остаток:" + IntToString(nStock);
        SetLocalString(oPlayer, TradeGuiLineKey(i), sLine);
        i = i + 1;
    }
}

void BuildResourceTradeGui(object oPlayer, object oMerchant, int nItemIdList[], int nCount)
{
    string sHeader = "Оптовая торговля ресурсами | Баланс: " + IntToString(GetBalance(oPlayer));
    SetLocalString(oPlayer, KEY_TRADE_GUI_HEADER, sHeader);

    SetLocalInt(oPlayer, KEY_RESOURCE_TRADE_MODE, TRADE_MODE_RESOURCE);
    SetLocalInt(oPlayer, KEY_TRADE_GUI_TAB, TRADE_GUI_TAB_GOODS);
    SetLocalInt(oPlayer, KEY_TRADE_GUI_LINES, ClampMinInt(nCount, 0));

    int i = 0;
    while (i < nCount)
    {
        int nItemId = nItemIdList[i];
        int nPrice = GetLocalInt(oMerchant, ListWholesalePriceKey(nItemId));
        int nStockTons = GetLocalInt(oMerchant, ListWholesaleStockTonsKey(nItemId));
        int nLotTons = GetLocalInt(oMerchant, ListWholesaleLotTonsKey(nItemId));

        string sLine = "ID:" + IntToString(nItemId)
            + " | Цена/т:" + IntToString(nPrice)
            + " | Остаток(т):" + IntToString(nStockTons)
            + " | Лот(т):" + IntToString(nLotTons);
        SetLocalString(oPlayer, TradeGuiLineKey(i), sLine);
        i = i + 1;
    }
}

void BuildResourceCityTabFromAmbientLive2(object oPlayer, object oSyncBus, int nCityIdList[], int nCount)
{
    string sHeader = "Параметры городов (ambientlive2)";
    SetLocalString(oPlayer, KEY_TRADE_CITY_HEADER, sHeader);
    SetLocalInt(oPlayer, KEY_TRADE_CITY_LINES, ClampMinInt(nCount, 0));

    int i = 0;
    while (i < nCount)
    {
        int nCityId = nCityIdList[i];
        int nDemand = GetLocalInt(oSyncBus, AL2SyncFieldKey(CityDemandMilliKey(nCityId)));
        int nSupply = GetLocalInt(oSyncBus, AL2SyncFieldKey(CitySupplyMilliKey(nCityId)));
        int nProsperity = GetLocalInt(oSyncBus, AL2SyncFieldKey(CityProsperityMilliKey(nCityId)));
        int nTraffic = GetLocalInt(oSyncBus, AL2SyncFieldKey(CityTrafficMilliKey(nCityId)));

        string sLine = "City:" + IntToString(nCityId)
            + " | Спрос:" + IntToString(nDemand)
            + " | Предлож:" + IntToString(nSupply)
            + " | Достаток:" + IntToString(nProsperity)
            + " | Трафик:" + IntToString(nTraffic);
        SetLocalString(oPlayer, TradeGuiCityLineKey(i), sLine);
        i = i + 1;
    }
}

void OpenResourceTradeFromDialog(object oPlayer, object oMerchant, object oSyncBus, int nItemIdList[], int nItemCount, int nCityIdList[], int nCityCount)
{
    BuildResourceTradeGui(oPlayer, oMerchant, nItemIdList, nItemCount);
    BuildResourceCityTabFromAmbientLive2(oPlayer, oSyncBus, nCityIdList, nCityCount);
}

void SetTradeGuiTab(object oPlayer, int nTab)
{
    int nSafeTab = nTab;
    if (nTab != TRADE_GUI_TAB_CITY)
    {
        nSafeTab = TRADE_GUI_TAB_GOODS;
    }

    SetLocalInt(oPlayer, KEY_TRADE_GUI_TAB, nSafeTab);
}

// Returns total price, or -1 on validation failure.
int BuyOneLine(object oPlayer, object oMerchant, int nItemId, int nQty, int nStorageMode)
{
    if (nItemId < 0 || nQty <= 0)
    {
        return -1;
    }

    string sPriceKey = ListPriceKey(nItemId);
    string sStockKey = ListStockKey(nItemId);

    int nPrice = GetLocalInt(oMerchant, sPriceKey);
    int nStock = GetLocalInt(oMerchant, sStockKey);
    if (nPrice <= 0 || nStock < nQty)
    {
        return -1;
    }

    if (nPrice > (2147483647 / nQty))
    {
        return -1;
    }

    int nTotal = nPrice * nQty;
    int nPlayerBalance = GetBalance(oPlayer);
    if (nPlayerBalance < nTotal)
    {
        return -1;
    }

    // Atomic commit for one order line.
    SetBalance(oPlayer, nPlayerBalance - nTotal);
    SetBalance(oMerchant, SaturatingAddInt(GetBalance(oMerchant), nTotal));
    SetLocalInt(oMerchant, sStockKey, nStock - nQty);

    AddTradeInventory(oPlayer, nItemId, nQty, ResolveTradeStorageMode(oPlayer, nStorageMode));
    return nTotal;
}

// Returns total price, or -1 on validation failure.
int BuyResourceLineTons(object oPlayer, object oMerchant, int nItemId, int nLots)
{
    if (nItemId < 0 || nLots <= 0)
    {
        return -1;
    }

    int nPricePerTon = GetLocalInt(oMerchant, ListWholesalePriceKey(nItemId));
    int nStockTons = GetLocalInt(oMerchant, ListWholesaleStockTonsKey(nItemId));
    int nLotTons = GetLocalInt(oMerchant, ListWholesaleLotTonsKey(nItemId));
    if (nPricePerTon <= 0 || nLotTons <= 0)
    {
        return -1;
    }

    if (nLotTons > (2147483647 / nLots))
    {
        return -1;
    }

    int nRequestedTons = nLotTons * nLots;
    if (nStockTons < nRequestedTons)
    {
        return -1;
    }

    if (nPricePerTon > (2147483647 / nRequestedTons))
    {
        return -1;
    }

    int nTotal = nPricePerTon * nRequestedTons;
    int nPlayerBalance = GetBalance(oPlayer);
    if (nPlayerBalance < nTotal)
    {
        return -1;
    }

    SetBalance(oPlayer, nPlayerBalance - nTotal);
    SetBalance(oMerchant, SaturatingAddInt(GetBalance(oMerchant), nTotal));
    SetLocalInt(oMerchant, ListWholesaleStockTonsKey(nItemId), nStockTons - nRequestedTons);

    AddCargoLedger(oPlayer, nItemId, nRequestedTons);
    return nTotal;
}
