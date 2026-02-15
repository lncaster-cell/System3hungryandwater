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

    SetLocalInt(oPlayer, sInventoryKey, GetLocalInt(oPlayer, sInventoryKey) + nQty);
}

void BuildMerchantTradeGui(object oPlayer, object oMerchant, int nStorageMode, int nItemIdList[], int nCount)
{
    int nResolvedStorage = ResolveTradeStorageMode(oPlayer, nStorageMode);

    string sStorageLabel = nResolvedStorage == TRADE_STORAGE_CAMP ? "Лагерь" : "Персонаж";
    string sHeader = "Торговля | Склад: " + sStorageLabel + " | Баланс: " + IntToString(GetBalance(oPlayer));
    SetLocalString(oPlayer, KEY_TRADE_GUI_HEADER, sHeader);

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
    SetBalance(oMerchant, GetBalance(oMerchant) + nTotal);
    SetLocalInt(oMerchant, sStockKey, nStock - nQty);

    AddTradeInventory(oPlayer, nItemId, nQty, ResolveTradeStorageMode(oPlayer, nStorageMode));
    return nTotal;
}
