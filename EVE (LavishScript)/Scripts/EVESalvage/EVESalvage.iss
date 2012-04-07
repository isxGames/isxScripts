;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declare all script or global variables here
variable(script) index:string SalvageLocationLabels
variable(script) index:fleetmember MyFleet
variable(script) iterator FleetMember
variable(script) bool FoundThem
variable(script) bool UsingAt
variable(script) bool StopAfterSalvaging
variable(script) bool LootContraband
variable(script) bool IgnoreRightsOnWrecks
variable(script) bool IgnoreRightsOnCans
variable(script) bool CycleBelts
variable(script) bool DoLoot
variable(script) bool SalvageHereOnly
variable(script) bool UseCorpHangar
variable(script) int CycleBeltsCount
variable(script) int WaitTimeVariable
variable(script) int Counter
variable(script) string UnloadTo
variable(script) string CorpFolderToUse
variable(script) string HomeBaseBookmarkName
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INCLUDE FUNCTION LIBRARY
;; This means that the contents of EVESalvageLibrary.iss is 'inserted' 
;; at this point as though it were part of THIS file.
#include "EVESalvageLibrary.iss"
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; When a script is executed via the 'run' command, this is the 
;; function that Lavishscript executes first.   Once this function
;; ends, the script ends.
function main(... Args)
{
  variable int i = 1
  variable int WaitCount = 0
  variable int Iterator = 1
  variable iterator BMLabel

  DoLoot:Set[TRUE]
  SalvageHereOnly:Set[FALSE]
  UsingAt:Set[FALSE]
  StopAfterSalvaging:Set[FALSE]
  LootContraband:Set[FALSE]
  IgnoreRightsOnWrecks:Set[FALSE]
  IgnoreRightsOnCans:Set[FALSE]
  CycleBelts:Set[FALSE]
  FoundThem:Set[FALSE]
  WaitTimeVariable:Set[3]
  CorpFolderToUse:Set["Corporation Folder 1"]
  UnloadTo:Set[]
  HomeBaseBookmarkName:Set["Salvager Home Base"]
  UseCorpHangar:Set[FALSE]

  if !${ISXEVE(exists)}
  {
     echo "EVESalvage.CONFIG::  ISXEVE must be loaded to use this script."
     return
  }
  do
  {
     waitframe
  }
  while !${ISXEVE.IsReady}

  echo " \n \n \n** EVE Salvager Script 4.9 by Amadeus ** \n \n"

  ; 'Args' is an array ... arrays are static.
	if ${Args.Size} > 0
	{
		do
		{
			if (${Args[${Iterator}].Equal[-NOLOOT]} || ${Args[${Iterator}].Equal[-NoLoot]} || ${Args[${Iterator}].Equal[-NL]})
				DoLoot:Set[FALSE]
			if (${Args[${Iterator}].Equal[-LOOT]} || ${Args[${Iterator}].Equal[-loot]})
			{
				echo "EVESalvage.CONFIG::  <DEPRECATED> The '-loot' flag is no longer necessary.  EVESalvage now loots by default."
				DoLoot:Set[TRUE]				
			}
			elseif (${Args[${Iterator}].Equal[-HERE]} || ${Args[${Iterator}].Equal[-here]})
				SalvageHereOnly:Set[TRUE]				
			elseif (${Args[${Iterator}].Equal[-WAITTIMEVAR]} || ${Args[${Iterator}].Equal[-WaitTimeVar]} || ${Args[${Iterator}].Equal[-WTV]})
			{
				Iterator:Inc
				WaitTimeVariable:Set[${Args[${Iterator}]}]		
				echo "EVESalvage.CONFIG::  EVESalvage will now 'wait ${WaitTimeVariable}' while changing targets and when activating/deactivating modules"
			}	
			elseif (${Args[${Iterator}].Equal[-UNLOADTO]} || ${Args[${Iterator}].Equal[-UnloadTo]} || ${Args[${Iterator}].Equal[-UT]})
			{
				Iterator:Inc
				UnloadTo:Set[${Args[${Iterator}]}]		
			}	
			elseif (${Args[${Iterator}].Equal[-HOMEBASE]} || ${Args[${Iterator}].Equal[-HomeBase]} || ${Args[${Iterator}].Equal[-HB]})
			{
				Iterator:Inc
				HomeBaseBookmarkName:Set[${Args[${Iterator}]}]		
			}				
			elseif (${Args[${Iterator}].Equal[-USECORPFOLDER]} || ${Args[${Iterator}].Equal[-UseCorpFolder]} || ${Args[${Iterator}].Equal[-UCF]})
			{
				Iterator:Inc
				CorpFolderToUse:Set["Corporation Folder ${Args[${Iterator}]}"]		
			}				
			elseif (${Args[${Iterator}].Equal[-LOOTCONTRABAND]} || ${Args[${Iterator}].Equal[-LootContraband]} || ${Args[${Iterator}].Equal[-LC]})
				LootContraband:Set[TRUE]		
			elseif (${Args[${Iterator}].Equal[-USECORPHANGAR]} || ${Args[${Iterator}].Equal[-UseCorpHangar]} || ${Args[${Iterator}].Equal[-UCH]})
				UseCorpHangar:Set[TRUE]	
			elseif (${Args[${Iterator}].Equal[-CYCLEBELTS]} || ${Args[${Iterator}].Equal[-cyclebelts]} || ${Args[${Iterator}].Equal[-CycleBelts]})
			{
				CycleBelts:Set[TRUE]						
				Iterator:Inc
				CycleBeltsCount:Set[${Args[${Iterator}]}]
				if ${CycleBeltsCount} == 0
				{
					echo "EVESalvage.CONFIG::  Bad Syntax used with '-CycleBelts'.  (Proper Syntax:  '-CycleBelts #')
					echo "EVESalvage.ERROR::  Aborting script"
					return
				}
			}
			elseif (${Args[${Iterator}].Equal[-IGNORERIGHTSONCANS]} || ${Args[${Iterator}].Equal[-ignorerightsoncans]} || ${Args[${Iterator}].Equal[-IgnoreRightsOnCans]} || ${Args[${Iterator}].Equal[-IROC]})
				IgnoreRightsOnCans:Set[TRUE]		
			elseif (${Args[${Iterator}].Equal[-IGNORERIGHTSONWRECKS]} || ${Args[${Iterator}].Equal[-ignorerightsonwrecks]} || ${Args[${Iterator}].Equal[-IgnoreRightsOnWrecks]} || ${Args[${Iterator}].Equal[-IROW]})
				IgnoreRightsOnWrecks:Set[TRUE]													
			elseif (${Args[${Iterator}].Equal[-MAXTARGETS]} || ${Args[${Iterator}].Equal[-maxtargets]})
			{
				Iterator:Inc
				MaxTargets:Set[${Args[${Iterator}]}]
			}
			elseif (${Args[${Iterator}].Equal[-AT]} || ${Args[${Iterator}].Equal[-at]})
			{
				Iterator:Inc
				UsingAt:Set[TRUE]
				Me.Fleet:GetMembers[MyFleet]
				if ${MyFleet.Used} <= 0
				{
				    echo "EVESalvage.CONFIG::  Sorry, you cannot clear a field 'at' someone who is not in your fleet."
				    echo "EVESalvage.ERROR::  Aborting script"
				    return
				}
				MyFleet:GetIterator[FleetMember]
				if ${FleetMember:First(exists)}
				{
					do
			    {
		        if (${FleetMember.Value.ToPilot.Name.Find[${Args[${Iterator}]}]} > 0)
		        {
		           FoundThem:Set[TRUE]
		           break
		           ; "FleetMember" is a global variable and will still be available later in the script since we're stopping the iteration at this point
		        }
			    }
			    while ${FleetMember:Next(exists)}
				}
		    if !${FoundThem}
		    {
	        echo "EVESalvage.CONFIG::  There does not seem to be a fleet member with the name '${Args[${Iterator}]}'..."
	        echo "EVESalvage.ERROR::  Aborting script"
	        return
		    }
			}
			elseif (${Args[${Iterator}].Equal[-STOP]} || ${Args[${Iterator}].Equal[-stop]})
    		StopAfterSalvaging:Set[TRUE]
			elseif ${EVE.Bookmark[${Args[${Iterator}]}](exists)}
				SalvageLocationLabels:Insert[${Args[${Iterator}]}]
			else
				echo "EVESalvage.CONFIG::  '${Args[${Iterator}]}' is not a valid Bookmark label or command line argument:  Ignoring..."
		}
		while ${Iterator:Inc} <= ${Args.Size}
	}
	else
  {
  	ui -reload "${LavishScript.HomeDirectory}/Extensions/isxevepopup.xml"
  	UIElement[ISXEVE Popup]:SetTitle["EVESalvage"]
  	UIElement[status@ISXEVE Popup]:SetText["Ready..."]
  	
  	UIElement[output@ISXEVE Popup]:AddLine["* Syntax:"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     'run EVESalvage [parameters] [flags] <bookmarklabel1> <bookmarklabel2> ...'"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     'run EVESalvage [parameters] [flags] -at <FleetMemberName>'"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     'run EVESalvage [parameters] [flags] -here'"]
  	UIElement[output@ISXEVE Popup]:AddLine["*"]
  	UIElement[output@ISXEVE Popup]:AddLine["* Parameters:"]
   	UIElement[output@ISXEVE Popup]:AddLine["*     '-cyclebelts #'         [after everything else is handled, the script will cycle through all asteroid belts in the current solar system # times]"]
   	UIElement[output@ISXEVE Popup]:AddLine["*     '-maxTargets #'  	      [indicates maximum number of targets you wish to use (otherwise, default to the maximum you or your ship can handle)]"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     '-WaitTimeVar #'        [The script will 'wait #' while changing targets and activating/deactivating modules  (Advanced topic; default is 3)]"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     '-UnloadTo <NAME>'      [If your 'HomeBase' bookmark refers to a point in space, then <NAME> is the name of the entity that receives the unloaded loot/salvage]"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     '-UseCorpFolder #'      [If unloading to an entity that has corporation folders, use 'Corporation Folder #'.  (default is '1')]"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     '-HomeBase <NAME>'      [Overrides the default (\"Salvager Home Base\")]"]
  	UIElement[output@ISXEVE Popup]:AddLine["*"]
  	UIElement[output@ISXEVE Popup]:AddLine["* Flags:"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     '-stop'                 [the script will stop after the last wreck is handled and will not return to the base/location from which you started]"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     '-NoLoot'               [the script will *NOT* loot all cans that are found in space]"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     '-LootContraband'       [the script *will* loot contraband (not applicable if the '-NoLoot' flag is used)]"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     '-IgnoreRightsOnWrecks' [the script will take the time to salvage wrecks for which you do not have loot rights (after all other wrecks have been salvaged)]"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     '-IgnoreRightsOnCans'   [when looting, the script will attempt to loot all cans regardless of 'loot rights']"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     '-UseCorpHangar'        [unload to Corp Hangar (when the 'HomeBase' bookmark is a 'station bookmark'); use '-UseCorpFolder #' to override default folder]"]
  	UIElement[output@ISXEVE Popup]:AddLine["*"]
  	UIElement[output@ISXEVE Popup]:AddLine["* Examples:"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     'run EVESalvage -here -stop'"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     'run EVESalvage -IgnoreRightsOnWrecks Salvage1 Salvage2 Salvage3'"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     'run EVESalvage -IgnoreRightsOnWrecks -cyclebelts 999'"]
   	UIElement[output@ISXEVE Popup]:AddLine["*     'run EVESalvage -IgnoreRightsOnWrecks -HomeBase \"Corp Tower\" -UnloadTo \"Corporate Hangar Array\" -UseCorpFolder 7 Salvage1 Salvage2 Salvage3'"]
   	UIElement[output@ISXEVE Popup]:AddLine["*     'run EVESalvage -IgnoreRightsOnWrecks -HomeBase \"Secret Location\" -UnloadTo \"Amadeus\" -UseCorpFolder 7 Salvage1 Salvage2 Salvage3'"]
  	UIElement[output@ISXEVE Popup]:AddLine["*"]
  	UIElement[output@ISXEVE Popup]:AddLine["* NOTES:"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     1.  The '-CycleBelts #' option will cycle through the belts in the system that is current once all other directives have been processed."]
  	UIElement[output@ISXEVE Popup]:AddLine["*"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     2.  The default HomeBaseBookmark is \"Salvager Home Base\".   Any bookmark (including the default) can be a 'station bookmark' or, if you want to"]
  	UIElement[output@ISXEVE Popup]:AddLine["*         unload to an entity (POS, can, ect.), it can simply be a point in space that is next to the aforementioned entity.   If the bookmark is NOT"]
  	UIElement[output@ISXEVE Popup]:AddLine["*         a 'station bookmark', then you MUST use the '-UnloadTo <NAME>' parameter.   (NOTE:  If you want to use a bookmark other than the default"]
  	UIElement[output@ISXEVE Popup]:AddLine["*         bookmark name, then simply use the '-HomeBase <NAME>' parameter when starting the script.)"]
  	UIElement[output@ISXEVE Popup]:AddLine["*"]
  	UIElement[output@ISXEVE Popup]:AddLine["*     3.  As of this version of EVESalvage, the script will unload to the following entity types:  A) Group = \"Corporate Hangar Array\""]
  	UIElement[output@ISXEVE Popup]:AddLine["*         B) Group = \"Cargo Container\", C) Group = \"Secure Cargo Container\", D) Group = \"Industrial Command Ship\""]
  	return
  }


  if ${DoLoot}
  {
  	echo "EVESalvage.CONFIG::  EVESalvage will loot cans as it goes."
  	if ${LootContraband}
  		echo "EVESalvage.CONFIG::  When looting, the Salvager *will* loot contraband items."
  	else
  		echo "EVESalvage.CONFIG::  EVESalvage will NOT loot contraband items."
	  if ${IgnoreRightsOnCans}
	  	echo "EVESalvage.CONFIG::  EVESalvage will loot (or attempt to loot) all cans regardless of whether you have 'loot rights' or not."	
  }
  else
  	echo "EVESalvage.CONFIG::  EVESalvage will *NOT* loot cans as it goes."
  if ${SalvageHereOnly}
  	echo "EVESalvage.CONFIG::  EVESalvage will only salvage at this location."
  else
  {
  	if !${EVE.Bookmark[${HomeBaseBookmarkName}](exists)}
  	{
   		echo "EVESalvage.CONFIG::  EVESalvage has detected that you do not have a bookmark labeled '${HomeBaseBookmarkName}'.   This means that the script will end" 
   		echo "EVESalvage.CONFIG::  without returning to a station to unload.  To avoid this error message, you must do one of three things:"
   		echo "EVESalvage.CONFIG::  1.  Start the script with the '-stop' flag"
   		echo "EVESalvage.CONFIG::  2.  Create a station bookmark and call it '${HomeBaseBookmarkName}' (or, the default value: 'Salvager Home Base')"
   		echo "EVESalvage.CONFIG::  3.  Create a bookmark near an entity (called '${HomeBaseBookmarkName}' or the default 'Salvager Home Base') and use the"
   		echo "EVESalvage.CONFIG::      '-UnloadTo <NAME>' parameter (and optionally, the 'UseCorpFolder #' parameter)"
   		echo "EVESalvage.ERROR::  Aborting script"
  		return
  	}
  	else
  		echo "EVESalvage.CONFIG::  EVESalvage will return to the location stored under the bookmark '${HomeBaseBookmarkName}' after all salvaging operations have completed."
  }
  if ${StopAfterSalvaging}
  {
    echo "EVESalvage.CONFIG::  EVESalvage will immediately end after salvaging has finished."
    if (${UnloadTo.Length} > 0)
    	echo "EVESalvage.ERROR::  Why did you indicate an 'UnloadTo' destination when you want the salvager to stop after salvaging (-stop)?"
  }
  if ${IgnoreRightsOnWrecks}
  	echo "EVESalvage.CONFIG::  EVESalvage will take the time to salvage wrecks for which you do not have loot rights (NOTE: These wrecks are processed after all other wrecks have been handled.)"
  if ${CycleBelts}
	  echo "EVESalvage.CONFIG::  Once all other given commands have been processed (if applicable), EVESalvage will cycle through all asteroid belts ${CycleBeltsCount} times."
	if (${UseCorpFolder} > 1)
	{
		if (${UnloadTo.Length} < 1)
		{
			echo "EVESalvage.ERROR::  A corp folder parameter was given; however, no 'UnloadTo' value was set.   BAD SYNTAX."
			return
		}
	}
	if (${UnloadTo.Length} > 0)
		echo "EVESalvage.CONFIG::  EVESalvage will unload salvage/loot to '${CorpFolderToUse}' of '${UnloadTo}'"
	if (${UseCorpHangar})
	{
		if (${UnloadTo.Length} > 0)
		{
			echo "EVESalvage.ERROR::  The '-UseCorpHangar' flag is used when unloading to a corporate hangar in a STATION.  Type 'run evesalvage' for more information."
			echo "EVESalvage.ERROR::  Aborting script"
			return
		}
		elseif ${StopAfterSalvaging}
		{
			echo "EVESalvage.CONFIG::  You specified that the script should 'unload' to your corporation's hangar; however, the '-stop' flag means that you will not be returning to your home base."
			echo "EVESalvage.ERROR::  Aborting script"
			return
		}
		else
			echo "EVESalvage.CONFIG::  EVESalvage will unload salvage/loot to '${CorpFolderToUse}' of your corporation's hangar once all salvaging operations have been completed."
	}
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Salvage just this particular area, and then go home (or not)   [ '-here' flag used]
	if (${SalvageHereOnly})
	{
		call SalvageArea ${DoLoot}
		call CloseShipCargo
		if (!${StopAfterSalvaging})
			call ReturnToHomeBase
		return
	}
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; if the '-at' flag is used
  if ${UsingAt}
  {
		call LeaveStation

		echo "EVESalvage::  Warping to '${FleetMember.Value.ToPilot.Name}' for salvage operation..."
		if (${FleetMember.Value(exists)} && ${FleetMember.Value.ToPilot(exists)})
		{
			FleetMember.Value:WarpTo
			do
			{
				wait 20
			}
			while (${Me.ToEntity.Mode} == 3)
		
		  wait 10
			call SalvageArea ${DoLoot}
			call CloseShipCargo
		
			; Remove bookmark now that we're done
			wait 2
			echo "EVESalvage::  Salvage operation at '${FleetMember.Value.ToPilot.Name}' complete..."
		}
  }
  ;; END '-at'
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Handle any BOOKMARKS provided as arguments
  if (!${SalvageHereOnly} && ${SalvageLocationLabels.Used} > 0)
  {
  	SalvageLocationLabels:GetIterator[BMLabel]
  	if ${BMLabel:First(exists)}
  	{
	    echo "EVESalvage::  ${SalvageLocationLabels.Used} salvage locations identified"
	    do
	    {
				if (${EVE.Bookmark[${BMLabel.Value}](exists)})
	  		{
	  	      echo "EVESalvage::  Salvage location found in bookmarks: (${BMLabel.Value})..."
		    		call TravelToBookmark "${BMLabel.Value}"
		    		
	        	wait 10
						call SalvageArea ${DoLoot}
	
		    		; Remove bookmark now that we're done
		    		wait 2
		    		echo "EVESalvage::  Salvage operation at '${BMLabel.Value}' complete ... removing bookmark."
		    		EVE.Bookmark[${BMLabel.Value}]:Remove
		    		call CloseShipCargo
		    		wait 10
		    }
	    }
	    while ${BMLabel:Next(exists)}
	  }
  }
  ;; Loop for use with bookmarks ENDS 
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; '-cyclebelts #'
	if (${CycleBelts})
	{
		call LeaveStation
		i:Set[1]
		do
		{
			echo "EVESalvage::  Beginning trip ${i} of ${CycleBeltsCount} through asteroid belts in this system."
			call CycleBeltsAndSalvage
			echo "EVESalvage::  Finished trip ${i} of ${CycleBeltsCount} through the asteroid belts in this system."
		}
		while ${i:Inc} <= ${CycleBeltsCount}
		
		call CloseShipCargo
	}
	;; END '-cyclebelts #'
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Return to ${HomeBaseBookmarkName} [if that bookmark exists]
  if (!${StopAfterSalvaging})
		call ReturnToHomeBase
	else
		call CloseShipCargo
	;; END [return to ${HomeBaseBookmarkName}]
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  return
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Whenever a script ends, Lavishscript looks for a function called 
;; 'atexit' and executes it.
function atexit()
{
	variable iterator Target
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Unlock all remaining targets (if applicable)
	if (!${Me.InStation})
	{
		Me:GetTargets[Targets]
		if (${Targets.Used} > 0)
		{
			Targets:GetIterator[Target]
			if ${Target:First(exists)}
			{
				do
				{
					echo "EVESalvage->atexit::  Unlocking target '${Target.Value.Name}'"
					Target.Value:UnlockTarget
				}
				while ${Target:Next(exists)}
			}
		}
	}
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Other Misc. Items
	if (!${Me.InStation})
	{
		call ManipulateSensorBoosters "Off"
	}
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
 	echo "EVESalvage:: EVE Salvager Script -- Ended"
	return
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;