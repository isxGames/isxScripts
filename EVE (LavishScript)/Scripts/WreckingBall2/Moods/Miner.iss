objectdef Salvager
{
	variable bool StillGoing = TRUE
	variable int MaxRange
	variable string Stage
	variable bool Reloaded = FALSE
	
	variable string AsteroidType = Pyroxere
	variable int Full = 90
	variable bool UseLastSpot = FALSE
	
	variable collection:string Lasers
	variable string ShieldBooster
	
	variable collection:int64 Asteroids
	variable collection:int64 Belts
	variable index:int64 Targets
	
	variable index:string Locations
	variable string SafeSpot
	variable string LastSpot
	variable int CurrentLocation = 1
	
	function Begin()
	{
		while SHIPMODE == WARPING
			wait RANDOM(SLOW,SLOW)
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
		
		if !INSPACE
			Stage:Set[Docked]
		else
		{
			Stage:Set[MoveOn]
			This:GetBelts
		}
		
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
		if ${Reloaded}
		{
			;call Ship.Grab ${MiningCrystalID}, 1
			Reloaded:Set[FALSE]
		}
		Stage:Set[MoveOn]
		
		if ${StillGoing}
		{
			call Ship.Undock
			if ${Lasers.Used} < 1
			{
				This:GetModules
				if ${Lasers.Used} < 1
				{
					echo "No Modules - ${Lasers.Used}"
					Debug:Spew["${Lasers.Used}", "StartUpNoModules", TRUE]
					call Ship.Goto ${SafeSpot}
					StillGoing:Set[FALSE]
				}
			}
			if ${Belts.Used} < 1
				This:GetBelts
		}
	}
	
	function MoveOn()
	{
		if ${CurrentLocation} > ${Locations.Used} && ${Locations.Used} > 0
		{
			StillGoing:Set[FALSE]
			call Ship.Goto ${SafeSpot}
		}
		elseif ${CurrentLocation} > ${Locations.Used} && !${UseLastSpot}
		{
			if ${CurrentLocation} > ${Belts.Used}
			{
				StillGoing:Set[FALSE]
				call Ship.Goto ${SafeSpot}
			}
			call Ship.Goto ${Belts.Element[${CurrentLocation}]}
		}
		else
		{
			if ${UseLastSpot}
				call Ship.Goto ${LastSpot}
			else
			{
				call Ship.Goto ${Locations.Get[${CurrentLocation}]}
				if ${Entity[${AsteroidType}].Distance} > 150000
				{
					while SHIPMODE != WARPING
					{
						Entity[${AsteroidType}]:WarpTo
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
		variable bool NotAligned = TRUE
		
		This:GetEntities
		;;;;;;;;;;;;;;;;;
		if ${Asteroids.Used} > 0
		while ${Mining} && ${Asteroids.Used} > 0
		{
			if CARGOPCT > ${Full}
				break
			
			if CARGOPCT > DIVIDE(${Full},0.9) && ${NotAligned}
			{
				BMALIGN(${SafeSpot})
				wait RANDOM(SLOW,SLOW)
				NotAligned:Set[FALSE]
			}
			
			This:GetEntities
			
			if ENTDISTANCE(${This.Closest})
			while ENTDISTANCE(${This.Closest})
			{
				call Ship.Approach ${This.Closest}
				NotAligned:Set[TRUE]
				wait RANDOM(SLOW,SLOW)
			}
			
			;Lock
			if ${Asteroids.FirstValue(exists)} && ALLTARGETS < ${Lasers.Used} && ALLTARGETS < MAXTARGETS
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
			while ${Asteroids.NextValue(exists)} && ALLTARGETS < ${Lasers.Used} && ALLTARGETS < ${Lasers.Used}
			
			This:GetTargets
			Targets:GetIterator
			if ${Iter:First(exists)}
			do
			{
				if ${Lasers.FirstValue(exists)}
				do
				{
					if ENTDISTANCE(${Iter.Value}) > ${MaxRange}
					{
						call Ship.Approach ${Iter.Value}
						NotAligned:Set[TRUE]
						wait RANDOM(SLOW,SLOW)
						break
					}
					if !MODACTIVATED(${Lasers.CurrentValue}) && !${Lasers.Element[${Iter.Value}](exists)}
					{
						ORBIT(${Iter.Value},DIVIDE(${MaxRange,3}))
						NotAligned:Set[TRUE]
						call Ship.MakeActiveTarget ${Iter.Value}
						if ${Return} > 90
							continue
						call Ship.ActivateModule ${Lasers.CurrentValue}, TRUE
						Lasers:Set[${Iter.Value}, ${Lasers.CurrentValue}]
						Lasers:Erase[${Lasers.CurrentKey}]
						break
					}
				}
				while ${Lasers.NextValue(exists)}
			}
			while ${Iter:Next(exists)}
			
		}
		;;;;;;;;;;;;;;;;;;;
		if CARGOPCT > ${Full}
		{
			BMREMOVE(${LastSpot})
			wait RANDOM(SLOW, SLOW)
			variable string Temp = "@?@ ${Debug.Runtime} Last Spot"
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
	
	member:int64 Closest()
	{
		variable int64 Winner = ${Me.ToEntity.ID}
		variable float curDistance = 150000
		if ${Asteroids.FirstValue(exists)}
		do
		{
			if ENTDISTANCE(${Asteroids.CurrentValue}) < ${curDistance}
			{
				curDistance:Set[ENTDISTANCE(${Asteroids.CurrentValue})]
				Winner:Set[${Asteroids.CurrentValue}]
			}
		}
		while ${Asteroids.NextValue(exists)}
		return ${Winner}
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
			if ${Iter.Value.Name.Find[${AsteroidType}]} > 0
				Asteroids:Set[${Iter.Value.ID}, ${Iter.Value.ID}]
		}
		while ${Iter:Next(exists)}
	}
	
	method GetBelts()
	{
		variable index:entity MyEntities
		variable iterator Iter
		
		Belts:Clear
		
		EVE:DoGetEntities[MyEntities]
		MyEntities:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ${Iter.Value.TypeID} == ENTTYPEASTEROIDBELT
				Belts:Set[${Iter.Value.ID}, {Iter.Value.ID}]
		}
		while ${Iter:Next(exists)}
	}
}