;;;;;;;;;;;;;;;;;;;;;;;;
;;; A Significant portion of the scripting used in this file was taken from OpenBot (for World of Warcraft and ISXWOW).
;;; That source is available at http://www.ob-dev.com/svn/openbot/ in its original form and, except where noted, is
;;; licensed under a Attribution-Noncommercial-No Derivative Works 3.0 United States License 
;;; (http://creativecommons.org/licenses/by-nc-nd/3.0/us/)
;;;;;;;;;;;;;;;;;;;;;;;;


objectdef EQ2Mapper
{
    ;; Move these to settings/UI so users can adjust
    variable bool UseLSO = FALSE
    
    variable filepath ZonesDir = "${LavishScript.HomeDirectory}/Scripts/EQ2Navigation/zones/"
	variable filepath ConfigDir = "${LavishScript.HomeDirectory}/Scripts/EQ2Navigation/config/"
	variable string ConfigFile = "config.xml"
	variable lnavregionref CurrentZone
	variable lnavregionref PreviousZone
	variable lnavregionref CurrentRegion
	variable lnavregionref PreviousRegion
	variable int LastMapRend = ${LavishScript.RunningTime}
	variable EQ2Topography Topography
	variable string LastRegionAdded_Name
	variable float LastRegionAdded_X
	variable float LastRegionAdded_Y
	variable float LastRegionAdded_Z
	
	variable bool MapPathway = FALSE
	variable bool MapPathwayReverse = FALSE

	variable bool MapPathwayOld = FALSE

	method Initialize()
	{
	}

	method OnGUIChange()
	{
	}

	method Output(string Text)
	{
	    echo "EQ2Mapper:: ${Text}"
	}
	
	method Debug(string Text)
	{
	    echo "EQ2Mapper-Debug:: ${Text}"
	}	

	/* moved map loading out of intialize to allow LSO setting to load */
	method LoadMapper()
	{
		This:Output["Starting mapping system."]
		This:Load
		This:ZoneChanged
	}

	method Shutdown()
	{
		This:Output["Shutting down."]
		This:Save
		LavishNav:Clear
	}

	method ZoneChanged()
	{
		if !${LNavRegion[${This.ZoneText}](exists)}
		{
			LavishSettings[Instances]:AddSetting[${This.ZoneText},1]
			LNavRegion[${This.Continent}]:AddChild[universe,${This.ZoneText},-unique]
		}
		PreviousZone:Set[${CurrentZone}]
		CurrentZone:SetRegion[${LNavRegion[${This.ZoneText}].FQN}]
	}

    ;; This is unused at the moment....
	method Save1()
	{
		This:Debug["Saving map file ${ConfigDir}${ConfigFile}."]
		LNavRegion[EQ2]:Export[-lso,"${ConfigDir}new${ConfigFile}"]
		This:Debug["Saved."]
	}

	method BackupZone()
	{
		if ${UseLSO}
		{
			LNavRegion[${This.ZoneText}]:Export[-lso,"${ZonesDir}/bak/${This.ZoneText}.lso"]
		}
		else
		{
			LNavRegion[${This.ZoneText}]:Export["${ZonesDir}/bak/${This.ZoneText}.xml"]
		}
	}

	method Save()
	{
		if ${UseLSO}
		{
			LNavRegion[${This.ZoneText}]:Export[-lso,"${ZonesDir}${This.ZoneText}.lso"]
		}
		else
		{
			LNavRegion[${This.ZoneText}]:Export["${ZonesDir}${This.ZoneText}.xml"]
		}
	}

	method Load()
	{
		variable lnavregionref LoadZoneRegion
		variable lnavregionref LoadedZoneRegion

		;Clear out the map information
		LavishNav:Clear
		
		; Add tree structure for the loading
		Mapper:InitializeRegions


		LoadZoneRegion:SetRegion[${LavishNav.FindRegion[${This.ZoneText}].FQN}]
		LoadedZoneRegion:SetRegion[${LoadZoneRegion.Parent}]

		if ${UseLSO}
		{
			LoadedZoneRegion:Import[-lso,"${ZonesDir}${This.ZoneText}.lso"]
		}
		else
		{
			LoadedZoneRegion:Import["${ZonesDir}${This.ZoneText}.xml"]
		}
	}

	method InitializeRegions()
	{
		This:Output["Initializing regions."]
		LavishNav.Tree:AddChild[universe,EQ2,-unique]
			
		LNavRegion[EQ2]:AddChild[universe,${This.Continent},-unique,-coordinatesystem]		
				
		LNavRegion[${This.Continent}]:AddChild[universe,${This.ZoneText},-unique]
	}

	method Pulse()
	{
		This.PreviousRegion:SetRegion[${This.CurrentRegion}]
		This.CurrentRegion:SetRegion[${This.CurrentZone.BestContainer[${Me.ToActor.Loc}].ID}]

		if (${This.CurrentZone.ID} != ${LNavRegion[${This.ZoneText}].ID})
		{
			This:Output["Zone changed, updating!"]
			This:ZoneChanged
		}

		; Do we have this mapped? If not map it
		if !${This.IsMapped[${Me.ToActor.Loc}]}
		{
			This:MapLocation[${Me.ToActor.Loc},"${CurrentZone.FQN}-${Time.Timestamp}-${CurrentZone.ChildCount}"]
		}


		if ${CurrentRegion.FQN.NotEqual[${PreviousRegion.FQN}]}
		{
			if ${This.MapPathway}
			{
				This:Output["Marking preferred path from ${CurrentRegion.FQN} to ${PreviousRegion.FQN}."]
				PreviousRegion.GetConnection[${CurrentRegion.FQN}]:SetDistance[1]
			}
			if ${This.PathwayReverse}
			{
				This:Output["Marking preferred path (reverse) from ${PreviousRegion.FQN} to ${CurrentRegion.FQN}."]
				CurrentRegion.GetConnection[${PreviousRegion.FQN}]:SetDistance[1]
			}
		}
	}

	member IsMapped(float X, float Y, float Z)
	{
		if (${This.CurrentZone.ID} == ${This.CurrentRegion.ID})
		{
			return FALSE
		}
		return TRUE
	}

	method MapLocation(float X, float Y, float Z, string RegionName)
	{
		variable float X1
		variable float X2
		variable float Y1
		variable float Y2
		variable float Z1
		variable float Z2

		X1:Set[${X}-2.5]
		X2:Set[${X}+2.5]
		Y1:Set[${Y}-3]
		Y2:Set[${Y}+3]
		Z1:Set[${Z}-2.5]
		Z2:Set[${Z}+2.5]

		CurrentZone:AddChild[box,${RegionName},-unique,${X1},${X2},${Y1},${Y2},${Z1},${Z2}]
		This:Output["Area not found, mapping!  Added (${RegionName} ${X}, ${Y}, ${Z})."]
		LastRegionAdded_Name:Set[${RegionName}]
		LastRegionAdded_X:Set[${X}]
		LastRegionAdded_Y:Set[${Y}]
		LastRegionAdded_Z:Set[${Z}]
		
		;Connect To Previous and Current
		This:ConnectNeighbours[${RegionName}]
	}

	method ConnectNeighbours(string RegionName)
	{
		variable index:lnavregionref SurroundingRegions
		variable int RegionsFound
		variable int Shouldconnect = 0
		variable int Index = 1
		variable int Connected_To = 0
		variable int Connected_From = 0

		CurrentRegion:SetRegion[${RegionName}]
		
		if !${PreviousRegion.FQN(exists)}
    		This.PreviousRegion:SetRegion[${This.CurrentRegion}]
    	

		if ${This.ShouldConnect[${CurrentRegion.FQN},${PreviousRegion.FQN}]}
		{
			This:Debug["Connecting ${CurrentRegion.FQN} to ${PreviousRegion.FQN}."]
			CurrentRegion:Connect[${PreviousRegion.FQN}]
		}
		if ${This.ShouldConnect[${PreviousRegion.FQN},${CurrentRegion.FQN}]}
		{
			This:Debug["Connecting ${PreviousRegion.FQN} to ${CurrentRegion.FQN}."]
			PreviousRegion:Connect[${CurrentRegion.FQN}]
		}

		; Need to add in Connect to Previous spot to current spot and current spot to previous spot if no collisions
		; Scan all descendants within 5 feet of this area
		RegionsFound:Set[${CurrentZone.ChildrenWithin[SurroundingRegions,10,${CurrentRegion.CenterPoint}]}]
		if ${RegionsFound} > 0
		{
			do
			{
				if ${This.ShouldConnect[${CurrentRegion.FQN},${SurroundingRegions.Get[${Index}].FQN}]} && ${This.ShouldConnect[${SurroundingRegions.Get[${Index}].FQN},${CurrentRegion.FQN}]}
				{
					Connected_To:Inc
					Connected_From:Inc
					CurrentRegion:Connect[${SurroundingRegions.Get[${Index}].FQN}]
					SurroundingRegions.Get[${Index}]:Connect[${CurrentRegion.FQN}]
				}
			}
			while ${SurroundingRegions.Get[${Index:Inc}](exists)}
			This:Output["Connections To: ${Connected_To} and From: ${Connected_From}"]
		}
	}

	member ShouldConnect(string RegionA, string RegionB)
	{
		variable lnavregionref RegionRefA
		variable lnavregionref RegionRefB

		if !${RegionA(exists)} || !${RegionB(exists)}
		{
			return FALSE
		}

		; If they are the same Region.. Dont connect them
		if ${RegionA.Equal[${RegionB}]}
		{
			return FALSE
		}

		RegionRefA:SetRegion[${RegionA}]
		RegionRefB:SetRegion[${RegionB}]

		if !${This.RegionsIntersect[${RegionA},${RegionB}]}
		{
			return FALSE
		}

		if ${This.MapPathway}
		{
			if (${RegionRefA.CenterPoint.X} - ${RegionRefB.CenterPoint.X} == 0) && (${RegionRefA.CenterPoint.Y} - ${RegionRefB.CenterPoint.Y} == 0)
			{
				This:Output["Pathway, moving vertically -- Map it!"]
				return TRUE
			}
			if !${This.CollisionTest[${RegionRefA.CenterPoint.}, ${RegionRefB.CenterPoint}]}
			{
				This:Output["Pathway (smooth way) -- Map it!"]
				return TRUE
			}
			if !${This.CollisionTest[${RegionRefA.CenterPoint.X}, ${RegionRefA.CenterPoint.Y}, ${Math.Calc[${RegionRefA.CenterPoint.Z}+1.6]}, ${RegionRefB.CenterPoint.X}, ${RegionRefB.CenterPoint.Y}, ${Math.Calc[${RegionRefA.CenterPoint.Z}+1.6]}]}
			{
				This:Output["Pathway (rough way) -- Map it!"]
				return TRUE
			}
		}


		if ${Topography.IsSteep[${RegionRefA.CenterPoint}, ${RegionRefB.CenterPoint}]}
		{
			This:Output["Point too steep! -- Not Connected"]
			return FALSE
		}
		return TRUE
	}

	member RegionsIntersect(string RegionA, string RegionB)
	{
		variable lnavregionref RA
		variable lnavregionref RB

		RA:SetRegion[${RegionA}]
		RB:SetRegion[${RegionB}]

		if ${RA.Type.NotEqual["Box"]} || ${RB.Type.NotEqual["Box"]}
		{
			return FALSE
		}

		; Check Distance between if > 10 then it shouldnt connect
		if ${Math.Distance[${RA.CenterPoint.X}, ${RA.CenterPoint.Y}, ${RB.CenterPoint.X}, ${RB.CenterPoint.Y}]}>10
		{
			return FALSE
		}
		return TRUE
	}

	member ZoneText()
	{
		return ${Zone.ShortName}
	}

	member Continent()
	{
		return ${Zone.ShortName.Token[1,_]}
	}
}


objectdef EQ2Topography
{
	variable point3f TempLoc
	variable int SlopeCheck = ${LavishScript.RunningTime}

	method Output(string Text)
	{
	    echo "EQ2Topography:: ${Text}"
	}
	
	method Debug(string Text)
	{
	    echo "EQ2Topography-Debug:: ${Text}"
	}	

	method UpdateTemp()
	{
		if ${LavishScript.RunningTime}-${This.SlopeCheck} > 500
		{
			This.TempLoc:Set[${Me.ToActor.Loc}]
			This.SlopeCheck:Set[${LavishScript.RunningTime}]
		}
	}

	member IsFlat()
	{
		if ${This.IsSteep[${This.TempLoc},${Me.ToActor.Loc}]}
		{
			This:Debug["Very steep!"]
			This:UpdateTemp
			return FALSE
		}
		This:UpdateTemp
		return TRUE
	}

	/* check slope to determine if two points should connect - assumes anything more than 45 degrees is impassable */
	member IsSteep(float FromX, float FromY, float FromZ, float ToX, float ToY, float ToZ)
	{
		variable float slope = 0
		variable float horizontal = ${Math.Distance[${FromX}, ${FromZ}, ${ToY},${ToX}, ${ToZ},${ToY}]}
		variable float vertical = ${Math.Distance[${ToX}, ${ToZ}, ${FromY}, ${ToX}, ${ToZ}, ${ToY}]}

		/* did we move? */
		if ${horizontal} < 1.5
		{
			return FALSE
		}
		slope:Set[${Math.Atan[${vertical}/${horizontal}]}]
		if ${slope} > 50
		{
			return TRUE
		}
		return FALSE
	}
}
