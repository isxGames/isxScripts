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
	SpelTrigger:Set[Cast]

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
					Debug:Echo["call CastSpellRange ${Message.Mid[${Math.Calc[${SpellTrigger.Length}+1]},3]} 0 0 0 ${Target.ID}"]
					Script[EQ2Bot]:QueueCommand[call CastSpellRange ${Message.Mid[${Math.Calc[${SpellTrigger.Length}+1]},3]} 0 0 0 ${Target.ID}]
				}
      case default
          break
    }
  }
}