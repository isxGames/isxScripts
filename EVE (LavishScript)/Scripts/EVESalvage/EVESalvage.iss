;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declare all script or global variables here
variable(script) bool LeftStation
variable(script) int Counter
variable(script) bool DoLoot
variable(script) bool SalvageHereOnly
variable(script) index:string SalvageLocationLabels
variable(script) index:fleetmember MyFleet
variable(script) iterator FleetMember
variable(script) bool FoundThem
variable(script) bool UsingAt
variable(script) bool StopAfterSalvaging
variable(script) bool IgnoreContraband
variable(script) bool IgnoreRightsOnWrecks
variable(script) bool IgnoreRightsOnCans
variable(script) bool CycleBelts
variable(script) int CycleBeltsCount
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

  LeftStation:Set[FALSE]
  DoLoot:Set[FALSE]
  SalvageHereOnly:Set[FALSE]
  UsingAt:Set[FALSE]
  StopAfterSalvaging:Set[FALSE]
  IgnoreContraband:Set[FALSE]
  IgnoreRightsOnWrecks:Set[FALSE]
  IgnoreRightsOnCans:Set[FALSE]
  CycleBelts:Set[FALSE]
  FoundThem:Set[FALSE]

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

  echo " \n \n \n** EVE Salvager Script 4.7 by Amadeus ** \n \n"

  ; 'Args' is an array ... arrays are static.
	if ${Args.Size} > 0
	{
		do
		{
			if (${Args[${Iterator}].Equal[-LOOT]} || ${Args[${Iterator}].Equal[-loot]})
				DoLoot:Set[TRUE]
			elseif (${Args[${Iterator}].Equal[-HERE]} || ${Args[${Iterator}].Equal[-here]})
				SalvageHereOnly:Set[TRUE]				
			elseif (${Args[${Iterator}].Equal[-IGNORECONTRABAND]} || ${Args[${Iterator}].Equal[-ignorecontraband]} || ${Args[${Iterator}].Equal[-IgnoreContraband]} || ${Args[${Iterator}].Equal[-IC]})
				IgnoreContraband:Set[TRUE]		
			elseif (${Args[${Iterator}].Equal[-CYCLEBELTS]} || ${Args[${Iterator}].Equal[-cyclebelts]} || ${Args[${Iterator}].Equal[-CycleBelts]})
			{
				CycleBelts:Set[TRUE]						
				Iterator:Inc
				CycleBeltsCount:Set[${Args[${Iterator}]}]
				if ${CycleBeltsCount} == 0
				{
					echo "EVESalvage.CONFIG::  Bad Syntax used with '-CycleBelts'.  (Proper Syntax:  '-CycleBelts #')
					echo "EVESalvage.CONFIG::  Aborting script"
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
				    echo "EVESalvage.CONFIG::  Aborting script"
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
	        echo "EVESalvage.CONFIG::  Aborting script"
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
  	echo "* Syntax:   'run EVESalvage [flags] <bookmarklabel1> <bookmarklabel2> ...'"
  	echo "*           'run EVESalvage -at <FleetMemberName>'"
  	echo "*           'run EVESalvage -here'"
  	echo "*"
  	echo "* Flags:    '-loot'  					      [the script will loot all cans that are found in space]"
  	echo "*           '-stop'  					      [the script will stop after the last wreck is handled and will not return to the base/location from which you started]"
  	echo "*           '-cyclebelts #'			    [after everything else is handled, the script will cycle through all asteroid belts in the current solar system # times]"
  	echo "*           '-here'  					      [the script will only work at your current location (it will return to your 'home station' unless the -stop flag is used)]"
  	echo "*           '-IgnoreContraband'     [the script will not loot contraband (only applicable if the '-loot' flag is used)]"
  	echo "*           '-IgnoreRightsOnWrecks' [the script will take the time to salvage wrecks for which you do not have loot rights (after all other wrecks have been salvaged)]"
  	echo "*           '-IgnoreRightsOnCans'   [when '-loot' is used, the script will attempt to loot all cans regardless of 'loot rights']"
  	echo "*           '-maxTargets #'  	      [indicates maximum number of targets you wish to use (otherwise, default to the maximum you or your ship can handle)]"
  	echo "*"
  	echo "* Examples: 'run EVESalvage -loot -here -stop'"
  	echo "*           'run EVESalvage -loot Salvage1 Salvage2 Salvage3'"
  	echo "*           'run EVESalvage -loot -IgnoreRightsOnWrecks -cyclebelts 999'"
  	echo "*"
  	echo "* NOTES:"
  	echo "*           1.  EVESalvage will unload to a station with a bookmark labeled 'Salvager Home Base'.  If this bookmark does not exist, it will be created"
  	echo "*               if you start the script while in a station.   This bookmark is NOT deleted after the script ends.  So, if you want to set a new station"
  	echo "*               for unloading, you will need to delete the old bookmark."
  	echo "*"
  	echo "*           2.  The '-CycleBelts #' option will cycle through the belts in the system that is current once all other directives have been processed."
  	return
  }


  if ${DoLoot}
  {
  	echo "EVESalvage.CONFIG::  The Salvager will loot cans as it goes."
  	if ${IgnoreContraband}
  		echo "EVESalvage.CONFIG::  When looting, the Salvager will ignore contraband items."
	  if ${IgnoreRightsOnCans}
	  	echo "EVESalvage.CONFIG::  The Salvager will loot (or attempt to loot) all cans regardless of whether you have 'loot rights' or not."	
  }
  else
  	echo "EVESalvage.CONFIG::  The Salvager will *NOT* loot cans as it goes."
  if ${SalvageHereOnly}
  	echo "EVESalvage.CONFIG::  The Salvager will only salvage at this location."
  if ${StopAfterSalvaging}
    echo "EVESalvage.CONFIG::  This script will immediately end after salvaging has finished."
  if ${IgnoreRightsOnWrecks}
  	echo "EVESalvage.CONFIG::  The Salvager will take the time to salvage wrecks for which you do not have loot rights (NOTE: These wrecks are processed after all other wrecks have been handled.)"
  if ${CycleBelts}
	  echo "EVESalvage.CONFIG::  Once all other given commands have been processed (if applicable) the script will cycle through all asteroid belts ${CycleBeltsCount} times."

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
	
						call LeaveStation
	
		    		;;; Set destination and then activate autopilot (if we're not in that system to begin with)
		    		if (!${EVE.Bookmark[${BMLabel.Value}].SolarSystemID.Equal[${Me.SolarSystemID}]})
		    		{
		    		  echo "EVESalvage::  Setting Destination and activating auto pilot for salvage operation ${i} (${EVE.Bookmark[${BMLabel.Value}].Label})."
		    		  wait 5
		    			EVE.Bookmark[${BMLabel.Value}]:SetDestination
		    			wait 5
		    			EVE:Execute[CmdToggleAutopilot]
		    				do
		    				{
		    				   wait 50
		    				   if !${Me.AutoPilotOn(exists)}
		    				   {
		    				     do
		    				     {
		    				        wait 5
		    				     }
		    				     while !${Me.AutoPilotOn(exists)}
		    				   }
		    				}
		    			while ${Me.AutoPilotOn}
		    			wait 20
		    			do
		    			{
		    			   wait 10
		    			}
		    			while !${Me.ToEntity.IsCloaked}
		    			wait 5
		    		}
		    		
						if (${EVE.Bookmark[${BMLabel.Value}].Distance} > ${EVE.MinWarpDistance})
						{
			    		;;; Warp to location
			    		echo "EVESalvage::  Warping to salvage location..."
			    		EVE.Bookmark[${BMLabel.Value}]:WarpTo
			    		wait 120
			    		do
			    		{
			    			wait 20
			    		}
			    		while (${Me.ToEntity.Mode} == 3)
			    	}
	
	        	wait 10
						call SalvageArea ${DoLoot}
	
		    		; Remove bookmark now that we're done
		    		wait 2
		    		echo "EVESalvage::  Salvage operation at '${EVE.Bookmark[${BMLabel.Value}]}' complete ... removing bookmark."
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
		while ${i:Inc} < ${CycleBeltsCount}
		
		call CloseShipCargo
	}
	;; END '-cyclebelts #'
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Return to "Salvager Home Base" [if that bookmark exists]
  if (!${StopAfterSalvaging})
		call ReturnToHomeBase
	else
		call CloseShipCargo
	;; END [return to "Salvager Home Base"]
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
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
 	echo "EVESalvage:: EVE Salvager Script -- Ended"
	return
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;