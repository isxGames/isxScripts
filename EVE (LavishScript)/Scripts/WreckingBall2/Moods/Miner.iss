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
	
	variable collection:string Lasers
	variable string ShieldBooster
	variable index:item MiningDrones
	variable index:item CombatDrones
	
	variable index:int64 Asteroids
	variable collection:int64 Belts
	variable index:int64 Targets
	
	variable index:string Locations
	variable string SafeSpot
	variable string LastSpot
	variable int CurrentLocation = 1
	
	variable int Runs = 0
	variable int64 Profit = 0
	variable int AsteroidValue = 35
	
	function Begin()
	{
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
			;This:GetDrones
			This:GetModules
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
		if ${CurrentLocation} > ${Locations.Used} && ${Locations.Used} > 0
		{
			Debug:Spew["${Lasers.Used}", "MoveOnNoBMsleft", FALSE]
			StillGoing:Set[FALSE]
			call Ship.Goto ${SafeSpot}
			return
		}
		elseif ${CurrentLocation} > ${Locations.Used} && !${UseLastSpot}
		{
			if ${CurrentLocation} > ${Belts.Used}
			{
				Debug:Spew["${Lasers.Used}", "MoveOnNoBeltsLeft", FALSE]
				StillGoing:Set[FALSE]
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
			else
			{
				Debug:Spew["${Locations.Get[${CurrentLocation}]} - ${Entity[${AsteroidType}].Distance}", "MoveOnNextLocation", FALSE]
				call Ship.Goto ${Locations.Get[${CurrentLocation}]}
				if ${Entity[TypeID,${AsteroidType}].Distance} > 150000
				{
					Debug:Spew["SHIPMODE", "MoveOnWarpTo", FALSE]
					while SHIPMODE != WARPING
					{
						Entity[${AsteroidType}]:WarpTo
						wait RANDOM(SLOW, SLOW)
					}
					Debug:Spew["SHIPMODE", "MoveOnWarping", FALSE]
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
		variable iterator Iter
		variable bool Approaching = FALSE
		variable int Random = RANDOM(60,100)
		
		variable time Timer
		
		This:GetEntities
		Debug:Spew["${Asteroids.Used}", "StartMining", FALSE]
		;;;;;;;;;;;;;;;;;
		if ${Asteroids.Used} > 3
		while ${Asteroids.Used} > 3 && CARGOPCT < ${Full}
		{
			if SHIELD < 74
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
			;	if ${CombatDrones.Used} > 0
			;	{
			;		if ${MiningDrones.Get[1].Location.Find[DroneBay]} < 1
			;			call Ship.ReturnDrones ${MiningDrones}
			;		elseif ${CombatDrones.Get[1].Location.Find[DroneBay]} > 0
			;			call Ship.LaunchDrones ${CombatDrones}
			;	}
			;}
			;elseif ${MiningDrones.Used} > 1
			;{
			;	if ${CombatDrones.Get[1].Location.Find[DroneBay]} > 0
			;		call Ship.ReturnDrones ${CombatDrones}
			;	elseif ${MiningDrones.Get[1].Location.Find[DroneBay]} < 1
			;		call Ship.LaunchDrones ${MiningDrones}
			;}
			
			call This.CheckLasers
			
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
		if ${Lasers.FirstValue(exists)}
		do
		{
			if !MODACTIVATED(${Lasers.CurrentValue})
			{
				Debug:Spew["${Lasers.CurrentValue}", "LaserOff", FALSE]
				while TARGETS < ${Lasers.Used} && TARGETS < MAXTARGETS
				{
					Debug:Spew["TARGETS - ${Lasers.Used} - TARGETS - MAXTARGETS", "NeedTargets", FALSE]
					This:GetEntities
					Asteroids:GetIterator[Iter]
					if ${Iter:First(exists)}
					do
					{
						if !ENTHASBEENLOCKED(${Iter.Value})
						{
							Debug:Spew["ENTNAME(${Iter.Value})", "FoundRock", FALSE]
							while ENTDISTANCE(${Iter.Value}) > ${MaxRange}
							{
								Debug:Spew["SHIPMODE - APPROACHING - ENTDISTANCE(${Iter.Value}) - ${MaxRange}", "ApproachRock ENTDISTANCE(${Iter.Value})", FALSE]
								if SHIPMODE != APPROACHING
									APPROACH(${Iter.Value})
								wait RANDOM(SLOW,SLOW)
							}
							Debug:Spew["ENTNAME(${Iter.Value})", "Lock", FALSE]
							LOCK(${Iter.Value})
							wait RANDOM(SLOW,SLOW)
						}
					}
					while ${Iter:Next(exists)} && TARGETS < ${Lasers.Used} && TARGETS < MAXTARGETS
					wait RANDOM(SLOW, SLOW)
				}
				This:GetTargets
				Targets:GetIterator[Iter]
				if ${Iter:First(exists)}
				do
				{
					if ENTDISTANCE(${Iter.Value}) > ${MaxRange}
					{
						while ENTDISTANCE(${Iter.Value}) > ${MaxRange}
						{
							Debug:Spew["SHIPMODE - APPROACHING - ENTDISTANCE(${Iter.Value}) - ${MaxRange}", "ApproachTarget ENTDISTANCE(${Iter.Value})", FALSE]
							if SHIPMODE != APPROACHING
								APPROACH(${Iter.Value})
							wait RANDOM(SLOW,SLOW)
						}
					}
					if !${Lasers.Element[${Iter.Value}](exists)}
					{
						Debug:Spew["${Iter.Value}", "FoundTarget ${Iter.Value}", FALSE]
						call Ship.MakeActiveTarget ${Iter.Value}
						call Ship.ActivateModule ${Lasers.CurrentValue}, TRUE
						STOPSHIP()
						Lasers:Set[${Iter.Value}, ${Lasers.CurrentValue}]
						Lasers:Erase[${Lasers.CurrentKey}]
						return
					}
				}
				while ${Iter:Next(exists)}
			}
		}
		while ${Lasers.NextValue(exists)}
	}
	
	member:int64 RatFinder()
	{
		variable index:entity Entities
		variable iterator Iter
		
		EVE:DoGetEntities[Entities,CategoryID,ENTCATENTITY]
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
		MyShip:DoGetCargo[Cargo]
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
		
		MyShip:DoGetCargo[Cargo]
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
		
		Me:DoGetTargets[MyTargets]
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
			if ${Iter.Value.GroupID} == 459
				Asteroids:Insert[${Iter.Value.ID}]
		}
		while ${Iter:Next(exists)}
	}
	
	method GetBelts()
	{
		variable index:entity MyEntities
		variable iterator Iter
		variable int i = 1
		
		Belts:Clear
		
		EVE:DoGetEntities[MyEntities]
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
		variable index:item MyDrones
		variable iterator Iter
		
		MiningDrones:Clear
		CombatDrones:Clear
		
		MyShip:DoGetDrones[MyDrones]
		MyDrones:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ${Iter.Value.GroupID} == ITMGROUPCOMBATDRONE && ${CombatDrones.Used} < 5
				CombatDrones:Insert[${Iter.Value}]
			if ${Iter.Value.GroupID} == ITMGROUPMININGDRONE && ${MiningDrones.Used} < 5
				MiningDrones:Insert[${Iter.Value}]
		}
		while ${Iter:Next(exists)}
		if ${MiningDrones.Used} > 0 || ${CombatDrones} > 0
			DronesOut:Set[None]
	}
}