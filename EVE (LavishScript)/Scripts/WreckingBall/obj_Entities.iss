variable(script) index:entity Entities
variable(script) index:entity EntitiesToApproach
variable(script) index:entity EntitiesContainer
variable(script) index:entity EntitiesTargeted
variable(script) index:entity EntitiesMission
variable(script) index:entity EntitiesMissionContainer
variable(script) index:entity EntitiesMissionStructure
objectdef obj_Entities
{

	variable int ObjEntityCounter
	
	method Initialize()
	{
	}

	method Acquire(string EntityFilterType, int EntityFilterID, int EntityRange, bool EntityLootCheck)
	{
		BotCurrentState:Set["Acquire entities"]
		variable index:entity ObjEntities
		variable iterator ObjEntityIterator
		
		ObjEntities:Clear
		Entities:Clear
		EntitiesToApproach:Clear
		EntitiesContainer:Clear
		EVE:DoGetEntities[ObjEntities,${EntityFilterType}ID,${EntityFilterID}]
		ObjEntities:GetIterator[ObjEntityIterator]
		StatusUpdate:Yellow["${ObjEntities.Used} of ${EntityFilterType} ${EntityFilterID}"]
		if ${ObjEntityIterator:First(exists)}
		do
		{
			if ${EntityLootCheck} && ${ObjEntityIterator.Value.HaveLootRights}
				Entities:Insert[${ObjEntityIterator.Value}]
			elseif !(${EntityLootCheck})
				Entities:Insert[${ObjEntityIterator.Value}]
		}
		while ${ObjEntityIterator:Next(exists)}
		
		EVE:DoGetEntities[ObjEntities,GroupID,12]
		ObjEntities:GetIterator[ObjEntityIterator]
		StatusUpdate:Yellow["${ObjEntities.Used} containers"]
		if ${ObjEntityIterator:First(exists)}
		do
		{
			if ${ObjEntityIterator.Value.GroupID} == 12 && ${ObjEntityIterator.Value.HaveLootRights}
				EntitiesContainer:Insert[${ObjEntityIterator.Value}]
		}
		while ${ObjEntityIterator:Next(exists)}
		
		Entities:GetIterator[ObjEntityIterator]
		if ${ObjEntityIterator:First(exists)}
		do
		{
			if ${ObjEntityIterator.Value.Distance} >= ${EntityRange}
			{
				EntitiesToApproach:Insert[${ObjEntityIterator.Value}]
			}
		}
		while ${ObjEntityIterator:Next(exists)}
		
		EntitiesContainer:GetIterator[ObjEntityIterator]
		do
		{
			if ${ObjEntityIterator.Value.Distance} >= ${EntityRange}
			{
				EntitiesToApproach:Insert[${ObjEntityIterator.Value}]
			}
		}
		while ${ObjEntityIterator:Next(exists)}
	}
	
	method AcquireTargets()
	{
		BotCurrentState:Set["AcquireTargets"]
		EntitiesTargeted:Clear
		Me:DoGetTargets[EntitiesTargeted]
		StatusUpdate:Yellow["Acquired ${EntitiesTargeted.Used} targets"]
	}
	
	method GetRats()
	{
		variable iterator Purgatory
		EntitiesMission:Clear
		Entities:GetIterator[Purgatory]
		if ${Purgatory:First(exists)}
		do
		{
			if ${Purgatory.Value.Group.Find[Mission]} > 0 || ${Purgatory.Value.Group.Find[Deadspace]} > 0 || ${Purgatory.Value.Group.Find[Destructible]} > 0 || ${Purgatory.Value.Group.Find[Asteroid]} > 0
				EntitiesMission:Insert[${Purgatory.Value}]
		}
		while ${Purgatory:Next(exists)}
		Entities:Collapse
	}
	
	member:int64 PriorityTarget()
	{
		variable iterator Prioritize
		EntitiesMission:GetIterator[Prioritize]
		if ${Prioritize:First(exists)}
		do
		{
			if ${Prioritize.Value.Group.Find[Destructible]} > 0
			{
				StatusUpdate:Green["Found Destructible - ${Prioritize.Value.Group}"]
				return ${Prioritize.Value.ID}
			}
		}
		while ${Prioritize:Next(exists)}
		if ${Prioritize:First(exists)}
		do
		{
			if ${Prioritize.Value.Group.Find[Battleship]} > 0
			{
				StatusUpdate:Green["Found Battleship - ${Prioritize.Value.Group}"]
				return ${Prioritize.Value.ID}
			}
		}
		while ${Prioritize:Next(exists)}
		if ${Prioritize:First(exists)}
		do
		{
			if ${Prioritize.Value.Group.Find[Battlecruiser]} > 0
			{
				StatusUpdate:Green["Found Battlecruiser - ${Prioritize.Value.Group}"]
				return ${Prioritize.Value.ID}
			}
		}
		while ${Prioritize:Next(exists)}
		if ${Prioritize:First(exists)}
		do
		{
			if ${Prioritize.Value.Group.Find[Cruiser]} > 0
			{
				StatusUpdate:Green["Found Cruiser - ${Prioritize.Value.Group}"]
				return ${Prioritize.Value.ID}
			}
		}
		while ${Prioritize:Next(exists)}
		if ${Prioritize:First(exists)}
		do
		{
			if ${Prioritize.Value.Group.Find[Destroyer]} > 0
			{
				StatusUpdate:Green["Found Destroyer - ${Prioritize.Value.Group}"]
				return ${Prioritize.Value.ID}
			}
		}
		while ${Prioritize:Next(exists)}
		if ${Prioritize:First(exists)}
		do
		{
			if ${Prioritize.Value.Group.Find[Frigate]} > 0
			{
				StatusUpdate:Green["Found Frigate - ${Prioritize.Value.Group}"]
				return ${Prioritize.Value.ID}
			}
		}
		while ${Prioritize:Next(exists)}
		if ${Prioritize:First(exists)}
		{
			StatusUpdate:Green["Found OTHER - ${Prioritize.Value.Group}"]
			return ${Prioritize.Value.ID}
		}
	}
	
	member:int64 PriorityTargetB()
	{
		variable iterator Prioritize
		EntitiesMission:GetIterator[Prioritize]
		if ${Prioritize:First(exists)}
		do
		{
			if ${Prioritize.Value.Group.Find[Destructible]} > 0
			{
				StatusUpdate:Green["Found Destructible - ${Prioritize.Value.Group}"]
				return ${Prioritize.Value.ID}
			}
		}
		while ${Prioritize:Next(exists)}
		if ${Prioritize:First(exists)}
		do
		{
			if ${Prioritize.Value.Group.Find[Frigate]} > 0
			{
				StatusUpdate:Green["Found Frigate - ${Prioritize.Value.Group}"]
				return ${Prioritize.Value.ID}
			}
		}
		while ${Prioritize:Next(exists)}
		if ${Prioritize:First(exists)}
		do
		{
			if ${Prioritize.Value.Group.Find[Destroyer]} > 0
			{
				StatusUpdate:Green["Found Destroyer - ${Prioritize.Value.Group}"]
				return ${Prioritize.Value.ID}
			}
		}
		while ${Prioritize:Next(exists)}
		if ${Prioritize:First(exists)}
		do
		{
			if ${Prioritize.Value.Group.Find[Cruiser]} > 0
			{
				StatusUpdate:Green["Found Cruiser - ${Prioritize.Value.Group}"]
				return ${Prioritize.Value.ID}
			}
		}
		while ${Prioritize:Next(exists)}
		if ${Prioritize:First(exists)}
		do
		{
			if ${Prioritize.Value.Group.Find[Battlecruiser]} > 0
			{
				StatusUpdate:Green["Found Battlecruiser - ${Prioritize.Value.Group}"]
				return ${Prioritize.Value.ID}
			}
		}
		while ${Prioritize:Next(exists)}
		if ${Prioritize:First(exists)}
		do
		{
			if ${Prioritize.Value.Group.Find[Battleship]} > 0
			{
				StatusUpdate:Green["Found Battleship - ${Prioritize.Value.Group}"]
				return ${Prioritize.Value.ID}
			}
		}
		while ${Prioritize:Next(exists)}
		
		if ${Prioritize:First(exists)}
		{
			StatusUpdate:Green["Found OTHER - ${Prioritize.Value.Group}"]
			return ${Prioritize.Value.ID}
		}
	}
	
	function EmptyContainer(int64 EmptyContainerID, bool IsCargoContainer)
	{
		BotCurrentState:Set["Empty Container"]
		variable index:item ObjContainerItems
		variable iterator ObjContainerItemIterator
		variable string ObjEntityToLoot
		variable string ObjEntityToLootName
		variable index:int64 ObjQueuedContainerItems
		variable int ObjEntTimeout
		
		ObjQueuedContainerItems:Clear
		
		if !(${IsCargoContainer})
		{
			ObjEntityToLoot:Set["Entities"]
			ObjEntityToLootName:Set["Wreck"]
		}
		else
		{
			ObjEntityToLoot:Set["EntitiesContainer"]
			ObjEntityToLootName:Set["Floating"]
		}
		ObjEntTimeout:Set[1]
		do
		{
			Entity[${EmptyContainerID}]:OpenCargo
			wait ${Math.Calc[${Slow} / 5]}
			if ${Entity[${EmptyContainerID}].Distance} > 2300 || ${ObjEntTimeout} > 3
			{
				StatusUpdate:Yellow["Unable to open ${ObjEntityToLoot}"]
				do
				{
					if ${EVEWindow[ByCaption,${ObjEntityToLootName}](exists)}
					{
						EVEWindow[ByCaption,${ObjEntityToLootName}]:Close
						StatusUpdate:Yellow["${ObjEntityToLoot} is open CLOSE"]
					}
					wait ${Math.Calc[${Slow} / 4]}
					StatusUpdate:Yellow["${ObjEntityToLoot} not closing?"]
				}
				while ${EVEWindow[ByCaption,${ObjEntityToLootName}](exists)}
				StatusUpdate:Yellow["${ObjEntityToLoot} closed"]
				wait ${Math.Calc[${Slow} / 4]}
				return
			}
			ObjEntTimeout:Inc
		}
		while !(${EVEWindow[ByCaption,${ObjEntityToLootName}](exists)})
		StatusUpdate:Yellow["window open"]
		if ${Entity[${EmptyContainerID}].Distance} > 2300 || !(${Entity[${EmptyContainerID}](exists)})
		{
			StatusUpdate:Yellow["Stopping before we can't loot ${ObjEntityToLoot}"]
			do
			{
				if ${EVEWindow[ByCaption,${ObjEntityToLootName}](exists)}
				{
					EVEWindow[ByCaption,${ObjEntityToLootName}]:Close
					StatusUpdate:Yellow["${ObjEntityToLoot} is open CLOSE"]
				}
				wait ${Math.Calc[${Slow} / 4]}
				StatusUpdate:Yellow["${ObjEntityToLoot} not closing?"]
			}
			while ${EVEWindow[ByCaption,${ObjEntityToLootName}](exists)}
			StatusUpdate:Yellow["${ObjEntityToLoot} closed"]
			wait ${Math.Calc[${Slow} / 4]}
			return
		}
		Entity[${EmptyContainerID}]:DoGetCargo[ObjContainerItems]
		ObjContainerItems:GetIterator[ObjContainerItemIterator]
		StatusUpdate:Yellow["${ObjContainerItems.Used} items to loot"]
		StatusUpdate:Green["${ObjContainerItems.Used} items to loot"]
		if ${ObjContainerItemIterator:First(exists)}
		do
		{
			ObjContainerItemIterator.Value:MoveTo[MyShip]
			wait 1
		}
		while ${ObjContainerItemIterator:Next(exists)}
		StatusUpdate:Yellow["Done Looting"]
		wait ${Math.Calc[${Slow} / 4]}
		do
		{
			if ${EVEWindow[ByCaption,${ObjEntityToLootName}](exists)}
			{
				EVEWindow[ByCaption,${ObjEntityToLootName}]:Close
				StatusUpdate:Yellow["Close window"]
			}
			wait ${Math.Calc[${Slow} / 4]}
			StatusUpdate:Yellow["Not closing?"]
		}
		while ${EVEWindow[ByCaption,${ObjEntityToLootName}](exists)}
		Me.Ship:StackAllCargo
	}
}