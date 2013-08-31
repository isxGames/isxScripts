variable(script) index:module ModuleMiner
variable(script) index:module ModuleSalvager
variable(script) index:module ModuleTractor
variable(script) index:module ModuleAll
variable(script) collection:int64 AlreadyLocked
variable(script) collection:int64 LockedContainer
variable(script) int MaxTractorRange = 0
variable(script) int MaxSalvageRange = 0
variable(script) int MaxMiningRange = 0
variable(script) index:entity ShipTargets
variable(script) int MaxTargetsAllowed

objectdef obj_TheShip
{
	variable index:module ObjShipModules
	variable index:module ObjAfterburner

	method Initialize()
	{
	}
	
	method ResetCollections()
	{
		AlreadyLocked:Clear
		LockedContainer:Clear
	}

	method AcquireModules()
	{
		BotCurrentState:Set["Acquire Modules"]
		variable iterator ObjModuleIterator
		variable index:module ObjAcquireModules
		if !(${Me.InSpace})
		{
			StatusUpdate:Red["Can't get ship info while not in space"]
			return
		}
		if ${Me.Ship.MaxLockedTargets} < ${Me.MaxLockedTargets}
			MaxTargetsAllowed:Set[${Me.Ship.MaxLockedTargets}]
		else
			MaxTargetsAllowed:Set[${Me.MaxLockedTargets}]
		StatusUpdate:Yellow["${MaxTargetsAllowed} max targets allowed"]
		StatusUpdate:Green["${MaxTargetsAllowed} max targets allowed"]
		ObjShipModules:Clear
		ModuleMiners:Clear
		ModuleSalvagers:Clear
		ModuleTractors:Clear
		Me.Ship:DoGetModules[ObjAcquireModules]
		Me.Ship:DoGetModules[ModuleAll]
		StatusUpdate:Yellow["${ObjAcquireModules.Used} modules found"]
		ObjAcquireModules:GetIterator[ObjModuleIterator]
		if ${ObjModuleIterator:First(exists)}
		{
			do
			{
				if ${ObjModuleIterator.Value.MaxTractorVelocity} > 0
				{
					ModuleTractor:Insert[${ObjModuleIterator.Value}]
					if ${MaxTractorRange} == 0
					{
						MaxTractorRange:Set[${ObjModuleIterator.Value.OptimalRange}]
						StatusUpdate:Yellow["${MaxTractorRange} max tractor range"]
						StatusUpdate:Green["${MaxTractorRange} max tractor range"]
					}
				}
				elseif ${ObjModuleIterator.Value.AccessDifficultyBonus} > 0
				{
					if ${ObjModuleIterator.Value.ToItem.Type.Find["Salvager"]} > 0
					{
						ModuleSalvager:Insert[${ObjModuleIterator.Value}]
						if ${MaxSalvageRange} == 0
						{
							MaxSalvageRange:Set[${ObjModuleIterator.Value.OptimalRange}]
							StatusUpdate:Yellow["${MaxSalvageRange} max salvage range"]
							StatusUpdate:Green["${MaxSalvageRange} max salvage range"]
						}
					}
				}
				elseif ${ObjModuleIterator.Value.MaxVelocityBonus} > 0
				{
					ObjAfterburner:Insert[${ObjModuleIterator.Value}]
					StatusUpdate:Yellow["Afterburner found"]
					StatusUpdate:Green["Afterburner found"]
				}
				elseif ${ObjModuleIterator.Value.MiningAmount} > 0
				{
					ModuleMiner:Insert[${ObjModuleIterator.Value}]
					if ${MaxMiningRange} == 0
					{
						MaxMiningRange:Set[${ObjModuleIterator.Value.OptimalRange}]
						StatusUpdate:Yellow["${MaxMiningRange} max mining range"]
						StatusUpdate:Green["${MaxMiningRange} max mining range"]
					}
				}
			}
			while ${ObjModuleIterator:Next(exists)}
		}
		else
		{
			StatusUpdate:Red["No Modules found on ship"]
			StatusUpdate:Green["No modules found on ship"]
			return
		}
	}
	
	member:bool ShipCargoFull()
	{
		if ${Math.Calc[${Me.Ship.UsedCargoCapacity} / ${Me.Ship.CargoCapacity}]} > .95
			return TRUE
		else
			return FALSE
	}
	
	function EmptyCargo(string ObjItemStorageLocation)
	{
		BotCurrentState:Set["Empty Cargo"]
		StatusUpdate:Green["Emptying cargo hold"]
		variable index:item ObjItemsCargo
		variable iterator ObjCargoIterator
		variable index:int64 ObjQueuedCargoItems
		
		do
		{
			if !${EVEWindow[hangarFloor](exists)}
			{
				EVE:Execute[OpenHangarFloor]
				wait ${Slow}
				StatusUpdate:Yellow["Is hangar open - ${EVEWindow[hangarFloor](exists)}"]
			}
		}
		while !${EVEWindow[hangarFloor](exists)}
		do
		{
			if !(${EVEWindow[MyShipCargo](exists)})
			{
				EVE:Execute[OpenCargoHoldOfActiveShip]
				wait ${Slow}
				StatusUpdate:Yellow["Is Cargo Hold Open - ${EVEWindow[MyShipCargo](exists)}"]
			}
		}
		while !(${EVEWindow[MyShipCargo](exists)})
		Me.Ship:DoGetCargo[ObjItemsCargo]
		ObjItemsCargo:GetIterator[ObjCargoIterator]
		StatusUpdate:Yellow["${ObjItemsCargo.Used} items to move"]
		StatusUpdate:Green["${ObjItemsCargo.Used} items to move"]
		ObjQueuedCargoItems:Clear
		if ${ObjCargoIterator:First(exists)}
		do
		{
			ObjQueuedCargoItems:Insert[${ObjCargoIterator.Value.ID}]
		}
		while ${ObjCargoIterator:Next(exists)}
		StatusUpdate:Yellow["${ObjQueuedCargoItems.Used} items to move"]
		if ${ObjQueuedCargoItems.Used} > 0
			EVE:MoveItemsTo[ObjQueuedCargoItems,${ObjItemStorageLocation}]
		wait ${Math.Calc[${Slow} / 2]}
	}
	
	function GetTypeIDFromHangar(int ObjItemTypeIDToGet, int ObjItemQuantityToGet)
	{
		BotCurrentState:Set["Get TypeID from hangar"]
		variable index:item ObjHangarItems
		variable iterator ObjHangarIterator
		
		do
		{
			if !${EVEWindow[hangarFloor](exists)}
			{
				EVE:Execute[OpenHangarFloor]
				wait ${Slow}
				StatusUpdate:Yellow["Is hangar open - ${EVEWindow[hangarFloor](exists)}"]
			}			
		}
		while !${EVEWindow[hangarFloor](exists)}
		EVE:Execute[OpenCargoHoldOfActiveShip]
		wait ${Math.Calc[${Slow} / 2]}
		;Me.Station:StackAllHangarItems
		wait ${Slow}
		Me.Station:DoGetHangarItems[ObjHangarItems]
		ObjHangarItems:GetIterator[ObjHangarIterator]
		if ${ObjHangarIterator:First(exists)}
		do
		{
			if ${ObjHangarIterator.Value.TypeID} == ${ObjItemTypeIDToGet}
			{
				ObjHangarIterator.Value:MoveTo[MyShip, ${ObjItemQuantityToGet}]
				wait ${Slow}
				break
			}
		}
		while ${ObjHangarIterator:Next(exists)}
	}

	function Afterburners(bool ObjAfterburnersOn)
	{
		BotCurrentState:Set["Afterburners"]
		StatusUpdate:Yellow["Turn on Afterburners ${ObjAfterburnerson}"]
		StatusUpdate:Yellow["Afterburners are on ${ObjAfterburner.Get[1].IsActive}"]
		StatusUpdate:Yellow["Afterburners are deactivating ${ObjAfterburner.Get[1].IsDeactivating}"]
		StatusUpdate:Yellow["Ship Cap lvl ${Me.Ship.CapacitorPct}"]
		variable int ObjAfterburnerCounter
		StatusUpdate:Green["Afterburner check"]
		
		if ${ObjAfterburnersOn} && ${ObjAfterburner.Used} > 0
		{
			if ${Me.Ship.CapacitorPct} < 40 && ${ObjAfterburner.Get[1].IsActive} && !(${ObjAfterburner.Get[1].IsDeactivating})
			{
				StatusUpdate:Yellow["AB Off cap to low"]
				StatusUpdate:Green["Cap to low, turn off afterburner"]
				ObjAfterburner.Get[1]:Click
				ObjAfterburnerCounter:Set[0]
				do
				{
					waitframe
					waitframe
					waitframe
					waitframe
					waitframe
				}
				while !(${ObjAfterburner.Get[1].IsDeactivating}) && ${ObjAfterburnerCounter:Inc} <= ${Slow}
				StatusUpdate:Yellow["${ObjAfterburnerCounter} time should be less than ${Slow}"]
			}
			elseif ${Me.Ship.CapacitorPct} > 50 && !(${ObjAfterburner.Get[1].IsActive}) && !(${ObjAfterburner.Get[1].IsDeactivating})
			{
				StatusUpdate:Yellow["AB On Cap OK"]
				StatusUpdate:Green["Afterburner ON"]
				ObjAfterburner.Get[1]:Click
				ObjAfterburnerCounter:Set[0]
				do
				{
					waitframe
					waitframe
					waitframe
					waitframe
					waitframe
				}
				while !(${ObjAfterburner.Get[1].IsActive}) && ${ObjAfterburnerCounter:Inc} <= ${Slow}
				StatusUpdate:Yellow["${ObjAfterburnerCounter} time should be less than ${Slow}"]
			}
		}
		elseif ${ObjAfterburner.Used} > 0
		{
			if ${ObjAfterburner.Get[1].IsActive} && !(${ObjAfterburner.Get[1].IsDeactivating})
			{
				StatusUpdate:Yellow["AB OFF"]
				StatusUpdate:Green["Afterburner OFF"]
				ObjAfterburner.Get[1]:Click
				ObjAfterburnerCounter:Set[0]
				do
				{
					waitframe
					waitframe
					waitframe
					waitframe
					waitframe
				}
				while !(${ObjAfterburner.Get[1].IsDeactivating}) && ${ObjAfterburnerCounter} <= ${Slow}
				StatusUpdate:Yellow["${ObjAfterburnerCounter} time should be less than ${Slow}"]
			}
		}
	}


	function ActivateModule(string ObjModName, int64 ObjModTarget)
	{
		BotCurrentState:Set["Activate Module"]
		StatusUpdate:Yellow["Begin activating ${ObjModName} on ${Entity[${ObjModTarget}].Name}"]
		variable iterator ObjActivateIterator
		variable int ObjActivateCounter
		
		call This.MakeActiveTarget ${ObjModTarget}
		Module${ObjModName}:GetIterator[ObjActivateIterator]
		if ${ObjActivateIterator:First(exists)}
		do
		{
			if !(${ObjActivateIterator.Value.IsActive}) && !(${ObjActivateIterator.Value.IsDeactivating})
			{
				ObjActivateIterator.Value:Click
				ObjActivateCounter:Set[0]
				do
				{
					waitframe
					waitframe
					waitframe
					waitframe
					waitframe
				}
				while ${ObjActivateIterator.Value.TargetID} != ${ObjModTarget} && ${ObjActivateCounter:Inc} <= ${Slow} && !(${ObjActivateIterator.Value.IsActive})
				StatusUpdate:Yellow["${ObjActivateCounter} time should be less than ${Slow}"]
				StatusUpdate:Yellow["Module target ${ObjActivateIterator.Value.TargetID}"]
				StatusUpdate:Yellow["TargetID ${ObjModTarget}"]
				StatusUpdate:Yellow["Module Active ${ObjActivateIterator.Value.IsActive}"]
				StatusUpdate:Green["${ObjModName} on ${Entity[${ObjModTarget}].Name}"]
				return
			}
		}
		while ${ObjActivateIterator:Next(exists)}
	}

	
	function MakeActiveTarget(int64 ObjActiveTarget)
	{
		variable int ObjTarCounter
		StatusUpdate:Yellow["Begin MakeActiveTarget ${Entity[${ObjActiveTarget}].Name}"]
		Entity[${ObjActiveTarget}]:MakeActiveTarget
		ObjTarCounter:Set[0]
		do
		{
			waitframe
			waitframe
			waitframe
			waitframe
			waitframe
		}
		while ${Me.ActiveTarget.ID} != ${ObjActiveTarget} && ${ObjTarCounter:Inc} <= ${Slow}
		StatusUpdate:Yellow["${ObjTarCounter} time should be less than ${Slow}"]
		StatusUpdate:Yellow["My target ${Me.ActiveTarget.ID}"]
		StatusUpdate:Yellow["TargetID ${ObjActiveTarget}"]
	}

	function Undock()
	{
		BotCurrentState:Set["Undock"]
		StatusUpdate:Yellow["Undocking"]
		StatusUpdate:Green["Undocking"]
		EVE:Execute[CmdExitStation]
		do
		{
			wait ${Slow}
		}
		while !(${Me.InSpace})
		StatusUpdate:Yellow["InSpace - ${Me.InSpace}"]
		StatusUpdate:Green["Undocked, wait just a bit longer"]
		wait ${Math.Calc[${Slow} * 2]}
	}
	
	function LockMaxEntities(bool ObjAlsoContainers, int ObjLockingRange)
	{
		BotCurrentState:Set["Locking Max"]
		StatusUpdate:Yellow["Lock max, Containers - ${ObjAlsoContainers}, Range - ${ObjLockingRange}"]
		variable iterator ObjLockMaxIterator
		
		Entities:GetIterator[ObjLockMaxIterator]
		if ${ObjLockMaxIterator:First(exists)}
		do
		{
			if !(${AlreadyLocked.Element[${ObjLockMaxIterator.Value.ID}](exists)}) && ${ObjLockMaxIterator.Value.Distance} < ${ObjLockingRange}
			{
				ObjLockMaxIterator.Value:LockTarget
				AlreadyLocked:Set[${ObjLockMaxIterator.Value.ID},1]
				waitframe
				waitframe
				waitframe
				waitframe
				waitframe
			}
		}
		while ${ObjLockMaxIterator:Next(exists)} && ${MaxTargetsAllowed} > ${Math.Calc[${Me.GetTargets} + ${Me.GetTargeting}]}
		;echo "Lock Container - ${EntitiesContainer.Get[1](exists)} && ${MaxTargetsAllowed} > ${Math.Calc[${Me.GetTargets} + ${Me.GetTargeting}]} && ${ObjAlsoContainers}"
		if ${EntitiesContainer.Get[1](exists)} && ${MaxTargetsAllowed} > ${Math.Calc[${Me.GetTargets} + ${Me.GetTargeting}]} && ${ObjAlsoContainers}
		{
			EntitiesContainer:GetIterator[ObjLockMaxIterator]
			if ${ObjLockMaxIterator:First(exists)}
			do
			{
				;echo "In Lock - !(${AlreadyLocked.Element[${ObjLockMaxIterator.Value.ID}](exists)}) && ${ObjLockMaxIterator.Value.Distance} > 2300 && ${ObjLockMaxIterator.Value.Distance} < ${ObjLockingRange}"
				if !(${AlreadyLocked.Element[${ObjLockMaxIterator.Value.ID}](exists)}) && ${ObjLockMaxIterator.Value.Distance} > 2300 && ${ObjLockMaxIterator.Value.Distance} < ${ObjLockingRange}
				{
					StatusUpdate:Yellow["Lock Container"]
					ObjLockMaxIterator.Value:LockTarget
					AlreadyLocked:Set[${ObjLockMaxIterator.Value.ID},1]
					LockedContainer:Set[${ObjLockMaxIterator.Value.ID},1]
					waitframe
					waitframe
					waitframe
					waitframe
					waitframe
				}
			}
			while ${ObjLockMaxIterator:Next(exists)} && ${MaxTargetsAllowed} > ${Math.Calc[${Me.GetTargets} + ${Me.GetTargeting}]}
		}
	}
	
	function DrugBust()
	{
		BotCurrentState:Set["Drug Bust"]
		variable iterator DrugIterator
		variable index:item DrugItems
		variable int DrugCounter
		do
		{
			if !(${EVEWindow[MyShipCargo](exists)})
			{
				StatusUpdate:Yellow["Open Cargo Hold"]
				EVE:Execute[OpenCargoHoldOfActiveShip]
				wait ${Math.Calc[${Slow} / 2]}
			}
		}
		while !(${EVEWindow[MyShipCargo](exists)})
		Me.Ship:DoGetCargo[DrugItems]
		DrugItems:GetIterator[DrugIterator]
		if ${DrugIterator:First(exists)}
		do
		{
			if ${DrugIterator.Value.GroupID} == 313
			{
				StatusUpdate:Yellow["${DrugIterator.Value.Group} - ${DrugIterator.Value.Name} FOUND"}
				StatusUpdate:Yellow["Drug Container exists - ${Entity["Drugs"](exists)}"]
				StatusUpdate:Green["${DrugIterator.Value.Group} - ${DrugIterator.Value.Name} FOUND"}
				if !(${Entity["Drugs"](exists)})
				{
					DrugIterator.Value:Jettison
					wait ${Slow}
					DrugCount:Set[0]
					do
					{
						DrugCounter:Inc
						wait 1
						if ${DrugCounter} > 40
						{
							DrugIterator.Value:Jettison
							DrugCounter:Set[0]
						}
					}
					while !(${Entity["Cargo Container"](exists)})
					wait ${Slow}
					Entity["Cargo Container"]:SetName["Drugs"]
					wait ${Slow}
					Entity["Drugs"]:OpenCargo
					wait ${Slow}
				}
				else
				{
					StatusUpdate:Green["${DrugIterator.Value.Group} - ${DrugIterator.Value.Name} FOUND"}
					StatusUpdate:Yellow["${DrugIterator.Value.Group} - ${DrugIterator.Value.Name} FOUND"}
					StatusUpdate:Yellow["Drug Container exists - ${Entity["Drugs"](exists)}"]
					DrugIterator.Value:MoveTo[${Entity["Drugs"].ID}]
					wait ${Math.Calc[${Slow} / 2]}
				}
			}
		}
		while ${DrugIterator:Next(exists)}
		Entity["Drugs"]:CloseCargo
		wait ${Slow}
	}
	
	function BattleStations()
	{
		
		variable int64 TempEntID
		do
		{
			if ${Me.Ship.ShieldPct} < ${ChickenPct} && ${ShieldTanker}
			{
				BotCurrentState:Set["Chicken"]
				StatusUpdate:Green["Chicken - ${Me.Ship.ShieldPct}"]
				Entity[CategoryID,3]:CreateBookmark["+Chicken"]
				wait 5
				TheBookmarks:Acquire[Chicken]
				call TheBookmarks.GoTo ${MyBookmarks.Get[1]}
				return
			}
			elseif ${Me.Ship.ArmorPct} < ${ChickenPct}
			{
				BotCurrentState:Set["Chicken"]
				StatusUpdate:Green["Chicken - ${Me.Ship.ArmorPct}"]
				Entity[CategoryID,3]:CreateBookmark["+Chicken"]
				wait 5
				TheBookmarks:Acquire[Chicken]
				call TheBookmarks.GoTo ${MyBookmarks.Get[1]}
				return
			}
			
			if ${Me.GetTargets} < 1
			{
				BotCurrentState:Set["Locking"]
				TheEntities:Acquire[Category,11,200000,FALSE]
				StatusUpdate:Green["${Entities.Used} Entities"]
				TheEntities:GetRats
				StatusUpdate:Green["${EntitiesMission.Used} Mission Entities"]
				TempEntID:Set[${TheEntities.PriorityTarget}]
				StatusUpdate:Green["Lock new target"]
				if ${Entity[${TempEntID}].Distance} < ${Me.Ship.MaxTargetRange}
					Entity[${TempEntID}]:LockTarget
				wait 5
				Entity[${TempEntID}]:Orbit[${OrbitDistance}]
				do
				{
					waitframe
					waitframe
					waitframe
					waitframe
					waitframe
				}
				while ${Me.GetTargeting} > 0
			}
			if ${Me.GetTargets} > 0
				call This.ActivateAll
			BotCurrentState:Set["Killing"]
			if ${Entity[${TempEntID}].IsMoribund}
				do
				{
					BotCurrentState:Set["Target Moribund - ${Entity[${TempEntID}].IsMoribund}"]
					waitframe
					waitframe
					waitframe
					waitframe
					waitframe
					TheEntities:Acquire[Category,11,200000,FALSE]
					TheEntities:GetRats
					TempEntID:Set[${TheEntities.PriorityTarget}]
				}
				while ${Entity[${TempEntID}].IsMoribund}
			if ${EntityWatchOn}
				call StatusUpdate.White
			wait ${Slow}
		}
		while ${EntitiesMission.Used} > 0
		EVE:Execute[CmdStopShip]
	}
	
	function ActivateAll()
	{
		BotCurrentState:Set["Activate All"]
		variable iterator ObjAllOnIterator
		variable int ObjAllOnCounter
		ModuleAll:GetIterator[ObjAllOnIterator]
		if ${ObjAllOnIterator:First(exists)}
		do
		{
			if !${ObjAllOnIterator.Value.IsActive} && !${ObjAllOnIterator.Value.IsDeactivating}
			{
				ObjAllOnCounter:Set[0]
				StatusUpdate:Green["Activate - ${ObjAllOnIterator.Value.ToItem.Name}"]
				ObjAllOnIterator.Value:Click
				do
				{
					waitframe
				}
				while ${ObjAllOnIterator.Value.IsActive} && ${ObjAllOnCounter:Inc} <= ${Math.Calc[${Slow} * 3]}
			}
		}
		while ${ObjAllOnIterator:Next(exists)} && ${Me.GetTargets} > 0
	}
}