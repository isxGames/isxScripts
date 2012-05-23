;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; IMPORTANT NOTE:  This file is not a standalone script.  It simply includes 
;;                  functions that can be used with multiple (salvage related)
;;                  scripts.   See EVESalvage.iss for an example of how this
;;                  file is (and its contents are) included and used.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Definitions
#define CATEGORYID_STATION 								3
#define GROUPID_CORPORATE_HANGAR_ARRAY 		471
#define GROUPID_CARGO_CONTAINER 					12
#define GROUPID_WRECK 										186
#define GROUPID_SECURE_CARGO_CONTAINER		340
#define GROUPID_TRACTOR_BEAM 							650
#define GROUPID_SALVAGER 									112
#define GROUPID_SALVAGEDITEM							754
#define GROUPID_INDUSTRIALCOMMANDSHIP			941
#define GROUPID_SENSORBOOSTER 						212
#define DOCKING_RANGE 										200
#define LOOT_RANGE 												2490
#define CORP_HANGAR_LOOT_RANGE 						3000
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declare all script or global variables here
variable(script) index:module AllModules
variable(script) index:module TractorBeams
variable(script) index:module Salvagers
variable(script) index:module Afterburners
variable(script) index:module SensorBoosters
variable(script) index:item MyCargo
variable(script) index:int64 CargoToTransfer
variable(script) int MaxSalvageRange
variable(script) int MaxTractorRange
variable(script) int MoveWithinDistance
variable(script) int WaitCounter
variable(script) index:entity Wrecks
variable(script) int MaxTargets
variable(script) int MaxTargetRange
variable(script) index:entity Targets
variable(script) bool ContinueOn
variable(script) bool alreadyTractoring
variable(script) bool alreadySalvaging
variable(script) bool allCansProcessed
variable(script) index:entity Cans
variable(script) index:entity NearbyCans
variable(script) index:item EntityCargo
variable(script) collection:int64 ProcessedEntities
variable(script) collection:int64 CargoholdLoot
variable(script) bool LibraryInitialized
variable(script) bool ModuleInformationAcquired
variable(script) index:entity Belts

variable(script) string EVELootingFileName
variable(script) bool CheckLootItemDB
variable(script) settingsetref LootItemsDB
variable(script) filepath EVELootingFilePath
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This function initializes various things that are used
;; in the rest of this library.  You can call it manually
;; at the beginning of your script, or allow it to be called
;; by the SalvageArea() function
function InitializeLibrary(bool LootCans)
{
	if (${LootCans})
	{
		EVELootingFilePath:Set["${LavishScript.HomeDirectory}/Scripts/"]
		EVELootingFileName:Set[${EVELootingFilePath}EVEIgnoreLootingItems.xml]
	 
		LavishSettings:AddSet[Loot Items Database]
		LavishSettings[Loot Items Database]:Clear
		LavishSettings[Loot Items Database]:AddComment["This is your 'ignore' list while looting.  Items set to TRUE will be ignored and therefore NOT looted."]
		LavishSettings[Loot Items Database]:AddSet[${Me.Name}]
		LavishSettings[Loot Items Database]:Import[${EVELootingFileName}]
		
		LootItemsDB:Set[${LavishSettings[Loot Items Database].FindSet[${Me.Name}]}]		
	}
	
	LibraryInitialized:Set[TRUE]
	return
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This function gets informations about your modules for use
;; in other routines in this library.  You will see it used
;; in the function SalvageArea() below.
function GetModulesInformation(bool LootCans)
{
	variable iterator iModule
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; We already have the information we need.
	if ${ModuleInformationAcquired}
		return
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	TractorBeams:Clear
	Salvagers:Clear
	Afterburners:Clear

	;; This function is always called when using the EVESalvageLibrary, so initialize it the first time it's called
	if !${LibraryInitialized}
		call InitializeLibrary ${LootCans}

	;; Determine the modules at our disposal
	echo "EVESalvage->GetModulesInformation::  Acquiring Information about your ship's modules..."
	MyShip:GetModules[AllModules]
	if (${AllModules.Used} <= 0)
	{
		echo "EVESalvage->GetModulesInformation::  ERROR -- Your ship does not appear to have any modules"
		return
	}
	AllModules:GetIterator[iModule]
	if (${iModule:First(exists)})
	{
		do
		{
	   	if (${iModule.Value.MaxTractorVelocity} > 0)
	   	{
	   	  ;echo "EVESalvage->GetModulesInformation::  Adding ${iModule.Value.ToItem.Name} to 'TractorBeams'"
				TractorBeams:Insert[${iModule.Value.ID}]
				if ${MaxTractorRange} <= 0
				{
					MaxTractorRange:Set[${iModule.Value.OptimalRange}]
					;echo "EVESalvage->GetModulesInformation::  MaxTractorRange set to: ${MaxTractorRange}"
				}
	   	}
	   	elseif (${iModule.Value.AccessDifficultyBonus} > 0)
	   	{
	   	  ;echo "EVESalvage->GetModulesInformation::  Adding ${iModule.Value.ToItem.Name} to 'Salvagers'"
	   	  Salvagers:Insert[${iModule.Value.ID}]
				if ${MaxSalvageRange} <= 0
				{
					MaxSalvageRange:Set[${iModule.Value.OptimalRange}]
				}   	  
	   	}
	   	elseif (${iModule.Value.MaxVelocityBonus} > 0)
	   	{
	   	  ;echo "EVESalvage->GetModulesInformation::  Adding ${iModule.Value.ToItem.Name} to 'Afterburners'"
	   	  Afterburners:Insert[${iModule.Value.ID}] 	  
	   	}  
	   	elseif (${iModule.Value.ToItem.GroupID} == GROUPID_SENSORBOOSTER)
	   	{
	   		;echo "EVESalvage->GetModulesInformation::  Adding ${iModule.Value.ToItem.Name} to 'SensorBoosters'"
	   		SensorBoosters:Insert[${iModule.Value.ID}]
	   	} 	
		}
		while (${iModule:Next(exists)})
	}
	
  echo "EVESalvage->GetModulesInformation::  Your ship has ${TractorBeams.Used} Tractor Beam(s), ${Salvagers.Used} Salvage Module(s), ${SensorBoosters.Used} Sensor Booster(s), and ${Afterburners.Used} Afterburner/MWD."
  ModuleInformationAcquired:Set[TRUE]
	return
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Opens the player's ship cargo hold
function OpenShipCargo()
{
	if !${EVEWindow[ByName,"active ship"](exists)}
	{
		echo "EVESalvage->OpenShipCargo::  Opening Ship Cargohold"
		MyShip:OpenCargo
		wait 15
		while !${EVEWindow[ByName,"active ship"](exists)}
		{
			wait 0.5
		}
		wait 10
	}
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Closes the player's ship cargo hold
function CloseShipCargo()
{
	if ${EVEWindow[ByName,"active ship"](exists)}
	{
		echo "EVESalvage->CloseShipCargo::  Stacking cargo..."
		EVEWindow[ByName,"active ship"]:StackAll
		wait 10					
		
		echo "EVESalvage->CloseShipCargo::  Closing Ship Cargohold"
		EVEWindow[byName, "Inventory"]:Close
		wait 15
		while ${EVEWindow[byName, "Inventory"](exists)}
		{
			wait 0.5
		}
		wait 5
	}
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Check for cargo containers in the area to loot
function CheckForLoot(int WithinDistance)
{
	variable int i = 1
	variable int k
	variable int j
	variable bool alreadyTargeted
	variable int TargetLoopCounter = 0
	
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Loot nearby cans before thinking about those that are out of "looting range"
	i:Set[1]
	if (${IgnoreRightsOnCans})
		EVE:QueryEntities[NearbyCans, Name =- "Cargo Container" && Distance <= LOOT_RANGE]
	else
		EVE:QueryEntities[NearbyCans, Name =- "Cargo Container" && Distance <= LOOT_RANGE && (HaveLootRights = 1 || IsOwnedByCorpMember = 1)]
	if ${NearbyCans.Used} > 0
	{
		echo "EVESalvage->CheckForLoot::  ${NearbyCans.Used} cargo containers found, processing..."
		do
		{
			if (!${NearbyCans[${i}](exists)} || !${NearbyCans[${i}].Name(exists)})
			{
				i:Inc
				continue
			}
			
			echo "EVESalvage->CheckForLoot::  Processing: ${NearbyCans[${i}].Name}"
			;; If we've already processed this can, then we want to ignore it.
			if (${ProcessedEntities.Element[${NearbyCans[${i}].ID}](exists)})
			{
				i:Inc
				continue
			}
		
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;; Loot
			ProcessedEntities:Set[${NearbyCans[${i}].ID},1]
			if (${NearbyCans[${i}](exists)})
				call LootCargoContainer ${NearbyCans[${i}]}
			else
				echo "EVESalvage->CheckForLoot::  **ERROR ENCOUNTERED {NearbyCans[${i}]} is NULL** [_FILE_: _LINE_)"
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
			i:Inc
		}
		while ${i} <= ${NearbyCans.Used}
	} 	
	;; END LOOP (handling nearby cans)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Handle ALL remaining cans that are within ${Distance}.  If ${Distance} is <=LOOT_RANGE, then we have already handled them.
	if (${WithinDistance} > LOOT_RANGE)
	{
		if (${IgnoreRightsOnCans})
			EVE:QueryEntities[Cans, Name =- "Cargo Container" && Distance <= ${WithinDistance}]
		else
			EVE:QueryEntities[Cans, Name =- "Cargo Container" && Distance <= ${WithinDistance} && (HaveLootRights = 1 || IsOwnedByCorpMember = 1)]
			
		if (${Cans.Used} == 0)
		{
			echo "EVESalvage->CheckForLoot::  No cargo containers found in this area."
			return
		}
		else
			echo "EVESalvage->CheckForLoot::  ${Cans.Used} cargo containers found, processing..."	
		;;;run until break
		while 1 == 1
		{
			echo "EVESalvage->CheckForLoot::  Checking..."
			
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;; Check to see if all of the cargo containers have been processed.  If so, then break
			i:Set[1]
			allCansProcessed:Set[TRUE]
			do
			{
				if (${ProcessedEntities.Element[${Cans[${i}].ID}](exists)})
				{
					i:Inc
					continue
				}
				else
				{
					allCansProcessed:Set[FALSE]
					;;;found one, no need to look for more, start processing!
					break
				}	
			}
			while ${i} <= ${Cans.Used}

			if ${allCansProcessed}
			{
				echo "EVESalvage->CheckForLoot::  - All cargo containers (loot) in this area have been processed."
				return
			}		
			;;
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
			
			
			i:Set[1]
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;; Targeting Routine (lock targets until ${MaxTargets} is reached)
			TargetLoopCounter:Set[0]
			while (${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}]} < ${MaxTargets})
			{
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				;; Avoid endless loops in situations where Wrecks disappear midstream
				TargetLoopCounter:Inc
				if (${TargetLoopCounter} > ${Math.Calc[${MaxTargets}+3]})
					break
				;;
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				echo "EVESalvage->CheckForLoot::  - ${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}].Precision[0]} of ${MaxTargets} targets acquired (${Cans.Used} available)"

				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				;; In case there are fewer cargo containers than our max targets  (otherwise this makes for a neverending loop)
				if (${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}]} >= ${Cans.Used})
				{
					echo "EVESalvage->CheckForLoot::  - All remaining cargo containers have been targeted.  Processing..."
					break
				}

				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				;; Make sure we're not already targetting this cargo container...
				Me:GetTargets[Targets]
				k:Set[1]
				alreadyTargeted:Set[FALSE]
				if (${Targets.Used} > 0)
				{
					do
					{
						if ${Targets[${k}].ID.Equal[${Cans[${i}].ID}]} 
						{
						   alreadyTargeted:Set[TRUE]
						   break
						}		
					}
					while ${k:Inc} <= ${Targets.Used}
				}
				
				if ${alreadyTargeted}
				{
					i:Inc
					continue
				}
				;;
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				;; cargo container is out of 'targeting range'
				if (${Cans[${i}].Distance} > ${MaxTargetRange})
				{
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;; Before moving, make sure we finish targeting
				    while (${Me.TargetingCount} > 0 && ${Me.TargetCount} < 1)
				    {
				    	echo "EVESalvage->CheckForLoot::  -- Waiting for a target lock..."
							wait 2
				    }
	
						;;;;;;;;;;;;;;;;;;;;;;;;
						;; Approach
				    if (${Me.TargetCount} == 0)
				    {
				    	if (${Cans[${i}](exists)})
				    	{			    	
					    	echo "EVESalvage->CheckForLoot::  -- ${Cans[${i}].Name} too far away to target :: Approaching..."
					    	call ApproachEntity ${Cans[${i}]} ${MaxTargetRange}
				    	}
				    	else
				    		echo "EVESalvage->CheckForLoot::  **ERROR ENCOUNTERED {Cans[${i}]} is NULL** [_FILE_: _LINE_)"
				    }
				    else
				    {
							echo "EVESalvage->CheckForLoot::  --- ${Cans[${i}].Name} too far away to target :: Handling current targets before moving..."
							i:Inc
							continue
				    }
				}
				;; END->cargo container out of 'targeting range'
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

				if (!${Cans[${i}](exists)} || !${Cans[${i}].Name(exists)})
				{
					i:Inc
					ProcessedEntities:Set[${Cans[${i}].ID},1]
					continue
				}
				
				;;; Don't lock any targets for cargo containers we have already processed
				if (${ProcessedEntities.Element[${Cans[${i}].ID}](exists)})
				{
					i:Inc
					continue
				}		
				;;
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
			
				;; Otherwise, lock the target and go on to the next 'can' in the array!
				echo "EVESalvage->CheckForLoot::  --- LockTarget :: ${Cans[${i}].Name}"
				Cans[${i}]:LockTarget
				wait 6
				i:Inc
			}   
			;; Finished Targetting Routine  
			;; This closing bracket is the end of the loop: "while (${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}]} < ${MaxTargets})"
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			;; Wait until all targets are fully locked
			if (${Me.TargetingCount} > 0)
			{
				echo "EVESalvage->CheckForLoot::  -- Waiting for a target lock..."
				while (${Me.TargetingCount} > 0 && ${Me.TargetCount} < 1)
				{
					wait 2
				}
			}
			echo "EVESalvage->CheckForLoot::  -- ${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}].Precision[0]} Target(s) Acquired"
			
			;;;;;;;;;;;;;;
			;##################################################
			;;; TARGETS ALL LOCKED UP!
			;##################################################
			;;;;;;;;;;;;;;
			;; Process all locked targets using the following logic:
			;; 1. Disengage Tractors on cargo containers that are close enough to loot
			;; 2. Engage Tractors on far cargo containers
			;; 3. If cargo container is outside tractor range then move into range.
			
			Me:GetTargets[Targets]
			k:Set[1]
			alreadyTractoring:Set[FALSE]
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;; Loop through all targets currently locked
			;; NOTE: At this point, all targets should be "cargo containers"
			;;
			;; Disengage Tractors for cargo containers that are close enough and then loot
			while ${k} <= ${Targets.Used} 
			{
				;;;;;;;;;;;;;;;;;;;;;;;
				;; Make sure the target (as an entity) still exists
				if (!${Targets[${k}](exists)} || !${Targets[${k}].Name(exists)})
				{
					k:Inc
					continue
				}		
				;;
				;;;;;;;;;;;;;;;;;;;;;;;
				
				;;;;;;;;;;;;;;;;;;;;;;;
				;; Ensure that only 'wrecks' are targeted
				if (${Targets[${k}].GroupID} != GROUPID_CARGO_CONTAINER)
				{
					echo "EVESalvage->CheckForLoot::  --- ${Targets[${k}].Name} is not a cargo container.   Unlocking as target. (TURN OFF 'target back' OPTION IN EVE SETTINGS.)"
					Targets[${k}]:UnlockTarget
					k:Inc
					continue
				}
				;;
				;;;;;;;;;;;;;;;;;;;;;;;

				if (${Targets[${k}].Distance} <= LOOT_RANGE)
				{
					Targets[${k}]:MakeActiveTarget
					WaitCounter:Set[0]
					do
					{
						wait ${WaitTimeVariable}
						if ${WaitCounter} > 20
							break
						WaitCounter:Inc[${WaitTimeVariable}]
					}
					while (!${Targets[${k}].ID.Equal[${Me.ActiveTarget.ID}]})
					echo "EVESalvage->CheckForLoot::  --- ${Targets[${k}].Name} is close enough now.  Disengaging tractor beams..."

					;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					;; Go through tractor beams and turn off any tractors on this cargo container
					j:Set[1]
					do
					{
						if (${TractorBeams[${j}].IsActive} && !${TractorBeams[${j}].IsDeactivating})
						{
							if (${TractorBeams[${j}].TargetID.Equal[${Targets[${k}].ID}]})
							{
								alreadyTractoring:Set[TRUE]
								TractorBeams[${j}]:Deactivate
								WaitCounter:Set[0]
								do
								{
									wait ${WaitTimeVariable}
									if (${WaitCounter} > 20)
										break
									WaitCounter:Inc[${WaitTimeVariable}]
								}
								while !${TractorBeams[${j}].IsDeactivating}
							}
						}	
					}
					while (${j:Inc} <= ${TractorBeams.Used})
					;; END LOOP [Disengaging tractor beams on this wreck]
					;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					
					;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					;; Loot!!
					echo "EVESalvage->CheckForLoot::  ---- ${Targets[${k}].Name} in range.  Looting..."
					ProcessedEntities:Set[${Targets[${k}].ID},1]
					if (${Targets[${k}](exists)})
						call LootCargoContainer ${Targets[${k}]}				
					else
						echo "EVESalvage->CheckForLoot::  **ERROR ENCOUNTERED {Targets[${k}]} is NULL** [_FILE_: _LINE_)"

					;; End Looting
					;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				}
				k:Inc 
			}	
			;; END LOOP (current locked targets)
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			

			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;; Loop through all targets currently locked
			;; NOTE: At this point, all targets should be "cargo containers"
			;;
			;; cargo containers that are within LOOT_RANGE should already have been looted
			;; Engage Tractors on cargo containers that are far away
			k:Set[1]
			while ${k} <= ${Targets.Used} 
			{
				if (!${Targets[${k}](exists)} || !${Targets[${k}].Name(exists)})
				{
					k:Inc
					continue
				}
				echo "EVESalvage->CheckForLoot::  --- Checking target: ${Targets[${k}].Name} (ID: ${Targets[${k}].ID})"

				;;;;;;;;;;;;;;;;;;;;;;;
				;; (Note:  Cargo containers that are within LOOT_RANGE were already handled)
				if (${Targets[${k}].Distance} <= LOOT_RANGE)
				{
					echo "EVESalvage->CheckForLoot::  Cargo container already within loot range.  Looting should take place soon."
					k:Inc
					continue
				}
				;;;;;;;;;;;;;;;;;;;;;;;
				;; Tractor wreck if it's close enough to be tractored
				if (${Targets[${k}].Distance} <= ${MaxTractorRange})
				{
					Targets[${k}]:MakeActiveTarget
					WaitCounter:Set[0]
					do
					{
						wait ${WaitTimeVariable}
						if (${WaitCounter} > 20)
							break
						WaitCounter:Inc[${WaitTimeVariable}]
					}
					while (!${Targets[${k}].ID.Equal[${Me.ActiveTarget.ID}]})
					echo "EVESalvage->CheckForLoot::  --- Cargo container in tractor range..."

					;;;;;;;;;;;;;;;;;;;;;;;
					;; Before engaging tractor beam on this target, make sure that it doesn't already have one active on it.
					j:Set[1]
					alreadyTractoring:Set[FALSE]
					do
					{
						if (${TractorBeams[${j}].IsActive} && !${TractorBeams[${j}].IsDeactivating})
						{
							;echo "EVESalvage->CheckForLoot[DEBUG]::  Tractor Beam [${TractorBeams[${j}].ID}]-${TractorBeams[${j}].ToItem.Name} is active and is not deactivating"
							if (${TractorBeams[${j}].TargetID.Equal[${Targets[${k}].ID}]})
							{
								;echo "EVESalvage->CheckForLoot[DEBUG]::  Tractor Beam [${TractorBeams[${j}].ID}]-${TractorBeams[${j}].ToItem.Name}'s TargetID is ${TractorBeams[${j}].TargetID}"
								;;Already tractoring this...
								alreadyTractoring:Set[TRUE]
								echo "EVESalvage->CheckForLoot::  ---- Already tractoring..."
								if (${Targets[${k}].Distance} <= LOOT_RANGE)
								{
									echo "EVESalvage->CheckForLoot::  ---- Cargo container close enough now... stop Tractoring..."
									TractorBeams[${j}]:Deactivate
									WaitCounter:Set[0]
									do
									{
										wait ${WaitTimeVariable}
										if (${WaitCounter} > 20)
											break
										WaitCounter:Inc[${WaitTimeVariable}]
									}
									while !${TractorBeams[${j}].IsDeactivating}
								}
							}
						}	
					}
					while (${j:Inc} <= ${TractorBeams.Used})
					;; END LOOP (determine if cargo container is already being tractored)
					;;;;;;;;;;;;;;;;;;;;;;;

					;;;;;;;;;;;;;;;;;;;;;;;
					;; if it was NOT already being tractored, then start tractoring
					if (!${alreadyTractoring})
					{
						echo "EVESalvage->CheckForLoot::  ---- Start tractoring..."
									
						;; Activate Tractor Beam...
						j:Set[1]
						do
						{
							if (!${TractorBeams[${j}].IsActive} && !${TractorBeams[${j}].IsDeactivating} )
							{
							  echo "EVESalvage->CheckForLoot::  ----- Activating: ${TractorBeams[${j}].ToItem.Name}"
								TractorBeams[${j}]:Click
								WaitCounter:Set[0]
								do
								{
									wait ${WaitTimeVariable}
									if (${WaitCounter} > 20)
										break
									WaitCounter:Inc[${WaitTimeVariable}]
								}
								while !${TractorBeams[${j}].IsActive}
								break
							}	
						}
						while (${j:Inc} <= ${TractorBeams.Used})				
					}
				}
				elseif (${Targets[${k}].Distance} > ${MaxTractorRange})
				{
					ContinueOn:Set[TRUE]
					echo "EVESalvage->CheckForLoot::  --- Cargo container out of tractor range..."
					
					;;;;;;;;;;;;;;;;;;;;;;;
					;; Ensure that we do not move unless we're positive there are no other cargo containers that are within LOOT_RANGE of our current location
					if (${IgnoreRightsOnCans})
						EVE:QueryEntities[NearbyCans, Name =- "Cargo Container" && Distance <= LOOT_RANGE]
					else
						EVE:QueryEntities[NearbyCans, Name =- "Cargo Container" && Distance <= LOOT_RANGE && (HaveLootRights = 1 || IsOwnedByCorpMember = 1)]
				  if ${NearbyCans.Used} > 0
				  {
						l:Set[1]
						do
						{
							if (!${IgnoreRightsOnCans} && !${NearbyCans[${l}].HaveLootRights})
							{
								l:Inc
								continue
							}	 
							echo "EVESalvage->CheckForLoot::  --- Cannot approach while jet cans near by..."
							ContinueOn:Set[FALSE]	
							break
							l:Inc
						}
						while ${l} <= ${NearbyCans.Used}
				  }
					;;
					;;;;;;;;;;;;;;;;;;;;;;;

					if (${ContinueOn})
					{
						echo "EVESalvage->CheckForLoot::  --- Approaching ..."
						
						if (${Targets[${k}](exists)})
						{
							call ApproachEntity ${Targets[${k}]} ${MaxTractorRange}
							echo "EVESalvage->CheckForLoot::  --- Cargo container is now within tractor range..."
						}
						else
							echo "EVESalvage->CheckForLoot::  **ERROR ENCOUNTERED {Targets[${k}]} is NULL** [_FILE_: _LINE_)"
					}
				}
				else
				{
					;; This should never happen....
					echo "EVESalvage->CheckForLoot::  **WHAT?!?**"
				}

				;; Now we check the next locked target
				k:Inc 
			}
			;; END LOOP (current locked targets)  ["while ${k} <= ${Targets.Used}"]
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
			
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
			;; Repopulate Cans with updated data
			if (${IgnoreRightsOnCans})
				EVE:QueryEntities[Cans, Name =- "Cargo Container" && Distance <= ${WithinDistance}]
			else
				EVE:QueryEntities[Cans, Name =- "Cargo Container" && Distance <= ${WithinDistance} && (HaveLootRights = 1 || IsOwnedByCorpMember = 1)]
			if (${Cans.Used} == 0)
			{
				echo "EVESalvage->CheckForLoot::  - All cargo containers have been processed."
				return
			}	
			;;
			;; This is the end of the Main Looting Loop.  This will repeat over and over until there
			;; are no more jet cans (cargo containers) in the area.  (which will cause the routine directly 
			;; above to 'return', thereby ending the loop.)   
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
		}
		;; END LOOP (Main Looting Pulse routine) ["while 1 == 1"]
	}
	;; END LOOP (handle all remaining cans that are "out of reach")
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	return
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Salvage wrecks in the current area
function SalvageArea(bool LootCans)
{
  variable int i = 1
  variable int j
  variable int k
  variable int l
  variable bool alreadyTargeted
  variable bool FirstTime = TRUE
  variable bool SalvagingYellowWrecks = FALSE
  variable int TargetLoopCounter = 0
  variable iterator Salvager

	call GetModulesInformation ${LootCans}
	if (${MaxTargets} < 1)
	{
		if (${Me.MaxLockedTargets} <= ${MyShip.MaxLockedTargets})
			MaxTargets:Set[${Me.MaxLockedTargets}]
		else
			MaxTargets:Set[${MyShip.MaxLockedTargets}]
	}
	MaxTargetRange:Set[${MyShip.MaxTargetRange}]
	
	echo "EVESalvage->SalvageArea::  Salvager initialized ... "
	EVE:QueryEntities[Wrecks,Name =- "wreck" && GroupID == GROUPID_WRECK && (HaveLootRights = 1 || IsOwnedByCorpMember = 1)]
	if (${Wrecks.Used} == 0)
	{
		if ${IgnoreRightsOnWrecks}
		{
			SalvagingYellowWrecks:Set[TRUE]
			EVE:QueryEntities[Wrecks,Name =- "wreck" && GroupID == GROUPID_WRECK]
			if (${Wrecks.Used} == 0)
			{
				echo "EVESalvage->SalvageArea::  No wrecks found in this area, looking for loot..."
				if (${LootCans})
					call CheckForLoot ${EVE.MinWarpDistance}		
				return
			}
			else
				echo "EVESalvage->SalvageArea::  ${Wrecks.Used} wrecks remain in this area."
		}
		else
		{
			echo "EVESalvage->SalvageArea::  No wrecks found in this area, looking for loot..."
			if (${LootCans})
				call CheckForLoot ${EVE.MinWarpDistance}		
			return
		}
	}
	else
		echo "EVESalvage->SalvageArea::  ${Wrecks.Used} wrecks remain in this area."
		
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Activate Sensor Booster(s)
	call ManipulateSensorBoosters "On"
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; MAIN LOOP
	while 1 == 1
	{
		echo "EVESalvage->SalvageArea::  Starting salvaging operation"
		i:Set[1]
		;;;;;;;;;;;;;;;
		;; FOR TESTING
		;do
		;{
		;	echo "Wreck ${i}. ${Wrecks[${i}].Name} - Distance: ${Wrecks[${i}].Distance.Precision[2]}"
		;}
		;while ${i:Inc} < ${Wrecks.Used}
		;return
		;;
		;;;;;;;;;;;;;;;

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Targeting Routine (lock targets until ${MaxTargets} is reached)
		TargetLoopCounter:Set[0]
		while (${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}]} < ${MaxTargets})
		{	
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;; Avoid endless loops in situations where Wrecks disappear midstream
			TargetLoopCounter:Inc
			if ${TargetLoopCounter} > ${Math.Calc[${MaxTargets}+3]}
				break
			;;
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
			echo "EVESalvage->SalvageArea::  - ${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}].Precision[0]} of ${MaxTargets} targets acquired (${Wrecks.Used} available)"

			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;; In case there are fewer wrecks than our max targets  (otherwise this makes for a neverending loop)
			if (${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}]} >= ${Wrecks.Used})
			{
				echo "EVESalvage->SalvageArea::  - All remaining wrecks have been targeted.  Processing..."
				break
			}

			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;; Make sure we're not already targetting this wreck...
			Me:GetTargets[Targets]
			alreadyTargeted:Set[FALSE]
			k:Set[1]
			if (${Targets.Used} > 0)
			{
				do
				{
					if ${Targets[${k}].ID.Equal[${Wrecks[${i}].ID}]} 
					{
					   alreadyTargeted:Set[TRUE]
					   break
					}		
				}
				while ${k:Inc} <= ${Targets.Used}
			}
			
			if ${alreadyTargeted}
			{
				i:Inc
				continue
			}
			;;
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
			
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;; Wreck is out of 'targeting range'
			if (${Wrecks[${i}].Distance} > ${MaxTargetRange})
			{
			    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			    ;; Before moving, make sure we handle all wrecks that we are targetting or have targeted
					if (${Me.TargetingCount} > 0)
					{
						echo "EVESalvage->SalvageArea::  -- Waiting for a target lock..."
						while (${Me.TargetingCount} > 0 && ${Me.TargetCount} < 1)
						{
							wait 2
						}
					}
					
					;;;;;;;;;;;;;;;;;;;;;;;;
					;; Approach
			    if (${Me.TargetCount} == 0)
			    {
				    ;;;;;;;;;;;;;;;;
				    ;; Deal with any loot that is within ${MaxTractorRange} before moving
						if (${LootCans})
							call CheckForLoot ${MaxTractorRange}
						;;
						;;;;;;;;;;;;;;;;
			    	
			    	
			    	if (${Wrecks[${i}](exists)})
			    	{
			    		echo "EVESalvage->SalvageArea::  -- ${Wrecks[${i}].Name} too far away to target :: Approaching..."
			    		call ApproachEntity ${Wrecks[${i}]} ${MaxTargetRange}
			    	}
			    	else
			    		echo "EVESalvage->SalvageArea::  **ERROR ENCOUNTERED {Wrecks[${i}]} is NULL** [_FILE_: _LINE_)"
			    }
			    else
			    {
						echo "EVESalvage->SalvageArea::  -- ${Wrecks[${i}].Name} too far away to target :: Handling current targets before moving..."
						i:Inc
						continue
			    }
			}
			;; END->Wreck out of 'targeting range'
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			if (!${Wrecks[${i}].ID(exists)})
			{
				i:Inc
				continue
			}
			
			echo "EVESalvage->SalvageArea::  --- LockTarget :: ${Wrecks[${i}].Name}"
			Wrecks[${i}]:LockTarget
			wait 6
			i:Inc
		}   
		;; Finished Targetting Routine  
		;; This closing bracket is the end of the loop: "while (${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}]} < ${MaxTargets})"
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		;; Wait until all targets are fully locked
		if (${Me.TargetingCount} > 0)
		{
			echo "EVESalvage->SalvageArea::  -- Waiting for a target lock..."
			while (${Me.TargetingCount} > 0 && ${Me.TargetCount} < 1)
			{
				wait 2
			}
		}
		echo "EVESalvage->SalvageArea::  ** ${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}].Precision[0]} Target(s) Acquired"
		
		;;;;;;;;;;;;;;
		;##################################################
		;;; TARGETS ALL LOCKED UP!
		;##################################################
		;;;;;;;;;;;;;;
		;; Process all locked targets using the following logic:
		;; 1. Disengage Tractors on wrecks that are close enough to salvage
		;; 2. Engage Salvagers on close wrecks
		;; 3. Engage Tractors on far wrecks
		;; 4. If wreck is outside tractor range AND no salvagers are active AND no cans present -- then move into range.

		Me:GetTargets[Targets]
		k:Set[1]
		alreadyTractoring:Set[FALSE]
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Loop through all targets currently locked
		;; NOTE: At this point, all targets should be "wrecks"
		;;
		;; Disengage Tractors for wrecks that are close enough and then engage salvager
		while ${k} <= ${Targets.Used} 
		{
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;; Make sure the target (as an entity) still exists
			if (!${Targets[${k}](exists)} || !${Targets[${k}].Name(exists)})
			{
				k:Inc
				continue
			}		
			;;
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;; Ensure that only 'wrecks' are targeted
			if (${Targets[${k}].GroupID} != 186)
			{
				echo "EVESalvage->SalvageArea::  --- ${Targets[${k}].Name} is not a wreck.   Unlocking as target. (TURN OFF 'target back' OPTION IN EVE SETTINGS.)"
				Targets[${k}]:UnlockTarget
				k:Inc
				continue
			}
			;;
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
			if (${Targets[${k}].Distance} <= ${MaxSalvageRange})
			{
				Targets[${k}]:MakeActiveTarget
				WaitCounter:Set[0]
				do
				{
					wait ${WaitTimeVariable}
					if (${WaitCounter} > 20)
						break
					WaitCounter:Inc[${WaitTimeVariable}]
				}
				while (!${Targets[${k}].ID.Equal[${Me.ActiveTarget.ID}]})
				echo "EVESalvage->SalvageArea::  --- ${Targets[${k}].Name} is close enough now.  Disengaging tractor beams..."
				
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				;; Go through tractor beams and turn off any tractors on this wreck
				j:Set[1]
				do
				{
					if (${TractorBeams[${j}].IsActive} && !${TractorBeams[${j}].IsDeactivating})
					{
						if (${TractorBeams[${j}].TargetID.Equal[${Targets[${k}].ID}]})
						{
							alreadyTractoring:Set[TRUE]
							TractorBeams[${j}]:Deactivate
							WaitCounter:Set[0]
							do
							{
								wait ${WaitTimeVariable}
								if (${WaitCounter} > 20)
									break
								WaitCounter:Inc[${WaitTimeVariable}]
							}
							while !${TractorBeams[${j}].IsDeactivating}
						}
						wait 1
					}	
				}
				while (${j:Inc} <= ${TractorBeams.Used})
				;; END LOOP [Disengaging tractor beams on this wreck]
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				;; Engage a Salvager (if one is available)
				;;
				;; First, make sure we don't already a salvager on this wreck
				alreadySalvaging:Set[FALSE]
				Salvagers:GetIterator[Salvager]
				if (${Salvager:First(exists)})
				{
					do
					{
						if (${Salvager.Value.TargetID.Equal[${Me.ActiveTarget.ID}]})
						{
							alreadySalvaging:Set[TRUE]
							break
						}
					}
					while ${Salvager:Next(exists)}
				}
				;;
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

				if (!${alreadySalvaging})
				{
					j:Set[1]
					do
					{
						if (!${Salvagers[${j}].IsActive} && !${Salvagers[${j}].IsDeactivating})
						{
							echo "EVESalvage->SalvageArea::  ---- Wreck in range, Using ${Salvagers[${j}].ToItem.Name} (${Salvagers[${j}].ToItem.ID}) on ${Targets[${k}].Name}..."
							Salvagers[${j}]:Click
							WaitCounter:Set[0]
							do
							{
								wait ${WaitTimeVariable}
								if (${WaitCounter} > 20)
									break
								WaitCounter:Inc[${WaitTimeVariable}]
							}
							while !${Salvagers[${j}].IsActive}
							break
						}
					}
					while ${j:Inc} <= ${Salvagers.Used}
				}
				;; END [Activating a salvager on this wreck]
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			}
			k:Inc 
		}	
		;; END LOOP (current locked targets)
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Loop through all targets currently locked
		;; NOTE: At this point, all targets should be "wrecks"
		;;
		;; Salvagers should be engaged by this point (on items that are close enough to be salvaged)
		;; Engage Tractors on wrecks that are far away
		;; Engage Salvagers on wrecks that are close
		k:Set[1]
		while ${k} <= ${Targets.Used} 
		{
			;;;;;;;;;;;;;;;;;;;;;;;
			;; Make sure the target (as an entity) still exists
			if (!${Targets[${k}](exists)} || !${Targets[${k}].Name(exists)})
			{
				k:Inc
				continue
			}		
			;;
			;;;;;;;;;;;;;;;;;;;;;;;
			
			;;;;;;;;;;;;;;;;;;;;;;;
			;; Ensure that only 'wrecks' are targeted
			if (${Targets[${k}].GroupID} != 186)
			{
				echo "EVESalvage->SalvageArea::  --- ${Targets[${k}].Name} is not a wreck.   Unlocking as target. (TURN OFF 'target back' OPTION IN EVE SETTINGS.)"
				Targets[${k}]:UnlockTarget
				k:Inc
				continue
			}
			;;
			;;;;;;;;;;;;;;;;;;;;;;;
			echo "EVESalvage->SalvageArea::  --- Checking target: ${Targets[${k}].Name} (ID: ${Targets[${k}].ID})"
			
			;;;;;;;;;;;;;;;;;;;;;;;
			;; (Note:  Wrecks that are within Salvage Range were already handled)
			if (${Targets[${k}].Distance} <= ${MaxSalvageRange})
			{
				echo "EVESalvage->SalvageArea::  ---- Wreck already within salvage range.  Salvaging operation should complete soon."
				k:Inc
				continue
			}
			;;
			;;;;;;;;;;;;;;;;;;;;;;;
			;; Tractor wreck if it's close enough to be tractored (and if it's not a yellow wreck)
			elseif (${Targets[${k}].Distance} <= ${MaxTractorRange} && ${Targets[${k}].Distance} > ${MaxSalvageRange} && !${SalvagingYellowWrecks})
			{
				Targets[${k}]:MakeActiveTarget
				WaitCounter:Set[0]
				do
				{
					wait ${WaitTimeVariable}
					if (${WaitCounter} > 20)
						break
					WaitCounter:Inc[${WaitTimeVariable}]
				}
				while (!${Targets[${k}].ID.Equal[${Me.ActiveTarget.ID}]})
				echo "EVESalvage->SalvageArea::  ---- Wreck in tractor range..."
				
				;;;;;;;;;;;;;;;;;;;;;;;
				;; Before engaging tractor beam on this target, make sure that it doesn't already have one active on it.
				j:Set[1]
				alreadyTractoring:Set[FALSE]
				do
				{
					if (${TractorBeams[${j}].IsActive} && !${TractorBeams[${j}].IsDeactivating})
					{
						;echo "EVESalvage->SalvageArea[DEBUG]::  Tractor Beam [${TractorBeams[${j}].ID}]-${TractorBeams[${j}].ToItem.Name} is active and is not deactivating"
						if (${TractorBeams[${j}].TargetID.Equal[${Targets[${k}].ID}]})
						{
							;echo "EVESalvage->SalvageArea[DEBUG]::  Tractor Beam [${TractorBeams[${j}].ID}]-${TractorBeams[${j}].ToItem.Name}'s TargetID is ${TractorBeams[${j}].TargetID}"
							;;Already tractoring this...
							alreadyTractoring:Set[TRUE]
							echo "EVESalvage->SalvageArea::  ----- Already tractoring...."
							if (${Targets[${k}].Distance} <= ${MaxSalvageRange})
							{
								echo "EVESalvage->SalvageArea::  ------ Wreck close enough now... stop tractoring..."
								TractorBeams[${j}]:Deactivate
								WaitCounter:Set[0]
								do
								{
									wait ${WaitTimeVariable}
									if (${WaitCounter} > 20)
										break
									WaitCounter:Inc[${WaitTimeVariable}]
								}
								while !${TractorBeams[${j}].IsDeactivating}
							}
						}
					}	
				}
				while (${j:Inc} <= ${TractorBeams.Used})
				;; END LOOP (determine if wreck is already being tractored)
				;;;;;;;;;;;;;;;;;;;;;;;
				
				;;;;;;;;;;;;;;;;;;;;;;;
				;; if it was NOT already being tractored, then start tractoring
				if (!${alreadyTractoring})
				{
					echo "EVESalvage->SalvageArea::  ---- Start tractoring...."
								
					;; Activate Tractor Beam...
					j:Set[1]
					do
					{
						if (!${TractorBeams[${j}].IsActive} && !${TractorBeams[${j}].IsDeactivating} )
						{
						  echo "EVESalvage->SalvageArea::  ---- Activating: ${TractorBeams[${j}].ToItem.Name}"
							TractorBeams[${j}]:Click
							WaitCounter:Set[0]
							do
							{
								wait ${WaitTimeVariable}
								if (${WaitCounter} > 20)
									break
								WaitCounter:Inc[${WaitTimeVariable}]
							}
							while !${TractorBeams[${j}].IsActive}
							break
						}	
					}
					while (${j:Inc} <= ${TractorBeams.Used})				
				}
			}
			elseif (${Targets[${k}].Distance} > ${MaxTractorRange} || ${SalvagingYellowWrecks})
			{
				if !${SalvagingYellowWrecks}
					echo "EVESalvage->SalvageArea::  --- Wreck out of Tractor range..."
								
				;;;;;;;;;;;;;;;;;;;;;;;
				;; Do not approach if any salvagers are actively running
				ContinueOn:Set[TRUE]
				j:Set[1]
				do
				{
					if (${Salvagers[${j}].IsActive})
					{
						echo "EVESalvage->SalvageArea::  --- Can not approach while actively salvaging"
						ContinueOn:Set[FALSE]
						break
					}
				}
				while ${j:Inc} <= ${Salvagers.Used}
				;;
				;;;;;;;;;;;;;;;;;;;;;;;
				
				;;;;;;;;;;;;;;;;;;;;;;;
				;; Do not approach/move if any jet cans are close by
				if (${ContinueOn})
				{
					if (${IgnoreRightsOnCans})
						EVE:QueryEntities[Cans, Name =- "Cargo Container" && Distance <= LOOT_RANGE]
					else
						EVE:QueryEntities[Cans, Name =- "Cargo Container" && Distance <= LOOT_RANGE && (HaveLootRights = 1 || IsOwnedByCorpMember = 1)]
				  if ${Cans.Used} > 0
				  {  	
						echo "EVESalvage->SalvageArea::  --- Can not approach while jet cans present..."
						ContinueOn:Set[FALSE]	
				  }
				}
				;;
				;;;;;;;;;;;;;;;;;;;;;;;
				
				;;;;;;;;;;;;;;;;;;;;;;;
				;; Approach Wreck
				if (${ContinueOn})
				{
					if ${SalvagingYellowWrecks}
						MoveWithinDistance:Set[${MaxSalvageRange}]
					else
						MoveWithinDistance:Set[${MaxTractorRange}]
						
					if (${Targets[${k}](exists)})
					{		
						echo "EVESalvage->SalvageArea::  --- Approaching Wreck (to within ${MoveWithinDistance}m)..."
						call ApproachEntity ${Targets[${k}]} ${MoveWithinDistance}
						echo "EVESalvage->SalvageArea::  ---- Wreck is now within ${MoveWithinDistance}m..."
					}
					else
					{
						echo "EVESalvage->SalvageArea::  **ERROR ENCOUNTERED {Targets[${k}]} is NULL** [_FILE_: _LINE_)"
						ContinueOn:Set[FALSE]
					}
				}
				
				if ${ContinueOn}
				{
					if ${SalvagingYellowWrecks}
					{
						;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
						;; First, make sure we don't already a salvager on this wreck
						alreadySalvaging:Set[FALSE]
						Salvagers:GetIterator[Salvager]
						if (${Salvager:First(exists)})
						{
							do
							{
								if (${Salvager.Value.TargetID.Equal[${Me.ActiveTarget.ID}]})
								{
									alreadySalvaging:Set[TRUE]
									break
								}
							}
							while ${Salvager:Next(exists)}
						}
						;;
						;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
						
						if (!${alreadySalvaging})
						{
							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
							;; Engage a Salvager (if one is available)
							j:Set[1]
							do
							{
								if (!${Salvagers[${j}].IsActive} && !${Salvagers[${j}].IsDeactivating})
								{
									echo "EVESalvage->SalvageArea::  ----- Wreck in range, Using ${Salvagers[${j}].ToItem.Name} (${Salvagers[${j}].ToItem.ID}) on ${Targets[${k}].Name}..."
									Salvagers[${j}]:Click
									WaitCounter:Set[0]
									do
									{
										wait ${WaitTimeVariable}
										if (${WaitCounter} > 20)
											break
										WaitCounter:Inc[${WaitTimeVariable}]
									}
									while !${Salvagers[${j}].IsActive}
									break
								}
							}
							while ${j:Inc} <= ${Salvagers.Used}
							;; END LOOP [Activating a salvager on this wreck]
							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
						}			
					}
				}
			}
			else
			{
				echo "EVESalvage->SalvageArea::  WHAT?!"
			}
			
			;; Now we check the next locked target
			k:Inc 
		}
		;; END LOOP (current locked targets)  ["while ${k} <= ${Targets.Used}"]
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Targets are all being handled.  Deal with any nearby jet cans
		if ${LootCans}
		{
			call CheckForLoot LOOT_RANGE
		}
		;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Make sure we're not running low on capacitor
		if (${MyShip.CapacitorPct} <= 22)
		{
			echo "EVESalvage->SalvageArea::  !! Running low on Capacitor:  Pausing...
			do
			{
			   wait 20
			}
			while (${MyShip.CapacitorPct} <= 22)
		}
		;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Make sure we aren't out of cargo space
		call CheckShipIsFull 0
		;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Repopulate "Wrecks" with updated data
		EVE:QueryEntities[Wrecks,Name =- "wreck" && GroupID == GROUPID_WRECK && (HaveLootRights = 1 || IsOwnedByCorpMember = 1)]
		if (${Wrecks.Used} == 0)
		{
			if ${IgnoreRightsOnWrecks}
			{
				SalvagingYellowWrecks:Set[TRUE]
				EVE:QueryEntities[Wrecks,Name =- "wreck" && GroupID == GROUPID_WRECK]
				if (${Wrecks.Used} == 0)
				{
					echo "EVESalvage->SalvageArea::  - Salvaging complete -- looking for loot..."
					if (${LootCans})
						call CheckForLoot ${EVE.MinWarpDistance}	
					call ManipulateSensorBoosters "Off"
					return
				}
				else
					echo "EVESalvage->SalvageArea::  - ${Wrecks.Used} YELLOW wrecks remain in this area."
			}
			else
			{
				echo "EVESalvage->SalvageArea::  - Salvaging complete -- looking for loot..."
				if (${LootCans})
					call CheckForLoot ${EVE.MinWarpDistance}		
				call ManipulateSensorBoosters "Off"
				return
			}
		}
		else
			echo "EVESalvage->SalvageArea::  - ${Wrecks.Used} wrecks remain in this area."
		;;
		;; This is the end of the Main Salvaging Loop.  This will repeat over and over until there
		;; are no more wrecks in the area.  (which will cause the routine directly above to 'return',
		;; thereby ending the loop.)   
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	} 
	
	;;;;;;;;
	;; This part of the function should never be reached (the main loop should 'return' itself)
	;; But, just in case...
	call ManipulateSensorBoosters "Off"
	return	
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loot the cargo container passed as the argument "CargoContainer"
;; (NOTE:  This function assumes that "CargoContainer" is within looting range.)
function LootCargoContainer(entity CargoContainer)
{	
		variable iterator ThisCargo
		variable iterator CargoIterator
		variable float64 TotalCargoVolume = 0
		
		;; Open Entity for looting
		CargoContainer:OpenCargo
		wait 20
		call OpenShipCargo					

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Populate "EntityCargo" (index:item)
		CargoContainer:GetCargo[EntityCargo]
		EntityCargo:GetIterator[ThisCargo]

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Populate "CargoToTransfer" based upon whether it's set to ignore or not in the 'Loot Items Database'
		;; and other criteria
		CargoToTransfer:Clear
		if ${ThisCargo:First(exists)}
		{
			do
			{
				variable string Name
				Name:Set[${ThisCargo.Value.Name}]			
				
				CheckLootItemDB:Set[${LootItemsDB.FindSetting["${Name}",FALSE]}]
				LavishSettings[Loot Items Database]:Export[${EVELootingFileName}]
				
				; If the entry in the xml is FALSE, then we want to loot it.
				if (!${CheckLootItemDB})
				{
					if (!${LootContraband})
					{
						if (${ThisCargo.Value.IsContraband})
						{
							echo "EVESalvage->LootCargoContainer::  Ignoring ${Name} (CONTRABAND)"
							continue
						}
					}
					CargoToTransfer:Insert[${ThisCargo.Value.ID}]
					TotalCargoVolume:Inc[${Math.Calc[${ThisCargo.Value.Quantity} * ${ThisCargo.Value.Volume}]}]
					echo "EVESalvage->LootCargoContainer::  - Adding ${ThisCargo.Value.Name} (TotalCargoVolume: ${TotalCargoVolume.Precision[2]})"
				}
				else
					echo "EVESalvage->LootCargoContainer::  Ignoring ${Name}"	
			}
			while ${ThisCargo:Next(exists)}
		}
		;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Check to make sure the ship's cargo hold has room
		if (${TotalCargoVolume} > ${Math.Calc[${MyShip.CargoCapacity} - ${MyShip.UsedCargoCapacity}]})
		{
			echo "EVESalvage->LootCargoContainer::  Ship Cargo Hold is full."
			CargoContainer:CloseCargo
			wait 2
			CargoContainer:UnlockTarget
			wait 2		
			call CheckShipIsFull 1
			return
		}
		;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Make sure there is loot we want to process
		if (${CargoToTransfer.Used} <= 0)
		{
			echo "EVESalvage->LootCargoContainer::  Entity either has no items, or else no item(s) pass(es) muster for looting"
			CargoContainer:CloseCargo
			wait 2
			CargoContainer:UnlockTarget
			wait 2			
			return
		}
		else
			echo "EVESalvage->LootCargoContainer::  -- Ready to transfer ${CargoToTransfer.Used} items."
		;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Adding loot to "CargoholdLoot" (which is used when unloading loot to the 'Scavenger Home Base' station)
		if ${CargoToTransfer.Used} > 0
		{
			CargoToTransfer:GetIterator[CargoIterator]
			
			if ${CargoIterator:First(exists)}
			do
			{
					CargoholdLoot:Set[${CargoIterator.Value},1]
			}
			while (${CargoIterator:Next(exists)})
		}
		;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		EVE:MoveItemsTo[CargoToTransfer, ${MyShip.ID}, CargoHold]
		wait 5
		
		return
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; If the bookmark ${HomeBaseBookmarkName} exists, return to it and transfer
;; all salvaged and looted items to the hangar's cargo hold
function ReturnToHomeBase()
{
  call CloseShipCargo
  if (${EVE.Bookmark[${HomeBaseBookmarkName}](exists)})
	 {
		echo "EVESalvage->ReturnToHomeBase::  Salvage operations completed .. returning to home base ('${HomeBaseBookmarkName}')"
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; If it is in another solar system
		;;
		;; NOTE:  If the bookmark is a 'station' then autopilot will go ahead and dock with the station.
		if (!${EVE.Bookmark[${HomeBaseBookmarkName}].SolarSystemID.Equal[${Me.SolarSystemID}]})
		{
			echo "EVESalvage->ReturnToHomeBase::  - Setting destination and activating auto pilot for return to home base"
			EVE.Bookmark[${HomeBaseBookmarkName}]:SetDestination
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

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Otherwise, the bookmark is in the current solar system
		if (!${Me.InStation})
		{
			;; TODO:  .Distance is NULL sometimes.  This is a quick fix for now so that the script assumes that a warp is necessary if the .Distance is NULL/0
			if (${EVE.Bookmark[${HomeBaseBookmarkName}].Distance} <= 0 || ${EVE.Bookmark[${HomeBaseBookmarkName}].Distance} > ${EVE.MinWarpDistance})
			{
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				;; Warp to location
				echo "EVESalvage->ReturnToHomeBase::  - Warping to home base location"
				EVE.Bookmark[${HomeBaseBookmarkName}]:WarpTo
				wait 120
				do
				{
					wait 20
				}
				while (${Me.ToEntity.Mode} == 3)
				wait 20
			}
			else
				echo "EVESalvage->ReturnToHomeBase::  - No need to warp (${EVE.Bookmark[${HomeBaseBookmarkName}].Distance} is not greater than ${EVE.MinWarpDistance})"
				
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;; The bookmark is an 'entity', handle it properly  [At the moment, only 'station' bookmarks should have a valid .ToEntity]
			if ${EVE.Bookmark[${HomeBaseBookmarkName}].ToEntity(exists)}
			{
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				;; The bookmark is a 'station'.  Approach and dock.
				if (${EVE.Bookmark[${HomeBaseBookmarkName}].ToEntity.CategoryID.Equal[3]})
				{
					if (${EVE.Bookmark[${HomeBaseBookmarkName}].ToEntity(exists)})
						call ApproachEntity ${EVE.Bookmark[${HomeBaseBookmarkName}].ToEntity} DOCKING_RANGE
					else
						echo "EVESalvage->ReturnToHomeBase::  **ERROR ENCOUNTERED {EVE.Bookmark['Salvager Home Base'].ToEntity} is NULL** [_FILE_: _LINE_)"
	
					EVE.Bookmark[${HomeBaseBookmarkName}].ToEntity:Dock
					Counter:Set[0]
					do
					{
					   wait 20
					   Counter:Inc[20]
					   if (${Counter} > 200)
					   {
					      echo "EVESalvage->ReturnToHomeBase::  -- Docking atttempt failed ... trying again."
					      Entity[CategoryID = CATEGORYID_STATION]:Dock
					      Counter:Set[0]
					   }
					}
					while (!${Me.InStation})
				}
				;;
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			}
			else
			{
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				;; The bookmark is not an 'entity'; therefore, we need to use the entity name provided
				echo "EVESalvage->ReturnToHomeBase::  -- Attempting unload to '${UnloadTo}'"
				if ${Entity[Name =- "${UnloadTo}"](exists)}
				{
					call ApproachEntity ${Entity[Name =- "${UnloadTo}"]} LOOT_RANGE
					call TransferSalvagedItemsAndLootToEntity ${Entity[Name =- "${UnloadTo}"]}
					return
				}
				else
					echo "EVESalvage->ReturnToHomeBase::  -- There is no {Entity[Name =- \"${UnloadTo}\"]} in this area."
				;;
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			}
		}
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Otherwise, we're in a station -- unload!
		if (${Me.InStation})		
		{
			;;; unload all "salvaged" items to hangar ;;;;;;;;;;;;;;
		  wait 10
		  echo "EVESalvage->ReturnToHomeBase::  --- Unloading Items..."
		 	call TransferSalvagedItemsAndLootToHangar
		}
	}
	
	return
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Undock from the current space station
function LeaveStation()
{
	if ${Me.InStation}
	{
	   echo "EVESalvage->LeaveStation::  - Undocking from station..."
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
		   			  echo "EVESalvage->LeaveStation::  - Undocking attempt failed ... trying again."
		   				EVE:Execute[CmdExitStation]
		   				Counter:Set[0]
		   			}
	   		}
	   		while (${Me.InStation} || !${EVEWindow[Local](exists)} || !${Me.InStation(exists)})
	   }
	   wait 5
	}
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cycle through all of the asteroid belts in the CURRENT system and salvage
function CycleBeltsAndSalvage()
{
	variable iterator AsteroidBelt

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; The caller should ensure that we are in space 
	if ${Me.InStation}
	{
		echo "EVESalvage->CycleBelts::  You must be in space to cycle asteroid belts for scavenging."
		return
	}

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Populate 'Belts' for this system  
	EVE:QueryEntities[Belts, Name =- "Asteroid Belt"]
	
	if (${Belts.Used} < 1)
	{
		echo "EVESalvage->CycleBelts::  There does not appear to be any asteroid belts in this system."
		return
	}
	else
		echo "EVESalvage->CycleBelts::  There are ${Belts.Used} asteroid belts in this system."
	
	Belts:GetIterator[AsteroidBelt]
	if ${AsteroidBelt:First(exists)}
	{
		do
		{
			echo "EVESalvage->CycleBelts::  Traveling to ${AsteroidBelt.Value.Name}..."
			
			if (${AsteroidBelt.Value.Distance} > ${EVE.MinWarpDistance})
			{
	  		;;; Warp to location
	  		echo "EVESalvage->CycleBelts::  Warping to ${AsteroidBelt.Value.Name}..."
	  		AsteroidBelt.Value:WarpTo
	  		wait 120
	  		do
	  		{
	  			wait 20
	  		}
	  		while (${Me.ToEntity.Mode} == 3)
	  	}
	
	  	wait 10
			call SalvageArea ${DoLoot}
		}
		while ${AsteroidBelt:Next(exists)}
	}
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Click or Deactivate sensor booster
function ManipulateSensorBoosters(string State)
{
	variable iterator SensorBooster
	
	if (${State.Equal["On"]})
	{
		if (${SensorBoosters.Used} > 0)
		{
			SensorBoosters:GetIterator[SensorBooster]
			if ${SensorBooster:First(exists)}
			{
				do
				{
					if (!${SensorBooster.Value.IsActive} && !${SensorBooster.Value.IsDeactivating})
					{
						echo "EVESalvage->ManipulateSensorBoosters::  Activating Sensor Booster (${SensorBooster.Value.ToItem.Name})"
						SensorBooster.Value:Click
					}
				}
				while (${SensorBooster:Next(exists)})
			}
		}
	}
	elseif (${State.Equal["Off"]})
	{
		if (${SensorBoosters.Used} > 0)
		{
			SensorBoosters:GetIterator[SensorBooster]
			if ${SensorBooster:First(exists)}
			{
				do
				{
					if (${SensorBooster.Value.IsActive} && !${SensorBooster.Value.IsDeactivating})
					{
						echo "EVESalvage->ManipulateSensorBoosters::  Deactivating Sensor Booster (${SensorBooster.Value.ToItem.Name})"
						SensorBooster.Value:Deactivate
					}
				}
				while (${SensorBooster:Next(exists)})
			}
		}
	}
	
	return
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Appraoch an entity until within ${WithinDistance}
function ApproachEntity(entity TheEntity, int WithinDistance)
{
	if (${TheEntity.Distance} <= ${WithinDistance})
		return
		
	echo "EVESalvage->ApproachEntity::  Approaching '${TheEntity.Name}'"
	TheEntity:Approach
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Use Afterburner/MWD (if applicable)
	if (${Afterburners.Used} > 0)
	{
		if (!${Afterburners[1].IsActive} && !${Afterburners[1].IsDeactivating})
			Afterburners[1]:Click
	}
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Wait until within range
	do
	{
		wait 10
	}
	while (${TheEntity.Distance} > ${WithinDistance})	
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Turn off Afterburner/MWD (if applicable)
	if (${Afterburners.Used} > 0)
	{
		if (${Afterburners[1].IsActive} && !${Afterburners[1].IsDeactivating})
			Afterburners[1]:Deactivate
	}
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	EVE:Execute[CmdStopShip]
	return
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Populate the Cargo To Transfer (when salvaging is complete)
function PopulateCargoToTransfer(string CargoType)
{
	
	variable iterator ThisCargo

  wait 10
  call OpenShipCargo
	wait 20

	MyShip:GetCargo[MyCargo]
	if (${MyCargo.Used} == 0)
	{
		call CloseShipCargo
		wait 10
		call OpenShipCargo
		wait 10
		MyShip:GetCargo[MyCargo]
	}					
					
	CargoToTransfer:Clear[]
	MyCargo:GetIterator[ThisCargo]
	if ${ThisCargo:First(exists)}
	{
		if (${CargoType.Equal["Salvage"]})
		{
			do
			{
				variable int GroupID
				GroupID:Set[${ThisCargo.Value.GroupID}]
				
				;variable string Name
				;Name:Set[${ThisCargo.Value.Name}]
				;echo "EVESalvage->PopulateCargoToTransfer[DEBUG]::  GroupID: ${GroupID} ${Name} - ${ThisCargo.Value.Quantity}"			
				
				switch ${GroupID}
				{
					case GROUPID_SALVAGEDITEM
						CargoToTransfer:Insert[${ThisCargo.Value.ID}]
						break
					default
						break
				}
			}
			while ${ThisCargo:Next(exists)}
		}
		elseif (${CargoType.Equal["Loot"]})
		{
			do
			{
				;echo "EVESalvage->PopulateCargoToTransfer[DEBUG]::  CargoholdLoot.Element[ThisCargo.Value.ID]: ${CargoholdLoot.Element[${ThisCargo.Value.ID}]}"
				if (${CargoholdLoot.Element[${ThisCargo.Value.ID}](exists)})
					CargoToTransfer:Insert[${ThisCargo.Value.ID}]
			}
			while ${ThisCargo:Next(exists)}
		}
	}
	
	return
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Transfer all salvaged items and loot to the station hanger present when this function is called
;; (NOTE:  This function will only transfer those items looted since the library was initialized, 
;;         not everything that is in the ship's cargo hold.)
function TransferSalvagedItemsAndLootToHangar()
{	
	if (!${Me.InStation})
	{
		return
	}	
	
	echo "EVESalvage->TransferSalvagedItemsAndLootToHangar::  --- Opening Hangar..."
	if !${EVEWindow[ByCaption,"item hangar"](exists)}
	{
		EVE:Execute[OpenHangarFloor]
		wait 25
	}	
	
	echo "EVESalvage->TransferSalvagedItemsAndLootToHangar::  --- Unloading Salvaged Items..."
	call PopulateCargoToTransfer "Salvage"
	if (${CargoToTransfer.Used} > 0)
	{
		echo "EVESalvage->TransferSalvagedItemsAndLootToHangar::  ---- ${CargoToTransfer.Used} items found..."
		if (${UseCorpHangar})
		{
			echo "EVESalvage->TransferSalvagedItemsAndLootToHangar::  ----- Transferring items to your corporation's hangar ['${CorpFolderToUse}']"
			EVE:MoveItemsTo[CargoToTransfer, MyStationCorporateHangar, StationCorporateHangar, ${CorpFolderToUse}]
		}
		else
		{
			echo "EVESalvage->TransferSalvagedItemsAndLootToHangar::  ----- Transferring items to your personal hangar"
			EVE:MoveItemsTo[CargoToTransfer, MyStationHangar]
		}
	}
	if (${DoLoot})
	{
		echo "EVESalvage->TransferSalvagedItemsAndLootToHangar::  --- Unloading Loot..."
		call PopulateCargoToTransfer "Loot"
		if (${CargoToTransfer.Used} > 0)
		{
			echo "EVESalvage->TransferSalvagedItemsAndLootToHangar::  ---- ${CargoToTransfer.Used} items found..."
			if (${UseCorpHangar})
			{
				echo "EVESalvage->TransferSalvagedItemsAndLootToHangar::  ----- Transferring items to your corporation's hangar ['${CorpFolderToUse}']"
				EVE:MoveItemsTo[CargoToTransfer, MyStationCorporateHangar, StationCorporateHangar, ${CorpFolderToUse}]
			}
			else
			{
				echo "EVESalvage->TransferSalvagedItemsAndLootToHangar::  ----- Transferring items to your personal hangar"
				EVE:MoveItemsTo[NewCargoToTransfer, MyStationHangar]	
			}
		}
	}
	EVEWindow[ByCaption,"item hangar"]:StackAll
	EVEWindow[ByCaption,"active ship"]:StackAll
	EVEWindow[byName, "Inventory"]:Close
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Transfer salvaged items and loot to entity
;; (NOTE:  This function will only transfer those items looted since the library was initialized, 
;;         not everything that is in the ship's cargo hold.)
function TransferSalvagedItemsAndLootToEntity(entity TheEntity)
{
	variable int TimeOut
	
	switch ${TheEntity.GroupID}
	{
		case GROUPID_CARGO_CONTAINER
		case GROUPID_SECURE_CARGO_CONTAINER
			echo "EVESalvage->TransferSalvagedItemsAndLootToEntity::  --- Opening '${TheEntity.Name}'..."
			if (!${EVEWindow[ByItemID, ${TheEntity.ID}](exists)})
				TheEntity:OpenCargo
			wait 5
			if !${EVEWindow[ByItemID, ${TheEntity.ID}](exists)}
			{
				do
				{
					TimeOut:Inc[5]
					wait 5
					if ${TimeOut} > 50
						break
				}
				while !${EVEWindow[ByItemID, ${TheEntity.ID}](exists)}
			}				
			echo "EVESalvage->TransferSalvagedItemsAndLootToEntity::  --- Unloading Salvaged Items..."
			call PopulateCargoToTransfer "Salvage"
			if (${CargoToTransfer.Used} > 0)
			{
				echo "EVESalvage->TransferSalvagedItemsAndLootToEntity::  ---- ${CargoToTransfer.Used} items found..."
				EVE:MoveItemsTo[CargoToTransfer, ${TheEntity.ID}, CargoHold]
			}
			if (${DoLoot})
			{
				echo "EVESalvage->TransferSalvagedItemsAndLootToEntity::  --- Unloading Loot..."
				call PopulateCargoToTransfer "Loot"
				if (${CargoToTransfer.Used} > 0)
				{
					EVE:MoveItemsTo[CargoToTransfer, ${TheEntity.ID}, CargoHold]		
					echo "EVESalvage->TransferSalvagedItemsAndLootToEntity::  ---- ${CargoToTransfer.Used} items found..."
				}
			}
			EVEWindow[ByItemID,${TheEntity.ID}]:StackAll
			EVEWindow[ByCaption,"active ship"]:StackAll
			EVEWindow[byName, "Inventory"]:Close
			break
		
		case GROUPID_INDUSTRIALCOMMANDSHIP
		case GROUPID_CORPORATE_HANGAR_ARRAY
			echo "EVESalvage->TransferSalvagedItemsAndLootToEntity::  --- Opening '${TheEntity.Name}'..."
			if (!${EVEWindow[ByItemID, ${TheEntity.ID}](exists)})
				TheEntity:OpenStorage
			wait 5
			if !${EVEWindow[ByItemID, ${TheEntity.ID}](exists)}
			{
				do
				{
					TimeOut:Inc[5]
					wait 5
					if ${TimeOut} > 50
						break
				}
				while !${EVEWindow[ByItemID, ${TheEntity.ID}](exists)}
			}				
			echo "EVESalvage->TransferSalvagedItemsAndLootToEntity::  --- Unloading Salvaged Items..."
			call PopulateCargoToTransfer "Salvage"
			if (${CargoToTransfer.Used} > 0)
			{
				echo "EVESalvage->TransferSalvagedItemsAndLootToEntity::  ---- ${CargoToTransfer.Used} items found..."
				EVE:MoveItemsTo[CargoToTransfer, ${TheEntity.ID}, Hangar, ${CorpFolderToUse}]
			}
			if (${DoLoot})
			{
				echo "EVESalvage->TransferSalvagedItemsAndLootToEntity::  --- Unloading Loot..."
				call PopulateCargoToTransfer "Loot"
				if (${CargoToTransfer.Used} > 0)
				{
					EVE:MoveItemsTo[CargoToTransfer, ${TheEntity.ID}, Hangar, ${CorpFolderToUse}]		
					echo "EVESalvage->TransferSalvagedItemsAndLootToEntity::  ---- ${CargoToTransfer.Used} items found..."
				}
			}
			EVE:StackItems[${TheEntity.ID}, Hangar, ${CorpFolderToUse}]
			EVEWindow[ByCaption,"active ship"]:StackAll
			EVEWindow[byName, "Inventory"]:Close
			
			break
		
		Default
			break
	}
	
	return
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; If the ship's cargo hold is full, deal with it.  If 'IgnoreCapacity' is TRUE, then it returns to your 
;; HomeBase and unloads whatever you have currently without doing any capacity checks.
;; 
function CheckShipIsFull(bool IgnoreCapacity)
{
	variable int k
	variable int UndockCounter
	
	;echo "DEBUG: Math.Calc[MyShip.CargoCapacity-MyShip.UsedCargoCapacity: ${Math.Calc[${MyShip.CargoCapacity}-${MyShip.UsedCargoCapacity}]}"
	;echo "DEBUG: Math.Calc[MyShip.CargoCapacity*0.01: ${Math.Calc[${MyShip.CargoCapacity}*0.01]}"
	
	if !${IgnoreCapacity}
	{
		/* 
		; salvage operation requires a minimum of 40 m^3 free -- so, this is not useful 
		if (${Math.Calc[${MyShip.CargoCapacity}-${MyShip.UsedCargoCapacity}]} > ${Math.Calc[${MyShip.CargoCapacity}*0.01]})
		return
		*/
	 	
		if (${Math.Calc[${MyShip.CargoCapacity}-${MyShip.UsedCargoCapacity}]} > 40)
		{
			return
		}	   	
	}
	
	if (!${EVE.Bookmark[${HomeBaseBookmarkName}](exists)})
	{
		echo "EVESalvage->CheckShipIsFull::  -- Your ship is full; however, you do not have a 'HomeBase' bookmark."
		echo "EVESalvage->CheckShipIsFull::  - Ending Script"
		Script:End
		return
	}
	
	echo "EVESalvage->CheckShipIsFull::  - Ship is Full. (${Math.Calc[${MyShip.CargoCapacity}-${MyShip.UsedCargoCapacity}]} remaining)"
	
	echo "EVESalvage->CheckShipIsFull::  -- Creating temporary bookmark 'ContinueSalvagingHere'"
	EVE:CreateBookmark["ContinueSalvagingHere"]
	
	echo "EVESalvage->CheckShipIsFull::  -- Returning to ${HomeBaseBookmarkName} for unloading."
	; This function also "unloads"
	call ReturnToHomeBase
	 
	echo "EVESalvage->CheckShipIsFull::  -- Cargo Unloaded, returning to previous location"
	call TravelToBookmark "ContinueSalvagingHere"

	echo "EVESalvage->CheckShipIsFull::  -- Removing temporary bookmark 'ContinueSalvagingHere'"
	EVE.Bookmark["ContinueSalvagingHere"]:Remove
	
  echo "EVESalvage->CheckShipIsFull::  - Cargo Hold Empty: Resuming Operations..."
  return
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Travel to the given bookmark name
function TravelToBookmark(string BookmarkName)
{
	if (${EVE.Bookmark["${BookmarkName}"](exists)})
	{
		call LeaveStation

		;;; Set destination and then activate autopilot (if we're not in that system to begin with)
		if (!${EVE.Bookmark["${BookmarkName}"].SolarSystemID.Equal[${Me.SolarSystemID}]})
		{
		  echo "EVESalvage->TravelToBookmark::  - Setting Destination and activating auto pilot for '${BookmarkName}'..."
		  wait 5
			EVE.Bookmark["${BookmarkName}"]:SetDestination
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
		
		;; TODO:  .Distance is NULL sometimes.  This is a quick fix for now so that the script assumes that a warp is necessary if the .Distance is NULL/0
		if (${EVE.Bookmark["${BookmarkName}"].Distance} <= 0 || ${EVE.Bookmark["${BookmarkName}"].Distance} > ${EVE.MinWarpDistance})
		{
  		;;; Warp to location
  		echo "EVESalvage->TravelToBookmark::  -- Warping to '${BookmarkName}'..."
  		EVE.Bookmark["${BookmarkName}"]:WarpTo
  		wait 120
  		do
  		{
  			wait 20
  		}
  		while (${Me.ToEntity.Mode} == 3)
  	}
  }
  else
  {
  	echo "EVESalvage->TravelToBookmark::  CRITICAL ERROR ['${BookmarkName}' bookmark did not exist!]"
		Script:End
		return
	}
	
	return
}