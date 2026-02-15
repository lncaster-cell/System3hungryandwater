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

// Returns total price, or -1 on validation failure.
int BuyOneLine(object oPlayer, object oMerchant, int nItemId, int nQty)
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

    string sInventoryKey = InventoryKey(nItemId);
    SetLocalInt(oPlayer, sInventoryKey, GetLocalInt(oPlayer, sInventoryKey) + nQty);
    return nTotal;
}
