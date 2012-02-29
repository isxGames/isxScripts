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
variable(script) index:entity Belts

variable(script) string EVELootingFileName
variable(script) bool CheckLootItemDB
variable(script) settingsetref LootItemsDB
variable(script) filepath EVELootingFilePath

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

function GetModulesInformation(bool LootCans)
{
	variable int k = 1
	TractorBeams:Clear
	Salvagers:Clear
	Afterburners:Clear
	
	;; This function is always called when using the EVESalvageLibrary, so initialize it the first time it's called
	if !${LibraryInitialized}
		call InitializeLibrary ${LootCans}

	;; Determine the modules at our disposal
	echo "INFO - Acquiring Information about your ship's modules..."
	Me.Ship:GetModules[AllModules]
	if (${AllModules.Used} <= 0)
	{
		echo ERROR -- Your ship does not appear to have any modules
		return
	}
	do
	{
   	if (${AllModules[${k}].MaxTractorVelocity} > 0)
   	{
   	  ;echo "Adding ${AllModules[${k}].ToItem.Name} to 'TractorBeams'"
			TractorBeams:Insert[${AllModules[${k}].ID}]
			if ${MaxTractorRange} <= 0
			{
				MaxTractorRange:Set[${AllModules[${k}].OptimalRange}]
				;echo "MaxTractorRange set to: ${MaxTractorRange}"
			}
   	}
   	elseif (${AllModules[${k}].AccessDifficultyBonus} > 0)
   	{
   	  ;echo "Adding ${AllModules[${k}].ToItem.Name} to 'Salvagers'"
   	  Salvagers:Insert[${AllModules[${k}].ID}]
			if ${MaxSalvageRange} <= 0
			{
				MaxSalvageRange:Set[${AllModules[${k}].OptimalRange}]
			}   	  
   	}
   	elseif (${AllModules[${k}].MaxVelocityBonus} > 0)
   	{
   	  ;echo "Adding ${AllModules[${k}].ToItem.Name} to 'Afterburners'"
   	  Afterburners:Insert[${AllModules[${k}].ID}] 	  
   	}   	
	}
	while ${k:Inc} <= ${AllModules.Used}
	
	TractorBeamCount:Set[${TractorBeams.Used}]
	SalvagerCount:Set[${Salvagers.Used}]
	AfterburnerCount:Set[${Afterburners.Used}]
  echo "INFO - Your ship has ${TractorBeamCount} Tractor Beams, ${SalvagerCount} Salvage Modules, and ${AfterburnerCount} Afterburner."
	return
}

function OpenShipCargo()
{
	if !${EVEWindow[MyShipCargo](exists)}
	{
		echo "OPEN ----- Opening Ship Cargohold"
		EVE:Execute[OpenCargoHoldOfActiveShip]
		wait 15
		while !${EVEWindow[MyShipCargo](exists)}
		{
			wait 0.5
		}
		wait 10
	}
}

function CloseShipCargo()
{
	if ${EVEWindow[MyShipCargo](exists)}
	{
		echo "CLOSE ----- Stacking cargo..."
		Me.Ship:StackAllCargo
		wait 10					
		
		echo "CLOSE ----- Closing Ship Cargohold"
		EVEWindow[MyShipCargo]:Close
		wait 15
		while ${EVEWindow[MyShipCargo](exists)}
		{
			wait 0.5
		}
		wait 5
	}
}

function DoGetLoot(bool InReachOnly)
{
	variable int i = 1
	variable int k
	variable int j
	variable bool alreadyTargeted
	
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Loot nearby cans before thinking about those that are out of "looting range"
	i:Set[1]
	EVE:QueryEntities[NearbyCans, Name =- "Cargo Container" && Distance <= 2500 && HaveLootRights = 1]
	if ${NearbyCans.Used} > 0
	{
		echo "LOOT -     Looting: ${NearbyCans.Used} cargo containers found, processing..."
		do
		{
			echo "LOOT --    Processing: ${NearbyCans[${i}].Name}"
			;; If we've already processed this can, then we want to ignore it.
			if (${ProcessedEntities.Element[${NearbyCans[${i}].ID}](exists)})
			{
				i:Inc
				continue
			}
			
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;; Ignore cans for which we do not have loot rights
			;; NOTE:  This should no longer occur since we're now only acquiring the list of cargo containers for which we have loot rights.
			if (!${NearbyCans[${i}].HaveLootRights})
			{
				i:Inc
				ProcessedEntities:Set[${NearbyCans[${i}].ID},1]
				continue
			}	
			;;
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 	
	
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
		EVE:QueryEntities[Cans, Name =- "Cargo Container" && HaveLootRights = 1]
		if (${Cans.Used} == 0)
		{
			echo "LOOT -     No cargo containers (loot) found in this area."
			return
		}
		else
			echo "LOOT --    ${Cans.Used} cargo containers found, processing..."
		
		;;;run until break
		while 1 == 1
		{
			echo echo "LOOT -     ##### Start Loot Pulse #####"
			
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
				echo "LOOT -     All cargo containers (loot) in this area have been processed."
				return
			}		
			;;
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
			
			
			i:Set[1]
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;; Targeting Routine (lock targets until ${MaxTargets} is reached)
			while (${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}]} < ${MaxTargets})
			{
				echo "LOOT -     ${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}].Precision[0]} Targets Acquired/Acquiring of ${MaxTargets} max or ${Cans.Used} available."

				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				;; In case there are fewer cargo containers than our max targets  (otherwise this makes for a neverending loop)
				if (${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}]} >= ${Cans.Used})
				{
					echo "LOOT -     All remaining cargo containers have been targeted.  Processing..."
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
				    	echo "LOOT ---   Waiting for lock on all targets..."
							wait 5
				    }
	
						;;;;;;;;;;;;;;;;;;;;;;;;
						;; Approach
				    if (${Me.TargetCount} == 0)
				    {
				    	echo "LOOT ---   ${Cans[${i}].Name} too far away to target :: Approaching..."
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
							; EVE:Execute[CmdStopShip]
							; wait 2
				    }
				    else
				    {
							echo "LOOT ---   ${Cans[${i}].Name} too far away to target :: Handling current targets before moving..."
							i:Inc
							continue
				    }
				}
				;; END->cargo container out of 'targeting range'
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

				if (!${Cans[${i}].ID(exists)})
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
				
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				;; Ignore cans for which we do not have loot rights
				;; NOTE:  This should no longer occur since we're now only acquiring the list of cargo containers for which we have loot rights.
				if (!${Cans[${i}].HaveLootRights})
				{
					echo "LOOT ---   You do not have loot rights for ${Cans[${i}].Name} -- skipping..."
					i:Inc
					ProcessedEntities:Set[${Cans[${i}].ID},1]
					continue
				}	 		
				;;
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
			
				;; Otherwise, lock the target and go on to the next 'can' in the array!
				echo "Loot ---   LockTarget :: ${Cans[${i}].Name}... ${Cans[${i}].GroupID}"
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
				echo "LOOT ---   Waiting for lock on all targets..."
				while ${Me.TargetingCount} > 0
				{
					wait 5
				}
			}
			echo "LOOT **    ${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}].Precision[0]} Target(s) Acquired"
			
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
				wait 12
				if (!${Targets[${k}](exists)})
				{
					k:Inc
					continue
				}		
			
				if (${Targets[${k}].Distance} <= 2500)
				{
					Targets[${k}]:MakeActiveTarget
					echo "LOOT ----  ${Targets[${k}].Name} is close enough now.  Disengaging tractor beams..."

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
					echo "LOOT --    ${Targets[${k}].Name} in range, Start Looting..."
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
				if (!${Targets[${k}](exists)})
				{
					k:Inc
					continue
				}
				echo "LOOT -     Checking target: ${Targets[${k}].Name} (ID: ${Targets[${k}].ID})"

				;;;;;;;;;;;;;;;;;;;;;;;
				;; (Note:  Cargo containers that are within Salvage Range were already handled)
				if (${Targets[${k}].Distance} <= 2500)
				{
					echo "LOOT --    Cargo container already within loot range.  Looting should take place soon."
					k:Inc
					continue
				}
				;;;;;;;;;;;;;;;;;;;;;;;
				;; Tractor wreck if it's close enough to be tractored
				if (${Targets[${k}].Distance} <= ${MaxTractorRange})
				{
					Targets[${k}]:MakeActiveTarget
					wait 2
					echo "LOOT --    Cargo container in tractor range..."

					;;;;;;;;;;;;;;;;;;;;;;;
					;; Before engaging tractor beam on this target, make sure that it doesn't already have one active on it.
					j:Set[1]
					alreadyTractoring:Set[FALSE]
					do
					{
						if (${TractorBeams[${j}].IsActive} && !${TractorBeams[${j}].IsDeactivating})
						{
							;echo "LOOT[DEBUG] --    Tractor Beam [${TractorBeams[${j}].ID}]-${TractorBeams[${j}].ToItem.Name} is active and is not deactivating"
							if (${TractorBeams[${j}].TargetID.Equal[${Targets[${k}].ID}]})
							{
								;echo "LOOT[DEBUG] --    Tractor Beam [${TractorBeams[${j}].ID}]-${TractorBeams[${j}].ToItem.Name}'s TargetID is ${TractorBeams[${j}].TargetID}"
								;;Already tractoring this...
								alreadyTractoring:Set[TRUE]
								echo "LOOT ---    ...already Tractoring"
								if (${Targets[${k}].Distance} <= 2500)
								{
									echo "LOOT ---    cargo container close enough now... stop Tractoring..."
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
						echo "LOOT ---    ...start Tractoring"
									
						;; Activate Tractor Beam...
						j:Set[1]
						do
						{
							if (!${TractorBeams[${j}].IsActive} && !${TractorBeams[${j}].IsDeactivating} )
							{
							  echo "LOOT ----  Activating: ${TractorBeams[${j}].ToItem.Name}"
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
					echo "LOOT --    cargo container out of tractor range..."
					
					;;;;;;;;;;;;;;;;;;;;;;;
					;; Ensure that we do not move unless we're positive there are no other cargo containers that are within 2500 of our current location
				  EVE:QueryEntities[NearbyCans, Name =- "Cargo Container" && Distance <= 2500]
				  if ${NearbyCans.Used} > 0
				  {
						l:Set[1]
						do
						{
							if (!${NearbyCans[${l}].HaveLootRights})
							{
								l:Inc
								continue
							}	 
							echo "LOOT ---   Can not approach while jet cans near by..."
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
						echo "LOOT ---   Approaching ..."

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

							echo "LOOT ----  Can is now within tractor range..."

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
					echo "LOOT ***** WHAT?!?"
				}

				;; Now we check the next locked target
				k:Inc 
			}
			;; END LOOP (current locked targets)  ["while ${k} <= ${Targets.Used}"]
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
			
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
			;; Repopulate Cans with updated data
			EVE:QueryEntities[Cans, Name =- "Cargo Container"]
			if (${Cans.Used} == 0)
			{
				echo "LOOT -     All cargo containers have been processed."
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

function DoSalvage(bool LootCans)
{
  variable int i = 1
  variable int j
  variable int k
  variable int l
  variable bool alreadyTargeted
  variable bool FirstTime = TRUE
  variable bool SalvagingYellowWrecks = FALSE

	call GetModulesInformation ${LootCans}
	if (${MaxTargets} < 1)
	{
		if (${Me.MaxLockedTargets} <= ${Me.Ship.MaxLockedTargets})
			MaxTargets:Set[${Me.MaxLockedTargets}]
		else
			MaxTargets:Set[${Me.Ship.MaxLockedTargets}]
	}
	MaxTargetRange:Set[${Me.Ship.MaxTargetRange}]
	
	echo "SALV -     Salvager initialized ... "
	EVE:QueryEntities[Wrecks,Name =- "wreck" && GroupID == 186 && HaveLootRights = 1]
	if (${Wrecks.Used} == 0)
	{
		if ${SalvageYellowWrecks}
		{
			SalvagingYellowWrecks:Set[TRUE]
			EVE:QueryEntities[Wrecks,Name =- "wreck" && GroupID == 186 && HaveLootRights = 0]
			if (${Wrecks.Used} == 0)
			{
				echo "SALV -     No wrecks found in this area, looking for loot..."
				if (${LootCans})
					call DoGetLoot 0		
				return
			}
			else
				echo "SALV -     ${Wrecks.Used} YELLOW wrecks remain in this area."
		}
		else
		{
			echo "SALV -     No wrecks found in this area, looking for loot..."
			if (${LootCans})
				call DoGetLoot 0		
			return
		}
	}
	else
		echo "SALV -     ${Wrecks.Used} wrecks remain in this area."
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; MAIN LOOP
	while 1 == 1
	{
		echo "SALV -     ##### Start Salvage Pulse #####"
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
		while (${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}]} < ${MaxTargets})
		{	
			echo "SALV -     ${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}].Precision[0]} Targets Acquired/Acquiring of ${MaxTargets} max or ${Wrecks.Used} available."

			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;; In case there are fewer wrecks than our max targets  (otherwise this makes for a neverending loop)
			if (${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}]} >= ${Wrecks.Used})
			{
				echo "SALV -     All remaining wrecks have been targeted.  Processing..."
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
						echo "SALV ---   Waiting for lock on all targets..."
						while ${Me.TargetingCount} > 0
						{
							wait 5
						}
					}

					;;;;;;;;;;;;;;;;;;;;;;;;
					;; Approach
			    if (${Me.TargetCount} == 0)
			    {
			    	echo "SALV ---   ${Wrecks[${i}].Name} too far away to target :: Approaching..."
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
						echo "SALV ---   ${Wrecks[${i}].Name} too far away to target :: Handling current targets before moving..."
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
			
			echo "SALV ---   LockTarget :: ${Wrecks[${i}].Name}... ${Wrecks[${i}].GroupID}"
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
			echo "SALV ---   Waiting for lock on all targets..."
			while ${Me.TargetingCount} > 0
			{
				wait 5
			}
		}
		echo "SALV **    ${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}].Precision[0]} Target(s) Acquired"
		
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
			if (!${Targets[${k}](exists)})
			{
				k:Inc
				continue
			}		
			
			if (${Targets[${k}].Distance} <= ${MaxSalvageRange})
			{
				Targets[${k}]:MakeActiveTarget
				echo "SALV ----  ${Targets[${k}].Name} is close enough now.  Disengaging tractor beams..."
				
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
						echo "SALV ---   Wreck in range, Using ${Salvagers[${j}].ToItem.Name} (${Salvagers[${j}].ToItem.ID}) on ${Targets[${k}].Name}..."
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
			wait 10
			if (!${Targets[${k}](exists)})
			{
				k:Inc
				continue
			}			
			echo "SALV -     Checking target: ${Targets[${k}].Name} (ID: ${Targets[${k}].ID})"
			
			;;;;;;;;;;;;;;;;;;;;;;;
			;; (Note:  Wrecks that are within Salvage Range were already handled)
			if (${Targets[${k}].Distance} <= ${MaxSalvageRange})
			{
				echo "SALV --    Wreck already within salvage range.  Salvaging operation should complete soon."
				k:Inc
				continue
			}
			;;;;;;;;;;;;;;;;;;;;;;;
			;; Tractor wreck if it's close enough to be tractored (and if it's not a yellow wreck)
			elseif (${Targets[${k}].Distance} <= ${MaxTractorRange} && ${Targets[${k}].Distance} > ${MaxSalvageRange} && !${SalvagingYellowWrecks})
			{
				Targets[${k}]:MakeActiveTarget
				wait 2
				echo "SALV --    Wreck in tractor range..."
				
				;;;;;;;;;;;;;;;;;;;;;;;
				;; Before engaging tractor beam on this target, make sure that it doesn't already have one active on it.
				j:Set[1]
				alreadyTractoring:Set[FALSE]
				do
				{
					if (${TractorBeams[${j}].IsActive} && !${TractorBeams[${j}].IsDeactivating})
					{
						;echo "SALV[DEBUG] --    Tractor Beam [${TractorBeams[${j}].ID}]-${TractorBeams[${j}].ToItem.Name} is active and is not deactivating"
						if (${TractorBeams[${j}].TargetID.Equal[${Targets[${k}].ID}]})
						{
							;echo "SALV[DEBUG] --    Tractor Beam [${TractorBeams[${j}].ID}]-${TractorBeams[${j}].ToItem.Name}'s TargetID is ${TractorBeams[${j}].TargetID}"
							;;Already tractoring this...
							alreadyTractoring:Set[TRUE]
							echo "SALV ---    ...already Tractoring"
							if (${Targets[${k}].Distance} <= ${MaxSalvageRange})
							{
								echo "SALV ---    Wreck close enough now... stop Tractoring..."
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
					echo "SALV ---    ...start Tractoring"
								
					;; Activate Tractor Beam...
					j:Set[1]
					do
					{
						if (!${TractorBeams[${j}].IsActive} && !${TractorBeams[${j}].IsDeactivating} )
						{
						  echo "SALV ----  Activating: ${TractorBeams[${j}].ToItem.Name}"
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
					echo "SALV --    Wreck out of Tractor range..."
								
				;;;;;;;;;;;;;;;;;;;;;;;
				;; Do not approach if any salvagers are actively running
				ContinueOn:Set[TRUE]
				j:Set[1]
				do
				{
					if (${Salvagers[${j}].IsActive})
					{
						echo "SALV ---   Can not approach while actively salvaging"
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
					  EVE:QueryEntities[Cans, Name =- "Cargo Container"]
					  if ${Cans.Used} > 0
					  {
							l:Set[1]
	
							do
							{
								if (!${Cans[${l}].HaveLootRights})
								{
									l:Inc
									continue
								}	 
	
								if (${Cans[${l}].Distance} <= 2500)
								{		  	
									echo "SALV ---   Can not approach while jet cans present..."
									ContinueOn:Set[FALSE]	
									break
								}
								l:Inc
							}
							while ${l} <= ${Cans.Used}
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
					echo "SALV ---    Approaching Wreck (to within ${MoveWithinDistance}m)..."
					
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
						echo "SALV ----  Wreck is now within ${MoveWithinDistance}m..."

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
									echo "SALV ---   Wreck in range, Using ${Salvagers[${j}].ToItem.Name} (${Salvagers[${j}].ToItem.ID}) on ${Targets[${k}].Name}..."
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
				echo "SALV ----- WHAT?!?"
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
			call DoGetLoot 1
		}
		;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Make sure we're not running low on capacitor
		if (${Me.Ship.CapacitorPct} <= 22)
		{
			echo "SALV !!!!! Running low on Capacitor:  Pausing...
			do
			{
			   wait 30
			}
			while (${Me.Ship.CapacitorPct} <= 22)
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
		EVE:QueryEntities[Wrecks,Name =- "wreck" && GroupID == 186 && HaveLootRights = 1]
		if (${Wrecks.Used} == 0)
		{
			if ${SalvageYellowWrecks}
			{
				SalvagingYellowWrecks:Set[TRUE]
				EVE:QueryEntities[Wrecks,Name =- "wreck" && GroupID == 186 && HaveLootRights = 0]
				if (${Wrecks.Used} == 0)
				{
					echo "SALV -     Salvaging complete -- looking for loot..."
					if (${LootCans})
						call DoGetLoot 0		
					return
				}
				else
					echo "SALV -     ${Wrecks.Used} YELLOW wrecks remain in this area."
			}
			else
			{
				echo "SALV -     Salvaging complete -- looking for loot..."
				if (${LootCans})
					call DoGetLoot 0		
				return
			}
		}
		else
			echo "SALV -     ${Wrecks.Used} wrecks remain in this area."
		;;
		;; This is the end of the Main Salvaging Loop.  This will repeat over and over until there
		;; are no more wrecks in the area.  (which will cause the routine directly above to 'return',
		;; thereby ending the loop.)   
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	} 
	
	return	
}

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
					
		Me.Ship:GetCargo[MyCargo]
		if (${MyCargo.Used} == 0)
		{
			call CloseShipCargo
			wait 10
			call OpenShipCargo
			wait 10
			Me.Ship:GetCargo[MyCargo]
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

			;echo "DEBUG: TransferSalvagedItemsToHangar: GroupID: ${GroupID} ${Name} - ${ThisCargo.Value.Quantity}"			
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
			EVE:MoveItemsTo[NewCargoToTransfer,Hangar]
		}

		;; OLD METHOD
		;
		;if ${CargoToTransfer.Used} > 0
		;{
		;	variable iterator CargoIterator
		;	CargoToTransfer:GetIterator[CargoIterator]
		;	
		;	if ${CargoIterator:First(exists)}
		;	do
		;	{
		;		;echo "obj_Cargo:TransferToHangar: Unloading Cargo: ${CargoIterator.Value.Name}"
		;		CargoIterator.Value:MoveTo[Hangar]
		;		wait 30
		;	}
		;	while ${CargoIterator:Next(exists)}
		;}

		NewCargoToTransfer:Clear[]
 
    ; After everything is done ...let's clean up the stacks.
    Me.Station:StackAllHangarItems
    wait 5
}

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
			echo "UNLOAD ---    EVESalvage does not have a record of any 'loot' that needs to be transferred.  This is probably the result of the script having been started (or restarted)"
			echo "              after the loot was acquired.   EVESalvage only moves items that it 'remembers' having looted."
			return
		}
		else
			echo "UNLOAD ---    Moving ${CargoholdLoot.Used} items"
		
		
		Me.Ship:GetCargo[MyCargo]
		if (${MyCargo.Used} == 0)
		{
			call CloseShipCargo
			wait 10
			call OpenShipCargo
			wait 20
			Me.Ship:GetCargo[MyCargo]
		}

		NewCargoToTransfer:Clear
		MyCargo:GetIterator[ThisCargo]
		if ${ThisCargo:First(exists)}
		do
		{
			;echo "DEBUG: TransferLootToHanger: CargoholdLoot.Element[ThisCargo.Value.ID]: ${CargoholdLoot.Element[${ThisCargo.Value.ID}]}"
			if (${CargoholdLoot.Element[${ThisCargo.Value.ID}](exists)})
				NewCargoToTransfer:Insert[${ThisCargo.Value.ID}]
		}
		while ${ThisCargo:Next(exists)}

		if ${NewCargoToTransfer.Used} > 0
		{
     			EVE:MoveItemsTo[NewCargoToTransfer,Hangar]
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

function CheckShipIsFull(bool LootCans, bool IgnoreCapacity)
{
		variable int k
		variable int UndockCounter
		
		;echo "DEBUG: Math.Calc[Me.Ship.CargoCapacity-Me.Ship.UsedCargoCapacity: ${Math.Calc[${Me.Ship.CargoCapacity}-${Me.Ship.UsedCargoCapacity}]}"
		;echo "DEBUG: Math.Calc[Me.Ship.CargoCapacity*0.01: ${Math.Calc[${Me.Ship.CargoCapacity}*0.01]}"
		
		if !${IgnoreCapacity}
		{
			/* 
			; salvage operation requires a minimum of 40 m^3 free -- so, this is not useful 
			if (${Math.Calc[${Me.Ship.CargoCapacity}-${Me.Ship.UsedCargoCapacity}]} > ${Math.Calc[${Me.Ship.CargoCapacity}*0.01]})
			return
			*/
	   	
	 		if (${Math.Calc[${Me.Ship.CargoCapacity}-${Me.Ship.UsedCargoCapacity}]} > 40)
			{
				return
			}	   	
	 	}
	  
		if (${EVE.Bookmark["Salvager Home Base"](exists)})
		{
		 	; make a temp bookmark, return us to our salvage home, unload, and go back for more
		 	echo "FULL -     Cargo Hold Full:  Returning to station to unload...
			EVE:CreateBookmark["tmp-looting"]
		  
		  ; Close cargo hold!
		  call CloseShipCargo
			
			if (!${EVE.Bookmark["Salvager Home Base"].SolarSystemID.Equal[${Me.SolarSystemID}]})
			{
				echo "FULL --    Setting destination and activating auto pilot for return to home station"
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
			echo "FULL --     Warping to home base location"
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
					      echo "FULL ---   Docking atttempt failed ... trying again."
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
		 	echo "FULL --    Unloading Salvaged Items..."
		  		call TransferSalvagedItemsToHangar
		 	wait 2
		 	if ${LootCans}
		 	{
		 		echo "FULL ---   Unloading Looted Items..."
		 		call TransferLootToHangar
		 	}
		 	call CloseShipCargo
		 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	 
		 
			;;; Now it's time to head back out to the site
			if ${Me.InStation}
			{
			   echo "FULL --    Undocking from station..."
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
			   			  echo "FULL --    Undocking atttempt failed ... trying again." 
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
			  echo "FULL -    Setting Destination and activating auto pilot to resume salvage operation"
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
			echo "FULL -     Warping to salvage location..."
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
		  
		  echo "FULL -    Cargo Hold Empty: Resuming Operations..."
		}
		else
		{
			echo "FULL -    Cargo hold is full; however, you do not seem to have a 'Salvager Home Base' bookmark for unloading.   You're screwed."
			Script:End
			return
		}
}

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
							echo "LootCargoContainer::  Ignoring ${Name} (CONTRABAND)"
							continue
						}
					}
					CargoToTransfer:Insert[${ThisCargo.Value.ID}]
					TotalCargoVolume:Inc[${Math.Calc[${ThisCargo.Value.Quantity} * ${ThisCargo.Value.Volume}]}]
					echo "LootCargoContainer::  Adding ${ThisCargo.Value.Name} (TotalCargoVolume: ${TotalCargoVolume.Precision[2]})"
				}
				else
					echo "LootCargoContainer::  Ignoring ${Name}"	
			}
			while ${ThisCargo:Next(exists)}
		}
		;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Check to make sure the ship's cargo hold has room
		if (${TotalCargoVolume} > ${Math.Calc[${Me.Ship.CargoCapacity} - ${Me.Ship.UsedCargoCapacity}]})
		{
			echo "LootCargoContainer::  Ship Cargo Hold is full."
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
			echo "LootCargoContainer::  Entity either has no items, or else no item(s) pass(es) muster for looting"
			CargoContainer:CloseCargo
			wait 2
			CargoContainer:UnlockTarget
			wait 2			
			return
		}
		else
			echo "LootCargoContainer::  Ready to transfer ${CargoToTransfer.Used} items."
		;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		EVE:MoveItemsTo[CargoToTransfer, MyShip]
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
	
	
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; TODO:  Is any of this still necessary?
		/*
		if ${NearbyCans[${i}](exists)}
		{
			NearbyCans[${i}]:CloseCargo
			wait 2
			Me:GetTargets[Targets]
			k:Set[1]
			if ${Targets.Used} > 0
			{
				do
				{
					if ${Targets[${k}].ID.Equal[${NearbyCans[${i}].ID}]} 
					{
						NearbyCans[${i}]:UnlockTarget
						break
					}		
					wait 2
				}
				while ${k:Inc} <= ${Targets.Used}
			}
		}
		
	
		if ${Targets[${k}](exists)}
		{
			Targets[${k}]:CloseCargo
			wait 2
			Targets[${k}]:UnlockTarget
			wait 2
		}
		*/

		return
}

function ReturnToSalvagerHomeBase()
{
	
  call CloseShipCargo
  if (${EVE.Bookmark["Salvager Home Base"](exists)})
	{
		echo "- Salvage operations completed .. returning to home base"
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
	
	return
}

function LeaveStation()
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
}

function CycleBeltsAndSalvage()
{
	variable iterator AsteroidBelt

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; The caller should ensure that we are in space 
	if ${Me.InStation}
	{
		echo "CycleBelts::  You must be in space to cycle asteroid belts for scavenging."
		return
	}


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Populate 'Belts' for this system  
	EVE:QueryEntities[Belts, Name =- "Asteroid Belt"]
	
	if (${Belts.Used} < 1)
	{
		echo "CycleBelts::  There does not appear to be any asteroid belts in this system."
		return
	}
	else
		echo "CycleBelts::  There are ${Belts.Used} asteroid belts in this system."
	
	Belts:GetIterator[AsteroidBelt]
	if ${AsteroidBelt:First(exists)}
	do
	{
		echo "CycleBelts::  Traveling to ${AsteroidBelt.Value.Name}..."
		
		if (${AsteroidBelt.Value.Distance} > ${EVE.MinWarpDistance})
		{
  		;;; Warp to location
  		echo "CycleBelts::  Warping to ${AsteroidBelt.Value.Name}..."
  		AsteroidBelt.Value:WarpTo
  		wait 120
  		do
  		{
  			wait 20
  		}
  		while (${Me.ToEntity.Mode} == 3)
  	}

  	wait 10
		call DoSalvage ${DoLoot}
	}
	while ${AsteroidBelt:Next(exists)}

}