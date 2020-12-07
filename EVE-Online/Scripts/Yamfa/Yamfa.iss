
#if !${Extension[ISXEVE]}
Script:End
#endif

#define ALLTARGETS ${Math.Calc[${Me.TargetingCount} + ${Me.TargetCount}]}
#define MAXTARGETS ${If[${Me.MaxLockedTargets} < ${MyShip.MaxLockedTargets},${Me.MaxLockedTargets},${MyShip.MaxLockedTargets}]}

variable(script) objConfig Config
variable(script) objUI UI
variable(script) objToon Toon
variable(script) objShip Ship

variable(script) collection:objCommand Commands
variable(script) collection:int64 UsedTargets

function main()
{
	while 1
		wait 1
}

objectdef objToon
{
	variable int PulseTimer = 60
	variable float TickCount = 0
	variable int ActionCount = 0
	variable float MaxRange = 0
	
	method Initialize()
	{
		UIElement[console]:SetX[0]
		UIElement[console]:SetY[800]
		UIElement[console]:SetWidth[400]
		UIElement[console]:SetHeight[280]
		Event[ISXEVE_onFrame]:AttachAtom[This:Pulse]
	}
	
	method Shutdown()
	{
		Event[ISXEVE_onFrame]:DetachAtom[This:Pulse]
		if !${EVE.IsTextureLoadingOn}
			EVE:ToggleTextureLoading
		if !${EVE.Is3DDisplayOn}
			EVE:Toggle3DDisplay
		Toon:Action["Shutdown"]
	}
	
	method Action(string Msg)
	{
		This.ActionCount:Inc
		;Config:Debug[${This.ActionCount}, "${Math.Calc[${System.TickCount} - ${This.TickCount}]} - ${Msg}"]
		switch ${Msg}
		{
			case NULL
			case Warping
			case Traveling
			case Docked
				return
		}
		relay ${Config.Attribute[MasterSession]} -echo "${Me.Name} - ${Math.Calc[${System.TickCount} - ${This.TickCount}]} - ${Msg}"
		;if ${Config.Attribute[Role].Equal[Salvager]}
		;	echo ${Msg} ${Math.Calc[${System.TickCount} - ${This.TickCount}]}
	}
	
	method Wait(int Factor = 1)
	{
		This.PulseTimer:Inc[${Math.Calc[${This.PulseTimer} * ${Factor}]}]
	}
	
	method Relay(string Msg)
	{
		relay all "Script[yamfa].VariableScope.Commands:Set[${Msg}]"
	}
	
	method SetRange(float Rng)
	{
		This.MaxRange:Set[${Rng}]
	}
	
	method Pulse()
	{
		variable string Message
		This.TickCount:Set[${System.TickCount}]
		UI:Update
		if ${This.PulseTimer:Dec} < 1
		{
			This.PulseTimer:Set[${Math.Rand[${Config.Attribute[PulseRate]}]:Inc[${Config.Attribute[PulseRate]}]}]
			
			Message:Set[${This.Processed}]
			if !${Message.Equal[TRUE]}
			{
				Toon:Action[${Message}]
				return
			}
			
			Message:Set[${Ship.Processed}]
			if !${Message.Equal[TRUE]}
			{
				Toon:Action[${Message}]
				return
			}
			
			if ${Commands.FirstKey(exists)}
			do
			{
				Message:Set[${Commands.CurrentValue.Processed}]
				if !${Message.Equal[TRUE]}
				{
					Toon:Action[${Message}]
					return
				}
			}
			while ${Commands.NextKey(exists)}
			
			Commands:Clear
		}
	}
	
	member:string Processed()
	{
		EVE:CloseAllMessageBoxes
		EVE:CloseAllChatInvites
		
		if (${Config.Setting[Blackout]} && ${EVE.Is3DDisplayOn}) || (!${Config.Setting[Blackout]} && !${EVE.Is3DDisplayOn})
			EVE:Toggle3DDisplay
		if (${Config.Setting[Blackout]} && ${EVE.IsTextureLoadingOn}) || (!${Config.Setting[Blackout]} && !${EVE.IsTextureLoadingOn})
			EVE:ToggleTextureLoading
		
		if ${EVE.IsProgressWindowOpen}
			return ${EVE.ProgressWindowTitle}
		if !${EVE.NextSessionChange.Equal[0]}
			return ${EVE.NextSessionChange}
		
		;if ${Config.Attribute[Role].Equal[Salvager]} && ${Config.Override.SpewOn}
		;	Config:GetItems
		;if ${Config.Attribute[Role].Equal[Master]} && ${Config.Override.SpewOn} && ${Me.InSpace}
		;	Config:GetEntities
		;	
		;if ${Config.Attribute[Role].Equal[Hauler]} && ${Me.InSpace} && ${Config.Override.SpewOn}
		;{
		;	Config:GetItems
		;	Config:GetEntities
		;}
		
		return TRUE
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Ship
objectdef objShip
{
	variable bool Unloaded = FALSE
	variable bool Opened = FALSE
	variable bool Looted = FALSE
	variable bool Contraband = FALSE
	variable bool SwitchedOff = FALSE
	variable int TravelCheck = 0
	
	variable collection:objModule Modules
	
	variable index:entity Entities
	variable index:entity Targets
	
	method Initialize()
	{
		variable index:module _Modules
		variable iterator Iter
		MyShip:GetModules[_Modules]
		_Modules:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ${Iter.Value.ToItem.Type.Find[Command Processor]} > 0
				continue
			switch ${Iter.Value.ToItem.Group}
			{
				case Mining Laser
				case Frequency Mining Laser
				case Strip Miner
					Modules:Set[${Iter.Value.ID}, ${Iter.Value.ID}, ${Iter.Value.ToItem.Slot}, Miner]
					break
				case Tractor Beam
					Modules:Set[${Iter.Value.ID}, ${Iter.Value.ID}, ${Iter.Value.ToItem.Slot}, Tractor]
					break
				case Salvager
					Modules:Set[${Iter.Value.ID}, ${Iter.Value.ID}, ${Iter.Value.ToItem.Slot}, Salvager]
					break
				case Gang Coordinator
				case Armor Hardener
				case Shield Hardener
				case Damage Control
				case Sensor Booster
				case Tracking Computer
					Modules:Set[${Iter.Value.ID}, ${Iter.Value.ID}, ${Iter.Value.ToItem.Slot}, Defense]
					break
				case Propulsion Module
					Modules:Set[${Iter.Value.ID}, ${Iter.Value.ID}, ${Iter.Value.ToItem.Slot}, Speed]
					break
				case Shield Booster
				case Ancillary Shield Booster
					Modules:Set[${Iter.Value.ID}, ${Iter.Value.ID}, ${Iter.Value.ToItem.Slot}, Shield]
					break
				case Armor Repair Unit
				case Ancillary Armor Repair Unit
					Modules:Set[${Iter.Value.ID}, ${Iter.Value.ID}, ${Iter.Value.ToItem.Slot}, Armor]
					break
				case Energy Weapon
				case Hybrid Weapon
				case Projectile Weapon
				case Missile Launcher Cruise
				case Missile Launcher Heavy
				case Missile Launcher Light
				case Missile Launcher Torpedo
				case Missile Launcher Heavy Assault
				case Missile Launcher Rapid Light
				case Energy Vampire
				case Energy Destabilizer
				case ECM
				case Tracking Disruptor
				case Remote Sensor Damper
				case Target Painter
				case Stasis Web
				case Warp Scrambler
					Modules:Set[${Iter.Value.ID}, ${Iter.Value.ID}, ${Iter.Value.ToItem.Slot}, Offense]
					break
				case Shield Transporter
				case Armor Repair Projector
				case Energy Transfer Array
					Modules:Set[${Iter.Value.ID}, ${Iter.Value.ID}, ${Iter.Value.ToItem.Slot}, None]
					break
			}
		}
		while ${Iter:Next(exists)}
		if ${Toon.MaxRange} < 1
			Toon:SetRange[${MyShip.MaxTargetRange}]
	}
	
	member:string Processed()
	{
		variable string Message
		variable iterator Iter
		
		Message:Set[${This.Unload}]
		if !${Message.Equal[TRUE]}
			return ${Message}
		
		Message:Set[${This.Traveling}]
		if !${Message.Equal[FALSE]}
		{
			if !${This.SwitchedOff}
			{
				Config.Override:Warping
				This.SwitchedOff:Set[TRUE]
				UsedTargets:Clear
				Toon:Action["Travel"]
			}
			return ${Message}
		}
		This.SwitchedOff:Set[FALSE]
		
		This.Entities:Clear
		EVE:QueryEntities[This.Entities]
		
		variable index:attacker Attackers
		Me:GetAttackers[Attackers]
		if ${Attackers.Used} > 0
		{
			Toon:Relay["Guard, Guard, ${Me.CharID}"]
		}
		
		switch ${Config.Attribute[Role]}
		{
			case Salvager
				if !${Me.AutoPilotOn}
				{
					Message:Set[${This.Salvaging}]
					if !${Message.Equal[FALSE]}
						return ${Message}
				}
				break
			case Miner
				if !${Me.ToEntity.Approaching(exists)}
				{
					if ${Entity[Name =- "${Config.Attribute[UnloadLocation]}"](exists)}
					{
						Entity[Name =- "${Config.Attribute[UnloadLocation]}"]:KeepAtRange[1000]
						return MinerApproach
					}
				}
				;Message:Set[${This.CargoProcessed}]
				;if !${Message.Equal[TRUE]}
				;{
				;	return ${Message}
				;}
				break
			case Hauler
				;if !${Entity[Name =- "${Config.Attribute[UnloadLocation]}"](exists)}
				;{
				;	Local[${Config.Attribute[UnloadLocation]}].ToFleetMember:WarpTo
				;	return HaulerWarp
				;}
				if !${Me.ToEntity.Approaching(exists)}
				{
					if ${Entity[Name =- "${Config.Attribute[UnloadLocation]}"](exists)}
					{
						Entity[Name =- "${Config.Attribute[UnloadLocation]}"]:KeepAtRange[2000]
						return HaulerApproach
					}
				}
				;Message:Set[${This.CargoProcessed}]
				;if !${Message.Equal[TRUE]}
				;{
				;	return ${Message}
				;}
				break
			case Booster
				break
			case Master
				variable index:entity RelayTargets
				Me:GetTargeting[RelayTargets]
				RelayTargets:GetIterator[Iter]
				if ${Iter:First(exists)}
				do
				{
					Toon:Relay["Lock${Iter.Value.ID}, Lock, ${Iter.Value.ID}"]
				}
				while ${Iter:Next(exists)}
				
				Me:GetTargets[RelayTargets]
				RelayTargets:GetIterator[Iter]
				if ${Iter:First(exists)}
				do
				{
					Toon:Relay["Lock${Iter.Value.ID}, Lock, ${Iter.Value.ID}"]
				}
				while ${Iter:Next(exists)}
				
				if ${Me.ActiveTarget(exists)}
				{
					Toon:Relay["Lock${Me.ActiveTarget.ID}, Lock, ${Me.ActiveTarget.ID}"]
					Toon:Relay["Target${Me.ActiveTarget.ID}, Target, ${Me.ActiveTarget.ID}"]
				}
					
				if ${This.Modules.FirstKey(exists)}
				do
				{
					if ${This.Modules.CurrentValue.Activation.Equal[Offense]} && ${This.Modules.CurrentValue.IsActive}
					{
						Toon:Relay["Lock${This.Modules.CurrentValue.TargetID}, Lock, ${This.Modules.CurrentValue.TargetID}"]
						Toon:Relay["Target${This.Modules.CurrentValue.TargetID}, Target, ${This.Modules.CurrentValue.TargetID}"]
						Toon:Relay["Shoot${This.Modules.CurrentValue.TargetID}, Shoot, ${This.Modules.CurrentValue.TargetID}"]
						break
					}
				}
				while ${This.Modules.NextKey(exists)}
				
				if ${Config.Setting[Autolock]} && ALLTARGETS < MAXTARGETS
				{
					Message:Set[${This.GetTarget[Destructible]}]
					if !${Message.Equal[FALSE]}
						return ${Message}
					Message:Set[${This.GetTarget[Battleship]}]
					if !${Message.Equal[FALSE]}
						return ${Message}
					Message:Set[${This.GetTarget[Battlecruiser]}]
					if !${Message.Equal[FALSE]}
						return ${Message}
					Message:Set[${This.GetTarget[Deadspace Sleeper]}]
					if !${Message.Equal[FALSE]}
						return ${Message}
					Message:Set[${This.GetTarget[Cruiser]}]
					if !${Message.Equal[FALSE]}
						return ${Message}
					Message:Set[${This.GetTarget[Destroyer]}]
					if !${Message.Equal[FALSE]}
						return ${Message}
					Message:Set[${This.GetTarget[Frigate]}]
					if !${Message.Equal[FALSE]}
						return ${Message}
				}
				break
		}
		
		This.Modules:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			Message:Set[${Iter.Value.Processed}]
			if !${Message.Equal[TRUE]}
				return ${Message}
		}
		while ${Iter:Next(exists)}
		
		Message:Set[${This.DronesProcessed}]
		if !${Message.Equal[TRUE]}
			return ${Message}
		
		if !${Me.ToEntity.Approaching(exists)} && ${Config.Setting[Defense]}
		{
			if ${Config.Attribute[Role].Equal[Slave]} && !${Config.Attribute[Mastername].Equal[${Me.Name}]}
			{
				if ${Entity[Name =- "${Config.Attribute[Mastername]}"](exists)} && ${Config.Attribute[Orbit]} > 99
				{
					Entity[Name =- "${Config.Attribute[Mastername]}"]:Orbit[${Config.Attribute[Orbit]}]
					return Orbit
				}
			}
			elseif ${Config.Attribute[Role].Equal[Salvager]} && ${Entity[GroupID = 366](exists)}
			{
				Entity[GroupID = 366]:Approach
				return SalvGate
			}
		}
		return TRUE
	}
	
	method QueryEntities(string QString = "")
	{
		This.Targets:Clear
		variable iterator Iter
		This.Entities:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			This.Targets:Insert[${Iter.Value}]
		}
		while ${Iter:Next(exists)}
		
		variable int QID = ${LavishScript.CreateQuery[${QString}]}
		This.Targets:RemoveByQuery[${QID},FALSE]
		LavishScript:FreeQuery[${QID}]
		This.Targets:Collapse
	}
	
	member:float Distance(int64 ID)
	{
		return ${Math.Distance[${Me.ToEntity.X}, ${Me.ToEntity.Y}, ${Me.ToEntity.Z}, ${Entity[${ID}].X}, ${Entity[${ID}].Y}, ${Entity[${ID}].Z}]}
	}
	
	member:string CargoProcessed()
	{
		;;;;;;;;;;;;;;;;;;;-----------------
		return TRUE
		;;;;;;;;;;;;;;;;;;;-----------------
		if !${EVEWindow["Inventory"](exists)}
		{
			MyShip:Open
			Toon:Wait
			return ShipOpen
		}
		if ${EVEWindow["Inventory"].ChildWindow[ShipCargo].HasCapacity} && ${EVEWindow["Inventory"].ChildWindow[ShipCargo].Capacity} < 1
		{
			EVEWindow["Inventory"].ChildWindow[ShipCargo]:MakeActive
			Toon:Wait
			return InvActivate
		}
		if ${EVEWindow["Inventory"].ChildWindow[ShipOreHold].HasCapacity} && ${EVEWindow["Inventory"].ChildWindow[ShipOreHold].Capacity} < 1
		{
			EVEWindow["Inventory"].ChildWindow[ShipOreHold]:MakeActive
			Toon:Wait
			return OreActivate
		}
		if !${EVEWindow["Inventory"].ChildWindow[${Entity[Name =- "${Config.Attribute[UnloadLocation]}"].ID}](exists)} && ${Entity[Name =- "${Config.Attribute[UnloadLocation]}"](exists)}
		{
			Entity[Name =- "${Config.Attribute[UnloadLocation]}"]:Open
			Toon:Wait
			return UnloadOpen
		}
		if ${EVEWindow["Inventory"].ChildWindow[${Entity[Name =- "${Config.Attribute[UnloadLocation]}"].ID}].Capacity} < 1 && ${Entity[Name =- "${Config.Attribute[UnloadLocation]}"](exists)} && ${Entity[Name =- "${Config.Attribute[UnloadLocation]}"].Distance} < 2490
		{
			EVEWindow["Inventory"].ChildWindow[${Entity[Name =- "${Config.Attribute[UnloadLocation]}"].ID}]:MakeActive
			return UnloadActivate
		}
		
		variable index:item Items
		variable index:int64 ItemIDs
		variable iterator Iter
		variable float Remaining = 0
		if ${Config.Attribute[Role].Equal[Hauler]}
		{
			if ${Math.Calc[${EVEWindow["Inventory"].ChildWindow[ShipCargo].UsedCapacity} / ${EVEWindow["Inventory"].ChildWindow[ShipCargo].Capacity}]} > .9
			{
				EVE.Bookmark[Home]:SetDestination
				return HaulerFull
			}
			if ${EVEWindow["Inventory"].ChildWindow[${Entity[Name =- "${Config.Attribute[UnloadLocation]}"].ID}].UsedCapacity} > 0
			{
				Entity[Name =- "${Config.Attribute[UnloadLocation]}"]:GetCargo[Items]
				Items:GetIterator[Iter]
				if ${Iter:First(exists)}
				do
				{
					ItemIDs:Insert[${Iter.Value.ID}]
				}
				while ${Iter:Next(exists)}
				if ${ItemIDs.Used}
					EVE:MoveItemsTo[ItemIDs,MyShip,CargoHold]
				Toon:Wait[5]
				return UnloadHauler
			}
		}
		if ${Config.Attribute[Role].Equal[Miner]}
		{
			if ${EVEWindow["Inventory"].ChildWindow[ShipOreHold].UsedCapacity} > 0 && ${Entity[Name =- "${Config.Attribute[UnloadLocation]}"](exists)} && ${Entity[Name =- "${Config.Attribute[UnloadLocation]}"].Distance} < 2490
			{
				Remaining:Set[${Math.Calc[${EVEWindow["Inventory"].ChildWindow[${Entity[Name =- "${Config.Attribute[UnloadLocation]}"].ID}].Capacity} - ${EVEWindow["Inventory"].ChildWindow[${Entity[Name =- "${Config.Attribute[UnloadLocation]}"].ID}].UsedCapacity}]}]
				MyShip:GetOreHoldCargo[Items]
				Items:GetIterator[Iter]
				if ${Iter:First(exists)}
				do
				{
					if ${Remaining} > ${Math.Calc[${Iter.Value.Quantity} * ${Iter.Value.Volume}]}
					{
						ItemIDs:Insert[${Iter.Value.ID}]
						Remaining:Dec[${Math.Calc[${Iter.Value.Quantity} * ${Iter.Value.Volume}]}]
					}
				}
				while ${Iter:Next(exists)}
				if ${ItemIDs.Used}
				{
					EVE:MoveItemsTo[ItemIDs,${Entity[Name =- "${Config.Attribute[UnloadLocation]}"].ID},FleetHangar]
					return UnloadMiner
				}
			}
		}
		return TRUE
	}
	
	member:string DronesProcessed()
	{
		if !${Config.Setting[Drones]} && !${Ship.Drones[Space]}
			return TRUE
		if ${Ship.Drones[Hurt]}
		{
			Config.Override:Set[Drones,TRUE]
			Toon:Action["DronesHurt"]
		}
		if !${Config.Setting[Drones]} && ${Ship.Drones[Space]}
		{
			This:Drones[Recall]
			Toon:Wait
			return DrReturn
		}
		if !${Ship.Drones[Space]} && ${Ship.Drones[Bay]}
		{
			This:Drones[Launch]
			Toon:Wait
			return DrLaunch
		}
		return TRUE
	}
	
	member:bool Drones(string Loc, int64 fID = 0)
	{
		variable index:item iDrones
		variable index:activedrone aDrones
		variable iterator Iter
		switch ${Loc}
		{
			case Following
				Me:GetActiveDrones[aDrones]
				aDrones:GetIterator[Iter]
				if ${Iter:First(exists)}
				do
				{
					if ${Iter.Value.ToEntity.Following.ID.Equal[${fID}]}
						return TRUE
				}
				while ${Iter:Next(exists)}
				break
			case Hurt
				Me:GetActiveDrones[aDrones]
				aDrones:GetIterator[Iter]
				if ${Iter:First(exists)}
				do
				{
					if ${Iter.Value.ToEntity.ShieldPct} < 100
						return TRUE
				}
				while ${Iter:Next(exists)}
				break
			case Bay
				MyShip:GetDrones[iDrones]
				if ${iDrones.Used} > 0
					return TRUE
				break
			case Space
			case Idle
				Me:GetActiveDrones[aDrones]
				if ${Loc.Equal[Idle]}
					return ${If[${aDrones[1].State.Equal[0]}, TRUE, FALSE]}
				elseif ${aDrones.Used} > 0
					return TRUE
		}
		return FALSE
	}
	
	method Drones(string cmd, int64 id = 0)
	{
		variable index:int64 _Drones
		Me:GetActiveDroneIDs[_Drones]
		switch ${cmd}
		{
			case Recall
				EVE:DronesReturnToDroneBay[_Drones]
				return
			case Launch
				MyShip:LaunchAllDrones
				return
			case Guard
				EVE:DronesGuard[_Drones, ${id}]
				return
		}
	}
	
	member:string Unload()
	{
		variable index:item Items
		variable index:int64 ItemIDs
		variable iterator Iter
		if ${Me.InSpace}
		{
			if ${This.Contraband}
			{
				MyShip:GetCargo[Items]
				Items:GetIterator[Iter]
				if ${EVEWindow[Inventory].ItemID.Equal[${Entity[Name =- "Contraband"].ID}]}
				{
					if ${Iter:First(exists)}
					do
					{
						if ${Iter.Value.IsContraband}
						{
							ItemIDs:Insert[${Iter.Value.ID}]
						}
					}
					while ${Iter:Next(exists)}
					if ${ItemIDs.Used} > 0
						EVE:MoveItemsTo[ItemIDs,${Entity[Name =- "Contraband"].ID}]
					
					This.Contraband:Set[FALSE]
					return CleanContra
				}
				if ${Entity[Name =- "Contraband"](exists)}
				{
					Entity[Name =- "Contraband"]:Open
					return OpenContra
				}
				if ${Entity[TypeID = 23](exists)} && ${Entity[TypeID = 23].HaveLootRights}
				{
					Entity[TypeID = 23]:SetName["Contraband"]
					return NameContra
				}
				if !${Entity[TypeID = 23](exists)} || !${Entity[TypeID = 23].HaveLootRights}
				{
					if ${Iter:First(exists)}
					do
					{
						if ${Iter.Value.IsContraband}
						{
							Iter.Value:Jettison
							Toon:Wait[2]
							return JettisonContra
						}
					}
					while ${Iter:Next(exists)}
				}
			}
			if ${Config.Attribute[Role].Equal[Salvager]} && ${Me.ToEntity.Mode.Equal[3]}
			{
				MyShip:GetCargo[Items]
				Items:GetIterator[Iter]
				if ${Iter:First(exists)}
				do
				{
					if ${Iter.Value.IsContraband}
					{
						EVE:Execute[CmdStopShip]
						This.Contraband:Set[TRUE]
						return FoundContra
					}
				}
				while ${Iter:Next(exists)}
			}
			This.Unloaded:Set[FALSE]
			return TRUE
		}
		elseif ${Config.Setting[Unload]} && !${This.Unloaded}
		{
			if !${EVEWindow[Inventory](exists)}
			{
				MyShip:Open
				return Open
			}
			MyShip:GetCargo[Items]
			Items:GetIterator[Iter]
			if ${Iter:First(exists)}
			do
			{
				ItemIDs:Insert[${Iter.Value.ID}]
			}
			while ${Iter:Next(exists)}
			if ${ItemIDs.Used} > 0
			{
				EVE:MoveItemsTo[ItemIDs, MyStationHangar]
			}
			This.Unloaded:Set[TRUE]
			return Unload
		}
		variable index:int Waypoints
		EVE:GetWaypoints[Waypoints]
		if ${Waypoints.Used} > 0
			return TRUE
		;if ${This.Unloaded} && ${Config.Attribute[Role].Equal[Hauler]} && !${Me.InSpace}
		;{
		;	Universe[System]:SetDestination
		;	;EVE:Execute[CmdExitStation]
		;	;Toon:Wait[5]
		;	return HaulerSetDest
		;}
		return TRUE
	}
	
	member:string Traveling()
	{
		variable index:int Waypoints
		EVE:GetWaypoints[Waypoints]
		if ${Waypoints.Used} > 0
		{
			if !${Me.InSpace} && ${Waypoints.Used} > 0 && ${Config.Setting[Undock]}
			{
				if ${This.TravelCheck:Inc} > 5
				{
					EVE:Execute[CmdExitStation]
					This.TravelCheck:Set[0]
					Toon:Wait[5]
					return Undocking
				}
			}
			if ${Me.InSpace} && !${Me.AutoPilotOn} && ${Waypoints.Used} > 0 && ${Config.Setting[Autopilot]}
			{
				if ${This.TravelCheck:Inc} > 3
				{
					EVE:Execute[CmdToggleAutopilot]
					This.TravelCheck:Set[0]
					return Autopilot
				}
			}
			if ${Config.Setting[Autopilot]}
				return Traveling
		}
		
		if !${Me.InSpace}
			return Docked
		
		if ${Me.ToEntity.Mode.Equal[3]}
			return Warping
		
		if ${Me.ToFleetMember.IsFleetCommander}
		{
			variable index:agentmission Missions
			variable index:bookmark Bookmarks
			variable iterator Iter
			variable iterator Iterb
			
			EVE:GetAgentMissions[Missions]
			Missions:GetIterator[Iter]
			if ${Iter:First(exists)}
			do
			{
				if ${Iter.Value.State} > 1
				{
					Iter.Value:GetBookmarks[Bookmarks]
					Bookmarks:GetIterator[Iterb]
					if ${Iterb:First(exists)}
					do
					{
						if ${Iterb.Value.LocationType.Find[dungeon]} > 0 && ${Me.SolarSystemID.Equal[${Iterb.Value.SolarSystemID}]}
						{
							Iterb.Value:WarpFleetTo
							Toon:Wait[3]
							return FleetWarp
						}
					}
					while ${Iterb:Next(exists)}
				}
			}
			while ${Iter:Next(exists)}
			
		}
		return FALSE
	}
	
	member:string Salvaging()
	{
		variable iterator Iter
		variable index:entity SalvTargets
		
		This.Entities:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ((${Iter.Value.GroupID.Equal[186]} && !${Iter.Value.IsWreckEmpty}) || ${Iter.Value.TypeID.Equal[23]}) && !${Iter.Value.Name.Equal[Contraband]} && ${Iter.Value.HaveLootRights}
			{
				if ${EVEWindow[Inventory].ItemID.Equal[${Iter.Value.ID}]} && !${This.Looted}
				{
					EVEWindow[Inventory]:LootAll
					This.Looted:Set[TRUE]
					return Loot
				}
				elseif ${This.Looted}
					This.Looted:Set[FALSE]
				
				if ${Ship.Distance[${Iter.Value.ID}]} < 2000 && !${This.Opened}
				{
					Iter.Value:Open
					This.Opened:Set[TRUE]
					return Open
				}
				elseif ${This.Opened}
					This.Opened:Set[FALSE]
			}
			if (${Iter.Value.GroupID.Equal[186]} || ${Iter.Value.TypeID.Equal[23]}) && ${Ship.Distance[${Iter.Value.ID}]} > ${Toon.MaxRange} && !${Me.ToEntity.Approaching(exists)} && ${Iter.Value.HaveLootRights}
			{
				Iter.Value:Approach
				Toon:Wait
				return ApproachWreck
			}
		}
		while ${Iter:Next(exists)}
		
		variable float distance
		if ${Me.ActiveTarget(exists)}
		{
			distance:Set[${This.Distance[${Me.ActiveTarget.ID}]}]
			if (${Me.ActiveTarget.GroupID.Equal[186]} || ${Me.ActiveTarget.TypeID.Equal[23]}) && ${distance} > 2400 && !${This.UsedTarget[${Me.ActiveTarget.ID},Tractor]}
			{
				This.Modules:GetIterator[Iter]
				if ${Iter:First(exists)}
				do
				{
					if ${Iter.Value.Activation.Equal[Tractor]} && !${Iter.Value.IsActive}
					{
						Iter.Value:Click
						Toon:Wait
						return Tractor
					}
				}
				while ${Iter:Next(exists)}
			}
			elseif ${Me.ActiveTarget.GroupID.Equal[186]} && ${distance} < 5000 && !${This.UsedTarget[${Me.ActiveTarget.ID},Salvager]}
			{
				This.Modules:GetIterator[Iter]
				if ${Iter:First(exists)}
				do
				{
					if ${Iter.Value.Activation.Equal[Salvager]} && !${Iter.Value.IsActive}
					{
						Iter.Value:Click
						Toon:Wait
						return Salvager
					}
				}
				while ${Iter:Next(exists)}
			}
		}
		
		variable iterator mIter
		Ship.Modules:GetIterator[mIter]
		if ${mIter:First(exists)}
		do
		{
			if !${mIter.Value.IsActive}
			{
				if ${mIter.Value.Activation.Equal[Tractor]}
				{
					Me:GetTargets[SalvTargets]
					SalvTargets:GetIterator[Iter]
					if ${Iter:First(exists)}
					do
					{
						distance:Set[${Ship.Distance[${Iter.Value.ID}]}]
						if !${Ship.UsedTarget[${Iter.Value.ID},Tractor]} && ${distance} > 2400
						{
							Iter.Value:MakeActiveTarget
							return TractorTarget
						}
					}
					while ${Iter:Next(exists)}
				}
				if ${mIter.Value.Activation.Equal[Salvager]}
				{
					Me:GetTargets[SalvTargets]
					SalvTargets:GetIterator[Iter]
					if ${Iter:First(exists)}
					do
					{
						distance:Set[${Ship.Distance[${Iter.Value.ID}]}]
						if !${Iter.Value.TypeID.Equal[23]} && !${Ship.UsedTarget[${Iter.Value.ID},Salvager]} && ${distance} < 5000
						{
							Iter.Value:MakeActiveTarget
							return SalvagerTarget
						}
					}
					while ${Iter:Next(exists)}
				}
			}
		}
		while ${mIter:Next(exists)}
		
		if ALLTARGETS < MAXTARGETS
		{
			This:QueryEntities[CategoryID = 2]
			This.Entities:GetIterator[Iter]
			if ${Iter:First(exists)}
			do
			{
				distance:Set[${This.Distance[${Iter.Value.ID}]}]
				if !${Iter.Value.HaveLootRights}
					continue
				if ${Iter.Value.TypeID.Equal[23]} && ${distance} < 2490
					continue
				if !(${Iter.Value.GroupID.Equal[186]} || ${Iter.Value.TypeID.Equal[23]})
					continue
				if !${Iter.Value.IsLockedTarget} && !${Iter.Value.BeingTargeted} && ${distance} < ${Toon.MaxRange}
				{
					Iter.Value:LockTarget
					return LockSalvage
				}
			}
			while ${Iter:Next(exists)}
		}
		return FALSE
	}
	
	member:bool UsedTarget(int64 ID, string Activation = "None")
	{
		if ${This.Modules.FirstKey(exists)}
		do
		{
			if !${Activation.Equal[None]}
			{
				if ${This.Modules.CurrentValue.Activation.Equal[${Activation}]} && ${This.Modules.CurrentValue.TargetID.Equal[${ID}]}
					return TRUE
			}
			elseif ${This.Modules.CurrentValue.TargetID.Equal[${ID}]}
				return TRUE
		}
		while ${This.Modules.NextKey(exists)}
		return FALSE
	}
	
	member:string GetTarget(string Group)
	{
		variable iterator Iter
		
		This.Entities:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if !${Iter.Value.BeingTargeted} && !${Iter.Value.IsLockedTarget} && !${Iter.Value.Mode.Equal[3]} && ${Iter.Value.CategoryID.Equal[11]} && ${Ship.Distance[${Iter.Value.ID}]} < ${Toon.MaxRange} && ${Iter.Value.Group.Find[${Group}]}
			{
				Iter.Value:LockTarget
				return Lock - ${Iter.Value.Name}
			}
		}
		while ${Iter:Next(exists)}
		return FALSE
	}
	
	member:bool OffenseModule()
	{
		variable iterator Iter
		This.Modules:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if !${Iter.Value.IsActive} && ${Iter.Value.Activation.Equal[Offense]}
			{
				Iter.Value:Click
				return TRUE
			}
		}
		while ${Iter:Next(exists)}
		return FALSE
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Module
objectdef objModule
{
	variable string Slot
	variable string Activation
	
	method Initialize(int64 ID, string _Slot, string _Activation)
	{
		Slot:Set[${_Slot}]
		Activation:Set[${Config.ModuleActivation[${ID},${Slot},${_Activation}]}]
		if ${This.Range} > ${Toon.MaxRange}
			Toon:SetRange[${This.Range}]
	}
	
	member:string Processed()
	{
		if ${Me.ToEntity.IsCloaked}
			return TRUE
		if !${This.IsOnline}
			return TRUE
		if ${This.IsWaiting}
			return Blinking
		
		variable iterator Iter
		switch ${This.Activation}
		{
			case Master
				if ${This.IsActive}
					Toon:Relay[Lock${This.TargetID}, Lock, ${This.TargetID}]
					Toon:Relay[Target${This.TargetID}, Target, ${This.TargetID}]
					Toon:Relay[Shoot${This.TargetID}, Shoot, ${This.TargetID}]
				return TRUE
			case Always
				if !${This.IsActive}
				{
					This:Click
					return AlwaysClick
				}
				return TRUE
			case Defense
				if ${Config.Setting[Defense]} && !${This.IsActive}
				{
					This:Click
					return Defense
				}
				return TRUE
			case Shield
			case Armor
				if ${Config.Setting[Defense]} && !${This.IsActive} && ${MyShip.CapacitorPct} > ${Config.Attribute[Capmax]} && ${MyShip.${This.Activation}Pct} < ${Config.Attribute[${This.Activation}Pct]}
				{
					This:Click
					return ${This.Activation}On
				}
				if ${This.IsntTurningOff} && ${MyShip.${This.Activation}Pct} > ${Config.Attribute[${This.Activation}Pct]}
				{
					This:Click
					return ${This.Activation}Off
				}
			case Speed
				if ${This.IsntTurningOff} && ${MyShip.CapacitorPct} < ${Config.Attribute[Capmin]}
				{
					This:Click
					return CapSave
				}
				if !${This.IsActive} && ${This.Activation.Equal[Speed]} && ${Config.Setting[Speed]} && ${MyShip.CapacitorPct} > ${Config.Attribute[Capmax]} && ${Me.ToEntity.Approaching(exists)}
				{
					This:Click
					return Speed
				}
				if ${This.IsntTurningOff} && ${This.Activation.Equal[Speed]} && !${Me.ToEntity.Approaching(exists)}
				{
					This:Click
					return StopSpeed
				}
				return TRUE
			case Auto
				if !${This.IsActive} && ${Me.ActiveTarget(exists)} && ${Config.Setting[Shooting]}
				{
					This:Click
					return Auto
				}
				return TRUE
			case Tractor
				if ${This.IsntTurningOff} && ${Ship.Distance[${This.TargetID}]} < 2490
				{
					This:Click
					return TractorOff
				}
				return TRUE
			case Salvager
				return TRUE
			case Miner
				if !${Config.Setting[Defense]}
					return TRUE
				if !${This.IsActive}
				{
					if !${Ship.UsedTarget[${Me.ActiveTarget.ID}]}
					{
						return ${This.MiningProcessed}
					}
					else
					{
						Ship:QueryEntities[CategoryID = 25]
						break
					}
				}
				elseif ${This.IsActive} && !${Entity[${This.TargetID}](exists)}
				{
					This:Click
					return VoidTarget
				}
				return TRUE
			case Ice
				return TRUE
			case Gas
				return TRUE
			case None
				return TRUE
			case A
			case B
			case C
			case D
			case E
			case F
			case G
			case H
			case I
			case J
			case X
			case Y
			case Z
			case 1
			case 2
			case 3
			case 4
			case 5
			case 6
			case 7
			case 8
			case 9
				if !${This.IsActive} && ${Config.Setting[Defense]}
					Ship:QueryEntities[FleetTag =- "${This.Activation}"]
				else
					return TRUE
				break
			default
				if !${This.IsActive} && ${Config.Setting[Defense]}
					Ship:QueryEntities[Name =- "${This.Activation}"]
				else
					return TRUE
				break
		}
		if ${This.IsActive}
			return TRUE
		Ship.Targets:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ${Ship.Distance[${Iter.Value.ID}]} < ${This.Range}
			{
				if ${Iter.Value.IsActiveTarget} && !${This.Activation.Equal[Miner]}
				{
					This:Click
					Toon:Wait
					return "Click ${This.Activation}"
				}
				if ${This.Activation.Equal[Miner]} && !${Iter.Value.IsActiveTarget} && ${Iter.Value.IsLockedTarget} && !${Ship.UsedTarget[${Iter.Value.ID}]}
				{
					Iter.Value:MakeActiveTarget
					return "Target ${Iter.Value.Name}"
				}
				elseif !${This.Activation.Equal[Miner]} && !${Iter.Value.IsActiveTarget} && ${Iter.Value.IsLockedTarget}
				{
					Iter.Value:MakeActiveTarget
					return "Target ${Iter.Value.Name}"
				}
				if !${Iter.Value.BeingTargeted} && !${Iter.Value.IsLockedTarget} && ALLTARGETS < MAXTARGETS && !${Iter.Value.Mode.Equal[3]}
				{
					if ${This.Activation.Equal[Miner]} && !${UsedTargets.Element[${Iter.Value.ID}](exists)} && ${Me.TargetingCount} < 1 && ALLTARGETS < 3
					{
						relay all "Script[yamfa].VariableScope.UsedTargets:Set[${Iter.Value.ID},${Iter.Value.ID}]"
						Iter.Value:LockTarget
						return "Lock ${Iter.Value.Name}"
					}
					elseif !${This.Activation.Equal[Miner]}
					{
						Iter.Value:LockTarget
						return "Lock ${Iter.Value.Name}"
					}
				}
			}
		}
		while ${Iter:Next(exists)}
		if ${Iter:First(exists)} && ${This.Activation.Equal[Miner]}
		do
		{
			if ${Ship.Distance[${Iter.Value.ID}]} < ${This.Range}
			{
				if !${Iter.Value.IsActiveTarget} && ${Iter.Value.IsLockedTarget} && !${Ship.UsedTarget[${Iter.Value.ID}]}
				{
					Iter.Value:MakeActiveTarget
					return "Target ${Iter.Value.Name}"
				}
				if !${Iter.Value.BeingTargeted} && !${Iter.Value.IsLockedTarget} && ALLTARGETS < MAXTARGETS && !${Iter.Value.Mode.Equal[3]} && ALLTARGETS < 3
				{
					relay all "Script[yamfa].VariableScope.UsedTargets:Set[${Iter.Value.ID},${Iter.Value.ID}]"
					Iter.Value:LockTarget
					return "Lock ${Iter.Value.Name}"
				}
			}
		}
		while ${Iter:Next(exists)}
		return TRUE
	}
	
	member:string MiningProcessed()
	{
		variable index:item Ammo
		variable iterator Iter
		
		if ${This.HasCharges}
		{
			if ${MyShip.Module[${This.Slot}].Charge.Type.Find[${Entity[${Me.ActiveTarget.ID}].Group}]} < 1
			{
				MyShip.Module[${This.Slot}]:GetAvailableAmmo[Ammo]
				Ammo:GetIterator[Iter]
				if ${Iter:First(exists)}
				do
				{
					if ${Iter.Value.Type.Find[${Entity[${Me.ActiveTarget.ID}].Group}]} > 0
					{
						MyShip.Module[${This.Slot}]:ChangeAmmo[${Iter.Value.ID}]
						return SwapCrystal
					}
				}
				while ${Iter:Next(exists)}
				MyShip.Module[${This.Slot}]:UnloadToCargo
				return UnloadCrystal
			}
			else
			{
				This:Click
				return MinerClick
			}
		}
		else
		{
			MyShip.Module[${This.Slot}]:GetAvailableAmmo[Ammo]
			Ammo:GetIterator[Iter]
			if ${Iter:First(exists)}
			do
			{
				if ${Iter.Value.Type.Find[${Entity[${Me.ActiveTarget.ID}].Group}]}
				{
					MyShip.Module[${This.Slot}]:ChangeAmmo[${Iter.Value.ID}]
					return ReloadCrystal
				}
			}
			while ${Iter:Next(exists)}
		}
		This:Click
		return NoCrysClick
	}
	
	member:bool IsntTurningOff()
	{
		return ${If[${This.IsActive} && !${This.IsDeactivating}, TRUE, FALSE]}
	}
	
	member:bool IsActive()
	{
		return ${MyShip.Module[${This.Slot}].IsActive}
	}
	
	member:bool IsOnline()
	{
		return ${MyShip.Module[${This.Slot}].IsOnline}
	}
	
	member:bool IsDeactivating()
	{
		return ${MyShip.Module[${This.Slot}].IsDeactivating}
	}
	
	member:bool IsWaiting()
	{
		if ${MyShip.Module[${This.Slot}].IsWaitingForActiveTarget}
		{
			This:Click
			return TRUE
		}
		return FALSE
	}
	
	member:int64 TargetID()
	{
		return ${If[${This.IsActive}, ${MyShip.Module[${This.Slot}].TargetID}, 0]}
	}
	
	member:bool IsReloading()
	{
		return ${If[${MyShip.Module[${This.Slot}].IsReloadingAmmo} || ${MyShip.Module[${This.Slot}].IsChangingAmmo}, TRUE, FALSE]}
	}
	
	member:bool HasCharges()
	{
		return ${MyShip.Module[${This.Slot}].Charge(exists)}
	}
	
	member:string Group()
	{
		return ${MyShip.Module[${This.Slot}].ToItem.Group}
	}
	
	member:float Range()
	{
		if ${This.Group.Find[Missile]} > 0
			return ${Math.Calc[${MyShip.Module[${This.Slot}].Charge.MaxVelocity} + ${MyShip.Module[${This.Slot}].Charge.MaxFlightTime}]}
		elseif ${This.Group.Find[Shield]} > 0
			return ${MyShip.Module[${This.Slot}].ShieldTransferRange}
		elseif ${This.Group.Find[Energy]} > 0
			return ${MyShip.Module[${This.Slot}].TransferRange}
		else
			return ${Math.Calc[${MyShip.Module[${This.Slot}].AccuracyFalloff} + ${MyShip.Module[${This.Slot}].OptimalRange}]}
	}
	
	method Click()
	{
		MyShip.Module[${This.Slot}]:Click
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Config
objectdef objConfig
{
	variable objOverride Override
	variable settingsetref ConfigSet
	variable settingsetref DebugSet
	variable settingsetref EntityListing
	variable settingsetref ItemListing
	
	method Initialize()
	{
		LavishSettings:AddSet[config${Me.Name}]
		LavishSettings[config${Me.Name}]:Import[${Me.Name}.xml]
		LavishSettings[config${Me.Name}]:AddSet[${MyShip.Name}]
		ConfigSet:Set[${LavishSettings.FindSet[config${Me.Name}].FindSet[${MyShip.Name}]}]
		
		LavishSettings:AddSet[debug${Me.Name}]
		DebugSet:Set[${LavishSettings.FindSet[debug${Me.Name}]}]
		
		LavishSettings:AddSet[EntityListing]
		LavishSettings[EntityListing]:Import[EntityListing.xml]
		EntityListing:Set[${LavishSettings.FindSet[EntityListing]}]
		
		LavishSettings:AddSet[ItemListing]
		LavishSettings[ItemListing]:Import[ItemListing.xml]
		ItemListing:Set[${LavishSettings.FindSet[ItemListing]}]
		
		if ${ConfigSet.FindSetting[FirstTime,TRUE].String}
		{
			ConfigSet:AddSetting[Autopilot, TRUE]
			ConfigSet:AddSetting[Undock, TRUE]
			ConfigSet:AddSetting[Defense, TRUE]
			ConfigSet:AddSetting[Speed, TRUE]
			ConfigSet:AddSetting[Autolock, FALSE]
			ConfigSet:AddSetting[Locking, FALSE]
			ConfigSet:AddSetting[Targeting, FALSE]
			ConfigSet:AddSetting[Shooting, FALSE]
			ConfigSet:AddSetting[Drones, FALSE]
			ConfigSet:AddSetting[Blackout, FALSE]
			ConfigSet:AddSetting[Unload, FALSE]
			ConfigSet:AddSetting[FirstTime, FALSE]
			
			ConfigSet:AddSetting[Pulserate, 40]
			ConfigSet:AddSetting[Shieldpct, 80]
			ConfigSet:AddSetting[Armorpct, 80]
			ConfigSet:AddSetting[Capmin, 30]
			ConfigSet:AddSetting[Capmax, 60]
			ConfigSet:AddSetting[Orbit, 5000]
			ConfigSet:AddSetting[UnloadLocation, Athena Doomhammer]
			ConfigSet:AddSetting[Mastername, ${Me.Name}]
			ConfigSet:AddSetting[Mastersession, ${Session}]
			ConfigSet:AddSetting[Role, Slave]
		}
		
		ConfigSet:AddSet[Modules]
	}
	
	method Debug(int Count, string Msg)
	{
		DebugSet:AddSetting[${Count}, ${Msg}]
	}
	
	method Update(string Attr, string Val)
	{
		ConfigSet:AddSetting[${Attr}, ${Val}]
	}
	
	method UpdateMaster(string Name, string Sess)
	{
		if ${ConfigSet.FindSetting[Role].String.Equal[Salvager]} || ${ConfigSet.FindSetting[Role].String.Equal[Logistic]} || ${ConfigSet.FindSetting[Role].String.Equal[Miner]} || ${ConfigSet.FindSetting[Role].String.Equal[Hauler]}
			return
		else
		{
			ConfigSet:AddSetting[Role, Slave]
			ConfigSet:AddSetting[Mastername, ${Name}]
			ConfigSet:AddSetting[Mastersession, ${Sess}]
		}
	}
	
	method Shutdown()
	{
		if ${Config.Attribute[Role].Equal[Master]} || ${Config.Attribute[Role].Equal[Hauler]}
		{
			LavishSettings[EntityListing]:Export[EntityListing.xml]
		}
		if ${Config.Attribute[Role].Equal[Salvager]} || ${Config.Attribute[Role].Equal[Hauler]}
		{
			LavishSettings[ItemListing]:Export[ItemListing.xml]
		}
		LavishSettings[ItemListing]:Clear
		LavishSettings[EntityListing]:Remove
		LavishSettings[config${Me.Name}]:Export[${Me.Name}.xml]
		LavishSettings[config${Me.Name}]:Remove
		;LavishSettings[debug${Me.Name}]:Sort
		;LavishSettings[debug${Me.Name}]:Export[${Me.Name}.xml]
		LavishSettings[debug${Me.Name}]:Remove
	}
	
	member:string ModuleActivation(int64 ID, string Slot, string Activation)
	{
		ConfigSet.FindSet[Modules].FindSetting[${ID}, ${Activation}]:AddAttribute[Group, ${MyShip.Module[${Slot}].ToItem.Group}]
		ConfigSet.FindSet[Modules].FindSetting[${ID}, ${Activation}]:AddAttribute[Slot, ${Slot}]
		return ${ConfigSet.FindSet[Modules].FindSetting[${ID}, ${Activation}].String}
	}
	
	member:string Attribute(string Attr)
	{
		return ${ConfigSet.FindSetting[${Attr}, 0].String}
	}
	
	member:string Setting(string Attr)
	{
		return ${If[${ConfigSet.FindSetting[${Attr}, FALSE].String} && !${This.Override.${Attr}},TRUE,FALSE]}
	}
	
	method GetEntities()
	{
		if !${Me.InSpace}
			return
		variable settingsetref EntityCat
		variable settingsetref EntityGroup
		variable settingsetref EntityType
		variable string Category
		variable string Group
		variable string TypeName
		variable int CatID
		variable int GroupID
		variable int TypeID
		variable int Bounty
		variable string Name
		variable iterator Iter
		variable bool Changed = FALSE

		Ship.Entities:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			Category:Set[${Iter.Value.Category}]
			Group:Set[${Iter.Value.Group}]
			TypeName:Set[${Iter.Value.Type}]
			CatID:Set[${Iter.Value.CategoryID}]
			GroupID:Set[${Iter.Value.GroupID}]
			TypeID:Set[${Iter.Value.TypeID}]
			Bounty:Set[${Iter.Value.Bounty}]
			Name:Set[${Iter.Value.Name}]
			
			if ${Category.Find[Null]} > 0 || ${Group.Find[Null]} > 0 || ${TypeName.Find[Null]} > 0 || ${Name.Find[Null]} > 0 || ${CatID} < 1 || ${GroupID} < 1 || ${TypeID} < 1
				continue
			switch ${GroupID}
			{
				case 227
				case 226
				case 9
				case 8
				case 7
				case 15
				case 1025
					continue
			}
			
			if !${This.EntityListing.FindSet[${Category}](exists)}
			{
				This.EntityListing:AddSet["${Category}"]
				This.EntityListing:Sort
				This.EntityListing.FindSet[${Category}]:AddAttribute[CatID,${CatID}]
			}
			EntityCat:Set[${This.EntityListing.FindSet[${Category}]}]
			if !${EntityCat.FindSet[${Group}](exists)}
			{
				EntityCat:AddSet["${Group}"]
				EntityCat:Sort
				EntityCat.FindSet[${Group}]:AddAttribute[GroupID,${GroupID}]
			}
			EntityGroup:Set[${EntityCat.FindSet[${Group}]}]
			if !${EntityGroup.FindSetting[${TypeName}](exists)}
			{
				EntityGroup:AddSet["${TypeName}", ${TypeID}]
				EntityGroup:Sort
				EntityGroup.FindSet[${TypeName}]:AddAttribute[TypeID,${TypeID}]
			}
			EntityType:Set[${EntityGroup.FindSet[${TypeName}]}]
			if !${EntityType.FindSetting[${Name}](exists)}
			{
				Toon:Action["C-${Category}, G-${Group}, T-${TypeName}, N-${Name}, B-${Bounty}"]
				EntityType:AddSetting["${Name}",${Bounty}]
				EntityType:Sort
			}
		}
		while ${Iter:Next(exists)}
	}
	
	method GetItems()
	{
		variable settingsetref ItemCat
		variable settingsetref ItemGroup
		variable string Category
		variable string Group
		variable string TypeName
		variable int CatID
		variable int GroupID
		variable int TypeID
		
		variable index:item MyScan
		variable iterator Iter

		if !${Me.InSpace}
			Me.Station:GetHangarItems[MyScan]
		else
			MyShip:GetCargo[MyScan]
		MyScan:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			Category:Set[${Iter.Value.Category}]
			Group:Set[${Iter.Value.Group}]
			TypeName:Set[${Iter.Value.Type}]
			CatID:Set[${Iter.Value.CategoryID}]
			GroupID:Set[${Iter.Value.GroupID}]
			TypeID:Set[${Iter.Value.TypeID}]
			
			if ${Category.Find[Null]} > 0 || ${Group.Find[Null]} > 0 || ${Type.Find[Null]} > 0 || ${CatID} < 1 || ${GroupID} < 1 || ${TypeID} < 1
				continue
			
			if !${ItemListing.FindSet[${Category}](exists)}
			{
				ItemListing:AddSet["${Category}"]
				ItemListing:Sort
				ItemListing.FindSet[${Category}]:AddAttribute[CatID,${CatID}]
			}
			ItemCat:Set[${ItemListing.FindSet[${Category}]}]
			if !${ItemCat.FindSet[${Group}](exists)}
			{
				ItemCat:AddSet["${Group}"]
				ItemCat:Sort
				ItemCat.FindSet[${Group}]:AddAttribute[GroupID,${GroupID}]
			}
			ItemGroup:Set[${ItemCat.FindSet[${Group}]}]
			if !${ItemGroup.FindSetting[${TypeName}](exists)}
			{
				;Toon:Action["C-${Category}, G-${Group}, T-${TypeName}"]
				echo "C-${Category}, G-${Group}, T-${TypeName}"
				ItemGroup:AddSetting["${TypeName}", ${TypeID}]
				ItemGroup:Sort
			}
		}
		while ${Iter:Next(exists)}
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Override
objectdef objOverride
{
	variable bool Defense = TRUE
	variable bool Shooting = TRUE
	variable bool Drones = TRUE
	variable bool Autolock = TRUE
	variable bool DebugOn = FALSE
	variable bool SpewOn = FALSE
	
	method Warping()
	{
		This.Defense:Set[TRUE]
		This.Locking:Set[TRUE]
		This.Shooting:Set[TRUE]
		This.Drones:Set[TRUE]
		This.Autolock:Set[TRUE]
	}
	
	method Set(string Attr, string Val)
	{
		variable string tmp = ${Attr.Left[1].Upper}
		tmp:Concat[${Attr.Right[${Attr.Length:Dec}]}]
		This.${tmp}:Set[${Val}]
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Command
objectdef objCommand
{
	variable string Cmd
	variable string ID
	
	method Initialize(string _Cmd, string _ID)
	{
		Cmd:Set[${_Cmd}]
		ID:Set[${_ID}]
	}
	
	member:string Processed()
	{
		switch ${This.Cmd}
		{
			case Lock
				if ALLTARGETS >= MAXTARGETS || ${Entity[${This.ID}].IsLockedTarget} || ${Entity[${This.ID}].BeingTargeted} || ${Ship.Distance[${This.ID}]} > ${Toon.MaxRange} || !${Entity[${This.ID}](exists)} || !${Config.Setting[Locking]}
					return TRUE
				else
				{
					Entity[${This.ID}]:LockTarget
					return CmdLock
				}
			case Target
				if !${Entity[${This.ID}].IsLockedTarget} || ${Me.ActiveTarget.ID.Equal[${This.ID}]} || !${Config.Setting[Targeting]} || ${Config.Attribute[Role].Equal[Master]}
					return TRUE
				else
				{
					Entity[${This.ID}]:MakeActiveTarget
					return CmdTarget
				}
			case Shoot
				Toon:Action[Shoot!${Entity[${This.ID}].IsActiveTarget} || !${Config.Setting[Shooting]}]
				if !${Entity[${This.ID}].IsActiveTarget} || !${Config.Setting[Shooting]}
					return TRUE
				else
				{
					if !${Ship.OffenseModule}
						return TRUE
					else
						return CmdShoot
				}
			case Guard
				if !${Config.Setting[Drones]} || !${Ship.Drones[Space]} || !${Ship.Drones[Idle]} || ${Ship.Drones[Following,${This.ID}]}
					return TRUE
				else
				{
					Ship:Drones[Guard, ${This.ID}]
					return Guard
				}
			case Undock
				if ${Me.InSpace} || !${Config.Setting[Undock]}
					return TRUE
				else
				{
					EVE:Execute[CmdExitStation]
					return CmdUndock
				}
			case Gate
				if !${Me.InSpace} || ${Config.Attribute[Role].Equal[Salvager]}
					return TRUE
				if ${Entity[GroupID = 366](exists)}
				{
					Entity[GroupID = 366]:${This.ID}
					return TRUE
				}
				break
			case Retreat
				if !${Me.InSpace}
					return TRUE
				if ${This.ID.Equal[Dock]}
				{
					if !${EVE.Bookmark[Home](exists)}
						return TRUE
					if ${EVE.Bookmark[Home].JumpsTo} > 0
						EVE.Bookmark[Home]:SetDestination
					else
						EVE.Bookmark[Home].ToEntity:Dock
					return Docking
				}
				elseif ${This.ID.Equal[Retreat]}
				{
					Entity[GroupID = 6]:WarpTo[100000]
					return Running
				}
			case Salvager
				if !${Config.Attribute[Role].Equal[Salvager]}
					return TRUE
				if ${This.ID.Equal[Autopilot]}
				{
					EVE:Execute[CmdToggleAutopilot]
					return TRUE
				}
				elseif ${Entity[GroupID = 366](exists)}
				{
					Entity[GroupID = 366]:Activate
					return TRUE
				}
				elseif ${Local[${Config.Attribute[MasterName]}](exists)}
				{
					Local[${Config.Attribute[MasterName]}].ToFleetMember:WarpTo
					return TRUE
				}
				else
				{
					EVE:Execute[CmdToggleAutopilot]
					return TRUE
				}
		}
		return TRUE
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  UI
objectdef objUI
{
	variable collection:float Alpha
	
	method Initialize()
	{
		ui -load ui.xml
	}
	
	method Shutdown()
	{
		ui -unload ui.xml
	}
	
	method Update()
	{
		if ${Alpha.FirstKey(exists)}
		do
		{
			if ${Alpha.CurrentValue.Equal[1]}
				continue
			if ${Alpha.CurrentValue} < 0.8
				Alpha.CurrentValue:Inc[.111]
			if ${Alpha.CurrentValue} > 0.8
				Alpha.CurrentValue:Set[0.8]
		}
		while ${Alpha.NextKey(exists)}
	}
}