/* This File contains the Bohika Navigation object definition */

/* Written by Bohika */


variable filepath sVGPathsDir = "${Script.CurrentDirectory}/vgpaths"
variable string sOutputFile = "${Script.CurrentDirectory}/vgpaths/move_debug.log"

objectdef  bnav
{

	variable string CurrentRegion
	variable string LastRegion
	variable int bpathindex
	variable lnavpath mypath
	variable lnavconnection CurrentConnection

	variable bool isMoving
	variable time tTimeOut
	variable int stuckCounter


	function:bool Initialize()
	{
		Event[VG_onHitObstacle]:AttachAtom[Bump]
		LavishNav:Clear

		mkdir "${sVGPathsDir}"

		isMoving:Set[FALSE]

		;Look for zone file and load it, else create a new once
		if ${sVGPathsDir.FileExists[${Me.Chunk}.xml]}
		{
			LavishNav.Tree:Import[${sVGPathsDir}/${Me.Chunk}.xml]
			call DebugOut "bNav: Loaded ${sVGPathsDir}/${Me.Chunk}.xml with ${LNavRegion[${Me.Chunk}].ChildCount} children"
			;call DebugOut "bNav: CurrentRegion: ${CurrentRegion} :: ${This.CurrentRegionID}"
		}
		else
		{
			call DebugOut "bNav: Creating New Zone :: ${Me.Chunk}"
			LavishNav.Tree:AddChild[universe,${Me.Chunk},-unique]
			isMapping:Set[TRUE]
		}

		CurrentRegion:Set[${This.CurrentRegionID}]
		LastRegion:Set[${This.CurrentRegionID}]

		;if !${Script[ForestRun](exists)}
		;{
		;	run "${Script.CurrentDirectory}/common/forestrun.iss"
		;}

		Event[OnFrame]:AttachAtom[This:Move]

		return TRUE
	}

	method Shutdown()
	{
		call DebugOut "Shutting Down"

		;ui -unload "${Script.CurrentDirectory}/CTNavigator-UI.xml"
		isMoving:Set[FALSE]

		Event[OnFrame]:DetachAtom[This:Move]
	}

	method SavePaths()
	{
		LNavRegion[${Me.Chunk}]:Export[${sVGPathsDir}/${Me.Chunk}.xml]
		;LNavRegion[${Me.Chunk}]:Remove

		;if ${lso}
		;{
		;	LNavRegion[${Me.Chunk}]:Export[-lso,${sVGPathsDir}${Me.Chunk}.lso]
		;	LNavRegion[${Me.Chunk}]:Remove
		;	echo Exported to LSO
		;}

	}

	method LoadPaths()
	{
		;Look for zone file and load it, else create a new once
		if ${sVGPathsDir.FileExists[${Me.Chunk}.xml]}
		{
			LavishNav.Tree:Import[${sVGPathsDir}/${Me.Chunk}.xml]
			call DebugOut "bNav: Loaded ${sVGPathsDir}/${Me.Chunk}.xml with ${LNavRegion[${Me.Chunk}].ChildCount} children"
		}
		else
		{
			call DebugOut "bNav: Creating New Zone :: ${Me.Chunk}"
			LavishNav.Tree:AddChild[universe,${Me.Chunk},-unique]
			isMapping:Set[TRUE]
		}
	}

	function DebugOut(string aText)
	{
		redirect -append "${sOutputFile}" echo "${Time}:: ${aText}"
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
		call DebugOut "bNav: Added tag ${custom} to ${LNavRegion[${CurrentRegion}].Name}"
	}

	method AutoBox()
	{
		variable string Region
		Region:Set[${LNavRegion[${Me.Chunk}].BestContainer[${Me.X},${Me.Y},${Me.Z}].ID}]

		if ${LNavRegion[${Region}].Type.Equal[Universe]}
		{
			call DebugOut "bNav: AutoBox to ${LNavRegion[${This.CurrentRegionID}].FQN}"

			;LNavRegion[${This.CurrentRegionID}]:AddChild[sphere,"auto",-unique,${Math.Calc[${Me.X} - 200]},${Math.Calc[${Me.X} + 300]}, ${Math.Calc[${Me.Y} - 300]}, ${Math.Calc[${Me.Y} + 300]}, ${Math.Calc[${Me.Z} - 200]},${Math.Calc[${Me.Z}+ 200]}]
			LNavRegion[${This.CurrentRegionID}]:AddChild[sphere,"auto",400,${Me.X},${Me.Y},${Me.Z}]
			;Region:Set[${LNavRegion[${Me.Chunk}].BestContainer[${Me.X},${Me.Y},${Me.Z}].ID}]
			CurrentRegion:Set[${LNavRegion[${This.CurrentRegionID}].ID}]
			LNavRegion[${CurrentRegion}]:SetAllPointsValid[TRUE]
		}

	}

	method ConnectOnMove()
	{
		CurrentRegion:Set[${LNavRegion[${This.CurrentRegionID}].ID}]
		if !${CurrentRegion(exists)} || ${CurrentRegion.Equal[NULL]} || ${LastRegion.Equal[NULL]}
		{
			return
		}
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
		variable index:lnavregionref endRegionsIndex
		variable index:lnavregionref startRegionsIndex
		variable string Region
		variable int RegionsFound
		variable int Index

		mypath:Clear
		Index:Set[1]

		call DebugOut "bNav:FindPath: Start ${startRegion} to ${endRegion}"

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
		RegionsFound:Set[${LNavRegion[${Me.Chunk}].DescendantsWithin[endRegionsIndex,3000,${LNavRegion[${endRegion}].CenterPoint}]}]

		call DebugOut "bNav:FindPath: Looking for regions within 3000: ${RegionsFound} found of ${LNavRegion[${endRegion}].Name}:${LNavRegion[${endRegion}].Type}"

		if ${RegionsFound} > 0
		{
			do
			{
				if ${endRegionsIndex.Get[${Index}].ConnectionCount} > 0
				{
					; ok, has connections, let's try a path
					aPathFinder:SelectPath[${LNavRegion[${startRegion}].FQN},${endRegionsIndex.Get[${Index}].FQN},mypath]
					if ${mypath.Hops} > 0
					{
						call DebugOut "bNav:FindPath: ${mypath.Hops} hops from ${LNavRegion[${startRegion}].FQN} to ${endRegionsIndex.Get[${Index}].FQN}"
						return TRUE
					}
				}
			}
			while ${endRegionsIndex.Get[${Index:Inc}](exists)}
		}

		mypath:Clear
		Index:Set[1]

		; Could not find a path from the closest point, so maybe that's the problem one
		Region:Set[${LNavRegion[${startRegion}].FQN}]

		; We need to iterate through all the nearby regions and find the closest one that also has connections
		RegionsFound:Set[${LNavRegion[${Me.Chunk}].DescendantsWithin[startRegionsIndex,2000,${LNavRegion[${startRegion}].CenterPoint}]}]

		call DebugOut "bNav:FindPath: Looking for regions within 2000: ${RegionsFound} found of ${LNavRegion[${Region}].Name}:${LNavRegion[${Region}].Type}"

		if ${RegionsFound} > 0
		{
			do
			{
				if ${startRegionsIndex.Get[${Index}].ConnectionCount} > 0
				{
					; ok, has connections, let's try a path
					aPathFinder:SelectPath[${startRegionsIndex.Get[${Index}].FQN},${LNavRegion[${endRegion}].FQN},mypath]
					if ${mypath.Hops} > 0
					{
						if !${This.CollisionTest[${Me.Location},${startRegionsIndex.Get[${Index}].CenterPoint}]}
						{
							call DebugOut "bNav:FindPath: ${mypath.Hops} hops from ${startRegionsIndex.Get[${Index}].FQN} to ${LNavRegion[${endRegion}].FQN}"
							return TRUE
						}
					}
				}
			}
			while ${startRegionsIndex.Get[${Index:Inc}](exists)}
		}

		; Could not find any paths
		mypath:Clear
		return FALSE
	}

	function StopMoving()
	{
		isMoving:Set[FALSE]
		VG:ExecBinding[moveforward,release]
		VG:ExecBinding[movebackward,release]
	}

	function StartMoving()
	{
		isMoving:Set[TRUE]
		tTimeOut:Set[${Time.Timestamp}]
		stuckCounter:Set[0]
	}

	member:bool Moving()
	{
		return ${isMoving}
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   ;;;;;;;;;;;;
	;;;;;;;;;;   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   ;;;;;;;;;;;;
	;;;;;;;;;;   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   ;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;  ;;;;;;;;;;;;;;;;;;;;;;;;;  ;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;   ;;;;;;;;;;;;;;;;;;;;;;;   ;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;                           ;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	function:bool MoveToMappedArea()
	{
		variable index:lnavregionref SurroundingRegions
		variable string Region
		variable int RegionsFound
		variable int Index = 1

		Region:Set[${This.CurrentRegionID}]

		; We need to iterate through all the nearby regions and find the closest one that also has connections
		RegionsFound:Set[${LNavRegion[${Region}].DescendantsWithin[SurroundingRegions,1500,${Me.Location}]}]

		call DebugOut "MoveToMap: Looking for regions within 1500: ${RegionsFound} found of ${LNavRegion[${Region}].Name}:${LNavRegion[${Region}].Type}"

		if ${RegionsFound} > 0
		{
			do
			{
				if ${SurroundingRegions.Get[${Index}].ConnectionCount} > 0 && !${This.CollisionTest[${LNavRegion[${Region}].CenterPoint}, ${SurroundingRegions.Get[${Index}].CenterPoint}]}
				{
					; ok, has connections and no collisions, let's MOVE!
					call doFastMove ${SurroundingRegions.Get[${Index}].CenterPoint.X} ${SurroundingRegions.Get[${Index}].CenterPoint.Y} 500
					isMoving:Set[FALSE]
					return TRUE
				}
			}
			while ${SurroundingRegions.Get[${Index:Inc}](exists)}
		}
		; Could not find any good regions
		return FALSE
	}

	function:string MovetoTargetName(string aTarget, bool checkMoved, int minDistance, bool checkMobs)
	{
		variable string CPname
		variable float WPX
		variable float WPY
		variable int iCheck
		variable string tName

		bpathindex:Set[1]

		call DebugOut "bNav: X: ${Pawn[${aTarget}].X} Y: ${Pawn[${aTarget}].Y} Z: ${Pawn[${aTarget}].Z}"

		call This.FindClosestPoint ${Pawn[${aTarget}].X} ${Pawn[${aTarget}].Y} ${Pawn[${aTarget}].Z}
		tName:Set[${Return}]

		call This.FindClosestPoint ${Me.X} ${Me.Y} ${Me.Z}
		CPname:Set[${Return}]

		call DebugOut "bNav: Names: ${CPname} :: ${tName}"

		mypath:Clear

		call FindPath "${CPname}" "${tName}"

		if !${Return}
		{
			return "NO PATH"
		}

		iCheck:Set[${Math.Calc[${mypath.Hops} * 0.8].Int}]

		call DebugOut "bNav:MovetoTargetName: Found Path to ${LNavRegion[${tName}].FQN} with ${mypath.Hops} hops from ${LNavRegion[${CPname}].FQN}"

		if ${mypath.Hops} > 0
		{
			WPX:Set[${mypath.Region[${bpathindex}].CenterPoint.X}]
			WPY:Set[${mypath.Region[${bpathindex}].CenterPoint.Y}]

			;Turn to face the desired loc
			Face ${WPX} ${WPY}

			do
			{
				if ${Pawn[${aTarget}].Distance} < ${minDistance}
				{
					; ok, Close enough
					return "END"
				}

				; Move to next Waypoint
				WPX:Set[${mypath.Region[${bpathindex}].CenterPoint.X}]
				WPY:Set[${mypath.Region[${bpathindex}].CenterPoint.Y}]

				call doFastMove ${WPX} ${WPY} 300 NULL ${checkMobs}

				if ${Return.Equal["STUCK"]}
				{
					CurrentConnection:SetConnection[${mypath.Connection[${bpathindex}]}]
					call DebugOut "bNav: Removing Connection ${mypath.Connection[${bpathindex}]}"
					CurrentConnection:Remove

					call doFastMove ${mypath.Region[${Math.Calc[${bpathindex}-2]}].CenterPoint.X} ${mypath.Region[${Math.Calc[${bpathindex}-2]}].CenterPoint.Y} 300 NULL ${checkMobs}
					call DebugOut "bNav: doFastMove return: ${Return}"

					mypath:Clear
					CurrentConnection:Clear

					call This.FindClosestPoint ${Me.X} ${Me.Y} ${Me.Z}
					CPname:Set[${Return}]

					call FindPath "${CPname}" "${tName}"

					if !${Return}
					{
						return "NO PATH"
					}

					call DebugOut "bNav: mypath.Hops: ${mypath.Hops}"

					if ${mypath.Hops} > 0
					{
						call DebugOut "bNav: Found new path to ${tName} with ${mypath.Hops} hops."
						bpathindex:Set[1]
					}
					else
					{
						VG:ExecBinding[moveforward,release]

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

						CPname:Set[${mypath.Region[${bpathindex}].Name}]

						mypath:Clear

						call FindPath "${CPname}" "${tName}"

						if !${Return}
						{
							return "NO PATH"
						}

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
			while ${bpathindex:Inc} <= ${mypath.Hops}

			VG:ExecBinding[moveforward,release]

			return "END"
		}
		else
		{
			return "NO PATH"
		}

	}

	function:string MovetoXYZ(int iX, int iY, int iZ, bool iCheckMobs)
	{
		variable string CPname

		call This.FindClosestPoint ${iX} ${iY} ${iZ}
		CPname:Set[${Return}]

		call MovetoWP "${CPname}" ${iCheckMobs}

		return "${Return}"
	}

	function:string MovetoWP(string destination, bool checkMobs)
	{
		variable string CPname
		variable float WPX
		variable float WPY
		variable int iCheck

		bpathindex:Set[1]

		mypath:Clear


		call This.FindClosestPoint ${Me.X} ${Me.Y} ${Me.Z}
		CPname:Set[${Return}]

		call FindPath "${CPname}" "${destination}"

		if !${Return}
		{
			return "NO PATH"
		}

		call DebugOut "bNav:MovetoWP: Found Path to ${LNavRegion[${destination}].FQN} with ${mypath.Hops} hops from ${LNavRegion[${CPname}].FQN}"

		iCheck:Set[${Math.Calc[${mypath.Hops} * 0.8].Int}]

		if ${mypath.Hops} > 0
		{
			WPX:Set[${mypath.Region[${bpathindex}].CenterPoint.X}]
			WPY:Set[${mypath.Region[${bpathindex}].CenterPoint.Y}]

			;Turn to face the desired loc
			Face ${WPX} ${WPY}

			do
			{
				; Move to next Waypoint
				WPX:Set[${mypath.Region[${bpathindex}].CenterPoint.X}]
				WPY:Set[${mypath.Region[${bpathindex}].CenterPoint.Y}]

				call doFastMove ${WPX} ${WPY} 300 NULL ${checkMobs}

				if ${Return.Equal["STUCK"]}
				{
					CurrentConnection:SetConnection[${mypath.Connection[${bpathindex}]}]
					call DebugOut "bNav: Removing Connection ${mypath.Connection[${bpathindex}]}"
					CurrentConnection:Remove

					call doFastMove ${mypath.Region[${Math.Calc[${bpathindex}-2]}].CenterPoint.X} ${mypath.Region[${Math.Calc[${bpathindex}-2]}].CenterPoint.Y} 300 NULL ${checkMobs}
					call DebugOut "bNav: doFastMove return: ${Return}"

					mypath:Clear
					CurrentConnection:Clear

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
					if !${CurrentChunk.Equal[${Me.Chunk}]}	
					{
						VG:ExecBinding[moveforward,release]
						return "STUCK"
					}
				}
			}
			while ${bpathindex:Inc} <= ${mypath.Hops} && !${Me.InCombat}

			VG:ExecBinding[moveforward,release]

			return "END"
		}
		else
		{
			return "NO PATH"
		}
	}

	function:string FastMove(float X, float Y, int range, string Region, bool checkMobs)
	{
		call DebugOut "bNav: FastMove ${X} ${Y} ${range} ${Region} ${checkMobs}"

		do
		{
			call doFastMove ${X} ${Y} ${range} ${Region} ${checkMobs}
		}
		while ${Return.Equal[MOVING]}

		return "${Return}"
	}

	function:string doFastMove(float X, float Y, int range, string Region, bool checkMobs)
	{
		variable float xDist
		variable float SavDist = ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}
		variable int xTimer
		variable int FullTimer

		;call DebugOut "bNav: doFastMove: ${X} ${Y}"

		Face ${X} ${Y}

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

			if ${CurrentRegion.Equal[${Region}]}
			{
				return "SUCCESS"
			}

			Face ${X} ${Y}

		}
		while (${Math.Distance[${Me.X},${Me.Y},${X},${Y}]} > ${range}) && (${Math.Calc[${Time.Timestamp} - ${FullTimer}]} < 3)

		if (${Math.Distance[${Me.X},${Me.Y},${X},${Y}]} < ${range})
		{
			return "SUCCESS"
		}
		else
		{
			;call DebugOut "bNav: MOVING ${Math.Calc[${Time.Timestamp}-${FullTimer}]}"
			return "MOVING"
		}
	}

	/*
	*****************************************************************************************************
	
	*****************************************************************************************************
	
	*****************************************************************************************************
	***                                ******************************************************************
	***                                                               ***********************************
	***********************************                                                         *********
	*****************************************************************************************************
	
	*****************************************************************************************************
	
	*****************************************************************************************************
	*/

	function:string SetupPathXYZ(int iX, int iY, int iZ)
	{
		variable string currentP
		variable string destP

		call This.FindClosestPoint ${Me.X} ${Me.Y} ${Me.Z}
		currentP:Set[${Return}]

		call This.FindClosestPoint ${iX} ${iY} ${iZ}
		destP:Set[${Return}]

		bpathindex:Set[1]

		mypath:Clear

		call FindPath "${currentP}" "${destP}"

		if !${Return}
		{
			return "NO PATH"
		}

		call DebugOut "bNav:MovetoWP: Found Path to ${LNavRegion[${destP}].FQN} with ${mypath.Hops} hops from ${LNavRegion[${currentP}].FQN}"

		return "END"
	}

	method Move()
	{
		variable float WPX
		variable float WPY

		if !${isMoving}
		{
			return
		}

		WPX:Set[${mypath.Region[${bpathindex}].CenterPoint.X}]
		WPY:Set[${mypath.Region[${bpathindex}].CenterPoint.Y}]

		;Turn to face the desired loc
		Face ${WPX} ${WPY}

		VG:ExecBinding[moveforward]

		if ${Math.Distance[${Me.X},${Me.Y},${WPX},${WPY}]} < 200
		{
			; See if we are at the end of the current Path
			if ${bpathindex} == ${mypath.Hops}
			{
				call This.StopMoving
				isMoving:Set[FALSE]
				bpathindex:Set[1]
				mypath:Clear
			}
			else
			{
				bpathindex:Inc
				tTimeOut:Set[${Time.Timestamp}]
				stuckCounter:Set[0]
			}
		}
		elseif (${Math.Calc[${Time.Timestamp} - ${tTimeOut.Timestamp}]}) > 5
		{
			; We are STUCK!
			if ${stuckCounter} > 3
			{
				; We keep getting stuck here, so let's remove this connection
				CurrentConnection:SetConnection[${mypath.Connection[${bpathindex}]}]
				call DebugOut "bNav: Removing Connection ${mypath.Connection[${bpathindex}]}"
				CurrentConnection:Remove
				; Now Stop moving and let the calling program deal with it.
				call This.StopMoving
				isMoving:Set[FALSE]
				bpathindex:Set[1]
				mypath:Clear
				return
			}
			; Try moving back to the previous path index
			bpathindex:Dec
			tTimeOut:Set[${Time.Timestamp}]
			stuckCounter:Inc
		}

	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

		variable string Region = ${This.CurrentRegionID}
		if !${LNavRegion[${Region}].Type.Equal[Universe]}
		{
			LNavRegion[${Region}]:SetCustom["level", ${This.getlvl}]
			LNavRegionGroup["hunt"]:Add[${Region}]
		}

	}

}


/************************************************************************/

atom Bump(string Name)
{
	if (${Name.Find[Mover]})
	{
		VG:ExecBinding[UseDoorEtc]
	}
	elseif
	{
		; just return for now
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


