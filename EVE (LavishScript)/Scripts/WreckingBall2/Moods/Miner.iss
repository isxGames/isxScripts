objectdef Salvager
{
	variable bool StillGoing = TRUE
	variable int MaxRange
	variable string Stage
	
	variable int MiningType = 9999999
	variable int Full = 90
	variable bool UseLastSpot = FALSE
	
	variable collection:string Lasers
	variable string ShieldBooster
	
	variable collection:int64 Asteroids
	variable index:int64 Targets
	
	variable index:string Locations
	variable string SafeSpot
	variable string LastSpot
	variable int CurrentLocation
	
	function Begin()
	{
		This:GetBookmarks
		if ${SafeSpot.Length} < 1 && INSPACE
		{
			echo No Home BM
			return
		}
		elseif !INSPACE && ${SafeSpot.Length} < 1
		{
			EVE:CreateBookmark["${HomeBookmarkSymbol} Home"]
			This:GetBookmarks
		}
		
		if INSPACE && CARGOPCT > 60
			call Ship.Goto ${SafeSpot}
		
		if INSPACE
			Stage:Set[Docked]
		else
			Stage:Set[MoveOn]
		
		while ${StillGoing}
		switch ${Stage}
		{
			case Docked
				call This.Docked
				break
			case MoveOn
				call This.MoveOn
				break
			case Mining
				call This.Mining
				break
		}
	}
	
	function Docked()
	{
		call Ship.Unload Hangar
		Stage:Set[MoveOn]
		
		if ${StillGoing}
		{
			call Ship.Undock
			if ${Lasers.Used} < 1 
			{
				This:GetModules
				if ${Tractors.Used} < 1 && ${Salvagers.Used} < 1
				{
					echo "No Modules - ${Tractors.Used} - ${Salvagers.Used}"
					Debug:Spew["${Tractors.Used} - ${Salvagers.Used}", "StartUpNoModules", TRUE]
					call Ship.Goto ${SafeSpot}
					StillGoing:Set[FALSE]
				}
			}
		}
	}
	
	function MoveOn()
	{
		if ${CurrentLocation} > ${Locations.Used}
		{
			StillGoing:Set[FALSE]
			call Ship.Goto ${SafeSpot}
		}
		else
		{
			if ${UseLastSpot}
				call Ship.Goto ${LastSpot}
			else
			{
				call Ship.Goto ${Locations.Get[${CurrentLocation}]}
				if ${Entity[TypeID, ${MiningType}].Distance} > 150000
				{
					while SHIPMODE != WARPING
					{
						Entity[TypeID, ${MiningType}]:WarpTo
						wait RANDOM(SLOW, SLOW)
					}
					
					while SHIPMODE == WARPING
						wait RANDOM(SLOW, SLOW)
					
					wait RANDOM(SLOW, SLOW)
				}
			}
		}
		
		Stage:Set[Mining]
	}
	
	function Mining()
	{
		variable bool Mining = TRUE
		variable iterator Iter
		
		This:GetEntities
		;;;;;;;;;;;;;;;;;
		if ${Asteroids.Used} > 0
		while ${Mining} && ${Asteroids.Used} > 0
		{
			if CARGOPCT > ${Full}
				break
			
			This:GetEntities
			
			;Lock
			if ${Asteroids.FirstValue(exists)} && ALLTARGETS < MAXTARGETS
			do
			{
				if ENTHASBEENLOCKED(${Asteroids.CurrentValue}) || ENTDISTANCE(${Asteroids.CurrentValue}) > ${MaxRange}
					continue
				elseif ${Entity[${Asteroids.CurrentValue}].Name.Find[entity]} > 0
					continue
				else
				{
					Debug:Spew["ENTNAME(${Asteroids.CurrentValue})", "Lock", FALSE]
					LOCK(${Asteroids.CurrentValue})
					i:Set[RANDOM(SLOWQ,SLOWH)]
					while ${i:Dec} > 0
						waitframe
				}
			}
			while ${Asteroids.NextValue(exists)} && ALLTARGETS < MAXTARGETS
			
			This:GetTargets
			Targets:GetIterator
			if ${Iter:First(exists)}
			do
			{
				
			}
			while ${Iter:Next(exists)}
			
		}
		;;;;;;;;;;;;;;;;;;;
		if CARGOPCT > ${Full}
		{
			BMREMOVE(${LastSpot})
			wait RANDOM(SLOW, SLOW)
			variable string Temp = "${Debug.Runtime} Last Spot $$$"
			EVE:CreateBookmark[${Temp}]
			LastSpot:Set[${Temp}]
			UseLastSpot:Set[TRUE]
			call Ship.Goto ${SafeSpot}
			Stage:Set[Docked]
		}
		else
		{
			UseLastSpot:Set[FALSE]
			CurrentLocation:Inc
			Stage:Set[MoveOn]
		}
	}
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
		
		Lasers:Clear
		Afterburner:Set[NULL]
		SensorBooster:Set[NULL]
		CloakingUnit:Set[NULL]
		
		MyShip:DoGetModules[Modules]
		Modules:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			echo "${Iter.Value.ToItem.Name} - ${Iter.Value.ToItem.GroupID}"
			if ${Iter.Value.ToItem.GroupID} == ITMGROUPMININGLASER
			{
				Lasers:Set[${Iter.Value.ToItem.ID},${Iter.Value.ToItem.Slot}]
				if ${MaxRange} < 1
				{
					if ${Iter.Value.OptimalRange} >= TARGETINGRANGE
						MaxRange:Set[TARGETINGRANGE]
					else
						MaxRange:Set[${Iter.Value.OptimalRange}]	
				}
			}
			elseif ${Iter.Value.ToItem.GroupID} == ITMGROUPSHIELDBOOSTER
				ShieldBooster:Set[${Iter.Value.ToItem.Slot}]
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
		
		Asteroids:Clear
		
		EVE:DoGetEntities[MyEntities]
		MyEntities:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ${Iter.Value.TypeID} == ENTGROUPWRECK
			if ${Iter.Value.HaveLootRights}
				Asteroids:Set[${Iter.Value.ID}, ${Iter.Value.ID}]
		}
		while ${Iter:Next(exists)}
	}
}