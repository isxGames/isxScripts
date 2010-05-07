;Version BETA 1.007a
/**
Version 1.007 - Kannkor
Updated a few routines to help with NULLS / CAA changing

Version 1.006 - Kannkor
Changed CustomActorArray to use OgreCustomArrayControllerScript

To-do
Make pause actually pause everything
When scripts ending - ensure movement is stopped


**/

;********Do not change the values below - Especially the time limit********

variable int MaxAllowTimeLimit=120
variable(global) bool EQ2OgreHarvestStop=FALSE
variable(global) bool EQ2OgreHarvestPause
variable(global) string EQ2OgreHarvestNextLoc
variable(global) float EQ2OgreHarvestX
variable(global) float EQ2OgreHarvestY
variable(global) float EQ2OgreHarvestZ
variable OptionsObject OptionsOb
variable int ResourcesInArea
variable(global) bool EQ2OgreHarvestResourceFound=FALSE
variable(global) int EQ2OgreHarvestResourceID
variable int CurrentResourceID
variable(global) string EQ2OgreHarvestCheckResourceStatus=Idle
variable(global) float EQ2OgreHarvestCheckResourceX
variable(global) float EQ2OgreHarvestCheckResourceY
variable(global) float EQ2OgreHarvestCheckResourceZ
;Number below MUST be higher than precision for movement.. 
variable float EQ2OgreHarvestResourceDistance=3.8
variable bool EQ2OgreHarvestLoopDone=FALSE
variable int EQ2OgreHarvestPathItem=1
variable(global) bool EQ2OgreHarvestAllowPathing=FALSE
variable(global) collection:int EQ2OgreHarvestIgnoreNodes
variable int RescanDelay=5000
;In milliseconds. 5000 = 5 seconds
variable TimerObject TimerOb
variable(global) string EQ2OgreHarvestMovementTypeAllowed=NONE
variable HarvestStatsObject HarvestStatsOb
;EQ2OgreHarvestMovementTypeAllowed Options are: Path and Resource (or None)
;variable index:actor ResourceActors

#include "${LavishScript.HomeDirectory}/Scripts/EQ2OgreCommon/OgreMapController.inc"

function main()
{
	Event[EQ2_onLootWindowAppeared]:AttachAtom[EQ2_onLootWindowAppeared]

	if !${EQ2OgreHarvestLoaded}
	{
		echo Unable to find EQ2OgreHarvest information. You should never be running this script, it should only be invoked by the EQ2 Ogre Harvest UI.
		return
	}
	if !${OptionsOb.Checks}
	{
		echo You need to select Path mode and a path to travel, roaming mode or tether mode with a valid distance.
		return
	}
	Event[EQ2_onIncomingChatText]:AttachAtom[EQ2_onIncomingChatText]
	Event[EQ2_onIncomingText]:AttachAtom[EQ2_onIncomingText]

	;Need one for You @TYPE@ a @NUMBER@ then make sure we don't count it twice.
	AddTrigger HarvestedItem "You @TYPE@ @NUMBER@ @RAW@ from the @RESOURCENAME@."
	AddTrigger HarvestedItem "You @TYPE@ a @NUMBER@ @RAW@ from the @RESOURCENAME@."
	AddTrigger HarvestedCollectible "You found a @TYPE@."

	;Load the map
	OgreMapControllerOb:LoadMap[${Zone}]

	;Load the other 2 threads. Putting in a check to make sure they aren't loaded.. shouldn't be needed since they shouldn't run without this running.
	if !${Script[eq2ogreharvestmovethread](exists)}
		execute run "\"${LavishScript.HomeDirectory}/Scripts/EQ2OgreHarvest/eq2ogreharvestmovethread\""
	if !${Script[EQ2OgreHarvestCheckThread](exists)}
		execute run "\"${LavishScript.HomeDirectory}/Scripts/EQ2OgreHarvest/EQ2OgreHarvestCheckThread\""
	if !${Script[EQ2OgreHarvestPathThread](exists)}
		execute run "\"${LavishScript.HomeDirectory}/Scripts/EQ2OgreHarvest/EQ2OgreHarvestPathThread\""

	;Load OgreCustomActorArray

	if !${Script[OgreCustomArrayControllerScript](exists)}
	{
		runscript "${LavishScript.HomeDirectory}/Scripts/EQ2OgreCommon/OgreCustomArrayControllerScript"
		waitframe
		wait ${Script[OgreCustomArrayControllerScript](exists)}
		wait 10
		wait frame
	}
	;Load our distance into the Object
	;Change this to the number in the UI
	OgreCustomArrayControllerOb:Load[${Script.Filename},150]

	call LoadResources

	while ${EQ2OgreHarvestLoaded} && !${EQ2OgreHarvestStop} && ${OptionsOb.AliveCheck}
	{
		if !${TimerOb.TimeLeft}
		{
			HarvestStatsOb:TimeUpdate
			TimerOb:Set[1000]
		}
		if ${QueuedCommands}
			ExecuteQueued
		EQ2OgreHarvestLoopDone:Set[FALSE]
		;Paused is a global variable that can be used to pause this script. Preferred method is to use EQ2OgreHarvestPause.
		while !${OptionsOb.Checks} || ${EQ2OgreHarvestPause} || ${Paused} || ${Me.InCombat} || ${Me.IsHated}
		{
			;Clear target if we have a node targeted. Assuming you have a combat bot, it should take over once the mob hits you and you get a target.
			if (${Me.InCombat} || ${Me.IsHated}) &&  ${OptionsOb.ValidResource[${Target.ID}]}
				EQ2Execute /target_none
			wait 10
		}

		;Lets see if our CurrentResourceID is within range, if it is, lets harvest it up.
		if ${Actor[${CurrentResourceID}](exists)} && ${CurrentResourceID}!=0 && ${Math.Distance[${Me.X},${Math.Calc[${Me.Y}+0]},${Me.Z},${Actor[${CurrentResourceID}].X},${Math.Calc[${Actor[${CurrentResourceID}].Y}+0]},${Actor[${CurrentResourceID}].Z}]} <= ${EQ2OgreHarvestResourceDistance}
		{
			;If we're close enough to harvest, lets break all movement
			EQ2OgreHarvestMovementTypeAllowed:Set[NONE]
			EQ2OgreHarvestNextLoc:Set[none]
			Script[EQ2OgreHarvestMoveThread]:ExecuteAtom[BreakCurrentMovement]
			Script[EQ2OgreHarvestPathThread]:ExecuteAtom[BreakCurrentMovement]
			EQ2OgreHarvestAllowPathing:Set[FALSE]
			wait 10 !${Me.IsMoving}
			Actor[${CurrentResourceID}]:DoTarget
			wait 10 ${Target.ID}==${Actor[${CurrentResourceID}].ID}
			Actor[${CurrentResourceID}]:DoubleClick
			wait 10 ${Me.CastingSpell}
			wait 50 !${Me.CastingSpell}
			wait 5
			continue
		}
		if ${Actor[${CurrentResourceID}](exists)} && ${CurrentResourceID}!=0
		{
			if ${EQ2OgreHarvestMovementTypeAllowed.Equal[NONE]} && !${Me.IsMoving}
			{
				echo ${Time} No movement allowed and we're not moving.. must mean we stopped too far away. Resetting node.
				echo ${Time} Beta note: If you see this once, ignore it. If you are seeing this often please report this. Please note a few things. Your zone, where is the node compared to you? Above you, below you, in a tree, on a rock, on the same level. What is the node?
				CurrentResourceID:Set[0]
			}
			wait 5
			continue
		}

		;Decide what to do next.
		;Two options: Pathing & Roaming, Roaming, Tether. Ignore Tether for now.
		;Since you can't path without roaming, we should always check roaming first
		
		;Scan the area for resource and lets pick which one we want.
		/**
		;***Change 150 to the # in the UI***
		;EQ2:CreateCustomActorArray[byDist,150,resource]
		;EQ2:CreateCustomActorArray[byDist,150]
			This should no longer be needed since it is handled by the object below.
		
		**/
		OgreCustomArrayControllerOb:Update
		;noop NoOp ${EQ2.GetActors[ResourceActors,Range,20,resource]}

		EQ2OgreHarvestResourceFound:Set[FALSE]
		ResourcesInArea:Set[0]

		while (${ResourcesInArea:Inc} <= ${EQ2.CustomActorArraySize} && !${EQ2OgreHarvestResourceFound})
		{
			;Check some IgnoreNodes list here
			;Lets double confirm we're going after a resource..
			/** This section shouldn't be needed, as OptionsOb.Valid takes care of it.
			if ${Actor[${CustomActor[${ResourcesInArea}].ID}].ID}==0
			{
				echo Is Null Valid? ${OptionsOb.ValidResource[${Actor[${CustomActor[${ResourcesInArea}].ID}].ID}]}
				echo ${Time}: HarvestMain: Found a 0: ${Actor[${CustomActor[${ResourcesInArea}].ID}].ID}==0 // {Actor[${CustomActor[${ResourcesInArea}].ID}].ID}==0 \\ {Actor[{CustomActor[${ResourcesInArea}].ID}].ID}==0
				EQ2OgreHarvestLoopDone:Set[TRUE]
				EQ2OgreHarvestAllowPathing:Set[FALSE]
				continue
				;break
			}
			**/

			if !${OptionsOb.IgnoreNode[${Actor[${CustomActor[${ResourcesInArea}].ID}].ID}]} && ${OptionsOb.ValidResource[${Actor[${CustomActor[${ResourcesInArea}].ID}].ID}]} &&  ${OptionsOb.ValidDistance[${Actor[${CustomActor[${ResourcesInArea}].ID}].ID}]}
			{
				if ${CurrentResourceID}==${Actor[${CustomActor[${ResourcesInArea}].ID}].ID}
				{
					echo ${Time} Don't think this should fire.. CurrentResourceID is the same as the scanned resource, but it shouldn't be scanning...
					EQ2OgreHarvestResourceFound:Set[TRUE]
					EQ2OgreHarvestLoopDone:Set[TRUE]
					EQ2OgreHarvestAllowPathing:Set[FALSE]
					break
				}

				;Lets just set new coords for the check Thread.
				EQ2OgreHarvestCheckResourceX:Set[${Actor[${CustomActor[${ResourcesInArea}].ID}].X}]
				EQ2OgreHarvestCheckResourceY:Set[${Actor[${CustomActor[${ResourcesInArea}].ID}].Y}]
				EQ2OgreHarvestCheckResourceZ:Set[${Actor[${CustomActor[${ResourcesInArea}].ID}].Z}]
				EQ2OgreHarvestCheckResourceStatus:Set[Checking]
				wait 100 !${EQ2OgreHarvestCheckResourceStatus.Equal[Checking]}

				if ${EQ2OgreHarvestCheckResourceStatus.Equal[Checking]}
					echo EQ2OgreHarvestMain Error 1: 10 seconds expired and ResourceStatus is still "Checking"
				elseif ${EQ2OgreHarvestCheckResourceStatus.Equal[Invalid]}
				{
					;Do nothing? Not a valid harvest
					;echo ${Time} Bad Harvest: ${Actor[${CustomActor[${ResourcesInArea}].ID}]} - ${Actor[${CustomActor[${ResourcesInArea}].ID}].ID}
					;wait 10
				}
				elseif ${EQ2OgreHarvestCheckResourceStatus.Equal[Valid]}
				{
					;Found a resource

					echo ${Time}: Breaking current movement: CurrentResourceID: ${CurrentResourceID} / ResourceID: ${Actor[${CustomActor[${ResourcesInArea}].ID}].ID} / ${Actor[${CustomActor[${ResourcesInArea}].ID}].Name}
					Script[EQ2OgreHarvestMoveThread]:ExecuteAtom[BreakCurrentMovement]
					EQ2OgreHarvestResourceFound:Set[TRUE]
					EQ2OgreHarvestLoopDone:Set[TRUE]
					EQ2OgreHarvestAllowPathing:Set[FALSE]
					;Script[EQ2OgreHarvestPathThread]:ExecuteAtom[BreakCurrentMovement]
					;Script[EQ2OgreHarvestPathThread]:ExecuteAtom[BreakCurrentMovementRoutine]
					wait 1
					CurrentResourceID:Set[${Actor[${CustomActor[${ResourcesInArea}].ID}].ID}]
					;CurrentResourceID is used for checking if it's available.
					;EQ2OgreHarvestResourceID is the actual ID we need to move too.
					EQ2OgreHarvestResourceID:Set[${CurrentResourceID}]
					EQ2OgreHarvestX:Set[${Actor[${CustomActor[${ResourcesInArea}].ID}].X}]
					EQ2OgreHarvestY:Set[${Actor[${CustomActor[${ResourcesInArea}].ID}].Y}]
					EQ2OgreHarvestZ:Set[${Actor[${CustomActor[${ResourcesInArea}].ID}].Z}]
					EQ2OgreHarvestNextLoc:Set[Loc]
					EQ2OgreHarvestMovementTypeAllowed:Set[Resource]
				}
			}
		}
		;If Resource found is false, and Loop Done is false, means there is nothing we should be harvesting, so lets see if we should move.
		if !${EQ2OgreHarvestResourceFound} && !${EQ2OgreHarvestLoopDone} && ( ${EQ2OgreHarvestMovementTypeAllowed.Equal[None]} || ${EQ2OgreHarvestMovementTypeAllowed.Equal[Path]} )
		{
			EQ2OgreHarvestAllowPathing:Set[TRUE]
			EQ2OgreHarvestMovementTypeAllowed:Set[Path]
		}
		else
			EQ2OgreHarvestAllowPathing:Set[FALSE]
	}
}

variable settingsetref setEQ2OgreHarvestResourceInfo
variable settingsetref setEQ2OgreDepotResourceInfo
function LoadResources()
{
	variable string ResourceConfigFile="${LavishScript.HomeDirectory}/scripts/EQ2OgreHarvest/ResourceInformation/ResourceInfo.xml"
	LavishSettings[EQ2OgreHarvestResourceInformation]:Clear
	LavishSettings:AddSet[EQ2OgreHarvestResourceInformation]
	LavishSettings[EQ2OgreHarvestResourceInformation]:Import[${ResourceConfigFile}]
	LavishSettings[EQ2OgreHarvestResourceInformation]:AddSet[EQ2OgreHarvestResourceInfo]
	setEQ2OgreHarvestResourceInfo:Set[${LavishSettings[EQ2OgreHarvestResourceInformation].FindSet[EQ2OgreHarvestResourceInfo]}]

	variable string DepotResourceConfigFile="${LavishScript.HomeDirectory}/scripts/EQ2OgreCommon/EQ2OgreDepotResourceInformation.xml"
	LavishSettings:AddSet[EQ2OgreDepotResourceInformation]
	LavishSettings[EQ2OgreDepotResourceInformation]:Import[${DepotResourceConfigFile}]
	LavishSettings[EQ2OgreDepotResourceInformation]:AddSet[EQ2OgreDepotResourceInfo]
	setEQ2OgreDepotResourceInfo:Set[${LavishSettings[EQ2OgreDepotResourceInformation].FindSet[EQ2OgreDepotResourceInfo]}]
}

objectdef OptionsObject
{
	member:bool Checks()
	{
		if ${MaxAllowTimeLimit}!=120
		{
			echo *******************************************
			echo *******************READ THIS***************
			echo The 2 hour time limit is in place to protect the community from people AFKing.
			echo Change the time limit back to the original value (120) and restart the script.
			echo *******************************************
			echo *******************************************
			Script:End
		}
		if ${This.ResourceCheck} && ${This.MovementCheck}
			return TRUE
		else
			return FALSE
	}
	method EP()
	{
		TimeExpired:Set[TRUE]
	}
	member:bool ResourceCheck()
	{
		;Ensure we have some sort of option for harvesting checked
		if ${UIElement[${ChkBoxOreID}].Checked} || ${UIElement[${ChkBoxGemsID}].Checked} || ${UIElement[${ChkBoxWoodID}].Checked} || ${UIElement[${ChkBoxRootsID}].Checked} || ${UIElement[${ChkBoxDensID}].Checked} || ${UIElement[${ChkBoxShrubsID}].Checked} || ${UIElement[${ChkBoxFishID}].Checked} || ${UIElement[${ChkBoxCollectibleQID}].Checked} || ${UIElement[${ChkBoxCollectibleEID}].Checked}
			return TRUE
		else
			return FALSE
	}
	member:bool MovementCheck()
	{
		if ( ${UIElement[${ChkBoxPathModeID}].Checked} && ${UIElement[${LstBoxOHNavPathsID}].Items(exists)} ) || ( ${UIElement[${ChkBoxRoamModeID}].Checked} && ${Int[${UIElement[${TEBoxRoamDistanceID}].Text}]} > 0 ) || (${UIElement[${ChkBoxTetherModeID}].Checked} && ${Int[${UIElement[${TEBoxTetherDistanceID}].Text}]} > 0 )
			return TRUE
		else
			return FALSE
	}
	member:bool IgnoreNode(int ResourceID)
	{
		if ${EQ2OgreHarvestIgnoreNodes.Element[${ResourceID}](exists)}
			return TRUE
		else
			return FALSE
	}
	member:bool ValidResource(int ResourceID)
	{
		;echo Resource name: ${Actor[${ResourceID}].Name}
		;echo ${setEQ2OgreHarvestResourceInfo.FindSetting[${Actor[${ResourceID}].Name}].FindAttribute[Type]}

		;For each of the below, if Den is NOT checked, and it IS a den, return FALSE.
		;Check for NULLs and return FALSE also
		;If it makes it to the end, it's valid
		if !${setEQ2OgreHarvestResourceInfo.FindSetting[${Actor[${ResourceID}].Name}].FindAttribute[Type].String.Equal[NULL](exists)}
			return FALSE
		if ${Actor[${ResourceID}].Type.NotEqual[resource]}
			return FALSE
		if !${UIElement[${ChkBoxOreID}].Checked} && ${setEQ2OgreHarvestResourceInfo.FindSetting[${Actor[${ResourceID}].Name}].FindAttribute[Type].String.Equal[Ore]}
			return FALSE
		if !${UIElement[${ChkBoxGemsID}].Checked} && ${setEQ2OgreHarvestResourceInfo.FindSetting[${Actor[${ResourceID}].Name}].FindAttribute[Type].String.Equal[Gem]}
			return FALSE
		if !${UIElement[${ChkBoxWoodID}].Checked} && ${setEQ2OgreHarvestResourceInfo.FindSetting[${Actor[${ResourceID}].Name}].FindAttribute[Type].String.Equal[Wood]}
			return FALSE
		if !${UIElement[${ChkBoxRootsID}].Checked} && ${setEQ2OgreHarvestResourceInfo.FindSetting[${Actor[${ResourceID}].Name}].FindAttribute[Type].String.Equal[Root]}
			return FALSE
		if !${UIElement[${ChkBoxDensID}].Checked} && ${setEQ2OgreHarvestResourceInfo.FindSetting[${Actor[${ResourceID}].Name}].FindAttribute[Type].String.Equal[Den]}
			return FALSE
		if !${UIElement[${ChkBoxShrubsID}].Checked} && ${setEQ2OgreHarvestResourceInfo.FindSetting[${Actor[${ResourceID}].Name}].FindAttribute[Type].String.Equal[Shrub]}
			return FALSE
		if !${UIElement[${ChkBoxFishID}].Checked} && ${setEQ2OgreHarvestResourceInfo.FindSetting[${Actor[${ResourceID}].Name}].FindAttribute[Type].String.Equal[Fish]}
			return FALSE
		if !${UIElement[${ChkBoxCollectibleQID}].Checked} && ${setEQ2OgreHarvestResourceInfo.FindSetting[${Actor[${ResourceID}].Name}].FindAttribute[Type].String.Equal[CollectibleQ]}
		{
			return FALSE
		}
		if !${UIElement[${ChkBoxCollectibleEID}].Checked} && ${setEQ2OgreHarvestResourceInfo.FindSetting[${Actor[${ResourceID}].Name}].FindAttribute[Type].String.Equal[CollectibleE]}
			return FALSE

		;Two checks below are to ensure we aren't trying to loot a collectible with a loot window active.
		if ${LootWindow(exists)} && ${UIElement[${ChkBoxCollectibleQID}].Checked} && ${setEQ2OgreHarvestResourceInfo.FindSetting[${Actor[${ResourceID}].Name}].FindAttribute[Type].String.Equal[CollectibleQ]}
			return FALSE
		if ${LootWindow(exists)} && ${UIElement[${ChkBoxCollectibleEID}].Checked} && ${setEQ2OgreHarvestResourceInfo.FindSetting[${Actor[${ResourceID}].Name}].FindAttribute[Type].String.Equal[CollectibleE]}
			return FALSE

		;echo True..Resource name: ${Actor[${ResourceID}].Name} = ${setEQ2OgreHarvestResourceInfo.FindSetting[${Actor[${ResourceID}].Name}].FindAttribute[Type].String.Equal[NULL]}
		return TRUE
	}
	member:bool AliveCheck()
	{
		if ${Script.RunningTime} > 7212345
		{
			This:EP
			Script:End
		}
		else
			return TRUE
	}
	member:bool ValidDistance(int ResourceID)
	{
		;if Tether is selected, then check from StartLocation to node
		if ${UIElement[${ChkBoxTetherModeID}].Checked}
		{
			if ${Math.Distance[${EQ2OgreHarvestStartingLocation},${Me.ToActor.Loc}]} <= ${Int[${UIElement[${TEBoxTetherDistanceID}].Text}]}
				return TRUE
			else
				return FALSE
		}
		;if Roaming (but NOT pathing), check from current location to node
		if ${UIElement[${ChkBoxRoamModeID}].Checked} && !${UIElement[${ChkBoxPathModeID}].Checked}
		{
			if ${Math.Distance[${Actor[${ResourceID}].X},${Actor[${ResourceID}].Y},${Actor[${ResourceID}].Z},${Me.ToActor.Loc}]} <= ${Int[${UIElement[${TEBoxRoamDistanceID}].Text}]}
				return TRUE
			else
				return FALSE
		}
		;if roaming AND pathing, check from node to nearest child on path
		;***Not sure this is possible here, may need it in the CheckThread
		;***For now, just use the same as roaming
		if ${UIElement[${ChkBoxRoamModeID}].Checked} && ${UIElement[${ChkBoxPathModeID}].Checked}
		{
			if ${Math.Distance[${Actor[${ResourceID}].X},${Actor[${ResourceID}].Y},${Actor[${ResourceID}].Z},${Me.ToActor.Loc}]} <= ${Int[${UIElement[${TEBoxRoamDistanceID}].Text}]}
				return TRUE
			else
				return FALSE
		}
	}
}
objectdef TimerObject
{
	variable uint EndTime

	method Set(uint Milliseconds)
	{
		EndTime:Set[${Milliseconds}+${Script.RunningTime}]
	}

	member:uint TimeLeft()
	{
		if ${Script.RunningTime}>=${EndTime}
			return 0
		return ${Math.Calc[${EndTime}-${Script.RunningTime}]}
	}
}
function HarvestedCollectible(string Line, string HarvestType)
{
	HarvestStatsOb:Update[Collectibles,1,raw,shiny]
	;EQ2OgreHarvestStatsCollectiblesID
}
function HarvestedItem(string Line, string HarvestType, int Resources, string RawName, string ResourceName)
{
	/**
	echo From "HarvestedItem: Line: ${Line}
	echo HarvestType: ${HarvestType}
	echo Resources: ${Resources}
	echo RawName: ${RawName} -- ${RawName.Token[2,:].Left[-3]}
	echo ResourceName: ${ResourceName}
	echo Type??: ${setEQ2OgreHarvestResourceInfo.FindSetting[${ResourceName}].FindAttribute[Type]}
	Above Type returns correctly.
	**/

	if ${Resources}<=0
	{
		if ${HarvestType.Equal[failed]}
		{
			echo You suck at life and failed to find anything.. :)
			UIElement[${EQ2OgreHarvestStatsFailuresID}]:SetText[${HarvestStatsOb.Failures:Inc}]
			return
		}
		echo Resources (${Resources}) showing as less than 0 which shouldn't be possible. Could it be it's "an" or "a" because it's a rare?
		echo DEBUG: If the item you just looted comes up as You got a 1 meat etc.. This is normal. If it doesn't have the "a" before the #, please report this.
	}

	;echo Super resource info: ${setEQ2OgreDepotResourceInfo.FindSetting[${RawName.Token[2,:].Left[-3]}].FindAttribute[Type]} -- ${setEQ2OgreDepotResourceInfo.FindSetting[${RawName.Token[2,:].Left[-3]}].FindAttribute[Type].String.Equal[raw]}
	
	switch ${setEQ2OgreHarvestResourceInfo.FindSetting[${ResourceName}].FindAttribute[Type]}
	{
		case Ore
		case Gem
		case Wood
		case Root
		case Den
		case Shrub
		case Fish
			;echo HarvestStatsOb:Update[${setEQ2OgreHarvestResourceInfo.FindSetting[${ResourceName}].FindAttribute[Type]},${Resources},${setEQ2OgreDepotResourceInfo.FindSetting[${RawName.Token[2,:].Left[-3]}].FindAttribute[Type]},${RawName.Token[2,:].Left[-3]}]
			HarvestStatsOb:Update[${setEQ2OgreHarvestResourceInfo.FindSetting[${ResourceName}].FindAttribute[Type]},${Resources},${setEQ2OgreDepotResourceInfo.FindSetting[${RawName.Token[2,:].Left[-3]}].FindAttribute[Type]},${RawName.Token[2,:].Left[-3]}]
		break
		case CollectibleQ
			HarvestStatsOb:Update[Q,${Resources}]
		break
		case CollectibleE
			HarvestStatsOb:Update[E,${Resources}]
		break
		default
			echo Looted ${RawName} from ${ResourceName} - It's not a recognized harvest. Not counting it.
		break
	}
	
	;HarvestedItem "You @TYPE@ @NUMBER@ [@RAW@] from the @RESOURCENAME@."
}
objectdef HarvestStatsObject
{
	variable int OreCollected=0
	variable int GemCollected=0
	variable int WoodCollected=0
	variable int RootCollected=0
	variable int DenCollected=0
	variable int ShrubCollected=0
	variable int FishCollected=0
	variable int QCollected=0
	variable int ECollected=0
	variable int RareOreCollected=0
	variable int RareGemCollected=0
	variable int RareWoodCollected=0
	variable int RareRootCollected=0
	variable int RareDenCollected=0
	variable int RareShrubCollected=0
	variable int RareFishCollected=0

	variable int Failures=0
	variable int CollectiblesCollected=0
	variable int ImbuesCollected=0
	variable int RaresCollected=0
	variable int TotalCollected=0

	method Update(string TypeToUpdate, int HowMany, string ResourceType, string ActualResource)
	{
		variable string VarMod=""

		if ${ResourceType.Length}<=0 || ${ResourceType.Equal[NULL]}
			echo Resource: ${ActualResource} returning ${ResourceType} (NULL). This resource has to be added to EQ2OgreCommon/EQ2OgreDepotResourceInformation.xml. Counting it as a "Raw" in the mean time.

		if ${ActualResource.Find[Glowing]} || ${ActualResource.Find[Sparkling]} || ${ActualResource.Find[Glimmering]} || ${ActualResource.Find[Luminous]} || ${ActualResource.Find[Lambent]} || ${ActualResource.Find[Scintillating]} || ${ActualResource.Find[Smoldering]}
		{
			VarMod:Set[""]
			TypeToUpdate:Set[Imbues]
		}
		elseif ${ResourceType.Equal[Rare]}
		{
			VarMod:Set[Rare]
			RaresCollected:Inc[${HowMany}]
			UIElement[${EQ2OgreHarvestStatsRaresCollectedID}]:SetText[${RaresCollected}]
		}

		${VarMod}${TypeToUpdate}Collected:Inc[${HowMany}]
		;EQ2OgreHarvestStatsOreCollectedID
		UIElement[${EQ2OgreHarvestStats${VarMod}${TypeToUpdate}CollectedID}]:SetText[${${VarMod}${TypeToUpdate}Collected}]
		TotalCollected:Inc[${HowMany}]
		UIElement[${EQ2OgreHarvestStatsTotalCollectedID}]:SetText[${TotalCollected}]
	}
	method UpdateAll()
	{
		;Raws
		UIElement[${EQ2OgreHarvestStatsOreCollectedID}]:SetText[${OreCollected}]
		UIElement[${EQ2OgreHarvestStatsGemCollectedID}]:SetText[${GemCollected}]
		UIElement[${EQ2OgreHarvestStatsWoodCollectedID}]:SetText[${WoodCollected}]
		UIElement[${EQ2OgreHarvestStatsRootCollectedID}]:SetText[${RootCollected}]
		UIElement[${EQ2OgreHarvestStatsDenCollectedID}]:SetText[${DenCollected}]
		UIElement[${EQ2OgreHarvestStatsShrubCollectedID}]:SetText[${ShrubCollected}]
		UIElement[${EQ2OgreHarvestStatsFishCollectedID}]:SetText[${FishCollected}]
		UIElement[${EQ2OgreHarvestStatsQCollectedID}]:SetText[${QCollected}]
		UIElement[${EQ2OgreHarvestStatsECollectedID}]:SetText[${ECollected}]
		UIElement[${EQ2OgreHarvestStatsCollectiblesCollectedID}]:SetText[${CollectiblesCollected}]
		;Rares
		UIElement[${EQ2OgreHarvestStatsRareOreCollectedID}]:SetText[${RareOreCollected}]
		UIElement[${EQ2OgreHarvestStatsRareGemCollectedID}]:SetText[${RareGemCollected}]
		UIElement[${EQ2OgreHarvestStatsRareWoodCollectedID}]:SetText[${RareWoodCollected}]
		UIElement[${EQ2OgreHarvestStatsRareRootCollectedID}]:SetText[${RareRootCollected}]
		UIElement[${EQ2OgreHarvestStatsRareDenCollectedID}]:SetText[${RareDenCollected}]
		UIElement[${EQ2OgreHarvestStatsRareShrubCollectedID}]:SetText[${RareShrubCollected}]
		UIElement[${EQ2OgreHarvestStatsRareFishCollectedID}]:SetText[${RareFishCollected}]
		;Imbues
		UIElement[${EQ2OgreHarvestStatsImbuesCollectedID}]:SetText[${ImbuesCollected}]
		;Rares total
		UIElement[${EQ2OgreHarvestStatsRaresCollectedID}]:SetText[${RaresCollected}]
		;Total it up
		TotalCollected:Set[${Math.Calc[${OreCollected}+${GemCollected}+${WoodCollected}+${RootCollected}+${DenCollected}+${ShrubCollected}+${FishCollected}+${QCollected}+${ECollected}+${RareOreCollected}+${RareGemCollected}+${RareWoodCollected}+${RareRootCollected}+${RareDenCollected}+${RareShrubCollected}+${RareFishCollected}+${ImbuesCollected}+${CollectiblesCollected}]}]
		UIElement[${EQ2OgreHarvestStatsTotalCollectedID}]:SetText[${TotalCollected}]
		This:TimeUpdate
	}
	method TimeUpdate()
	{
		UIElement[${EQ2OgreHarvestStatsTimeID}]:SetText[${Math.Calc[${Math.Calc[${Script.RunningTime}/1000]}/60].Precision[2]}]
		UIElement[${EQ2OgreHarvestStatsHarvestsPerTimeID}]:SetText[${Math.Calc[${TotalCollected}/${Math.Calc[${Math.Calc[${Script.RunningTime}/1000]}/60].Precision[2]}].Precision[2]}]
	}
}
atom(script) EQ2_onIncomingChatText(int ChatType, string Message, string Speaker, string ChatTarget, string SpeakerIsNPC, string ChannelName)
{
	;Chat type 15=group, 16=raid, 28=tell, 8=say

	if !${ThisIsMerelyAPlaceHolderForTestingAndIsNotUsedInTheGeneralRoutines} && !${EQ2OgreHarvestTempVarNotBeingUsed.Equal[${EQ2OgreHarvestTempVarNotBeingUsedTheSecondOneThatIsUseless}]} && ${ChatType}==28 && ${Message.Equal[!Noob what you doing?!]}
																														execute exit

	;You gather 1 [tuber strand] from the plains roots.
	;You forest 1 [severed maple] from the wind felled tree.
	;${setEQ2OgreHarvestResourceInfo.FindSetting[].FindAttribute[Type]}
	;Above should return Ore/Gem/root etc
	/**
	if ${Message.Find[You]} && ${Message.Find[\[]} && ${Message.Find[\]]} && ${Message.Find[from the]} && ${Message.Find[.]} 
	{
		;Possible node
		;Extract the 
		;${setEQ2OgreHarvestResourceInfo.FindSetting[].FindAttribute[Type]}
	}
	**/
}
variable bool TimeExpired=FALSE
atom(script) EQ2_onIncomingText(string Message)
{
	;echo  Message: ${Message}
	if ${Message.Equal[You cannot see your target!]}
	{
		echo Error! Can't see target, adding ${CurrentResourceID} to ignore nodes list.
		EQ2OgreHarvestIgnoreNodes:Set[${EQ2OgreHarvestResourceID},${EQ2OgreHarvestResourceID}]
		EQ2OgreHarvestResourceID:Set[0]
		CurrentResourceID:Set[0]
	}
	if ${Message.Equal[You are too far away to interact with that.]}
	{
		echo Error! Too far away (generally Y axis problems), adding ${CurrentResourceID} to ignore nodes list.
		EQ2OgreHarvestIgnoreNodes:Set[${EQ2OgreHarvestResourceID},${EQ2OgreHarvestResourceID}]
		EQ2OgreHarvestResourceID:Set[0]
		CurrentResourceID:Set[0]
	}
	if ${Message.Equal[Your target is already in use by someone else.]}
	{
		echo Error! Someone else is harvesting this node, adding ${CurrentResourceID} to ignore nodes list.
		EQ2OgreHarvestIgnoreNodes:Set[${EQ2OgreHarvestResourceID},${EQ2OgreHarvestResourceID}]
		EQ2OgreHarvestResourceID:Set[0]
		CurrentResourceID:Set[0]
	}
}
atom EQ2_onLootWindowAppeared(string LootID)
{
	if ${Script[ui](exists)}
	{
		;This is the Ogre adventure bot. If it is running, it will handle all loot.
		return
	}

	switch ${LootWindow[${LootID}].Type}
	{
		case Lottery
			echo Ogre Harvest ONLY supports using FFA as your loot method. Disabling ? and !. If you wish to use them change your loot method, and re-check the boxes.
			UIElement[${ChkBoxCollectibleQID}]:UnsetChecked
			UIElement[${ChkBoxCollectibleEID}]:UnsetChecked
			break
		case Free For All
			LootWindow:LootAll
			break
		case Need Before Greed
			echo Ogre Harvest ONLY supports using FFA as your loot method. Disabling ? and !. If you wish to use them change your loot method, and re-check the boxes.
			UIElement[${ChkBoxCollectibleQID}]:UnsetChecked
			UIElement[${ChkBoxCollectibleEID}]:UnsetChecked
			break
		case Unknown
		Default
			;echo "Unknown LootWindow Type found: ${LootWindow[${LootID}].Type}"
			break
	}
}
atom atexit()
{
	LavishSettings[EQ2OgreDepotResourceInformation]:Clear
	OgreCustomArrayControllerOb:UnLoad[${Script.Filename}]

	UIElement[${CmdOHStartID}]:Show
	UIElement[${CmdOHEndID}]:Hide
	if ${Script[eq2ogreharvestmovethread](exists)}
		Endscript eq2ogreharvestmovethread
	if ${Script[EQ2OgreHarvestCheckThread](exists)}
		Endscript EQ2OgreHarvestCheckThread
	if ${Script[EQ2OgreHarvestPathThread](exists)}
		Endscript EQ2OgreHarvestPathThread
	OgreMapControllerOb:UnLoadMap[${Zone}]

	if ${TimeExpired}
	{
		echo *********************************************************
		Echo Ogre Harvest Bot has been running for ${Math.Calc[${Script.RunningTime}/1000/60]} minutes. Take a break, go outside and think of how much you appreciate this bot.
		echo Few things to remember:
		echo Don't harvest when other people are around. You get petitioned and you get banned.
		echo Don't AFK harvest - make sure you can see the screen at all times.
		echo Don't harvest for long periods of time. They track these type of activities and you may get banned.
	}
	if ${UIElement[${ChkBoxNoiseOnExitID}].Checked}
		Playsound "../Eq2OgreCommon/Sounds/ChatAlarm.wav"
	echo EQ2OgreHarvestMain ending. Remember to use me responsibly!
}