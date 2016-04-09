/* -----------------------------------------------------------------------------------
 * EQ2AFKAlarm.iss, Version 1.1 29-Nov-2008 
 *
 * Currently maintained by Valerian
 *
 * Orignal port to EQ2 by SuperNoob
 * 
 * *Major* swipe from the AFKAlarm system developed for WoW, kudos to
 * - Original Author: BobTest, Jackalo
 * - Current Author: Tenshi
 * - Last Updated: 10/01/06
 * - Comments: Alerts you with a sound when certain things happen. 
 *
 * Intent is to borrow all the good stuff and make it work for EQ2 and then extend it further
 *
 * New features Added:
 * 
 * Text-To-Speech ->  Allows by channel to have message converted to speach
 *                    via the ISXTTS Module.  Note TTS will be pre-empted by text that matches
 *                    text Filter triggers for other actions 
 *
 * To be added features:
 *   - ISXAIM Support
 *   - auto response to key word phrases
 * 
 */

#include ${LavishScript.HomeDirectory}/Scripts/EQ2Common/Debug.iss
#include Include/Config.iss
#include Include/Console_and_Logging.iss
#define MESSAGE_TYPE_SAY 1
#define MESSAGE_TYPE_TELL 2
#define MESSAGE_TYPE_GUILD 3
#define MESSAGE_TYPE_GROUP 4
#define MESSAGE_TYPE_RAID 5
#define MESSAGE_TYPE_OFFICER 7

; flag for testing
#define IGNORE_MY_CONVO TRUE

function main(string argv)
{
	Debug:Enable
	
	echo EQ2AFKAlarm starting...
	#include "eq2checkext.iss"

	;extension -require isxeq2
	;extension -require isxtts
	;squelch module -add lsmtts

		
	declare	EQ2AFKAlarm_version_devel	bool	script	FALSE

	declare EQ2AFKAlarm_version_major	int	script	1
	declare EQ2AFKAlarm_version_minor	int	script	1
	declare EQ2AFKAlarm_version_rev	int	script	0
	declare EQ2AFKAlarm_version	string	script	${EQ2AFKAlarm_version_major}.${EQ2AFKAlarm_version_minor}.${EQ2AFKAlarm_version_rev}

	declare AFKAlarmTimer	int	script	0

	declare TriggerSays	bool	script	FALSE
	declare TriggerTells	bool	script	FALSE
	declare TriggerGroup	bool	script	FALSE
	declare TriggerRaid	bool	script	FALSE
	declare TriggerGuild	bool	script	FALSE
	declare TriggerOfficer	bool	script	FALSE
	
	declare TTSSays	bool	script	FALSE
	declare TTSTells	bool	script	FALSE
	declare TTSGroup	bool	script	FALSE
	declare TTSRaid	bool	script	FALSE
	declare TTSGuild	bool	script	FALSE
	declare TTSOfficer	bool	script	FALSE
	
	declare TriggerMySays		bool	script	FALSE
	declare TriggerMyTells	bool	script	FALSE
	declare TriggerMyGroup		bool	script	FALSE
	declare TriggerMyRaid		bool	script	FALSE
	declare TriggerMyGuild		bool	script	FALSE
	declare TriggerMyOfficer	bool	script	FALSE
	
	declare CountSays	int	script	0
	declare CountTells	int	script	0
	declare CountGroup	int	script	0
	declare CountRaid	int	script	0
	declare CountGuild	int	script	0
	declare CountOfficer	int	script	0
	
	declare SoundfileChimes	string	script	"${Script.CurrentDirectory}/Sounds/chatalarm.wav"
	declare SoundfileChord	string	script	"${Script.CurrentDirectory}/Sounds/disarm.wav"
	declare SoundfileDing	string	script	"${Script.CurrentDirectory}/Sounds/ping.wav"
	declare SoundfileNotify	string	script	"${Script.CurrentDirectory}/Sounds/intercom.wav"
	declare SoundfilePhaser string script "${Script.CurrentDirectory}/Sounds/PHASER.wav"

	declare DefaultSound	string	script	${SoundFileDing}
	declare DefaultLoudSound string script ${SoundfilePhaser}

	; declare Triggers

	declare PlayersIgnored index:string script
	declare PlayersIgnoredTime index:int script
	declare AFKTriggerSettings string script "${Script.CurrentDirectory}/Data/afktriggers.xml"
	declare AFKTriggers settingsetref script
	
	declare Logging		bool	script	FALSE

	declare ConfigFile	string	script	"${Script.CurrentDirectory}/Data/Config.xml"

	declare LogFile		file	script	"${Script.CurrentDirectory}/Data/${Me}/Logs/${Time.Year}-${Time.Month}-${Time.Day}_${Time.Time24.Replace[:,REMOVE]}.txt"

	declare Log debug script
	Log:SetFilename[${LogFile}]
	Log:SetPrefix[""]

	call CheckForConfigFolders

	ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/EQ2.xml"
	ui -reload -skin eq2 "${Script.CurrentDirectory}/Interface/EQ2AFKAlarmUI.xml"

	call config_load
	LavishSettings:AddSet[AFKTriggers]
	AFKTriggers:Set[${LavishSettings[AFKTriggers]}]
	
	AddTrigger MySays	"@speaker@ says, \"@what@\""
	AddTrigger MyTells	"@speaker@ tells you, \"@what@\""
	AddTrigger MyGroup	"@speaker@ says to the group, \"@what@\""
	AddTrigger MyRaid	"@speaker@ says to the raid party, \"@what@\""
	AddTrigger MyGuild	"@speaker@ says to the guild, \"@what@\""
	AddTrigger MyOfficer	"@speaker@ says to the officers, \"@what@\""

/*	AddTrigger MySays	"@*@] @speaker@ says, \"@what@\""
	AddTrigger MyTells	"@*@] @speaker@ tells you,\"@what@\""
	AddTrigger MyGroup	"@*@] @speaker@ says to the group,\"@what@\""
	AddTrigger MyRaid	"@*@] @speaker@ says to the raid party,\"@what@\""
	AddTrigger MyGuild	"@*@] @speaker@ says to the guild,\"@what@\""
	AddTrigger MyOfficer	"@*@] @speaker@ says to the officers,\"@what@\""
*/	
	
	echo EQ2AFKAlarm started, processing...

	do
	{
		ExecuteQueued

		waitframe
	}
	while (1)
}

objectdef eq2string
{
	member:string CleanLinks(string TheString)
	{
		variable int count=0
		;Debug:Log["TheString = ${TheString.Replace[\",""].Escape}"]
		variable string PreLink
		variable string LinkText
		variable string Remain
		Returning:Set["${TheString.Replace[\",""].Escape}"]
		;Debug:Log["Returning = ${Returning.Escape}"]
		while ${Returning.Find["\\a"]}
		{
			PreLink:Set["${Returning.Left[${Math.Calc[${Returning.Find["\\a"]}-1]}].Escape}"]
			LinkText:Set["${Returning.Right[-${Returning.Find["\\a"]}].Token[2,:].Token[1,/]}"]
			Remain:Set["${Returning.Right[-${Math.Calc[${Returning.Find["/a"]}+1]}].Escape}"]
			;Debug:Log["${LinkText.Escape} | ${Remain.Escape}"]
			Returning:Set["${If[${PreLink.NotEqual[NULL]},"${PreLink.Escape}",""].Escape}${LinkText}${If[${Remain.Length},"${Remain.Escape}",""].Escape}"]
			;Debug:Log["Returning:Set[\"${PreLink}\" \"${LinkText}\" \"${If[${Remain.NotEqual[NULL]} && ${Remain.Length},"${Remain.Escape}",""].Escape}\"]"]
			;echo ${Returning}
			;Debug:Log[${Returning.Escape}]
			if ${count:Inc}>30
				break
		}
		return
	}
}
variable eq2string EQ2String

function PlaySound(string Filename)  
{  
	;System:APICall[${System.GetProcAddress[WinMM.dll,PlaySound].Hex},${Filename.String},0,"Math.Dec[22001]"] 
	if !${Filename.Length}
		Filename:Set[${DefaultSound}]
	playsound "${Filename}"
} 


function DebugSound()
{
	call ConsoleEcho "Testing Sound..."
	call PlaySound "${SoundfilePhaser}"
}

function CheckTriggers(string Message, string Speaker, int MsgType)
{
	variable iterator Iter
	
	AFKTriggers:Clear
	AFKTriggers:AddSet[Keywords]
	AFKTriggers:Import[${AFKTriggerSettings}]
	
	AFKTriggers.FindSet[Keywords]:GetSetIterator[Iter]
	
	if ${Iter:First(exists)}
	{
		do
		{
			if ${Message.Find[${Iter.Value.FindSetting[Word]}]}
			{
				call AFKAlarmAction ${MsgType} ${Speaker} ${Iter.Key}
				return TRUE
			}
		}
		while ${Iter:Next(exists)}
	}
	return FALSE

}

function MySays(string Line, string speaker, string message)
{
	
	if ${TriggerSays} && ${Actor[pc,exactname,${speaker}](exists)}

	{
		CountSays:Inc[1]

		call ConsoleEcho "[${speaker}] [Says] ${message}"

		call CheckTriggers "${message.EscapeQuotes}" "${speaker.EscapeQuotes}" MESSAGE_TYPE_SAY
		if ${Return}
			return
		
		if ${TTSSays} 
		{
			uplink Speak "${EQ2String.CleanLinks["${Line.Escape}"]}"
		}
		else
		{
			;Say does not match any defined triggers, so just play a sound
			call PlaySound "${SoundfilePhaser}"
		}
	}
}

function MyTells(string Line, string speaker, string message)
{
	if ${String[${speaker}].Equal[${Me.Name}]} && IGNORE_MY_CONVO
		return

	if ${TriggerTells}
	{
		CountTells:Inc[1]
		call ConsoleEcho "[${speaker}] [Tells] ${message}"

		call CheckTriggers "${message.EscapeQuotes}" "${speaker.EscapeQuotes}" MESSAGE_TYPE_TELL
		if ${Return}
			return
		
		if ${TTSTells} 
		{
			;Debug:Log["Calling CleanLinks = ${Line.Escape}"]
			uplink Speak "${EQ2String.CleanLinks["${Line.Escape}"]}"
		}
		else
		{
			;Tell does not match any defined triggers, so just play a sound.
			call PlaySound "${SoundfilePhaser}"
		}
	}
}

function MyGroup(string Line, string speaker, string message)
{
	;
	; why you would group and run afk I am not sure
	;
	if ${speaker.Equal[${Me.Name}]} && IGNORE_MY_CONVO
		return

	if ${TriggerGroup}
	{
		CountGroup:Inc[1]

		call CheckTriggers "${message.EscapeQuotes}" "${speaker.EscapeQuotes}" MESSAGE_TYPE_GROUP
		if ${Return}
			return
		
		if ${TTSGroup} 
		{
			uplink Speak "${EQ2String.CleanLinks["${Line.Escape}"]}"
		}
		else
		{
			;Does not match any defined key word triggers, so just play a sound.
			call PlaySound "${SoundfileDing}"
		}
	}
}

function MyRaid(string Line, string speaker, string message)
{
	if ${String[${speaker}].Equal[${Me.Name}]} && IGNORE_MY_CONVO
		return

	if ${TriggerRaid}
	{
		CountRaid:Inc[1]

		if ${message.Find[${Me.Name}]}
		{
		call ConsoleEcho "[${speaker}] [Raid] ${message}"
			call PlaySound "${SoundfileChimes}"
		}

		call CheckTriggers "${message.EscapeQuotes}" "${speaker.EscapeQuotes}" MESSAGE_TYPE_RAID
		if ${Return}
			return

		if ${TTSRaid} 
		{
			uplink Speak "${EQ2String.CleanLinks["${Line.Escape}"]}"
		}
		else
		{
			;Does not match any defined key word triggers, so just play a sound.
			call PlaySound "${SoundfileDing}"
		}
	}
}

function MyGuild(string Line, string speaker, string message)
{
	if ${String[${speaker}].Equal[${Me.Name}]} && IGNORE_MY_CONVO
		return

	if ${TriggerGuild}
	{
		CountGuild:Inc[1]
		
		if ${message.Find[${Me.Name}]}
		{
			call ConsoleEcho "[${speaker}] [Guild] ${message}"
			call PlaySound "${SoundfileChimes}"
		}
		
		call CheckTriggers "${message.EscapeQuotes}" "${speaker.EscapeQuotes}" MESSAGE_TYPE_GUILD
		if ${Return}
			return

		if ${TTSGuild} 
		{
			uplink Speak "${EQ2String.CleanLinks["${Line.Escape}"]}"
		}
		else
		{
			;Does not match any defined key word triggers, so just play a sound.
			call PlaySound "${SoundfileDing}"
		}
	}
}

function MyOfficer(string Line, string speaker, string message)
{
	echo officer trigger
	
	if ${String[${speaker}].Equal[${Me.Name}]} && IGNORE_MY_CONVO
		return

	if ${TriggerOfficer}
	{
		CountOfficer:Inc[1]

		call CheckTriggers "${message.EscapeQuotes}" "${speaker.EscapeQuotes}" MESSAGE_TYPE_OFFICER
		if ${Return}
			return

		if ${TTSOfficer} 
		{
			uplink Speak "${EQ2String.CleanLinks["${Line.Escape}"]}"
		}
		else
		{
			;Does not match any defined key word triggers, so just play a sound.
			call PlaySound "${SoundfileDing}"
		}
	}
}


function AFKAlarmAction(int MessageType, string Speaker, int Key)
{

	declare SecurityLevel int local ${AFKTriggers.FindSet[Keywords].FindSet[${Key}].FindSetting[SecurityLevel].Int}
	echo Security Level: ${SecurityLevel}

	switch ${SecurityLevel}
	{
		case 1
			call SecurityLevelOne ${MessageType} ${Speaker} ${Key}
			break
		case 2
			call SecurityLevelTwo ${MessageType} ${Speaker} ${Key}
			break
		case 3
			call SecurityLevelThree ${MessageType} ${Speaker} ${Key}
			break
		case 4
			call SecurityLevelFour ${MessageType} ${Speaker} ${Key}
			break
		case 5
			call SecurityLevelFive ${MessageType} ${Speaker} ${Key}
	}
}

function SecurityLevelOne(int MessageType, string Speaker, int Key)
{
	; Do Nothing
	; this is useful for filtering out the plat spam tells
	;
}

function SecurityLevelTwo(int MessageType, string Speaker, int Key)
{
	; this is for auto response based on text found in the message
	;
	declare Response string local ${AFKTriggers.FindSet[Keywords].FindSet[${Key}].FindSetting[Response]}
	declare TypingPause int local ${Math.Calc[${Math.Rand[100]}+50]}

	call IsNotIgnored ${Speaker}

	if ${Return}
	{
		if ${Return}!=2
			call AddSpeakerToIgnore ${Speaker}

		echo Waiting ${TypingPause} to type response.
		wait ${TypingPause}
		
	; this is for future to perhaps have auto responses to key word phrases
		echo ${Response}
	}
}

function SecurityLevelThree(int MessageType, string Speaker, int Key)
{
	; normal operation, play a sound.
	call PlaySound "${SoundfilePhaser}"
}

function SecurityLevelFour(int MessageType, string Speaker, int Key)
{
	call SecurityLevelTwo ${MessageType} ${Speaker} ${Key}
	call SecurityLevelThree ${MessageType} ${Speaker} ${Key}
}

function SecurityLevelFive(int MessageType, string Speaker, int Key)
{
	; For future use.
	; I plan on adding ISXAIM support to this module
	;
	call PlaySound "${SoundfilePhaser}"
	call PlaySound "${SoundfileChimes}"
	call PlaySound "${SoundfilePhaser}"
}

function AddSpeakerToIgnore(string Speaker)
{
	PlayersIgnored:Insert[${Speaker}]
	PlayersIgnoredTime:Insert[${Time.Timestamp}]
}

function IsNotIgnored(string Speaker)
{
	declare Count int local 1

	while ${PlayersIgnored.Get[${Count}].NotEqual[NULL]}
	{
		if ${PlayersIgnored.Get[${Count}].Equal[${Speaker}]}
		{
			if ${PlayersIgnoredTime.Get[${Count}]}<${Math.Calc[${Time.Timestamp}+900]}
			{
				return FALSE
			}
			else
			{
				PlayersIgnoredTime:Set[${Count},${Time.Timestamp}]
				return 2
			}
		}
	}
	return 1
}



function atexit()
{
	ui -unload "${Script.CurrentDirectory}/Interface/EQ2AFKAlarmUI.xml"
	ui -unload "${Script.CurrentDirectory}/Interface/EQ2AFKAlarm_ConfigUI.xml"

	call config_save

	LavishSettings[eq2afkalarm]:Remove
	
	RemoveTrigger MySays
	RemoveTrigger MyTells
	RemoveTrigger MyGroup
	RemoveTrigger MyRaid
	RemoveTrigger MyGuild
	RemoveTrigger MyOfficer
	
	echo EQ2AFKAlarm exiting...
}