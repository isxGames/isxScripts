;; Declare all script or global variables here
variable(script) bool LeftStation
variable(script) int Counter
variable(script) bool DoLoot
variable(script) bool SalvageHereOnly
variable(script) index:string SalvageLocationLabels
variable(script) index:fleetmember MyFleet
variable(script) int MyFleetCount
variable(script) int FleetIterator
variable(script) bool FoundThem
variable(script) bool UsingAt
variable(script) bool StopAfterSalvaging
variable(script) bool IgnoreContraband
variable(script) bool IgnoreRightsOnWrecks
variable(script) bool IgnoreRightsOnCans
variable(script) bool CycleBelts
variable(script) int CycleBeltsCount


;; INCLUDE FUNCTION LIBRARY
#include "EVESalvageLibrary.iss"

function atexit()
{
 	echo "EVE Salvager Script -- Ended"
	return
}

function main(... Args)
{
  variable int i = 1
  variable int j = 1
  variable int k = 1
  variable int WaitCount = 0
  variable int Iterator = 1

  LeftStation:Set[FALSE]
  DoLoot:Set[FALSE]
  SalvageHereOnly:Set[FALSE]
  UsingAt:Set[FALSE]
  StopAfterSalvaging:Set[FALSE]
  IgnoreContraband:Set[FALSE]
  IgnoreRightsOnWrecks:Set[FALSE]
  IgnoreRightsOnCans:Set[FALSE]
  CycleBelts:Set[FALSE]

  if !${ISXEVE(exists)}
  {
     echo "- CONFIG:  ISXEVE must be loaded to use this script."
     return
  }
  do
  {
     waitframe
  }
  while !${ISXEVE.IsReady}

  echo " \n \n \n** EVE Salvager Script 4.4 by Amadeus ** \n \n"

  ; 'Args' is an array ... arrays are static.  Copying to an index just in case we have a desire at some point to add/remove elements.
	if ${Args.Size} > 0
	{
		do
		{
			if (${Args[${Iterator}].Equal[-LOOT]} || ${Args[${Iterator}].Equal[-loot]})
				DoLoot:Set[TRUE]
			elseif (${Args[${Iterator}].Equal[-HERE]} || ${Args[${Iterator}].Equal[-here]})
				SalvageHereOnly:Set[TRUE]				
			elseif (${Args[${Iterator}].Equal[-IGNORECONTRABAND]} || ${Args[${Iterator}].Equal[-ignorecontraband]} || ${Args[${Iterator}].Equal[-IgnoreContraband]})
				IgnoreContraband:Set[TRUE]		
			elseif (${Args[${Iterator}].Equal[-CYCLEBELTS]} || ${Args[${Iterator}].Equal[-cyclebelts]} || ${Args[${Iterator}].Equal[-CycleBelts]})
			{
				CycleBelts:Set[TRUE]						
				Iterator:Inc
				CycleBeltsCount:Set[${Args[${Iterator}]}]
				if ${CycleBeltsCount} == 0
				{
					echo "- CONFIG:  Bad Syntax used with '-CycleBelts'.  (Proper Syntax:  '-CycleBelts #')
					echo "- CONFIG:  Aborting script"
					return
				}
			}
			elseif (${Args[${Iterator}].Equal[-IGNORERIGHTSONCANS]} || ${Args[${Iterator}].Equal[-ignorerightsoncans]} || ${Args[${Iterator}].Equal[-IgnoreRightsOnCans]})
				IgnoreRightsOnCans:Set[TRUE]		
			elseif (${Args[${Iterator}].Equal[-IGNORERIGHTSONWRECKS]} || ${Args[${Iterator}].Equal[-ignorerightsonwrecks]} || ${Args[${Iterator}].Equal[-IgnoreRightsOnWrecks]})
				IgnoreRightsOnWrecks:Set[TRUE]													
			elseif (${Args[${Iterator}].Equal[-MAXTARGETS]} || ${Args[${Iterator}].Equal[-maxtargets]})
			{
				Iterator:Inc
				MaxTargets:Set[${Args[${Iterator}]}]
			}
			elseif (${Args[${Iterator}].Equal[-AT]} || ${Args[${Iterator}].Equal[-at]})
			{
				UsingAt:Set[TRUE]
				Iterator:Inc
				Me.Fleet:GetMembers[MyFleet]
				MyFleetCount:Set[${MyFleet.Used}]

				if ${MyFleetCount} <= 0
				{
				    echo "- CONFIG:  Sorry, you cannot clear a field 'at' someone who is not in your fleet."
				    echo "- CONFIG:  Aborting script"
				    return
				}
				FoundThem:Set[FALSE]
				do
			    {
			        if (${MyFleet.Get[${FleetIterator}].ToPilot.Name.Find[${Args[${Iterator}]}]} > 0)
			        {
			           FoundThem:Set[TRUE]
			           break
			        }
			    }
			    while ${FleetIterator:Inc} <= ${MyFleetCount}

			    if !${FoundThem}
			    {
			        echo "- CONFIG:  There does not seem to be a fleet member with the name '${Args[${Iterator}]}'..."
			        echo "- CONFIG:  Aborting script"
			        return
			    }

			}
			elseif (${Args[${Iterator}].Equal[-STOP]} || ${Args[${Iterator}].Equal[-stop]})
    			StopAfterSalvaging:Set[TRUE]
			elseif ${EVE.Bookmark[${Args[${Iterator}]}](exists)}
				SalvageLocationLabels:Insert[${Args[${Iterator}]}]
			else
				echo "- CONFIG: '${Args[${Iterator}]}' is not a valid Bookmark label or command line argument:  Ignoring..."
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
  	echo "- CONFIG:  The Salvager will loot cans as it goes."
  	if ${IgnoreContraband}
  		echo "- CONFIG:  When looting, the Salvager will ignore contraband items."
	  if ${IgnoreRightsOnCans}
	  	echo "- CONFIG:  The Salvager will loot (or attempt to loot) all cans regardless of whether you have 'loot rights' or not."	
  }
  else
  	echo "- CONFIG:  The Salvager will *NOT* loot cans as it goes."
  if ${SalvageHereOnly}
  	echo "- CONFIG:  The Salvager will only salvage at this location."
  if ${StopAfterSalvaging}
    echo "- CONFIG:  This script will immediately end after salvaging has finished."
  if ${IgnoreRightsOnWrecks}
  	echo "- CONFIG:  The Salvager will take the time to salvage wrecks for which you do not have loot rights (NOTE: These wrecks are processed after all other wrecks have been handled.)"
  if ${CycleBelts}
	  echo "- CONFIG:  Once all other given commands have been processed (if applicable) the script will cycle through all asteroid belts ${CycleBeltsCount} times."

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Salvage just this particular area, and then go home (or not)   [ '-here' flag used]
	if (${SalvageHereOnly})
	{
		call DoSalvage ${DoLoot}
		call CloseShipCargo
		if (!${StopAfterSalvaging})
			call ReturnToSalvagerHomeBase
		return
	}
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; if the '-at' flag is used
  if ${UsingAt}
  {
		call LeaveStation

		echo "- Warping to '${MyFleet.Get[${FleetIterator}].ToPilot.Name}' for salvage operation..."
		MyFleet.Get[${FleetIterator}]:WarpTo
		do
		{
			wait 20
		}
		while (${Me.ToEntity.Mode} == 3)
	
	  wait 10
		call DoSalvage ${DoLoot}
		call CloseShipCargo
	
		; Remove bookmark now that we're done
		wait 2
		echo "- Salvage operation at '${MyFleet.Get[${FleetIterator}].ToPilot.Name}' complete..."
  }
  ;; END '-at'
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Handle any BOOKMARKS provided as arguments
  if (!${SalvageHereOnly} && ${SalvageLocationLabels.Used} > 0)
  {
      echo "- ${SalvageLocationLabels.Used} salvage locations identified"
      do
      {
				if (${EVE.Bookmark[${SalvageLocationLabels[${i}]}](exists)})
    		{
    	      echo "- Salvage location found in bookmarks: (${SalvageLocationLabels[${i}]}) (${i})..."

						call LeaveStation

		    		;;; Set destination and then activate autopilot (if we're not in that system to begin with)
		    		if (!${EVE.Bookmark[${SalvageLocationLabels[${i}]}].SolarSystemID.Equal[${Me.SolarSystemID}]})
		    		{
		    		  echo "- Setting Destination and activating auto pilot for salvage operation ${i} (${EVE.Bookmark[${SalvageLocationLabels[${i}]}].Label})."
		    		  wait 5
		    			EVE.Bookmark[${SalvageLocationLabels[${i}]}]:SetDestination
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
		    		
						if (${EVE.Bookmark[${SalvageLocationLabels[${i}]}].Distance} > ${EVE.MinWarpDistance})
						{
			    		;;; Warp to location
			    		echo "- Warping to salvage location..."
			    		EVE.Bookmark[${SalvageLocationLabels[${i}]}]:WarpTo
			    		wait 120
			    		do
			    		{
			    			wait 20
			    		}
			    		while (${Me.ToEntity.Mode} == 3)
			    	}

          	wait 10
  					call DoSalvage ${DoLoot}

		    		; Remove bookmark now that we're done
		    		wait 2
		    		echo "- Salvage operation at '${SalvageLocationLabels[${i}]}' complete ... removing bookmark."
		    		EVE.Bookmark[${SalvageLocationLabels[${i}]}]:Remove
		    		call CloseShipCargo
		    		wait 10
		    }
      }
      while ${i:Inc} <= ${SalvageLocationLabels.Used}
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
			echo "- Beginning trip #${i} through asteroid belts in this system."
			call CycleBeltsAndSalvage
			echo "- Finished trip #${i} through the asteroid belts in this system."
		}
		while ${i:Inc} < ${CycleBeltsCount}
		
		call CloseShipCargo
	}
	;; END '-cyclebelts #'
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Return to "Salvager Home Base" [if that bookmark exists]
  if (!${StopAfterSalvaging})
		call ReturnToSalvagerHomeBase
	else
		call CloseShipCargo
	;; END [return to "Salvager Home Base"]
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  return
}
