objectdef Miner
{
	variable bool StillGoing = TRUE
	variable int MaxRange
	variable string Stage
	
	variable string AsteroidType = Pyroxere
	variable int CrystalType = 18614
	variable int Full = 90
	variable bool UseLastSpot = FALSE
	variable string DroneTypeOut = NoDrones
	
	variable collection:int AsteroidTypes
	
	variable collection:string Lasers
	variable string ShieldBooster
	variable index:int64 MiningDrones
	variable index:int64 CombatDrones
	variable index:int64 LaunchedDrones
	
	variable index:int64 Asteroids
	variable collection:int64 Belts
	variable index:int64 Targets
	
	variable index:string Locations
	variable string SafeSpot
	variable string LastSpot
	variable int CurrentLocation = 1
	
	variable int Runs = 0
	variable int64 Profit = 0
	variable int AsteroidValue = 100
	
	function Begin()
	{
		;variable iterator Iter
		
		;This:GetEntities
		;echo "Used - ${Asteroids.Used}"
		;Asteroids:GetIterator[Iter]
		;if ${Iter:First(exists)}
		;do
		;{
		;	echo "ENTNAME(${Iter.Value}) - ${Iter.Value}"
		;}
		;while ${Iter:Next(exists)}
		
		;return
	
	
		AsteroidTypes:Set["Veldspar",18618]
		AsteroidTypes:Set["Pyroxere",18614]
		AsteroidTypes:Set["Scordite",18616]
		
		if ${AsteroidTypes.FirstKey(exists)}
		{
			AsteroidType:Set[${AsteroidTypes.CurrentKey}]
			CrystalType:Set[${AsteroidTypes.CurrentValue}]
			echo "${AsteroidType} - ${CrystalType}"
		}
		
		if !INSPACE
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
		
		if INSPACE
			call Ship.Goto ${SafeSpot}
		
		Stage:Set[Docked]
		
		Debug:Spew["${Lasers.Used}", "Startup - ${Stage}", FALSE]
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
		This:CalculateProfit
		
		call Ship.Unload Hangar, ${CrystalType}
		
		Stage:Set[MoveOn]
		
		if ${This.SpareCrystals} < 3
			call Ship.Grab ${CrystalType}, ${Math.Calc[3 - ${This.SpareCrystals}]}
		
		
		
		if ${StillGoing}
		{
			call Ship.Undock
			This:GetModules
			if ${Lasers.FirstValue(exists)}
			do
			{
				call Ship.Reload ${Lasers.CurrentValue}, ${CrystalType}
				wait RANDOM(SLOW,SLOW)
			}
			while ${Lasers.NextValue(exists)}
			if ${Lasers.Used} < 1
			{
				echo "No Modules - ${Lasers.Used}"
				Debug:Spew["${Lasers.Used}", "StartUpNoModules", TRUE]
				call Ship.Goto ${SafeSpot}
				StillGoing:Set[FALSE]
			}
			if ${Belts.Used} < 1
				This:GetBelts
		}
	}
	
	function MoveOn()
	{
		if !${UseLastSpot}
		{
			if ${CurrentLocation} > ${Belts.Used}
			{
				if ${AsteroidTypes.NextKey(exists)}
				{
					Debug:Spew["${Lasers.Used}", "MoveOnRanoutofAsteroid", FALSE]
					AsteroidType:Set[${AsteroidTypes.CurrentKey}]
					CrystalType:Set[${AsteroidTypes.CurrentValue}]
					CurrentLocation:Set[1]
					Stage:Set[Docked]
				}
				else
				{
					Debug:Spew["${Lasers.Used}", "AllGone", FALSE]
					StillGoing:Set[FALSE]
				}
				call Ship.Goto ${SafeSpot}
				return
			}
			Debug:Spew["${CurrentLocation} - ${Belts.Element[${CurrentLocation}]} - ENTDISTANCE(${Belts.Element[${CurrentLocation}]})", "MoveOnNextBelt", FALSE]
			if ENTDISTANCE(${Belts.Element[${CurrentLocation}]}) > 150000
			{
				while SHIPMODE != WARPING
				{
					Debug:Spew["SHIPMODE", "Warpto", FALSE]
					WARPTO(${Belts.Element[${CurrentLocation}]})
					wait RANDOM(SLOW,SLOW)
				}
				while SHIPMODE == WARPING
					wait RANDOM(SLOW,SLOW)
				Debug:Spew["SHIPMODE", "Warpto", FALSE]
			}
			Stage:Set[Mining]
			return
		}
		else
		{
			if ${UseLastSpot}
			{
				Debug:Spew["${LastSpot} - ${UseLastSpot}", "MoveOnLastSpot", FALSE]
				call Ship.Goto ${LastSpot}
			}
		}
		Stage:Set[Mining]
	}
	
	function Mining()
	{
		variable iterator Iter
		variable bool Approaching = FALSE
		variable int Random = RANDOM(60,100)
		
		variable time Timer
		
		This:GetEntities
		This:GetDrones
		Debug:Spew["${Asteroids.Used}", "StartMining", FALSE]
		;;;;;;;;;;;;;;;;;
		if ${Asteroids.Used} > 3
		while ${Asteroids.Used} > 3 && CARGOPCT < ${Full}
		{
			if SHIELD < 65
			{
				Debug:Spew["SHIELD", "Chicken", TRUE]
				call Ship.Goto ${SafeSpot}
				echo chicken
				endscript wreckingball2
			}
			if !MODACTIVATED(${ShieldBooster}) && ${ShieldBooster.Length} > 0
				call Ship.ActivateModule ${ShieldBooster}, TRUE
			
			;if ${This.RatFinder} > 0
			;{
			;	This:GetDrones
			;	if ${LaunchedDrones.Used} > 0 && ENTGROUP(${LaunchedDrones.Get[1]}) == DRONEGROUPMINING
			;	{
			;		call Ship.Drones ${LaunchedDrones}, Return
			;		call Ship.Drones ${CombatDrones}, Launch
			;	}
			;}
			;elseif ${LaunchedDrones.Used} > 0 && ENTGROUP(${LaunchedDrones.Get[1]}) == DRONEGROUPCOMBAT
			;{
			;	call Ship.Drones ${LaunchedDrones}, Return
			;	call Ship.Drones ${MiningDrones}, Launch
			;	This:GetDrones
			;	call Ship.Drones ${LaunchedDrones}, Mine
			;}
			;elseif ${LaunchedDrones.Used} < 1
			;{
			;	This:GetDrones
			;	call Ship.Drones ${MiningDrones}, Launch
			;	This:GetDrones
			;	call Ship.Drones ${LaunchedDrones}, Mine
			;}
			
			call This.CheckLasers
			
			if SHIPMODE != STOPPING
			{
				STOPSHIP()
				wait RANDOM(SLOW,SLOW)
			}
		}
		;;;;;;;;;;;;;;;;;;;
		if CARGOPCT > ${Full}
		{
			Debug:Spew["CARGOPCT - ${Full}", "CargoFull", FALSE]
			BMREMOVE(${LastSpot})
			wait RANDOM(SLOW, SLOW)
			variable string Temp = "${Debug.Runtime} Last Spot"
			EVE:CreateBookmark[${Temp}]
			LastSpot:Set[${Temp}]
			UseLastSpot:Set[TRUE]
			Runs:Inc
			call Ship.Goto ${SafeSpot}
			Stage:Set[Docked]
		}
		elseif ${Asteroids.Used} <= 3
		{
			Debug:Spew["${Asteroids.Used} - 3", "Not Enough Rocks", FALSE]
			UseLastSpot:Set[FALSE]
			CurrentLocation:Inc
			Stage:Set[MoveOn]
		}
	}
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	function CheckLasers()
	{
		variable iterator Iter
		variable int i
		variable time MyTime = ${Time.Timestamp}
		if ${Lasers.FirstValue(exists)}
		do
		{
			if !MODACTIVATED(${Lasers.CurrentValue})
			{
				if !${MyShip.Module[${Lasers.CurrentValue}].Charge(exists)}
					RELOAD()
				Debug:Spew["TARGETS - ${Lasers.Used} - MAXTARGETS", "LaserOff", FALSE]
				while TARGETS < ${Lasers.Used} && TARGETS < MAXTARGETS && ${Asteroids.Used} > TARGETS
				{
					if ${Math.Calc[${Time.Timestamp}-${MyTime.Timestamp}]} > 30
						return
					Debug:Spew["TARGETS - ${Lasers.Used} - TARGETS - MAXTARGETS", "NeedTargets ${Math.Calc[${Time.Timestamp}-${MyTime.Timestamp}]}", FALSE]
					This:GetEntities
					if ${Asteroids.Used} < 1
						return
					Asteroids:GetIterator[Iter]
					if ${Iter:First(exists)} && TARGETS < ${Lasers.Used} && TARGETS < MAXTARGETS
					do
					{
						if !ENTHASBEENLOCKED(${Iter.Value})
						{
							Debug:Spew["ENTNAME(${Iter.Value})", "FoundRock ${Math.Calc[${Time.Timestamp}-${MyTime.Timestamp}]}", FALSE]
							while ENTDISTANCE(${Iter.Value}) > ${MaxRange} && TARGETS < ${Lasers.Used} && TARGETS < MAXTARGETS
							{
								if ${Math.Calc[${Time.Timestamp}-${MyTime.Timestamp}]} > 30
									return
								Debug:Spew["SHIPMODE - APPROACHING - ENTDISTANCE(${Iter.Value}) - ${MaxRange}", "ApproachRock ENTDISTANCE(${Iter.Value}) - ${Math.Calc[${Time.Timestamp}-${MyTime.Timestamp}]}", FALSE]
								if SHIPMODE != APPROACHING
									APPROACH(${Iter.Value})
								wait RANDOM(SLOW,SLOW)
							}
							if ${Math.Calc[${Time.Timestamp}-${MyTime.Timestamp}]} > 30
								return
							Debug:Spew["ENTNAME(${Iter.Value})", "Lock ${Math.Calc[${Time.Timestamp}-${MyTime.Timestamp}]}", FALSE]
							LOCK(${Iter.Value})
							wait RANDOM(SLOW,SLOW)
						}
					}
					while ${Iter:Next(exists)} && TARGETS < ${Lasers.Used} && TARGETS < MAXTARGETS
					wait RANDOM(SLOW, SLOW)
				}
				if ${Math.Calc[${Time.Timestamp}-${MyTime.Timestamp}]} > 30
					return
				This:GetTargets
				Targets:GetIterator[Iter]
				if ${Iter:First(exists)}
				do
				{
					if ${Math.Calc[${Time.Timestamp}-${MyTime.Timestamp}]} > 30
						return
					if ENTDISTANCE(${Iter.Value}) > ${MaxRange} && ${Targets.Used} < 2
					{
						;while ENTDISTANCE(${Iter.Value}) > ${MaxRange}
						;{
						;	if ${Math.Calc[${Time.Timestamp}-${MyTime.Timestamp}]} > 30
						;		return
						;	Debug:Spew["SHIPMODE - APPROACHING - ENTDISTANCE(${Iter.Value}) - ${MaxRange}", "ApproachTarget ENTDISTANCE(${Iter.Value}) - ${Math.Calc[${Time.Timestamp}-${MyTime.Timestamp}]}", FALSE]
						;	if SHIPMODE != APPROACHING
						;		APPROACH(${Iter.Value})
						;	wait RANDOM(SLOW,SLOW)
						;}
						UNLOCK(${Iter.Value})
						wait RANDOM(SLOW,SLOW)
						continue
					}
					if !${Lasers.Element[${Iter.Value}](exists)} && ENTDISTANCE(${Iter.Value}) < ${MaxRange}
					{
						Debug:Spew["${Iter.Value}", "FoundTarget ${Iter.Value} - ${Math.Calc[${Time.Timestamp}-${MyTime.Timestamp}]}", FALSE]
						call Ship.MakeActiveTarget ${Iter.Value}
						call Ship.ActivateModule ${Lasers.CurrentValue}, TRUE
						if ${Return} < 1
						{
							Lasers:Set[${Iter.Value}, ${Lasers.CurrentValue}]
							Lasers:Erase[${Lasers.CurrentKey}]
						}
						return
					}
				}
				while ${Iter:Next(exists)}
				if ${Targets.Used} > 0 && !MODACTIVATED(${Lasers.CurrentValue})
					call Ship.ActivateModule ${Lasers.CurrentValue}, TRUE
				if ${Math.Calc[${Time.Timestamp}-${MyTime.Timestamp}]} > 30
					return
			}
			if ${Math.Calc[${Time.Timestamp}-${MyTime.Timestamp}]} > 30
				return
		}
		while ${Lasers.NextValue(exists)}
	}
	
	member:int64 RatFinder()
	{
		variable index:entity Entities
		variable iterator Iter
		
		EVE:QueryEntities[Entities,CategoryID = ENTCATENTITY]
		Entities:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ${Iter.Value.Group.Find[Asteroid]} > 0
				return ${Iter.Value.ID}
		}
		while ${Iter:Next(exists)}
		return 0
	}
	
	member:int SpareCrystals()
	{
		variable index:item Cargo
		variable iterator Iter
		variable int Qty = 0
		MyShip:GetCargo[Cargo]
		Cargo:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ${Iter.Value.TypeID} == ${CrystalType}
				Qty:Inc[${Iter.Value.Quantity}]
		}
		while ${Iter:Next(exists)}
		return ${Qty}
	}
	
	method CalculateProfit()
	{
		variable index:item Cargo
		variable iterator Iter
		variable int Count = 0
		
		MyShip:GetCargo[Cargo]
		Cargo:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ${Iter.Value.CategoryID} == ITMCATASTEROID
				Count:Inc[${Iter.Value.Quantity}]
		}
		while ${Iter:Next(exists)}
		Profit:Inc[${Math.Calc[${Count} * ${AsteroidValue}]}]
	}
	
	method GetTargets()
	{
		variable index:entity MyTargets
		variable iterator Iter
		Targets:Clear
		
		Me:GetTargets[MyTargets]
		MyTargets:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			Targets:Insert[${Iter.Value.ID}]
		}
		while ${Iter:Next(exists)}
	}
	
	method GetModules()
	{
		variable index:module Modules
		variable iterator Iter
		
		Lasers:Clear
		
		MyShip:GetModules[Modules]
		Modules:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			echo "${Iter.Value.ToItem.Name} - ${Iter.Value.ToItem.GroupID}"
			if ${Iter.Value.ToItem.GroupID} == ITMGROUPMININGLASER
			{
				Lasers:Set[${Iter.Value.ToItem.ID},${Iter.Value.ToItem.Slot}]
				if ${MaxRange} < 1
					MaxRange:Set[${Iter.Value.OptimalRange}]
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
		
		EVE:GetBookmarks[Bookmarks]
		Bookmarks:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ${Iter.Value.Label.Find[${BookmarkSymbol}]} > 0
				Locations:Insert[${Iter.Value.Label}]
			elseif ${Iter.Value.Label.Find[${HomeBookmarkSymbol}]} > 0
				SafeSpot:Set[${Iter.Value.Label}]
			elseif ${Iter.Value.Label.Find["Last Spot"]} > 0
			{
				LastSpot:Set[${Iter.Value.Label}]
				UseLastSpot:Set[TRUE]
			}
		}
		while ${Iter:Next(exists)}
	}
	
	method GetEntities()
	{
		variable index:entity MyEntities
		variable iterator Iter
		
		Asteroids:Clear
		
		EVE:QueryEntities[MyEntities]
		MyEntities:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ${Iter.Value.Group.Find[${AsteroidType}]} > 0
			{
				Asteroids:Insert[${Iter.Value.ID}]
			}
		}
		while ${Iter:Next(exists)}
	}
	
	method GetBelts()
	{
		variable index:entity MyEntities
		variable iterator Iter
		variable int i = 1
		
		Belts:Clear
		
		EVE:QueryEntities[MyEntities]
		MyEntities:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ${Iter.Value.TypeID} == ENTTYPEASTEROIDBELT
			{
				Belts:Set[${i}, ${Iter.Value.ID}]
				i:Inc
			}
		}
		while ${Iter:Next(exists)}
	}
	
	method GetDrones()
	{
		variable index:item DroneBay
		variable index:entity DroneEntities
		variable iterator Iter
		
		MiningDrones:Clear
		CombatDrones:Clear
		LaunchedDrones:Clear
		
		MyShip:GetDrones[DroneBay]
		DroneBay:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ${Iter.Value.GroupID} == DRONEGROUPCOMBAT && ${CombatDrones.Used} < 5
				CombatDrones:Insert[${Iter.Value.ID}]
			if ${Iter.Value.GroupID} == DRONEGROUPMINING && ${MiningDrones.Used} < 5
				MiningDrones:Insert[${Iter.Value.ID}]
		}
		while ${Iter:Next(exists)}
		
		EVE:QueryEntities[DroneEntities,CategoryID = DRONECATEGORY]
		DroneEntities:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			echo emptiness
		}
		while ${Iter:Next(exists)}
	}
}