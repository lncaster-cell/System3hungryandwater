// camp_system.nss
// Ultra-light camp mechanics for party members.

#include "system_core"

const int ACTIVITY_NORMAL_MILLI = 1000;
const int ACTIVITY_CAMP_MILLI   = 550;

void ApplyPartyActivityMultiplier(object oPartyLeader, int nMultiplier)
{
    int nPartySize = GetLocalInt(oPartyLeader, KEY_PARTY_SIZE);
    int i = 0;

    while (i < nPartySize)
    {
        object oMember = GetLocalObject(oPartyLeader, PartyMemberSlotKey(i));
        if (GetIsObjectValid(oMember))
        {
            SetLocalInt(oMember, NeedActivityMilliKey(), nMultiplier);
        }
        i = i + 1;
    }
}

void SetPartyCampState(object oPartyLeader, int bInCamp)
{
    int bCamp = bInCamp ? TRUE : FALSE;
    int nMultiplier = bCamp ? ACTIVITY_CAMP_MILLI : ACTIVITY_NORMAL_MILLI;

    SetLocalInt(oPartyLeader, KEY_CAMP_STATE, bCamp);
    ApplyPartyActivityMultiplier(oPartyLeader, nMultiplier);
}

int IsPartyCamped(object oPartyLeader)
{
    return GetLocalInt(oPartyLeader, KEY_CAMP_STATE);
}
