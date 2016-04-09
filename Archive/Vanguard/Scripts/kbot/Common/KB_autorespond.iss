/*
Alarm and Auto-response code
*/

#define ALARMSOUND	"${Script.CurrentDirectory}/sounds/alarm.wav"
#define DETECTSOUND	"${Script.CurrentDirectory}/sounds/detect.wav"
#define TELLSOUND	"${Script.CurrentDirectory}/sounds/tell.wav"
#define LEVELSOUND	"${Script.CurrentDirectory}/sounds/level.wav"
#define WARNSOUND	"${Script.CurrentDirectory}/sounds/warning.wav"

#define CHATCOOL 600

variable bool isSquelched = FALSE
variable bool isGMDetected = FALSE
variable bool ChatAlarm = FALSE
variable time ChatAlarmTimer

variable bool monName = TRUE			;for say
variable bool monTell = TRUE			;15
variable bool monTransport = TRUE		;18
variable bool monLevel = TRUE			;19
variable bool monSay = TRUE				;3
variable bool monShout = TRUE			;4
variable bool monPCEmote = TRUE			;5
variable bool monBC = TRUE				;39 (serverwide) & 77 (localserver)


/* Find and execute an Auto-response */
function findAutoResponse(string aText, string aName)
{
	variable iterator anIter
	variable string aMatch
	variable int aDelay
	variable string aReply
	variable string aEmote
	variable string aAction
	variable time aTime

	call DebugIt "VG:AR: called with: ${aText}"

	setAutoRespond:GetSetIterator[anIter]
	if !${anIter:First(exists)}
	{
		call DebugIt "VG:AR: No auto-reponse values found in setAutoRespond"
		return
	}

	do
	{
		call DebugIt "VG:AR: Testing # ${anIter.Key}"

		if ${setAutoRespond.FindSet[${anIter.Key}].FindSetting[match](exists)}
		{
			aMatch:Set[${setAutoRespond.FindSet[${anIter.Key}].FindSetting[match]}]

			call DebugIt "VG:AR: test with aMatch: ${setAutoRespond.FindSet[${anIter.Key}].FindSetting[match]}"

			if ${aText.Find[${aMatch}]} || ${aMatch.Equal[ANY]}
			{
				; Found a match, now test timestamp
				if  ${Time.Timestamp} > ${setAutoRespond.FindSet[${anIter.Key}].FindSetting[time,0]}
				{
					; Make sure we don't repeat ourselves too often... once every 2 mins is good
					setAutoRespond.FindSet[${anIter.Key}]:AddSetting[time,${Math.Calc[${Time.Timestamp} + 120]}]
					aDelay:Set[${Math.Calc[10 * ${setAutoRespond.FindSet[${anIter.Key}].FindSetting[delay]}]}]

					if !${isGMDetected} && ${setAutoRespond.FindSet[${anIter.Key}].FindSetting[gmonly,FALSE]}
					{
						; GM's only on that response
						call DebugIt "VG:AR: gmonly response"
						continue
					}

					; Find what type of action it is and set up a time to execute it
					if ${setAutoRespond.FindSet[${anIter.Key}].FindSetting[reply](exists)}
					{
						call DebugIt "VG:AR: reply: ${setAutoRespond.FindSet[${anIter.Key}].FindSetting[reply]}"
						if ${aName.Equal[NONE]}
						{
							TimedCommand ${aDelay} "VGExecute /reply ${setAutoRespond.FindSet[${anIter.Key}].FindSetting[reply]}"
						}
						else
						{
							TimedCommand ${aDelay} "VGExecute /tell ${aName} ${setAutoRespond.FindSet[${anIter.Key}].FindSetting[reply]}"
						}
						return
					}
					elseif ${setAutoRespond.FindSet[${anIter.Key}].FindSetting[emote](exists)}
					{
						call DebugIt "VG:AR: emote: ${setAutoRespond.FindSet[${anIter.Key}].FindSetting[emote]}"
						TimedCommand ${aDelay} "VGExecute ${setAutoRespond.FindSet[${anIter.Key}].FindSetting[emote]}"
						return
					}
					elseif ${setAutoRespond.FindSet[${anIter.Key}].FindSetting[say](exists)}
					{
						call DebugIt "VG:AR: say: ${setAutoRespond.FindSet[${anIter.Key}].FindSetting[say]}"
						TimedCommand ${aDelay} "VGExecute /say ${setAutoRespond.FindSet[${anIter.Key}].FindSetting[say]}"
						return
					}
					elseif ${setAutoRespond.FindSet[${anIter.Key}].FindSetting[action](exists)}
					{
						call DebugIt "VG:AR: action: ${setAutoRespond.FindSet[${anIter.Key}].FindSetting[action]}"
						TimedCommand ${aDelay} "VG:ExecBinding[${setAutoRespond.FindSet[${anIter.Key}].FindSetting[action]}]"
						return
					}
				}
				else
				{
					call DebugIt "VG:AR: still waiting for timeout on: ${aMatch}"
				}
			}
		}
	}
	while ${anIter:Next(exists)}
}

/* Try to detect if this is a GM */
function testNameForGM(string aName)
{
	if ${Pawn[${aName}].Title.Find[Crimson Fellowship]}
	{
		call GMAlarm
		isGMDetected:Set[TRUE]
		call DebugIt "VG: ALARM! Crimson Fellowship detected"
	}

	if ${aName.Find[GM-]}
	{
		call GMAlarm
		isGMDetected:Set[TRUE]
		call DebugIt "VG: ALARM! GM- detected"
	}

	if ${aName.Find[Zodero]} || ${aName.Find[Tyathera]} || ${aName.Find[Zwee]} || ${aName.Find[Tiara]} || ${aName.Find[Nethe]} || ${aName.Find[Volson]} || ${aName.Find[Daegarmo]} || ${aName.Find[Kardoras]} || ${aName.Find[Akila]} || ${aName.Find[Vizu]}
	{
		call GMAlarm
		isGMDetected:Set[TRUE]
		call DebugIt "VG: ALARM! Name match detected"
	}

	if ${aName.Find[Knight]} || ${aName.Find[Lady]} || ${aName.Find[Squire]}
	{
		call GMAlarm
		isGMDetected:Set[TRUE]
		call DebugIt "VG: ALARM! Knight detected detected"
	}
}

function testTell(string aText)
{
	; Of the form:
	; From [<pcname>GM-Volson</link>]: Hello, this is GM Volson. Are you there?
	/*
	GM Zodero
	GM Tyathera
	GM Zwee
	GM Tiara
	GM Nethe
	GM Volson
	GM Daegarmo
	GM Kardoras
	*/

	variable string aName
	variable string aTell

	call DebugIt "VGAlarm: testing Tell: ${aText}"

	aName:Set[${aText.Token[2,">"].Token[1,"<"]}]

	call DebugIt "VGAlarm: aName: ${aName}"

	call testNameForGM "${aName}"

	if ${doTellAlarm}
	{
		call TellAlarm
	}

	if (${doGMRespond} && ${isGMDetected}) || ${doPlayerRespond}
	{
		if ${isAutoRespondLoaded}
		{
			call findAutoResponse "${aText}" "${aName}"
		}
		elseif ${Math.Calc[${Time.Timestamp} - ${ChatAlarmTimer.Timestamp}]} > CHATCOOL
		{
			ChatAlarmTimer:Set[${Time.Timestamp}]

			if (${aText.Find[Hello]} || ${aText.Find[Hi]} || ${aText.Find[Hey]})
			{
				TimedCommand 40 "VGExecute /reply Hiya"
			}
			elseif (${aText.Find[?]})
			{
				TimedCommand 60 "VGExecute /reply yes?"
			}
			else
			{
				TimedCommand 50 "VGExecute /reply ok"
			}
		}
	}

	if ${isGMDetected}
	isGMDetected:Set[FALSE]

}

function testSayEmoteText(string aText)
{
	; Of the form:
	; Thorfinn cheers for MyName.
	; GM-Volson waves at MyName.

	variable string aName

	call DebugIt "VGAlarm: testing emote: ${aText}"

	aName:Set[${aText.Token[1," "]}]

	if ${aName.Equal[${Me.FName}]}
	{
		return
	}

	call testNameForGM "${aName}"

	if (${doGMRespond} && ${isGMDetected}) || ${doPlayerRespond}
	{
		if ${aText.Find[${Me.FName}]}
		{
			if ${isAutoRespondLoaded}
			{
				call findAutoResponse "${aText}" "${aName}"
			}
			elseif ${Math.Calc[${Time.Timestamp} - ${ChatAlarmTimer.Timestamp}]} > CHATCOOL
			{
				ChatAlarmTimer:Set[${Time.Timestamp}]

				TimedCommand 50 "VGExecute /bow"
			}
		}
	}

	if ${isGMDetected}
	isGMDetected:Set[FALSE]
}

function testPawn(string aName)
{
	if ${Pawn[${aName}].Title.Find[Crimson Fellowship]}
	{
		call GMDetect
		TimedCommand 60 "call GMDetect"
		call DebugIt "VG: ALARM! Crimson Fellowship detected"
	}
}

function EchoAlarm(string aText, int Number)
{
	call DebugIt "VGAlarm Tripped: (${Number}) :: ${aText}"
}

function AutoRespond(string aText, int Number)
{
	if ${aText.Find[GM-]} && (${Number} == 25 || ${Number} == 36)
	{
		call TellsOut "${aText}"
		call GMAlarm
		TimedCommand 60 "call GMAlarm"

		if ${doGMRespond} && ${isAutoRespondLoaded}
		{
			call findAutoResponse "${aText}" "NONE"
		}
	}

	if ${aText.Find[You have been summoned]} && (${Number} == 18)
	{
		call TellsOut "${aText}"
		call GMAlarm
		TimedCommand 60 "call GMAlarm"

		if ${doGMRespond} && ${isAutoRespondLoaded}
		{
			call findAutoResponse "${aText}" "NONE"
		}
	}

	if ${aText.Find[Your Crafting level is now]} && (${Number} == 19)
	{
		call TellsOut "${aText}"

		call LevelAlarm

		if ${doPlayerRespond} && ${isAutoRespondLoaded}
		{
			call findAutoResponse "${aText}" "NONE"
		}
	}
	if ${aText.Find[You have gained a level]} && (${Number} == 19)
	{
		call TellsOut "${aText}"

		call LevelAlarm

		if ${doPlayerRespond} && ${isAutoRespondLoaded}
		{
			call findAutoResponse "${aText}" "NONE"
		}
	}

	if ${aText.Find[Your spirit will release in]} && (${Number} == 0)
	{
		call TellsOut "${aText}"

		call PlaySound ALARMSOUND
		StopBot
	}

	if ${aText.Find[servers will be coming down]} && (${Number} == 39)
	{
		call TellsOut "${aText}"

		if ${doServerDown}
		{
			StopBot
		}
	}

	if ${aText.Find[From ]} && (${Number} == 15)
	{
		call TellsOut "${aText}"

		call testTell "${aText}"
		call EchoAlarm "${aText}" "${Number}"
	}
	if (${Number} == 3)
	{
		if ${aText.Find[${Me.FName}]}
		{
			call TellsOut "${aText}"
			call EchoAlarm "${aText}" "${Number}"
		}
	}
	if (${Number} == 4)
	{
		if ${aText.Find[${Me.FName}]}
		{
			call TellsOut "${aText}"
			call EchoAlarm "${aText}" "${Number}"
		}
	}
	if (${Number} == 5)
	{
		call testSayEmoteText "${aText}"
		if ${aText.Find[${Me.FName}]}
		{
			call TellsOut "${aText}"
			call EchoAlarm "${aText}" "${Number}"
		}
		elseif ${aText.Find[GM-]}
		{
			call GMAlarm
			TimedCommand 60 "call GMAlarm"
		}
	}
	if (${Number} == 8)
	{
		if ${aText.Find["invited you to join"]}
		{
			call TellsOut "${aText}"

			if ${doTellAlarm}
			{
				call TellAlarm
			}
		}
	}
	if (${Number} == 39)
	{
		call TellsOut "${aText}"
		call EchoAlarm "${aText}" "${Number}"
	}
	if (${Number} == 77)
	{
		call TellsOut "${aText}"
		call EchoAlarm "${aText}" "${Number}"
	}

}


function GMAlarm()
{
	if ${doGMAlarm}
	{
		if !${Me.InCombat}
		{
			isPaused:Set[TRUE]
			VGExecute /cleartarget
		}

		isGMDetected:Set[TRUE]

		call ScreenOut "VG: -=+ GM detected +=- +++ now PAUSED ++++ "
		call DebugIt "VG: -=+ GM detected +=- +++ now PAUSED ++++ "

		call PlaySound ALARMSOUND
		call PlaySound ALARMSOUND
	}
}

function testGMAlarm()
{
	call PlaySound ALARMSOUND
}

function GMDetect()
{
	if ${doDetectGM}
	{
		call ScreenOut "VG: CAUTION: ===== Detected a GM!  ====="
		call DebugIt "VG: CAUTION: ===== Detected a GM!  ====="
		isGMDetected:Set[TRUE]
		call PlaySound DETECTSOUND
	}
}

function testGMDetect()
{
	call PlaySound DETECTSOUND
}

function TellAlarm()
{
	if ${doTellAlarm}
	{
		call DebugIt "VG: tellAlarm"
		call PlaySound TELLSOUND
	}
}

function testTellAlarm()
{
	call DebugIt "VG: tellAlarm"
	call PlaySound TELLSOUND
}

function WarnAlarm()
{
	call DebugIt "VG: WarnAlarm"
	call PlaySound WARNSOUND
}

function LevelAlarm()
{
	if ${doLevelAlarm}
	{
		call DebugIt "VG: levelAlarm"
		call PlaySound LEVELSOUND
	}
}

function testLevelAlarm()
{
	call PlaySound LEVELSOUND
}

function PlaySound(string Filename)
{
	System:APICall[${System.GetProcAddress[WinMM.dll,PlaySound].Hex},Filename.String,0,"Math.Dec[22001]"]
}

function TellsOut(string aText)
{
	variable string TellsFile = "${Script.CurrentDirectory}/save/${Me.FName}_tells.log"

	if ${Verbose}
	{
		echo ${aText}
	}
	redirect -append "${TellsFile}" echo "${Time}:: ${aText}"
}

;function Squelch()
;{
;	echo "Alarm is Squelched!"
;	isSquelched:Set[TRUE]
;	TimedCommand 600 isSquelched:Set[FALSE]
;	TimedCommand 600 echo "Alarm is no longer Squelched!"
;}

;function Unsquelch()
;{
;	echo "Alarm is no longer Squelched!"
;	isSquelched:Set[FALSE]
;	UIElement[Title@TitleBar@Alarm]:SetText["Alarm - ARMED"]
;}