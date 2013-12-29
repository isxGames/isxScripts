/* Contains all the code that interacts with the UI */

function SetDebug()
{
	echo "Setting debug to true"
	echo "debug: ${debug}"	
}

atom(global) PauseBot()
{
	call ScreenOut "VGCraft:: CraftBot Paused"
	echo "CraftBot Paused"
	isPaused:Set[TRUE]
	isMoving:Set[FALSE]
	moveDetector:Set[FALSE]
	;Navigator:Reset
	movePathCount:Set[0]

	This:SetText[Resume]
	UIElement[Title@TitleBar@CraftBot]:SetText["CraftBot -- PAUSED"] 
	UIElement[RunButton@CraftBot]:SetText[Resume]

	if ${doRefining}
		UIElement[Title@TitleBar@CHUD]:SetText["HUD - Refining"]
	else
		UIElement[Title@TitleBar@CHUD]:SetText["HUD - Finishing"]

	UIElement[Chunk@CHUD]:SetText[${Me.Chunk}]

}

atom(global) ResumeBot()
{
	call ScreenOut "VGCraft:: CraftBot Resumed"
	echo "CraftBot Resumed"
	isPaused:Set[FALSE]
	movePathCount:Set[0]

	;Navigator:Reset

	tTimeOut:Set[${Time.Timestamp}]

	if ${doRecipeOnly}
		cTarget:Set[${recipeStation}]

	if ( ${cState} == CS_WAIT || ${cState} >= CS_MOVE )
	{
		;cTarget:Set[${cStation}]
		;currSpot:Set[NONE]
		;nextDest:Set[${destStation}] 
		cState:Set[CS_MOVE]
	}

	if ${doRefining}
		UIElement[Title@TitleBar@CHUD]:SetText["HUD - Refining"]
	else
		UIElement[Title@TitleBar@CHUD]:SetText["HUD - Finishing"]

	UIElement[Chunk@CHUD]:SetText[${Me.Chunk}]
}

function Start()
{
	;if ${isMapping}
	;{
	;	call ScreenOut "VGCraft:: Finish Mapping first!"
	;	return
	;}

	call ScreenOut "VGCraft:: CraftBot Starting" 1
	echo "Starting CraftBot"

	call DebugOut "Station: ${cStation}" 
	call DebugOut "WO NPC: ${cWorkNPC}" 
	call DebugOut "Supplier: ${cSupplyNPC}"

	call DebugOut "VGCraft:: Current WO Count: ${TaskMaster[Crafting].CurrentWorkOrderCount}"

	VGExecute "/cleartargets"

	wait 5

	if ${doRefining}
		setupRefining
	else
		setupFinishing

	if ${doRecipeOnly}
	{
		cTarget:Set[${recipeStation}]
		nextDest:Set[${destStation}]
		cState:Set[CS_STATION]
	}
	elseif ( !${cStation.Equal[NONE]} )
	{
		cTarget:Set[${cStation}]
		nextDest:Set[${destStation}]
		cState:Set[CS_MOVE]
		call DebugOut "VGCraft:: Moving to Crafting Station :: ${cTarget}"
	}
	else
	{
		cState:Set[CS_STATION]
		nextDest:Set[${destStation}]
	}
	
	Switch ${Refining.State}
	{
		case 0
			UIElement[State@CHUD]:SetText["IDLE"]
			break
		case 1
			UIElement[State@CHUD]:SetText["STATION SETUP"]
			cState:Set[CS_STATION_SETUP]
			break
		case 2
			UIElement[State@CHUD]:SetText["COOLDOWN"]
			cState:Set[CS_ACTION_KICK]
			break
		case 3
			UIElement[State@CHUD]:SetText["KICK START"]
			cState:Set[CS_ACTION_KICK]
			break
		case 4
		
			UIElement[State@CHUD]:SetText["SELECT RECIPE"]
			cState:Set[CS_STATION_RECIPE]
			break
		Default
			UIElement[State@CHUD]:SetText["(State=${Refining.State})"]
			break
	}
	
	isPaused:Set[FALSE]
	isRunning:Set[TRUE]
	hasStarted:Set[TRUE]
	recipeRepeatNumDone:Set[0]

	tTimeOut:Set[${Time.Timestamp}]

	if ${doRefining}
		UIElement[Title@TitleBar@CHUD]:SetText["HUD - Refining"]
	else
		UIElement[Title@TitleBar@CHUD]:SetText["HUD - Finishing"]

	UIElement[Chunk@CHUD]:SetText[${Me.Chunk}]

	isMapping:Set[TRUE]
}

atom(global) StopBot()
{
	call ScreenOut "VGCraft:: CraftBot Stopped"
	echo "Stopping CraftBot"
	isRunning:Set[FALSE]
	isMoving:Set[FALSE]
	;Navigator:Reset
}

/* **************************************************************************** */

/* Read in the saved Config info */
function InitConfig()
{

	LavishSettings[AutoRespond]:Clear
	LavishSettings[Actions]:Clear
	LavishSettings[VGCraft]:Clear

	setConfig:Clear
	setPath:Clear
	setSaleItems:Clear
	setExtraItems:Clear

	LavishSettings:AddSet[Actions]
	;LavishSettings[Actions]:Import[${ActionFile}]
	actionStore:Set[${LavishSettings[Actions].GUID}]

	LavishSettings:AddSet[AutoRespond]
	LavishSettings[AutoRespond]:Import[${AutoRespondFile}]
	setAutoRespond:Set[${LavishSettings[AutoRespond].GUID}]

	LavishSettings:AddSet[VGCraft]
	LavishSettings[VGCraft]:AddSet[Config]
	LavishSettings[VGCraft]:AddSet[Path]
	LavishSettings[VGCraft]:AddSet[Sell]
	LavishSettings[VGCraft]:AddSet[Extra]

	LavishSettings[VGCraft]:Import[${ConfigFile}]

	setConfig:Set[${LavishSettings[VGCraft].FindSet[Config].GUID}]
	setPath:Set[${LavishSettings[VGCraft].FindSet[Path].GUID}]
	setSaleItems:Set[${LavishSettings[VGCraft].FindSet[Sell].GUID}]
	setExtraItems:Set[${LavishSettings[VGCraft].FindSet[Extra].GUID}]

	getWOrder:Set[${setConfig.FindSetting[getWOrder,5]}]

	doBatches:Set[${setConfig.FindSetting[doBatches,TRUE]}]
	doSets:Set[${setConfig.FindSetting[doSets,TRUE]}]
	doSingles:Set[${setConfig.FindSetting[doSingles,TRUE]}]
	preferUtility:Set[${setConfig.FindSetting[preferUtility,TRUE]}]

	apLimit2k:Set[${setConfig.FindSetting[apLimit2k,33]}]
	apLimit25k:Set[${setConfig.FindSetting[apLimit25k,33]}]
	apLimit3k:Set[${setConfig.FindSetting[apLimit3k,33]}]
	apLimit35k:Set[${setConfig.FindSetting[apLimit35k,32]}]

	minQVEasy:Set[${setConfig.FindSetting[minQVEasy,280]}]
	minQEasy:Set[${setConfig.FindSetting[minQEasy,280]}]
	minQMod:Set[${setConfig.FindSetting[minQMod,280]}]
	minQDiff:Set[${setConfig.FindSetting[minQDiff,280]}]

	maxQVEasy:Set[${setConfig.FindSetting[maxQVEasy,720]}]
	maxQEasy:Set[${setConfig.FindSetting[maxQEasy,520]}]
	maxQMod:Set[${setConfig.FindSetting[maxQMod,420]}]
	maxQDiff:Set[${setConfig.FindSetting[maxQDiff,320]}]

	apLimitRecipe:Set[${setConfig.FindSetting[apLimitRecipe,33]}]
	minQRecipe:Set[${setConfig.FindSetting[minQRecipe,280]}]
	maxQRecipe:Set[${setConfig.FindSetting[maxQRecipe,450]}]

	doRefining:Set[${setConfig.FindSetting[doRefining]}]
	doSlowTurn:Set[${setConfig.FindSetting[doSlowTurn]}]
	doExactPath:Set[${setConfig.FindSetting[doExactPath]}]
	movePrecision:Set[${setConfig.FindSetting[movePrecision,180]}]
	objPrecision:Set[${setConfig.FindSetting[objPrecision,3]}]
	maxWorkDist:Set[${setConfig.FindSetting[maxWorkDist,5]}]

	fullAuto:Set[${setConfig.FindSetting[fullAuto]}]
	doComplications:Set[${setConfig.FindSetting[doComplications]}]
	doExtraIngredients:Set[${setConfig.FindSetting[doExtraIngredients]}]
	doHardFirst:Set[${setConfig.FindSetting[doHardFirst]}]
	doBatchesFirst:Set[${setConfig.FindSetting[doBatchesFirst]}]
	doOpenPacks:Set[${setConfig.FindSetting[doOpenPacks]}]
	doRepair:Set[${setConfig.FindSetting[doRepair]}]
	doFactionGrind:Set[${setConfig.FindSetting[doFactionGrind]}]
	autoSwitchCrafting:Set[${setConfig.FindSetting[autoSwitchCrafting]}]

	doUseActionStore:Set[${setConfig.FindSetting[doUseActionStore]}]
	doPauseRecipe:Set[${setConfig.FindSetting[doPauseRecipe]}]
	doConsoleOut:Set[${setConfig.FindSetting[doConsoleOut]}]
	debug:Set[${setConfig.FindSetting[debug]}]

	;doRecipeOnly:Set[${setConfig.FindSetting[doRecipeOnly]}]
	doStep1Action:Set[${setConfig.FindSetting[doStep1Action]}]
	doStep2Action:Set[${setConfig.FindSetting[doStep2Action]}]
	recipeStep1Action:Set[${setConfig.FindSetting[recipeStep1Action]}]
	recipeStep2Action:Set[${setConfig.FindSetting[recipeStep2Action]}]
	recipeRepeatNum:Set[${setConfig.FindSetting[recipeRepeatNum]}]
	recipeName:Set[${setConfig.FindSetting[recipeName]}]
	doRecipeMatCheck:Set[${setConfig.FindSetting[doRecipeMatCheck]}]

	doGMAlarm:Set[${setConfig.FindSetting[doGMAlarm]}]
	doDetectGM:Set[${setConfig.FindSetting[doDetectGM]}]
	doGMRespond:Set[${setConfig.FindSetting[doGMRespond]}]
	doPlayerRespond:Set[${setConfig.FindSetting[doPlayerRespond]}]
	doTellAlarm:Set[${setConfig.FindSetting[doTellAlarm]}]
	doSayAlarm:Set[${setConfig.FindSetting[doTellAlarm]}]
	doLevelAlarm:Set[${setConfig.FindSetting[doLevelAlarm]}]
	doServerDown:Set[${setConfig.FindSetting[doServerDown]}]

	doAnyWO:Set[${setConfig.FindSetting[doAnyWO]}]
	doDiffWO:Set[${setConfig.FindSetting[doDiffWO]}]
	doModWO:Set[${setConfig.FindSetting[doModWO]}]
	doEasyWO:Set[${setConfig.FindSetting[doEasyWO]}]
	doVeryEasyWO:Set[${setConfig.FindSetting[doVeryEasyWO]}]
	doTrivWO:Set[${setConfig.FindSetting[doTrivWO]}]

	windowX:Set[${setConfig.FindSetting[windowX, 10]}]
	windowY:Set[${setConfig.FindSetting[windowY, 10]}]
	
	AutoConnectToIRC:Set[${setConfig.FindSetting[AutoConnectToIRC,FALSE]}]
	IRCServer:Set[${setConfig.FindSetting[IRCServer,""]}]
	IRCNick:Set[${setConfig.FindSetting[IRCNick,""]}]
	bIRCChannel:Set[${setConfig.FindSetting[bIRCChannel,FALSE]}]
	IRCChannel:Set[${setConfig.FindSetting[IRCChannel,""]}]
	bUseIRCMaster:Set[${setConfig.FindSetting[bUseIRCMaster,FALSE]}]
	IRCMaster:Set[${setConfig.FindSetting[IRCMaster,""]}]
	IRCAcceptMasterCommands:Set[${setConfig.FindSetting[IRCAcceptMasterCommands,TRUE]}]
	IRCSpewToMasterPM:Set[${setConfig.FindSetting[IRCSpewToMasterPM,FALSE]}]
	IRCSpewToChannel:Set[${setConfig.FindSetting[IRCSpewToChannel,FALSE]}]
	IRCSpewExtraDebugText:Set[${setConfig.FindSetting[IRCSpewExtraDebugText,FALSE]}]
	bUseNickservIdentify:Set[${setConfig.FindSetting[bUseNickservIdentify,FALSE]}]
	NickservIdentifyPasswd:Set[${setConfig.FindSetting[NickservIdentifyPasswd,""]}]
	bUseChannelKey:Set[${setConfig.FindSetting[bUseChannelKey,FALSE]}]
	ChannelKey:Set[${setConfig.FindSetting[ChannelKey,""]}]

	moveFileName:Set[${setConfig.FindSetting[moveFileName]}]

	if ${setPath.FindSet[${Me.Chunk}](exists)}
	{
		cRefiningStation:Set[${setPath[${Me.Chunk}].FindSetting[cRefiningStation,NONE]}]
		cRefiningWorkNPC:Set[${setPath[${Me.Chunk}].FindSetting[cRefiningWorkNPC,NONE]}]
		cRefiningSupplyNPC:Set[${setPath[${Me.Chunk}].FindSetting[cRefiningSupplyNPC,NONE]}]

		cFinishingStation:Set[${setPath[${Me.Chunk}].FindSetting[cFinishingStation,NONE]}]
		cFinishingWorkNPC:Set[${setPath[${Me.Chunk}].FindSetting[cFinishingWorkNPC,NONE]}]
		cFinishingSupplyNPC:Set[${setPath[${Me.Chunk}].FindSetting[cFinishingSupplyNPC,NONE]}]

		cRepairNPC:Set[${setPath[${Me.Chunk}].FindSetting[cRepairNPC,NONE]}]
	}
	else
	{
		setPath:AddSet[${Me.Chunk}]
	}

	; A sanity check for crazy people
	if ( ${movePrecision} > 120 )
		movePrecision:Set[120]
	if ( ${movePrecision} < 80 )
		movePrecision:Set[80]

	if ( ${objPrecision} > 5 )
		objPrecision:Set[5]
	if ( ${objPrecision} < 1 )
		objPrecision:Set[1]

	if ${windowX} < 0
		windowX:Set[10]
	if ${windowY} < 0
		windowY:Set[10]

}

/* Save user config to a file */
function SaveConfig()
{
	echo "VGCraft:: Saving Config Settings"

	setConfig:AddSetting[getWOrder, ${getWOrder}]

	setConfig:AddSetting[doBatches, ${doBatches}]
	setConfig:AddSetting[doSets, ${doSets}]
	setConfig:AddSetting[doSingles, ${doSingles}]
	setConfig:AddSetting[preferUtility, ${preferUtility}]

	setConfig:AddSetting[apLimit2k, ${apLimit2k}]
	setConfig:AddSetting[apLimit25k, ${apLimit25k}]
	setConfig:AddSetting[apLimit3k, ${apLimit3k}]
	setConfig:AddSetting[apLimit35k, ${apLimit35k}]

	setConfig:AddSetting[minQVEasy, ${minQVEasy}]
	setConfig:AddSetting[minQEasy, ${minQEasy}]
	setConfig:AddSetting[minQMod, ${minQMod}]
	setConfig:AddSetting[minQDiff, ${minQDiff}]

	setConfig:AddSetting[maxQVEasy, ${maxQVEasy}]
	setConfig:AddSetting[maxQEasy, ${maxQEasy}]
	setConfig:AddSetting[maxQMod, ${maxQMod}]
	setConfig:AddSetting[maxQDiff, ${maxQDiff}]

	setConfig:AddSetting[apLimitRecipe, ${apLimitRecipe}]
	setConfig:AddSetting[maxQRecipe, ${maxQRecipe}]
	setConfig:AddSetting[minQRecipe, ${minQRecipe}]

	setConfig:AddSetting[doRefining, ${doRefining}]
	setConfig:AddSetting[doSlowTurn, ${doSlowTurn}]
	setConfig:AddSetting[doExactPath, ${doExactPath}]
	setConfig:AddSetting[movePrecision, ${movePrecision}]
	setConfig:AddSetting[objPrecision, ${objPrecision}]
	setConfig:AddSetting[maxWorkDist, ${maxWorkDist}]

	setConfig:AddSetting[fullAuto, ${fullAuto}]
	setConfig:AddSetting[doComplications, ${doComplications}]
	setConfig:AddSetting[doExtraIngredients, ${doExtraIngredients}]
	setConfig:AddSetting[doHardFirst, ${doHardFirst}]
	setConfig:AddSetting[doBatchesFirst, ${doBatchesFirst}]
	setConfig:AddSetting[doOpenPacks, ${doOpenPacks}]
	setConfig:AddSetting[doRepair, ${doRepair}]
	setConfig:AddSetting[doFactionGrind, ${doFactionGrind}]
	setConfig:AddSetting[autoSwitchCrafting, ${autoSwitchCrafting}]

	setConfig:AddSetting[doUseActionStore, ${doUseActionStore}]
	setConfig:AddSetting[doPauseRecipe, ${doPauseRecipe}]
	setConfig:AddSetting[doConsoleOut, ${doConsoleOut}]
	setConfig:AddSetting[debug, ${debug}]

	;setConfig:AddSetting[doRecipeOnly, ${doRecipeOnly}]
	setConfig:AddSetting[doStep1Action, ${doStep1Action}]
	setConfig:AddSetting[doStep2Action, ${doStep2Action}]
	setConfig:AddSetting[recipeStep1Action, ${recipeStep1Action}]
	setConfig:AddSetting[recipeStep2Action, ${recipeStep2Action}]
	setConfig:AddSetting[recipeRepeatNum, ${recipeRepeatNum}]
	setConfig:AddSetting[recipeName, ${recipeName}]
	setConfig:AddSetting[doRecipeMatCheck, ${doRecipeMatCheck}]

	setConfig:AddSetting[doGMAlarm, ${doGMAlarm}]
	setConfig:AddSetting[doDetectGM, ${doDetectGM}]
	setConfig:AddSetting[doGMRespond, ${doGMRespond}]
	setConfig:AddSetting[doPlayerRespond, ${doPlayerRespond}]
	setConfig:AddSetting[doTellAlarm, ${doTellAlarm}]
	setConfig:AddSetting[doSayAlarm, ${doSayAlarm}]
	setConfig:AddSetting[doServerDown, ${doServerDown}]
	setConfig:AddSetting[doLevelAlarm, ${doLevelAlarm}]

	setConfig:AddSetting[doAnyWO, ${doAnyWO}]
	setConfig:AddSetting[doDiffWO, ${doDiffWO}]
	setConfig:AddSetting[doModWO, ${doModWO}]
	setConfig:AddSetting[doEasyWO, ${doEasyWO}]
	setConfig:AddSetting[doVeryEasyWO, ${doVeryEasyWO}]
	setConfig:AddSetting[doTrivWO, ${doTrivWO}]

	setConfig:AddSetting[moveFileName, ${moveFileName}]

	setConfig:AddSetting[windowX, ${UIElement[CraftBot].X}]
	setConfig:AddSetting[windowY, ${UIElement[CraftBot].Y}]
	
	setConfig:AddSetting[AutoConnectToIRC, ${AutoConnectToIRC}]
	setConfig:AddSetting[IRCServer, ${IRCServer}]
	setConfig:AddSetting[IRCNick, ${IRCNick}]
	setConfig:AddSetting[bIRCChannel, ${bIRCChannel}]
	setConfig:AddSetting[IRCChannel, ${IRCChannel}]
	setConfig:AddSetting[bUseIRCMaster, ${bUseIRCMaster}]
	setConfig:AddSetting[IRCMaster, ${IRCMaster}]
	setConfig:AddSetting[IRCAcceptMasterCommands, ${IRCAcceptMasterCommands}]
	setConfig:AddSetting[IRCSpewToMasterPM, ${IRCSpewToMasterPM}]
	setConfig:AddSetting[IRCSpewToChannel, ${IRCSpewToChannel}]
	setConfig:AddSetting[IRCSpewExtraDebugText, ${IRCSpewExtraDebugText}]
	setConfig:AddSetting[bUseNickservIdentify, ${bUseNickservIdentify}]
	setConfig:AddSetting[NickservIdentifyPasswd, ${NickservIdentifyPasswd}]
	setConfig:AddSetting[bUseChannelKey, ${bUseChannelKey}]
	setConfig:AddSetting[ChannelKey, ${ChannelKey}]
	
	setPath.FindSet[${Me.Chunk}]:AddSetting[cRefiningStation, ${cRefiningStation}]
	setPath.FindSet[${Me.Chunk}]:AddSetting[cRefiningWorkNPC, ${cRefiningWorkNPC}]
	setPath.FindSet[${Me.Chunk}]:AddSetting[cRefiningSupplyNPC, ${cRefiningSupplyNPC}]
	setPath.FindSet[${Me.Chunk}]:AddSetting[cFinishingStation, ${cFinishingStation}]
	setPath.FindSet[${Me.Chunk}]:AddSetting[cFinishingWorkNPC, ${cFinishingWorkNPC}]
	setPath.FindSet[${Me.Chunk}]:AddSetting[cFinishingSupplyNPC, ${cFinishingSupplyNPC}]

	setPath.FindSet[${Me.Chunk}]:AddSetting[cRepairNPC, ${cRepairNPC}]

	navi:SavePaths
	;Navigator.AutoMapper:Save 

	LavishSettings[VGCraft]:Export[${ConfigFile}]
	;LavishSettings[Actions]:Export[${ActionFile}]
}


/* **************************************************************************** */

atom(global) setupFinishing()
{
	cStation:Set[${cFinishingStation}]
	cWorkNPC:Set[${cFinishingWorkNPC}]
	cSupplyNPC:Set[${cFinishingSupplyNPC}]

	stationLoc:Set[${setPath.FindSet[${Me.Chunk}].FindSetting[FinishingStationLoc]}]
	workLoc:Set[${setPath.FindSet[${Me.Chunk}].FindSetting[FinishingWorkLoc]}]
	supplyLoc:Set[${setPath.FindSet[${Me.Chunk}].FindSetting[FinishingSupplyLoc]}]
	repairLoc:Set[${setPath.FindSet[${Me.Chunk}].FindSetting[RepairLoc]}]

	cTarget:Set[${cWorkNPC}]
	nextDest:Set[${destWork}]

	UIElement[Title@TitleBar@CHUD]:SetText["HUD - Finishing"]
	UIElement[Chunk@CHUD]:SetText[${Me.Chunk}]
}

atom(global) setupRefining()
{
	cStation:Set[${cRefiningStation}]
	cWorkNPC:Set[${cRefiningWorkNPC}]
	cSupplyNPC:Set[${cRefiningSupplyNPC}]

	stationLoc:Set[${setPath.FindSet[${Me.Chunk}].FindSetting[RefiningStationLoc]}]
	workLoc:Set[${setPath.FindSet[${Me.Chunk}].FindSetting[RefiningWorkLoc]}]
	supplyLoc:Set[${setPath.FindSet[${Me.Chunk}].FindSetting[RefiningSupplyLoc]}]
	repairLoc:Set[${setPath.FindSet[${Me.Chunk}].FindSetting[RepairLoc]}]

	cTarget:Set[${cWorkNPC}]
	nextDest:Set[${destWork}]

	UIElement[Title@TitleBar@CHUD]:SetText["HUD - Refining"]
	UIElement[Chunk@CHUD]:SetText[${Me.Chunk}]
}

/* We have changed chunks, load the new .XML file and associated info */
atom(global) fixChunkChange()
{
	navi.LoadPaths
	CurrentRegion:Set[${LNavRegion[${navi.CurrentRegionID}].Name}]
	LastRegion:Set[${LNavRegion[${navi.CurrentRegionID}].Name}]
	CurrentChunk:Set[${Me.Chunk}]

	if ${setPath.FindSet[${Me.Chunk}](exists)}
	{
		cRefiningStation:Set[${setPath[${Me.Chunk}].FindSetting[cRefiningStation]}]
		cRefiningWorkNPC:Set[${setPath[${Me.Chunk}].FindSetting[cRefiningWorkNPC]}]
		cRefiningSupplyNPC:Set[${setPath[${Me.Chunk}].FindSetting[cRefiningSupplyNPC]}]

		cFinishingStation:Set[${setPath[${Me.Chunk}].FindSetting[cFinishingStation]}]
		cFinishingWorkNPC:Set[${setPath[${Me.Chunk}].FindSetting[cFinishingWorkNPC]}]
		cFinishingSupplyNPC:Set[${setPath[${Me.Chunk}].FindSetting[cFinishingSupplyNPC]}]

		cRepairNPC:Set[${setPath[${Me.Chunk}].FindSetting[cRepairNPC]}]
	}
	else
	{
		setPath:AddSet[${Me.Chunk}]

		setPath.FindSet[${Me.Chunk}]:AddSetting[cRefiningStation, NONE]
		setPath.FindSet[${Me.Chunk}]:AddSetting[cRefiningWorkNPC, NONE]
		setPath.FindSet[${Me.Chunk}]:AddSetting[cRefiningSupplyNPC, NONE]
		setPath.FindSet[${Me.Chunk}]:AddSetting[cFinishingStation, NONE]
		setPath.FindSet[${Me.Chunk}]:AddSetting[cFinishingWorkNPC, NONE]
		setPath.FindSet[${Me.Chunk}]:AddSetting[cFinishingSupplyNPC, NONE]

		setPath.FindSet[${Me.Chunk}]:AddSetting[cRepairNPC, NONE]

	}

	if ${doRefining}
		setupRefining
	else
		setupFinishing

}

/* Used from the UI to select a Crafting Station */
atom(global) SetRefiningStation()
{
	if ( ${Me.Target(exists)} )
	{
		call DebugOut "VG:SetStation: ${Me.Target.Type} :: ${Me.Target.Name}"
		if ( ${Me.Target.Type.Find[Crafting]} )
		{
			cRefiningStation:Set[${Me.Target.Name}]

			setPath.FindSet[${Me.Chunk}]:AddSetting[RefiningStationLoc, "${Me.Location}"]

			call ScreenOut "VGCraft:: Refining Station set: ${Me.Target.Name}"

			;call AddNamedPoint "${cRefiningStation}"

		}
		else
		{
			call ScreenOut "VGCraft:: Select a Crafting Station first!"
		}
	}
	else
	{
		call ScreenOut "VGCraft:: Select a Crafting Station first!"
	}
}

/* Used from the UI to select a Crafting Station */
atom(global) SetFinishingStation()
{
	if ( ${Me.Target(exists)} )
	{
		call DebugOut "VG:SetStation: ${Me.Target.Type} :: ${Me.Target.Name}"
		if ( ${Me.Target.Type.Find[Crafting]} )
		{
			cFinishingStation:Set[${Me.Target.Name}]

			setPath.FindSet[${Me.Chunk}]:AddSetting[FinishingStationLoc, "${Me.Location}"]

			call ScreenOut "VGCraft:: Finishing Station set: ${Me.Target.Name}"

			;call AddNamedPoint "${cFinishingStation}"

		}
		else
		{
			call ScreenOut "VGCraft:: Select a Crafting Station first!"
		}
	}
	else
	{
		call ScreenOut "VGCraft:: Select a Crafting Station first!"
	}
}

/* Used from the UI to select a Work Order NPC */
atom(global) SetWOSearch()
{
		call AddNamedPoint "${woNPCSearch}"

		call ScreenOut "VGCraft:: Adding WO NPC search spot"
}

/* Used from the UI to select a Work Order NPC */
atom(global) SetRefiningWorkNPC()
{
	if ( ${Me.Target(exists)} )
	{
		call DebugOut "VG:SetRefiningWorkNPC: ${Me.Target.Title} :: ${Me.Target.Name}"

		cRefiningWorkNPC:Set[${Me.Target.Name}]

		setPath.FindSet[${Me.Chunk}]:AddSetting[RefiningWorkLoc, "${Me.Location}"]

		call ScreenOut "VGCraft:: Refining NPC set: ${Me.Target.Name}"

		;call AddNamedPoint "${cRefiningWorkNPC}"

	}
	else
	{
		call ScreenOut "VGCraft:: Select a Work Order NPC first!"
	}
}

/* Used from the UI to select a Work Order NPC */
atom(global) SetFinishingWorkNPC()
{
	if ( ${Me.Target(exists)} )
	{
		call DebugOut "VG:SetFinishingWorkNPC: ${Me.Target.Title} :: ${Me.Target.Name}"

		cFinishingWorkNPC:Set[${Me.Target.Name}]

		setPath.FindSet[${Me.Chunk}]:AddSetting[FinishingWorkLoc, "${Me.Location}"]

		call ScreenOut "VGCraft:: Finishing NPC set: ${Me.Target.Name}"

		;call AddNamedPoint "${cFinishingWorkNPC}"

	}
	else
	{
		call ScreenOut "VGCraft:: Select a Work Order NPC first!"
	}
}

/* Used from the UI to select a Supply Vendor NPC */
atom(global) SetRefiningSupplyNPC()
{
	if ( ${Me.Target(exists)} )
	{
		call DebugOut "VG:SetSupplier: ${Me.Target.Type} :: ${Me.Target.Name}"
		cRefiningSupplyNPC:Set[${Me.Target.Name}]

		setPath.FindSet[${Me.Chunk}]:AddSetting[RefiningSupplyLoc, "${Me.Location}"]

		call ScreenOut "VGCraft:: Supply NPC set: ${Me.Target.Name}"

		;call AddNamedPoint "${cRefiningSupplyNPC}"
	}
	else
	{
		call ScreenOut "VGCraft:: Select a Merchant first!"
	}
}

/* Used from the UI to select a Supply Vendor NPC */
atom(global) SetFinishingSupplyNPC()
{
	if ( ${Me.Target(exists)} )
	{
		call DebugOut "VG:SetSupplier: ${Me.Target.Type} :: ${Me.Target.Name}"
		cFinishingSupplyNPC:Set[${Me.Target.Name}]

		setPath.FindSet[${Me.Chunk}]:AddSetting[FinishingSupplyLoc, "${Me.Location}"]

		call ScreenOut "VGCraft:: Supply NPC set: ${Me.Target.Name}"

		;call AddNamedPoint "${cFinishingSupplyNPC}"
	}
	else
	{
		call ScreenOut "VGCraft:: Select a Merchant first!"
	}
}


/* Used from the UI to select a Supply Vendor NPC */
atom(global) SetRepairNPC()
{
	if ( ${Me.Target(exists)} )
	{
		call DebugOut "VG:SetRepair: ${Me.Target.Type} :: ${Me.Target.Name}"
		cRepairNPC:Set[${Me.Target.Name}]

		setPath.FindSet[${Me.Chunk}]:AddSetting[RepairLoc, "${Me.Location}"]

		call ScreenOut "VGCraft:: Repair NPC set: ${Me.Target.Name}"

		;call AddNamedPoint "${cRepairNPC}"
	}
	else
	{
		call ScreenOut "VGCraft:: Select a Repair Merchant first!"
	}
}

/* Add a DOOR tag to the current Region */
atom(global) AddDoor()
{
	call ScreenOut "VGCraft:: Adding Door point"

	pointcount:Inc

	navi:AddDoorTag[DOOR_${pointcount}]
}

/* Add a Named point to the LavishNav map object */
function AddNamedPoint(string aLabel)
{
	; Ok, asked to add a point to the list
	call DebugOut "VG:Path:AddPoint: ${aLabel}"

	navi:AddNamedPoint[${aLabel}]
}


/* **************************************************************************** */

/* Add item to the Sell list */
atom(global) AddSellItem(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		setSaleItems:AddSetting[${aName}, ${aName}]
		call DebugOut "VGCraft:: setSaleItems: ${setSaleItems.FindSetting[${aName}]}"
	}
	else
	{
		call DebugOut "VGCraft:: AddSellitem: ${aName} is zero length!"
	}
}

atom(global) RemoveSellItem(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		setSaleItems.FindSetting[${aName}]:Remove
		call DebugOut "VGCraft:: RemoveSellItem: ${aName}"
	}
	else
	{
		call DebugOut "VGCraft:: RemoveSellitem: ${aName} is zero length!"
	}
}

atom(global) BuildSellList()
{
	variable iterator Iterator

	UIElement[ItemsList@Items@Craft Main@CraftBot]:ClearItems
	setSaleItems:GetSettingIterator[Iterator]
	
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[ItemsList@Items@Craft Main@CraftBot]:AddItem[${Iterator.Key}]
		;call DebugOut "BuildSellList:Add: ${Iterator.Key}"
		Iterator:Next
	}
}

/* **************************************************************************** */

atom(global) AddExtraItem(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		setExtraItems:AddSetting[${aName}, ${aName}]
		call DebugOut "VGCraft:: setExtraItems: ${setExtraItems.FindSetting[${aName}]}"
	}
	else
	{
		call DebugOut "VGCraft:: AddExtraItem: ${aName} is zero length!"
	}
}

atom(global) RemoveExtraItem(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		setExtraItems.FindSetting[${aName}]:Remove
		call DebugOut "VGCraft:: RemoveExtraItem: ${aName}"
	}
	else
	{
		call DebugOut "VGCraft:: RemoveExtraItem: ${aName} is zero length!"
	}
}

atom(global) BuildExtraList()
{
	variable iterator Iterator

	UIElement[ExtraList@Items@Craft Main@CraftBot]:ClearItems
	setExtraItems:GetSettingIterator[Iterator]
	
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[ExtraList@Items@Craft Main@CraftBot]:AddItem[${Iterator.Key}]
		;call DebugOut "BuildExtraList:Add: ${Iterator.Key}"
		Iterator:Next
	}
}

/* **************************************************************************** */

/* Build up the list of recipes to select from */
atom(global) BuildRecipeList()
{
	variable int rCount

	call DebugOut "VG:BuildRecipeList called"

	if !${Refining(exists)}
		return

	rCount:Set[0]

	while ${rCount:Inc} <= ${Refining.RecipeCount}
	{
		if ! ${Refining.Recipe[${rCount}](exists)}
		{
			continue
		}

		;call DebugOut "VG:BuildRecipeList: ${Refining.Recipe[${rCount}].Name}"
		UIElement[RecipeSelectCombo@Recipe@Craft Main@CraftBot]:AddItem[${Refining.Recipe[${rCount}].Name}]
		if ${Refining.Recipe[${rCount}].Name.Equal[${recipeName}]}
			UIElement[RecipeSelectCombo@Recipe@Craft Main@CraftBot]:SelectItem[${rCount}]
	}
}

/* Used from the UI to select a Crafting Station */
function SetRecipeStation()
{
	if ${Me.Target(exists)}
	{
		call DebugOut "VG:SetRecipeStation: ${Me.Target.Type} :: ${Me.Target.Name}"
		if ${Me.Target.Type.Find[Crafting]}
		{
			recipeStation:Set[${Me.Target.Name}]
			call ScreenOut "VGCraft:: Recipe Crafting Station set: ${Me.Target.Name}"
		}
		else
		{
			call ScreenOut "VGCraft:: Select a Crafting Station first!"
		}
	}
	else
	{
		call ScreenOut "VGCraft:: Select a Crafting Station first!"
	}
}
