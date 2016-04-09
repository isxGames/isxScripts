objectdef obj_Salvager
{
	variable int CurrentSalvageLocation = 0
	variable bool NeedToUnload = TRUE
	variable index:entity ToApproach
	variable int SalvCounter
	variable bool SalvShipStopped = FALSE
	

	method Initialize()
	{
	}
	
	member:int WrecksCount()
	{
		return ${Entities.Used}
	}
	
	member:int ContainerCount()
	{
		return ${EntitiesContainer.Used}
	}
	
	member:int ToApproachCount()
	{
		return ${EntitiesToApproach.Used}
	}
		
	function Begin()
	{
		BotCurrentState:Set["Begun salvager"]
		if ${Me.InStation}
		{
			SalvageStage:Set[Docked]
			CurrentSalvageLocation:Inc
		}
		else
		{
			NeedToUnload:Set[FALSE]
			SalvageStage:Set[Begin]
			TheShip:AcquireModules
			if ${ModuleTractor.Used} < 1 || ${ModuleSalvager.Used} < 1
			{
				StatusUpdate:Green["No tractors or salvagers found, ENDING"]
				StatusUpdate:Red["None of the Right modules"]
				return
			}
		}
		
		TheBookmarks:Acquire[Salvage]
		if ${MyBookmarks.Used} < 1 && ${Me.InStation}
		{
			StatusUpdate:Green["I need bookmarks when I am docked, ENDING"]
			StatusUpdate:Red["No bookmarks and docked"]
			return
		}
		elseif ${MyBookmarks.Used} > 0
		{
			DoingMore:Set[TRUE]
		}
		BotCurrentState:Set["Start loop"]
		StatusUpdate:Yellow["Stage - ${SalvageStage} Doing more - ${DoingMore}"]
		do
		{
			switch ${SalvageStage}
			{
				case Docked
					call This.Docked
					break
				case MoveOn
					call This.MoveOn
					break
				case Begin
					call This.BeginSalvage
					break
				case GoSafe
					call This.GoSafe
					break
			}
		}
		while ${StillGoing}
		BotCurrentState:Set["Not still going"]
		StatusUpdate:Yellow["Done with salvage operations"]
		StatusUpdate:Green["Done with salvage operations"]
	}
	
	function Docked()
	{
		BotCurrentState:Set["In Station"]
		StatusUpdate:Green["In Station"]
		call TheShip.EmptyCargo Hangar
		if ${NeedToUnload}
		{
			StatusUpdate:Yellow["Unloaded"]
			SalvageStage:Set[MoveOn]
			NeedToUnload:Set[FALSE]
		}
		else
		{
			StatusUpdate:Yellow["Last Stop"]
			StillGoing:Set[FALSE]
			return
		}
		if ${ModuleTractor.Used} < 1 || ${ModuleSalvager.Used} < 1
		{
			call TheShip.Undock
			TheShip:AcquireModules
			if ${ModuleTractor.Used} < 1 || ${ModuleSalvager.Used} < 1
			{
				StatusUpdate:Green["No tractors or salvagers found, ENDING"]
				StatusUpdate:Red["None of the right modules found"]
				StillGoing:Set[FALSE]
			}
		}
	}
	
	function MoveOn()
	{
		BotCurrentState:Set["Move On"]
		if ${CurrentSalvageLocation} > ${MyBookmarks.Used}
		{
			StatusUpdate:Yellow["No more locations ${HomeBookmark.ID} ${UseSafe}"]
			DoingMore:Set[FALSE]
			if ${HomeBookmark.ID} > 0 && ${UseSafe}
			{
				SalvageStage:Set[GoSafe]
				StatusUpdate:Yellow["Set Go Home"]
			}
			else
			{
				StillGoing:Set[FALSE]
				StatusUpdate:Yellow["Set to done"]
			}
			return
		}
		StatusUpdate:Yellow["Next location - ${MyBookmarks.Get[${CurrentSalvageLocation}].Label}"]
		StatusUpdate:Green["Next location - ${MyBookmarks.Get[${CurrentSalvageLocation}].Label}"]
		call TheBookmarks.GoTo ${MyBookmarks.Get[${CurrentSalvageLocation}]}
		StatusUpdate:Green["Arrived - ${MyBookmarks.Get[${CurrentSalvageLocation}].Label}"]
		StatusUpdate:Yellow["Arrived - ${MyBookmarks.Get[${CurrentSalvageLocation}].Label}"]
		SalvageStage:Set[Begin]
	}
	
	function BeginSalvage()
	{
		BotCurrentState:Set["SalvBegin"]
		variable iterator MainSalvIteratorA
		variable iterator MainSalvIteratorB
		variable int MainWaitCounter
		variable collection:int64 AlreadyTractored
		variable collection:int64 AlreadySalvaged
		variable collection:int64 AlreadyApproached
		AlreadyTractored:Clear
		AlreadySalvaged:Clear
		
		TheEntities:Acquire[Group,186,${MaxTractorRange},TRUE]
		StatusUpdate:Green["${This.WrecksCount} - Wrecks, ${This.ContainerCount} - Containers"]
		if ${This.WrecksCount} > 0 || ${This.ContainerCount} > 0
		{
			StatusUpdate:Green["Begin Salvaging"]
			do
			{
			do
			{
				if ${EntitiesToApproach.Get[1].Distance} < ${MaxTractorRange} && ${Me.GetTargets} < ${MaxTargetsAllowed} && ${EntitiesToApproach.Get[1](exists)} && !(${AlreadyLocked.Element[${EntitiesToApproach.Get[1].ID}](exists)})
				{
					StatusUpdate:Yellow["To approach in distance and lockable"]
					StatusUpdate:Green["Lock an approach target"]
					EntitiesToApproach.Get[1]:LockTarget
					AlreadyLocked:Set[${EntitiesToApproach.Get[1].ID},1]
					EntitiesToApproach:Remove[1]
					EntitiesToApproach:Collapse
				}
				if ${EntitiesToApproach.Get[1].Distance} > ${MaxTractorRange} && ${EntitiesToApproach.Get[1](exists)}
				{
					StatusUpdate:Yellow["Approaching - ${EntitiesToApproach.Get[1].Distance}"]
					StatusUpdate:Green["Approaching - ${EntitiesToApproach.Get[1].Distance}"]
					if !(${AlreadyApproached.Element[${EntitiesToApproach.Get[1].ID}](exists)})
					{
						EntitiesToApproach.Get[1]:Approach
						AlreadyApproached:Set[${EntitiesToApproach.Get[1].ID},1]
					}
					call TheShip.Afterburners TRUE
					SalvShipStopped:Set[FALSE]
				}
				if !(${EntitiesToApproach.Get[1](exists)}) && !(${SalvShipStopped})
				{
					StatusUpdate:Yellow["No more to approach stop the ship"]
					StatusUpdate:Green["No more to approach stop the ship"]
					EVE:Execute[CmdStopShip]
					SalvShipStopped:Set[TRUE]
					call TheShip.Afterburners FALSE
				}
				
				variable bool TempBool
				TheEntities:Acquire[Group,186,${MaxTractorRange},TRUE]
				BotCurrentState:Set["SalvTargeting"]
				StatusUpdate:Green["${This.WrecksCount} wrecks, ${This.ContainerCount} containers, ${EntitiesToApproach.Used} to approach"]
				StatusUpdate:Yellow["${This.WrecksCount} wrecks, ${This.ContainerCount} containers, ${EntitiesToApproach.Used} to approach"]
				TempBool:Set[!(${NoLoot})]
				if ${Math.Calc[${Me.GetTargets} + ${Me.GetTargeting}]} < ${MaxTargetsAllowed}
				{
					StatusUpdate:Yellow["I can target more"]
					call TheShip.LockMaxEntities ${TempBool} ${MaxTractorRange}
				}
				
				Entities:GetIterator[MainSalvIteratorA]
				EntitiesContainer:GetIterator[MainSalvIteratorB]
				BotCurrentState:Set["SalvLooting"]
				do
				{
					if ${MainSalvIteratorA:First(exists)} && !(${NoLoot})
					{
						do
						{
							if ${MainSalvIteratorA.Value.Distance} < 2300 && !(${MainSalvIteratorA.Value.IsWreckEmpty})
							{
								StatusUpdate:Yellow["Loot wreck"]
								StatusUpdate:Green["Loot wreck"]
								call TheEntities.EmptyContainer ${MainSalvIteratorA.Value.ID} FALSE
							}
						}
						while ${MainSalvIteratorA:Next(exists)}
					}
					if ${MainSalvIteratorB:First(exists)} && !(${NoLoot})
					{
						do
						{
							if ${MainSalvIteratorB.Value.Distance} < 2300
							{
								StatusUpdate:Yellow["Loot container"]
								StatusUpdate:Green["Loot container"]
								call TheEntities.EmptyContainer ${MainSalvIteratorB.Value.ID} TRUE
							}
						}
						while ${MainSalvIteratorB:Next(exists)}
					}
					if ${NoLoot}
					{
						wait ${Slow}
					}
					wait ${Math.Calc[${Slow} / 5]}
				}
				while ${Me.GetTargeting} > 0
				
				
				wait 5
				
				
				TheEntities:AcquireTargets
				ModuleTractor:GetIterator[MainSalvIteratorA]
				EntitiesTargeted:GetIterator[MainSalvIteratorB]
				BotCurrentState:Set["SalvTractor"]
				if ${MainSalvIteratorA:First(exists)}
				do
				{
					if !(${MainSalvIteratorA.Value.IsActive}) && !(${MainSalvIteratorA.Value.IsDeactivating}) && ${MainSalvIteratorB:First(exists)}
					{
						do
						{
							if ${MainSalvIteratorB.Value.Velocity} < ${Math.Calc[${ModuleTractor.Get[1].MaxTractorVelocity} / 2]} && ${MainSalvIteratorB.Value.Distance} > 2000 || !(${AlreadyTractored.Element[${MainSalvIteratorB.Value.ID}](exists)})
							{
								StatusUpdate:Yellow["Found Target and Tractor"]
								call TheShip.ActivateModule Tractor ${MainSalvIteratorB.Value.ID}
								SalvCounter:Set[0]
								do
								{
									waitframe
									waitframe
									waitframe
									waitframe
									waitframe
								}
								while ${MainSalvIteratorB.Value.Velocity} < 1 && ${SalvCounter:Inc} < ${Slow}
								StatusUpdate:Yellow["${SalvCounter} wait for Velocity -${MainSalvIteratorB.Value.Velocity}"]
								AlreadyTractored:Set[${MainSalvIteratorB.Value.ID},1]
								break
							}
						}
						while ${MainSalvIteratorB:Next(exists)}
					}
				}
				while ${MainSalvIteratorA:Next(exists)}
				
				TheEntities:AcquireTargets
				ModuleSalvager:GetIterator[MainSalvIteratorA]
				EntitesTargeted:GetIterator[MainSalvIteratorB]
				BotCurrentState:Set["SalvSalvager"]
				if ${MainSalvIteratorA:First(exists)}
				do
				{
					if !(${MainSalvIteratorA.Value.IsActive}) && !(${MainSalvIteratorA.Value.IsDeactivating}) && ${MainSalvIteratorB:First(exists)}
					{
						do
						{
							if !(${AlreadySalvaged.Element[${MainSalvIteratorB.Value.ID}](exists)}) && ${MainSalvIteratorB.Value.Distance} < ${MaxSalvageRange} && !(${LockedContainer.Element[${MainSalvIteratorB.Value.ID}](exists)})
							{
								call TheShip.ActivateModule Salvager ${MainSalvIteratorB.Value.ID}
								AlreadySalvaged:Set[${MainSalvIteratorB.Value.ID},1]
								break
							}
							elseif ${This.WrecksCount} < 5 && ${MainSalvIteratorB.Value.Distance} < ${MaxSalvageRange} && !(${LockedContainer.Element[${MainSalvIteratorB.Value.ID}](exists)})
							{
								call TheShip.ActivateModule Salvager ${MainSalvIteratorB.Value.ID}
								break
							}
						}
						while ${MainSalvIteratorB:Next(exists)}
					}
				}
				while ${MainSalvIteratorA:Next(exists)}
			}
			while ${This.WrecksCount} > 0 || ${This.ContainerCount} > 0
			}
			while ${SalvagerStayOn}
		}
		else
		{
			StatusUpdate:Yellow["No Wrecks to begin with"]
			StatusUpdate:Green["No wrecks moving on"]
		}
		TheShip:ResetCollections
		
		call TheShip.DrugBust
		
		if ${TheShip.ShipCargoFull}
		{
			NeedToUnload:Set[TRUE]
			StatusUpdate:Green["Cargo full, make a drop off"]
			StatusUpdate:Yellow["Cargo full make a drop off"]
		}
		if ${NeedToUnload}
		{
			SalvageStage:Set[GoSafe]
		}
		else
		{
			StatusUpdate:Yellow["Done here, deleting bookmark and moving on"]
			StatusUpdate:Green["Done here, deleting bookmark and moving on"]
			if ${MyBookmarks.Get[${CurrentSalvageLocation}](exists)}
				MyBookmarks.Get[${CurrentSalvageLocation}]:Remove
			CurrentSalvageLocation:Inc
			SalvageStage:Set[MoveOn]
		}
	}
	
	function GoSafe()
	{
		BotCurrentState:Set["SalvGoSafe"]
		StatusUpdate:Green["Going to Safe"]
		StatusUpdate:Yellow["Going to Safe"]
		call TheBookmarks.GoTo ${HomeBookmark}
		if ${NeedToUnload} && !(${Me.InStation})
		{
			StillGoing:Set[FALSE]
			StatusUpdate:Green["Full Cargo and nowhere to empty it! ENDING"]
			StatusUpdate:Yellow["Full cargo and nowhere to empty it FATAL"]
		}
		elseif !(${Me.InStation})
		{
			StillGoing:Set[FALSE]
			StatusUpdate:Green["Done and Safe"]
			StatusUpdate:Yellow["Done and Safe"]
		}
		else
		{
			SalvageStage:Set[Docked]
			StatusUpdate:Yellow["Docked after go safe"]
		}
	}
}