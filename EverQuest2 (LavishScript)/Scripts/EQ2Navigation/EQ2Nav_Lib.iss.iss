;;;;;;;;;;;;;;;;;;;;;;;;
;;; A Significant portion of the scripting used in this file was taken from OpenBot (for World of Warcraft and ISXWOW).
;;; That source is available at http://www.ob-dev.com/svn/openbot/ in its original form and, except where noted, is
;;; licensed under a Attribution-Noncommercial-No Derivative Works 3.0 United States License 
;;; (http://creativecommons.org/licenses/by-nc-nd/3.0/us/)
;;;;;;;;;;;;;;;;;;;;;;;;
;; Additional References:
;;    http://www.lavishsoft.com/wiki/index.php/LavishNav:Object_Types
;;

#include ${LavishScript.HomeDirectory}/Scripts/EQ2Navigation/EQ2NavMapper_Lib.iss

objectdef EQ2NavPath
{
	variable point3f Location
	variable int Method
	variable string FQN

	method Initialize(float X, float Y, float Z, int MoveType, string Label )
	{
		This.Location:Set[${X},${Y},${Z}]
		This.Method:Set[${MoveType}]
		This.FQN:Set[${Label}]
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
    
    ;; Export to user definable (3.5 seems a good value)
    variable float PRECISION = 2
    variable float DestinationPrecision = 4
    
    variable EQ2Mapper Mapper
	variable index:EQ2NavPath NavigationPath
	variable point3f NavDestination
	variable int StuckTime = ${LavishScript.RunningTime}
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
	variable float DestinationDistance

	variable string MeLastLocation=${Me.ToActor.Loc}
	variable bool MeMoving=FALSE
	
	variable int BackupTime
    variable int StrafeTime

    variable bool MovingTo = FALSE
    variable int MovingTo_Timer
    variable float MovingTo_X
    variable float MovingTo_Y
    variable float MovingTo_Z
    variable float MovingTo_Precision
    variable float MovingTo_keepmoving
    variable float MovingTo_Attempts
    variable float MovingTo_StopOnAggro

	member CurrentDestination = ${vCurrentDestination}

	method Initialize()
	{
		This.NavDestination:Set[0,0,0]
		degrees:Set[15]
		Mapper:Initialize
        Mapper:LoadMapper	
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
		NavigationPath:Clear
		NavigationPath:Collapse
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
	    ;This:Debug["StartRunning() Called"]
    	if !${Me.IsMoving}
    		press "${This.AUTORUN}"
	}
	
	method StopRunning()
	{
	    ;This:Debug["StopRunning() Called"]
        if ${Me.IsMoving}
            press "${This.AUTORUN}"  
	}
	
	method MoveTo(float X, float Y, float Z, float fPrecision, int keepmoving, int Attempts, int StopOnAggro)
	{
	    ;;; This moves you directly to a point, without using lavishnav at all ... MoveToLoc() will be much better if you have a path file for the zone...
    	variable int obstaclecount=0
    	variable int failedattempts=0
    	variable int checklag
    	variable int maxattempts=${If[${Attempts},${Attempts},3]}
    	
    	
    	;;;; Keep track of things for the Pulse()
    	;;
    	This.MovingTo_X:Set[${X}]
    	This.MovingTo_Y:Set[${Y}]
    	This.MovingTo_Z:Set[${Z}]
    	This.MovingTo_Precision:Set[${fPrecision}]
    	This.MovingTo_keepmoving:Set[${keepmoving}]
    	This.MovingTo_Attempts:Set[${Attempts}]
    	This.MovingTo_StopOnAggro:Set[${StopOnAggro}]
        ;;
        ;;;;
        
    	This:CheckAggro
    	
    	;; If we're moving to a specific point, or if this is the final destination -- then accept a much higher precision value
    	if !${NavigationPath.Get[1](exists)} || ${NavigationPath.Used} == 0
    	{
    	    if (${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]} < ${DestinationPrecision})   
    	    {         
        	    ;This:Debug["Me.CheckCollision[${X},${Y},${Z}] = ${Me.CheckCollision[${X},${Y},${Z}]}"]
        	    if (!${Me.CheckCollision[${X},${Y},${Z}]})
        	    {
            	    This:Debug["MoveTo()-] Within ${DestinationPrecision}m of final destination -- ending movement."]
        		    if ${keepmoving}
                		This:StartRunning
                	else
                		This:StopRunning
            	    This.MovingTo:Set[FALSE]
            	    This.MovingTo:Set[FALSE]
            	    This.MovingTo_Timer:Set[0]
            	    face ${X} ${Y} ${Z}
            	    if ${NavigationPath.Get[1](exists)} || ${NavigationPath.Used} > 0
            	    {
            	        NavigationPath:Clear
            	    }
            	    This.MeMoving:Set[FALSE]
            	    return
            	}	    
    	    }
    	}
    	
        ;This:Debug["MoveTo()-] Math.Distance[${Me.X},${Me.Z},${X},${Z}]: ${Math.Distance[${Me.X},${Me.Z},${X},${Z}]} (Precision: ${fPrecision})"]
    	if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]} > ${fPrecision} || ${Mapper.IsSteep[${X},${Y},${Z},${Me.ToActor.Loc}]} || ${Me.CheckCollision[${X},${Y},${Z}]}
    	{
    	    This:CheckAggro
    		face ${X} ${Z}
    		This:StartRunning
    		
    		This.MovingTo:Set[TRUE]   		
	    }
    	else
    	{
    	    ;This:Debug["Me.CheckCollision[${X},${Y},${Z}] = ${Me.CheckCollision[${X},${Y},${Z}]}"]
    	    if (!${Me.CheckCollision[${X},${Y},${Z}]})
    	    {
        	    This:Debug["MoveTo()-] Within ${fPrecision.Precision[1]}m of destination -- ending movement."]
    		    if ${keepmoving}
            		This:StartRunning
            	else
            		This:StopRunning
        	    This.MovingTo:Set[FALSE]
        	    This.MovingTo_Timer:Set[0]
        	    This.MeMoving:Set[FALSE]
        	    face ${X} ${Y} ${Z}
        	    if ${NavigationPath.Get[1](exists)} || ${NavigationPath.Used} > 0
        	    {
        	        NavigationPath:Clear
        	    }
        	}
    	}
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
			if ${This.NavigationPath.Get[1](exists)}
			{
				if ${This.NavDestination.X}==${X} && ${This.NavDestination.Y}==${Y} && ${This.NavDestination.Z}==${Z}
				{
					return TRUE
				}
			}
		}
		return FALSE
	}
	
	method MoveToRegion(string RegionName)
	{
		variable lnavregionref ZoneRegion
		variable lnavregionref DestZoneRegion
		variable lnavregionref DestinationRegion	    
	    
		ZoneRegion:SetRegion[${LNavRegion[${Mapper.ZoneText}].FQN}]
		DestZoneRegion:SetRegion[${LavishNav.FindRegion[${Mapper.ZoneText}].FQN}]
		DestinationRegion:SetRegion[${RegionName}]
		This:Debug["MoveToRegion:: Moving to ${DestinationRegion.FQN}"]
		This:MoveToLoc[${DestinationRegion.CenterPoint}]
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
		if ${Math.Distance[${Me.ToActor.Loc},${X},${Y},${Z}]}<${This.GetPRECISION}
		{
			This:Output["Already here, not moving."]
			This:ClearPath
			This:MoveStop
			This.MeMoving:Set[FALSE]
			This.MovingTo:Set[FALSE]
			return
		}
		
		;If we already have a Path make sure it is a new one
		if ${This.NavigationPath.Get[1](exists)}
		{
			if ${This.NavDestination.X}==${X} && ${This.NavDestination.Y}==${Y} && ${This.NavDestination.Z}==${Z}
			{
				This:Output["Error: Calling again to same destination. Aborting!"]
				This.MeMoving:Set[FALSE]
				This.MovingTo:Set[FALSE]
				return
			}
		}

		This:ClearPath

		This:Debug["Clearing #3."]
		This.StuckTime:Set[${LavishScript.RunningTime}]

		if ${OVERRIDE}!=0
			This:Output["Nav Overrriding: Using path!"]

		if (${Math.Distance[${Me.ToActor.Loc},${X},${Y},${Z}]} < 10 && ${OVERIDE}==0)
		{
		    if (!${Mapper.Topography.IsSteep[${Me.ToActor.Loc},${X},${Y},${Z}]})
		    {
    		    This:Debug["Moving to ${X},${Y},${Z} directly."]
    			;This.NavigationPath:Insert[${X},${Y},${Z},0]
    			;This.NavDestination:Set[${X},${Y},${Z}]
    			This:MoveTo[${X},${Y},${Z},${This.GetPRECISION}]
    			This.MeMoving:Set[TRUE]
    			return
    		}
		}
		else
		{
			Path:Clear
			ZoneRegion:SetRegion[${LNavRegion[${Mapper.ZoneText}].FQN}]
			DestZoneRegion:SetRegion[${LavishNav.FindRegion[${Mapper.ZoneText}].FQN}]
			CurrentRegion:SetRegion[${ZoneRegion.BestContainer[${Me.ToActor.Loc}].ID}]
			DestinationRegion:SetRegion[${DestZoneRegion.BestContainer[${X},${Math.Calc[${Y}+1]},${Z}].ID}]
			This:Debug["DestinationRegion: ${DestinationRegion}"]
			PathFinder:SelectPath[${CurrentRegion.FQN},${DestinationRegion.FQN},Path]

			if ${Path.Hops}
			{
				do
				{
				    This:Debug["Adding [${Path.Region[${Index}].CenterPoint}] - [${Path.Region[${Index}].FQN}] to NavigationPath"]
					This.NavigationPath:Insert[${Path.Region[${Index}].CenterPoint},0,${Path.Region[${Index}].FQN}]
				}
				while ${Index:Inc} <= ${Path.Hops}

				This.NavDestination:Set[${X},${Y},${Z}]
				This:Debug["Path found: ${NavigationPath.Used} hops."] 
				This.MeMoving:Set[TRUE]
			}
			else
			{
				; We didnt get a path run to the next closest point and try from there
				This:Output["Error: Can't find connection. Not enough mapping data! ${X},${Y},${Z}"]
				This:Debug["From: ${CurrentRegion.FQN} to ${DestinationRegion.FQN}."]
				This.MeMoving:Set[FALSE]
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
	    variable point3f Dest
		
		;Only do every 2 frames (CPU Saver)
		if ${SKIPNAV} < 50
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
		This.MeLastLocation:Set[${Me.ToActor.Loc}]
		
		;;;;;;;;;;;;;;;;;;;;;;
		;; Deal with MoveTo()
		if ${This.MovingTo}
		{
		    if ${LavishScript.RunningTime}-${This.MovingTo_Timer}>1000
		    {
		        ;; Only pertinant if there is no current NavigationPath
		        if !${NavigationPath.Get[1](exists)} || ${NavigationPath.Used} == 0
		        {
		            ;This:Debug["Calling MoveTo(${This.MovingTo_X},${This.MovingTo_Z},${This.MovingTo_Precision},${This.MovingTo_keepmoving},${This.MovingTo_Attempts},${This.MovingTo_StopOnAggro})"]
    		        This:MoveTo[${This.MovingTo_X},${This.MovingTo_Y},${This.MovingTo_Z},${This.MovingTo_Precision},${This.MovingTo_keepmoving},${This.MovingTo_Attempts},${This.MovingTo_StopOnAggro}]
    		        This.MovingTo_Timer:Set[${LavishScript.RunningTime}]
    		        This.MeMoving:Set[TRUE]
    		    }
		    }
		}
		;;
		;;;;;;;;;;;;;;;;;;;;;;

		
		if ${NavigationPath.Get[1](exists)}
		{
		    ;This:Debug["DESTINATION: ${This.NavigationPath.Get[${NavigationPath.Used}].FQN}"]
		    ;This:Debug["NavigationPath[1] exists (${This.NavigationPath.Get[1].FQN})..."]
			This.NextHopDistance:Set[${Math.Distance[${Me.ToActor.Loc},${This.NavigationPath.Get[1].Location}]}]
			This.DestinationDistance:Set[${Math.Distance[${Me.ToActor.Loc},${This.NavDestination}]}]
            This:Debug["Distance to ${This.NavigationPath.Get[1].FQN}: ${This.NextHopDistance} (Distance to Destination: ${This.DestinationDistance})"]
            
            
            if (${This.DestinationDistance} <= ${This.GetPRECISION})
            {
                if (!${Me.CheckCollision[${This.NavDestination}]})
                {
                    This:Debug["Within ${This.GetPRECISION} meters of destination -- ending movement."]
    				if ${This.Moving} || ${This.MovingTo}
    					This:MoveStop	   
    				This.MovingTo:Set[FALSE]
    				This.MeMoving:Set[FALSE]
    				face ${This.NavDestination.X} ${This.NavDestination.Y} ${This.NavDestination.Z}
    				NavigationPath:Clear
    				return      
    			}    
            }
            
            ;; TODO -- make this value an option
            if (${This.DestinationDistance} <= 15 && !${Me.CheckCollision[${This.NavDestination}]})
            {
                This:Debug["Within 15m of the destination and no obstructions found -- moving directly (outside of navigation system)"]
                face ${This.NavDestination.X} ${This.NavDestination.Y} ${This.NavDestination.Z}
                Dest:Set[${This.NavDestination}]
                NavigationPath:Clear
                ;This:Debug["Calling MoveTo(${Dest}) -- Distance: ${This.DestinationDistance}"]
				This:MoveTo[${Dest},${This.GetPRECISION}]         
				This.MeMoving:Set[TRUE]
				return
            }  
                              
            
            ;; TODO -- make this value an option`
            if ${This.NextHopDistance} > 20
            {
                This:Debug["Bypassed next Hop in path -- resetting path"]
                Dest:Set[${This.NavDestination}]
                NavigationPath:Clear
                This:MoveToLoc[${Dest}]
                This.MeMoving:Set[TRUE]
                return           
            }
            
			if ${This.NextHopDistance} <= ${This.GetPRECISION}
			{
			    if (${Me.CheckCollision[${This.NavigationPath.Get[1].Location}]})
			    {
			        This:Debug["The next hop is within ${This.GetPRECISION}m; however, there is an obstruction to the next hop."]
			        return   
			    }
			    
			    
			    ;This:Debug["The next hop is within ${This.GetPRECISION}m -- removing ${This.NavigationPath.Get[1].FQN} from path."]
				NavigationPath:Remove[1]
				NavigationPath:Collapse
				

				if (!${NavigationPath.Get[1](exists)} || ${NavigationPath.Used} <= 0)
				{
				    if (!${Me.CheckCollision[${This.NavDestination}]})
				    {
    				    This:Debug["NavigationPath now empty -- ending movement."]
                        if ${This.Moving} || ${This.MovingTo}
        					This:MoveStop	
        			    This.MeMoving:Set[FALSE]   
        				This.MovingTo:Set[FALSE]
        				return     
        			}
				}
				
				This:Debug["NavigationPath[1] is now ${This.NavigationPath.Get[1].FQN}"
				This.NextHopDistance:Set[${Math.Distance[${Me.ToActor.Loc},${This.NavigationPath.Get[1].Location}]}]
				
				if (${This.NextHopDistance} < ${This.GetPRECISION})
				{
				    This.DestinationDistance:Set[${Math.Distance[${Me.ToActor.Loc},${This.NavDestination}]}]
				    if (${This.DestinationDistance} < ${This.GetPRECISION})
				    {
                        This:Debug["Within ${This.GetPRECISION} meters of destination -- ending movement."]
                        face ${This.NavDestination.X} ${This.NavDestination.Y} ${This.NavDestination.Z}
                        NavigationPath:Clear
        				if ${This.Moving} || ${This.MovingTo}
        					This:MoveStop	   
        				This.MovingTo:Set[FALSE]
        				This.MeMoving:Set[FALSE]
        				return     
				    }
				    else
				    {
    				    This:Debug["Next hop was within precision range as well - resetting path."]
    				    Dest:Set[${This.NavDestination}]
                        NavigationPath:Clear
                        This:MoveToLoc[${Dest}]
                        This.MeMoving:Set[TRUE]
                        return      
                    }
                }
                else
                {
    				;This:Debug["Calling MoveTo(${This.NavigationPath.Get[1].FQN}) -- Distance: ${This.NextHopDistance}"]
    				This:MoveTo[${This.NavigationPath.Get[1].Location},${This.GetPRECISION}]
    				This.MeMoving:Set[TRUE]
			    }
			}
			else
			{
			    ;This:Debug["${This.NavigationPath.Get[1].FQN} still out of precision range."]
			    if !${Me.IsMoving} || !${This.MovingTo}
			    {
			        This:Debug["NavigationPath exists, but not moving -- issuing movement"]
			        This.NextHopSpeed:Set[(${This.NextHopOldDistance}-${This.NextHopDistance})/(${LavishScript.RunningTime}-${This.NextHopOldTime}]
				    This.NextHopDistance:Set[${Math.Distance[${Me.ToActor.Loc},${This.NavigationPath.Get[1].Location}]}]
				    This:Debug["Calling MoveTo(${This.NavigationPath.Get[1].FQN}) -- Distance: ${This.NextHopDistance}"]
				    This:MoveTo[${This.NavigationPath.Get[1].Location},${This.GetPRECISION}]
				    This.MeMoving:Set[TRUE]
    	        }
    	        else
    	        {
			        This.NextHopSpeed:Set[(${This.NextHopOldDistance}-${This.NextHopDistance})/(${LavishScript.RunningTime}-${This.NextHopOldTime}]
				    This.NextHopDistance:Set[${Math.Distance[${Me.ToActor.Loc},${This.NavigationPath.Get[1].Location}]}]
				    ;This:Debug["Calling MoveTo(${This.NavigationPath.Get[1].FQN}) -- Distance: ${This.NextHopDistance}"]
				    This:MoveTo[${This.NavigationPath.Get[1].Location},${This.GetPRECISION}]        
				    This.MeMoving:Set[TRUE]
    	        }
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
					;This:HandleObstacle
					This.StuckTime:Set[${LavishScript.RunningTime}]
				}
			}

			This.TotalStuck:Set[0]
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
            press "${This.AUTORUN}"
	}

	member Moving()
	{
	    return ${This.MeMoving}
	}
}