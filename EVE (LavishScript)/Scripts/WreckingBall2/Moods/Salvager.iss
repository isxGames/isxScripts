objectdef Salvager
{
	variable bool StillGoing = TRUE
	variable bool DoUnload = FALSE
	
	variable int MaxRange
	variable int SalvRange = 5000
	variable int CurrentLocation = 0
	
	variable collection:string Tractors
	variable collection:int64 Salvagers
	variable string Afterburner
	variable string SensorBooster
	variable string CloakingUnit
	
	variable collection:int64 Wrecks
	variable index:int64 Targets
	
	variable index:string Locations
	variable string SafeSpot
	
	variable string Stage

	function Begin()
	{
		CurrentLocation:Set[0]
		DoUnload:Set[FALSE]
		if !INSPACE
		{
			Stage:Set[Docked]
		}
		else
		{
			Stage:Set[Salvaging]
			if ${Tractors.Used} < 1 || ${Salvagers.Used} < 1
			{
				This:GetModules
				if ${Tractors.Used} < 1 && ${Salvagers.Used} < 1
				{
					echo "No Modules - ${Tractors.Used} - ${Salvagers.Used}"
					Debug:Spew["${Tractors.Used} - ${Salvagers.Used}", "StartUpNoModules", TRUE]
					return
				}
			}
		}
		
		This:GetBookmarks
		if ${Locations.Used} < 1 && !INSPACE
		{
			echo "No Bookmarks and Docked"
			Debug:Spew["${Locations.Used} - !INSPACE", "StartUpNoBMs", TRUE]
		}
		if ${SafeSpot.Length} < 1 && !INSPACE && ${GoSafe}
		{
			Debug:Spew["${SafeSpot.Length} - !INSPACE - ${GoSafe}", "StartUpNoHomeBM", TRUE]
			EVE:CreateBookmark["${HomeBookmarkSymbol} Home"]
			This:GetBookmarks
		}
		
		Debug:Spew["${Stage}", "Start", FALSE]
		while ${StillGoing}
		{
			switch ${Stage}
			{
				case Docked
					call This.Docked
					break
				case MoveOn
					call This.MoveOn
					break
				case Salvaging
					call This.Salvaging
					if ${StayOn}
						Stage:Set[Salvaging]
					break
				case GoSafe
					call This.GoSafe
					break
			}
		State:Set[${Stage}]
		}
		if ${CloakingUnit.Length} > 0
			call Ship.Activate ${CloakingUnit}, TRUE
	}
	
	function Docked()
	{
		call Ship.Unload Hangar
		Stage:Set[MoveOn]
		
		if ${DoUnload}
			DoUnload:Set[FALSE]
		else
			CurrentLocation:Inc
			
		if ${CurrentLocation} > ${Locations.Used}
			StillGoing:Set[FALSE]
		
		if ${StillGoing}
		{
			call Ship.Undock
			if ${Tractors.Used} < 1 || ${Salvagers.Used} < 1 
			{
				This:GetModules
				if ${Tractors.Used} < 1 && ${Salvagers.Used} < 1
				{
					echo "No Modules - ${Tractors.Used} - ${Salvagers.Used}"
					Debug:Spew["${Tractors.Used} - ${Salvagers.Used}", "FirstUndockNoModules", TRUE]
					call Ship.Goto ${SafeSpot}
					StillGoing:Set[FALSE]
				}
			}
		}
	}
	
	function MoveOn()
	{
		Debug:Spew["${CurrentLocation} - ${Locations.Used}", "MoveOn", FALSE]
		if ${CurrentLocation} > ${Locations.Used}
		{
			Debug:Spew["${SafeSpot.Length} - ${GoSafe}", "NoMoreLocs", FALSE]
			if ${SafeSpot.Length} > 0 && ${GoSafe}
				Stage:Set[GoSafe]
			else
				StillGoing:Set[FALSE]
			
			return
		}
		call Ship.Goto ${Locations.Get[${CurrentLocation}]}
		Stage:Set[Salvaging]
	}
	
	function GoSafe()
	{
		Debug:Spew["${SafeSpot}", "GoSafe", FALSE]
		call Ship.Goto ${SafeSpot}
		if ${DoUnload} && INSPACE
		{
			Debug:Spew["${DoUnload} - INSPACE", "CantUnload", TRUE]
			StillGoing:Set[FALSE]
		}
		elseif INSPACE
			StillGoing:Set[FALSE]
		else
		{
			Stage:Set[Docked]
			return
		}
		if ${CloakingUnit.Length} > 0
			call Ship.Activate ${CloakingUnit}, TRUE
	}
	
	function Salvaging()
	{
		variable int64 Approach = ${Me.ToEntity.ID}
		variable bool Approaching = FALSE
		variable bool Afterburning = FALSE
		variable int i
		variable string ChickenCheck
		variable iterator Iter
		
		call Ship.OpenCargo
		
		ChickenCheck:Set[${Chicken.Safe}]
		if ${ChickenCheck.Find[Null]} < 1
			call Chicken.DoChicken ${SafeSpot}, ${ChickenCheck}
		
		if ${SensorBooster.Length} > 0
		if !MODACTIVATED(${SensorBooster})
			call Ship.ActivateModule ${SensorBooster}, TRUE
		
		This:GetEntities
		Debug:Spew["Start - ${Wrecks.Used}", "StartSalvage - ${Wrecks.Used}", FALSE]
		
		if ${Wrecks.Used} > 0
		while ${Wrecks.Used} > 0
		{
			while SHIPMODE == WARPING
				wait RANDOM(SLOW, SLOW)
			
			;Approach management next 4 if's
			if ENTDISTANCE(${Approach}) < ${MaxRange}
				Approach:Set[${This.Approachable}]
			
			if ENTDISTANCE(${Approach}) > ${MaxRange} && !${Approaching}
			{
				call Ship.Approach ${Approach}
				Approaching:Set[TRUE]
			}
			
			if ENTDISTANCE(${Approach}) < ${MaxRange} && ${Approaching}
			{
				STOPSHIP()
				Debug:Spew["ENTDISTANCE(${Approach}) - ${MaxRange} - ${Approaching}", "StopShip", FALSE]
				Approaching:Set[FALSE]
			}
			
			if ${Approaching}
			{
				if CAPACITOR > 60 && !${Afterburning}
				{
					call Ship.ActivateModule ${Afterburner}, TRUE
					Afterburning:Set[TRUE]
				}
				elseif CAPACITOR < 40 && ${Afterburning}
				{
					Afterburning:Set[FALSE]
					call Ship.ActivateModule ${Afterburner}, FALSE
				}
			}
			elseif ${Afterburning}
			{
				Afterburning:Set[FALSE]
				call Ship.ActivateModule ${Afterburner}, FALSE
			}
			
			
			ChickenCheck:Set[${Chicken.Safe}]
			if ${ChickenCheck.Find[Null]} < 1
				call Chicken.DoChicken ${SafeSpot}, ${ChickenCheck}
			
			This:GetEntities
			
			;Lock wreck
			if ${Wrecks.FirstValue(exists)} && ALLTARGETS < MAXTARGETS
			do
			{
				if ENTHASBEENLOCKED(${Wrecks.CurrentValue}) || ENTDISTANCE(${Wrecks.CurrentValue}) > ${MaxRange}
					continue
				elseif ENTGROUP(${Wrecks.CurrentValue}) == ENTGROUPCARGO && ENTDISTANCE(${Wrecks.CurrentValue}) < LOOTRANGE
					continue
				elseif ${Entity[${Wrecks.CurrentValue}].Name.Find[entity]} > 0
					continue
				else
				{
					Debug:Spew["ENTNAME(${Wrecks.CurrentValue})", "Lock", FALSE]
					LOCK(${Wrecks.CurrentValue})
					i:Set[RANDOM(SLOWQ,SLOWH)]
					while ${i:Dec} > 0
						waitframe
				}
			}
			while ${Wrecks.NextValue(exists)} && ALLTARGETS < MAXTARGETS
			
			;Loot wreck
			if ${Wrecks.FirstValue(exists)} && ${Looting}
			do
			{
				
				if ENTDISTANCE(${Wrecks.CurrentValue}) < LOOTRANGE && !WRECKEMPTY(${Wrecks.CurrentValue})
				{
					Debug:Spew["ENTDISTANCE(${Wrecks.CurrentValue}) - !WRECKEMPTY(${Wrecks.CurrentValue})", "Loot", FALSE]
					call Ship.GetLoot ${Wrecks.CurrentValue}
				}
			}
			while ${Wrecks.NextValue(exists)}
			
			;Target and Module management
			This:GetTargets
			Targets:GetIterator[Iter]
			if ${Iter:First(exists)}
			do
			{
				State:Set["Wrecks - ${Wrecks.Used}"]
				ChickenCheck:Set[${Chicken.Safe}]
				if ${ChickenCheck.Find[Null]} < 1
					call Chicken.DoChicken ${SafeSpot}, ${ChickenCheck}
				
				;Tractors on
				if ENTDISTANCE(${Iter.Value}) > LOOTRANGE
				{
					if ${Tractors.FirstValue(exists)}
					do
					{
						if !MODACTIVATED(${Tractors.CurrentValue}) && !${Tractors.Element[${Iter.Value}](exists)} && ENTEXISTS(${Iter.Value})
						{
							call Ship.MakeActiveTarget ${Iter.Value}
							if ${Return} > 90
								continue
							call Ship.ActivateModule ${Tractors.CurrentValue}, TRUE
							Tractors:Set[${Iter.Value}, ${Tractors.CurrentValue}]
							Tractors:Erase[${Tractors.CurrentKey}]
							break
						}
					}
					while ${Tractors.NextValue(exists)}
				}
				
				;Tractors off
				if ENTDISTANCE(${Iter.Value}) < LOOTRANGE && MODACTIVE(${Tractors.Element[${Iter.Value}]}) && !${Approaching}
					call Ship.ActivateModule ${Tractors.Element[${Iter.Value}]}, FALSE
				
				;Salvagers on
				if ENTDISTANCE(${Iter.Value}) < ${SalvRange} && ENTGROUP(${Iter.Value}) != ENTGROUPCARGO
				{
					if ${Salvagers.FirstKey(exists)}
					do
					{
						if !MODACTIVATED(${Salvagers.CurrentKey}) && ENTEXISTS(${Iter.Value})
						{
							call Ship.MakeActiveTarget ${Iter.Value}
							if ${Return} > 90
								continue
							call Ship.ActivateModule ${Salvagers.CurrentKey}, TRUE
							break
						}
					}
					while ${Salvagers.NextKey(exists)}
				}
			}
			while ${Iter:Next(exists)}
			if CARGOPCT > 80
				break
		}
		STACKCARGOITEMS()
		Stage:Set[MoveOn]
		if CARGOPCT > 80 && ${GoSafe}
		{
			Stage:Set[GoSafe]
			DoUnload:Set[TRUE]
			Debug:Spew["CARGOPCT - 80", "CargoFull", FALSE]
		}
		elseif !${GoSafe}
		{
			if ${Entity[GroupID,ENTGROUPACCELGATE](exists)}
			{
				Entity[GroupID,ENTGROUPACCELGATE]:Approach
				wait RANDOM(SLOW,SLOW)
				call Ship.ActivateModule ${Afterburner}
				Debug:Spew["${Entity[GroupID,ENTGROUPACCELGATE](exists)}", "ApproachGate", FALSE]
			}
			Debug:Spew[" ", "Done", FALSE]
			StillGoing:Set[FALSE]
		}
		elseif ${RemoveBookmarks} && !${Looped}
		{
			BMREMOVE(${Locations.Get[${CurrentLocation}]})
			CurrentLocation:Inc
			Debug:Spew["${CurrentLocation}", "RemoveLocation NextSpot", FALSE]
		}
		else
		{
			CurrentLocation:Inc
			Debug:Spew["${CurrentLocation}", "NextSpot", FALSE]
		}
	}
	
	;;;;;;;;;;;;;;;;;;;;;;;********************************;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Utils
	
	member:int64 Approachable()
	{
		if ${Wrecks.FirstValue(exists)}
		do
		{
			if ENTDISTANCE(${Wrecks.CurrentValue}) > ${MaxRange}
				return ${Wrecks.CurrentValue}
		}
		while ${Wrecks.NextValue(exists)}
		return ${Me.ToEntity.ID}
	}
	
	method GetTargets()
	{
		variable index:entity MyTargets
		variable iterator Iter
		Targets:Clear
		
		Me:DoGetTargets[MyTargets]
		MyTargets:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			Targets:Insert[${Iter.Value}]
		}
		while ${Iter:Next(exists)}
	}
	
	method GetModules()
	{
		variable index:module Modules
		variable iterator Iter
		
		Tractors:Clear
		Salvagers:Clear
		Afterburner:Set[NULL]
		SensorBooster:Set[NULL]
		CloakingUnit:Set[NULL]
		
		MyShip:DoGetModules[Modules]
		Modules:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ${Iter.Value.ToItem.GroupID} == ITMGROUPTRACTOR
			{
				Tractors:Set[${Iter.Value.ToItem.ID},${Iter.Value.ToItem.Slot}]
				if ${MaxRange} < 1
				{
					if ${Iter.Value.OptimalRange} >= TARGETINGRANGE
						MaxRange:Set[TARGETINGRANGE]
					else
						MaxRange:Set[${Iter.Value.OptimalRange}]	
				}
			}
			elseif ${Iter.Value.ToItem.GroupID} == ITMGROUPSALVAGER
			{
				Salvagers:Set[${Iter.Value.ToItem.Slot},${Iter.Value.ToItem.ID}]
				if ${Iter.Value.OptimalRange} > ${SalvRange}
					SalvRange:Set[${Iter.Value.OptimalRange}]
			}
			elseif ${Iter.Value.ToItem.GroupID} == ITMGROUPAFTERBURNER || ${Iter.Value.ToItem.GroupID} == ITMGROUPMICROWARPDRIVE
				Afterburner:Set[${Iter.Value.ToItem.Slot}]
			elseif ${Iter.Value.ToItem.GroupID} == ITMGROUPSENSORBOOSTER
				SensorBooster:Set[${Iter.Value.ToItem.Slot}]
			elseif ${Iter.Value.ToItem.GroupID} == ITMGROUPCLOAKINGUNIT
				CloakingUnit:Set[${Iter.Value.ToItem.Slot}]
		}
		while ${Iter:Next(exists)}
	}
	
	method GetBookmarks()
	{
		variable index:bookmark Bookmarks
		variable iterator Iter
		
		Locations:Clear
		SafeSpot:Set[NULL]
		
		EVE:DoGetBookmarks[Bookmarks]
		Bookmarks:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ${Iter.Value.Label.Find[${BookmarkSymbol}]} > 0
				Locations:Insert[${Iter.Value.Label}]
			elseif ${Iter.Value.Label.Find[${HomeBookmarkSymbol}]} > 0
				SafeSpot:Set[${Iter.Value.Label}]
		}
		while ${Iter:Next(exists)}
	}
	
	method GetEntities()
	{
		variable index:entity MyEntities
		variable iterator Iter
		
		Wrecks:Clear
		
		EVE:DoGetEntities[MyEntities]
		MyEntities:GetIterator[Iter]
		if ${Iter:Last(exists)}
		do
		{
			if ${Iter.Value.GroupID} == ENTGROUPWRECK || ${Iter.Value.GroupID} == ENTGROUPCARGO
			if ${Iter.Value.HaveLootRights}
				Wrecks:Set[${Iter.Value.ID}, ${Iter.Value.ID}]
		}
		while ${Iter:Previous(exists)}
	}
}