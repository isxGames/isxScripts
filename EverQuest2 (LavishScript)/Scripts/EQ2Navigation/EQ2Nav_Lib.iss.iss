;;;;;;;;;;;;;;;;;;;;;;;;
;;; A Significant portion of the scripting used in this file was taken from OpenBot (for World of Warcraft and ISXWOW).
;;; That source is available at http://www.ob-dev.com/svn/openbot/ in its original form and, except where noted, is
;;; licensed under a Attribution-Noncommercial-No Derivative Works 3.0 United States License 
;;; (http://creativecommons.org/licenses/by-nc-nd/3.0/us/)
;;;;;;;;;;;;;;;;;;;;;;;;
;; Additional References:
;;    http://www.lavishsoft.com/wiki/index.php/LavishNav:Object_Types
;;



objectdef EQ2NavPath
{
	variable point3f Location
	variable int Method

	method Initialize(float X, float Y, float Z, int MoveType)
	{
		This.Location:Set[${X},${Y},${Z}]
		This.Method:Set[${MoveType}]
	}
}

objectdef EQ2Nav
{
    ;;; These need to be added to a UI option or xml options file
    variable string AUTORUN = "num lock"
    variable string MOVEFORWARD = "w"
    variable string MOVEBACKWARD = "s"
    variable string STRAFELEFT = "q"
    variable string STRAFERIGHT = "e"
    variable string TURNLEFT = "a"
    variable string TURNRIGHT = "d"
    
    variable EQ2Mapper Mapper
	variable index:EQ2NavPath NavPath
	variable point3f NavDestination
	variable int StuckTime = ${LavishScript.RunningTime}
	variable int PRECISION = 4
	variable int TotalStuck = 0
	variable int SKIPNAV = 0
	variable string vCurrentDestination = ""
	variable int degrees
	variable point3f BestPoint
	variable float BestPointDistance

	variable int NAV_Wait_Until = 0
	variable int NAV_Wait_Until_Timeout = 10

	variable float NextHopOldDistance
	variable float NextHopDistance
	variable int NextHopOldTime=${LavishScript.RunningTime}
	variable float NextHopSpeed

	variable string MeLastLocation=${Me.ToActor.Loc}
	variable bool MeMoving=FALSE
	
	variable int BackupTime
    variable int StrafeTime

	member CurrentDestination = ${vCurrentDestination}

	method Initialize()
	{
		This.NavDestination:Set[0,0,0]
		degrees:Set[15]
	}

	method Shutdown()
	{
	}

	method Output(string Text)
	{
	    echo "EQ2Nav:: ${Text}"
	}
	
	method Debug(string Text)
	{
	    echo "EQ2Nav-Debug:: ${Text}"
	}	

	method SetPRECISION(int NUM)
	{
		This:Output["Setting navigation precision to ${NUM}."]
		PRECISION:Set[${NUM}]
	}

	member GetPRECISION()
	{
		return ${This.PRECISION}
	}
	method ClearPath()
	{
		This.NavDestination:Set[0,0,0]
		NavPath:Clear
		NavPath:Collapse
		This.POIStr:Set[""]
	}

	member AvailablePath(float X,float Y,float Z)
	{
		variable dijkstrapathfinder PathFinder
		variable lnavpath Path
		variable int Index = 2
		variable lnavregionref CurrentRegion
		variable lnavregionref ZoneRegion
		variable lnavregionref DestZoneRegion
		variable lnavregionref DestinationRegion
		variable index:lnavregionref SurroundingRegions

		if ${X}==0 && ${Y}==0 && ${Z}==0
		{
			return FALSE
		}

		if ${Math.Distance[${Me.ToActor.Loc},${X},${Y},${Z}]} < 40
		{
			if !${Mapper.Topography.IsSteep[${Me.ToActor.Loc},${X},${Y},${Z}]}
			{
				return TRUE
			}
		}
		Path:Clear
		ZoneRegion:SetRegion[${LNavRegion[${Mapper.ZoneText}].FQN}]
		DestZoneRegion:SetRegion[${LavishNav.FindRegion[${Mapper.ZoneText}].FQN}]
		CurrentRegion:SetRegion[${ZoneRegion.BestContainer[${Me.ToActor.Loc}].ID}]
		DestinationRegion:SetRegion[${DestZoneRegion.BestContainer[${X},${Math.Calc[${Y}+1]},${Z}].ID}]
		PathFinder:SelectPath[${CurrentRegion.FQN},${DestinationRegion.FQN},Path]
		if ${Path.Hops}
		{
			return TRUE
		}
		else
		{
			return FALSE
		}
	}

	member PointsConnect(float toX, float toY, float toZ, float fromX, float fromY, float fromZ)
	{
		variable dijkstrapathfinder PathFinder
		variable lnavpath Path
		variable lnavregionref ToRegion
		variable lnavregionref ZoneRegion
		variable lnavregionref DestZoneRegion
		variable lnavregionref DestinationRegion

		if (${toX}==0 && ${toY}==0 && ${toZ}==0) || (${fromX}==0 && ${fromY}==0 && ${fromZ}==0)
		{
			return FALSE
		}

		Path:Clear
		ZoneRegion:SetRegion[${LavishNav.FindRegion[${Mapper.ZoneText}].FQN}]
		DestZoneRegion:SetRegion[${LavishNav.FindRegion[${Mapper.ZoneText}].FQN}]
		ToRegion:SetRegion[${DestZoneRegion.BestContainer[${toX},${Math.Calc[${toY}+1]},${toZ}].ID}]
		DestinationRegion:SetRegion[${DestZoneRegion.BestContainer[${fromX},${Math.Calc[${fromY}+1]},${fromZ}].ID}]
		PathFinder:SelectPath[${ToRegion.FQN},${DestinationRegion.FQN},Path]
		if ${Path.Hops}
		{
			return TRUE
		}
		else
		{
			return FALSE
		}
	}
	
	method CheckAggro()
	{
	    ;; To Do   
	    
	    
	}
	
	method StartRunning()
	{
	    
	    
	}
	
	method StopRunning()
	{
	    
	    
	}

	method MoveTo(float X,float Z, float Precision, int keepmoving, int Attempts, int StopOnAggro)
	{
	    ;;; This moves you directly to a point, without using lavishnav at all
	    
    	variable float SavX=${Me.X}
    	variable float SavZ=${Me.Z}
    	variable int obstaclecount=0
    	variable int failedattempts=0
    	variable int checklag
    	variable int maxattempts=${If[${Attempts},${Attempts},3]}
    
    	This:CheckAggro
    
    	; Set the number of iterations before it determines its stuck
    	checklag:Set[4]
    
    	; How far do you want to move back for, if your stuck? (10 = 1 second)
    	This.BackupTime:Set[5]
    
    	; How far do you want to strafe for, after backing up? (10 = 1 second)
    	This.StrafeTime:Set[5]
    
    	if !${Attempts}
    		maxattempts:Set[3]
    	else
    		maxattempts:Set[${Attempts}]
    
    	; Check Weight in case we are moving to slow
    	if ${Math.Calc[${Me.Weight}/${Me.MaxWeight}*100]}>150
    	{
    		checklag:Set[10]
    		This.BackupTime:Set[2]
    		This.StrafeTime:Set[2]
    		Precision:Set[2]
    	}
    
    	; Check that we are not already there!
    	if ${Math.Distance[${Me.X},${Me.Z},${X},${Z}]} > ${Precision}
    	{
    	    This:CheckAggro
    		;Make sure we're moving
    		This:StartRunning
    		Do
    		{
    			This:CheckAggro
    			face ${X} ${Z}
    			wait 4
    
    			if ${Math.Distance[${Me.X},${Me.Z},${SavX},${SavZ}]}<2
    			{
    				obstaclecount:Inc
    
    				; This might be caused by lag or not updating our co-ordinates
    				if ${obstaclecount}==${checklag}
    					wait 1
    
    				; We are probably stuck
    				if ${obstaclecount}>${Math.Calc64[${checklag}+1]}
    				{
    					obstaclecount:Set[0]
    					This:HandleObstacle[${failedattempts}]
    					if (${failedattempts} == ${maxattempts})
    					{
    					    This:CheckAggro
    						; Main script will handle this situation
    						if ${keepmoving}
    							This:StartRunning
    						else
    							This:StopRunning
    						return "STUCK"
    					}
    					failedattempts:Inc
    				}
    			}
    			else
    				obstaclecount:Set[0] 
    
    			; Store our current location for future checking
    			SavX:Set[${Me.X}]
    			SavZ:Set[${Me.Z}]
    		}
    		while ${Math.Distance[${Me.X},${Me.Z},${X},${Z}]} > ${Precision}
    	}
    
    	; Made it to our target loc
    	if ${keepmoving}
    		This:StartRunning
    	else
    		This:StopRunning
    
    	return "SUCCESS"
	}

	method MoveToLocQ(float X, float Y, float Z,string DestName = "")
	{
		This.vCurrentDestination:Set[${DestName}]
		This:MoveToLoc[${X},${Y},${Z}]
	}


	/* useful for preventing excess MoveToLoc calls */
	member MovingToPoint(float X, float Y, float Z)
	{
		variable int count = 0
		if ${This.Moving}
		{
			if ${This.OpenNavPath.Get[1](exists)}
			{
				if ${This.OpenNavPath.Get[${OpenNavPath.Used}].Location.X}==${X} && ${This.OpenNavPath.Get[${OpenNavPath.Used}].Location.Y}==${Y} && ${This.OpenNavPath.Get[${OpenNavPath.Used}].Location.Z}==${Z}
				{
					return TRUE
				}
			}
		}
		return FALSE
	}

	method MoveToLoc(float X, float Y, float Z, int OVERRIDE=0)
	{
		variable dijkstrapathfinder PathFinder
		variable lnavpath Path
		variable int count = 0
		variable int Index = 2
		variable lnavregionref CurrentRegion
		variable lnavregionref ZoneRegion
		variable lnavregionref DestZoneRegion
		variable lnavregionref DestinationRegion
		variable index:lnavregionref SurroundingRegions

		if ${X}==0 && ${Y}==0 && ${Z}==0
		{
			; No reason to run to NOTHING
			return
		}

		; If we are already PRECISION from it why bother moving?
		; Changed... Default PRECISION is slightly greater then USE distance
		if ${Math.Distance[${Me.ToActor.Loc},${X},${Y},${Z}]}<${This.GetPRECISION} && ${POI.Type.Equal[HOTSPOT]}
		{
			This:Output["Already here, not moving."]
			This:ClearPath
			This:MoveStop
			return
		}
		; Added. Check for POIs that we are probably wanting to use
		; This is to help eliminate issues between client, server information disconnects. such as using an NPC
		if ${Math.Distance[${Me.ToActor.Loc},${X},${Y},${Z}]}< 2
		{
			This:Output["Already here, not moving"]
			This:ClearPath
			This:MoveStop
			return
		}

		;If we already have a Path make sure it is a new one
		if ${This.OpenNavPath.Get[1](exists)}
		{
			if ${This.OpenNavPath.Get[${OpenNavPath.Used}].Location.X}==${X} && ${This.OpenNavPath.Get[${OpenNavPath.Used}].Location.Y}==${Y} && ${This.OpenNavPath.Get[${OpenNavPath.Used}].Location.Z}==${Z}
			{
				This:Output["Error: Calling again to same destination. Aborting!"]
				return
			}
		}

		This:ClearPath

		This:Debug["Clearing #3."]
		This.StuckTime:Set[${LavishScript.RunningTime}]

		if ${OVERRIDE}!=0
		{
			This:Output["Nav Overrriding: Using path!"]
		}

		if ${Math.Distance[${Me.ToActor.Loc},${X},${Y},${Z}]} < 40 && ${OVERIDE}==0 && !${Mapper.Topography.IsSteep[${Me.ToActor.Loc},${X},${Y},${Z}]}
		{
			This:Debug["Moving to ${X},${Y},${Z} directly."]
			This.OpenNavPath:Insert[${X},${Y},${Z},0]
			This.NavDestination:Set[${X},${Y},${Z}]
		}
		else
		{
			Path:Clear
			ZoneRegion:SetRegion[${LNavRegion[${Mapper.ZoneText}].FQN}]
			DestZoneRegion:SetRegion[${LavishNav.FindRegion[${Mapper.ZoneText}].FQN}]
			CurrentRegion:SetRegion[${ZoneRegion.BestContainer[${Me.ToActor.Loc}].ID}]
			DestinationRegion:SetRegion[${DestZoneRegion.BestContainer[${X},${Math.Calc[${Y}+1]},${Z}].ID}]
			PathFinder:SelectPath[${CurrentRegion.FQN},${DestinationRegion.FQN},Path]

			if ${Path.Hops}
			{
				do
				{
					This.OpenNavPath:Insert[${Path.Region[${Index}].CenterPoint},0]
				}
				while ${Index:Inc} <= ${Path.Hops}

				This.NavDestination:Set[${X},${Y},${Z}]
			}
			else
			{
				; We didnt get a path run to the next closest point and try from there
				This:Output["Error: Can't find connection. Not enough mapping data! ${X},${Y},${Z}"]
				This:Debug["From: ${CurrentRegion.FQN} to ${DestinationRegion.FQN}."]
			}
		}
	}
	
	method HandleObstacle(int delay)
	{   
    	variable float newheading
    
    	This:CheckAggro
    
    	if ${delay}>0
    	{
    		;backup a little
            press -release ${This.MOVEFORWARD}		
            wait 1
    		press -hold ${This.MOVEBACKWARD}		
    		wait ${Math.Calc64[${This.BackupTime}*${delay}]}
            press -release ${This.MOVEBACKWARD}
    
    		if ${delay}==1 || ${delay}==3 || ${delay}==5
    		{
    			;randomly pick a direction
    			if "${Math.Rand[10]}>5"
    			{
    			    This:CheckAggro
                    press -hold ${This.STRAFELEFT}			    
    				This:StartRunning
    				wait ${Math.Calc64[${This.StrafeTime}*${delay}]}
                    press -release ${This.STRAFELEFT}	
    				This:StopRunning
    				wait 2
    			}
    			else
    			{
    			    This:CheckAggro
                    press -hold ${This.STRAFERIGHT}	
    				This:StartRunning
    				wait ${Math.Calc64[${This.StrafeTime}*${delay}]}
                    press -release ${This.STRAFERIGHT}	
    				This:StopRunning
    				wait 2
    			}
    		}
    		else
    		{
    			;randomly pick a direction
    			if (${Math.Rand[10]}>5)
    			{
    			    This:CheckAggro
                    press -hold ${This.STRAFELEFT}	
    				wait ${Math.Calc64[${This.StrafeTime}*${delay}]}
                    press -release ${This.STRAFELEFT}	
    				wait 2
    			}
    			else
    			{
    			    This:CheckAggro
                    press -hold ${This.STRAFERIGHT}	
    				wait ${Math.Calc64[${This.StrafeTime}*${delay}]}
                    press -release ${This.STRAFERIGHT}	
    				wait 2
    			}
    		}
    		;Start moving forward again
    		This:StartRunning
    		wait ${Math.Calc64[${This.BackupTime}*${delay}+5]}
    	}
    	else
    	{
    	    This:CheckAggro
    		if ${Math.Rand[10]}>5
    			newheading:Set[${Math.Calc[${Me.Heading}+90]}]
    		else
    			newheading:Set[${Math.Calc[${Me.Heading}-90]}]
    		if ${newheading}>360
    			newheading:Dec[360]
    		if ${newheading}<1
    			newheading:Inc[360]
    
    		face ${newheading}
    		wait ${Math.Calc64[${This.StrafeTime}*${delay}]}
    	}
    }    

	method Pulse()
	{
		;Only do every nth frame (CPU Saver)
		if ${SKIPNAV} < 1
		{
			SKIPNAV:Inc
			return
		}
		SKIPNAV:Set[0]
		
		if ${This.MeLastLocation.Equal[${Me.ToActor.Loc}]}
		{
			This.MeMoving:Set[FALSE]
		}
		else
		{
			This.MeMoving:Set[TRUE]
		}
		This.MeLastLocation:Set[${Me.Location}]
		
		if ${OpenNavPath.Get[1](exists)}
		{
			This.NextHopDistance:Set[${Math.Distance[${Me.ToActor.Loc},${This.OpenNavPath.Get[1].Location}]}]

			if ${This.NextHopDistance} < ${This.GetPRECISION}
			{
				OpenNavPath:Remove[1]
				OpenNavPath:Collapse

				if !${OpenNavPath.Get[1](exists)}
				{
					if ${This.Moving}
						This:MoveStop
					return
				}

				;If we have 2 hops and next hop is < 10 and we can get to the 2nd hop just go there
				if ${This.OpenNavPath.Get[2](exists)} && ${Math.Distance[${Me.ToActor.Loc},${This.OpenNavPath.Get[1].Location}]} < 20
				{
					if !${Me.IsPathObstructed[${This.OpenNavPath.Get[2].Location}]}
					{
						OpenNavPath:Remove[1]
						OpenNavPath:Collapse
					}
				}
				This.NextHopDistance:Set[${Math.Distance[${Me.ToActor.Loc},${This.OpenNavPath.Get[1].Location}]}]
			}
			else
			{
				This.NextHopSpeed:Set[(${This.NextHopOldDistance}-${This.NextHopDistance})/(${LavishScript.RunningTime}-${This.NextHopOldTime}]
			}

			This.NextHopOldTime:Set[${LavishScript.RunningTime}]
			This.NextHopOldDistance:Set[${This.NextHopDistance}]

			if ${This.Moving} && ${This.NextHopSpeed} > 0.001
			{
				This.StuckTime:Set[${LavishScript.RunningTime}]
			}
			else
			{
				if ${LavishScript.RunningTime}-${This.StuckTime}>1000
				{
					This:HandleObstacle
					This.StuckTime:Set[${LavishScript.RunningTime}]
				}
			}

			This.TotalStuck:Set[0]
			This:MoveToLoc[${This.OpenNavPath.Get[1].Location}]
			Bot:Update_Status["Running"]
		}
	}


	;----------
	;----- Movement Functions
	;----------

	method FaceXYZ(float X, float Y, float Z)
	{
		if ${X}==0 && ${Y}==0 && ${Z}==0
		{
			; No reason to face NOTHING
			This:Debug["Error in FaceXYZ: Call to 0,0,0."]
			return
		}
		face ${X} ${Y} ${Z}
	}

	/* replacement to DegreesCCW */
	member Flip(float theHeading)
	{
		theHeading:Dec[180]
		if ${theHeading} < 0
		{
			theHeading:Inc[360]
		}
		return ${theHeading}
	}

	method FaceHeading(float hd)
	{
		if ${Math.Abs[${Me.Heading}-${hd}]} > 10
		{
			This:Debug["FaceHeading: Facing ${hd}."]
			face ${hd}
		}
	}

	method MoveStop()
	{
        if ${Me.IsMoving} || ${This.Moving}
        {
        	do
        	{
        	    press ${This.AUTORUN}
        		wait 5
        	}
        	while ${Me.IsMoving}
        }
	}

	member Moving()
	{
	    if ${Me.IsMoving}
	        return TRUE
	        
		return ${This.MeMoving}
	}
}