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
					if ${Script[Eq2bot](exists)} && ${Mesage.Token[2," "].Length}<3
					{
						Debug:Echo["call CastSpellRange ${Mesage.Token[2," "]} 0 0 0 ${Target.ID}"]
						Script[EQ2Bot]:QueueCommand[call CastSpellRange ${Mesage.Token[2," "]} 0 0 0 ${Target.ID}]
					}
					else
					{
						Me.Ability[${Mesage.Token[2," "]}]:Use
					}
				}
      case default
          break
    }
  }
}