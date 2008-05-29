variable string myname
declare InsultTimer int script
declare ChuckTimer int script
variable string respondSpeaker
variable string respondTimer
variable string AssHat



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

	myname:Set[${Me.Name}]
	AssHat:Set[Mandevo]

	Event[EQ2_onIncomingChatText]:AttachAtom[ChatText]
	call Init_Triggers

	do
	{
		waitframe
		ProcessTriggers()
	}
	while 1
}

function RandomMsg(string chatTarget, string randomKey, bit PrefixName, string Speaker)
{
	variable int keycount
	variable int tempvar=1
	variable string chatfile

	chatfile:Set[${LavishScript.HomeDirectory}/Scripts/XML/Chuckisms.xml]
	keycount:Set[${SettingXML[${chatfile}].Set[${randomKey}].Keys}]

	if ${PrefixName}
	{
		EQ2Execute /${chatTarget} ${Speaker}, ${SettingXML[${chatfile}].Set[${randomKey}].GetString[${Math.Rand[${keycount}]}]}
	}
	else
	{
		EQ2Execute /${chatTarget} ${SettingXML[${chatfile}].Set[${randomKey}].GetString[${Math.Rand[${keycount}]}]}
	}
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
			case 28	;tell
			case 18
				;guild
				if ${Message.Find[${myname}?]}
				{
					EQ2Execute /gu "Yes ${Speaker}?"
					respondSpeaker:Set[${Speaker}]
					respondTimer:Set[${Time.Timestamp}]
				}
				elseif ${Speaker.Equal[${respondSpeaker}]} && ${Math.Calc[${Time.Timestamp}-${respondTimer}]}<60
				{
					EQ2Execute /gu "hmm, if you say so"
					respondSpeaker:Set[]
				}
				elseif ${Message.Left[6].Eqaul[Insult]} && ${Message.Token[2, ](exists)} && ${Math.Calc[${Time.Timestamp}-${InsultTimer}]}>60
				{
					InsultTimer:Set[${Time.Timestamp}]
					chatDest:Set[gu]
					call RandomMsg ${chatDest} Insults 1 ${Message.Token[2, ]}
				}
				elseif ${Message.Left[Private Insult]} && ${Message.Token[3, ](exists)} && ${Math.Calc[${Time.Timestamp}-${InsultTimer}]}>60
				{
					InsultTimer:Set[${Time.Timestamp}]
					chatDest:Set[tell  ${Message.Token[3, ]}]
					call RandomMsg ${chatDest} Insults 0
				}
				elseif ${Message.Find[Chuck]}
				{
					if ${Math.Calc[${Time.Timestamp}-${ChuckTimer}]}>10
					{
						ChuckTimer:Set[${Time.Timestamp}]
						chatDest:Set[gu]
						call RandomMsg ${chatDest} Chuckisms 0
					}
					else
					{
						chatDest:Set[gu]
						call RandomMsg ${chatDest} Insults 1 ${Speaker}
					}
				}
				break
			case 32 ;ooc
			case 9 	;shout
				break
			case 8
				;say
				if ${Message.Find[Chuck]}
				{
					chatDest:Set[say]
					call RandomMsg ${chatDest} Chuckisms 0
				}
				break
			case 34
				;chat
				if ${ChannelName.Find[60-69]} && ${Speaker.Find[${AssHat}]} && ${Math.Calc[${Time.Timestamp}-${InsultTimer}]}>60
				{
					InsultTimer:Set[${Time.Timestamp}]
					chatDest:Set[say]
					call RandomMsg ${chatDest} Insults 1 ${Speaker}
				}
			case 15	;group
			case 16	;raid
				if ${Math.Calc[${Time.Timestamp}-${ChuckTimer}]}>10
				{
					ChuckTimer:Set[${Time.Timestamp}]
					chatDest:Set[say]
					call RandomMsg ${chatDest} Chuckisms 0
				}
				else
				{
					chatDest:Set[say]
					call RandomMsg ${chatDest} Insults 0 ${Speaker}
				}
			default
				break
		}
	}
}