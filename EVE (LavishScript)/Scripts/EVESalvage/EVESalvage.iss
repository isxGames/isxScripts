;; Declare all script or global variables here
variable(script) int NumSalvageLocations
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

  echo " \n \n \n** EVE Salvager Script 4.1 by Amadeus ** \n \n"

  ; 'Args' is an array ... arrays are static.  Copying to an index just in case we have a desire at some point to add/remove elements.
	if ${Args.Size} > 0
	{
		do
		{
			if (${Args[${Iterator}].Equal[-LOOT]} || ${Args[${Iterator}].Equal[-loot]})
				DoLoot:Set[TRUE]
			elseif (${Args[${Iterator}].Equal[-HERE]} || ${Args[${Iterator}].Equal[-here]})
				SalvageHereOnly:Set[TRUE]				
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
				    echo "- CONFIG:  Sorry -- you cannot clear a field 'at' someone that is not in your fleet."
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
  	echo "* Flags:    '-loot'  					[the script will loot all cans that are found in space]"
  	echo "*           '-stop'  					[the script will stop after the last wreck is handled and will not return to the base/location from which you started]"
  	echo "*           '-here'  					[the script will only work at your current location (it will return to your 'home station' unless the -stop flag is used)]"
  	echo "*           '-maxtargets #'  	[indicates maximum number of targets you wish to use (otherwise, default to the maximum you or your ship can handle)]"
  	echo "*"
  	echo "* Examples: 'run EVESalvage -loot -here -stop'"
  	echo "*           'run EVESalvage -loot -MaxTargets 6 Salvage1 Salvage2 Salvage3'"
  	echo "*"
  	echo "* NOTES:"
  	echo "*           1.  EVESalvage will unload to a station with a bookmark labeled 'Salvager Home Base'.  If this bookmark does not exist, it will be created"
  	echo "*               if you start the script while in a station.   This bookmark is NOT deleted after the script ends.  So, if you want to set a new station"
  	echo "*               for unloading, you will need to delete the old bookmark."
  	return
  }


  if ${DoLoot}
  	echo "- CONFIG:  The Salvager will loot cans as it goes."
  else
  	echo "- CONFIG:  The Salvager will *NOT* loot cans as it goes."
  if ${SalvageHereOnly}
  	echo "- CONFIG:  The Salvager will only salvage at this location."
  if ${StopAfterSalvaging}
    echo "- CONFIG:  This script will immediately end after salvaging has finished."
  	

  ;;; For use with the -at flag
  if ${UsingAt}
  {
		if !${LeftStation}
		{
			if ${Me.InStation}
			{
				   ;; First, make sure we have a bookmark labeled "Salvager Home Base" -- otherwise, create it ;;;;;;;;;;;;;

				   if !${EVE.Bookmark["Salvager Home Base"](exists)}
				   {
				   		echo "- Creating 'Salvager Home Base' bookmark..."
				  		EVE:CreateBookmark["Salvager Home Base"]
				  		wait 10
				 	 }
	
			   echo "- Undocking from station..."
			   EVE:Execute[CmdExitStation]
			   wait 150
			   Counter:Set[0]
			   if (${Me.InStation})
			   {
			   		do
			   		{
			   			wait 20
			   			Counter:Inc[20]
				   			if (${Counter} > 300)
				   			{
				   			  echo "- Undocking attempt failed ... trying again."
				   				EVE:Execute[CmdExitStation]
				   				Counter:Set[0]
				   			}
			   		}
			   		while (${Me.InStation} || !${EVEWindow[Local](exists)} || !${Me.InStation(exists)})
			   }
			   wait 5
			   LeftStation:Set[TRUE]
			}
			else
			{
 				 if (!${StopAfterSalvaging} && !${EVE.Bookmark["Salvager Home Base"](exists)})
 				 {
 			   		echo "- WARNING: EVESalvage has detected that you are not in a station and that you do not have a bookmark labeled 'Salvager Home Base'.   This means that the"
 			   		echo "-          script will end without returning to a station to unload.  You can change this by starting in a station (the script will create the bookmark for you"
 			   		echo "-          or create the bookmark manually while in the station you want to use as your 'home base'"
 			   		StopAfterSalvaging:Set[TRUE]
 			   		echo "- CONFIG:  This script will immediately end after salvaging has finished."
 			   }				
			}
			wait 1
		}

		echo "- Warping to '${MyFleet.Get[${FleetIterator}].ToPilot.Name}' for salvage operation..."
		MyFleet.Get[${FleetIterator}]:WarpTo
		do
		{
			wait 20
		}
		while (${Me.ToEntity.Mode} == 3)
	
	  wait 10
		call DoSalvage ${DoLoot}
		call CloseCargo
	
		; Remove bookmark now that we're done
		wait 2
		echo "- Salvage operation at '${MyFleet.Get[${FleetIterator}].ToPilot.Name}' complete..."
  }

  ; Checks required for using bookmarks...
  if (!${UsingAt} && !${SalvageHereOnly})
  {
      if (${SalvageLocationLabels.Used} < 1)
      {
        echo "- Sorry, you did not specify any valid bookmarks"
        return
      }
  }

  ;;; Loop for use with bookmarks...we skip this if using -at or -here ;;;;;;;
  if (!${UsingAt} && !${SalvageHereOnly})
  {
      NumSalvageLocations:Set[${SalvageLocationLabels.Used}]
      echo "- ${NumSalvageLocations} salvage locations identified"
      do
      {
				if (${EVE.Bookmark[${SalvageLocationLabels[${i}]}](exists)})
    		{
    	      echo "- Salvage location found in bookmarks: (${SalvageLocationLabels[${i}]}) (${i})..."

		    		;;; Leave station
		    		if !${LeftStation}
		    		{
		       			if ${Me.InStation}
		       			{
		    				   ;; First, make sure we have a bookmark labeled "Salvager Home Base" -- otherwise, create it ;;;;;;;;;;;;;
		
		    				   if !${EVE.Bookmark["Salvager Home Base"](exists)}
		    				   {
		    				   		echo "- Creating 'Salvager Home Base' bookmark..."
		    				  		EVE:CreateBookmark["Salvager Home Base"]
		    				  		wait 10
		    				   }
		
		       			   echo "- Undocking from station..."
		       			   EVE:Execute[CmdExitStation]
		       			   wait 150
		       			   Counter:Set[0]
		       			   if (${Me.InStation})
		       			   {
		       			   		do
		       			   		{
		       			   			wait 20
		       			   			Counter:Inc[20]
		    				   			if (${Counter} > 300)
		    				   			{
		    				   			  echo "- Undocking atttempt failed ... trying again."
		    				   				EVE:Execute[CmdExitStation]
		    				   				Counter:Set[0]
		    				   			}
		       			   		}
		       			   		while (${Me.InStation} || !${EVEWindow[Local](exists)} || !${Me.InStation(exists)})
		       			   }
		       			   wait 5
		       			   LeftStation:Set[TRUE]
		       			}
		       			else
		       			{
					 				 if (!${StopAfterSalvaging} && !${EVE.Bookmark["Salvager Home Base"](exists)})
					 				 {
					 			   		echo "- WARNING: EVESalvage has detected that you are not in a station and that you do not have a bookmark labeled 'Salvager Home Base'.   This means that the"
					 			   		echo "-          script will end without returning to a station to unload.  You can change this by starting in a station (the script will create the bookmark for you"
					 			   		echo "-          or create the bookmark manually while in the station you want to use as your 'home base'"
					 			   		StopAfterSalvaging:Set[TRUE]
					 			   		echo "- CONFIG:  This script will immediately end after salvaging has finished."
					 			   }	
		       			}
		       			wait 1
		    		}

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
						elseif (${EVE.Bookmark[${SalvageLocationLabels[${i}]}].Distance} > ${EVE.MinWarpDistance})
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
		    		call CloseCargo
		    		wait 10
		    }
      }
      while ${i:Inc} <= ${NumSalvageLocations}
  }
  ; Loop for use with bookmarks ENDS ;;;;;;;;;;;;;;;;;;;

	;; Salvage just this particular area, and then go home (or not)
	if (${SalvageHereOnly})
	{
		call DoSalvage ${DoLoot}
		call CloseCargo
	}

  if (${StopAfterSalvaging})
  {
  	call CloseCargo
    return
  }

  ;;; Finished...returning home ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  echo "- Salvage operations completed .. returning to home base"
  if (${EVEWindow[MyShipCargo](exists)})
  	EVEWindow[MyShipCargo]:Close
  	
  if (${EVE.Bookmark["Salvager Home Base"](exists)})
	{
		if (!${EVE.Bookmark["Salvager Home Base"].SolarSystemID.Equal[${Me.SolarSystemID}]})
		{
			echo "- Setting destination and activating auto pilot for return to home base"
			EVE.Bookmark["Salvager Home Base"]:SetDestination
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
		}

		if (!${Me.InStation})
		{
			;;; Warp to location
			echo "- Warping to home base location"
			EVE.Bookmark["Salvager Home Base"]:WarpTo
			wait 120
			do
			{
				wait 20
			}
			while (${Me.ToEntity.Mode} == 3)
			wait 20
	
			;;; Dock, if applicable
			if ${EVE.Bookmark["Salvager Home Base"].ToEntity(exists)}
			{
				if (${EVE.Bookmark["Salvager Home Base"].ToEntity.CategoryID.Equal[3]})
				{
					EVE.Bookmark["Salvager Home Base"].ToEntity:Approach
					do
					{
						wait 20
					}
					while (${EVE.Bookmark["Salvager Home Base"].ToEntity.Distance} > 50)
	
					EVE.Bookmark["Salvager Home Base"].ToEntity:Dock
					Counter:Set[0]
					do
					{
					   wait 20
					   Counter:Inc[20]
					   if (${Counter} > 200)
					   {
					      echo " - Docking atttempt failed ... trying again."
					      ;EVE.Bookmark[${Destination}].ToEntity:Dock
					      Entity[CategoryID = 3]:Dock
					      Counter:Set[0]
					   }
					}
					while (!${Me.InStation})
				}
			}
		}
		
		if (${Me.InStation})		
		{
			;;; unload all "salvaged" items to hangar ;;;;;;;;;;;;;;
		  wait 10
		  echo "- Unloading Salvaged Items..."
		 	call TransferSalvagedItemsToHangar
		 	wait 2
		 	if (${DoLoot})
		 	{
		 		echo "- Unloading Looted Items..."
		 		call TransferLootToHangar
		 	}
		}
	}
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  return
}
