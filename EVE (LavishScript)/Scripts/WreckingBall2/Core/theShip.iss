objectdef theShip
{
	function Unload(string Destination)
	{
		variable iterator Iter
		variable index:item Items
		variable int i
		
		call This.OpenItems
		call This.OpenCargo
		
		MyShip:DoGetCargo[Items]
		Items:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			while ${Iter.Value.Location.Find[${Destination}]} < 1
			{
				if ${Iter.Value.Location.Find[${Destination}]} < 1
					Debug:Spew["${Iter.Value.Location} - ${Destination}", "Unload", FALSE]
				Iter.Value:MoveTo[${Destination}]
				wait RANDOM(SLOWQ, SLOWQ)
				i:Set[RANDOM(SLOW,SLOW)]
				while ${i:Dec} > 0 && ${Iter.Value.Location.Find[${Destination}]} < 1
					waitframe
			}
			
			i:Set[RANDOM(SLOWQ,SLOWQ)]
			while ${i:Dec} > 0
				waitframe
			if ${Iter.Value.Location.Find[${Destination}]} < 1
				Debug:Spew["${Iter.Value.Location} - ${Destination}", "Unload", TRUE]
		}
		while ${Iter:Next(exists)}
	}
	
	function UnloadAll(string Destination)
	{
		variable iterator Iter
		variable index:item Items
		variable index:int64 TmpItems
		variable int i
		
		call This.OpenItems
		call This.OpenCargo
		
		MyShip:DoGetCargo[Items]
		Items:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			TmpItems:Insert[${Iter.Value.ID}]
		}
		while ${Iter:Next(exists)}
		
		if ${TmpItems.Used} > 0
		{
			;echo ${TmpItems.Used} > 0
			EVE:MoveItemsTo[${TmpItems}, ${Me.Station.ID}]
		}
		
		wait RANDOM(SLOW, SLOW)
	}
	
	function Undock()
	{
		Debug:Spew["!INSPACE", "Undock", FALSE]
		UNDOCK()
		while !INSPACE
			wait RANDOM(SLOW,SLOW)
		
		wait RANDOM(SLOW, SLOW2)
		Debug:Spew["INSPACE", "Undocked", FALSE]
	}
	
	function OpenItems()
	{
		variable int i
		while !ITEMSWINDOW
		{
			while !ITEMSWINDOW
			{
				if !ITEMSWINDOW
					Debug:Spew["!ITEMSWINDOW", "OpenHangar", FALSE]
				i:Set[RANDOM(SLOW, SLOW)]
				OPENHANGAR()
				wait RANDOM(SLOWQ, SLOWQ)
				while ${i:Dec} > 0 && !ITEMSWINDOW
					waitframe
			}
			
			i:Set[RANDOM(SLOW, SLOW)]
			while ${i:Dec} > 0
				waitframe
			if !ITEMSWINDOW
				Debug:Spew["!ITEMSWINDOW", "OpenHangar", TRUE]
		}
	}
	
	function OpenCargo()
	{
		variable int i
		while !CARGOWINDOW
		{
			while !CARGOWINDOW
			{
				if !CARGOWINDOW
					Debug:Spew["!CARGOWINDOW", "OpenCargo", FALSE]
				i:Set[RANDOM(SLOW, SLOW)]
				OPENCARGO()
				wait RANDOM(SLOWQ, SLOWQ)
				while ${i:Dec} > 0 && !CARGOWINDOW
					waitframe
			}
			
			i:Set[RANDOM(SLOW, SLOW)]
			while ${i:Dec} > 0
				waitframe
			if !CARGOWINDOW
				Debug:Spew["!CARGOWINDOW", "OpenCargo", TRUE]
		}
	}
	
	function OpenLoot(int64 TargetID)
	{
		variable int i
		variable int j = 0
		while !LOOTWINDOW
		{
			while !LOOTWINDOW
			{
				if !LOOTWINDOW
					Debug:Spew["${Entity[${TargetID}].Name} - !LOOTWINDOW - ${Entity[${TargetID}](exists)}", "OpenLoot", FALSE]
				if ${Entity[${TargetID}].Name.Find[entity]} > 0
					return 100
				OPENLOOT(${TargetID})
				wait RANDOM(SLOWQ, SLOWQ)
				i:Set[RANDOM(SLOW, SLOW)]
				while ${i:Dec} > 0 && !LOOTWINDOW && ${j:Inc} < 100
					waitframe
				if ${j} > 95
					return ${j}
			}
			
			i:Set[RANDOM(SLOWQ, SLOWQ)]
			while ${i:Dec} > 0
				waitframe
			if !LOOTWINDOW
				Debug:Spew["${Entity[${TargetID}].Name} - !LOOTWINDOW - ${Entity[${TargetID}](exists)}", "OpenLoot", TRUE]
		}
		return 0
	}
	
	function CloseLoot(int64 TargetID)
	{
		variable int i
		while LOOTWINDOW
		{
			while LOOTWINDOW
			{
				if LOOTWINDOW
					Debug:Spew["LOOTWINDOW", "CloseLoot", FALSE]
				i:Set[RANDOM(SLOW, SLOW)]
				CLOSELOOT(${TargetID})
				wait RANDOM(SLOWQ, SLOWQ)
				while ${i:Dec} > 0 && LOOTWINDOW
					waitframe
			}
			
			i:Set[RANDOM(SLOWQ, SLOWQ)]
			while ${i:Dec} > 0
				waitframe
			if LOOTWINDOW
				Debug:Spew["LOOTWINDOW", "CloseLoot", TRUE]
		}
	}
	
	function GetLoot(int64 TargetID)
	{
		variable int i
		variable index:item Loot
		variable iterator Iter
		
		call This.OpenLoot ${TargetID}
		if ${Return} >= 95
			return
		Entity[${TargetID}]:DoGetCargo[Loot]
		Debug:Spew["ENTNAME(${TargetID})", "Looting ${Loot.Used} Items", FALSE]
		Loot:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			Iter.Value:MoveTo[MyShip]
			i:Set[RANDOM(SLOWQ,SLOWQ)]
			while ${i:Dec} > 0
				waitframe
		}
		while ${Iter:Next(exists)}
		call This.CloseLoot ${TargetID}
	}
	
	function GetAllLoot(int64 TargetID)
	{
		variable index:item Loot
		variable index:int64 TmpLoot
		variable iterator Iter
		call This.OpenLoot ${TargetID}
		Entity[${TargetID}]:DoGetCargo[Loot]
		Loot:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			TmpLoot:Insert[${Iter.Value.ID}]
		}
		while ${Iter:Next(exists)}
		if ${TmpLoot.Used} > 0
			EVE:MoveItemsTo[MyShip]
		wait RANDOM(SLOW, SLOW)
	}
	
	function Approach(int64 TargetID)
	{
		if APPROACHLEFT < 1
		while APPROACHLEFT < 1
		{
			while APPROACHLEFT < 1
			{
				if APPROACHLEFT < 1
					Debug:Spew["APPROACHLEFT - ENTDISTANCE(${TargetID})", "Approach", FALSE]
				APPROACH(${TargetID})
				wait RANDOM(SLOW2, SLOW2)
				i:Set[RANDOM(SLOW, SLOW)]
				while APPROACHLEFT < 1 && ${i:Dec} > 0
					waitframe
			}
			i:Set[RANDOM(SLOW, SLOW)]
			while ${i:Dec} > 0
				waitframe
			if APPROACHLEFT < 1
				Debug:Spew["APPROACHLEFT - ENTDISTANCE(${TargetID})", "Approach", TRUE]
		}
	}
	
	function ActivateModule(string Slot, bool Activate)
	{
		variable int i
		if ${Activate}
		if !MODACTIVATED(${Slot})
		while !MODACTIVATED(${Slot})
		{
			while !MODACTIVATED(${Slot})
			{
				if !MODACTIVATED(${Slot})
					Debug:Spew["MODNAME(${Slot}) - MODACTIVATED(${Slot})", "Activate", FALSE]
				MODCLICK(${Slot})
				wait RANDOM(SLOWQ, SLOWQ)
				i:Set[RANDOM(SLOW, SLOW)]
				while !MODACTIVATED(${Slot}) && ${i:Dec} > 0
					waitframe
			}
			i:Set[RANDOM(SLOWQ, SLOWQ)]
			while ${i:Dec} > 0
				waitframe
			if !MODACTIVATED(${Slot})
				Debug:Spew["MODNAME(${Slot}) - MODACTIVATED(${Slot})", "Activate", TRUE]
		}
		if !${Activate}
		if MODACTIVATED(${Slot}) && !MODDEACTIVATING(${Slot})
		while MODACTIVATED(${Slot}) && !MODDEACTIVATING(${Slot})
		{
			while MODACTIVATED(${Slot}) && !MODDEACTIVATING(${Slot})
			{
				if MODACTIVATED(${Slot}) && !MODDEACTIVATING(${Slot})
					Debug:Spew["MODNAME(${Slot}) - MODACTIVATED(${Slot}) - !MODDEACTIVATING(${Slot})", "Deactivate", FALSE]
				MODCLICK(${Slot})
				wait RANDOM(SLOWQ, SLOWQ)
				i:Set[RANDOM(SLOW, SLOW)]
				while MODACTIVATED(${Slot}) && !MODDEACTIVATING(${Slot}) && ${i:Dec} > 0
					waitframe
			}
			
			i:Set[RANDOM(SLOWQ, SLOWQ)]
			while ${i:Dec} > 0
				waitframe
			if MODACTIVATED(${Slot}) && !MODDEACTIVATING(${Slot})
				Debug:Spew["MODNAME(${Slot}) - MODACTIVATED(${Slot}) - !MODDEACTIVATING(${Slot})", "Deactivate", TRUE]
		}
	}
	
	function MakeActiveTarget(int64 TargetID)
	{
		variable int i
		variable int j = 0
		if !ENTISTARGET(${TargetID})
		while !ENTISTARGET(${TargetID})
		{
			while !ENTISTARGET(${TargetID})
			{
				if ${Entity[${TargetID}].Name.Find[entity]} > 0
					return 100
				if !ENTISTARGET(${TargetID})
					Debug:Spew["${Entity[${TargetID}].Name} - !ENTISTARGET(${TargetID}) - ${Entity[${TargetID}](exists)}", "Target", FALSE]
				TARGET(${TargetID})
				wait RANDOM(SLOWQ, SLOWQ)
				i:Set[RANDOM(SLOW, SLOW)]
				while !ENTISTARGET(${TargetID}) && ${i:Dec} > 0 && ${j:Inc} < 100
					waitframe
				if ${j} > 95
					return ${j}
			}
			i:Set[RANDOM(SLOWQ, SLOWQ)]
			while ${i:Dec} > 0
				waitframe
			if !ENTISTARGET(${TargetID})
				Debug:Spew["${Entity[${TargetID}].Name} - !ENTISTARGET(${TargetID}) - ${Entity[${TargetID}](exists)}", "Target", TRUE]
		}
		return 0
	}
	
	function Goto(string Label)
	{
		EVE:ClearAllWaypoints
		if SOLARSYSTEM != BMSYSTEM(${Label})
		{
			while WAYPOINTS < 1
			{
				BMSETDEST(${Label})
				wait RANDOM(SLOW, SLOW)
				Debug:Spew["WAYPOINTS", "SetDest", FALSE]
			}
			
			while !AUTOPILOTON
			{
				AUTOPILOT()
				wait RANDOM(SLOW2, SLOW2)
			}
			Debug:Spew["!AUTOPILOTON", "Autopilot", FALSE]
			while SOLARSYSTEM != BMSYSTEM(${Label})
			{
				while SOLARSYSTEM != BMSYSTEM(${Label})
					wait RANDOM(SLOW,SLOW)
				wait RANDOM(SLOW5,SLOW5)
				Debug:Spew["SOLARSYSTEM - BMSYSTEM(${Label})", "AreWeThereYet", FALSE]
			}
			
		}
		Debug:Spew["SOLARSYSTEM - BMSYSTEM(${Label})", "InSystem", FALSE]
		if SOLARSYSTEM == BMSYSTEM(${Label})
		{
			Debug:Spew["BMDISTANCE(${Label}) - WARPRANGE", "Warp", FALSE]
			if BMDISTANCE(${Label}) > WARPRANGE
			{
				while SHIPMODE != WARPING
				{
					BMWARP(${Label})
					wait RANDOM(SLOW, SLOW)
				}
			}
			else
			{
				BMWARP(${Label})
				wait RANDOM(SLOW, SLOW)
				BMWARP(${Label})
				wait RANDOM(SLOW, SLOW)
			}
			Debug:Spew["SHIPMODE - WARPING", "Warping", FALSE]
			while SHIPMODE == WARPING
				wait RANDOM(SLOW, SLOW)
			
			if BMGROUPID(${Label}) == ENTGROUPSTATION
			{
				while INSPACE
				{
					if BMDISTANCE(${Label}) < 400
					{
						BMDOCK(${Label})
						wait RANDOM(SLOW2,SLOW)
						Debug:Spew["BMDISTANCE(${Label})", "Dock", FALSE]
					}
					
					if	BMDISTANCE(${Label}) > 400
					{
						BMAPPROACH(${Label})
						wait RANDOM(SLOW2,SLOW)
						Debug:Spew["BMDISTANCE(${Label})", "Approach", FALSE]
					}
				}
			}
		}
	}
}