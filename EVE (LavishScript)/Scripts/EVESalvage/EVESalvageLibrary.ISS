;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; IMPORTANT NOTE:  This file is not a standalone script.  It simply includes 
;;                  functions that can be used with multiple (salvage related)
;;                  scripts.   See EVESalvage.iss for an example of how this
;;                  file is (and its contents are) included and used.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declare all script or global variables here
variable(script) int TractorBeamCount
variable(script) int SalvagerCount
variable(script) int AfterburnerCount
variable(script) index:module AllModules
variable(script) index:module TractorBeams
variable(script) index:module Salvagers
variable(script) index:module Afterburners
variable(script) index:item MyCargo
variable(script) index:int64 CargoToTransfer
variable(script) index:int64 NewCargoToTransfer
variable(script) int MaxSalvageRange
variable(script) int MaxTractorRange
variable(script) int MoveWithinDistance
variable(script) index:entity Wrecks
variable(script) int MaxTargets
variable(script) int MaxTargetRange
variable(script) index:entity Targets
variable(script) bool ContinueOn
variable(script) bool alreadyTractoring
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
		echo ERROR -- Your ship does not appear to have any modules
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
		}
		while (${iModule:Next(exists)})
	}
	
	TractorBeamCount:Set[${TractorBeams.Used}]
	SalvagerCount:Set[${Salvagers.Used}]
	AfterburnerCount:Set[${Afterburners.Used}]
  echo "EVESalvage->GetModulesInformation::  Your ship has ${TractorBeamCount} Tractor Beams, ${SalvagerCount} Salvage Modules, and ${AfterburnerCount} Afterburner."
  ModuleInformationAcquired:Set[TRUE]
	return
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Opens the player's ship cargo hold
function OpenShipCargo()
{
	if !${EVEWindow[MyShipCargo](exists)}
	{
		echo "EVESalvage->OpenShipCargo::  Opening Ship Cargohold"
		MyShip:OpenCargo
		wait 15
		while !${EVEWindow[MyShipCargo](exists)}
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
	if ${EVEWindow[MyShipCargo](exists)}
	{
		echo "EVESalvage->CloseShipCargo::  Stacking cargo..."
		MyShip:StackAllCargo
		wait 10					
		
		echo "EVESalvage->CloseShipCargo::  Closing Ship Cargohold"
		EVEWindow[MyShipCargo]:Close
		wait 15
		while ${EVEWindow[MyShipCargo](exists)}
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
function CheckForLoot(bool InReachOnly)
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
		EVE:QueryEntities[NearbyCans, Name =- "Cargo Container" && Distance <= 2500]
	else
		EVE:QueryEntities[NearbyCans, Name =- "Cargo Container" && Distance <= 2500 && (HaveLootRights = 1 || IsOwnedByCorpMember = 1)]
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
			call LootCargoContainer ${NearbyCans[${i}]}
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
			i:Inc
		}
		while ${i} <= ${NearbyCans.Used}
	} 	
	;; END LOOP (handling nearby cans)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Handle ALL remaining cans if we have NOT set ${InReachOnly}
	if (!${InReachOnly})
	{
		if (${IgnoreRightsOnCans})
			EVE:QueryEntities[Cans, Name =- "Cargo Container"]
		else
			EVE:QueryEntities[Cans, Name =- "Cargo Container" && (HaveLootRights = 1 || IsOwnedByCorpMember = 1)]
			
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
						wait 2
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
				    while ${Me.TargetingCount} > 0
				    {
				    	echo "EVESalvage->CheckForLoot::  -- Waiting for lock on all targets..."
							wait 5
				    }
	
						;;;;;;;;;;;;;;;;;;;;;;;;
						;; Approach
				    if (${Me.TargetCount} == 0)
				    {
				    	echo "EVESalvage->CheckForLoot::  -- ${Cans[${i}].Name} too far away to target :: Approaching..."
							Cans[${i}]:Approach
							if (${AfterburnerCount} > 0)
							{
								if (${Afterburners[1].IsDeactivating})
								{
									while ${Afterburners[1].IsDeactivating}
									{
										wait 5
									}
								}			
								if (!${Afterburners[1].IsActive})
									Afterburners[1]:Click
								wait 5
							}			
							while (${Cans[${i}].Distance} > ${MaxTargetRange})
							{
								wait 20
							}
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
				wait 5
				i:Inc
			}   
			;; Finished Targetting Routine  
			;; This closing bracket is the end of the loop: "while (${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}]} < ${MaxTargets})"
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			;; Wait until all targets are fully locked
			if (${Me.TargetingCount} > 0)
			{
				echo "EVESalvage->CheckForLoot::  -- Waiting for lock on all targets..."
				while ${Me.TargetingCount} > 0
				{
					wait 5
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
			
			wait 2
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
				wait 8
				
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
				if (${Targets[${k}].GroupID} != 12)
				{
					echo "EVESalvage->CheckForLoot::  --- ${Targets[${k}].Name} is not a cargo container.   Unlocking as target. (TURN OFF 'target back' OPTION IN EVE SETTINGS.)"
					Targets[${k}]:UnlockTarget
					k:Inc
					continue
				}
				;;
				;;;;;;;;;;;;;;;;;;;;;;;

				if (${Targets[${k}].Distance} <= 2500)
				{
					Targets[${k}]:MakeActiveTarget
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
							}
							wait 3
						}	
					}
					while (${j:Inc} <= ${TractorBeamCount})
					;; END LOOP [Disengaging tractor beams on this wreck]
					;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					
					;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					;; Loot!!
					echo "EVESalvage->CheckForLoot::  ---- ${Targets[${k}].Name} in range, Start Looting..."
					ProcessedEntities:Set[${Targets[${k}].ID},1]
					call LootCargoContainer ${Targets[${k}]}				

					;; End Looting
					;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				}
				k:Inc 
				wait 1
			}	
			;; END LOOP (current locked targets)
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			

			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;; Loop through all targets currently locked
			;; NOTE: At this point, all targets should be "cargo containers"
			;;
			;; cargo containers that are within 2500 should already have been looted
			;; Engage Tractors on cargo containers that are far away
			k:Set[1]
			while ${k} <= ${Targets.Used} 
			{
				wait 10
				if (!${Targets[${k}](exists)} || !${Targets[${k}].Name(exists)})
				{
					k:Inc
					continue
				}
				echo "EVESalvage->CheckForLoot::  --- Checking target: ${Targets[${k}].Name} (ID: ${Targets[${k}].ID})"

				;;;;;;;;;;;;;;;;;;;;;;;
				;; (Note:  Cargo containers that are within Salvage Range were already handled)
				if (${Targets[${k}].Distance} <= 2500)
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
					wait 2
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
								if (${Targets[${k}].Distance} <= 2500)
								{
									echo "EVESalvage->CheckForLoot::  ---- Cargo container close enough now... stop Tractoring..."
									TractorBeams[${j}]:Deactivate
								}
							}
							wait 1
						}	
					}
					while (${j:Inc} <= ${TractorBeamCount})
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
								wait 5
								break
							}	
							wait 2
						}
						while (${j:Inc} <= ${TractorBeamCount})				
					}
				}
				elseif (${Targets[${k}].Distance} > ${MaxTractorRange})
				{
					ContinueOn:Set[TRUE]
					echo "EVESalvage->CheckForLoot::  --- Cargo container out of tractor range..."
					
					;;;;;;;;;;;;;;;;;;;;;;;
					;; Ensure that we do not move unless we're positive there are no other cargo containers that are within 2500 of our current location
					if (${IgnoreRightsOnCans})
						EVE:QueryEntities[NearbyCans, Name =- "Cargo Container" && Distance <= 2500]
					else
						EVE:QueryEntities[NearbyCans, Name =- "Cargo Container" && Distance <= 2500 && (HaveLootRights = 1 || IsOwnedByCorpMember = 1)]
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

						Targets[${k}]:Approach
						if (${AfterburnerCount} > 0)
						{
							if (${Targets[${k}].Distance} > ${MaxTractorRange})
							{
								if (${Afterburners[1].IsDeactivating})
								{
									do
								 	{
										wait 5
									}
									while ${Afterburners[1].IsDeactivating}
								}

								if (!${Afterburners[1].IsActive})
								{
									Afterburners[1]:Click
									wait 5
								}
							}

							do
							{
								wait 20
							}
							while (${Targets[${k}].Distance} > ${MaxTractorRange})

							wait 2
							EVE:Execute[CmdStopShip]

							echo "EVESalvage->CheckForLoot::  --- Cargo container is now within tractor range..."

							if (${AfterburnerCount} > 0)
							{
								if (${Afterburners[1].IsActive})
								{
									Afterburners[1]:Deactivate
									wait 2
								}
							}
						}
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
				EVE:QueryEntities[Cans, Name =- "Cargo Container"]
			else
				EVE:QueryEntities[Cans, Name =- "Cargo Container" && (HaveLootRights = 1 || IsOwnedByCorpMember = 1)]
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
	EVE:QueryEntities[Wrecks,Name =- "wreck" && GroupID == 186 && (HaveLootRights = 1 || IsOwnedByCorpMember = 1)]
	if (${Wrecks.Used} == 0)
	{
		if ${IgnoreRightsOnWrecks}
		{
			SalvagingYellowWrecks:Set[TRUE]
			EVE:QueryEntities[Wrecks,Name =- "wreck" && GroupID == 186]
			if (${Wrecks.Used} == 0)
			{
				echo "EVESalvage->SalvageArea::  No wrecks found in this area, looking for loot..."
				if (${LootCans})
					call CheckForLoot 0		
				return
			}
			else
				echo "EVESalvage->SalvageArea::  ${Wrecks.Used} wrecks remain in this area."
		}
		else
		{
			echo "EVESalvage->SalvageArea::  No wrecks found in this area, looking for loot..."
			if (${LootCans})
				call CheckForLoot 0		
			return
		}
	}
	else
		echo "EVESalvage->SalvageArea::  ${Wrecks.Used} wrecks remain in this area."
	
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
					wait 2
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
						echo "EVESalvage->SalvageArea::  -- Waiting for lock on all targets..."
						while ${Me.TargetingCount} > 0
						{
							wait 5
						}
					}

					;;;;;;;;;;;;;;;;;;;;;;;;
					;; Approach
			    if (${Me.TargetCount} == 0)
			    {
			    	echo "EVESalvage->SalvageArea::  -- ${Wrecks[${i}].Name} too far away to target :: Approaching..."
						Wrecks[${i}]:Approach
						if (${AfterburnerCount} > 0)
						{
							if (${Afterburners[1].IsDeactivating})
							{
								while ${Afterburners[1].IsDeactivating}
								{
									wait 5
								}
							}			
							if (!${Afterburners[1].IsActive})
								Afterburners[1]:Click
							wait 5
						}			
						while (${Wrecks[${i}].Distance} > ${MaxTargetRange})
						{
							wait 20
						}
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
			wait 5
			i:Inc
		}   
		;; Finished Targetting Routine  
		;; This closing bracket is the end of the loop: "while (${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}]} < ${MaxTargets})"
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		;; Wait until all targets are fully locked
		if (${Me.TargetingCount} > 0)
		{
			echo "EVESalvage->SalvageArea::  -- Waiting for lock on all targets..."
			while ${Me.TargetingCount} > 0
			{
				wait 5
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

		wait 2
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
							wait 4
						}
						wait 1
					}	
				}
				while (${j:Inc} <= ${TractorBeamCount})
				;; END LOOP [Disengaging tractor beams on this wreck]
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				;; Engage a Salvager (if one is available)
				j:Set[1]
				do
				{
					if (!${Salvagers[${j}].IsActive} && !${Salvagers[${j}].IsDeactivating})
					{
						echo "EVESalvage->SalvageArea::  ---- Wreck in range, Using ${Salvagers[${j}].ToItem.Name} (${Salvagers[${j}].ToItem.ID}) on ${Targets[${k}].Name}..."
						Salvagers[${j}]:Click
						wait 8
						break
					}
				}
				while ${j:Inc} <= ${SalvagerCount}
				;; END LOOP [Activating a salvager on this wreck]
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			}
			k:Inc 
			wait 1
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
			wait 2
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
				wait 2
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
							}
						}
						wait 1
					}	
				}
				while (${j:Inc} <= ${TractorBeamCount})
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
							wait 5
							break
						}	
						wait 2
					}
					while (${j:Inc} <= ${TractorBeamCount})				
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
					wait 2
				}
				while ${j:Inc} <= ${SalvagerCount}
				;;
				;;;;;;;;;;;;;;;;;;;;;;;
				
				;;;;;;;;;;;;;;;;;;;;;;;
				;; Do not approach/move if any jet cans are close by
				if (${ContinueOn})
				{
					if (${IgnoreRightsOnCans})
						EVE:QueryEntities[Cans, Name =- "Cargo Container" && Distance <= 2500]
					else
						EVE:QueryEntities[Cans, Name =- "Cargo Container" && Distance <= 2500 && (HaveLootRights = 1 || IsOwnedByCorpMember = 1)]
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
					echo "EVESalvage->SalvageArea::  --- Approaching Wreck (to within ${MoveWithinDistance}m)..."
					
					Targets[${k}]:Approach
					if (${AfterburnerCount} > 0)
					{
						if (${Targets[${k}].Distance} > ${MoveWithinDistance})
						{
							if (${Afterburners[1].IsDeactivating})
							{
								do
							 	{
									wait 5
								}
								while ${Afterburners[1].IsDeactivating}
							}

							if (!${Afterburners[1].IsActive})
							{
								Afterburners[1]:Click
								wait 5
							}
						}

						do
						{
							wait 20
						}
						while (${Targets[${k}].Distance} > ${MoveWithinDistance})

						wait 2
						EVE:Execute[CmdStopShip]
						echo "EVESalvage->SalvageArea::  ---- Wreck is now within ${MoveWithinDistance}m..."

						if (${AfterburnerCount} > 0)
						{
							if (${Afterburners[1].IsActive})
							{
								Afterburners[1]:Click
								wait 2
							}
						}
						
						if ${SalvagingYellowWrecks}
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
									wait 8
									break
								}
							}
							while ${j:Inc} <= ${SalvagerCount}
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
			call CheckForLoot 1
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
			   wait 30
			}
			while (${MyShip.CapacitorPct} <= 22)
		}
		;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Make sure we aren't out of cargo space
		call CheckShipIsFull ${LootCans} 0
		;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Repopulate "Wrecks" with updated data
		EVE:QueryEntities[Wrecks,Name =- "wreck" && GroupID == 186 && (HaveLootRights = 1 || IsOwnedByCorpMember = 1)]
		if (${Wrecks.Used} == 0)
		{
			if ${IgnoreRightsOnWrecks}
			{
				SalvagingYellowWrecks:Set[TRUE]
				EVE:QueryEntities[Wrecks,Name =- "wreck" && GroupID == 186]
				if (${Wrecks.Used} == 0)
				{
					echo "EVESalvage->SalvageArea::  - Salvaging complete -- looking for loot..."
					if (${LootCans})
						call CheckForLoot 0		
					return
				}
				else
					echo "EVESalvage->SalvageArea::  - ${Wrecks.Used} YELLOW wrecks remain in this area."
			}
			else
			{
				echo "EVESalvage->SalvageArea::  - Salvaging complete -- looking for loot..."
				if (${LootCans})
					call CheckForLoot 0		
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
	
	return	
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Transfer all salvaged items to the station hanger present when this function is called
function TransferSalvagedItemsToHangar()
{	
		variable iterator ThisCargo
	
		; Currently, this function only supports unloading to a station hangar
		if (!${Me.InStation})
		{
			return
		}	
	
    wait 10
    call OpenShipCargo
		wait 20

		if !${EVEWindow[hangarFloor](exists)}
		{
			EVE:Execute[OpenHangarFloor]
			wait 30
		}
					
		MyShip:GetCargo[MyCargo]
		if (${MyCargo.Used} == 0)
		{
			call CloseShipCargo
			wait 10
			call OpenShipCargo
			wait 10
			MyShip:GetCargo[MyCargo]
		}					
						
		
		NewCargoToTransfer:Clear[]
		MyCargo:GetIterator[ThisCargo]
		if ${ThisCargo:First(exists)}
		do
		{
			variable int GroupID
			variable string Name

			GroupID:Set[${ThisCargo.Value.GroupID}]
			Name:Set[${ThisCargo.Value.Name}]

			;echo "EVESalvage->UnloadSalvage[DEBUG]::  TransferSalvagedItemsToHangar: GroupID: ${GroupID} ${Name} - ${ThisCargo.Value.Quantity}"			
			switch ${GroupID}
			{
				case 754
					NewCargoToTransfer:Insert[${ThisCargo.Value.ID}]
					break
				default
					break
			}
		}
		while ${ThisCargo:Next(exists)}

		if ${NewCargoToTransfer.Used} > 0
		{
			;; Note:  When moving to "Hangar" the ID# parameter is unused.  So, any positive integer will work.
			EVE:MoveItemsTo[NewCargoToTransfer, 1, Hangar]
		}

		NewCargoToTransfer:Clear[]
 
    ; After everything is done ...let's clean up the stacks.
    Me.Station:StackAllHangarItems
    wait 5
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Transfer all looted items to the station hanger present when this function is called
;; (NOTE:  This function will only transfer those items looted since the library was initialized, 
;;         not everything that is in the ship's cargo hold.)
function TransferLootToHangar()
{	
		variable iterator ThisCargo
	
		; Currently, this function only supports unloading to a station hangar
		if (!${Me.InStation})
		{
			return
		}	
	
    wait 10
    call OpenShipCargo
		wait 20
		
		if !${EVEWindow[hangarFloor](exists)}
		{
			EVE:Execute[OpenHangarFloor]
			wait 30
		}
					
		if (${CargoholdLoot.Used} < 1)
		{
			echo "EVESalvage->UnloadLoot::  EVESalvage does not have a record of any 'loot' that needs to be transferred.  This is probably the result of the script having been started (or restarted)"
			echo "                          after the loot was acquired.   EVESalvage only moves items that it 'remembers' having looted."
			return
		}
		else
			echo "EVESalvage->UnloadLoot::  Moving ${CargoholdLoot.Used} items"
		
		
		MyShip:GetCargo[MyCargo]
		if (${MyCargo.Used} == 0)
		{
			call CloseShipCargo
			wait 10
			call OpenShipCargo
			wait 20
			MyShip:GetCargo[MyCargo]
		}

		NewCargoToTransfer:Clear
		MyCargo:GetIterator[ThisCargo]
		if ${ThisCargo:First(exists)}
		do
		{
			;echo "EVESalvage->UnloadLoot[DEBUG]::  TransferLootToHanger: CargoholdLoot.Element[ThisCargo.Value.ID]: ${CargoholdLoot.Element[${ThisCargo.Value.ID}]}"
			if (${CargoholdLoot.Element[${ThisCargo.Value.ID}](exists)})
				NewCargoToTransfer:Insert[${ThisCargo.Value.ID}]
		}
		while ${ThisCargo:Next(exists)}

		if ${NewCargoToTransfer.Used} > 0
		{
				;; Note:  When moving to "Hangar" the ID# parameter is unused.  So, any positive integer will work.
     			EVE:MoveItemsTo[NewCargoToTransfer, 1, Hangar]
		}

		;; OLD METHOD
		;if ${CargoToTransfer.Used} > 0
		;{
		;	variable iterator CargoIterator
		;	CargoToTransfer:GetIterator[CargoIterator]
		;	
		;	if ${CargoIterator:First(exists)}
		;	do
		;	{
		;		;echo "TransferLootToHangar: Unloading Loot: ${CargoIterator.Value.Name}"
		;		CargoIterator.Value:MoveTo[Hangar]
		;		wait 30
		;	}
		;	while ${CargoIterator:Next(exists)}
		;}

		NewCargoToTransfer:Clear
 
    ; After everything is done ...let's clean up the stacks.
    Me.Station:StackAllHangarItems
    wait 5
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; If the ship's cargo hold is full, deal with it
;; (NOTE:  This function is not very good right now.  Overhaul coming soon...)
function CheckShipIsFull(bool LootCans, bool IgnoreCapacity)
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
	  
		if (${EVE.Bookmark["Salvager Home Base"](exists)})
		{
		 	; make a temp bookmark, return us to our salvage home, unload, and go back for more
		 	echo "EVESalvage->CheckShipIsFull::  Cargo Hold Full:  Returning to station to unload...
			EVE:CreateBookmark["tmp-looting"]
		  
		  ; Close cargo hold!
		  call CloseShipCargo
			
			if (!${EVE.Bookmark["Salvager Home Base"].SolarSystemID.Equal[${Me.SolarSystemID}]})
			{
				echo "EVESalvage->CheckShipIsFull::  - Setting destination and activating auto pilot for return to home station"
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
 				do
 				{
 				   wait 10
 				}
 				while !${Me.ToEntity.IsCloaked}
			}
   			
			;;; Warp to location
			echo "EVESalvage->CheckShipIsFull::  - Warping to home base location"
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
					      echo "EVESalvage->CheckShipIsFull::  -- Docking atttempt failed ... trying again."
					      ;EVE.Bookmark[${Destination}].ToEntity:Dock
					      Entity[CategoryID = 3]:Dock
					      Counter:Set[0]
					   }
					}
					while (!${Me.InStation})					
				}
			}
			
		 	;;; If we're in a station, unload all "salvaged" items and Loot ;;;;;;;;;;;;;;
		 	wait 10
		 	echo "EVESalvage->CheckShipIsFull::  -- Unloading Salvaged Items..."
		  		call TransferSalvagedItemsToHangar
		 	wait 2
		 	if ${LootCans}
		 	{
		 		echo "EVESalvage->CheckShipIsFull::  -- Unloading Looted Items..."
		 		call TransferLootToHangar
		 	}
		 	call CloseShipCargo
		 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	 
		 
			;;; Now it's time to head back out to the site
			if ${Me.InStation}
			{
			   echo "EVESalvage->CheckShipIsFull::  -- Undocking from station..."
			   EVE:Execute[CmdExitStation]	
			   wait 150
			   UndockCounter:Set[0]
			   if (${Me.InStation})
			   {
			   		do
			   		{
			   			wait 20
			   			UndockCounter:Inc[20]
			   			if (${UndockCounter} > 300)
			   			{
			   			  echo "EVESalvage->CheckShipIsFull::  --- Undocking atttempt failed ... trying again." 
			   				EVE:Execute[CmdExitStation]
			   				UndockCounter:Set[0]
			   			}	   			   			
			   		}
			   		while (${Me.InStation} || !${EVEWindow[Local](exists)} || !${Me.InStation(exists)})
			   }
			   wait 5
			   LeftStation:Set[TRUE]
			}
			
			if (!${EVE.Bookmark["tmp-looting"](exists)})
			{
				do
				{
					wait 10
				}
				while !${EVE.Bookmark["tmp-looting"](exists)}
			}
			
			;;; Set destination and then activate autopilot (if we're not in that system to begin with)    			
			if (!${EVE.Bookmark["tmp-looting"].SolarSystemID.Equal[${Me.SolarSystemID}]})
			{
			  echo "EVESalvage->CheckShipIsFull::  - Setting Destination and activating auto pilot to resume salvage operation"
			  wait 5
				EVE.Bookmark["tmp-looting"]:SetDestination
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
			
			;;; Warp to location
			echo "EVESalvage->CheckShipIsFull::  - Warping to salvage location..."
			EVE.Bookmark["tmp-looting"]:WarpTo
			wait 120
			do
			{
				wait 20
			}
			while (${Me.ToEntity.Mode} == 3)			
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		  ; delete tmp bookmark, and then we're ready to continue!
		  EVE.Bookmark["tmp-looting"]:Remove
		  
		  echo "EVESalvage->CheckShipIsFull::  Cargo Hold Empty: Resuming Operations..."
		}
		else
		{
			echo "EVESalvage->CheckShipIsFull::  Cargo hold is full; however, you do not seem to have a 'Salvager Home Base' bookmark for unloading.   You're screwed."
			Script:End
			return
		}
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
					if (${IgnoreContraband})
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
			call CheckShipIsFull 1 1
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
		
		EVE:MoveItemsTo[CargoToTransfer, ${MyShip.ID}, CargoHold]
		wait 5
		
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

		return
}
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; If the bookmark "Salvager Home Base" exists, return to it and transfer
;; all salvaged and looted items to the hangar's cargo hold
function ReturnToHomeBase()
{
	
  call CloseShipCargo
  if (${EVE.Bookmark["Salvager Home Base"](exists)})
	{
		echo "EVESalvage->ReturnToHomeBase::  Salvage operations completed .. returning to home base"
		if (!${EVE.Bookmark["Salvager Home Base"].SolarSystemID.Equal[${Me.SolarSystemID}]})
		{
			echo "EVESalvage->ReturnToHomeBase::  - Setting destination and activating auto pilot for return to home base"
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
			echo "EVESalvage->ReturnToHomeBase::  - Warping to home base location"
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
					      echo "EVESalvage->ReturnToHomeBase::  -- Docking atttempt failed ... trying again."
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
		  echo "EVESalvage->ReturnToHomeBase::  --- Unloading Salvaged Items..."
		 	call TransferSalvagedItemsToHangar
		 	wait 2
		 	if (${DoLoot})
		 	{
		 		echo "EVESalvage->ReturnToHomeBase::  ----- Unloading Looted Items..."
		 		call TransferLootToHangar
		 	}
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
	if !${LeftStation}
	{
		if ${Me.InStation}
		{
			   ;; First, make sure we have a bookmark labeled "Salvager Home Base" -- otherwise, create it ;;;;;;;;;;;;;

			   if !${EVE.Bookmark["Salvager Home Base"](exists)}
			   {
			   		echo "EVESalvage->LeaveStation::  - Creating 'Salvager Home Base' bookmark..."
			  		EVE:CreateBookmark["Salvager Home Base"]
			  		wait 10
			 	 }

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
		   LeftStation:Set[TRUE]
		}
		else
		{
			 if (!${StopAfterSalvaging} && !${EVE.Bookmark["Salvager Home Base"](exists)})
			 {
		   		echo "EVESalvage.CONFIG::  WARNING: EVESalvage has detected that you are not in a station and that you do not have a bookmark labeled 'Salvager Home Base'.   This means that the"
		   		echo "EVESalvage.CONFIG::           script will end without returning to a station to unload.  You can change this by starting in a station (the script will create the bookmark for you"
		   		echo "EVESalvage.CONFIG::           or create the bookmark manually while in the station you want to use as your 'home base'"
		   		StopAfterSalvaging:Set[TRUE]
		   		echo "EVESalvage.CONFIG::  This script will immediately end after salvaging has finished."
		   }				
		}
		wait 1
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