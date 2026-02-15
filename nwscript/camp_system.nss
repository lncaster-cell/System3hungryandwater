// camp_system.nss
// Ultra-light camp mechanics for party members.

const int ACTIVITY_NORMAL_MILLI = 1000;
const int ACTIVITY_CAMP_MILLI   = 550;

void SetPartyCampState(object oPartyLeader, int bInCamp)
{
    // 1) Save camp flag on leader object.
    SetLocalInt(oPartyLeader, "CAMP_STATE", bInCamp);

    // 2) Apply activity multiplier to all party members.
    // Party members are expected to be linked by local object slots:
    // PARTY_MEMBER_0..PARTY_MEMBER_(PARTY_SIZE-1)
    int nPartySize = GetLocalInt(oPartyLeader, "PARTY_SIZE");
    int nMultiplier = bInCamp ? ACTIVITY_CAMP_MILLI : ACTIVITY_NORMAL_MILLI;

    int i = 0;
    while (i < nPartySize)
    {
        object oMember = GetLocalObject(oPartyLeader, "PARTY_MEMBER_" + IntToString(i));
        if (GetIsObjectValid(oMember))
        {
            SetLocalInt(oMember, "NEED_ACTIVITY_MILLI", nMultiplier);
        }
        i = i + 1;
    }
}

int IsPartyCamped(object oPartyLeader)
{
    return GetLocalInt(oPartyLeader, "CAMP_STATE");
}
