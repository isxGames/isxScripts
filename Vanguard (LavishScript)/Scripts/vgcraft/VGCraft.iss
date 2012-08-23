#include ./vgcraft/craft-defines.iss
#include ./vgcraft/craft-actionlogic.iss
#include ./vgcraft/craft-autorespond.iss
#include ./vgcraft/craft-bnavobjects.iss
#include ./vgcraft/craft-items.iss
#include ./vgcraft/craft-move.iss
#include ./vgcraft/craft-moveto.iss
#include ./vgcraft/craft-movefaceslow.iss
#include ./vgcraft/craft-station.iss
#include ./vgcraft/craft-uilogic.iss
#include ./vgcraft/craft-workorder.iss
#include ./vgcraft/craft-IRCLib.iss

variable float VGCraft_VERSION = 2.0


/*
 * Vanguard Crafting Bot

 * Written by: Xeon

 * Additional Code from: Hendrix, Amadeus and Benelor
 *
 * LavishNav mapping code written by: Bohika
 *
 * MoveTo code by: Fippy, scubaski, and don'tdoit
 * faceslow code by: don'tdoit and Allen
 * VGSkin.exe app by Blazer


**************************************************************************

 *
 *          Special Thanks to:  **  Amadeus  ** 
 *  -- Great work on ISXVG and thanks for the coding help as well! --
 *

 */

/* **************************************** */
/*    Change these to the correct Values    */
/* **************************************** */

variable string sUtilPouch = "Utility Pouch"

/* Movement precision */
variable int movePrecision = 100
variable int objPrecision = 3
variable int maxWorkDist = 5

variable int TargetQuality = 300


/* **************************************** */

/*  Don't change anything below this line   */

/* **************************************** */



/* Global Variable Declarations */

variable bool doConsoleOut = FALSE

variable bool debug = FALSE
variable bool doComplications = TRUE
variable bool preferUtility
variable bool doPauseRecipe
variable bool doExtraIngredients
variable bool doHardFirst
variable bool doBatches
variable bool doSets
variable bool doSingles
variable bool doOpenPacks
variable bool doFactionGrind
variable bool doUseActionStore
variable bool doRepair
variable bool useSupplied = TRUE
variable bool doSlowTurn
variable bool doExactPath
variable bool doTestMove
variable bool fullAuto
variable bool autoSwitchCrafting

variable bool doGMAlarm = TRUE
variable bool doDetectGM = TRUE
variable bool doGMRespond = TRUE
variable bool doPlayerRespond = FALSE
variable bool doTellAlarm = TRUE
variable bool doSayAlarm = TRUE
variable bool doLevelAlarm = TRUE
variable bool doServerDown = TRUE

variable bool doAnyWO
variable bool doDiffWO
variable bool doModWO
variable bool doEasyWO
variable bool doVeryEasyWO
variable bool doTrivWO

variable bool autoUpdateFile
variable bool autoUpdateDone
variable bool moveDetector
variable bool isMoving
variable bool isRunning
variable bool isPaused
variable bool hasStarted
variable bool isAutoRespondLoaded
variable bool isChangingBelt
variable bool farAwayError
variable bool inCorrection
variable bool complicationRemoved

variable int getWOrder = 5

variable int apLimitRecipe
variable int minQRecipe
variable int maxQRecipe

variable int apLimit2k
variable int apLimit25k
variable int apLimit3k
variable int apLimit35k

variable int maxQ2k
variable int maxQ25k
variable int maxQ3k
variable int maxQ35k

variable int minQVEasy
variable int minQEasy
variable int minQMod
variable int minQDiff

variable int maxQVEasy
variable int maxQEasy
variable int maxQMod
variable int maxQDiff

variable int windowX
variable int windowY

variable bool doRecipeOnly
variable bool doStep1Action
variable bool doStep2Action
variable int recipeStep1Action
variable int recipeStep2Action
variable string recipeName
variable int recipeRepeatNum
variable int recipeRepeatNumDone
variable string recipeStation
variable bool doRecipeMatCheck

variable string crafterType

variable string artificerStation = "Artificer"
variable string blacksmithStation = "Blacksmith"
variable string outfitterStation = "Outfitter"

variable string moveFileName = "NONE"
variable string moveFile = ""

variable string savePath = "${Script.CurrentDirectory}/save"
variable filepath VGPathsDir = "${Script.CurrentDirectory}/vgpaths/"

variable string installPath = "${VG.InstallDirectory}"

variable string saveMoveFilePath
variable string ConfigFile
variable string ActionFile
variable string AutoRespondFile
variable string OutputFile
variable string StatsFile
variable string TellsFile

variable string cStation = "NONE"
variable string cWorkNPC = "NONE"
variable string cSupplyNPC = "NONE"
variable string cRepairNPC = "NONE"

variable bool doRefining = FALSE

variable string cRefiningStation = "NONE"
variable string cRefiningWorkNPC = "NONE"
variable string cRefiningSupplyNPC = "NONE"

variable string cFinishingStation = "NONE"
variable string cFinishingWorkNPC = "NONE"
variable string cFinishingSupplyNPC = "NONE"

variable point3f stationLoc
variable point3f workLoc
variable point3f supplyLoc
variable point3f repairLoc
variable point3f testLoc

variable string cTarget = "NONE"
variable int64 cTargetID = 0
variable point3f cTargetLoc

variable string nextDest = "NONE"

variable string destStation = "craftstation"
variable string woNPCSearch = "workordersearch"
variable string destWork = "workorder"
variable string destSupply = "supplier"
variable string destRepair = "repair"

variable float fTimer = 0

variable float fCheckProgress
variable float fLastProgress
variable float fLastProgDiff
variable int lastQuality
variable int lastQualDiff
variable int lastAP
variable int lastAPDiff
variable int apStageUsed

variable string missingItem = "NONE"

variable int iKickStep
variable int iLOSCount
variable int movePathCount

variable bool ooAPCheck = FALSE
variable bool doKickStart = FALSE
variable bool doFixRetry = FALSE

variable string currentStageName
variable string currentStepName
variable string currentActionName

variable int currentStage
variable int currentStep

variable int allowedStageAP
variable int stageAPUsed
variable int allowedStepAP
variable int stepAPUsed[10]
variable int tryKickStart[10]

variable string lastCorrection

variable collection:string IgnoredFixes
variable collection:string IgnoredComplications
variable collection:int StepProgress

variable index:int CompletedSteps

variable collection:int woRecipeFuel
variable set woRecipeNeeds

variable set woGrindCount

variable set BadRecipes
variable string BadRecipeName

variable string UIFile = "${LavishScript.CurrentDirectory}/scripts/vgcraft/VGCraftUI.xml"
variable string UISkin = "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"

/* IRC */
variable bool AutoConnectToIRC
variable string IRCServer
variable string IRCNick
variable bool bIRCChannel
variable string IRCChannel
variable bool bUseIRCMaster
variable string IRCMaster
variable bool IRCAcceptMasterCommands
variable bool IRCSpewToMasterPM
variable bool IRCSpewToChannel
variable bool IRCSpewExtraDebugText
variable bool bUseNickservIdentify
variable string NickservIdentifyPasswd
variable bool bUseChannelKey
variable string ChannelKey

/* object defined in craft-bnavobjects.iss */
variable bnav navi
variable string CurrentChunk
variable string CurrentRegion
variable string LastRegion
variable int bpathindex
variable lnavpath mypath
variable astarpathfinder PathFinder
variable lnavconnection CurrentConnection
variable bool isMapping
variable int pointcount

/* Settings variables */
variable settingsetref setConfig
variable settingsetref setPath
variable settingsetref setSaleItems
variable settingsetref setExtraItems

variable settingset actionStore
variable settingsetref setAutoRespond

/* Iteration for UI */
variable iterator setPathIterator
variable iterator sellItemListIterator


/* Current STATE of the script */
variable int cState

/* Previous STATE the script was in */
variable int pState = 0
variable int holdState = 0

/* A TimeOut timer */
variable time tTimeOut
variable time tStartTime
variable time ActionTime

/* Some Statistic Variables */
variable int startCraftXP = 0

variable int statRecipeDone = 0
variable int statRecipeFailed = 0
variable int statWODone = 0
variable int statWOAbandon = 0
variable int statCurrentCopper = 0
variable int statSpentCopper = 0
variable int startCopper = 0
variable float timeCheck = 0
variable float temp = 0
variable int tempXP = 0
variable int tempXPHour = 0
variable int lastCraftXP = 0

variable int GlobalPanicAttack = 0

variable string CurrentWorkOrderName



/* -------------------- Event Handlers ---------------------- */

/* Detect Script auto-updated files */
atom(script) VGC_onUpdatedFile(string FilePathPlusName)
{
	echo "VGCraft:: Updated file ${FilePathPlusName}"
	autoUpdateFile:Set[TRUE]
}
atom(script) VGC_onUpdateError(string ErrorName)
{
	echo "VG:ERROR: ${ErrorName}"
}
atom(script) VGC_onUpdateComplete()
{
	echo "VGCraft:: Updated of VGCraft all done!"
	autoUpdateDone:Set[TRUE]
}

atom(script) VGCB_onReceivedTradeInvitation(string PCName)
{
	call DebugOut "VGCraft:: TradeInvitation with ${PCName} :: TS: ${Trade.State}"

	if ${isPaused} || !${isRunning}
		return

	;["TRADING", "INVITE_PENDING", "INVITE_SENT", "NOT_TRADING"]
	if ${Trade.State.Equal[TRADING]} || ${Trade.State.Equal[INVITE_PENDING]} || ${Trade.State.Equal[INVITE_SENT]}
	{
		Trade:DeclineInvite

		PauseBot
		call WarnAlarm

		;if ${doPlayerRespond}
		;{
		;	TimedCommand 30 "VGExecute /tell ${PCName} Stop that!"
		;}
	}

	if ${Trade.State.Equal[TRADING]} || ${Trade.State.Equal[INVITE_PENDING]} || ${Trade.State.Equal[INVITE_SENT]}
	{
		Trade:Cancel
	}
}

/* Detect Login/Logout changes */
atom(script) VGCB_onConnectionStateChange(string NewConnectionState)
{
	;AT_CHARACTER_SELECT
	;IN_CHARACTER_CUSTOMIZATION
	;IN_GAME

	call MyOutput "VGCraft:: Connection State: ${NewConnectionState}"

	if ( ${NewConnectionState.Equal[AT_CHARACTER_SELECT]} )
	{
		; Hmm, how did we get here?
		call MyOutput " ========================================LOGOUT=================================="
		call MyOutput "VGCraft::                            Error, character logged out!"
		call MyOutput " ========================================LOGOUT=================================="
		isRunning:Set[FALSE]
		;EndScript
	}
}

/* We gained or lost come copper */
atom(script) VGCB_onCoinUpdate(int NewCopperCount)
{
	;call DebugOut "VG:onCoinUpdate: ${NewCopperCount}"

	if ( ${NewCopperCount} < ${statCurrentCopper} )
	{
		; We just spent some money
		statSpentCopper:Inc[${Math.Calc[${statCurrentCopper} - ${NewCopperCount}]}]
	}

	statCurrentCopper:Set[${NewCopperCount}]

}

/* When a step get's "greyed" out, this is called */
atom(script) VGCB_onCraftingStepComplete(string StepTypeID)
{
	;call DebugOut "VG:onCraftingStepComplete: ${StepTypeID}"

	; This Step is done!
	CompletedSteps:Insert[${StepTypeID}]

	tTimeOut:Set[${Time.Timestamp}]
}

/* Got a Crafting Message */
atom(script) VGCB_onCraftingAlert(string Text)
{
	;This event is fired upon every instance that the
	; Vanguard client sends a 'crafting alert'

	tTimeOut:Set[${Time.Timestamp}]

	call MyOutput "CA: ${Text}"
	call MyOutput "State: ${Refining.State}"
	call MyOutput "Progress: ${Refining.CurrentRecipe.ProgressBarPct}"
	call MyOutput "Quality: ${Refining.Quality}"
	call MyOutput "AP Used: ${Refining.ActionPointsUsed}"

	if ( ${Text.Find[Recipe section 1 complete]} )
	{
		tTimeOut:Set[${Time.Timestamp}]
		;Stage 1 done
		call resetCounts
		call allowedAPSetup
	}
	elseif ( ${Text.Find[Recipe section 2 complete]} )
	{
		tTimeOut:Set[${Time.Timestamp}]
		;Stage 2 done
		call resetCounts
		call allowedAPSetup
	}
	elseif ( ${Text.Find[Recipe section 3 complete]} )
	{
		tTimeOut:Set[${Time.Timestamp}]
		;Stage 3 done
		call resetCounts
		call allowedAPSetup
	}
	elseif ( ${Text.Find[Recipe section 4 complete]} )
	{
		tTimeOut:Set[${Time.Timestamp}]
		;Stage 4 done
		call resetCounts
	}

	if ( ${cState} == CS_COMPLICATE_WAIT )
	{
		; Complication Used, Check to see if we have to hit it again
		cState:Set[CS_COMPLICATE]
	}
	elseif ( ${cState} == CS_ACTION_WAIT )
	{
		; make sure to set the state so we can find another action to do
		cState:Set[CS_ACTION]
	}

	if (${cState} == CS_STATION_IWAIT) && ${doPauseRecipe}
	{
		cState:Set[CS_ACTION]
	}
}

/* Item got added to the Inventory, see if we need to move it around */
atom(script) VGCB_onAddInventoryItem(string sItemName, int iItemID, int iLevel, string sType, string sKeyword1, string sKeyword2, string sMiscDescription)
{
	;call MyOutput "====== aInv: ${sItemName} :: ${iItemID}  ============="
	;call MyOutput "aInv: sType: ${sType} :: ${iLevel}"
	;call MyOutput "aInv: sKeyword1: ${sKeyword1} :: sKeyword2: ${sKeyword2}"
	;call MyOutput "aInv: MiscDesc: ${sMiscDescription}"

	;if ( ${sType.Equal[Miscellaneous]} && !${sName.Find[Supply]} )
	;{
	;	call addSellItem "sItemName"
	;}

	tTimeOut:Set[${Time.Timestamp}]
}

/* Find those sneaky GM's */
atom(script) VGCB_onPawnSpawned(string iID, string aName, string aLevel, string aType)
{
	call testPawn ${aName}
	if ${aName.Find[GM-]}
		call GMDetect
}

/* Some type of Text was sent to the chat window */
/* Could be game, scripts, etc text! */
atom(script) VGCB_OnIncomingText(string Text, string ChannelNumber, string ChannelName)
{

	; Send it off to the auto-response code for processsing
	call AutoRespond "${Text}" "${ChannelNumber}"

	; Don't print Debug Info
	if ( ${ChannelNumber.Equal[17]} )
		return

	call MyOutput "VGCraft:: (${ChannelNumber}):(${ChannelName}) :: ${Text}"

	if ${Text.Find[You have moved too far from the crafting station]}
	{
		; If we arn't moving and we get this message, it might be a sneaky GM
		if ${moveDetector}
		{
			call GMDetect
			PauseBot
			return
		}
	}
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;; IRC ;;;;;;;;;;;;;;;;;;;;;;;;
	; ChannelNumber: 15 (tells)
	if ${ChannelNumber.Equal[15]}
	{
		if ${bUseIRCMaster}
			call IRCSpew "${IRCMaster}, I just received a TELL --> ${Text}"
		else
			call IRCSpew "I just received a TELL --> ${Text}"
	}	
	; Someone is saying my name!
	if ${Text.Find[${Me.FName}]}
	{
		;; ignore these channels
		if !${ChannelNumber.Equal[38]}
		{
			if ${IRCUser["${IRCNick}"](exists)}
			{
				if ${bUseIRCMaster}
				{
					call IRCSpew "${IRCMaster}, Someone just mentioned my name!! (Channel: ${ChannelName}, ${ChannelNumber})"
					call IRC_SendPM "${IRCMaster}" "[VGCraft ${Time}] Someone just mentioned my name --> ${Text} (Channel: ${ChannelName}, ${ChannelNumber})"
				}
				else
					call IRCSpew "Someone just mentioned my name!! (Channel: ${ChannelName}, ${ChannelNumber})"
			}
		}
	}
	; ChannelNumber: 19
	if (${Text.Find[Your Crafting level is now]})
	{
		call IRCSpew "DING!  I am now level ${Me.Level}"
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	
	
	; ChannelNumber: 78
	if ${Text.Find[You do not have enough items selected to continue crafting]}
	{
		; Damn SOE has a bug in their recipes
		call DebugOut "VGCraft:: Added to badRecipe list: ${BadRecipeName}"
		BadRecipes:Add["${BadRecipeName}"]
		cState:Set[CS_STATION]
		Refining:End
		pState:Set[CS_STATION]
		return
	}

	if ${Text.Find[You don't have all the materials required for that recipe]}
	{
		; Damn SOE has a bug in their recipes
		call DebugOut "VGCraft:: Added to badRecipe list: ${BadRecipeName}"
		BadRecipes:Add["${BadRecipeName}"]
		cState:Set[CS_STATION]
		Refining:End
		pState:Set[CS_STATION]
		return
	}

	if ( ${Text.Find[Select the recipe you wish to use]} ) 
	{
		tTimeOut:Set[${Time.Timestamp}]
		;call DebugOut "VG:State: ${Refining.State}"
		;cState:Set[CS_STATION_RECIPE]
	}
	elseif ( ${Text.Find[Crafting recipe selected]} )
	{
		tTimeOut:Set[${Time.Timestamp}]
		if ( ! ${fullAuto} )
		{
			; May need to kickstart the process
			cState:Set[CS_STATION_SETUP]
		}
	}
	elseif ( ${Text.Find[You may now set up your workbench]} )
	{
		tTimeOut:Set[${Time.Timestamp}]
		call StatsOut "===================== New Recipe Started ======================"
		call StatsOut "Name: ${Refining.CurrentRecipe.Name}"
		call StatsOut "Description: ${Refining.CurrentRecipe.Description}"

		if ( ${doPauseRecipe} )
		{
			call ScreenOut "PAUSED: Please set up table and hit BEGIN"
			cState:Set[CS_STATION_IWAIT]
		}
		call resetCounts
	}
	elseif ( ${Text.Find[Add secondary ingredient]} )
	{
		; Here is where we would Click the "Special Button" to add the Attuning Dust/Powder
		; CraftingCatalystAvailable 
		;if ${GV[bool,CraftingCatalystAvailable]}

		cState:Set[CS_ACTION_WAIT]
		ActionTime:Set[${Time.Timestamp}]

		VGExecute "/craftingaddsecondary"
	}
	elseif ( ${Text.Find[You may not choose a crafting action]} )
	{
		; We are currently busy!
		if ( ${cState} == CS_ACTION_WAIT )
		{
			call MyOutput "ACTION_WAIT: Trying to kickstart Action Sequence"
			cState:Set[CS_ACTION]
		}
		
		tTimeOut:Set[${Time.Timestamp}]
		call DebugOut "VGCraft:: Arg! Out of Sequence action try"

		if (${Refining.Stage.Index} == 4)
		{
			call DebugOut "VG:Warning: Setting KickStart TRUE" 
			doKickStart:Set[TRUE]
			fLastProgress:Set[${Refining.CurrentRecipe.ProgressBarPct}]
		}
		else
		{
			; For now just set OoAP, as it will work the same way
			cState:Set[CS_ACTION_OOAP]
			pState:Set[CS_ACTION_OOAP]
		}		
	}
	elseif ( ${Text.Find[New complication:]} )
	{
		tTimeOut:Set[${Time.Timestamp}]
	}
	elseif ( ${Text.Find[Complication has been removed]} )
	{
		tTimeOut:Set[${Time.Timestamp}]
		;Complication has been removed: Mangled Tool

		complicationRemoved:Set[TRUE]

		if ( ${cState} == CS_COMPLICATE_WAIT )
		{
			; We cleared up the Complication, yeah!
			call DebugOut "VGCraft:: Complication Cleared"
			doFixRetry:Set[FALSE]

			; ok, back to the action!
			cState:Set[CS_ACTION]
		}
	}
	elseif ( ${Text.Find[Missing tool of type:]} )
	{
		;Missing tool of type: Rigging Tools

		holdState:Set[${cState}]
		cState:Set[CS_ACTION_BELT]
		missingItem:Set[${Text.Token[2,":"]}]
		return
	}
	elseif ( ${Text.Find[Missing item of type:]} )
	{
		if ( ${cState} == CS_COMPLICATE_WAIT )
		{
			; Can't use this Correction because we are missing something
			; See if we can find a different one the works
			cState:Set[CS_COMPLICATE_REDO]
		}
		else
		{
			call ErrorOut "VGCraft:: Out Of Materials!"
			cState:Set[CS_ACTION_OOM]
		}
	}
	elseif ( ${Text.Find[You do not have enough action points]} )
	{
		tTimeOut:Set[${Time.Timestamp}]
		call DebugOut "VGCraft:: Arg! Ran out of Action Points"

		cState:Set[CS_ACTION_OOAP]
		pState:Set[CS_ACTION_OOAP]

	}
	elseif ( ${Text.Find[You may not do that action now]} )
	{
		tTimeOut:Set[${Time.Timestamp}]
		call DebugOut "VGCraft:: Arg! Out of Sequence action try"

		if (${Refining.Stage.Index} == 4)
		{
			call DebugOut "VG:Warning: Setting KickStart TRUE" 
			doKickStart:Set[TRUE]
			fLastProgress:Set[${Refining.CurrentRecipe.ProgressBarPct}]
		}
		else
		{
			; For now just set OoAP, as it will work the same way
			cState:Set[CS_ACTION_OOAP]
			pState:Set[CS_ACTION_OOAP]
		}

	}
	elseif ( ${Text.Find[You may not execute actions outside of the correct recipe section]} )
	{
		tTimeOut:Set[${Time.Timestamp}]
		call DebugOut "VGCraft:: Arg! Out of Sequence action try"

		; For now just set OoAP, as it will work the same way
		cState:Set[CS_ACTION_OOAP]
		pState:Set[CS_ACTION_OOAP]

	}
	elseif ( ${Text.Find[Your crafting session ends]} )
	{
		tTimeOut:Set[${Time.Timestamp}]
		call StatsOut "VGCraft::      Quality: ${lastQuality}"
		call StatsOut "===================== ${Refining.CurrentRecipe.Name} Finished ======================"
		call MyOutput "===================== ${Refining.CurrentRecipe.Name} Finished ======================"
		call IRCSpew "--- ${Refining.CurrentRecipe.Name} Finished ---"

		if ( (${cState} >= CS_WAIT) && (${cState} < CS_MOVE) )
		{ 
			; All Done!
			; Set the next action to Loot!
			cState:Set[CS_LOOT]
		}

		; Clear out the variables for the next run through
		call resetCounts

		statRecipeDone:Inc

		UIElement[TotalRecipe@CHUD]:SetText[${statRecipeDone}]
		UIElement[FailedRecipe@CHUD]:SetText[${statRecipeFailed}]

	}
	elseif ( ${Text.Find[You may not select a recipe at this point]} )
	{
		; Tried to activate/use something but too far away
		; Check state and then move to target
		if ( ${fullAuto} )
		{
			call DebugOut "VG:ERROR: Can't use the crafting station, MOVE!"
			cState:Set[CS_MOVE]
			pState:Set[CS_MOVE]
			farAwayError:Set[TRUE]
		}
		else
		{
			cState:Set[CS_WAIT]
		}
	}
	elseif ( ${Text.Find[You do not have enough items or charges for this action]} )
	{
		if ${doRecipeOnly}
		{
			call ErrorOut "VG:ERROR: Out of ITEMS!"
			cState:Set[CS_STATION]
			Refining:End
			PauseBot
			return
		}
	}
	elseif ( ${Text.Find[You don't have all the materials required for that recipe]} )
	{
		if ${doRecipeOnly}
		{
			call ErrorOut "VG:ERROR: Out of ITEMS!"
			cState:Set[CS_STATION]
			Refining:End
			PauseBot
			return
		}
	}

	; ChannelNumber: 38
	elseif ( ${Text.Find[check space limits]} )
	{
		;;; Could not loot all of the items. (check space limits?)
		; Just ran out of space!
		if ( ${Me.InventorySlotsOpen} < 2 )
		{
			; Try to go sell stuff
			cTarget:Set[${cSupplyNPC}]
			nextDest:Set[${destSupply}]
			cState:Set[CS_MOVE]
			pState:Set[CS_MOVE]
		}
	}
	elseif ( ${Text.Find[You have looted]} )
	{
		tTimeOut:Set[${Time.Timestamp}]
		; Just finished looting, check state to see what to do next
	}
	elseif ( ${Text.Find[too far away to do that]} )
	{
		; Tried to activate/use something but too far away
		; Check state and then move to target
		if ( ${fullAuto} )
		{
			call ErrorOut "VG:ERROR: To far from crafting station, MOVE!"
			cTarget:Set[${cStation}]
			nextDest:Set[${destStation}]
			cState:Set[CS_MOVE]
			pState:Set[CS_MOVE]
			farAwayError:Set[TRUE]
		}
		else
		{
			cState:Set[CS_WAIT]
		}
	}

	; ChannelNumber: 0
	elseif ( ${Text.Find[You are too far away to request work]} )
	{
		; Damn NPC moved!
		call ErrorOut "VGCraft:: Work Order NPC moved!" 
		cTarget:Set[${cWorkNPC}]
		nextDest:Set[${destWork}]
		cState:Set[CS_MOVE]
		pState:Set[CS_MOVE]
		farAwayError:Set[TRUE]
	}
	elseif ( ${Text.Find[You must select a recipe before crafting]} )
	{
		; Action Sequence got messed up, let's restart
		call ErrorOut "VGCraft:: Out of sequence somehow, starting over!"
		cState:Set[CS_STATION]
	}
	elseif ( ${Text.Find[You need more items to complete that work order]} )
	{
		if ( ${fullAuto} )
		{
			; Tried to finish a work Order, but can't so need to Abandon it!
			cState:Set[CS_ORDER_ABANDON]
		}
	}
	elseif ( ${Text.Find[You must return a work order to the task master who issued it]} )
	{
		if ( ${fullAuto} )
		{
			; Tried to finish a work Order, but can't so need to Abandon it!
			cState:Set[CS_ORDER_ABANDON]
		}
	}
	elseif ( ${Text.Find[Work order accepted]} )
	{
		tTimeOut:Set[${Time.Timestamp}]
		if ( ${fullAuto} )
		{
			; We just turned in a finished a work order, yay!
			cState:Set[CS_ORDER_DONE]

			; Count it!
			statWODone:Inc
		}
	}
	elseif ( ${Text.Find[Work order abandoned]} )
	{
		tTimeOut:Set[${Time.Timestamp}]
		; Abandoned a work order, see if there are more left
		cState:Set[CS_ORDER_FINISH]

		; Count it!
		statWOAbandon:Inc
	}
	elseif ( ${Text.Find[Work order selected]} )
	{
		tTimeOut:Set[${Time.Timestamp}]
		; We just got a new work order
	}
	elseif ( ${Text.Find[Refining recipe added:]} )
	{
		tTimeOut:Set[${Time.Timestamp}]
		; New Recipe added
	}

	; ChannelNumber: 7
	elseif ( ${Text.Find[There you go.]} )
	{
		tTimeOut:Set[${Time.Timestamp}]
		;; Very lame text a vendor spouts when he sells you something
		;; Don't set state here, as we now do the Item movement
		;; as part of the BuySupplies function
		;cState:Set[CS_SUPPLY_SORT]
	}
	if (${ChannelNumber} == 8)
	{
		; Group Invite:
		;bool bGroupInvitePendingSelf
		;${GV[bool,bGroupInvitePendingSelf]}

		if ${Text.Find["invited you to join"]}
		{
			PauseBot
			call WarnAlarm
		}
	}

}


/* ---------------------- STATE TREE ----------------------- */
/* This is the heart of the script, where everything happens */
/* We just call this over and over and over from main()      */
function CheckState()
{
	if ( ${Refining.CurrentRecipe(exists)} && ${Refining.InRecovery} )
	{
		UIElement[State@CHUD]:SetText["Action Recovery"]
		call MyOutput "InRecovery is TRUE"
		wait 3
		return
	}

	variable string sReturn

	;call DebugOut "VG:CheckState called == ${cState}" 
	;call MyOutput "CheckState called == ${cState}"

	Switch ${cState}
	{
		case CS_WAIT
				/* We are waiting for previous action/command/etc to finish */
			UIElement[State@CHUD]:SetText["Waiting"]
			break

		case CS_STATION         
				/* Using Crafting Station */
			cState:Set[CS_STATION_SELECT]
			break

		case CS_STATION_SELECT
				/* Find and Use Crafting Station */
			UIElement[State@CHUD]:SetText["Station Select"]

			if ${doRecipeOnly} && (${recipeRepeatNumDone} >= ${recipeRepeatNum})
			{
				recipeRepeatNumDone:Set[0]
				cState:Set[CS_STATION]
				PauseBot
				call ScreenOut "VGCraft:: All done with Recipe ${recipeName}"
				return
			}

			call TargetStation
			if ( ${Return} )
			{
				; Found and targeted a station, Begin!
				Refining:Begin

				moveDetector:Set[TRUE]

				wait 5
				cState:Set[CS_STATION_RECIPE]
				lastAP:Set[0]
			}
			else
			{
				; Could not find and Target a station
				if ${fullAuto}
				{
					cTarget:Set[${cStation}]
					nextDest:Set[${destStation}]
					moveDetector:Set[FALSE]
					cState:Set[CS_MOVE]
				}
				else
				{
					moveDetector:Set[FALSE]
					cState:Set[CS_WAIT]
					call ErrorOut "VGCraft:: Could not target crafting station!"
				}
			}
			break

		case CS_STATION_RECIPE
				/*  Select a Recipe */
			UIElement[State@CHUD]:SetText["Recipe Select"]

			; Do we need more Supplies?

			if !${doRecipeOnly}
			{
				call SupplyNeeded TRUE
				if ${Return} 
				{
					if ${fullAuto}
					{
						; End the Crafting Session
						Refining:End
						wait 10
	
						; looks like we need more supplies...
						call DebugOut "VGCraft:: Now moving to Supply NPC: ${cSupplyNPC}"
						cTarget:Set[${cSupplyNPC}]
						nextDest:Set[${destSupply}]
						moveDetector:Set[FALSE]
						cState:Set[CS_MOVE]
						return
					}
					else
					{
						call ScreenOut "VGCraft:: WARNING, Out of ingredients!"
						cState:Set[CS_STATION]
						moveDetector:Set[FALSE]
						Refining:End
						PauseBot
						return
					}
				}
			}

			; No? Then select a recipe...
			call StationRecipeSelect
			if ( ${Return} )
			{
				if ${doRecipeOnly}
				{
					call RecipeSupplyNeeded
					if ${Return} 
					{
						if ${fullAuto}
						{
							; End the Crafting Session
							Refining:End
							wait 10
	
							; looks like we need more supplies...
							call DebugOut "VGCraft:: Now moving to Supply NPC: ${cSupplyNPC}"
							cTarget:Set[${cSupplyNPC}]
							nextDest:Set[${destSupply}]
							moveDetector:Set[FALSE]
							cState:Set[CS_MOVE]
							return
						}
						else
						{
							call ScreenOut "VGCraft:: WARNING, Out of supplies!"
							cState:Set[CS_STATION]
							Refining:End
							PauseBot
							return
						}
					}
					else
					{
						call DebugOut "VGCraft:: Found a recipe to use, now do table setup" 
						cState:Set[CS_STATION_SETUP]
					}
				}
				else
				{
					call DebugOut "VGCraft:: Found a recipe to use, now do table setup" 
					cState:Set[CS_STATION_SETUP]
				}
			}
			else
			{
				call DebugOut "VGCraft:: No usable recipes found!"
				if ( ${fullAuto} )
				{
					Refining:End
					wait 10
					call DebugOut "VGCraft:: Moving to Work Order NPC: ${cWorkNPC}"
					cTarget:Set[${cWorkNPC}]
					nextDest:Set[${destWork}]
					moveDetector:Set[FALSE]
					cState:Set[CS_MOVE]
				}
				else
				{
					; All done with crafting, goto wait state
					cState:Set[CS_WAIT]
					moveDetector:Set[FALSE]
				}
			}

			break

		case CS_STATION_IWAIT
				/* Optional Manually added Ingredients, so wait */
			UIElement[State@CHUD]:SetText["Station Wait"]
			break

		case CS_STATION_SETUP
				/* Setup workbench with Ingredients */
			UIElement[State@CHUD]:SetText["Station Setup"]

			if !${Refining(exists)}
			{
				call ErrorOut "VGCraft:: ERROR: No recipe selected!"
				if ( ${fullAuto} )
				{
					Refining:End
					wait 10
					call DebugOut "VGCraft:: Moving to Work Order NPC: ${cWorkNPC}"
					cTarget:Set[${cWorkNPC}]
					nextDest:Set[${destWork}]
					moveDetector:Set[FALSE]
					cState:Set[CS_MOVE]
				}
				else
				{
					; All done with crafting, goto wait state
					cState:Set[CS_WAIT]
				}
			}

			; Ok, looks like we are ready to settle down and craft now
			testLoc:Set[${Me.Location}]
			isMoving:Set[FALSE]
			moveDetector:Set[TRUE]

			call MyOutput "Refining:DoSetup -- Table Setup started"

			; Goto choosing Ingredients phase
			Refining:DoSetup
			wait 5

			if ( !${doRecipeOnly} && ${fullAuto} )
			{
				; Remove personal (non-fuel/extras) resources
				wait 5
				call TableRemovePersonals
			}

			if ${doExtraIngredients}
			{
				; Add optional ingredients
				call TableAddExtra

				if ( (${Refining.TotalTableSpace} - ${Refining.Table}) > 0 )
					call TableAddExtraFuel
			}

			wait 5

			call addRecipeToActionStore

			call DumpRefining

			cState:Set[CS_STATION_BEGIN]

			break 

		case CS_STATION_BEGIN
				/*  Waiting to begin recipe */
			UIElement[State@CHUD]:SetText["Start Recipe"]

			call DebugOut "VGCraft:: === Refining:Start ===" 1

			if !${doPauseRecipe}
			{
				Refining:Start
				wait 5
			}

			variable string CurrentRecipeName
			UIElement[WorkOrder@CHUD]:SetText[${Refining.CurrentRecipe.Name}]
			if ${doRecipeOnly}
				UIElement[WODiff@CHUD]:SetText["${Refining.OrigActionPointsAvail} :: ${Refining.CurrentRecipe.StepCount}"]
			else
			{
				variable int i = 0
				UIElement[WODiff@CHUD]:SetText[-]
				CurrentRecipeName:Set[${Refining.CurrentRecipe.Name}]
				while ( ${i:Inc} <= ${TaskMaster[Crafting].CurrentWorkOrder} )
				{	
					if (${TaskMaster[Crafting].CurrentWorkOrder[${i}].RequestedItems.Find[${Refining.CurrentRecipe.Name}]} > 0)
					{
						UIElement[WODiff@CHUD]:SetText[${TaskMaster[Crafting].CurrentWorkOrder[${i}].Difficulty}]
						CurrentRecipeName:Set[${TaskMaster[Crafting].CurrentWorkOrder[${i}]]
						break
					}
				}
			}

			call allowedAPSetup

			if ${doRecipeOnly}
			{
				call ScreenOut "VGCraft:: Recipe: ${Refining.CurrentRecipe.Name}"
				call IRCSpew "Starting Recipe: ${Refining.CurrentRecipe.Name}"
			}
			else
			{
				call ScreenOut "VGCraft:: Recipe: ${CurrentRecipeName} :: ${Refining.OrigActionPointsAvail} :: ${Refining.CurrentRecipe.StepCount}"
				call StatsOut "VGCraft:: Recipe: ${CurrentRecipeName} :: ${Refining.OrigActionPointsAvail} :: ${Refining.CurrentRecipe.StepCount}"
				call IRCSpew "Starting Recipe: ${CurrentRecipeName}"
			}

			movePathCount:Set[0]

			if ${doPauseRecipe}
			{
				cState:Set[CS_STATION_IWAIT]
			}
			else
			{
				cState:Set[CS_ACTION]
			}

			if !${Refining(exists)}
			{
				call ErrorOut "VGCraft:: ERROR: No recipe selected!"
				cState:Set[CS_STATION_IWAIT]
			}

			break

		case CS_ACTION
				/* Using Recipe actions */
			UIElement[State@CHUD]:SetText["Recipe Action"]

			if !${Refining(exists)}
			{
				call ErrorOut "VGCraft:: ERROR: No recipe selected!"
				cState:Set[CS_STATION_IWAIT]
			}

			cState:Set[CS_ACTION_FIND]
			break

		case CS_ACTION_FIND     
				/*  Select Available Action */
			UIElement[State@CHUD]:SetText["Find Action"]

			; If we have changed Stages, recompute allowed AP
			if ${currentStage} != ${Refining.Stage.Index}
				call allowedAPSetup

			call ChooseAction
			ActionTime:Set[${Time.Timestamp}]

			if ( ${Return} )
			{
				if ${inCorrection}
				{
					UIElement[Action@CHUD]:SetText["(Fix) ${lastCorrection}"]

					call MyOutput "VGCraft:: in corrective action"

					wait 3

					if ${Refining.InRecovery}
					{
						cState:Set[CS_COMPLICATE_WAIT]
						return
					}
				}
				else
				{
					UIElement[Action@CHUD]:SetText[${currentActionName}]

					; Use the Action, then wait for it to Finish
					call ExecuteAction

					wait 3

					if ${Refining.InRecovery}
					{
						cState:Set[CS_ACTION_WAIT]
						return
					}
				}

				if ${doKickStart}
				{
					call markKickActionUsed
				}

			}
			else
			{
				if ${ooAPCheck}
				{
					; Ran out of Action Points and could not find a low cost action
					call DebugOut "VGCraft:: ChooseAction: Can't find low cost action and ooAPCheck TRUE" 
					cState:Set[CS_ACTION_OOAP]
					return
				}

				if ${doKickStart}
				{
					if ${iKickStep} > 10
					{
						; We ran out of AP, but have no way to know that!
						call DebugOut "VGCraft:: KICKSTART and out of AP!"

						ooAPCheck:Set[TRUE]
						cState:Set[CS_ACTION_OOAP]

					}

					call DebugOut "VGCraft:: cState got retry KICKSTART return from ChooseAction" 
					call DebugOut "VGCraft:: Starting the whole action KICKSTART tree over again"

					iKickStep:Inc

					cState:Set[CS_ACTION]

					wait 5

					fLastProgDiff:Set[${Refining.CurrentRecipe.ProgressBarPct} - ${fCheckProgress}]
					fLastProgress:Set[${Refining.CurrentRecipe.ProgressBarPct}]
					fCheckProgress:Set[${Refining.CurrentRecipe.ProgressBarPct}]
				}
				else
				{
					; Ran out of Action Points and could not find a low cost action
					call DebugOut "VGCraft:: ChooseAction: Can't find low cost action and ooAPCheck TRUE" 
					cState:Set[CS_ACTION_OOAP]
				}

			}

			break

		case CS_ACTION_KICK
				/*  Kickstart the Action! */
			UIElement[State@CHUD]:SetText["Kickstart Action"]

			wait 5
			if ( ${doKickStart} )
			{
				call TryKickStartAction
				if ( ${Return} )
				{
					; Found an Action, wait for it to Finish
					cState:Set[CS_ACTION]
				}
				else
				{
					cState:Set[CS_ACTION]
				}
			}
			else
			{
				call DebugOut "VGCraft:: CS.ACTION_KICK: doKickStart is False, return to action" 
				cState:Set[CS_ACTION]
			}

			break

		case CS_ACTION_BELT
				/* Change the tool belt */
			UIElement[State@CHUD]:SetText["Switch Toolbelt"]

			if ( ${missingItem.Equal[NONE]} )
			{
				call DebugOut "VGCraft:: Wanted to change toolbelts, but missingItem == NONE"
				cState:Set[CS_ACTION]
				return
			}

			call ChangeToolBelts "${missingItem}"
			if ( ${Return} )
			{
				wait 3

				; Found and switched belt
				call DebugOut "VGCraft:: Found and switched belt"
				missingItem:Set[NONE]

				call DebugOut "VGCraft:: Was Changing Tool Belts :: back to holdState: ${holdState}"

				cState:Set[${holdState}]

				if ( ${cState} == CS_COMPLICATE_WAIT )
				{
					; Tried a Correction, but missing the tools
					; See if we can find a different one that works
					cState:Set[CS_COMPLICATE_FIND]
				}
				else
				{
					; make sure to set the state so we can find another action to do
					cState:Set[CS_ACTION]
				}

				if ${doKickStart}
				{
					; Make sure if we are in Kickstart that we retry the same action
					call markKickActionNotUsed
				}

			}
			else
			{
				; Could not find that item in a tool belt
				call DebugOut "VGCraft:: FAILED to Change Tool Belts :: holdState: ${holdState}"

				cState:Set[${holdState}]

				if ( ${cState} == CS_COMPLICATE_WAIT )
				{
					; Tried a Correction, but missing the tools
					; See if we can find a different one that works
					cState:Set[CS_COMPLICATE_REDO]
				}
				else
				{
					; make sure to set the state so we can find another action to do
					cState:Set[CS_ACTION]
				}

			}

			break

		case CS_ACTION_WAIT     
				/*  Waiting for Action to finish */
			; Don't do anything here as this state will be changed
			; by an Event from VGCB_OnIncomingText()
			UIElement[State@CHUD]:SetText["Action Wait"]
			wait 5

			if ( ${Math.Calc[${Time.Timestamp} - ${ActionTime.Timestamp}]} > 30 )
			{
						cState:Set[CS_ACTION]
		        call ScreenOut "Timeout, retrying loot!!!"
			}
			break

		case CS_ACTION_MANUAL   
				/*  Requires User Input (manual typing) */
			UIElement[State@CHUD]:SetText["Wait Manual Action"]
			break

		case CS_ACTION_OOAP
				/*  Out Of Action Points */
			; Need to check and see if we can use a lower cost Action
			; in case Complication is causing cost to be higher than normal
			UIElement[State@CHUD]:SetText["Out of AP Check"]

			if ( ${ooAPCheck} )
			{
				; This is a real error, so Cancel current Recipe and start a new one

				call StatsOut "===================== ${Refining.CurrentRecipe.Name} Ended Early: Out of AP! ======================"
				call MyOutput "===================== ${Refining.CurrentRecipe.Name} Ended Early: Out of AP! ======================"
				call DebugOut "VGCraft:: Arg! Ran out of action points!"

				Refining:Cancel
				call resetCounts

				statRecipeFailed:Inc

				UIElement[LastWO@CHUD]:SetText["Failed"]
				UIElement[TotalRecipe@CHUD]:SetText[${statRecipeDone}]
				UIElement[FailedRecipe@CHUD]:SetText[${statRecipeFailed}]

				wait 10

				cState:Set[CS_STATION_SELECT]
			}
			else
			{
				wait 5
				ooAPCheck:Set[TRUE]
				cState:Set[CS_ACTION_FIND]
			}

			break

		case CS_ACTION_OOM
				/*  Out Of Material (ingredients) */
			UIElement[State@CHUD]:SetText["Out of Materials"]

			call StatsOut "===================== ${Refining.CurrentRecipe.Name} Ended Early: Out of Materials! ======================"
			call MyOutput "===================== ${Refining.CurrentRecipe.Name} Ended Early: Out of Materials! ======================"
			call DebugOut "VGCraft:: Arg! Ran out of Materials!"

			Refining:Cancel
			call resetCounts

			statRecipeFailed:Inc

			UIElement[LastWO@CHUD]:SetText["Failed"]
			UIElement[TotalRecipe@CHUD]:SetText[${statRecipeDone}]
			UIElement[FailedRecipe@CHUD]:SetText[${statRecipeFailed}]

			wait 10

			cState:Set[CS_STATION_SELECT]

			break

		case CS_COMPLICATE      
				/* Checking Complication */
			UIElement[State@CHUD]:SetText["Complication"]

			call CheckComplication
			if ${Return}
			{
				; CheckComplication has set the correct cState, so let main handle it
				inCorrection:Set[TRUE]
			}
			else
			{
				inCorrection:Set[FALSE]
				cState:Set[CS_ACTION]
			}

			break

		case CS_COMPLICATE_FIND 
				/*  Selecting Complication Action */
			UIElement[State@CHUD]:SetText["Find Correction"]

			call FindCorrection
			if ( ${Return} )
			{
				; Wait for Correction to finish
				cState:Set[CS_COMPLICATE_WAIT]
				wait 3
			}
			else
			{
				; No corrections selected, so return to Action!
				cState:Set[CS_ACTION]
				wait 3
			}
			break

		case CS_COMPLICATE_REDO
				/*  See if we should try the Correction Action one more time */
			UIElement[State@CHUD]:SetText["Correction Retry"]

			if ( ${doFixRetry} )
			{
				; We've already tried once, so Ignore and move on
				call DebugOut "VGCraft:: Ignoring Complication!"
				call IgnoreComplication
				doFixRetry:Set[FALSE]
				cState:Set[CS_ACTION]
			}
			else
			{
				call DebugOut "VGCraft:: Ignoring Correction: ${lastCorrection}"
				call IgnoreFix "${lastCorrection}"

				wait 5
				doFixRetry:Set[TRUE]
				cState:Set[CS_ACTION]
			}

			break

		case CS_COMPLICATE_WAIT 
				/*  Waiting for Complication Action to finish */
			; Don't do anything here as this state will be changed by an Event
			UIElement[State@CHUD]:SetText["Correction Wait"]

			break

		case CS_LOOT            
				/* Looting */
			UIElement[State@CHUD]:SetText["Get Loot"]

			call DoLoot

			cState:Set[CS_STATION]

			break

		case CS_ORDER           
				/* Talking to Order Giver/Taker */
			UIElement[State@CHUD]:SetText["Work Order NPC"]
			moveDetector:Set[FALSE]

			if ( ${fullAuto} )
			{
				cState:Set[CS_ORDER_TARGET]
			}
			else
			{
				; No BOTS!
				cState:Set[CS_WAIT]
			}
			break

		case CS_ORDER_TARGET
				/* Target and Talk to Work Order NPC */
			UIElement[State@CHUD]:SetText["Target WO NPC"]

			call TargetOrderNPC
			if ( ${Return} )
			{
				; Yes, now turn in finished orders
				cState:Set[CS_ORDER_FINISH]
			}
			else
			{
				call TargetLOS
				if ( ${Return} )
				{
					call DebugOut "VGCraft:: Not able to target Work Order NPC, back to moving"
					wait 10

					cTarget:Set[${cSupplyNPC}]
					nextDest:Set[${destSupply}]
					cState:Set[CS_MOVE]
				}
				else
				{
					call DebugOut "VGCraft:: Not able to target Work Order NPC, wait for 30 seconds"
					cState:Set[CS_MOVE_LOS]
				}
			}

			break

		case CS_ORDER_GET
				/*  Getting new Work Orders */
			UIElement[State@CHUD]:SetText["Talk to WO NPC"]

			if ${doBatches}
			{
				call GetWorkOrder FALSE 5

				if ( ${Return} )
				{
					; Got one, but can get more!
					cState:Set[CS_ORDER_GET]
					return
				}
			}

			if ${doSets}
			{
				call GetWorkOrder FALSE 3

				if ( ${Return} )
				{
					; Got one, but can get more!
					cState:Set[CS_ORDER_GET]
					return
				}
			}

			if ${doSingles}
			{
				; Ok then do Singles
				call GetWorkOrder FALSE 1

				if ( ${Return} )
				{
					; Got one, but can get more!
					cState:Set[CS_ORDER_GET]
					return
				}
			}

			; Ok, then get anything!
			call GetWorkOrder TRUE
			if ( ${Return} )
			{
				; Got one, but can get more!
				cState:Set[CS_ORDER_GET]
			}
			else
			{
				; Do we have any work orders?
				if (${TaskMaster[Crafting].CurrentWorkOrderCount} > 0)
				{
					; All full, move to next target
					if ( ${TaskMaster[Crafting].InTransaction} )
					{
						TaskMaster[Crafting]:End
						wait 3
					}

					; Do we need more Supplies?
					call SupplyNeeded FALSE
					if ( ${Return} )
					{
						; Next Target will be Supply Buy/Sell NPC
						call DebugOut "VGCraft:: Now moving to Supply NPC: ${cSupplyNPC}"
						cTarget:Set[${cSupplyNPC}]
						nextDest:Set[${destSupply}]
					}
					else
					{
						; No? Then back to work!
						; Next Target will be Craft Station
						cTarget:Set[${cStation}]
						nextDest:Set[${destStation}]
					}

					cState:Set[CS_MOVE]
					; Clear out any Faction Grind counters
					woGrindCount:Clear

				}
				else
				{
					if ${autoSwitchCrafting}
					{
						if ${doRefining}
						{
							; We are currently doing Refining, so check and see if we can switch to Finishing
							if !${cFinishingStation.Equal[NONE]} && !${cFinishingWorkNPC.Equal[NONE]}
							{
								call ErrorOut "VGCraft:: No more Refining Work Orders, switching to Finishing"
								UIElement[FinishingFrame@Move@Craft Main@CraftBot]:Show
								UIElement[RefiningCheck@Move@Craft Main@CraftBot]:UnsetChecked
								UIElement[RefiningFrame@Move@Craft Main@CraftBot]:Hide
								wait 10
								setupFinishing
								doRefining:Set[FALSE]
								wait 20
								cState:Set[CS_MOVE]
							}
							else
							{
								call ErrorOut "VGCraft:: No Work Orders available from ${cWorkNPC}, going to sleep"
								cState:Set[CS_WAIT]
							}
						}
						else
						{
							; We are currently Finishing, switch to Refining
							if !${cRefiningStation.Equal[NONE]} && !${cRefiningWorkNPC.Equal[NONE]}
							{
								call ErrorOut "VGCraft:: No more Finishing Work Orders, switching to Refining"
								UIElement[RefiningFrame@Move@Craft Main@CraftBot]:Show
								UIElement[FinishingCheck@Move@Craft Main@CraftBot]:UnsetChecked
								UIElement[FinishingFrame@Move@Craft Main@CraftBot]:Hide
								wait 10
								setupRefining
								doRefining:Set[TRUE]
								wait 20
								cState:Set[CS_MOVE]
							}
							else
							{
								call ErrorOut "VGCraft:: No Work Orders available from ${cWorkNPC}, going to sleep"
								cState:Set[CS_WAIT]
							}
						}
					}
					else
					{
						call ErrorOut "VGCraft:: No Work Orders available from ${cWorkNPC}, going to sleep"
						cState:Set[CS_WAIT]
					}
				}
			}

			break

		case CS_ORDER_FINISH
			/*  Finish/turn in old Work Orders */
			UIElement[State@CHUD]:SetText["Turn in Work Orders"]

			; Check to see if we have any to turn in

			call FinishWorkOrder
			if ( ${Return} )
			{
				; Found a work order, State will be set by an Event
				; -- Could be Either CS_ORDER_DONE (good, now loot)
				; -- Or could be CS_ORDER_ABANDON (bad, get rid of it)
				cState:Set[CS_WAIT]
			}
			else
			{
				; No more work Orders to turn in, get some new ones!
				cState:Set[CS_ORDER_GET]
			}

			break

		case CS_ORDER_DONE      
			/*  Completed Finished Orders, time to loot!  */
			UIElement[State@CHUD]:SetText["Work Order Rewards"]

			call DoLoot

			; See if we have any more to turn in
			cState:Set[CS_ORDER_FINISH]

			break

		case CS_ORDER_ABANDON
				/*  Failed at this Work Order, get rid of it  */
			UIElement[State@CHUD]:SetText["Abandon Work Order"]

			call AbandonWorkOrder

			; See if we have any more to turn in
			cState:Set[CS_WAIT]

			break

		case CS_SUPPLY
			/* Talking to Item/Resupply Vendor */
			UIElement[State@CHUD]:SetText["Supply NPC"]
			moveDetector:Set[FALSE]

			if ( ! ${fullAuto} )
			{
				; No bots!
				return
			}

			; First open any Reward bags we've received
			if ${doOpenPacks}
			{
				UIElement[State@CHUD]:SetText["Open Packs"]
				call openLootPacks
				wait 20
			}


			UIElement[State@CHUD]:SetText["Targeting Supply NPC"]
			call DebugOut "VGCraft:: Targeting Supply NPC"

			call TargetSupplyNPC
			if ( ${Return} )
			{
				wait 10
				cState:Set[CS_SUPPLY_SELL]
			}
			else
			{
				call TargetLOS
				if ( ${Return} )
				{
					call DebugOut "VGCraft:: Not able to target Supply NPC, back to moving"
					call DebugOut "VGCraft:: No Supply NPC, moving back to Craft Station: ${cStation}"
					cTarget:Set[${cStation}]
					nextDest:Set[${destStation}]
					wait 10
					cState:Set[CS_MOVE]
				}
				else
				{
					call DebugOut "VGCraft:: Not able to target Supply NPC, wait for 30 seconds"
					cState:Set[CS_MOVE_LOS]
				}
			}
			
			break

		case CS_SUPPLY_SELL
				/*  Sell any loot */
			UIElement[State@CHUD]:SetText["Sell Loot"]

			call SellLoot

			; Just ran out of space!
			if ( ${Me.InventorySlotsOpen} < 2 )
			{
				call ErrorOut "VGCraft:: NOTICE: Out of pack space! (${Me.InventorySlotsOpen})"
			;	cState:Set[CS_WAIT]
			;	pState:Set[CS_WAIT]
			;	return
			}

			cState:Set[CS_SUPPLY_BUY]

			wait 5

			break

		case CS_SUPPLY_BUY
				/*  Buying supplies */
			UIElement[State@CHUD]:SetText["Buy Supplies"]

			cState:Set[CS_SUPPLY_WAIT]

			call BuySupplies

			wait 10

			Merchant:End

			if ${doRepair}
			{
				call RepairNeeded
				if ${Return} && !${cRepairNPC.Equal[NONE]}
				{
					call DebugOut "VGCraft:: Done Buy/sell. Need to repair items, will move to Repair NPC"
					cTarget:Set[${cRepairNPC}]
					nextDest:Set[${destRepair}]
					cState:Set[CS_MOVE]
					return
				}
			}

			call DebugOut "VGCraft:: Done Sell/Buy, moving back to Craft Station"

			cTarget:Set[${cStation}]
			nextDest:Set[${destStation}]
			cState:Set[CS_MOVE]

			break

		case CS_SUPPLY_SORT
				/*  Moving supplies around inventory */
			;; We don't enter this state anymore, instead we move
			;; Supplies around as part of the BuySupplies function
			;call MoveCraftSupplies

			break

		case CS_SUPPLY_WAIT
				/*  Waiting for Supply Buy/Sell */
			break


		case CS_REPAIR
				/*  Repairing items */
			UIElement[State@CHUD]:SetText["Repair NPC"]

			cState:Set[CS_SUPPLY_WAIT]

			Call RepairItems
			Call DebugOut "VGCraft:: Done repairing items, heading to craft station"

			cTarget:Set[${cStation}]
			nextDest:Set[${destStation}]
			cState:Set[CS_MOVE]

			break

		case CS_MOVE            
			/* Moving to Target */
			UIElement[State@CHUD]:SetText["Move"]
			moveDetector:Set[FALSE]

			if !${fullAuto}
			{
				; No BOTS!
				cState:Set[CS_WAIT]
				return
			}

			if ${doExactPath}
			{
				; path to user set points
				cState:Set[CS_MOVE_UPATH]
			}
			else
			{
				; First, see if we can find a target to Path to
				call FindMoveTarget
				if ( ${Return} )
				{
					; Found a Target, path to it
					cState:Set[CS_MOVE_TPATH]
				}
				else
				{
					; No target, path to user set points
					cState:Set[CS_MOVE_UPATH]
				}
			}

			break
			
			
		case CS_MOVE_TOTARGET          
			/* Moving to Target */
			UIElement[State@CHUD]:SetText["Move"]
			moveDetector:Set[FALSE]

			if !${fullAuto}
			{
				; No BOTS!
				cState:Set[CS_WAIT]
				return
			}

			if ${doExactPath}
			{
				; path to user set points
				cState:Set[CS_MOVE_UPATH]
			}
			else
			{
				; First, see if we can find a target to Path to
				if ${Me.Target(exists)}
				{
					; Found a Target, path to it
					cState:Set[CS_MOVE_TPATH]
				}
				else
				{
					; No target, path to user set points
					cState:Set[CS_MOVE_UPATH]
				}
			}

			break			

		case CS_MOVE_TPATH
			/*  Found a Target, so LavishNav path to it */
			UIElement[State@CHUD]:SetText["Move to ${cTarget}"]

			; Increment a failsafe counter
			movePathCount:Inc

			; We should already have a target we are moving to...so why not use it's ID?
			;call MoveTargetPath "${cTarget}"
			;;; ..but..just in case...
			if !${Me.Target(exists)}
			{
				Pawn[exactname,${cTarget}]:Target
				wait 5
			}
			
			call MoveTargetPath "${Me.Target.Name}" ${Me.Target.ID}
			sReturn:Set[${Return}]
			call DebugOut "MoveTargetPath returned '${sReturn}'"

			if ${sReturn.Equal[END]}
			{
				; Done with path, now find end point target
				cState:Set[CS_MOVE_FIND]
			}
			elseif ${sReturn.Equal[NO MAP]}
			{
				; Get back on the MAP!
				call DebugOut "VGCraft:: Off the MAP"
				cState:Set[CS_MOVE_MAP]
			}
			elseif ${sReturn.Equal[NO PATH]}
			{
			;	; Failed to find a path with LavishNav, PAUSE
			;	PauseBot
			;	call ErrorOut "VGCraft:: ERROR: No Path to ${cTarget}, pausing"
			;	cState:Set[CS_WAIT]
				cState:Set[CS_MOVE_MAP]
			}
			elseif ${sReturn.Equal[STUCK]}
			{
				; Got stuck trying to move to Target with LavishNav
				call DebugOut "VGCraft:: We got STUCK while moveing to ${cTarget}, start over"
				cState:Set[CS_MOVE]
			}
			else
			{
				; Failed to move along path
				call DebugOut "VGCraft:: Failed to move along TARGET path, try the target direct"
				cState:Set[CS_MOVE_FIND]
			}

			if ${movePathCount} > 6
			{
				call ErrorOut "VGCraft:: Stuck in a path loop! Pausing"
				PauseBot
				cState:Set[CS_WAIT]
			}

			break


		case CS_MOVE_UPATH
				/* Move along user defined path */
				tTimeOut:Set[${Time.Timestamp}]

			UIElement[State@CHUD]:SetText["PMove to ${nextDest}"]

			; Increment a failsafe counter
			movePathCount:Inc

			call MoveAlongPath
			sReturn:Set[${Return}]

			if ${sReturn.Equal[END]}
			{
				; Done with User Path, now find end point target
				cState:Set[CS_MOVE_TPATH]
			}
			elseif ${sReturn.Equal[NO PATH]}
			{
				; Failed to move to user defined point, that is BAD!
				;call ErrorOut "VGCraft:: ERROR: No Path found, pausing"
				;PauseBot
				call DebugOut "VGCraft:: MOVE_UPATH: No Path found, try MOVE_TPATH"
				cState:Set[CS_MOVE_TPATH]
			}
			elseif ${sReturn.Equal[STUCK]}
			{
				; Got stuck trying to move with LavishNav
				call DebugOut "VGCraft:: We got STUCK while moving with UPATH, start over"
				cState:Set[CS_MOVE]
			}
			else
			{
				; Failed to move along path
				call DebugOut "VGCraft:: Failed to move along defined path, try the target direct"
				cState:Set[CS_MOVE_FIND]
			}

			if ${movePathCount} > 6
			{
				call ErrorOut "VGCraft:: Stuck in a path loop! Pausing"
				PauseBot
				cState:Set[CS_WAIT]
			}

			break

		case CS_MOVE_FIND     
			/*  Find a Target in range */
			UIElement[State@CHUD]:SetText["Targeting ${cTarget}"]

			call TargetCloseObject
			if ( ${Return} )
			{
				; Found a target, get moving!
				call DebugOut "VGCraft:: Moving to Found Target"
				cState:Set[CS_MOVE_TARGET]
			}
			else
			{
				if ${cTarget.Equal[${cWorkNPC}]}
				{
					; Wait for Wandering NPC to return
					call DebugOut "VG:CS.MOVE_FIND: cWorkNPC not found, waiting"
					cState:Set[CS_MOVE_TARGWAIT]
				}
				else
				{
					; No target to move to
					call ErrorOut "VG:ERROR: No Target to move to! Try making a new path"
					cState:Set[CS_WAIT]
				}
			}

			break

		case CS_MOVE_MAP
				/*  Get back on the MAP */
				tTimeOut:Set[${Time.Timestamp}]

			UIElement[State@CHUD]:SetText["Move to MAP"]

			movePathCount:Set[0]

			call MoveToMap
			if !${Return}
			{
				call ErrorOut "VGCraft:: Could not move back to Mapped area"
				PauseBot
				cState:Set[CS_WAIT]
				return
			}

			cState:Set[CS_MOVE]

			break

		case CS_MOVE_TARGET     
				/*  Moving to Selected Target */
				tTimeOut:Set[${Time.Timestamp}]

			UIElement[State@CHUD]:SetText["Move to ${cTarget}"]

			movePathCount:Set[0]

			call MoveToTarget

			break

		case CS_MOVE_TARGWAIT
			/*  Waiting for Roving Taskmaster to return */
			UIElement[State@CHUD]:SetText["Waiting for ${cTarget}"]

			call DebugOut "VGCraft:: CS.MOVE_TARGWAIT"

			call DebugOut "VG:Waiting 20 seconds for NPC ${cTarget} to return"
			wait 200

			;call MoveToTarget
			cState:Set[CS_MOVE_TPATH]

			break

		case CS_MOVE_LOS
				/*  Waiting for Line Of Sight to NPC */
			UIElement[State@CHUD]:SetText["No LOS ${cTarget}"]

			call DebugOut "VGCraft:: CS.MOVE_LOS"

			if ( ${iLOSCount} > 10 )
			{
				call DebugOut "VG:LOS: Done waiting, move on!"

				; We have waited long enough, give up
				iLOSCount:Set[0]

				; Next Target will be Craft Station
				cTarget:Set[${cStation}]
				nextDest:Set[${destStation}]
				cState:Set[CS_MOVE]
			}
			else
			{
				call ErrorOut "VG:No LoS, waiting for NPC ${cTarget} to return"
				wait 100

				iLOSCount:Inc
			}

			call MoveToTarget

			break

		case CS_MOVE_WAIT
				/*  Waiting for Move to finish */
			break

		case CS_MOVE_DONE      
				/*  We are there! */
			UIElement[State@CHUD]:SetText["Move Done"]

			tTimeOut:Set[${Time.Timestamp}]

			call MoveDone

			if (${doTestMove})
			{
				call DebugOut "VGCraft:: doTestMove MOVE_DONE, waiting 2 secs"
				wait 20

				cState:Set[CS_MOVE]

				if ${nextDest.Equal[${destStation}]}
				{
					call DebugOut "VGCraft:: at Station, move to WO Search"
					cTarget:Set[${cWorkNPC}]
					nextDest:Set[${destWork}]
				}
				elseif ${nextDest.Equal[${destWorkSearch}]}
				{
					call DebugOut "VGCraft:: at WO NPC Search Spot, look for NPC"

					cTarget:Set[${cWorkNPC}]
					nextDest:Set[${destWork}]
					cState:Set[CS_MOVE_FIND]
				}
				elseif ${nextDest.Equal[${destWork}]}
				{
					call DebugOut "VGCraft:: at WO NPC, get some"
					cTarget:Set[${cSupplyNPC}]
					nextDest:Set[${destSupply}]
				}
				elseif ${nextDest.Equal[${destSupply}]}
				{
					call DebugOut "VGCraft:: at Supply NPC, buy/sell"
					cTarget:Set[${cStation}]
					nextDest:Set[${destStation}]
				}
				elseif ${nextDest.Equal[${destRepair}]}
				{
					call DebugOut "VG:MoveDone: at Repair NPC"
					cTarget:Set[${cStation}]
					nextDest:Set[${destStation}]
				}

			}
			
			break

		default
				/* Hmm, how did we get here? */
			break
	}
}


/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */

/* Setup the vars for this recipe */
function allowedAPSetup()
{
/*
	5 steps @ 2000
	6 steps @ 2500
	7 steps @ 3000
	8 steps @ 3500

	Step 1 + 2 = 250
	5  steps add +200 for complications
	6  steps add +250 for complications
	7+ steps add +300 for complications

	3 steps @ 1600 == 530 each
	4 steps @ 2000 == 500 each
	5 steps @ 2450 == 490 each
	6 steps @ 2950 == 490 each

*/
	;${Refining.OrigActionPointsAvail}
	;${Refining.CurrentRecipe.StepCount}

	variable int tstep
	variable int totalSteps
	variable int totalAP

	; Set aside 200 AP for First and Last steps
	totalAP:Set[${Math.Calc[${Refining.OrigActionPointsAvail} - 200]}]

	; Take off First and Last step
	totalSteps:Set[${Math.Calc[${Refining.CurrentRecipe.StepCount} - 2]}]

	allowedStepAP:Set[${Math.Calc[${totalAP} / ${totalSteps}]}]


	;if ${Refining.CurrentRecipe.StepCount} <= 5
	;	allowedStepAP:Set[500]
	;if ${Refining.CurrentRecipe.StepCount} == 6
	;	allowedStepAP:Set[500]
	;if ${Refining.CurrentRecipe.StepCount} >= 7
	;	allowedStepAP:Set[490]

	;if ${Refining.OrigActionPointsAvail} <= 2000
	;	allowedStepAP:Set[400]
	;if ${Refining.OrigActionPointsAvail} == 2500
	;	allowedStepAP:Set[400]
	;if ${Refining.OrigActionPointsAvail} == 3000
	;	allowedStepAP:Set[400]
	;if ${Refining.OrigActionPointsAvail} >= 3500
	;	allowedStepAP:Set[400]


	call DebugOut "VGCraft:: allowedStepAP: ${allowedStepAP}"
	

		variable int stageAP
		variable int stepCount

		stepCount:Set[${Refining.Stage.StepCount}]

		if ${Refining.Stage.Index} == 1
		{
			allowedStageAP:Set[125]
		}
		elseif ${Refining.Stage.Index} == 4
		{
			if ${stepCount} > 1
				allowedStageAP:Set[${Math.Calc[(${stepCount} - 1) * ${allowedStepAP}]}]
			else
				allowedStageAP:Set[100]
		}
		else
		{
			allowedStageAP:Set[${Math.Calc[${stepCount} * ${allowedStepAP}]}]
		}

		call DebugOut "VGCraft:: Stage: ${Refining.Stage.Index} :: allowedAP: ${allowedStageAP}"

}

/* Reset some variables between Stages and Recipes */
function resetCounts()
{
	CompletedSteps:Clear
	IgnoredFixes:Clear
	IgnoredComplications:Clear
	StepProgress:Clear

	ooAPCheck:Set[FALSE]
	doFixRetry:Set[FALSE]
	doKickStart:Set[FALSE]
	iKickStep:Set[0]

	fLastProgress:Set[0]
	fLastProgDiff:Set[0]
	fCheckProgress:Set[0]
	lastQuality:Set[0]
	lastQualDiff:Set[0]
	apStageUsed:Set[0]

	currentStepName:Set[NONE]
	currentActionName:Set[NONE]

	variable int iCount
	for ( iCount:Set[1]; ${iCount} < 10; iCount:Inc )
	{
		stepAPUsed[${iCount}]:Set[0]
		tryKickStart[${iCount}]:Set[TRUE]
	}

	allowedStageAP:Set[0]
	stageAPUsed:Set[0]

}

/* Loot baby loot! */
function DoLoot()
{
	; Should probably check to see if we have a Loot window open
	call DebugOut "VGCraft:: DoLoot called"

	if ${doRecipeOnly}
		recipeRepeatNumDone:Inc
		
	wait 10 ${Me.IsLooting}

	if ${Loot.NumItems}
	{
		wait 2
		Loot:LootAll
		wait 10
	}
}

/* ActionStore this recipe */
function addRecipeToActionStore()
{
	variable string aName 
	variable string aDesc
	variable int tokCount
	variable int tstep
	variable int substep

	if ( ${Refining.CurrentRecipe.StepCount} > 0 )
	{

	tstep:Set[1]
	do
	{
		substep:Set[1]
		do
		{
			aName:Set["${Refining.CurrentRecipe.Step[${tstep}].AvailAction[${substep}].Name}"]
			aDesc:Set["${Refining.CurrentRecipe.Step[${tstep}].AvailAction[${substep}].Description}"]

			if ( ${actionStore.FindSet[${aName}](exists)} )
			{
				;call DebugOut "VG:actionStore exists: ${aName}"
				actionStore.FindSet[${aName}]:AddSetting[Stage,${Refining.CurrentRecipe.Step[${tstep}].InStage.Index}]
			}
			else
			{
				call DebugOut "VG:actionStore new: ${aName}"

				actionStore:AddSet[${aName}]

				actionStore.FindSet[${aName}]:AddSetting[Stage,${Refining.CurrentRecipe.Step[${tstep}].InStage.Index}]
				actionStore.FindSet[${aName}]:AddSetting[Name,${Refining.CurrentRecipe.Step[${tstep}].AvailAction[${substep}].Name}]
				actionStore.FindSet[${aName}]:AddSetting[ActionPointCost,${Refining.CurrentRecipe.Step[${tstep}].AvailAction[${substep}].ActionPointCost}]
				;actionStore.FindSet[${aName}]:AddSetting[Description,${Refining.CurrentRecipe.Step[${tstep}].AvailAction[${substep}].Description}]
				actionStore.FindSet[${aName}]:AddSetting[Attribute,NONE]
				actionStore.FindSet[${aName}]:AddSetting[Skill,NONE]
				actionStore.FindSet[${aName}]:AddSetting[Progress,0]
				actionStore.FindSet[${aName}]:AddSetting[Quality,0]
				actionStore.FindSet[${aName}]:AddSetting[ToolRequired,FALSE]
				actionStore.FindSet[${aName}]:AddSetting[ToolName,NONE]
				actionStore.FindSet[${aName}]:AddSetting[ItemRequired,FALSE]
				actionStore.FindSet[${aName}]:AddSetting[ItemName,NONE]
				actionStore.FindSet[${aName}]:AddSetting[QualLoss,0]
				actionStore.FindSet[${aName}]:AddSetting[NumUsed,0]
				actionStore.FindSet[${aName}]:AddSetting[AvgProg,0]
				actionStore.FindSet[${aName}]:AddSetting[AvgQual,0]

				; Need to Parse out the description to get Progress, Quality, Require Items, etc
				tokCount:Set[1]
				do
				{
					if ( ${aDesc.Token[${tokCount},"\n"].Find[Progress:]} )
					{
						call rateDescription "${aDesc.Token[${tokCount},"\n"].Token[2,:]}"
						actionStore.FindSet[${aName}]:AddSetting[Progress,${Return}]
					}
					elseif ( ${aDesc.Token[${tokCount},"\n"].Find[Quality:]} )
					{
						call rateDescription "${aDesc.Token[${tokCount},"\n"].Token[2,:]}"
						actionStore.FindSet[${aName}]:AddSetting[Quality,${Return}]
					}
					elseif ( ${aDesc.Token[${tokCount},"\n"].Find[Quality Loss:]} )
					{
						call rateDescription "${aDesc.Token[${tokCount},"\n"].Token[2,:]}"
						actionStore.FindSet[${aName}]:AddSetting[QualLoss,${Return}]
						call DebugOut "VG:actionStore Quality Loss: ${aName} :: ${Return}"

					}
					elseif ( ${aDesc.Token[${tokCount},"\n"].Find[Item Required:]} )
					{
						actionStore.FindSet[${aName}]:AddSetting[ItemRequired,TRUE]
						actionStore.FindSet[${aName}]:AddSetting[ItemName,${aDesc.Token[${tokCount},"\n"].Token[3," "]}]
					}
					elseif ( ${aDesc.Token[${tokCount},"\n"].Find[Tool Type Required:]} )
					{
						actionStore.FindSet[${aName}]:AddSetting[ToolRequired,TRUE]
						actionStore.FindSet[${aName}]:AddSetting[ToolName,${aDesc.Token[${tokCount},"\n"].Token[2,:]}]
					}
					elseif ( ${aDesc.Token[${tokCount},"\n"].Find[Attribute Used:]} )
					{
						actionStore.FindSet[${aName}]:AddSetting[Attribute,${aDesc.Token[${tokCount},"\n"].Token[2,:]}]
					}
					elseif ( ${aDesc.Token[${tokCount},"\n"].Find[Skill Used:]} )
					{
						actionStore.FindSet[${aName}]:AddSetting[Skill,${aDesc.Token[${tokCount},"\n"].Token[2,:]}]
					}

					tokCount:Inc
				}
				while ( ${aDesc.Token[${tokCount},"\n"](exists)} )
			}
		}
		while ( ${substep:Inc} <= ${Refining.CurrentRecipe.Step[${tstep}].AvailActionsCount} ) 

	}
	while ( ${tstep:Inc} <= ${Refining.CurrentRecipe.StepCount} )

	}
}

/* Dump out a bunch of data about the CurrentRecipe */
function DumpRefining()
{
	variable string aName 
	variable string aDesc
	variable int tokCount
	variable int tstep
	variable int substep

	if ( ${Refining.CurrentRecipe.StepCount} > 0 )
	{

		call MyOutput "Refining.State: ${Refining.State}"
		call MyOutput "UsableItemCount: ${Refining.UsableItemCount}"
		call MyOutput "OrigActionPointsAvail: ${Refining.OrigActionPointsAvail}"
		call MyOutput "ActionPointsUsed: ${Refining.ActionPointsUsed}"
		call MyOutput "Quality: ${Refining.Quality}"

		call MyOutput " ==== Table Data ==== "
		call MyOutput "Table: ${Refining.Table}"
		call MyOutput "TotalTableSpace: ${Refining.TotalTableSpace}"
		variable int count = 1
		do
		{
			call MyOutput "VG:Table(${count}): ${Refining.Table[${count}].Name} :: ${Refining.Table[${count}].Quantity}" 
		}
		while ( ${count:Inc} <= ${Refining.TotalTableSpace} )

		call MyOutput " ==== CurrentRecipe Data ==== "

		call MyOutput "ID: ${Refining.CurrentRecipe.ID}"
		call MyOutput "Name: ${Refining.CurrentRecipe.Name}"
		call MyOutput "Description: ${Refining.CurrentRecipe.Description}"
		call MyOutput "Stage1Name: ${Refining.CurrentRecipe.Stage1Name}"
		call MyOutput "Stage2Name: ${Refining.CurrentRecipe.Stage2Name}"
		call MyOutput "Stage3Name: ${Refining.CurrentRecipe.Stage3Name}"
		call MyOutput "Stage4Name: ${Refining.CurrentRecipe.Stage4Name}"
		call MyOutput "ActionPointsTotal: ${Refining.CurrentRecipe.ActionPointsTotal}"
		call MyOutput "ProgressBarPct: ${Refining.CurrentRecipe.ProgressBarPct}"
		call MyOutput "NumUses: ${Refining.CurrentRecipe.NumUses}"
		call MyOutput "IsWorkOrder: ${Refining.CurrentRecipe.IsWorkOrder}"
		call MyOutput "IsRefining: ${Refining.CurrentRecipe.IsRefining}"
		call MyOutput "IsFinishing: ${Refining.CurrentRecipe.IsFinishing}"
		call MyOutput "StepCount: ${Refining.CurrentRecipe.StepCount}"
		call MyOutput " ============================================================= "

		;call MyOutput "Stage: ${Refining.Stage.Name}"
		;call MyOutput "Stage: ${Refining.Stage.Index}"
		;call MyOutput "Stage: ${Refining.Stage.StepCount}"
		;call MyOutput " ============================================================= "

		tstep:Set[1]
		do
		{
			call MyOutput " ============================================================= "
			call MyOutput "Stage ${tstep}:Name: ${Refining.Stage[${tstep}].Name}"
			call MyOutput "Stage ${tstep}:Index: ${Refining.Stage[${tstep}].Index}"
			call MyOutput "Stage ${tstep}:StepCount: ${Refining.Stage[${tstep}].StepCount}"

		}
		while ( ${tstep:Inc} <= 4 ) 

		tstep:Set[1]

		do
		{
			;variable int iStage = ${Refining.CurrentRecipe.Stage[${tstep}].InStage.Index}
			call MyOutput " ============================================================= "
			;call MyOutput "Stage.Name: ${Refining.CurrentRecipe.Stage[${iStage}].Name}"
			;call MyOutput "Stage.Index: ${Refining.CurrentRecipe.Stage[${iStage}].Index}"
			;call MyOutput "Stage.StepCount: ${Refining.CurrentRecipe.Stage[${iStage}].StepCount}"

			call MyOutput "Step ${tstep}:Name: ${Refining.CurrentRecipe.Step[${tstep}].Name}"
			call MyOutput "Step ${tstep}:Description: ${Refining.CurrentRecipe.Step[${tstep}].Description}"
			call MyOutput "Step ${tstep}:AvailActionsCount: ${Refining.CurrentRecipe.Step[${tstep}].AvailActionsCount}"


			substep:Set[1]
			do
			{
				call MyOutput "Step ${tstep}:AvailAction ${substep}:Name: ${Refining.CurrentRecipe.Step[${tstep}].AvailAction[${substep}].Name}"
				call MyOutput "Step ${tstep}:AvailAction ${substep}:ActionPointCost: ${Refining.CurrentRecipe.Step[${tstep}].AvailAction[${substep}].ActionPointCost}"
				call MyOutput "Step ${tstep}:AvailAction ${substep}:Description: ${Refining.CurrentRecipe.Step[${tstep}].AvailAction[${substep}].Description}"
			}
			while ( ${substep:Inc} <= ${Refining.CurrentRecipe.Step[${tstep}].AvailActionsCount} ) 

		}
		while ( ${tstep:Inc} <= ${Refining.CurrentRecipe.StepCount} )

		call MyOutput " ============================================================= "
		call MyOutput " =============        Dump Done          ===================== "
		call MyOutput " ============================================================= "

	}

}

/* Output some info about the current Complications to the stats file */
function ComplicationStats()
{
	variable int tstep
	variable int substep

	call StatsOut "ComplicationsCount: ${Refining.ComplicationsCount}"

	if ( ${Refining.ComplicationsCount} > 0 )
	{
		tstep:Set[1]
		do
		{
			call StatsOut "Complication: ${Refining.Complication[${tstep}].Name}"
			call StatsOut "Complication: ${Refining.Complication[${tstep}].Description}"
		}
		while ( ${tstep:Inc} <= ${Refining.ComplicationsCount} )

		; Start with the highest (latest one to appear) Correction
		tstep:Set[${Refining.CorrectionsCount}]

		call StatsOut "Corrections Found: ${Refining.CorrectionsCount}"

		do
		{
			if ( ${Refining.Correction[${tstep}].AvailActionsCount} > 0 )
			{
				substep:Set[1]

				do
				{
					call StatsOut "Correction: ${Refining.Correction[${tstep}].AvailAction[${substep}].Name}"
					call StatsOut "Correction: ${Refining.Correction[${tstep}].AvailAction[${substep}].ActionPointCost}"
					call StatsOut "Correction: ${Refining.Correction[${tstep}].AvailAction[${substep}].Description}"
				}
				while ( ${substep:Inc} <= ${Refining.Correction[${tstep}].AvailActionsCount} ) 
			}
		}
		while ( ${tstep:Dec} >= 1 )
	}

}

/* Update the HUD */
function updateHUD()
{

	if ${isPaused}
	{
		UIElement[State@CHUD]:SetText["PAUSED"]
	}
	elseif ${isRunning}
	{
		; Hmm, let's set this from the CheckState function
		;UIElement[State@CHUD]:SetText["RUNNING (${cState})"]
	}
	else
	{
		UIElement[State@CHUD]:SetText["Stopped"]
	}

	if !${Refining.CurrentRecipe(exists)}
	{
		UIElement[WorkOrder@CHUD]:SetText[""]
		UIElement[WODiff@CHUD]:SetText[""]
		UIElement[Action@CHUD]:SetText[""]
	}
}


/* Output Debug messages to the IG chat window */
function DebugOut(string Message, bool SpewToIRC=FALSE)
{
	if ( ${debug} )
	{
		;call ScreenOut "${Message}"
		echo ${Message}
	}
	else
	{
		call MyOutput "${Message}"
	}
}

function SetOutputFile(string Filename)
{
	;OutputFile:Set[${Filename}]
	redirect "${OutputFile}" echo "============  ${Time} VGCraft Output started  =================="
	redirect -append "${OutputFile}" echo "============================================="
}

/* Output message to a file */
function MyOutput(string Message, bool SpewToIRC=FALSE)
{
	redirect -append "${OutputFile}" echo "${Time}::${Message}"
	
	if ${SpewToIRC}
		call IRCSpew "${Message}"
}

/* Output message to the stats file */
function StatsOut(string Message, bool SpewToIRC=FALSE)
{
	redirect -append "${StatsFile}" echo "${Time}::${Message}"
	
	if ${SpewToIRC}
		call IRCSpew "${Message}"	
}

/* Output message to the Conversation Log */
function TellsOut(string Message, bool SpewToIRC=FALSE)
{
	redirect -append "${TellsFile}" echo "${Time}:: ${Message}"
	
	call IRCSpew "TELL SENT at ${Time}:: ${Message}"	
}

/* Output an error message to screen and debug file */
function ErrorOut(string Message)
{
	call ScreenOut "*ERROR* - ${Message}"
	
	call IRCSpew "*ERROR* - ${Message}"
}

function ScreenOut(string Message, bool SpewToIRC=FALSE)
{
	call MyOutput "${Message}"

	if ( ${doConsoleOut} )
		echo "${Message}"
	else
		VGEcho "${Message}" > screen
		
	if ${SpewToIRC}
		call IRCSpew "${Message}"
}


;/*
;addtrigger damage "Your @Spell@ hits @Mob@ for @Damage@ damage"
;atom damage(string Line, string Spell, string Mob, int Damage)
;*/


/* Here it is BABY! */
function main(int testParam)
{
	variable filepath currentPath = "${Script.CurrentDirectory}"
	variable string noUpdateFile = VGCraft.iss.nopatch

	ext -require isxvg
	wait 100 ${ISXVG.IsReady}
	if !${ISXVG.IsReady}
	{
		echo "[${Time}] --> Unable to load ISXVG, exiting script"
		endscript vgcraft
	}

	autoUpdateFile:Set[FALSE]
	autoUpdateDone:Set[FALSE]

	LavishScript:RegisterEvent[VGC_onUpdatedFile]
	LavishScript:RegisterEvent[VGC_onUpdateError]
	LavishScript:RegisterEvent[VGC_onUpdateComplete]

	Event[VGC_onUpdatedFile]:AttachAtom[VGC_onUpdatedFile]
	Event[VGC_onUpdateError]:AttachAtom[VGC_onUpdateError]
	Event[VGC_onUpdateComplete]:AttachAtom[VGC_onUpdateComplete]

	if ( ${currentPath.FileExists[${noUpdateFile}]} )
	{
		echo "VGCraft:: Development setup, no auto-update"
	}
	/*
	else
	{
		if ( ${testParam} == 1 )
			VGCraft_VERSION:Set[0]

		tTimeOut:Set[${Time.Timestamp}]

		if ( ${testParam} == -1 )
		{
			; Run the auto-update patcher for Development Tree
			echo "VGCraft:: Running patch checker for Updates"
			dotnet VGCraftBot isxGamesPatcher VGCraft ${VGCraft_VERSION} http://www.reality.net/svn/vanguard/VGCraft-devtree.xml
		}
		else
		{
			; Run the auto-update patcher for Release tree
			echo "VGCraft:: Running patch checker for Updates"
			dotnet VGCraftBot isxGamesPatcher VGCraft ${VGCraft_VERSION} http://www.reality.net/svn/vanguard/release/VGCraft-manifest.xml
		}

		while !${autoUpdateDone}
		{
			wait 10
			if ( ${Math.Calc[${Time.Timestamp} - ${tTimeOut.Timestamp}]} > 120 )
	 		{
				echo "VGCraft:: Taking longer than 120 seconds for update, exiting"
				autoUpdateDone:Set[TRUE]
				return
			}
		}
	}

	; Check to see if we have updated, if so restart
	if ( ${autoUpdateFile} )
	{
		echo "VGCraft updated, exiting. Please runscript again"
		return
	}
	*/
	
	if (${testParam} == 2)
		doTestMove:Set[TRUE]

	isMoving:Set[FALSE]
	isRunning:Set[FALSE]
	isPaused:Set[FALSE]
	hasStarted:Set[FALSE]
	isPathLoaded:Set[FALSE]
	isAutoRespondLoaded:Set[FALSE]
	isChangingBelt:Set[FALSE]
	farAwayError:Set[FALSE]

	startCopper:Inc[${Me.Copper}]
	startCopper:Inc[${Math.Calc[${Me.Silver} * 100]}]
	startCopper:Inc[${Math.Calc[${Me.Gold} * 10000]}]
	startCopper:Inc[${Math.Calc[${Me.Platinum} * 1000000]}]

	statWODone:Set[0]
	statWOAbandon:Set[0]
	statCurrentCopper:Set[${startCopper}]
	statCopperSpent:Set[0]

	; Make the top level 'save' and 'vgpath' directory in case it doesn't exist
	mkdir "${savePath}"
	mkdir "${VGPathsDir}"

	; Check to see if the VGSkin.xml file exists
	/*
	variable filepath SkinPath = "${LavishScript.CurrentDirectory}/Interface/"
	if !${SkinPath.FileExists[VGSkin.xml]}
	{
		echo "VGCraft:: Creating VGSkin file"
		dotnet VGSkin "${Script.CurrentDirectory}/VGSkin.exe"
		while !${SkinPath.FileExists[VGSkin.xml]}
			wait 10

	}
	*/

	; Make sure we can get the name of the toon
	if ( ${Me.FName.Equal[NULL]} || ${Me.FName.Length} <= 0 )
	{
		VGEcho "VGCraft:: ERROR, can't get Toon Name! (${Me.FName})" > screen
		echo "VGCraft:: ERROR, can't get Toon Name! (${Me.FName})"
		return
	}
	else
	{
		; Get the First Name and use that to store save info
		savePath:Set["${Script.CurrentDirectory}/save/${Me.FName}"]

		; Make sure toonsName savePath exists
		mkdir "${savePath}"

		saveMoveFilePath:Set["${savePath}/VGPath_"]
		ConfigFile:Set["${savePath}/vgcraft-config.xml"]
		ActionFile:Set["${savePath}/action-data.xml"]
		AutoRespondFile:Set["${savePath}/autorespond.xml"]
		OutputFile:Set["${savePath}/xxcraft-output.log"]
		StatsFile:Set["${savePath}/xxcraft-stats.log"]
		TellsFile:Set["${savePath}/xxcraft-tells.log"]

		variable filepath fSavePath = "${Script.CurrentDirectory}/save/${Me.FName}/"
		if ${fSavePath.FileExists[autorespond.xml]}
		{
			; autoRespond file found
			isAutoRespondLoaded:Set[TRUE]
			echo "VGCraft:: ====== Auto-response Activated ===="
		}
		else
		{
			echo "VGCraft:: No Auto-Respond file found (would be loacated at: ${fSavePath.AbsolutePath}autorespond.xml) -- No auto response will be used."
		}


		call SetOutputFile "${OutputFile}"

		crafterType:Set[${GV[string,strCraftingTradeSelf]}]

		; Load up the saved config file
		call InitConfig

		;Tell the user that the script has initialized and is running!
		call DebugOut "VGCraft:: Crafting Assistant started -- version ${VGCraft_VERSION.Precision[2]}"
		echo "VGCraft:: Crafting Assistant started -- version ${VGCraft_VERSION.Precision[2]}"

		; Load up the UI panel
		ui -reload "${UISkin}"
		ui -reload -skin VGSkin "${UIFile}"

		iKickStep:Set[0]

		isRunning:Set[TRUE]
		isPaused:Set[FALSE]

		tTimeOut:Set[${Time.Timestamp}]
		tStartTime:Set[${Time.Timestamp}]

		if ${doRefining}
		{
			UIElement[Title@TitleBar@CraftBot]:SetText["CraftBot -- Refining"]
		}
		else
		{
			UIElement[Title@TitleBar@CraftBot]:SetText["CraftBot -- Finishing"]
		}

		; Build up the UI listboxes
		BuildRecipeList
		BuildExtraList
		BuildSellList

		CurrentChunk:Set[${Me.Chunk}]

		; Init the bNav object
		call navi.Initialize
		CurrentRegion:Set[${LNavRegion[${navi.CurrentRegionID}].Name}]
		LastRegion:Set[${LNavRegion[${navi.CurrentRegionID}].Name}]

		; Get player data and log to output file:
		call MyOutput "================================================="
		;call MyOutput "Name: ${Me.FName}"
		call MyOutput "CraftingClass: ${crafterType}"
		call MyOutput "CraftingLevel : ${Me.CraftingLevel}"
		call MyOutput "XP: ${Me.CraftXP}   XP%: ${Me.CraftXPPct}"
		call MyOutput "================================================="

		startCraftXP:Set[${Me.CraftXP}]
		lastCraftXP:Set[${Me.CraftXP}]
	
		;Initialize/Attach the event Atoms that we defined previously
		Event[VG_OnIncomingText]:AttachAtom[VGCB_OnIncomingText]

		Event[VG_onConnectionStateChange]:AttachAtom[VGCB_onConnectionStateChange]
		Event[VG_onCraftingAlert]:AttachAtom[VGCB_onCraftingAlert]
		Event[VG_onCraftingStepComplete]:AttachAtom[VGCB_onCraftingStepComplete]
		Event[VG_onAddInventoryItem]:AttachAtom[VGCB_onAddInventoryItem]
		Event[VG_onCoinUpdate]:AttachAtom[VGCB_onCoinUpdate]
		Event[VG_onReceivedTradeInvitation]:AttachAtom[VGCB_onReceivedTradeInvitation]


		;;;;;;
		;; Suggested by Zandros123
		variable int i = 1
		do
		{
			if ${Me.Inventory[${i}].CurrentEquipSlot.Equal[Crafting Container]}
			{
				sUtilPouch:Set[${Me.Inventory[${i}].Name}]
				break
			}
			
		}
		while ${i:Inc} <= ${Me.Inventory}
		;;
		;;;;;;
		
		; Move the Window to last saved position
		UIElement[CraftBot]:SetX[${windowX}]
		UIElement[CraftBot]:SetY[${windowY}]

		; Set the First Target to the Crafting Station
		cTarget:Set[${cStation}]
		nextDest:Set[${destStation}]
	}

	;; IRC ;;
	if ${AutoConnectToIRC}
	{
		call ConnectToIRC	
	}
	
	do 
	{
		if ${QueuedCommands}
			ExecuteQueued
		else
			WaitFrame
	
		if ${isMapping}
		{
			navi:AutoBox
			navi:ConnectOnMove
		}
	
		if ( ${Me.CraftXP} > ${lastCraftXP} )
		{
			tempXP:Set[${Me.CraftXP} - ${lastCraftXP}]
	
			timeCheck:Set[${Math.Calc[${Script[VGCraft].RunningTime}/1000/60/60]}]
	
			;call DebugOut "VGCraft:: time: ${timeCheck} : ${tempXP}"
	
			temp:Set[${Me.CraftXP} - ${startCraftXP}]
			tempXPHour:Set[${Math.Calc[${temp} / ${timeCheck}]}]
	
			lastCraftXP:Set[${Me.CraftXP}]
	
			UIElement[LastXP@CHUD]:SetText[${tempXP}]
			UIElement[XPHour@CHUD]:SetText[${tempXPHour}]
	
			;call ScreenOut "VGCraft:: You gained ${tempXP} XP (${tempXPHour}/Hour)"
			call StatsOut "VGCraft::       You gained ${tempXP} XP    --  (${tempXPHour}/Hour)"
		}
	
		if !${CurrentChunk.Equal[${Me.Chunk}]}
		{
			; OMG! They killed Kenny!
			; Or we have changed chunks... wacky
			fixChunkChange
		}
	
		; Update the HUD
		call updateHUD
	
		if ( ${isPaused} || !${hasStarted} )
		{
			wait 1
			tTimeOut:Set[${Time.Timestamp}]
			continue
		}
	
		; Check to see if a high Priority State was set by an error
		if ( ${pState} )
		{
			call DebugOut "VGCraft:: High Priority State Change:pState: ${pState} :: ${cState}"
			cState:Set[${pState}]
			pState:Set[0]
		}
	
		; Check what state of crafting we are in
		if ( ${cState} == CS_WAIT )
		{
			wait 5
		}
		else
		{
			if ( !${fullAuto} && (${cState} >= CS_MOVE) )
				cState:Set[CS_WAIT]
			else
				call CheckState
		}
	
		if ( ${Math.Calc[${Time.Timestamp} - ${tTimeOut.Timestamp}]} > 300 )
		{
			isMoving:Set[FALSE]
	
			if ( ${fullAuto} )
			{
				call DebugOut "VGCraft:: NOTICE: Idle for more than 5 minutes, kickstart!"
				echo "Timeout: ${Math.Calc[${Time.Timestamp} - ${tTimeOut.Timestamp}]}"
	
				Refining:Cancel
				call resetCounts
				wait 10
	
				cTarget:Set[${cStation}]
				nextDest:Set[${destStation}]
				cState:Set[CS_MOVE]
			}
	
			tTimeOut:Set[${Time.Timestamp}]
		}
	}
	while ( ${isRunning} )

	;;; This is all in atexit()
	; Save off the config stuff
	;call SaveConfig

	;call ScreenOut "VG:Total Copper Spent: ${statSpentCopper}"
	;call ScreenOut "VG:Total Copper Made: ${Math.Calc[${statCurrentCopper} - ${startCopper}].Int}"
	;call ScreenOut "VG:Total Recipes Done: ${statRecipeDone}"
	;call ScreenOut "VG:Failed Recipes: ${statRecipeFailed}"
}

function SpewStatsToIRC()
{
	variable string totalTime
	variable int totalXP

	totalXP:Set[${Me.CraftXP} - ${startCraftXP}]
	totalTime:Set[${Math.Calc[(${Script[VGCraft].RunningTime}/1000/60/60)%60].Int.LeadingZeroes[2]}:${Math.Calc[(${Script[VGCraft].RunningTime}/1000/60)%60].Int.LeadingZeroes[2]}:${Math.Calc[(${Script[VGCraft].RunningTime}/1000)%60].Int.LeadingZeroes[2]}]
	
	call IRCSpew "================================================="
	call IRCSpew "CraftingLevel : ${Me.CraftingLevel}"
	call IRCSpew "XP: ${Me.CraftXP}   XP%: ${Me.CraftXPPct}"
	call IRCSpew "Crafting XP gained: ${totalXP} in ${totalTime}"
	call IRCSpew "Factions:  Qalian Artisans: ${Me.Faction[Qalian Artisans].Value} - Thestra Artisans: ${Me.Faction[Thestra Artisans].Value} - Kojan Artisans: ${Me.Faction[Kojan Artisans].Value}"
	call IRCSpew "Total Copper Spent: ${statSpentCopper}"
	call IRCSpew "Total Copper Made: ${Math.Calc[${statCurrentCopper} - ${startCopper}].Int}"
	call IRCSpew "Total Recipes Done: ${statRecipeDone}"
	call IRCSpew "Failed Recipes: ${statRecipeFailed}"
	call IRCSpew "Sucessful Work Orders: ${statWODone}"
	call IRCSpew "Failed Work Orders: ${statWOAbandon}"
	call IRCSpew "================================================="
		
	return
}	

function atexit() 
{
	; If ISXEVG isn't loaded, then no reason to run this script.
	if (!${ISXVG(exists)}) 
	{
		return
	}

	variable string totalTime
	variable int totalXP

	totalXP:Set[${Me.CraftXP} - ${startCraftXP}]
	totalTime:Set[${Math.Calc[(${Script[VGCraft].RunningTime}/1000/60/60)%60].Int.LeadingZeroes[2]}:${Math.Calc[(${Script[VGCraft].RunningTime}/1000/60)%60].Int.LeadingZeroes[2]}:${Math.Calc[(${Script[VGCraft].RunningTime}/1000)%60].Int.LeadingZeroes[2]}]

	call ScreenOut "VG:Total Crafting XP gained: ${totalXP} in ${totalTime}"

	call MyOutput "================================================="
	call MyOutput "CraftingLevel : ${Me.CraftingLevel}"
	call MyOutput "XP: ${Me.CraftXP}   XP%: ${Me.CraftXPPct}"
	call MyOutput "Crafting XP gained: ${totalXP} in ${totalTime}"
	call MyOutput "Factions:  Qalian Artisans: ${Me.Faction[Qalian Artisans].Value} - Thestra Artisans: ${Me.Faction[Thestra Artisans].Value} - Kojan Artisans: ${Me.Faction[Kojan Artisans].Value}"
	call MyOutput "Total Copper Spent: ${statSpentCopper}"
	call MyOutput "Total Copper Made: ${Math.Calc[${statCurrentCopper} - ${startCopper}].Int}"
	call MyOutput "Total Recipes Done: ${statRecipeDone}"
	call MyOutput "Failed Recipes: ${statRecipeFailed}"
	call MyOutput "Sucessful Work Orders: ${statWODone}"
	call MyOutput "Failed Work Orders: ${statWOAbandon}"
	call MyOutput "================================================="
	
	
	;;; IRC ;;;
	if ${IRCUser["${IRCNick}"](exists)}
	{
		call SpewStatsToIRC
		call IRCSpew "--- Ending VGCraft ---"
		call IRC_Shutdown
		
	}

	;Remove the event listeners
	Event[VG_OnIncomingText]:DetachAtom[VGCB_OnIncomingText]

	Event[VG_onConnectionStateChange]:DetachAtom[VGCB_onConnectionStateChange]
	Event[VG_onCraftingAlert]:DetachAtom[VGCB_onCraftingAlert]
	Event[VG_onCraftingStepComplete]:DetachAtom[VGCB_onCraftingStepComplete]
	Event[VG_onAddInventoryItem]:DetachAtom[VGCB_onAddInventoryItem]
	Event[VG_onCoinUpdate]:DetachAtom[VGCB_onCoinUpdate]
	Event[VG_onReceivedTradeInvitation]:DetachAtom[VGCB_onReceivedTradeInvitation]

	Event[VGC_onUpdatedFile]:DetachAtom[VGC_onUpdatedFile]
	Event[VGC_onUpdateError]:DetachAtom[VGC_onUpdateError]
	Event[VGC_onUpdateComplete]:DetachAtom[VGC_onUpdateComplete]

	VG:ExecBinding[moveforward,release]

	; Save off the config stuff
	call SaveConfig	


	ui -unload "${UIFile}"
	ui -unload "${UISkin}"

	setPath:Set[0]
	setSaleItems:Set[0]
	setExtraItems:Set[0]
	setConfig:Set[0]
	LavishSettings[VGCraft]:Clear
	
	;Send a final message telling the user that the script has ended
	call DebugOut "VGCraft has ended" 
}

function ConnectToIRC()
{
	if ${bUseNickservIdentify}
		call IRC_Init "${IRCServer}" "${IRCNick}" "${NickservIdentifyPasswd}"
	else
		call IRC_Init "${IRCServer}" "${IRCNick}"
		
		
	if ${IRCUser["${IRCNick}"](exists)}
		return

	call IRC_Connect
	
	if ${bIRCChannel}
	{
		variable int Counter = 0
		if !${NickserIdentifySuccessful}
		{
			echo "VGCraft:: Waiting for Nickserv to register before joining channels..."
			do
			{
				waitframe
				Counter:Inc
				if ${Counter} > 300
				{
					echo "VGCraft:: Gave up waiting on nickserv..."
					break
				}
			}
			while !${NickserIdentifySuccessful}
		}
		
		if ${bUseChannelKey}
			call IRC_JoinChannel "${IRCChannel}" "${ChannelKey}"
		else
			call IRC_JoinChannel "${IRCChannel}"
	}
	
	call IRCSpew "VGCraft v. ${VGCraft_VERSION.Precision[2]} is connected and ready!"	
}

function IRCSpew(string aMessage)
{
	if !${IRCUser["${IRCNick}"](exists)}
		return
		
	if ${bUseIRCMaster} && ${IRCSpewToMasterPM}
		call IRC_SendPM "${IRCMaster}" "[VGCraft ${Time}] [${Me.FName}] ${aMessage}"
		
	if ${IRCSpewToChannel} && ${bIRCChannel}
		call IRC_SendPM "${IRCChannel}" "[VGCraft ${Time}] ${aMessage}"
	
}

function ConsolidateInventory()
{
	variable int itemIndexA = 0
	variable int itemIndexB = 1
	
	call DebugOut "VGCraft:: ConsolidateInventory Called"
	
	while (${itemIndexA:Inc} <= ${Me.Inventory})
	{
		if (${Me.Inventory[${itemIndexA}].Description.Find[Crafting:]} > 0)
		{
			do
	 		{
	 			if (${Me.Inventory[${itemIndexB:Inc}].Description.Find[Crafting:]} > 0)
	 			{
	 				;echo "'${Me.Inventory[${itemIndexA}].Name}' (${Me.Inventory[${itemIndexA}].ID}) vs '${Me.Inventory[${itemIndexB}].Name}' (${Me.Inventory[${itemIndexB}].ID})"
	 				if (${Me.Inventory[${itemIndexA}].ID} == ${Me.Inventory[${itemIndexB}].ID})
			 		{
						echo "Consolidating stacks of ${Me.Inventory[${itemIndexA}]} (${Me.Inventory[${itemIndexB}]})"
						Me.Inventory[${itemIndexB}]:StackWith[${Me.Inventory[${itemIndexA}].Index}]
						itemIndexB:Inc
			 		}
		 			else
		 				itemIndexB:Inc
		 		}
		 		else
		 			itemIndexB:Inc
	 		}
	 		while (${itemIndexB} <= ${Me.Inventory})
	 		itemIndexB:Set[1]
	 	}
	}
}