;-----------------------------------------------------------------------------------------------
; Obj_Navigator
;
; Description - this file handles all navigating routines to include automapping and movement
; --------------
; * automatically load settings every time you chunk
; * will automap using box method
; * will plot a point
; * uses both dijkstra and astar in finding a path to destination
; * will move to a point/destination
; * will get back on map if within 30m of nearest point having no collision


objectdef Obj_Navigator
{
	;; variables used by script
	variable int bpathindex
	variable lnavpath mypath
	variable astarpathfinder PathFinderA
	variable dijkstrapathfinder PathFinderD
	variable lnavconnection CurrentConnection
	variable string PointName
	variable string  LastRegion
	variable string  CurrentRegion
	variable string CurrentChunk
	variable bool FaceNow=TRUE
	variable bool doSave=FALSE
	variable bool doMoveToMappedArea=TRUE
	variable bool isMoving=FALSE
	variable bool doMapping=FALSE
	variable bool doFindPath=FALSE
	variable bool doMoveToPoint=FALSE
	variable filepath ChunkFilePath = "${Script.CurrentDirectory}/Paths"
	variable string CurrentChunk
	variable point3f LastKnownSpot
	variable int NextOnMapCheck
	variable bool doDumpToFile=FALSE



	;; define our object Face that's used within this script
	;variable obj_Face Face

	;; Initialize when objectdef is created
	method Initialize()
	{
		if ${ChunkFilePath.FileExists[/Debug.txt]}
		{
			rm "${This.ChunkFilePath}/Debug.txt"
		}
		LavishNav:Clear
		This.CurrentChunk:Set[${Me.Chunk}]
		This:LoadMap["${Me.Chunk}"]
		This.CurrentRegion:Set[${This.CurrentREGION}]
		This.LastRegion:Set[${This.CurrentREGION}]
		This.doSave:Set[FALSE]
		This.isMoving:Set[FALSE]
		This.doMapping:Set[FALSE]
		This.doFindPath:Set[FALSE]
		This.doMoveToPoint:Set[FALSE]
		Event[OnFrame]:AttachAtom[This:HandleEvent]
		Event[VG_onHitObstacle]:AttachAtom[Bump]
		This:EchoIt["Started"]
	}

	;; called when script is shut down
	method Shutdown()
	{
		This:Stop
		Event[OnFrame]:DetachAtom[This:HandleEvent]
		This:SavePaths
		This:EchoIt["Finished"]
	}

	;; called when script is shut down
	method ClearAll()
	{
		This:Stop
		LavishNav:Clear
		This:EchoIt["Creating New Zone:  ${Me.Chunk}"]
		LavishNav.Tree:AddChild[universe,${Me.Chunk},-unique]
		This.doSave:Set[TRUE]
		This:SavePaths
		if !${This.doMapping}
		{
			This.doSave:Set[FALSE]
		}
	}

	;; attempt to save if we chuncked
	method SaveMap()
	{
		;; if we turn on mapping then we need to save
		if ${This.doSave}
		{
			;; save only if we chunked
			if !${This.CurrentChunk.Equal[${Me.Chunk}]}
			{
				mkdir "${This.ChunkFilePath}"
				LNavRegion[${This.CurrentChunk}]:Export[${This.ChunkFilePath}/${This.CurrentChunk}.xml]
				LNavRegion[${This.CurrentChunk}]:Export[-lso,${This.ChunkFilePath}/${This.CurrentChunk}.lso]
				This:EchoIt["Saved paths to ${This.CurrentChunk}"]
				This.CurrentChunk:Set[${Me.Chunk}]
			}
		}
	}

	;; keep loading chunks into memory (lso's are smaller and quicker to load)
	method LoadMap(string MapToLoad)
	{
		if ${Me.Chunk(exists)}
		{
			if ${LavishNav.FindRegion[${MapToLoad}].ID}==0
			{
				This:EchoIt["Loading map: ${MapToLoad}"]
				if ${This.ChunkFilePath.FileExists[${MapToLoad}.lso]}
				{
					This:EchoIt["Loading LSO file: ${This.ChunkFilePath}/${MapToLoad}"]
					LavishNav.Tree:Import[-lso,${This.ChunkFilePath}/${MapToLoad}.lso]
				}
				elseif ${This.ChunkFilePath.FileExists[${MapToLoad}.xml]}
				{
					This:EchoIt["Loading XML file: ${ChunkFilePath}/${MapToLoad}"]
					LavishNav.Tree:Import[${This.ChunkFilePath}/${MapToLoad}.xml]
				}
				else
				{
					This:EchoIt["No LSO or XML file found. Creating a new file."]
					LavishNav.Tree:AddChild[universe,${MapToLoad},-unique]
				}
			}
			else
			{
				;; No need to echo this if we are spamming it constantly
				;This:EchoIt["This map is already loaded: ${MapToLoad}"]
			}
		}
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Good - executed by Shutdown
	method SavePaths()
	{
		if ${This.doSave}
		{
			mkdir "${This.ChunkFilePath}"
			LNavRegion[${Me.Chunk}]:Export[${This.ChunkFilePath}/${Me.Chunk}.xml]
			LNavRegion[${Me.Chunk}]:Export[-lso,${This.ChunkFilePath}/${Me.Chunk}.lso]
			This:EchoIt["Saved paths to ${Me.Chunk}"]
		}
		LNavRegion[${Me.Chunk}]:Remove
	}

	;; Example:  Navigate:Stop
	method Stop()
	{
		if ${This.isMoving}
		{
			VG:ExecBinding[moveforward,release]
		}
		This.doMoveToPoint:Set[FALSE]
		This.isMoving:Set[FALSE]
		This.doFindPath:Set[FALSE]
		This.doMoveToMappedArea:Set[TRUE]
	}

	method MoveForward()
	{
		VG:ExecBinding[moveforward]
		This.isMoving:Set[TRUE]
	}

	method StartMapping()
	{
		This.doMapping:Set[TRUE]
		This.doSave:Set[TRUE]
		This.CurrentChunk:Set[${Me.Chunk}]
	}

	;;
	method StopMapping()
	{
		This.doMapping:Set[FALSE]
	}

	;; Example:   Naviagate:MoveToPoint[${PointName}]
	method MoveToPoint(string Destination)
	{
		if ${Destination.Length}
		{
			This.PointName:Set[${Destination}]
			This:EchoIt["MoveToPoint: Moving to ${This.PointName}..."]
			This.doFindPath:Set[TRUE]
			This.doMoveToPoint:Set[TRUE]
			return
		}
	}

	method StartDumpToFile()
	{
		This.doDumpToFile:Set[TRUE]
	}

	method StopDumpToFile()
	{
		This.doDumpToFile:Set[FALSE]
	}

	method EchoIt(string aText)
	{
		if ${This.doDumpToFile}
		{
			redirect -append "${This.ChunkFilePath}/Debug.txt" echo "[${Time}] ${aText}"
			echo "[${Time}] ${aText}"
		}
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; DO NOT CALL THIS - IT IS AN ATTACHED ATOM "OnFrame"
	method HandleEvent()
	{
		;; Save current map
		This:SaveMap

		;; Keep loading maps as we chunk
		This:LoadMap["${Me.Chunk}"]

		;; Map as you move
		if ${This.doMapping}
		{
			This:AutoBox
			This:ConnectOnMove
		}

		;; Start mapping if we are not moving to a point
		if !${This.doMoveToPoint}
		{
			This:Stop
			return
		}

		;; Check to see if we are on the map
		if !${This.IsMapped[${Me.X},${Me.Y},${Me.Z}]}
		{
			call MoveToMappedArea
			return
		}

		;; Keep Trying
		if ${This.doFindPath}
		{
			call This.FindPath ${This.PointName}
			if !${Return}
			{
				This:EchoIt["No Path Found"]
				This:Stop
				call MoveToMappedArea
				return
			}
			This.doMoveToMappedArea:Set[TRUE]
			This.doFindPath:Set[FALSE]
		}

		;; return if we are already there (bpathindex is updated when FindPath and TakeNextHop is called)
		if ${This.bpathindex}>=${mypath.Hops}
		{
			This:EchoIt["HandleEvent: Reached ${This.PointName}... bpath=${This.bpathindex}, Hops=${mypath.Hops}"]
			This:Stop
			return
		}

		;; Start moving
		This:TakeNextHop
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; TO DO:  Pass it a destination that needs to check if on correct map - Do not call this from your routines
	function:bool MoveToMappedArea()
	{
		;; No need to get back onto the map if we are already on it!
		if ${This.IsMapped[${Me.X},${Me.Y},${Me.Z}]}
		{
			if !${doMoveToMappedArea}
			{
				This:Stop
			}
			NextOnMapCheck:Set[${Script.RunningTime}]
			This.doMoveToMappedArea:Set[TRUE]
			return
		}

		;; We are already moving onto the map
		if !${doMoveToMappedArea}
		{
			if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextOnMapCheck}]}/1000]}<1
			{
				This:MoveForward
				return
			}
			NextOnMapCheck:Set[${Script.RunningTime}]
		}

		This:EchoIt["Moving back onto map"]


		This.doMoveToMappedArea:Set[FALSE]
		variable index:lnavregionref SurroundingRegions
		variable string Region
		variable int RegionsFound
		variable int Index = 1
		variable int ClosetConnection = 10000000
		variable int IndexTemp = 0

		Region:Set[${Me.Chunk}]

		; We need to iterate through all the nearby regions and find the closest one that also has connections
		RegionsFound:Set[${LNavRegion[${Region}].DescendantsWithin[SurroundingRegions,1000,${Me.Location}]}]

		This:EchoIt["RegionsFound=${RegionsFound}"]

		if ${RegionsFound} > 0
		{
			;; find closest connection to us
			while ${SurroundingRegions.Get[${IndexTemp:Inc}](exists)}
			{
				This:EchoIt["[${RegionsFound}/${IndexTemp}][ConnectionCount=${SurroundingRegions.Get[${IndexTemp}].ConnectionCount}][Collision=${This.CollisionTest[${Me.Location}, ${SurroundingRegions.Get[${IndexTemp}].CenterPoint}]}][Distance=${Math.Distance[${Me.X},${Me.Y},${SurroundingRegions.Get[${IndexTemp}].CenterPoint.X},${SurroundingRegions.Get[${IndexTemp}].CenterPoint.Y}].Int}] "]

				if ${SurroundingRegions.Get[${IndexTemp}].ConnectionCount} > 0
				{
					;; avoid any collisions
					if ${SurroundingRegions.Get[${IndexTemp}].ConnectionCount} > 0 && !${This.CollisionTest[${Me.Location}, ${SurroundingRegions.Get[${IndexTemp}].CenterPoint}]}
					{
						;; if connection is closer then update Index
						if ${Math.Distance[${Me.X},${Me.Y},${SurroundingRegions.Get[${IndexTemp}].CenterPoint.X},${SurroundingRegions.Get[${IndexTemp}].CenterPoint.Y}]} <= ${ClosetConnection} &&  ${Math.Distance[${Me.X},${Me.Y},${SurroundingRegions.Get[${IndexTemp}].CenterPoint.X},${SurroundingRegions.Get[${IndexTemp}].CenterPoint.Y}]} > 500
						{
							Index:Set[${IndexTemp}]
							ClosetConnection:Set[${Math.Distance[${Me.X},${Me.Y},${SurroundingRegions.Get[${IndexTemp}].CenterPoint.X},${SurroundingRegions.Get[${IndexTemp}].CenterPoint.Y}]}]
						}
					}
				}
			}

			This:EchoIt["Index=${Index}, ClosetConnection=${ClosetConnection}"]

			;; if there is a connection closest to us, then face it and start moving
			if ${SurroundingRegions.Get[${Index}].ConnectionCount} > 0
			{
				if ${Math.Distance[${Me.X},${Me.Y},${SurroundingRegions.Get[${Index}].CenterPoint.X},${SurroundingRegions.Get[${Index}].CenterPoint.Y}].Int}<3000
				{
					This:EchoIt["MoveToMappedArea called - Moving to nearest connector that is ${Math.Distance[${Me.X},${Me.Y},${SurroundingRegions.Get[${Index}].CenterPoint.X},${SurroundingRegions.Get[${Index}].CenterPoint.Y}].Int} distance away"]
					face ${SurroundingRegions.Get[${Index}].CenterPoint.X} ${SurroundingRegions.Get[${Index}].CenterPoint.Y}
					This:MoveForward
					return TRUE
				}
				else
				{
					This:EchoIt["MoveToMappedArea called - Nearest connector is ${Math.Distance[${Me.X},${Me.Y},${SurroundingRegions.Get[${Index}].CenterPoint.X},${SurroundingRegions.Get[${Index}].CenterPoint.Y}].Int} distance away"]
				}
			}
		}
		; Could not find any good regions
		This:EchoIt["Not able to move back onto map"]
		return FALSE
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Good - you may use this within your routine
	member:bool IsMapped(float X, float Y, float Z)
	{
		variable string Region
		Region:Set[${LNavRegion[${Me.Chunk}].BestContainer[${X},${Y},${Z}].ID}]

		;; when it is not mapped it is Universe, otherwise, it would be Box
		if ${LNavRegion[${Region}].Type.Equal[Universe]}
		{
			;echo FALSE - ${LNavRegion[${Region}].Type} // ${LNavRegion[${Region}]}
			return FALSE
		}

		;; if it does not have any connections then we are not mapped
		if ${LNavRegion[${Region}].ConnectionCount}==0
		{
			return FALSE
		}

		;echo TRUE - ${LNavRegion[${Region}].Type} // ${LNavRegion[${Region}]}
		return TRUE
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Good - you may use this within your routines
	method AddNamedPoint(string pointname, string custom)
	{
		if ${pointname.Length}
		{
			LNavRegion[${LNavRegion[${This.CurrentREGION}].AddChild[point,${pointname},-unique,${Me.X},${Me.Y},${Me.Z}].ID}]:SetCustom[${custom}]
			if !${LNavRegion[${pointname}].Parent.Type.Equal[Universe]}
			{
				LNavRegion[${LNavRegion[${pointname}].Parent.Name}]:Connect[${pointname}]
			}
			This:EchoIt["Added point ${pointname} to ${LNavRegion[${This.CurrentREGION}].Name}"]
			return
		}
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Good - you may use this within your routines
	method AddHuntPoint()
	{
		variable string Region=${This.CurrentREGION}
		if !${LNavRegion[${Region}].Type.Equal[Universe]}
		{
			LNavRegion[${Region}]:SetCustom["level", ${This.getlvl}]
			LNavRegionGroup["hunt"]:Add[${Region}]
		}
	}


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Good - Do not call this from your routines
	method AutoBox()
	{
		variable string Region
		Region:Set[${LNavRegion[${Me.Chunk}].BestContainer[${Me.X},${Me.Y}, ${Me.Z}].ID}]
		if ${LNavRegion[${Region}].Type.Equal[Universe]}
		{
			This:EchoIt["Adding to ${LNavRegion[${This.CurrentREGION}].FQN}"]

			;; trying different types
			LNavRegion[${This.CurrentREGION}]:AddChild[box,"auto",-unique,${Math.Calc[${Me.X}-300]},${Math.Calc[${Me.X}+300]}, ${Math.Calc[${Me.Y}-300]}, ${Math.Calc[${Me.Y}+300]}, ${Math.Calc[${Me.Z}-300]},${Math.Calc[${Me.Z}+300]}]

			Region:Set[${LNavRegion[${Me.Chunk}].BestContainer[${Me.X},${Me.Y}, ${Me.Z}].ID}]
			This.CurrentRegion:Set[${LNavRegion[${Region}].Name}]
			LNavRegion[${This.CurrentRegion}]:SetAllPointsValid[TRUE]
		}

	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Good - Do not call this from your routines
	method ConnectOnMove()
	{
		This.CurrentRegion:Set[${This.CurrentREGION}]

		if !${This.CurrentRegion.Equal[${This.LastRegion}]} && !${LNavRegion[${This.CurrentRegion}].Type.Equal[Universe]} && !${LNavRegion[${This.LastRegion}].Type.Equal[Universe]} && !${LNavRegion[${This.LastRegion}].Avoid} && !${LNavRegion[${This.CurrentRegion}].Avoid}
		{
			if ${This.LastRegion.Length}
			{
				This:EchoIt["Moved from ${This.LastRegion} to ${This.CurrentRegion} making a 2 way connection"]
			}
			LNavRegion[${This.CurrentRegion}]:Connect[${This.LastRegion}]
			LNavRegion[${This.LastRegion}]:Connect[${This.CurrentRegion}]
		}
		This.LastRegion:Set[${This.CurrentRegion}]
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Good - used by almost all routines
	member CurrentREGION()
	{
		variable string Region

		Region:Set[${LNavRegion[${Me.Chunk}].BestContainer[${Me.X},${Me.Y},${Me.Z}].ID}]

		if ${LNavRegion[${Region}].Type.Equal[Point]}
		{
			return ${LNavRegion[${Region}].Parent.ID}
		}
		return ${LNavRegion[${Region}].ID}
	}


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Good - Do not call this from your routines
	function:bool FindPath(string destination)
	{
		This.bpathindex:Set[1]
		variable string CPname
		mypath:Clear
		CPname:Set[${This.CurrentREGION}]

		; BUILD PATH - use dijkstrapathfinder version
		This.PathFinderD:SelectPath[${LNavRegion[${CPname}]},${LNavRegion[${Me.Chunk}].FindRegion[${destination}]},mypath]
		if ${mypath.Hops} <= 0
		{
			;; TRY AGAIN - use astarpathfinder version
			mypath:Clear
			This.PathFinderA:SelectPath[${LNavRegion[${CPname}]},${LNavRegion[${Me.Chunk}].FindRegion[${destination}]},mypath]
		}

		;; FAILED - unable to map to destination if hops is 0
		if ${mypath.Hops} <= 0
		{
			if !${LNavRegion[${Me.Chunk}].FindRegion[${destination}](exists)}
			{
				;This:EchoIt["Point does not exist or too far away - (${destination})"]
				return FALSE
			}
			return FALSE
		}

		;; SUCCESS - we have more than 1 hop
		if ${mypath.Hops} > 0
		{
			This:EchoIt["Found Path to ${destination} with ${mypath.Hops} hops from ${LNavRegion[${CPname}].Name}"]
			return TRUE
		}
		return FALSE

	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Good - Do not call this from your routines
	method TakeNextHop()
	{
		variable float WPX
		variable float WPY

		;; bpath is where we are on the path!
		WPX:Set[${mypath.Region[${This.bpathindex}].CenterPoint.X}]
		WPY:Set[${mypath.Region[${This.bpathindex}].CenterPoint.Y}]

		;; We are near our point so let's set our pointer to the next point on path
		while ${Math.Distance[${Me.X},${Me.Y},${WPX},${WPY}]}<=250 && ${This.bpathindex}<${mypath.Hops}
		{
			;; keep incrementing counter until it is more than 4m away - should help on the ping-ponging
			This:EchoIt["Hop = ${This.bpathindex} of ${mypath.Hops} and Distance = ${Math.Distance[${Me.X},${Me.Y},${WPX},${WPY}].Int}"]

			This.bpathindex:Inc
			WPX:Set[${mypath.Region[${This.bpathindex}].CenterPoint.X}]
			WPY:Set[${mypath.Region[${This.bpathindex}].CenterPoint.Y}]

		}

		;; Move towards our point on path
		if ${Math.Distance[${Me.X},${Me.Y},${WPX},${WPY}]}>250 && ${This.bpathindex}<=${mypath.Hops}
		{
			face ${WPX} ${WPY}
			This:MoveForward
			return
		}
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Good - Do not call this from your routines
	member:bool CollisionTest(float FromX, float FromY, float FromZ, float ToX, float ToY, float ToZ)
	{
		variable point3f From
		From:Set[${FromX}, ${FromY}, {$FromZ}]

		variable point3f To
		To:Set[${ToX}, ${ToY}, {$ToZ}]

		variable point3f TEST1
		TEST1:Set[${VG.CheckCollision[${To}, ${From}].Location}]

		variable point3f TEST2
		TEST2:Set[${VG.CheckCollision[${From}, ${To}].Location}]

		if	( ${${TEST1}(exists)} || ${${TEST2}(exists)} )
		;if	( ${${TEST1}(exists)} || ${${TEST2}(exists)} || ${VG.CheckCollision[${To.X},${To.Y},${To.Z}](exists)})
		{
			This:EchoIt["Collision = TRUE, Collision actor=${VG.CheckCollision[${To.X}, ${To.Y}, ${To.Z}]} at ${VG.CheckCollision[${To.X}, ${To.Y}, ${To.Z}].Location}"]
			return TRUE
		}
		return FALSE
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Good - used by AddHuntPoint - Do not call this from your routines
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

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Used by MovetoWP
	function FindClosestPoint(int myx, int myy, int myz)
	{
		variable string Container
		Container:Set[${LNavRegion[${This.CurrentREGION}].BestContainer[${myx},${myy},${myz}]}]
		if !${LNavRegion[${Container}].Type.Equal[Universe]}
		{
			Container:Set[${LNavRegion[${Container}]}]
			return ${Container}
		}
		return ${LNavRegion[${Container}].NearestChild[${myx}, ${myy}, ${myz}]}
	}
}

atom Bump(string Name)
{
	if (${Name.Find[Mover]})
	{
		VG:ExecBinding[UseDoorEtc]
	}
	else
	{
		variable string Region
		Region:Set[${LNavRegion[${Me.Chunk}].BestContainer[${Me.X},${Me.Y}].ID}]
		if !${LNavRegion[${Region}].Avoid}
		{
			LNavRegion[${Region}]:AddChild[rect,"auto",-unique,${Math.Calc[${Me.X}-50]},${Math.Calc[${Me.X}+50]}, ${Math.Calc[${Me.Y}-50]}, ${Math.Calc[${Me.Y}+50]}]
			Region:Set[${LNavRegion[${Me.Chunk}].BestContainer[${Me.X},${Me.Y}].ID}]
			LNavRegion[${Region}]:SetAvoid[TRUE]
			LNavRegion[${Region}]:SetAllPointsValid[FALSE]
			LNavRegion[${Region}].Parent:SetAllPointsValid[FALSE]
			This:EchoIt["Not all valid! ${LNavRegion[${Region}].Name}"]
		}
	}
}


