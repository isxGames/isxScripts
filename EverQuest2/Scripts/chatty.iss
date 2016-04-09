variable string myname
variable int InsultTimer
variable int ChuckTimer
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

function RandomMsg(string chatTarget, string randomKey, int PrefixName, string Speaker)
{
	variable int keycount
	variable int tempvar=1
	variable string chatfile

	chatfile:Set[${LavishScript.HomeDirectory}/Scripts/XML/Chuckisms.xml]
	keycount:Set[${SettingXML[${chatfile}].Set[${randomKey}].Keys}]

	if ${PrefixName}
	{
		echo chat with prefix
		echo /${chatTarget} ${Speaker}
		EQ2Execute /${chatTarget} ${Speaker}, ${SettingXML[${chatfile}].Set[${randomKey}].GetString[${Math.Rand[${keycount}]}]}
	}
	else
	{
		echo chat without prefix
		echo /${chatTarget}
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
	echo atom - ${ChatType}
	if ${Speaker.NotEqual[${Me.Name}]}
	{
		switch ${ChatType}
		{
			case 28
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
					respondSpeaker:Set[]`
				}
				elseif ${Message.Left[6].Equal[Insult]} && ${Message.Token[2," "](exists)} && ${Math.Calc[${Time.Timestamp}-${InsultTimer}]}>60
				{
					echo atom Insult
					InsultTimer:Set[${Time.Timestamp}]
					chatDest:Set[gu]
					echo test ${chatDest} Insults 1 ${Message.Token[2," "]} ${Speaker}
					call RandomMsg ${chatDest} Insults 1 ${Message.Token[2," "]} ${Speaker}
				}
				elseif ${Message.Left[13].Equal[PrivateInsult]} && ${Message.Token[2," "](exists)}
				{
					
					InsultTimer:Set[${Time.Timestamp}]
					chatDest:Set["tell ${Message.Token[2," "]}"]
					echo atom Private ${chatDest} Insults 0			
					call RandomMsg "${chatDest}" Insults 0
				}
				elseif ${Message.Find[Chuck]}
				{
					if ${Math.Calc[${Time.Timestamp}-${ChuckTimer}]}>10
					{
						ChuckTimer:Set[${Time.Timestamp}]
						chatDest:Set[gu]
						call RandomMsg ${chatDest} Chuckisms 0 ${Speaker}
					}
					else
					{
						chatDest:Set[gu]
						call RandomMsg ${chatDest} Insults 1 ${Speaker}
					}
				}
				break
			case 32 
			case 9 	
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
				break
				;chat
				if ${ChannelName.Find[60-69]} && ${Speaker.Find[${AssHat}]} && ${Math.Calc[${Time.Timestamp}-${InsultTimer}]}>60
				{
					InsultTimer:Set[${Time.Timestamp}]
					chatDest:Set[say]
					call RandomMsg ${chatDest} Insults 1 ${Speaker}
				}
				break
			case 15
			case 16
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
				break
			default
				break
		}
	}
}