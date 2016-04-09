;variable string lastpoint = "init"
variable string  CurrentRegion
variable string  LastRegion
variable bool debug=TRUE
variable int bpathindex
variable lnavpath mypath
variable astarpathfinder PathFinder
variable lnavconnection CurrentConnection

objectdef  bnav
{
	method AddNamedPoint(string pointname, string custom)
	{
		if ${pointname.Length}
		{
			LNavRegion[${LNavRegion[${This.CurrentRegion}].AddChild[point,${pointname},-unique,${Me.X},${Me.Y},${Me.Z}].ID}]:SetCustom[${custom}]
			;LNavRegion[${This.CurrentRegion}]:AddChild[point,${pointname},-unique,${Me.X},${Me.Y},${Me.Z}]
			;LNavRegion[${pointname}]:SetCustom[${custom}]
			if !${LNavRegion[${pointname}].Parent.Type.Equal[Universe]}
			{
				LNavRegion[${LNavRegion[${pointname}].Parent.Name}]:Connect[${pointname}]
			}
			if ${debug}
			{
				echo Added point ${pointname} to ${LNavRegion[${This.CurrentRegion}].Name}
			}
			return
		}

	}

	function:bool Initialize()
	{
		variable filepath ConfigPath = "${LavishScript.CurrentDirectory}/Scripts/VGPATHS/"
		Event[VG_onHitObstacle]:AttachAtom[Bump]
		LavishNav:Clear
		;Look for zone file and load it, else create a new once
		if ${ConfigPath.FileExists[${Me.Chunk}.xml]}
		{
			LavishNav.Tree:Import[${ConfigPath}${Me.Chunk}.xml]
			echo Loaded ${ConfigPath}${Me.Chunk}.xml with ${LNavRegion[${Me.Chunk}].ChildCount} children
		}
		else
		{
			echo Creating New Zone
			LavishNav.Tree:AddChild[universe,${Me.Chunk},-unique]
		}
		if !${Script[Connector](exists)}
		{
			run "${LavishScript.CurrentDirectory}/Scripts/bohika/Connector.iss"
		}
		waitframe
		if !${Script[Connector](exists)}
		{
			return FALSE
		}
			
		return TRUE
	}
	
	method SavePaths()
	{
		variable filepath ConfigPath = "${LavishScript.CurrentDirectory}/Scripts/VGPATHS/"
		LNavRegion[${Me.Chunk}]:Export[${ConfigPath}/${Me.Chunk}.xml]
		LNavRegion[${Me.Chunk}]:Remove
	}
		
	method AutoBox()
	{
		variable string Region
		Region:Set[${LNavRegion[${Me.Chunk}].BestContainer[${Me.X},${Me.Y}, ${Me.Z}].ID}]
		if ${LNavRegion[${Region}].Type.Equal[Universe]}
		{
			if ${debug}
			{
				echo Adding to ${LNavRegion[${This.CurrentRegion}].FQN}
			}
			LNavRegion[${This.CurrentRegion}]:AddChild[box,"auto",-unique,${Math.Calc[${Me.X}-250]},${Math.Calc[${Me.X}+250]}, ${Math.Calc[${Me.Y}-250]}, ${Math.Calc[${Me.Y}+150]}, ${Math.Calc[${Me.Z}-250]},${Math.Calc[${Me.Z}+150]}]
			Region:Set[${LNavRegion[${Me.Chunk}].BestContainer[${Me.X},${Me.Y}, ${Me.Z}].ID}]
			CurrentRegion:Set[${LNavRegion[${Region}].Name}]
			LNavRegion[${CurrentRegion}]:SetAllPointsValid[TRUE]
		}

	}

	method ConnectOnMove()
	{
		CurrentRegion:Set[${This.CurrentRegion}]
		if !${CurrentRegion.Equal[${LastRegion}]} && !${LNavRegion[${CurrentRegion}].Type.Equal[Universe]} && !${LNavRegion[${LastRegion}].Type.Equal[Universe]} && !${LNavRegion[${LastRegion}].Avoid} && !${LNavRegion[${CurrentRegion}].Avoid}
		{
			if ${debug}
			{
				echo Moved from ${LastRegion} to ${CurrentRegion} making a 2 way connection
			}
			LNavRegion[${CurrentRegion}]:Connect[${LastRegion}]
			LNavRegion[${LastRegion}]:Connect[${CurrentRegion}]
		}
		LastRegion:Set[${CurrentRegion}]
	}

	function FindClosestPoint(int myx, int myy, int myz)
	{

		variable string Container
		Container:Set[${LNavRegion[${This.CurrentRegion}].BestContainer[${myx},${myy},${myz}]}]
		if !${LNavRegion[${Container}].Type.Equal[Universe]}
		{
			Container:Set[${LNavRegion[${Container}]}]
			return ${Container}
		}
		return ${LNavRegion[${Container}].NearestChild[${myx}, ${myy}, ${myz}]}
	}

	member CurrentRegion()
	{
		variable string Region

		Region:Set[${LNavRegion[${Me.Chunk}].BestContainer[${Me.X},${Me.Y},${Me.Z}].ID}]
		;Region:Set[${LNavRegion[${Me.Chunk}].BestContainer[${Me.X},${Me.Y}].ID}]

		if ${LNavRegion[${Region}].Type.Equal[Point]}
		{
			return ${LNavRegion[${Region}].Parent.ID}
		}
		return ${LNavRegion[${Region}].ID}
	}

	function:bool FindPath(string destination)
	{
		bpathindex:Set[1]
		variable string CPname
		variable float WPX
		variable float WPY
		mypath:Clear
		;call This.FindClosestPoint ${Me.X} ${Me.Y} ${Me.Z}
		CPname:Set[${This.CurrentRegion}]
		PathFinder:SelectPath[${LNavRegion[${CPname}]},${LNavRegion[${Me.Chunk}].FindRegion[${destination}]},mypath]
		if ${debug}
		{
			echo Found Path to ${destination} with ${mypath.Hops} hops from ${LNavRegion[${CPname}].Name}
		}
		if ${mypath.Hops} > 0
		{
			return TRUE
		}
		return FALSE
		
	}
	
	function:bool TakeNextHop()
	{
		variable float WPX
		variable float WPY
		echo ${bpathindex}
;		if ${bpathindex} >= ${mypath.Hops}
;		{
;			echo "WE R THERE"
;			VG:ExecBinding[moveforward,release]
;			TravelState:Set[${PathStateEnd}]
;			return TRUE
;		}
		WPX:Set[${mypath.Region[${bpathindex}].CenterPoint.X}]
		WPY:Set[${mypath.Region[${bpathindex}].CenterPoint.Y}]
		call FastMove ${WPX} ${WPY} 100 ${mypath.Region[${bpathindex}]}
		echo ${Return}
		if ${Return.Equal["STUCK"]}
		{
			CurrentConnection:SetConnection[${mypath.Connection[${bpathindex}]}]
			if ${debug}
			{
				echo Removing Connection ${mypath.Connection[${bpathindex}]}
			}
			CurrentConnection:Remove
			call FastMove ${mypath.Region[${Math.Calc[${bpathindex}-1]}].CenterPoint.X} ${mypath.Region[${Math.Calc[${bpathindex}-1]}].CenterPoint.Y} 100
			if ${debug}
			{
				echo ${Return}
			}		
			return FALSE
		}
		if ${Return.Equal["SUCCESS"]}
		{
			bpathindex:Inc
		}
		return TRUE
		
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	function MovetoWP(string destination)
	{

		bpathindex:Set[1]
		variable string CPname
		variable float WPX
		variable float WPY
		mypath:Clear
		call This.FindClosestPoint ${Me.X} ${Me.Y} ${Me.Z}
		CPname:Set[${Return}]
		PathFinder:SelectPath[${LNavRegion[${CPname}].ID},${LNavRegion[${This.CurrentRegion}].FindRegion[${destination}].ID},mypath]
		if ${debug}
		{
			echo Found Path to ${destination} with ${mypath.Hops} hops from ${LNavRegion[${CPname}].Name}
		}

		if ${mypath.Hops}>0
		{
			do
			{
				; Move to next Waypoint
				WPX:Set[${mypath.Region[${bpathindex}].CenterPoint.X}]
				WPY:Set[${mypath.Region[${bpathindex}].CenterPoint.Y}]
				call FastMove ${WPX} ${WPY} 100
				if ${debug}
				{
					echo ${Return}
				}
				if ${Return.Equal["STUCK"]}
				{
					CurrentConnection:SetConnection[${mypath.Connection[${bpathindex}]}]
					if ${debug}
					{
						echo Removing Connection ${mypath.Connection[${bpathindex}]}
					}
					CurrentConnection:Remove
					call FastMove ${mypath.Region[${Math.Calc[${bpathindex}-2]}].CenterPoint.X} ${mypath.Region[${Math.Calc[${bpathindex}-2]}].CenterPoint.Y} 100
					if ${debug}
					{
						echo ${Return}
					}
					mypath:Clear
					CurrentConnection:Clear
					;PathFinder:SelectPath[${mypath.Region[${Math.Calc[${bpathindex}-1]]}.ID},${LNavRegion[${navi.CurrentRegion}].FindRegion[${destination}].ID},mypath]
					call This.FindClosestPoint ${Me.X} ${Me.Y} ${Me.Z}
					CPname:Set[${Return}]
					PathFinder:SelectPath[${LNavRegion[${CPname}].ID},${LNavRegion[${This.CurrentRegion}].FindRegion[${destination}].ID},mypath]
					if ${debug}
					{
						echo ${mypath.Hops}
					}
					if ${mypath.Hops} > 0
					{
						if ${debug}
						{
							echo Found new to ${destination} with ${mypath.Hops} hops.
						}
						bpathindex:Set[1]
					}
					else
					{
						VG:ExecBinding[moveforward,release]
						CurrentRegion:Set[${This.CurrentRegion}]
						LastRegion:Set[${This.CurrentRegion}]
						return "Stuck and I can't find another way there."
					}
				}
			}
			while ${bpathindex:Inc}<=${mypath.Hops}
			VG:ExecBinding[moveforward,release]
			CurrentRegion:Set[${This.CurrentRegion}]
			LastRegion:Set[${This.CurrentRegion}]
			return "End of path"
		}
		else
		{
			return "No path found!"
		}
	}

	function FastMove(float X, float Y, int range, string Region)
	{
		variable float xDist
		variable float SavDist=${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}
		variable int xTimer
		variable int FullTimer
		;if ${debug}
		;{
			echo Move Fast ${X} ${Y}
		;}
		face ${X} ${Y}

		VG:ExecBinding[moveforward]

		xTimer:Set[${Time.Timestamp}]
		FullTimer:Set[${Time.Timestamp}]
		do
		{
			xDist:Set[${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}]

			if ${Math.Calc[${SavDist}-${xDist}]}<60
			{
				if ${Math.Calc[${Time.Timestamp}-${xTimer}]}>1
				{
					VG:ExecBinding[moveforward,release]
					return "STUCK"
				}
			}
			else
			{
				xTimer:Set[${Time.Timestamp}]
				SavDist:Set[${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}]
			}

			if ${This.CurrentRegion.Equal[${Region}]}
			{
				return "SUCCESS"
			}

			face ${X} ${Y}

		}
		while (${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${range}) && (${Math.Calc[${Time.Timestamp}-${FullTimer}]} < 3)
		
		if (${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}<${range})
		{
			return "SUCCESS"
		}
		else
		{
			echo ${Math.Calc[${Time.Timestamp}-${FullTimer}]} ${Time.Timestamp} - ${FullTimer}
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
;			tmp:Set[${LNavRegion[${This.CurrentRegion}].AddChild[point,"auto",-unique,${Me.X},${Me.Y},${Me.Z}]}]
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
			variable string Region=${This.CurrentRegion}
			if !${LNavRegion[${Region}].Type.Equal[Universe]}
			{
				LNavRegion[${Region}]:SetCustom["level", ${This.getlvl}]
				LNavRegionGroup["hunt"]:Add[${Region}]
			}
			
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
			if ${debug}
			{
				echo Not all valid! ${LNavRegion[${Region}].Name}
			}
		}
	}
}
