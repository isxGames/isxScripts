
; ///////////////////////////////////////////////////////////////////////////

;  			   EQ2 Quest by Equidis

; ///////////////////////////////////////////////////////////////////////////


; ///////////////////////////////////////////////////////////////////////////

; Required Command (Run on all your characters in your group)

; 		    Run EQ2Quest       - Auto Accept + Auto Share
;		    Run EQ2Quest 1     - Auto Accept Only
;		    Run EQ2Quest 2     - Auto Share Only
;		    Run EQ2Quest 3     - Valerian Mode - Script exits rudely.

; Expected Result:

;		    1. Automatically Accepts Quests Offered.

;		    1. Shares your next Accepted Quest (if not shared to you).

; ///////////////////////////////////////////////////////////////////////////


variable string parseID
variable int acceptedQuestID
variable int parseLength
variable bool questAcceptedByShare
variable int shareTimer
variable int timerDiff
variable bool readyToShare
variable int questMode
variable bool questwindowAppeared



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


function questAcceptedByShare(string Line, string playerName, string questName)
{
	; The quest you just accepted was Shared with you, which means everyone in the group now has it.
	; So theres no need to share it with anyone.
	readyToShare:Set[FALSE]
	shareTimer:Set[0]
	questAcceptedByShare:Set[TRUE]
}


function readQuestData(string Line, string qinfo)
{

variable bool allowSharing

if ${questMode} == 2
{
	allowSharing:Set[TRUE]
}
else
{

if ${questMode} == 1
{
allowSharing:Set[FALSE]
}
else
{
allowSharing:Set[TRUE]
}
}

	if ${qinfo.Mid[1,2].Equal["ID"]} && ${allowSharing} && ${questwindowAppeared}
	{
		parseLength:Set[${qinfo.Length}-4]
		parseID:Set[${qinfo.Mid[4,${parseLength}]}]
		acceptedQuestID:Set[${parseID}]
		readyToShare:Set[TRUE]
		shareTimer:Set[${Time.Timestamp}]
		questwindowAppeared:Set[FALSE]
	}

		
}


function main(int questingMode)
{

questMode:Set[${questingMode}]

if ${questMode} == 3
{
eq2echo "KNOCK IT OFF VALERIAN!! <Script exits rudely now>"
endscript EQ2Quest
}


  ; AUTOMATICALLY SHARE A JUST RECEIVED QUEST
  
  AddTrigger questAcceptedByShare "@playerName@ has accepted the Quest @questName@."
  AddTrigger readQuestData QUESTDATA::@qinfo@

eq2echo ** Now automatically accepting quests and quest rewards! **

readyToShare:Set[FALSE]

do
{


     ProcessTriggers()
     waitframe


; Auto accepts quests

if ${EQ2.PendingQuestName.Equal[None]}
{
; You have no pending quests
}
else
{

readyToShare:Set[FALSE]
questAcceptedByShare:Set[FALSE]
shareTimer:Set[0]
timerDiff:Set[0]

questwindowAppeared:Set[TRUE]

if ${questMode} < 2
{
	; Accept the quest in view....
	EQ2:AcceptPendingQuest
	wait 05
	EQ2UIPage[PopUp,RewardPack].Child[button,RewardPack.Accept]:LeftClick
}

}

if ${readyToShare}
{

if ${questAcceptedByShare}
{
questwindowAppeared:Set[FALSE]
readyToShare:Set[FALSE]
questAcceptedByShare:Set[FALSE]
shareTimer:Set[0]
acceptedQuestID:Set[0]
timerDiff:Set[0]
}

; A quest is ready to be shared to others.
; We are waiting on a timer to see if the quest I received was a shared quest
; Or if I naturally picked it myself, to be shared with others.
timerDiff:Set[${Time.Timestamp} - ${shareTimer}]

if ${timerDiff} >= 2 && ${shareTimer} > 0
{
; The timer has expired. Share the quest
questwindowAppeared:Set[FALSE]
readyToShare:Set[FALSE]
questAcceptedByShare:Set[FALSE]
shareTimer:Set[0]
timerDiff:Set[0]
eq2execute /share_quest ${acceptedQuestID}

acceptedQuestID:Set[0]

}


}

}
while 1

}