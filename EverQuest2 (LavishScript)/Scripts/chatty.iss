vairable string myname


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
	ext -require isxeq2

	myname:Set[]

	Event[EQ2_onIncomingChatText]:AttachAtom[ChatText]
	call Init_Triggers

	do
	{
		waitframe
		ProcessTriggers()
	}
	while 1
}

function RandomChuck(string chatTarget)
{
	variable int keycount
	variable int tempvar=1
	variable string chatfile

	chatfile:Set[${LavishScript.HomeDirectory}/Scripts/XML/Chuckisms.xml]
	keycount:Set[${SettingXML[${chatfile}].Set[Chuckisms].Keys}]

	EQ2Execute /${chatTarget} ${SettingXML[${chatfile}].Set[Chuckisms].Key[${Math.Rand[${keycount}]}]}

}

function GratsFunction(string WhoGrats)
{
	variable int gratsvar
	gratsvar:Set[${Math.Rand[4]}]

	if ${WhoGrats.NotEqual[${Me.Name}]}
	{
		switch ${gratsvar}
		{

			case 0
				wait ${Math.Rand[200]:Inc[10]}
				EQ2Execute /gu Grats!!! ${WhoGrats}
				break
			case 1
				wait ${Math.Rand[200]:Inc[10]}
				EQ2Execute /gu congrats!
				break
			case 2
				wait ${Math.Rand[200]:Inc[10]}
				EQ2Execute /gu WTG
				break
			case 3
				wait ${Math.Rand[200]:Inc[10]}
				EQ2Execute /gu gratz
				break
			case default
				break
		}
	}
}

function Init_Triggers()
{
	AddTrigger TSLevel "@player@ gained a tradeskill level and is now a level @tslevel@ @tstype@."
	AddTrigger PCLevel "@player@ gained an adventure level and is now a level @ALevel@ @AClass@."
	AddTrigger PCAchive "@player@ gained an achievement point and now has @points@ points."
}

function TSLevel(string line2,string player, string tslevel, string tstype)
{
	call GratsFunction ${player}
}
function PCLevel(string player, string ALevel, string AClass)
{
	call GratsFunction ${player}
}
function PCAchive(string line2, string player, string points)
{
	call GratsFunction ${player}
}

atom(script) ChatText(int ChatType, string Message, string Speaker, string ChatTarget, string SpeakerIsNPC, string ChannelName)
{
	variable string chatDest

	if ${Speaker.NotEqual[${Me.Name}]}
	{
		switch ${ChatType}
		{
			case 18
				;guild
				if ${Message.Find[${myname}?]}
				{
					EQ2Execute /gu "Yes ${Speaker}?"
				}

				if ${Message.Find[Chuck]}
				{
					chatDest:Set[gu]
					call RandomChuck ${chatDest}
				}
				break

			case 31
				;ooc
			case 9
				;shout
			case 8
				;say
				break


			case 15
				;group
			case 26
				;tell
			case 27
				;tell
			case 16
				;raid
				if ${Message.Find[Chuck]}
				{
					chatDest:Set[say]
					call RandomChuck
				}
			default
				break
		}
	}
}