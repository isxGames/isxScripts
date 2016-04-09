/* This File contains the Bohika Navigation object definition */

/* Written by Bohika */

objectdef  bnav
{

	;variable string CurrentChunk
	;variable string  CurrentRegion
	;variable string  LastRegion
	;variable int bpathindex
	;variable lnavpath mypath
	;variable astarpathfinder PathFinder
	;variable lnavconnection CurrentConnection

	function:bool Initialize()
	{
		Event[VG_onHitObstacle]:AttachAtom[Bump]

		LavishNav:Clear
		This:LoadPaths
		return TRUE
	}

	method SavePaths()
	{
		LNavRegion[${CurrentChunk}]:Export[${VGPathsDir}/${CurrentChunk}.xml]
	}

	method LoadPaths()
	{
		LavishNav:Clear
		;Look for zone file and load it, else create a new once
		if ${VGPathsDir.FileExists[${CurrentChunk}.xml]}
		{
			LavishNav.Tree:Import[${VGPathsDir}/${CurrentChunk}.xml]
			call DebugOut "bNav: Loaded ${VGPathsDir}/${CurrentChunk}.xml with ${LNavRegion[${CurrentChunk}].ChildCount} children"
		}
		else
		{
			call DebugOut "bNav: Creating New Zone :: ${CurrentChunk}"
			LavishNav.Tree:AddChild[universe,${CurrentChunk},-unique]
			isMapping:Set[TRUE]
		}
	}

	method AddNamedPoint(string pointname, string custom)
	{
		if ${pointname.Length}
		{
			LNavRegion[${LNavRegion[${This.CurrentRegionID}].AddChild[point,${pointname},-unique,${Me.X},${Me.Y},${Me.Z}].ID}]:SetCustom[${custom}]

			if !${LNavRegion[${pointname}].Parent.Type.Equal[Universe]}
			{
				LNavRegion[${LNavRegion[${pointname}].Parent.Name}]:Connect[${pointname}]
			}
			call DebugOut "bNav: Added point ${pointname} to ${LNavRegion[${This.CurrentRegionID}].Name}"
			return
		}
	}

	method AddCustomTag(string custom)
	{
		LNavRegion[${This.CurrentRegionID}]:SetCustom[${custom},${custom}]
		call DebugOut "bNav: Added tag ${custom} to ${LNavRegion[${This.CurrentRegionID}].Name}"
	}

	method AddDoorTag(string custom)
	{
		call DebugOut "bNav: Added DOOR to ${LNavRegion[${This.CurrentRegionID}].Name}"
		LNavRegion[${This.CurrentRegionID}]:SetCustom[DOOR,${custom}]
	}

	method AutoBox()
	{
		variable string Region
		Region:Set[${LNavRegion[${Me.Chunk}].BestContainer[${Me.X},${Me.Y},${Me.Z}].ID}]

		if ${LNavRegion[${Region}].Type.Equal[Universe]}
		{
			LNavRegion[${Region}]:AddChild[sphere,"auto",100,${Me.X},${Me.Y},${Me.Z}]
			CurrentRegion:Set[${LNavRegion[${This.CurrentRegionID}].ID}]
			LNavRegion[${This.CurrentRegionID}]:SetAllPointsValid[TRUE]

			call DebugOut "bNav: AutoBox to ${LNavRegion[${CurrentRegion}].Name}"
		}

	}

	method ConnectOnMove()
	{
		CurrentRegion:Set[${LNavRegion[${This.CurrentRegionID}].ID}]
		if !${CurrentRegion.Equal[${LastRegion}]} && !${LNavRegion[${CurrentRegion}].Type.Equal[Universe]} && !${LNavRegion[${LastRegion}].Type.Equal[Universe]} && !${LNavRegion[${LastRegion}].Avoid} && !${LNavRegion[${CurrentRegion}].Avoid}
		{
			if ${This.ShouldConnect[${LNavRegion[${CurrentRegion}].ID},${LNavRegion[${LastRegion}].ID}]}
			{
				call DebugOut "bNav: Moved from ${LNavRegion[${LastRegion}].Name} to ${LNavRegion[${CurrentRegion}].Name} making a 2 way connection"
				LNavRegion[${CurrentRegion}]:Connect[${LastRegion}]
				LNavRegion[${LastRegion}]:Connect[${CurrentRegion}]
			}
		}
		LastRegion:Set[${CurrentRegion}]
	}

	member:bool ShouldConnect(lnavregionref RegionRefA, lnavregionref RegionRefB)
	{
		if ${RegionRefA.ID} == ${RegionRefB.ID}
		{
			; Dont connect regions to themselves
			return FALSE
		}

		if ${Math.Distance[${RegionRefA.CenterPoint},${RegionRefB.CenterPoint}]} > 1000
		{
			call DebugOut "bNav: ShouldConnect: Regions to far away!"
			return FALSE
		}

		if ${This.CollisionTest[${RegionRefA.CenterPoint}, ${RegionRefB.CenterPoint}]}
		{
			;call DebugOut "bNav: ShouldConnect: Collision between regions!"
			return FALSE
		}
		return TRUE
	}

	member:bool CollisionTest(float FromX, float FromY, float FromZ, float ToX, float ToY, float ToZ)
	{
		variable point3f From
		From:Set[${FromX},${FromY},${FromZ}]

		variable point3f To
		To:Set[${ToX},${ToY},${ToZ}]

		;call DebugOut "bNav:CollisionTest: From ${FromX},${FromY},${FromZ} to ${ToX},${ToY},${ToZ}"

		if ${VG.CheckCollision[${From}, ${To}](exists)} || ${VG.CheckCollision[${To}, ${From}](exists)}
		{
			call DebugOut "VG: CheckCollision ${VG.CheckCollision[${To}, ${From}].Location} = TRUE"
			return TRUE
		}
		return FALSE
	}

	function FindClosestPoint(int myx, int myy, int myz)
	{
		variable string Container
		Container:Set[${LNavRegion[${This.CurrentRegionID}].BestContainer[${myx},${myy},${myz}]}]
		if !${LNavRegion[${Container}].Type.Equal[Universe]}
		{
			Container:Set[${LNavRegion[${Container}]}]
			return ${Container}
		}
		return ${LNavRegion[${Container}].NearestChild[${myx}, ${myy}, ${myz}]}
	}

	member:bool IsMapped(float X, float Y, float Z)
	{
		variable point3f Location
		Location:Set[${X},${Y},${Z}]

		variable lnavregionref Container

		Container:SetRegion[${LNavRegion[${This.CurrentRegionID}].BestContainer[${Location}].ID}]
		if !${Container.Type.Equal[Universe]} && ${Container.Contains[${Location}]}
		{
			return TRUE
		}
		return FALSE
	}

	member CurrentRegionID()
	{
		variable string Region

		Region:Set[${LNavRegion[${Me.Chunk}].BestContainer[${Me.X},${Me.Y},${Me.Z}].ID}]

		if ${LNavRegion[${Region}].Type.Equal[Point]}
		{
			return ${LNavRegion[${Region}].Parent.ID}
		}
		return ${LNavRegion[${Region}].ID}
	}

	function FindPath(string startRegion, string endRegion)
	{
		variable astarpathfinder aPathFinder
		variable dijkstrapathfinder dPathFinder
		variable index:lnavregionref endRegions
		variable index:lnavregionref startRegions
		variable string Region
		variable int RegionsFound
		variable int Index = 1

		mypath:Clear

		aPathFinder:SelectPath[${LNavRegion[${startRegion}].FQN},${LNavRegion[${endRegion}].FQN},mypath]
		if ${mypath.Hops} <= 0
		{
			mypath:Clear
			call DebugOut "bNav:FindPath: ZERO length path from ${LNavRegion[${startRegion}].FQN} to ${LNavRegion[${endRegion}].FQN}"
			; try the dijkstrapathfinder version
			dPathFinder:SelectPath[${LNavRegion[${startRegion}].FQN},${LNavRegion[${endRegion}].FQN},mypath]
		}

		if ${mypath.Hops} > 0
		{
			return TRUE
		}


		; Ok, need to start trying to find paths to different endpoints
		Region:Set[${LNavRegion[${endRegion}].FQN}]

		; We need to iterate through all the nearby regions and find the closest one that also has connections
		RegionsFound:Set[${LNavRegion[${Me.Chunk}].DescendantsWithin[endRegions,2000,${LNavRegion[${endRegion}].CenterPoint}]}]

		call DebugOut "bNav:FindPath: Looking for regions within 2000: ${RegionsFound} found of ${LNavRegion[${Region}].Name}:${LNavRegion[${Region}].Type}"

		if ${RegionsFound} > 0
		{
			do
			{
				if ${endRegions.Get[${Index}].ConnectionCount} > 0
				{
					; ok, has connections, let's try a path
					aPathFinder:SelectPath[${LNavRegion[${startRegion}].FQN},${endRegions.Get[${Index}].FQN},mypath]
					if ${mypath.Hops} > 0
					{
						call DebugOut "bNav:FindPath: ${mypath.Hops} hops from ${LNavRegion[${startRegion}].FQN} to ${endRegions.Get[${Index}].FQN}"
						return TRUE
					}
				}
			}
			while ${endRegions.Get[${Index:Inc}](exists)}
		}

		Index:Set[1]

		; Could not find a path from the closest point, so maybe that's the problem one
		Region:Set[${LNavRegion[${startRegion}].FQN}]

		; We need to iterate through all the nearby regions and find the closest one that also has connections
		RegionsFound:Set[${LNavRegion[${Me.Chunk}].DescendantsWithin[startRegions,1000,${LNavRegion[${startRegion}].CenterPoint}]}]

		call DebugOut "bNav:FindPath: Looking for regions within 1000: ${RegionsFound} found of ${LNavRegion[${Region}].Name}:${LNavRegion[${Region}].Type}"

		if ${RegionsFound} > 0
		{
			do
			{
				if ${startRegions.Get[${Index}].ConnectionCount} > 0
				{
					; ok, has connections, let's try a path
					aPathFinder:SelectPath[${startRegions.Get[${Index}].FQN},${LNavRegion[${endRegion}].FQN},mypath]
					if ${mypath.Hops} > 0
					{
						if !${This.CollisionTest[${Me.Location},${startRegions.Get[${Index}].CenterPoint}]}
						{
							call DebugOut "bNav:FindPath: ${mypath.Hops} hops from ${startRegions.Get[${Index}].FQN} to ${LNavRegion[${endRegion}].FQN}"
							return TRUE
						}
					}
				}
			}
			while ${startRegions.Get[${Index:Inc}](exists)}
		}

		; Could not find any paths
		mypath:Clear
		return FALSE
	}

	function:bool TakeNextHop()
	{
		variable float WPX
		variable float WPY

		call DebugOut "bNav: ${bpathindex}"

		WPX:Set[${mypath.Region[${bpathindex}].CenterPoint.X}]
		WPY:Set[${mypath.Region[${bpathindex}].CenterPoint.Y}]

		call FastMove ${WPX} ${WPY} 100 ${mypath.Region[${bpathindex}]}
		if ${Return.Equal["STUCK"]}
		{
			call DebugOut "bNav: TakeNextHop: STUCK"
			;CurrentConnection:SetConnection[${mypath.Connection[${bpathindex}]}]
			;call DebugOut "bNav: Removing Connection ${mypath.Connection[${bpathindex}]}"
			;CurrentConnection:Remove
			call FastMove ${mypath.Region[${Math.Calc[${bpathindex}-1]}].CenterPoint.X} ${mypath.Region[${Math.Calc[${bpathindex}-1]}].CenterPoint.Y} 100

			if ${debug}
			{
				echo "bNav: ${Return}"
			}

			return FALSE
		}
		if ${Return.Equal["SUCCESS"]}
		{
			bpathindex:Inc
		}
		return TRUE

	}

	/******************************************************************************************/

	function MoveWithCD(int iX, int iY, int iZ)
	{
		variable float range = 300
		variable float lastHeading
		variable float startHeading
		variable int resetCounter

		face ${iX} ${iY}

		startHeading:Set[${Me.Heading}]

		do
		{
			if ${Me.Heading} != ${lastHeading}
			lastHeading:Set[${Me.Heading}

			; First check to see if there is a collision in front of us
			call FindCollisionFreeSpot
			if ${Return}
			{
				VG:ExecBinding[moveforward]
				wait 3
			}
			else
			{
				call DebugOut "bNav:collision:Heading from ${lastHeading} to ${Me.Heading}"
				VG:ExecBinding[moveforward,release]
			}

			if !${This.IsMapped[${Me.X},${Me.Y},${Me.Z}]}
			{
				; We just moved to a new, non-mapped area, So make sure we stay on target!
				face ${iX} ${iY}
			}
		}
		while (${Math.Distance[${Me.X},${Me.Y},${iX},${iY}]} > ${range}) && ${isMoving}

		VG:ExecBinding[moveforward,release]

		if (${Math.Distance[${Me.X},${Me.Y},${iX},${iY}]} <= ${range})
		{
			call DebugOut "bNav: MoveWithCD succeeded"
			return "SUCCESS"
		}
		else
		{
			call DebugOut "bNav: MoveWithCD failed"
			return "FAILED"
		}
	}

	function FindCollisionFreeSpot()
	{
		; First check our Heading to see which coord we are facing
		; Heading 0-89 == -X,+Y
		; Heading 90-179 == -X,-Y
		; Heading 180-269 == +X,-Y
		; heading 270-360 == +X,+Y
		/*
		North = 0, east = 90, south = 180, west = 270
		just 360 degree compass headings w/ north as cardinal 0
		absolute north should be 0.000000,
		east should be 90.000000 etc
		*/

		variable float iX
		variable float iY

		iX:Set[${Me.X}]
		iY:Set[${Me.Y}]

		if ${Me.Heading} >= 0 && ${Me.Heading} <= 90
		{

			if !${VG.CheckCollision[${Math.Calc[${iX} - 2]}, ${Math.Calc[${iY} + 2]}, ${Me.Z}](exists)}
			{
				face ${Math.Calc[${iX} - 2]}, ${Math.Calc[${iY} + 2]}
				return TRUE
			}
			if !${VG.CheckCollision[${Math.Calc[${iX} - 0]}, ${Math.Calc[${iY} + 4]}, ${Me.Z}](exists)}
			{
				face ${Math.Calc[${iX} - 0]}, ${Math.Calc[${iY} + 4]}
				return TRUE
			}
			if !${VG.CheckCollision[${Math.Calc[${iX} - 4]}, ${Math.Calc[${iY} + 0]}, ${Me.Z}](exists)}
			{
				face ${Math.Calc[${iX} - 4]}, ${Math.Calc[${iY} + 0]}
				return TRUE
			}

		}
		elseif ${Me.Heading} > 90 && ${Me.Heading} <= 180
		{

			if !${VG.CheckCollision[${Math.Calc[${iX} - 2]}, ${Math.Calc[${iY} - 2]}, ${Me.Z}](exists)}
			{
				face ${Math.Calc[${iX} - 2]}, ${Math.Calc[${iY} - 2]}
				return TRUE
			}
			if !${VG.CheckCollision[${Math.Calc[${iX} - 0]}, ${Math.Calc[${iY} - 4]}, ${Me.Z}](exists)}
			{
				face ${Math.Calc[${iX} - 0]}, ${Math.Calc[${iY} - 4]}
				return TRUE
			}
			if !${VG.CheckCollision[${Math.Calc[${iX} - 4]}, ${Math.Calc[${iY} - 0]}, ${Me.Z}](exists)}
			{
				face ${Math.Calc[${iX} - 4]}, ${Math.Calc[${iY} - 0]}
				return TRUE
			}

		}
		elseif ${Me.Heading} > 180 && ${Me.Heading} <= 270
		{

			if !${VG.CheckCollision[${Math.Calc[${iX} + 2]}, ${Math.Calc[${iY} - 2]}, ${Me.Z}](exists)}
			{
				face ${Math.Calc[${iX} + 2]}, ${Math.Calc[${iY} - 2]}
				return TRUE
			}
			if !${VG.CheckCollision[${Math.Calc[${iX} + 0]}, ${Math.Calc[${iY} - 4]}, ${Me.Z}](exists)}
			{
				face ${Math.Calc[${iX} + 0]}, ${Math.Calc[${iY} - 4]}
				return TRUE
			}
			if !${VG.CheckCollision[${Math.Calc[${iX} + 4]}, ${Math.Calc[${iY} - 0]}, ${Me.Z}](exists)}
			{
				face ${Math.Calc[${iX} + 4]}, ${Math.Calc[${iY} - 0]}
				return TRUE
			}

		}
		elseif ${Me.Heading} > 270 && ${Me.Heading} <= 360
		{

			if !${VG.CheckCollision[${Math.Calc[${iX} + 2]}, ${Math.Calc[${iY} + 2]}, ${Me.Z}](exists)}
			{
				face ${Math.Calc[${iX} + 2]}, ${Math.Calc[${iY} + 2]}
				return TRUE
			}
			if !${VG.CheckCollision[${Math.Calc[${iX} + 0]}, ${Math.Calc[${iY} + 4]}, ${Me.Z}](exists)}
			{
				face ${Math.Calc[${iX} + 0]}, ${Math.Calc[${iY} + 4]}
				return TRUE
			}
			if !${VG.CheckCollision[${Math.Calc[${iX} + 4]}, ${Math.Calc[${iY} + 0]}, ${Me.Z}](exists)}
			{
				face ${Math.Calc[${iX} + 4]}, ${Math.Calc[${iY} + 0]}
				return TRUE
			}

		}
		; ok, doesn't look good, lets turn 20 degrees to the left
		; and see if it'll pickup next iteration
		if ${Me.Heading} > 340
		face 10.0
		else
		face ${Math.Calc[${Me.Heading} + 20]}
		return FALSE
	}


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	function:bool MoveToMappedArea()
	{
		variable index:lnavregionref SurroundingRegions
		variable string Region
		variable int RegionsFound
		variable int Index = 1

		Region:Set[${Me.Chunk}]

		; We need to iterate through all the nearby regions and find the closest one that also has connections within 30 meters
		RegionsFound:Set[${LNavRegion[${Region}].DescendantsWithin[SurroundingRegions,3000,${Me.Location}]}]

		call DebugOut "MoveToMap: Looking for regions within 1500: ${RegionsFound} found of ${LNavRegion[${Region}].Name}:${LNavRegion[${Region}].Type}"

		if ${RegionsFound} > 0
		{
			do
			{
				EchoIt "#[${Index}] Distance = ${Math.Distance[${Me.Location}, ${SurroundingRegions.Get[${Index}].CenterPoint}]}"
				if ${SurroundingRegions.Get[${Index}].ConnectionCount} > 0 && !${This.CollisionTest[${Me.Location}, ${SurroundingRegions.Get[${Index}].CenterPoint}]}
				{
					; ok, has connections and no collisions, let's MOVE!
					call FastMove ${SurroundingRegions.Get[${Index}].CenterPoint.X} ${SurroundingRegions.Get[${Index}].CenterPoint.Y} 100
					return TRUE
				}
			}
			while ${SurroundingRegions.Get[${Index:Inc}](exists)}
		}
		; Could not find any good regions
		return FALSE
	}

	function:string MovetoTargetName(string aTarget, bool checkMoved)
	{
		variable string CPname
		variable float WPX
		variable float WPY
		variable int iCheck
		variable string tName
		variable astarpathfinder aPathFinder
		variable dijkstrapathfinder dPathFinder

		bpathindex:Set[1]

		call DebugOut "bNav: X: ${Pawn[${aTarget}].X} Y: ${Pawn[${aTarget}].Y} Z: ${Pawn[${aTarget}].Z}"

		call This.FindClosestPoint ${Pawn[${aTarget}].X} ${Pawn[${aTarget}].Y} ${Pawn[${aTarget}].Z}
		tName:Set[${Return}]

		call This.FindClosestPoint ${Me.X} ${Me.Y} ${Me.Z}
		CPname:Set[${Return}]

		call DebugOut "bNav: Names: ${CPname} :: ${tName}"

		; Check to see if we are NOT in a mapped area
		if !${This.IsMapped[${Me.Location}]}
		{
			; Hmm, we need to get back on the map first
			return "NO MAP"
		}

		mypath:Clear

		call FindPath "${CPname}" "${tName}"

		if !${Return}
		return "NO PATH"

		iCheck:Set[${Math.Calc[${mypath.Hops} * 0.8].Int}]

		call DebugOut "bNav:MovetoTargetName: Found Path to ${LNavRegion[${tName}].FQN} with ${mypath.Hops} hops from ${LNavRegion[${CPname}].FQN}"

		;		if ${mypath.Hops}>0 && ${mypath.Hops}<5
		;		{
		;			call DebugOut "bNav:MovetoTargetName: Short path, just end it!"
		;			return "END"
		;		}

		if ${mypath.Hops} > 0
		{
			WPX:Set[${mypath.Region[${bpathindex}].CenterPoint.X}]
			WPY:Set[${mypath.Region[${bpathindex}].CenterPoint.Y}]

			;Turn to face the desired loc
			if ${doSlowTurn}
			call faceloc ${WPX} ${WPY} 15 1
			else
			Face ${WPX} ${WPY}

			do
			{
				; Move to next Waypoint
				WPX:Set[${mypath.Region[${bpathindex}].CenterPoint.X}]
				WPY:Set[${mypath.Region[${bpathindex}].CenterPoint.Y}]

				; See if this box has a DOOR tag
				;if ${mypath.Region[${bpathindex}].ChildCount} > 0 || ${mypath.Region[${bpathindex}].Custom.Find[DOOR]}
				if ${mypath.Region[${bpathindex}].Custom[DOOR](exists)}
				{
					call DebugOut "bNav: Found a Door in ${mypath.Region[${bpathindex}].Name}"
					VG:ExecBinding[UseDoorEtc]
					echo "Opened Door"
				}

				call FastMove ${WPX} ${WPY} ${movePrecision}

				if ${Return.Equal["STUCK"]}
				{
					;CurrentConnection:SetConnection[${mypath.Connection[${bpathindex}]}]
					;call DebugOut "bNav: Removing Connection ${mypath.Connection[${bpathindex}]}"
					;CurrentConnection:Remove

					call FastMove ${mypath.Region[${Math.Calc[${bpathindex}-2]}].CenterPoint.X} ${mypath.Region[${Math.Calc[${bpathindex}-2]}].CenterPoint.Y} 100
					call DebugOut "bNav: FastMove return: ${Return}"

					mypath:Clear
					;CurrentConnection:Clear

					call This.FindClosestPoint ${Me.X} ${Me.Y} ${Me.Z}
					CPname:Set[${Return}]

					call FindPath "${CPname}" "${tName}"

					call DebugOut "bNav: mypath.Hops: ${mypath.Hops}"

					if ${mypath.Hops} > 0
					{
						call DebugOut "bNav: Found new path to ${tName} with ${mypath.Hops} hops."
						bpathindex:Set[1]
					}
					else
					{
						VG:ExecBinding[moveforward,release]
						LastRegion:Set[${CurrentRegion}]
						CurrentRegion:Set[${LNavRegion[${This.CurrentRegionID}].Name}]

						return "STUCK"
					}
				}
				elseif ${checkMoved} && (${bpathindex} > ${iCheck}) && (${bpathindex} > 10)
				{
					; if most of the way through path, then check to see if the Target has moved
					; This is for Moving NPC's and slow running Toons

					variable string newName

					call This.FindClosestPoint ${Pawn[${aTarget}].X} ${Pawn[${aTarget}].Y} ${Pawn[${aTarget}].Z}
					newName:Set[${Return}]

					if !${newName.Equal[${tName}]}
					{
						call DebugOut "bNav: Target Moved! Recomputing path :: ${newName} :: ${tName}"

						call This.FindClosestPoint ${Me.X} ${Me.Y} ${Me.Z}
						CPname:Set[${Return}]

						mypath:Clear

						call FindPath "${CPname}" "${newName}"

						if !${Return}
						return "NO PATH"

						call DebugOut "bNav: mypath.Hops: ${mypath.Hops}"

						if ${mypath.Hops} > 0
						{
							call DebugOut "bNav: Found new path to ${newName} with ${mypath.Hops} hops."
							bpathindex:Set[1]
							iCheck:Set[${Math.Calc[${mypath.Hops} * 0.8].Int}]
						}
						else
						{
							VG:ExecBinding[moveforward,release]

							return "NO PATH"
						}

					}
				}
			}
			while ${bpathindex:Inc} <= ${mypath.Hops} && ${isMoving}

			VG:ExecBinding[moveforward,release]

			return "END"
		}
		else
		{
			return "NO PATH"
		}

	}

	function:string MovetoTargetID(int64 aTarget, bool checkMoved)
	{
		variable string CPname
		variable float WPX
		variable float WPY
		variable float WPZ
		variable int iCheck
		variable string tName
		variable astarpathfinder aPathFinder
		variable dijkstrapathfinder dPathFinder

		bpathindex:Set[1]

		call DebugOut "bNav: X: ${Pawn[id,${aTarget}].X} Y: ${Pawn[id,${aTarget}].Y} Z: ${Pawn[id,${aTarget}].Z}"

		call This.FindClosestPoint ${Pawn[id,${aTarget}].X} ${Pawn[id,${aTarget}].Y} ${Pawn[id,${aTarget}].Z}
		tName:Set[${Return}]

		call This.FindClosestPoint ${Me.X} ${Me.Y} ${Me.Z}
		CPname:Set[${Return}]

		call DebugOut "bNav: Names: ${CPname} :: ${tName}"

		;if ${This.CurrentRegionID.Equal[${LNavRegion[${Me.Chunk}].BestContainer[${Pawn[id,${aTarget}].X}, ${Pawn[id,${aTarget}].Y}, ${Pawn[id,${aTarget}].Z}]}]}
		;{
		;	;call FastMove ${Pawn[id,${aTarget}].X} ${Pawn[id,${aTarget}].Y}	${movePrecision}
		;	call DebugOut "bNav:MovetoTargetName In region quick hop"
		;	return "END"
		;}

		; Check to see if we are NOT in a mapped area
		if !${This.IsMapped[${Me.Location}]}
		{
			; Hmm, we need to get back on the map first
			return "NO MAP"
		}

		mypath:Clear

		call FindPath "${CPname}" "${tName}"

		if !${Return}
		return "NO PATH"

		iCheck:Set[${Math.Calc[${mypath.Hops} * 0.8].Int}]

		call DebugOut "bNav:MovetoTargetName: Found Path to ${LNavRegion[${tName}].FQN} with ${mypath.Hops} hops from ${LNavRegion[${CPname}].FQN}"

		;		if ${mypath.Hops}>0 && ${mypath.Hops}<5
		;		{
		;			call DebugOut "bNav:MovetoTargetName: Short path, just end it!"
		;			return "END"
		;		}

		if ${mypath.Hops} > 0
		{
			WPX:Set[${mypath.Region[${bpathindex}].CenterPoint.X}]
			WPY:Set[${mypath.Region[${bpathindex}].CenterPoint.Y}]

			;Turn to face the desired loc
			if ${doSlowTurn}
			call faceloc ${WPX} ${WPY} 15 1
			else
			Face ${WPX} ${WPY}

			do
			{
				;EchoIt "*[${bpathindex}] Distance = ${Math.Distance[${Me.X},${Me.Y},${WPX},${WPY}]}, RegionID=${This.CurrentRegionID}"

				; Set our next Waypoint
				WPX:Set[${mypath.Region[${bpathindex}].CenterPoint.X}]
				WPY:Set[${mypath.Region[${bpathindex}].CenterPoint.Y}]

				; See if this box has a DOOR tag
				if ${mypath.Region[${bpathindex}].Custom[DOOR](exists)}
				{
					call DebugOut "bNav: Found a Door in ${mypath.Region[${bpathindex}].Name}"
					VG:ExecBinding[UseDoorEtc]
					echo "Opened Door"
				}

				;; We reached the point so let's set our pointer to the next point on path
				if ${Math.Distance[${Me.X},${Me.Y},${WPX},${WPY}]}<=300
				{
					continue
				}

				; Move to next Waypoint
				call FastMove ${WPX} ${WPY} ${movePrecision}

				if ${Return.Equal["STUCK"]}
				{
					call FastMove ${mypath.Region[${Math.Calc[${bpathindex}-2]}].CenterPoint.X} ${mypath.Region[${Math.Calc[${bpathindex}-2]}].CenterPoint.Y} 100
					call DebugOut "bNav: FastMove return: ${Return}"

					mypath:Clear

					call This.FindClosestPoint ${Me.X} ${Me.Y} ${Me.Z}
					CPname:Set[${Return}]

					call FindPath "${CPname}" "${tName}"

					call DebugOut "bNav: mypath.Hops: ${mypath.Hops}"

					if ${mypath.Hops} > 0
					{
						call DebugOut "bNav: Found new path to ${tName} with ${mypath.Hops} hops."
						bpathindex:Set[1]
					}
					else
					{
						VG:ExecBinding[moveforward,release]
						LastRegion:Set[${CurrentRegion}]
						CurrentRegion:Set[${LNavRegion[${This.CurrentRegionID}].Name}]

						return "STUCK"
					}
				}
				elseif ${checkMoved} && (${bpathindex} > ${iCheck}) && (${bpathindex} > 10)
				{
					; if most of the way through path, then check to see if the Target has moved
					; This is for Moving NPC's and slow running Toons

					variable string newName

					call This.FindClosestPoint ${Pawn[id,${aTarget}].X} ${Pawn[id,${aTarget}].Y} ${Pawn[id,${aTarget}].Z}
					newName:Set[${Return}]

					if !${newName.Equal[${tName}]}
					{
						call DebugOut "bNav: Target Moved! Recomputing path :: ${newName} :: ${tName}"

						call This.FindClosestPoint ${Me.X} ${Me.Y} ${Me.Z}
						CPname:Set[${Return}]

						mypath:Clear

						call FindPath "${CPname}" "${newName}"

						if !${Return}
						return "NO PATH"

						call DebugOut "bNav: mypath.Hops: ${mypath.Hops}"

						if ${mypath.Hops} > 0
						{
							call DebugOut "bNav: Found new path to ${newName} with ${mypath.Hops} hops."
							bpathindex:Set[1]
							iCheck:Set[${Math.Calc[${mypath.Hops} * 0.8].Int}]
						}
						else
						{
							VG:ExecBinding[moveforward,release]

							return "NO PATH"
						}

					}
				}
				;vgecho [${bpathindex}] Distance to target is ${Math.Distance[${Me.X},${Me.Y},${Pawn[id,${aTarget}].X},${Pawn[id,${aTarget}].Y}]}
			}
			;; we can parlay at a distance of 0-7 meters, this allows parlaying NPC that are Aggro to you
			while ${bpathindex:Inc} <= ${mypath.Hops} && ${isMoving} && ${Pawn[id,${aTarget}].Distance}>=6

			VG:ExecBinding[moveforward,release]

			return "END"
		}
		else
		{
			return "NO PATH"
		}
	}

	function:string MovetoXYZ(int iX, int iY, int iZ)
	{
		variable string CPname

		call This.FindClosestPoint ${iX} ${iY} ${iZ}
		CPname:Set[${Return}]

		call MovetoWP "${CPname}"

		return "${Return}"
	}

	function:string MovetoWP(string destination)
	{

		bpathindex:Set[1]
		variable string CPname
		variable float WPX
		variable float WPY
		variable int iCheck

		mypath:Clear

		call This.FindClosestPoint ${Me.X} ${Me.Y} ${Me.Z}
		CPname:Set[${Return}]

		; Check to see if we are NOT in a mapped area
		if !${This.IsMapped[${Me.Location}]}
		{
			return "NO MAP"
		}

		call FindPath "${CPname}" "${destination}"

		if !${Return}
		return "NO PATH"

		iCheck:Set[${Math.Calc[${mypath.Hops} * 0.8].Int}]

		call DebugOut "bNav:MovetoWP: Found Path to ${LNavRegion[${destination}].FQN} with ${mypath.Hops} hops from ${LNavRegion[${CPname}].FQN}"

		if ${mypath.Hops} > 0
		{
			WPX:Set[${mypath.Region[${bpathindex}].CenterPoint.X}]
			WPY:Set[${mypath.Region[${bpathindex}].CenterPoint.Y}]

			Face ${WPX} ${WPY}

			do
			{
				;EchoIt "[${bpathindex}] Distance = ${Math.Distance[${Me.X},${Me.Y},${WPX},${WPY}]}, RegionID=${This.CurrentRegionID}"

				; Set our next Waypoint
				WPX:Set[${mypath.Region[${bpathindex}].CenterPoint.X}]
				WPY:Set[${mypath.Region[${bpathindex}].CenterPoint.Y}]

				; See if this box has a DOOR tag
				if ${mypath.Region[${bpathindex}].Custom[DOOR](exists)}
				{
					call DebugOut "bNav: Found a Door in ${mypath.Region[${bpathindex}].Name}"
					VG:ExecBinding[UseDoorEtc]
					echo "Opened Door"
				}

				;; We reached the point so let's set our pointer to the next point on path
				if ${Math.Distance[${Me.X},${Me.Y},${WPX},${WPY}]}<=300
				{
					continue
				}

				; Move to next Waypoint
				call FastMove ${WPX} ${WPY} ${movePrecision}

				; Move to next Waypoint
				WPX:Set[${mypath.Region[${bpathindex}].CenterPoint.X}]
				WPY:Set[${mypath.Region[${bpathindex}].CenterPoint.Y}]
				call FastMove ${WPX} ${WPY} ${movePrecision}

				if ${Return.Equal["STUCK"]}
				{
					call FastMove ${mypath.Region[${Math.Calc[${bpathindex}-2]}].CenterPoint.X} ${mypath.Region[${Math.Calc[${bpathindex}-2]}].CenterPoint.Y} 100
					call DebugOut "bNav: FastMove return: ${Return}"

					mypath:Clear

					call This.FindClosestPoint ${Me.X} ${Me.Y} ${Me.Z}
					CPname:Set[${Return}]

					call FindPath "${CPname}" "${destination}"

					call DebugOut "bNav: mypath.Hops: ${mypath.Hops}"

					if ${mypath.Hops} > 0
					{
						call DebugOut "bNav: Found new path to ${destination} with ${mypath.Hops} hops."
						bpathindex:Set[1]
					}
					else
					{
						VG:ExecBinding[moveforward,release]
						return "STUCK"
					}
				}
			}
			while ${bpathindex:Inc} <= ${mypath.Hops} && ${isMoving}
			VG:ExecBinding[moveforward,release]

			return "END"
		}
		else
		{
			return "NO PATH"
		}
	}

	function:string FastMove(float X, float Y, int range, string Region)
	{
		variable float xDist
		variable float SavDist = ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}
		variable int xTimer
		variable int FullTimer

		;call DebugOut "bNav: FastMove: ${X} ${Y}"

		face ${X} ${Y}

		VG:ExecBinding[moveforward]

		xTimer:Set[${Time.Timestamp}]
		FullTimer:Set[${Time.Timestamp}]

		do
		{
			xDist:Set[${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}]

			if ${Math.Calc[${SavDist} - ${xDist}]} < 60
			{
				if ${Math.Calc[${Time.Timestamp} - ${xTimer}]} > 1
				{
					VG:ExecBinding[moveforward,release]
					call DebugOut "bNav: STUCK"
					return "STUCK"
				}
			}
			else
			{
				xTimer:Set[${Time.Timestamp}]
				SavDist:Set[${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}]
			}

			if ${This.CurrentRegionID.Equal[${Region}]}
			{
				return "SUCCESS"
			}

			face ${X} ${Y}

			if ${VG.CheckCollision[${X},${Y},${Me.Z}](exists)}
			{
				call DebugOut "bNav: FastMove CheckCollision retured TRUE"
			}

		}
		while (${Math.Distance[${Me.X},${Me.Y},${X},${Y}]} > ${range}) && (${Math.Calc[${Time.Timestamp}-${FullTimer}]} < 3) && ${isMoving}

		if (${Math.Distance[${Me.X},${Me.Y},${X},${Y}]} < ${range})
		{
			return "SUCCESS"
		}
		else
		{
			call DebugOut "bNav: MOVING ${Math.Calc[${Time.Timestamp}-${FullTimer}]}"
			return "MOVING"
		}
	}

	member:string getlvl()
	{
		variable int lp = 2
		variable int lvl = 0
		while ${lp} <= ${VG.PawnCount}
		{
			if ${Pawn[${lp}].Type.Equal[npc]} || ${Pawn[${lp}].Type.Equal[AggroNPC]}
			{
				lvl:Inc[${Math.Calc[${Pawn[${lp}].Level}]}]
			}
			lp:Inc
		}
		lp:Dec[1]
		lvl:Set[${Math.Calc[${lvl}/${lp}]}]
		Return ${lvl}
	}

	method AddHuntPoint()
	{
		;			variable string tmp
		;			tmp:Set[${LNavRegion[${This.CurrentRegionID}].AddChild[point,"auto",-unique,${Me.X},${Me.Y},${Me.Z}]}]
		;			LNavRegion[${tmp}]:SetCustom["level", ${This.getlvl}]
		;			LNavRegionGroup["hunt"]:Add[${tmp}]
		;			if !${LNavRegion[${pointname}].Parent.Type.Equal[Universe]}
		;			{
		;				LNavRegion[${LNavRegion[${tmp}].Parent}]:Connect[${tmp}]
		;			}
		;			if ${debug}
		;			{
		;				echo added ${LNavRegion[${tmp}]} to hunt region group.
		;			}

		variable string Region=${This.CurrentRegionID}
		if !${LNavRegion[${Region}].Type.Equal[Universe]}
		{
			LNavRegion[${Region}]:SetCustom["level", ${This.getlvl}]
			LNavRegionGroup["hunt"]:Add[${Region}]
		}

	}

}


/********************************************************************************************/
/********************************************************************************************/
/********************************************************************************************/

atom Bump(string aObstacleActorName, float fX_Offset, float fY_Offset, float fZ_Offset)
{
	;	call DebugOut "bNav: Bump'ed ${aObstacleActorName}"

	if (${aObstacleActorName.Find[Mover]})
	{
		call DebugOut "bNav: Bump'ed a Door in ${CurrentRegion}"
		VG:ExecBinding[UseDoorEtc]
	}
	elseif !${isMapping}
	{
		; For now, just return
		return

		variable string Region
		Region:Set[${LNavRegion[${Me.Chunk}].BestContainer[${Me.X},${Me.Y}].ID}]
		if !${LNavRegion[${Region}].Avoid}
		{
			LNavRegion[${Region}]:AddChild[rect,"auto",-unique,${Math.Calc[${Me.X}-50]},${Math.Calc[${Me.X}+50]}, ${Math.Calc[${Me.Y}-50]}, ${Math.Calc[${Me.Y}+50]}]
			Region:Set[${LNavRegion[${Me.Chunk}].BestContainer[${Me.X},${Me.Y}].ID}]
			LNavRegion[${Region}]:SetAvoid[TRUE]
			LNavRegion[${Region}]:SetAllPointsValid[FALSE]
			LNavRegion[${Region}].Parent:SetAllPointsValid[FALSE]

			call DebugOut "bNav: Not all valid! ${LNavRegion[${Region}].Name}"
		}
	}
}


