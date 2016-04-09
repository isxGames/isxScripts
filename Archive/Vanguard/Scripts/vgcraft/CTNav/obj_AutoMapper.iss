/*
	AutoMapper Class
	
	Automatically generates LavishNav world maps as the world is travelled.
	
	Instantiated as Navigator.AutoMapper
	
	-- CyberTech (cybertech@gmail.com)
	

TODO:
	Connect on chunk change
	doors
	Add guards to POI list - they are NPC. will need substr check. do not add all npc.

	Mark collidable objects that can be jumped?

	For forges and such, that are bound on 1 side very closely
	Find nearest collidable Actor Collide1
	figure out which heading from Forge is Collide1
	... do something from here... process other 3 directions? what region type?

	Check for large z-changes from lastregion to currentregion. do not connect, if so.
	Find way to detect remote z drops (or rises) -- amadeus will have time to find this after isxeve, probably.
		Actor[from,x+100,y+100,me.z,zradius,100] - if it's null, there was no actor within 100 up or down of me.z @ the new location
		so ground must be at least that far away.  This might work.  +100 is arbitrary, would probly make sense to increase it in 6 directions
		
		Find out what the maxium drop height is w/o takingdmg.
		
	PlotDynamicBoxFromPoint, make box height +- dynamic after we get ground height detection.
	
*/

objectdef obj_AutoMapper
{
	; Private (well, intended so) variables
	variable string navConfigDir = "${Script.CurrentDirectory}/"
	variable string xmlMapFile = "Maps/Telon.xml"
	variable string lsoMapFile =	 "Maps/Telon.lso"

	; Max Distance between region needed checks - in LOC UNITS
	variable int Max_Distance_Between_Checks = 100
	variable int Max_Distance_Between_POI_Checks = 20000
	variable int Max_Region_Size = 250
		
	variable bool	Mapping = TRUE
	variable bool	MapPOIs = TRUE
	
	variable point3f LastMapPulseLocation
	variable point3f LastPOICheckLocation

	variable lnavregionref InvalidRegion = 4294967295
	variable lnavregionref PreviousRegion
	variable lnavregionref LastCreatedRegion
	variable obj_CollisionMath Collision

	; Public variables
	variable lnavregionref CurrentZone
	variable lnavregionref CurrentRegion

	method Initialize()
	{
		This.LastMapPulseLocation:Set[-9999999,-9999999,-9999999]
		This.LastPOICheckLocation:Set[-9999999,-9999999,-9999999]

		This:Load
		This:ZoneChanged

		This.CurrentRegion:SetRegion[${This.CurrentZone.BestContainer[${Me.Location}].ID}]
		Event[OnFrame]:AttachAtom[This:Pulse]
	}

	method Shutdown()
	{
		Event[OnFrame]:DetachAtom[This:Pulse]
		This:Save
	}

	method Pause()
	{
		This.Running:Set[FALSE]
	}
	
	method Resume()
	{
		This.Running:Set[TRUE]
	}
	
	method Pulse()
	{
		if !${This.Mapping}
		{
			return
		}
		declarevariable Distance float local ${Math.Distance[${Me.Location},${This.LastMapPulseLocation}]}
		
		if (${Distance} > ${This.Max_Distance_Between_Checks})
		{
			This.LastMapPulseLocation:Set[${Me.X}, ${Me.Y}, ${Me.Z}]
			
			if ${This.IsMapped[${This.LastMapPulseLocation}]}
			{
				This:ConnectNeighbours[${This.CurrentRegion}]
			} 
			elseif (${This.CurrentZone.ID} != ${LNavRegion[${This.MapName}].ID})
			{
				This:ZoneChanged
			} 
			elseif (${This.CurrentZone.ID} == ${This.CurrentRegion.ID})
			{
				This:PlotDynamicBoxFromPoint[${CurrentZone}, ${This.LastMapPulseLocation}]
			}
			This.PreviousRegion:SetRegion[${This.CurrentRegion.ID}]
			This.CurrentRegion:SetRegion[${This.CurrentZone.BestContainer[${This.LastMapPulseLocation}].ID}]
		}
		if ${This.MapPOIs}
		{
			Distance:Set[${Math.Distance[${Me.Location.X},${Me.Location.Y},${This.LastPOICheckLocation.X},${This.LastPOICheckLocation.Y}]}]
			if (${Distance} > ${This.Max_Distance_Between_POI_Checks})
			{
				This.LastPOICheckLocation:Set[${Me.X}, ${Me.Y}, ${Me.Z}]
				Navigator.AutoMapper:MapPointsOfInterest
			}
		}
	}

	method Save()
	{
		Navigator:EchoHUD["Saving map state..."]
		LNavRegion[Telon]:Export["${navConfigDir}${xmlMapFile}"]
		LNavRegion[Telon]:Export[-lso,"${navConfigDir}${lsoMapFile}"]
	}

	method Load()
	{
		variable filepath Dir = "${navConfigDir}"
		LavishNav:Clear

		if ${Dir.FileExists[${xmlMapFile}]}
		{
			if ${LNavRegion[Telon](exists)}
			{
				LNavRegion[Telon]:Remove
			}
			LavishNav:Import["${navConfigDir}${xmlMapFile}"]
			Navigator:EchoHUD["Loaded ${xmlMapFile}"]
		}

		if !${LNavRegion[Telon](exists)}
		{
			This:InitializeRegions
		}
	}


	method InitializeRegions()
	{
		LavishNav.Tree:AddChild[universe,"Telon",-unique]
		LNavRegion[Telon]:AddChild[universe,${This.MapName},-unique,-coordinatesystem]
	}

	member:string ZoneText()
	{
		return ${Me.Chunk.ShortName}
	}

	member:string MapName()
	{
		declarevariable Name string local ${Me.Chunk.MapName}
		return ${Name.Token[1,.]}
	}

	method ZoneChanged()
	{
		if !${LNavRegion[Telon].FindRegion[${This.MapName}](exists)}
		{
			LNavRegion[Telon]:AddChild[universe,${This.MapName},-unique,-coordinatesystem]
		}

		CurrentZone:SetRegion[${LNavRegion[Telon].FindRegion[${This.MapName}].ID}]
		This:Save
	}

	member:bool IsMapped(float X, float Y, float Z)
	{
		variable point3f Location
		Location:Set[${X},${Y},${Z}]
		
		variable lnavregionref Container

		Container:SetRegion[${This.CurrentZone.BestContainer[${Location}].ID}]
		if !${Container.Type.Equal[Universe]} && ${Container.Contains[${Location}]}
		{
			return TRUE
		}
		return FALSE
	}

	member:lnavregionref BestorNearestContainer(float X, float Y, float Z)
	{
		variable point3f Location
		Location:Set[${X},${Y},${Z}]

		variable lnavregionref Container
		
		if ${This.IsMapped[${Location}]}
		{
			return ${This.BestContainer[${Location}]}
		}
		else
		{
			return ${This.NearestChild[${Location}]}
		}
	}
	member:lnavregionref BestContainer(float X, float Y, float Z)
	{
		variable point3f Location
		Location:Set[${X},${Y},${Z}]

		variable lnavregionref Container

		Container:SetRegion[${This.CurrentZone.BestContainer[${Location}].ID}]
		if !${Container.Type.Equal[Universe]} && ${Container.Contains[${Location}]}
		{
			return ${Container}
		}
		return ${InvalidRegion}
	}

	member:lnavregionref NearestChild(float X, float Y, float Z)
	{
		variable point3f Location
		Location:Set[${X},${Y},${Z}]

		variable lnavregionref Container

		Container:SetRegion[${This.CurrentZone.NearestChild[${Location}].ID}]
		if !${Container.Type.Equal[Universe]} && ${Container.Contains[${Location}]}
		{
			return ${Container}
		}
		return ${InvalidRegion}
	}

	method MapPawn(int64 ID, string GroupName)
	{
		if !${Pawn[id,${ID}](exists)}
		{
			return
		}

		declarevariable Name string local ${Pawn[id,${ID}].Name}
		if ${Name.Length} == 1
		{
			; Don't worry about 0-length named items
			return
		}
		declarevariable ActorName string local ${Pawn[id,${ID}].ToActor.Name}
		variable point3f Location
		Location:Set[${Pawn[id,${ID}].Location}]
		declarevariable RegionName string local "${Name}_${Location.X.Int}-${Location.Y.Int}"

		if ${CurrentZone.FindRegion[${RegionName}](exists)}
		{
			; We don't need to check for the location, the region is stored with coords
			;DebugPrint("AutoMapper:MapPawn: ${RegionName} already mapped")
			return
		}
		
		Navigator:EchoHUD["  Noted ${GroupName}:${Name} (Region: ${RegionName})"]

		; Attempt to create an auto-adjusted sphere around the npc at a max size of 2.5 meters, so that the
		; npc is interactable from all points within the region.
		This:PlotDynamicSphereFromPawn[${CurrentZone}, ${ID}, 250, ${RegionName}]
		LNavRegionGroup[${GroupName}]:Add[${RegionName}]
		if !${Navigator.FindPath[${This.LastMapPulseLocation}, ${Location}]}
		{
			Navigator:EchoHUD["  Warning: No Path found to ${Name} from here; go visit them!"]
		}
	}

	method MapPointsOfInterest()
	{
		variable int CurrentPawn = 0
		while (${CurrentPawn:Inc}<=${VG.PawnCount})
		{
  			if !${Pawn[${CurrentPawn}](exists)}
  			{
  				next
     		}
     		Switch ${Pawn[${CurrentPawn}].Type}
     		{
     			case Me
     			case NPC
     			case PC
     			case AggroNPC
     			case Corpse
     			case Pet
     			case MyPet
     			case Attackable
     			case Group Member
     				; We don't care about these types, marking them on a map wouldn't be much use
     				break
     			case Altar
				case Resource
     			case QuestNPC
     			case Trainer
     			case Merchant
     			case Crafting Station
     			case Clickable
     			case Mailbox
 				case Assembly Station
 				case Taskmaster
 				case Banker
 				case Broker
     				This:MapPawn[${Pawn[${CurrentPawn}].ID}, ${Pawn[${CurrentPawn}].Type}]
     				break
     			case Unknown
     				Navigator:Echo["MapPointsOfInterest - Unknown: ${Pawn[${CurrentPawn}].ID} ${Pawn[${CurrentPawn}].Name} (Type: ${Pawn[${CurrentPawn}].Type})"]
     				break
     			default
     				Navigator:Echo["MapPointsOfInterest - Unexpected: ${Pawn[${CurrentPawn}].Name} (Type: ${Pawn[${CurrentPawn}].Type})"]
     		}
		}
	}

	method PlotPoint(lnavregionref ParentRegion, string PointName, float X, float Y, float Z)
	{
		variable point3f Location
		Location:Set[${X},${Y},${Z}]

		LastCreatedRegion:SetRegion[${CurrentZone.AddChild[point,${PointName}, ${Location}]}]
		This:Debug["Point added (${PointName}@${CurrentZone.FQN}) (${Location})"]
	}


	; Plot a 3d Sphere around a Center Location
	method PlotDynamicSphereFromPoint(lnavregionref ParentRegion, float X, float Y, float Z, float Radius=${This.Max_Region_Size}, string RegionName="")
	{
		variable point3f Location
		Location:Set[${X},${Y},${Z}]

		Radius:Set[${Collision.MaxCollisionFreeRadius[${Location}, ${Radius}]}]

		if ${RegionName.Equal[""]}
		{
			RegionName:Set["Sphere-${ParentRegion.ChildCount}"]
		}

		LastCreatedRegion:SetRegion[${ParentRegion.AddChild[sphere,${RegionName},-allpointsvalid,${Radius},${Location}]}]

		Navigator:EchoHUD["Region: (${LastCreatedRegion.FQN}) (${Location}) - Radius: ${Radius}]}"]
		This.Max_Distance_Between_Checks:Set[${Radius}]
		This:ConnectNeighbours[${LastCreatedRegion}]
	}

	; Plot a 3d Sphere around a Center Location
	method PlotDynamicSphereFromPawn(lnavregionref ParentRegion, int64 PawnID, float Radius=${This.Max_Region_Size}, string RegionName="")
	{
		variable point3f Location
		Location:Set[${Pawn[id,${PawnID}].Location}]

		Radius:Set[${Collision.MaxCollisionFreeRadius[${Location}, ${Radius}]}]

		if ${RegionName.Equal[""]}
		{
			RegionName:Set["Sphere-${ParentRegion.ChildCount}"]
		}

		; Don't set -allpointsvalid for Pawn regions, because of collision issues with what
		; are essentially 3-sided objects.
		LastCreatedRegion:SetRegion[${ParentRegion.AddChild[sphere,${RegionName},${Radius},${Location}]}]

		Navigator:EchoHUD["Region: (${LastCreatedRegion.FQN}) (${Location}) - Radius: ${Radius}]}"]
		This.Max_Distance_Between_Checks:Set[${Radius}]
		This:ConnectNeighbours[${LastCreatedRegion}]
	}

	; Plot a 3d Box around a Center Location
	; Uses Collision Actors to find the maximum size of the Box it can make, up to 50meters
	; First we generate a radius
	method PlotDynamicBoxFromPoint(lnavregionref ParentRegion, float X, float Y, float Z, float Radius=${This.Max_Region_Size}, string RegionName="")
	{
		DebugTrace("PlotDynamicBoxFromPoint(lnavregionref ${ParentRegion}, float ${X}, float ${Y}, float ${Z}, float ${Radius}, string ${RegionName})")
		variable point3f Location
		Location:Set[${X},${Y},${Z}]
		
		declarevariable X1 float local ${Location.X}
		declarevariable X2 float local ${Location.X}
		declarevariable Y1 float local ${Location.Y}
		declarevariable Y2 float local ${Location.Y}
		declarevariable Z1 float local ${Location.Z}
		declarevariable Z2 float local ${Location.Z}

		Radius:Set[${Collision.MaxCollisionFreeRadius[${Location}, ${Radius}]}]

		; Find the largest Square that will fit in our circle...(d/sqrt2)
		; Also convert result to loc units, insted of meters, by multiplying by 100
		variable float BoxWidth

		; ${Math.Sqrt[2]} (avoid doing calc every time)
		variable float SquareRootTwo = 1.414214
		BoxWidth:Set[${Math.Calc[((2 * ${Radius}) / ${SquareRootTwo}) * 100]}]
		Boxwidth:Set[${Math.Calc[${BoxWidth} / 2.0]}]

		DebugPrint("AutoMapper:PlotDynamicBoxFromPoint: Box width is: ${BoxWidth}")

		; Adjust the bounds of the Box so it's a 3D box around the point
		X1:Dec[${BoxWidth}]
		X2:Inc[${BoxWidth}]

		Y1:Dec[${BoxWidth}]
		Y2:Inc[${BoxWidth}]

		; TODO - Make this dynamic, after checkign the ground height of the 4 corners of the box on the ground
		Z1:Dec[300]
		Z2:Inc[300]

		if ${RegionName.Equal[""]}
		{
			RegionName:Set["Box-${ParentRegion.ChildCount}"]
		}

		LastCreatedRegion:SetRegion[${ParentRegion.AddChild[box,${RegionName},-allpointsvalid,${X1},${X2},${Y1},${Y2},${Z1},${Z2}]}]

		Navigator:EchoHUD["Region: (${LastCreatedRegion.FQN}) (${Location}) - Size: ${Math.Distance[${X1}, ${X2}]}"]
		This.Max_Distance_Between_Checks:Set[${BoxWidth}]]
		This:ConnectNeighbours[${LastCreatedRegion}]
	}

	; Plot a 3d Box of predefined size around a Center Location
	; XWidth - Total Width of X-Axis of Box, Location.X will be at XWidth/2
	method PlotBoxFromPoint(lnavregionref ParentRegion, float XWidth, float YWidth, float ZHeight, float X, float Y, float Z, string RegionName="")
	{
		variable point3f Location
		Location:Set[${X},${Y},${Z}]
		
		declarevariable X1 float local ${Location.X}
		declarevariable X2 float local ${Location.X}
		declarevariable Y1 float local ${Location.Y}
		declarevariable Y2 float local ${Location.Y}
		declarevariable Z1 float local ${Location.Z}
		declarevariable Z2 float local ${Location.Z}

		declarevariable XMod float local ${Math.Calc[${XWidth}/2.0]}
		declarevariable YMod float local ${Math.Calc[${YWidth}/2.0]}
		declarevariable ZMod float local ${Math.Calc[${ZHeight}/2.0]}

		; Adjust the bounds of the Box so it's a 3D box around the point
		X1:Dec[${XMod}]
		X2:Inc[${XMod}]

		Y1:Dec[${YMod}]
		Y2:Inc[${YMod}]

		Z1:Dec[${ZMod}]
		Z2:Inc[${ZMod}]

		if ${RegionName.Equal[""]}
		{
			RegionName:Set["Box-${ParentRegion.ChildCount}"]
		}
		LastCreatedRegion:SetRegion[${ParentRegion.AddChild[box,${RegionName},-allpointsvalid,${X1},${X2},${Y1},${Y2},${Z1},${Z2}]}]

		Navigator:EchoHUD["Region: (${LastCreatedRegion.FQN}) (${Location}) - Size: ${Math.Distance[${X1}, ${X2}]}"]
		This.Max_Distance_Between_Checks:Set[${BoxWidth}]]		
		This:ConnectNeighbours[${LastCreatedRegion}]
	}

	method ConnectNeighbours(lnavregionref Region)
	{
		variable index:lnavregionref SurroundingRegions
		variable int RegionsFound
		variable int Index = 1

		if !${Region.ID(exists)}
		{
			return
		}

		variable float DistanceToCheck
		switch ${Region.Type}
		{
			case Box
				DistanceToCheck:Set[${Math.Distance[${Region.X1},${Region.Y1},${Region.X2},${Region.Y2}]} * 1.5]
				break
			case Sphere
				DistanceToCheck:Set[${Region.Radius} * 3.0]
				break
			case Point
				return
				break
			default
				DebugPrint("AutoMapper:ConnectNeighbours - Unknown Object Type ${Region.Type}")
				return
				break
		}


		RegionsFound:Set[${CurrentZone.DescendantsWithin[SurroundingRegions,${DistanceToCheck},${Region.CenterPoint}]}]
		;DebugPrint("AutoMapper:ConnectNeighbours: Looking for regions within ${DistanceToCheck}: ${RegionsFound} found (Type ${Region.Type}")
		if ${RegionsFound} > 0
		{
			do
			{
				if ${Region.ID} == ${SurroundingRegions.Get[${Index}].ID}
				{
					; The result set includes the region were looking for
					continue
				}
				if !${Region.GetConnection[${SurroundingRegions.Get[${Index}].FQN}](exists)}
				{
					if ${This.ShouldConnect[${Region.ID},${SurroundingRegions.Get[${Index}].ID}]}
					{
						Region:Connect[${SurroundingRegions.Get[${Index}].ID}]
						SurroundingRegions.Get[${Index}]:Connect[${Region.ID}]
						Navigator:EchoHUD["  Connection: ${Region.FQN} <=> ${SurroundingRegions.Get[${Index}].FQN}"]
					}
				}
			}
			while ${SurroundingRegions.Get[${Index:Inc}](exists)}
		}
		;DebugPrint("AutoMapper:ConnectNeighbours: ${Region.ConnectionCount} regions found connecting to ${Region.FQN}")
	}

	member:bool ShouldConnect(lnavregionref RegionRefA, lnavregionref RegionRefB)
	{
		if ${RegionRefA.ID} == ${RegionRefB.ID}
		{
			; Dont connect regions to themselves
			return FALSE
		}

		if ${Collision.CollisionTest[${RegionRefA.CenterPoint}, ${RegionRefB.CenterPoint}]}
		{
			DebugPrint("AutoMapper:ShouldConnect: CollisionTest Failed")
			return FALSE
		}

		if ${Collision.RegionsIntersect[${RegionRefA},${RegionRefB}]}
		{
			return TRUE
		}
		return FALSE
			
	}
}
