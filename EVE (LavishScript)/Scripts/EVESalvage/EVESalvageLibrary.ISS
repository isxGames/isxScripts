;; Declare all script or global variables here
variable(script) int TractorBeamCount
variable(script) int SalvagerCount
variable(script) int AfterburnerCount
variable(script) index:module AllModules
variable(script) index:module TractorBeams
variable(script) index:module Salvagers
variable(script) index:module Afterburners
variable(script) index:item MyCargo
variable(script) index:item CargoToTransfer
variable(script) index:int64  NewCargoToTransfer
variable(script) int MaxSalvageRange
variable(script) int MaxTractorRange
variable(script) index:entity Wrecks
variable(script) int MaxTargets
variable(script) int MaxTargetRange
variable(script) index:entity Targets
variable(script) bool ContinueOn
variable(script) bool alreadyTractoring
variable(script) bool allCansProcessed
variable(script) index:entity Cans
variable(script) index:entity NearbyCans
variable(script) int EntityCargoCount
variable(script) index:item EntityCargo
variable(script) collection:int64 ProcessedEntities
variable(script) collection:int64 CargoholdLoot
variable(script) bool LibraryInitialized

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

function OpenCargo()
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

function CloseCargo()
{
	if ${EVEWindow[MyShipCargo](exists)}
	{
		echo "CLOSE ----- Closing Ship Cargohold"
		EVEWindow[MyShipCargo]:Close
		wait 15
		while ${EVEWindow[MyShipCargo](exists)}
		{
			wait 0.5
		}
		wait 10
	}
}

function DoGetLoot(bool InReachOnly)
{
	variable int i = 1
	variable int k
	variable int j
	
  
  ;;; Get loot within reach no matter what, but get all of it before thinking about moving around!!
	i:Set[1]
	EVE:QueryEntities[NearbyCans, Name =- "Cargo Container" && Distance <= 2500]
	if ${NearbyCans.Used} > 0
	{
		echo "LOOT -     Looting: ${NearbyCans.Used} cargo containers found, processing..."
		do
		{
			if (!${NearbyCans[${i}].HaveLootRights})
			{
				i:Inc
				continue
			}	 	

			; If we've already processed this can, then we want to ignore it.
			if (${ProcessedEntities.Element[${NearbyCans[${i}].ID}](exists)})
			{
				i:Inc
				continue
			}

			ProcessedEntities:Set[${NearbyCans[${i}].ID},1]
			echo "LOOT --    Processing: ${NearbyCans[${i}].Name}"

			;; Loot! ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			NearbyCans[${i}]:OpenCargo
			wait 30
			call OpenCargo
			call LootEntity ${NearbyCans[${i}].ID}
			echo "LOOT ---   Stacking cargo..."
			Me.Ship:StackAllCargo
			wait 10				
			;call CloseCargo			
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
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			i:Inc
		}
		while ${i} <= ${NearbyCans.Used}


	
	} 	
  ;;; Now, are we getting loot out of reach too?
	if (!${InReachOnly})
	{
		;;;run until break
		while 1 == 1
		{
			echo "LOOT ##### Start Looting Pulse..."
	
			;;;reload the list to make sure it stays fresh
			i:Set[1]
			EVE:QueryEntities[Cans, Name =- "Cargo Container"]
			
			if (${Cans.Used} == 0)
			{
				echo "LOOT -     No Cans found in this area."
				return
			}
			
			if ${Cans.Used} > 0
			{
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
					;;; all cans processed, break out
					return
				}

				i:Set[1]

				echo "LOOT --    Looting: ${Cans.Used} cargo containers found, processing..."
				do
				{
					if (!${Cans[${i}].HaveLootRights})
					{
						i:Inc
						continue
					}	 	

					if (${ProcessedEntities.Element[${Cans[${i}].ID}](exists)})
					{
						i:Inc
						continue
					}

					;;;lock em up, and tractor them in, 

					; Lock up to max targets
					while (${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}]} < ${MaxTargets})
					{

						echo "LOOT -     ${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}].Precision[0]} Targets Acquired/Acquiring of ${MaxTargets} max or ${Cans.Used} available."

						; Make sure we're not already targetting this wreck...
						Me:GetTargets[Targets]
						k:Set[1]

						if (${Targets.Used} > 0)
						{
							do
							{
								if ${Targets[${k}].ID.Equal[${Cans[${i}].ID}]} 
								{
								   i:Inc
								   continue
								}		
								wait 2
							}
							while ${k:Inc} <= ${Targets.Used}
						}

						;;; Target
						if (${Cans[${i}].Distance} > ${MaxTargetRange})
						{
							;;; Before moving, lets deal with what we have locked/locking

					    while ${Me.TargetingCount} > 0
					    {
								wait 10
					    }

					    if (${Me.TargetCount} == 0)
					    {
						    echo "LOOT ---   ${Wrecks[${i}].Name} too far away to target :: Approaching..."
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
								echo "LOOT ---   ${Cans[${i}].Name} too far away to target :: Handeling current targets before moving..."
								break
						  }
						}
						
						if (!${Cans[${i}].ID(exists)})
							break

						echo "LOOT ---   LockTarget :: ${Cans[${i}].Name}... ${Cans[${i}].GroupID}"
						Cans[${i}]:LockTarget
						wait 10
						i:Inc
					}
					
					do
					{
						wait 10
					}
					while ${Me.TargetingCount} > 0
					echo "**    ${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}].Precision[0]} Targets Acquired"

					;##################################################

					;;; TARGETS ALL LOCKED UP!

					;##################################################


					; lets process the locked targets and tractors on far cans
					; if can is outside of tractor range AND no cans present, move in range
					Me:GetTargets[Targets]
					k:Set[1]
					alreadyTractoring:Set[FALSE]
					while ${k} <= ${Targets.Used} 
					{
						wait 12
						;;; Start off by turning off all tractros for items that are already close enough  ;;;;;;;;
						if (${Targets[${k}].Distance} <= 2500)
						{
							Targets[${k}]:MakeActiveTarget
							;;;start salvager
							echo "LOOT ---   Can in looting range..."
							;; Loot Can ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
							j:Set[1]
							do
							{
								if (${TractorBeams[${j}].IsActive} && !${TractorBeams[${j}].IsDeactivating})
								{
									if (${TractorBeams[${j}].TargetID.Equal[${Targets[${k}].ID}]})
									{
										;;Already tractoring this...
										alreadyTractoring:Set[TRUE]
										if (${Targets[${k}].Distance} <= ${MaxSalvageRange})
										{
											echo "LOOT ----  Close enough now... stop Tractoring..."
											TractorBeams[${j}]:Deactivate
										}
									}
									wait 3
								}	
							}
							while (${j:Inc} <= ${TractorBeamCount})
						}
						;;;move next
						k:Inc 
					}	

					;;; If we shut any off, lets just wait a sec to be sure those are all off before we continue
					if (!${alreadyTractoring} )
						wait 25

					;;;reset K to the begining again
					k:Set[1]
					while ${k} <= ${Targets.Used} 
					{
						wait 10
						echo "LOOT -     Checking target: ${Targets[${k}].Name} "

						;;; Tractor...or else approach and wait for wreck to be in distance ;;;;;;;;
						if (${Targets[${k}].Distance} <= 2500)
						{
							Targets[${k}]:MakeActiveTarget
							echo "LOOT --    Can in range, Start Looting..."
							;; Loot! ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
							Targets[${k}]:OpenCargo
							wait 30
							call OpenCargo
							call LootEntity ${Targets[${k}].ID}
							echo "LOOT ---   Stacking cargo..."
							Me.Ship:StackAllCargo
							wait 10				
							;call CloseCargo		
							if ${Targets[${k}](exists)}
							{
								Targets[${k}]:CloseCargo
								wait 2
								Targets[${k}]:UnlockTarget
								wait 2
							}
							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
						}
						elseif (${Targets[${k}].Distance} <= ${MaxTractorRange})
						{
							Targets[${k}]:MakeActiveTarget
							;;;start Tractoring
							echo "LOOT --    Can in tractor range..."

							;;before turning in tractor, be sure you dont already have one on this target

							j:Set[1]
							alreadyTractoring:Set[FALSE]
							do
							{
								if (${TractorBeams[${j}].IsActive} && !${TractorBeams[${j}].IsDeactivating})
								{
									if (${TractorBeams[${j}].TargetID.Equal[${Targets[${k}].ID}]})
									{
										;;Already tractoring this...
										alreadyTractoring:Set[TRUE]
										echo "            ...already Tractoring"
										if (${Targets[${k}].Distance} <= ${MaxSalvageRange})
										{
											echo "LOOT ---   Can close enough now... stop Tractoring..."
											TractorBeams[${j}]:Deactivate
										}
									}
									wait 1
								}	
							}
							while (${j:Inc} <= ${TractorBeamCount})

							if (!${alreadyTractoring})
							{
								echo "            ...start Tractoring"

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
							echo "LOOT --    Can out of Tractor range..."

							if (${ContinueOn})
							{
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
							}
							echo "LOOT debug: ${ContinueOn}"
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
							echo "LOOT ***** WHAT?!?"
						}


						;;;move next
						k:Inc 

					}
					;;while ${k} <= ${Targets.Used} 		
					i:Inc
				}
				while ${i} <= ${Cans.Used}
			}
		}
	}
}

function DoSalvage(bool LootCans)
{
  variable int i = 1
  variable int j
  variable int k
  variable int l

	call GetModulesInformation ${LootCans}
	if (${MaxTargets} < 1)
	{
		if (${Me.MaxLockedTargets} <= ${Me.Ship.MaxLockedTargets})
			MaxTargets:Set[${Me.MaxLockedTargets}]
		else
			MaxTargets:Set[${Me.Ship.MaxLockedTargets}]
	}
	wait 5
	MaxTargetRange:Set[${Me.Ship.MaxTargetRange}]

	echo "SALV -     Salvager initialized ... "
	wait 5
	
	;;;run until break
	while 1 == 1
	{
		echo "SALV ##### Start Salvage Pulse..."
	
		EVE:QueryEntities[Wrecks,Name =- "wreck" && GroupID == 186]
		i:Set[1]
		
		;; FOR TESTING
		;do
		;{
		;	echo "Wreck ${i}. ${Wrecks[${i}].Name} - Distance: ${Wrecks[${i}].Distance.Precision[2]}"
		;}
		;while ${i:Inc} < ${Wrecks.Used}
		;return

		if (${Wrecks.Used} == 0)
		{
			echo "SALV -     No wrecks found in this area, looking for loot..."
			if (${LootCans})
			{
				;;; when there are no more ships, a final sweep with the long range loot collector
				call DoGetLoot 0		
			}
			return
		}
	
		echo "SALV -     ${Wrecks.Used} wrecks remain in this area."
	
		; Lock up to max targets
		while (${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}]} < ${MaxTargets})
		{	
			echo "SALV -     ${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}].Precision[0]} Targets Acquired/Acquiring of ${MaxTargets} max or ${Wrecks.Used} available."

			; Make sure we're not already targetting this wreck...
			Me:GetTargets[Targets]
			k:Set[1]
				
			if (${Targets.Used} > 0)
			{
				do
				{
					if ${Targets[${k}].ID.Equal[${Wrecks[${i}].ID}]} 
					{
					   i:Inc
					   continue
					}		
					wait 2
				}
				while ${k:Inc} <= ${Targets.Used}
			}
			
			;;; Target
			if (${Wrecks[${i}].Distance} > ${MaxTargetRange})
			{
			    ;;; Before moving, lets deal with what we have locked/locking

			    while ${Me.TargetingCount} > 0
			    {
						wait 10
			    }

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

						; EVE:Execute[CmdStopShip]
						; wait 2
			    }
			    else
			    {
						echo "SALV ---   ${Wrecks[${i}].Name} too far away to target :: Handling current targets before moving..."
						break
			    }
			}

			if (!${Wrecks[${i}].ID(exists)})
				break
				
			echo "SALV ---   LockTarget :: ${Wrecks[${i}].Name}... ${Wrecks[${i}].GroupID}"
			Wrecks[${i}]:LockTarget
			wait 5
			i:Inc
		}
		
		while ${Me.TargetingCount} > 0
		{
			wait 10
		}
		echo "SALV **    ${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount}].Precision[0]} Target(s) Acquired"
		
		;##################################################
		
		;;; TARGETS ALL LOCKED UP!
		
		;##################################################
		
		
		; lets process the locked targets, start by engaging salvagers on close wercks
		; and tractors on far wrecks
		; if wreck is outside of tractor range AND no salvagers active AND no cans present, move in range
		
		wait 2
		Me:GetTargets[Targets]
		k:Set[1]
		alreadyTractoring:Set[FALSE]
		while ${k} <= ${Targets.Used} 
		{
			;;; Start off by turning off all tractros for items that are already close enough  ;;;;;;;;
			if (${Targets[${k}].Distance} <= ${MaxSalvageRange})
			{
				Targets[${k}]:MakeActiveTarget
				;;;start salvager
				echo "SALV ---   Wreck in range, Salvager starting ${Targets[${k}].Name}..."
				;; Salvage ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				j:Set[1]
				do
				{
					if (${TractorBeams[${j}].IsActive} && !${TractorBeams[${j}].IsDeactivating})
					{
						if (${TractorBeams[${j}].TargetID.Equal[${Targets[${k}].ID}]})
						{
							;;Already tractoring this...
							alreadyTractoring:Set[TRUE]
							if (${Targets[${k}].Distance} <= ${MaxSalvageRange})
							{
								echo "SALV ----  Close enough now... stop Tractoring..."
								TractorBeams[${j}]:Deactivate
							}
						}
						wait 1
					}	
				}
				while (${j:Inc} <= ${TractorBeamCount})
			}
			;;;move next
			k:Inc 
			wait 1
		}	
		
		;;; If we shut any off, lets just wait a sec to be sure those are all off before we continue
		if (!${alreadyTractoring} )
			wait 17
				
		;;;reset k to the begining again
		k:Set[1]
		while ${k} <= ${Targets.Used} 
		{
			wait 10
			echo "SALV -     Checking target: ${Targets[${k}].Name} (ID: ${Targets[${k}].ID})"
			
			;;; Tractor...or else approach and wait for wreck to be in distance ;;;;;;;;
			if (${Targets[${k}].Distance} <= ${MaxSalvageRange})
			{
				Targets[${k}]:MakeActiveTarget
				;;;start salvager
				echo "SALV --    Wreck in range, Salvager starting..."
				;; Salvage ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				ContinueOn:Set[FALSE]
				do
				{	
					j:Set[1]
					do
					{
						if (!${Salvagers[${j}].IsActive} && !${Salvagers[${j}].IsDeactivating} && !${ContinueOn})
						{
						  echo "SALV ---   Activating: ${Salvagers[${j}].ToItem.Name}"
							Salvagers[${j}]:Click
							ContinueOn:Set[TRUE]
							wait 3
						}
						wait 2
					}
					while ${j:Inc} <= ${SalvagerCount}
				}
				while !${ContinueOn}
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			}
			elseif (${Targets[${k}].Distance} <= ${MaxTractorRange})
			{
				Targets[${k}]:MakeActiveTarget
				wait 2
				;;;start Tractoring
				echo "SALV --    Wreck in tractor range..."
				
				;;before turning in tractor, be sure you dont already have one on this target
				
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
			elseif (${Targets[${k}].Distance} > ${MaxTractorRange})
			{
				ContinueOn:Set[TRUE]
				echo "SALV --    Wreck out of Tractor range..."
								
				j:Set[1]
				do
				{
					if (${Salvagers[${j}].IsActive})
					{
						echo "SALV ---   Can not approach while salvagers running..."
						ContinueOn:Set[FALSE]
						break
					}
					wait 2
				}
				while ${j:Inc} <= ${SalvagerCount}
				
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
				
				if (${ContinueOn})
				{
					echo "SALV ---    Approaching ..."

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

						echo "SALV ----  Wreck is now within tractor range -- Tractoring..."

						if (${AfterburnerCount} > 0)
						{
							if (${Afterburners[1].IsActive})
							{
								Afterburners[1]:Click
								wait 2
							}
						}
					}
				}
			}
			else
			{
				echo "SALV ----- WHAT?!?"
			}
			
			
			;;;move next
			k:Inc 
			
		}
		;;while ${k} <= ${Targets.Used} 
		
		;##################################################
		;##################################################
		
		;;;all targets are being delt with, are there any other cargo containers nearby??
		if ${LootCans}
		{
			call DoGetLoot 1
		}
		

		;##################################################
		;##################################################
	
		
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
			
		; Make sure we aren't out of cargo space
		call CheckShipIsFull ${LootCans} 0
	} 
	
	
}

function TransferSalvagedItemsToHangar()
{	
    wait 10
    call OpenCargo
		wait 20

		if !${EVEWindow[hangarFloor](exists)}
		{
			EVE:Execute[OpenHangarFloor]
			wait 30
		}
					
		Me.Ship:GetCargo[MyCargo]
		if (${MyCargo.Used} == 0)
		{
			call CloseCargo
			wait 10
			call OpenCargo
			wait 10
			Me.Ship:GetCargo[MyCargo]
		}					
						
		variable iterator ThisCargo
		
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
    wait 10
    call OpenCargo
		wait 20
		
		if !${EVEWindow[hangarFloor](exists)}
		{
			EVE:Execute[OpenHangarFloor]
			wait 30
		}
						
		echo "DEBUG: TransferLootToHangar: ${CargoholdLoot.Used}"		
		Me.Ship:GetCargo[MyCargo]
		if (${MyCargo.Used} == 0)
		{
			call CloseCargo
			wait 10
			call OpenCargo
			wait 20
			Me.Ship:GetCargo[MyCargo]
		}
		
		variable iterator ThisCargo
		
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
		variable int j
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
	 	
	 	; else, make a temp bookmark, return us to our salvage home, unload, and go back for more
	 	echo "FULL -     Cargo Hold Full:  Returning to station to unload...
		EVE:CreateBookmark["tmp-looting"]
	  EVE:GetBookmarks[MyBookmarks]
	  
	  ; Close cargo hold!
	  call CloseCargo
	  
		j:Set[1]
		do
		{
			if (${MyBookmarks[${j}].Label.Find["Salvager Home Base"]} > 0)
			{
				if (!${MyBookmarks[${j}].SolarSystemID.Equal[${Me.SolarSystemID}]})
				{
					echo "FULL --    Setting destination and activating auto pilot for return to home station"
					MyBookmarks[${j}]:SetDestination
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
				MyBookmarks[${j}]:WarpTo
				wait 120
				do
				{
					wait 20
				}
				while (${Me.ToEntity.Mode} == 3)	
				wait 20
				
				;;; Dock, if applicable
				if ${MyBookmarks[${j}].ToEntity(exists)}
				{
					if (${MyBookmarks[${j}].ToEntity.CategoryID.Equal[3]})
					{
						MyBookmarks[${j}].ToEntity:Approach
						do
						{
							wait 20
						}
						while (${MyBookmarks[${j}].ToEntity.Distance} > 50)
						
						MyBookmarks[${j}].ToEntity:Dock
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
			}
		}
		while ${j:Inc} <= ${MyBookmarks.Used}
	 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	 	
	 	
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
	 	call CloseCargo
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

function LootEntity(int64 EntityID)
{	

		Entity[${EntityID}]:GetCargo[EntityCargo]
		
		variable iterator ThisCargo
		
		EntityCargo:GetIterator[ThisCargo]
		if ${ThisCargo:First(exists)}
		do
		{
			variable string Name
			Name:Set[${ThisCargo.Value.Name}]			
			
			CheckLootItemDB:Set[${LootItemsDB.FindSetting["${Name}",FALSE]}]
			LavishSettings[Loot Items Database]:Export[${EVELootingFileName}]
			
			; If the entry in the xml is FALSE, then we want to loot it.
			if (!${CheckLootItemDB})
			{
				CargoToTransfer:Insert[${ThisCargo.Value.ID}]
				;echo "DEBUG: CargoToTransfer.Used == ${CargoToTransfer.Used}
			}
			else
				echo "DEBUG: Ignoring ${Name}"
				
			
			;variable int TypeID
			;TypeID:Set[${ThisCargo.Value.TypeID}]
			
			;switch ${TypeID}
			;{
				; We don't want to loot metal scraps
			;	case 15331
			;		break
			;	default
			;	  CargoToTransfer:Insert[${ThisCargo.Value.ID}]
			;		break
			;}			
		}
		while ${ThisCargo:Next(exists)}

		if ${CargoToTransfer.Used} > 0
		{
			variable iterator CargoIterator
			CargoToTransfer:GetIterator[CargoIterator]
			
			if ${CargoIterator:First(exists)}
			do
			{
			  echo "LOOT ------ Processing: ${CargoIterator.Value.Name}"
			  if (${CargoIterator.Value.Volume} > ${Math.Calc[${Me.Ship.CargoCapacity} - ${Me.Ship.UsedCargoCapacity}]})
			  {
			  	call CheckShipIsFull 1 1	
			  	continue
				}
			
			  if (${Math.Calc[${CargoIterator.Value.Quantity} * ${CargoIterator.Value.Volume}]} > ${Math.Calc[${Me.Ship.CargoCapacity} - ${Me.Ship.UsedCargoCapacity}]})
			  {
				  CargoIterator.Value:MoveTo[MyShip,${Math.Calc[${Math.Calc[${Me.Ship.CargoCapacity} - ${Me.Ship.UsedCargoCapacity}]} / ${CargoIterator.Value.Volume}]}]
					CargoholdLoot:Set[${CargoIterator.Value.ID},1]
					;echo "DEBUG: Added ${CargoIterator.Value.ID} to CargoholdLoot (CargoholdLoot Used now: ${CargoholdLoot.Used})"
				  wait 3
				}
				else
				{
				  CargoIterator.Value:MoveTo[MyShip]
				  CargoholdLoot:Set[${CargoIterator.Value.ID},1]
				  ;echo "DEBUG: Added ${CargoIterator.Value.ID} to CargoholdLoot (CargoholdLoot Used now: ${CargoholdLoot.Used})"
				  wait 3
				}	
				
				call CheckShipIsFull 1 0			
			}
			while ((${CargoIterator:Next(exists)}) && (${Me.Ship.UsedCargoCapacity} < ${Me.Ship.CargoCapacity}))
			wait 2
		}

		CargoToTransfer:Clear[]
    wait 5
}
