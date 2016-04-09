#include obj_Bookmarks.iss
#include obj_TheShip.iss
#include obj_Entities.iss
#include obj_StatusUpdate.iss
#include obj_Agents.iss

#include obj_Salvager.iss
#include obj_Missioner.iss

;#include behaviors/obj_AssetGatherer.iss
;#include behaviors/obj_Miner.iss

variable(script) string HomeBookmarkIdentifier = "?"
variable(script) string SalvageBookmarkIdentifier = "@"
variable(script) string AssetBookmarkIdentifier = "#"
variable(script) string AsteroidBookmarkIdentifier = "$"
variable(script) string GoToBookmarkIdentifier = "*"
variable(script) string ChickenBookmarkIdentifier = "+"

variable(script) obj_Bookmarks TheBookmarks
variable(script) obj_Entities TheEntities
variable(script) obj_TheShip TheShip
variable(script) obj_Agents TheAgents

variable(script) obj_Missioner Missioner
variable(script) obj_Salvager Salvager
;variable(script) obj_AssetGatherer AssetGatherer
;variable(script) obj_Miner Miner

variable(script) string WreckingBotMode = "Salvager"
variable(script) int Slow = 20

variable(script) bool DebugOn = FALSE
variable(script) bool SalvagerStayOn = FALSE
variable(script) bool DoingMore = FALSE
variable(script) bool NoLoot = FALSE
variable(script) bool StillGoing = TRUE
variable(script) bool UseSafe = FALSE
variable(script) bool AvoidLowSec = TRUE
variable(script) bool ShieldTanker = FALSE
variable(script) bool EntityWatchOn = FALSE
variable(script) int ChickenPct = 50
variable(script) int OrbitDistance = 27000
variable(script) string MissionDoWhat
variable(script) string SalvageStage
variable(script) string BotCurrentState = Start

variable(script) obj_StatusUpdate StatusUpdate
function main()
{
	variable bool AlwaysOn = TRUE
	UI -load BotUI.xml
	BotCurrentState:Set["Paused"]
	StatusUpdate:Green["Paused"]
	
	Script:Pause
	BotCurrentState:Set["Unpaused"]
	StatusUpdate:Green["${WreckingBotMode} started"]
	StatusUpdate:Yellow["${WreckingBotMode} started"]
	
	do
	{
		BotCurrentState:Set[${WreckingBotMode}]
		switch ${WreckingBotMode}
		{
			case Salvager
				call Salvager.Begin
				break
			case AssetGatherer
				;call AssetGatherer.Begin
				break
			case Miner
				;call Miner.Begin
				break
			case Missioner
				call Missioner.Begin
				break
			case GoToBM
				TheBookmarks:Acquire[GoTo]
				if !(${MyBookmarks.Get[1](exists)})
				{
					StatusUpdate:Green["No bookmarks, pausing"]
					StatusUpdate:Red["No bookmarks"]
					break
				}
				call TheBookmarks.GoTo ${MyBookmarks.Get[1]}
				break
			case Watcher
				do
				{
					call StatusUpdate.White
				}
				while ${AlwaysOn}
			default
				StatusUpdate:Green["No bot mode selected, pausing"]
				StatusUpdate:Red["No Mode Selected"]
				break
		}
		StatusUpdate:Green["Finished current operations"]
		StatusUpdate:Yellow["Finished current operations"]
		BotCurrentState:Set["Paused"]
		Script:Pause
		UI -reload BotUI.xml
		BotCurrentState:Set["Resuming"]
		StatusUpdate:Green["Resuming"]
		;StatusUpdate:Yellow["Resuming"]
	}
	while ${AlwaysOn}
}

function atexit()
{
	UI -unload BotUI.xml
	echo Thanks for playing
}