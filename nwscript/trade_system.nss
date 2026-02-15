// trade_system.nss
// Integer-only atomic buy operation.

void SetBalance(object oActor, int nAmount)
{
    if (nAmount < 0)
    {
        nAmount = 0;
    }
    SetLocalInt(oActor, "BALANCE", nAmount);
}

int GetBalance(object oActor)
{
    return GetLocalInt(oActor, "BALANCE");
}

void SetMerchantListing(object oMerchant, int nItemId, int nBasePrice, int nStock)
{
    if (nBasePrice < 1)
    {
        nBasePrice = 1;
    }
    if (nStock < 0)
    {
        nStock = 0;
    }

    string sKeyPrice = "LIST_PRICE_" + IntToString(nItemId);
    string sKeyStock = "LIST_STOCK_" + IntToString(nItemId);
    SetLocalInt(oMerchant, sKeyPrice, nBasePrice);
    SetLocalInt(oMerchant, sKeyStock, nStock);
}

// Returns total price, or -1 on validation failure.
int BuyOneLine(object oPlayer, object oMerchant, int nItemId, int nQty)
{
    if (nQty <= 0)
    {
        return -1;
    }

    string sKeyPrice = "LIST_PRICE_" + IntToString(nItemId);
    string sKeyStock = "LIST_STOCK_" + IntToString(nItemId);

    int nPrice = GetLocalInt(oMerchant, sKeyPrice);
    int nStock = GetLocalInt(oMerchant, sKeyStock);
    if (nPrice <= 0 || nStock < nQty)
    {
        return -1;
    }

    int nTotal = nPrice * nQty;
    int nPlayerBalance = GetBalance(oPlayer);
    if (nPlayerBalance < nTotal)
    {
        return -1;
    }

    // Commit (atomic for single line).
    SetBalance(oPlayer, nPlayerBalance - nTotal);
    SetBalance(oMerchant, GetBalance(oMerchant) + nTotal);
    SetLocalInt(oMerchant, sKeyStock, nStock - nQty);

    string sKeyInv = "INV_" + IntToString(nItemId);
    SetLocalInt(oPlayer, sKeyInv, GetLocalInt(oPlayer, sKeyInv) + nQty);
    return nTotal;
}
