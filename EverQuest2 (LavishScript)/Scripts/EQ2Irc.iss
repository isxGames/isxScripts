/********************************************************************
*EQ2IRC.iss                                                         *
*by: Ownagejoo                                                      *
*use: Run EQ2IRC                                                    *
*Change the IRC_SERVER/IRC_CHANNEL/IRC_PASSWORD/IRC_CONTROLLER      *
*to your own                                                        *
*    8 - Says                                                       *
*    9 - Shouts                                                     *
*   15 - Group Chat                                                 *
*   16 - Raid Chat                                                  *
*   18 - Guild Chat                                                 *
*   26 - NPC to Player                                              *
*   27 - Tells                                                      *
*   31 - OOC                                                        *
*   33 - All Custom CHannel Names - Name in Channel Name Variable   *
********************************************************************/
#define IRC_SERVER irc.myserver.com
#define IRC_CHANNEL #yourchannel
#define IRC_PASSWORD yourPassword
#define IRC_CONTROLLER yourircchatname
#define IRC_CONTROLLER2 yourotherircchatname

#macro ProcessTriggers()
if "${QueuedCommands}"  
{  
  do  
  {  
     ExecuteQueued  
  }  
  while "${QueuedCommands}"  
}  
#endmac

function main()
{
    ext -require isxirc
    ext -require isxeq2

    call Init_Triggers
    call IRCStartup

    do
    {
        waitframe
        ProcessTriggers()
    }
    while 1
}
function IRCStartup()
{
    Event[IRC_ReceivedChannelMsg]:AttachAtom[IRC_ReceivedChannelMsg]
    Event[EQ2_onIncomingChatText]:AttachAtom[EQ2_onIncomingChatText]
    Event[EQ2_ActorStanceChange]:AttachAtom[EQ2_ActorStanceChange]
    Event[EQ2_onInventoryUpdate]:AttachAtom[EQ2_onInventoryUpdate]
    
    IRC:Connect[IRC_SERVER,${Me.Name}]
    wait 50
    IRCUser[${Me.Name}]:Join[IRC_CHANNEL, IRC_PASSWORD]
    wait 10
    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:SetMode["+k IRC_PASSWORD"] 
}
atom(script) EQ2_onInventoryUpdate()
{
    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["My Inventory Has updated"]    
}
atom(script) EQ2_onIncomingChatText(int ChatType, string Message, string Speaker, string ChatTarget, string SpeakerIsNPC, string ChannelName)
{
    switch ${ChatType}
    {
        if ${Speaker.NotEqual[${Me.Name}]}
        {

            case 8
                IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["${Speaker} says ${Message}"]
                break
            case 9
                IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["${Speaker} Shouts ${Message}"]
                break
            case 15
                IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["Group: ${Speaker} says ${Message}"]
                break
            case 16
                IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["Raid: ${Speaker} says ${Message}"]
                break
            case 26 
            case 27
                IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["${Speaker} tells ${Me.Name} ${Message}"]
                break
            case 31
                IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["OOC: ${Speaker} says ${Message}"]
                break
            case 18
                IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["Guild: ${Speaker} says ${Message}"]
                break
            case default
                break
        }
    }
}
atom(script) EQ2_ActorStanceChange(string ActorID, string ActorName, string ActorType, string OldStance, string NewStance, string TargetID, string Distance, string IsInGroup, string IsInRaid)
{
    if ${OldStance.NotEqual[${NewStance}]} && ${ActorName.Equal[${Me.Name}]}
    {
        switch ${NewStance}
        {
            case COMBAT
                IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["${Me.Name} Has started combat"]
                break
            case AT_PEACE
                IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["${Me.Name} Has stopped combat"]
                break
            case DEAD
                IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["${Me.Name} Has died"]
                break
        }
    }
}
atom(script) IRC_ReceivedChannelMsg(string User, string Channel, string From, string Message)
{
    declare strcnt int local 1
    declare grpcnt int
    declare tempgrp int
    declare NewIrcController string

    if ${From.Equal[IRC_CONTROLLER]} || ${From.Equal[IRC_CONTROLLER2]} || ${From.Equal[${NewIrcController}]}
    {
        if "${Message.Left[1].Equal[>]}"
        {
            if "${Message.Token[2," "].Equal[${Me.Name}]}"
            {
                switch ${Message.Token[1," "]}
                {
                    case >MyExp
                        IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["Level:${Me.Level} Exp:${Me.Exp}"]
                        break
                    case >MyStatus
                        IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["Health:${Me.ToActor.Health} Power:${Me.ToActor.Power}"]
                        break
                    case >location
                        IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["Zone:${Zone.Name} Location:${Me.X} ${Me.Y} ${Me.Z}"]
                        break
                    case >MainTank
                        IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["MT : ${Script[eq2bot].Variable[MainTankPC]}"]
                        break
                    case >MainAssist
                        IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["MT : ${Script[eq2bot].Variable[MainAssist]}"]
                        break
                    case >MyBags
                        call GetMyBags
                        break
                    case default
                        break
                }
            }
        }
        if "${Message.Left[1].Equal[*]}"
        {
            switch ${Message.Token[1," "]}
            {
                case *GroupStat
                    grpcnt:Set[${Me.GroupCount}]
                    tempgrp:Set[1]
                    do
                    {
                        IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["${Me.Group[${tempgrp}].Name} H->${Me.Group[${tempgrp}].ToActor.Health} P->${Me.Group[${tempgrp}].ToActor.Health}"]
                    }
                    while ${tempgrp:Inc}<${grpcnt}
                    break
                case *GroupNames
                    grpcnt:Set[${Me.GroupCount}]
                    tempgrp:Set[1]
                    do
                    {
                        IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["${Me.Group[${tempgrp}].Name}"]
                    }
                    while ${tempgrp:Inc}<${grpcnt}
                    break
                case *NewControllerAdd
                    if ${From.Equal[IRC_CONTROLLER]} || ${From.Equal[IRC_CONTROLLER2]}
                    {
                        NewIrcController:Set[${Message.Token[2," "]}]
                    }
                case *NewControllerRemove
                    if ${From.Equal[IRC_CONTROLLER]} || ${From.Equal[IRC_CONTROLLER2]}
                    {
                        NewIrcController:Set[NULL]
                    }
                case *EndAllScripts
                    endscript *
                    break
                case *CampAll
                    EQ2Execute /camp me
                    break
                case *IRCHELP
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["Group Commands : "]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["*GroupStat - get group stats"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["*GroupNames - get group MemberNames"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["*NewControllerAdd - Add a new person to control bots"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["*NewControllerRemove - Remove the person to control bots"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["*EndAllScripts - Ends all scripts running including this one"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["*CampAll - Camps all Bots - need to quit any scripts running first"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["Individual Commands : Usage ">Command" "CharacterName""]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say[">MyExp - Current Level and Exp percentage"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say[">MyStatus - Current Health/Power of Character"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say[">location - Zone/Loc/Moving of Character"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say[">MainTank - MainTank set in Eq2Bot"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say[">MainAssist - MainAssist Set in Eq2Bot"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["Misc Commands : Usage ">Command" "CharacterName" "Optional Parameters""]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["<SetEq2BotVariable - Set a Variable in eq2bot"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["<GetEQ2BotVariable - Get Variable from eq2bot"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["<SetScriptVariable - Set a Variable in the supplied script"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["<GetScriptVariable - Get Variable from the supplied script"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["<GetTLO - Get any ISXEQ2 Object"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["<UseFunction - Uses any function in Eq2bot"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["<EQ2Command - Executes a EQ2 Command (eg /tell)"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["<Harvest - Starts Harvest script"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["<QuitHarvest - Ends Harvest script"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["<QuitScript - Stops any script"]
                    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["<StartScript - Starts the requested script"]
                    break
                case default
                    break
            }
        }
        if "${Message.Left[1].Equal[<]}"
        {
            if "${Message.Token[2," "].Equal[${Me.Name}]}"
            {

                switch ${Message.Token[1," "]}
                {
                    case <SetEq2BotVariable
                        Script[eq2bot].Variable[${Message.Token[3," "]}]:Set[${Message.Token[4," "]}]
                        break
                    case <GetEQ2BotVariable
                        IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["${Script[eq2bot].Variable[${Message.Token[3," "]}]}]
                        break
                    case <SetScriptVariable
                        Script[${Message.Token[3," "]}].Variable[${Message.Token[4," "]}]:Set[${Message.Token[5," "]}]
                        break
                    case <GetScriptVariable
                        IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["${Script[[${Message.Token[3," "]}].Variable[${Message.Token[4," "]}]}]
                        break
                    case <GetTLO
                        IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["${Message.Token[3," "]}]
                        break
                    case <UseFunction
                        Script[eq2bot]:QueueCommand[call ${Message.Right[${Math.Calc[${Message.Length}-13-${Me.Name.Length}-1]}]}]
                        break
                    case <EQ2Command
                        eq2execute ${Message.Right[${Math.Calc[${Message.Length}-12-${Me.Name.Length}-1]}]}
                        break
                    case <Harvest
                        IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["Harvesting]
                        run harvest ${Message.Token[3," "]} ${Message.Token[4," "]}
                        break
                    case <QuitHarvest
                        IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["Quiting Harvesting"]
                        endscript harvest
                        break
                    case <QuitScript
                        endscript ${Message.Token[3," "]}
                        break
                    case <StartScript
                        run ${Message.Token[3," "]}
                        break
                    case default
                        break
                }
            }
        }
    }
}
/****************************************************************************************
* Add all special Triggers that are not covers by the on_incomingChat Event below here  *   
*                                                                                       *
****************************************************************************************/
function Init_Triggers()
{
    AddTrigger GuildLogin "Guildmate: @GuildMate@ has logged @Guildlog@"
    AddTrigger TSLevel "@player@ gained a tradeskill level and is now a level @tslevel@ @tstype@."
    AddTrigger PCLevel "@player@ gained an adventure level and is now a level @ALevel@ @AClass@."
    AddTrigger PCAchive "@player@ gained an achievement point and now has @points@ points."
    AddTrigger PCLoot "@player@ looted the @ItemTier@ @LootedItem@."
}
function GuildLogin(string line2, string GuildMate, string Guildlog)
{
    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["Guildmate: ${GuildMate} has logged ${Guildlog}]
}
function TSLevel(string line2,string player, string tslevel, string tstype)
{
    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["${player} gained a tradeskill level and is now a level ${tslevel} ${tstype}."]
    ;call GratsFunction ${player}
}
function PCLevel(string player, string ALevel, string AClass)
{
    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["${player} gained an adventure level and is now a level ${ALevel} ${AClass}."]
    ;call GratsFunction ${player}
}
function PCAchive(string line2, string player, string points)
{
    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["${player} gained an achievement point and now has ${points} points."]
    ;call GratsFunction ${player}
}
function PCLoot(string line2, string player, string ItemTier, string LootedItem)
{
    IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["${player} looted the ${ItemTier} ${LootedItem}."]

}
function GratsFunction(string WhoGrats)
{
    variable int gratsvar
    gratsvar:Set[${Math.Rand[4]}]

    switch ${gratsvar}
    {
        case 0
            wait ${Math.Rand[40]:Inc[10]}
            EQ2Execute /gu Grats!!! ${WhoGrats}
            break
        case 1
            wait ${Math.Rand[40]:Inc[10]}
            EQ2Execute /gu congrats!
            break
        case 2
            wait ${Math.Rand[40]:Inc[10]}
            EQ2Execute /gu WTG
            break
        case 3
            wait ${Math.Rand[40]:Inc[10]} 
            EQ2Execute /gu gratz
            break
        case default
            break
    }
}
function GetMyBags()
{
    variable int InvCount
    variable int tempcount
    variable index:item MyInventory
    
    
    InvCount:Set[${Me.GetInventoryAtHand[MyInventory]}]
    echo ${InvCount}
    tempcount:Set[9]

    do
    {
        IRCUser[${Me.Name}].Channel[IRC_CHANNEL]:Say["${MyInventory.Get[${tempcount}].Name}"]
    }
    while ${tempcount:Inc}<=${InvCount}
}
function atexit()
{
    Event[IRC_ReceivedChannelMsg]:DetachAtom[IRC_ReceivedChannelMsg]
    Event[EQ2_onIncomingChatText]:DetachAtom[EQ2_onIncomingChatText]
    Event[EQ2_ActorStanceChange]:DetachAtom[EQ2_ActorStanceChange]
    Event[EQ2_onInventoryUpdate]:DetachAtom[EQ2_onInventoryUpdate]
    IRCUser[${Me.Name}]:Disconnect[BYE BYE] 
}
