/********************************************************************
*EQ2BotOnTell.iss                                                   *
*by: Pygar                                                          *
*use: Run EQ2BotOnTell                                              *
* Date: 3/16/09                                                      *
********************************************************************/
variable string SpellTrigger

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

#include EQ2Common/Debug.iss

function main()
{
  ext -require isxeq2

	Debug:Enable
  call Init_Triggers
	
	Echo EQ2BotOnTell Started

  do
  {
    wait 5
    ProcessTriggers()
  }
  while 1
}

function Init_Triggers()
{
	;**** Set this to whatever Command you want to be the cast command. ****
	SpellTrigger:Set[Cast]

	Event[EQ2_onIncomingChatText]:AttachAtom[EQ2_onIncomingChatText]
}

atom(script) EQ2_onIncomingChatText(int ChatType, string Message, string Speaker, string ChatTarget, string SpeakerIsNPC, string ChannelName)
{

  if ${Speaker.NotEqual[${Me.Name}]}
  {
    switch ${ChatType}
    {
      case 28
				if ${Message.Find[${SpellTrigger}]}
				{
					if ${Script[Eq2bot](exists)} && ${Message.Token[2," "].Length}<4
					{
						Debug:Echo["EQ2botOnTell: call CastSpellRange ${Message.Token[2," "]} 0 0 0 ${Target.ID}"]
						Script[EQ2Bot]:QueueCommand[call CastSpellRange ${Message.Token[2," "]} 0 0 0 ${Target.ID}]
					}
					else
					{
						Debug:Echo["EQ2botOnTell: Me.Ability[${Message.Mid[${Math.Calc[${SpellTrigger.Length}+1]},${Message.Length}]}]:Use"]
						Me.Ability[${Message.Mid[${Math.Calc[${SpellTrigger.Length}+1]},${Message.Length}]}]:Use
					}
				}
      case default
          break
    }
  }
}

function atexit()
{
	Event[EQ2_onIncomingChatText]:DetachAtom[EQ2_onIncomingChatText]
	
	Echo EQ2BotOnTell Ended
}

