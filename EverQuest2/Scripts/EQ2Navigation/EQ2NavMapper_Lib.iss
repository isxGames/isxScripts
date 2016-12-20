;;;;;;;;;;;;;;;;;;;;;;;;
;;; A Significant portion of the scripting used in this file was taken from OpenBot (for World of Warcraft and ISXWOW).
;;; That source is available at http://www.ob-dev.com/svn/openbot/ in its original form and, except where noted, is
;;; licensed under a Attribution-Noncommercial-No Derivative Works 3.0 United States License
;;; (http://creativecommons.org/licenses/by-nc-nd/3.0/us/)
;;;
;;; All "Dynamic" region creation and concepts are originally from CyberTech (cybertech@gmail.com)
;;;;;;;;;;;;;;;;;;;;;;;;

#ifndef _EQ2NavMapper_
#define _EQ2NavMapper_

objectdef EQ2Mapper
{
	;;;; If FALSE, then 'xml' file is the output.  Scripts can modify this if desired.
	variable bool UseLSO = FALSE

	;; Can be 'Box', 'Point', or 'Sphere'
	variable string MapFileRegionsType = "Sphere"

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Values that should be set via GUI interfaces in your scripts (or config files):
	;; ~ BoxRadius:  When creating a mapfile using box type regions, this is the X/Z radius of the regions
	;;   created.  The default is 2, and should be good for almost everything.
	;; ~ Min/MaxBoxIntersectionDistance:  These values should be tweaked only with the greatest care.  If too
	;;   high, then you may not get interesections between regions and thereby not have enough mapping data.
	;;   If too low, then the paths could be innefficient and the navigator may run past regions faster than the
	;;   pulse can keep up.  The default of 3/7 seems to be appropriate for most things.  (5/8 might be another
	;;   workable option)
	;; ~ NoCollisionDetection:  If set to TRUE, then the script will not make any collision checks at all when
	;;   determining if regions should connect.
	;; ~ DefaultSphereRadius:  Self explanatory -- used when creating sphere region types
	;;
	variable float BoxRadius = 2
	variable int MinBoxIntersectionDistance = 2
	variable int MaxBoxIntersectionDistance = 10
	variable bool NoCollisionDetection = false
	variable float DefaultSphereRadius = 10
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	variable filepath ZonesDir = "${LavishScript.HomeDirectory}/Scripts/EQ2Navigation/zones/"
	variable filepath ConfigDir = "${LavishScript.HomeDirectory}/Scripts/EQ2Navigation/config/"
	variable string ConfigFile = "config.xml"
	variable lnavregionref CurrentZone
	variable lnavregionref PreviousZone
	variable lnavregionref CurrentRegion
	variable lnavregionref PreviousRegion
	variable int LastMapRend = ${LavishScript.RunningTime}
	variable EQ2Topography Topography
	variable lnavregionref LastCreatedRegion
	variable string LastRegionAdded_Name
	variable float LastRegionAdded_X
	variable float LastRegionAdded_Y
	variable float LastRegionAdded_Z
	variable float Max_Distance_Between_Checks = 10
	variable float Max_Region_Size = 20
	variable bool PointToPointMode = FALSE



	method Initialize()
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
	method LoadMap()
	{
		;This:Output["Starting mapping system."]
		call This.Load
		This:ZoneChanged
	}

	method Shutdown()
	{
		;This:Output["Shutting down."]
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

	method BackupZone()
	{
		if ${UseLSO}
		{
			LNavRegion[${This.ZoneText}]:Export[-lso,"${ZonesDir}bak/${This.ZoneText}"]
		}
		else
		{
			LNavRegion[${This.ZoneText}]:Export["${ZonesDir}bak/${This.ZoneText}.xml"]
		}
	}

	method Save()
	{
		if ${UseLSO}
		{
			LNavRegion[${This.ZoneText}]:Export[-lso,"${ZonesDir}${This.ZoneText}"]
		}
		else
		{
			LNavRegion[${This.ZoneText}]:Export["${ZonesDir}${This.ZoneText}.xml"]
		}
	}

	function Load()
	{
		variable lnavregionref LoadZoneRegion
		variable lnavregionref LoadedZoneRegion

		;Clear out the map information
		LavishNav:Clear

		; Add tree structure for the loading
		This:InitializeRegions


		LoadZoneRegion:SetRegion[${LavishNav.FindRegion[${This.ZoneText}].FQN}]
		LoadedZoneRegion:SetRegion[${LoadZoneRegion.Parent}]

		declare FP filepath ${ZonesDir}
		if ${UseLSO}
		{
			;; Atempt LSO first, if no LSO file, then try and load XML before giving up.
			if ${FP.FileExists[${This.ZoneText}]}
				LoadedZoneRegion:Import[-lso,"${ZonesDir}${This.ZoneText}"]
			elseif ${FP.FileExists[${This.ZoneText}.xml]}
				LoadedZoneRegion:Import["${ZonesDir}${This.ZoneText}.xml"]
			else
				This:Output["No file exists for zone: ${This.ZoneText}"
		}
		else
		{
			;; Atempt XML first, if no XML file, then try and load LSO before giving up.
			if ${FP.FileExists[${This.ZoneText}.xml]}
				LoadedZoneRegion:Import["${ZonesDir}${This.ZoneText}.xml"]
			elseif ${FP.FileExists[${This.ZoneText}]}
				LoadedZoneRegion:Import[-lso,"${ZonesDir}${This.ZoneText}"]
			else
				This:Output["No file exists for zone: ${This.ZoneText}"
		}
	}

	method InitializeRegions()
	{
		;This:Output["Initializing regions."]
		LavishNav.Tree:AddChild[universe,EQ2,-unique]

		LNavRegion[EQ2]:AddChild[universe,${This.Continent},-unique,-coordinatesystem]

		LNavRegion[${This.Continent}]:AddChild[universe,${This.ZoneText},-unique]
	}

	method Pulse()
	{
		This.PreviousRegion:SetRegion[${This.CurrentRegion}]
		This.CurrentRegion:SetRegion[${This.CurrentZone.BestContainer[${Me.Loc}].ID}]

		if (${This.CurrentZone.ID} != ${LNavRegion[${This.ZoneText}].ID})
		{
			This:Output["Zone changed, updating!"]
			This:ZoneChanged
		}


		if (!${This.IsMapped[${Me.Loc}]})
		{
			switch ${This.MapFileRegionsType}
			{
				case Box
				This:PlotBoxFromPoint[${Me.Loc}]
				break

				case Point
				This:PlotPoint[${Me.Loc}]
				break

				case Sphere
				This:PlotSphereFromPoint[${Me.Loc}]
				break

				Default
				This:PlotSphereFromPoint[${Me.Loc}]
				break
			}
		}
	}

	member IsMapped(float X, float Y, float Z)
	{
		if (${This.CurrentZone.ID} == ${This.CurrentRegion.ID})
			return FALSE

		variable lnavregionref Container

		Container:SetRegion[${This.CurrentZone.BestContainer[${X},${Y},${Z}].ID}]

		if ${Container.ID(exists)} && (${Container.Type.Equal[Universe]} || !${Container.ID})
		{
			;This:Output["IsMapped: Should never happen with mapped space: Container.Type.Equal[Universe] ${Container.ID} ${Container.FQN} ${Container.Type}  ${X},${Y},${Z}"]
			;This:Output["\${This.CurrentZone} = ${This.CurrentZone}"]
			return FALSE
		}

		return TRUE

	}

	member:lnavregionref BestorNearestContainer(float X, float Y, float Z)
	{
		if ${This.IsMapped[${X},${Y},${Z}]}
		{
			return ${This.BestContainer[${X},${Y},${Z}]}
		}
		else
		{
			return ${This.NearestChild[${X},${Y},${Z}]}
		}
	}
	member:lnavregionref BestContainer(float X, float Y, float Z)
	{
		variable lnavregionref Container

		Container:SetRegion[${This.CurrentZone.BestContainer[${X},${Y},${Z}].ID}]
		if ${Container.Type.Equal[Universe]}
		{
			return 0
		}
		return ${Container}
	}

	member:lnavregionref NearestChild(float X, float Y, float Z)
	{
		variable lnavregionref Container

		Container:SetRegion[${This.CurrentZone.NearestChild[${X},${Y},${Z}].ID}]
		if ${Container.Type.Equal[Universe]}
		{
			return 0
		}
		return ${Container}
	}

	method PlotPoint(float X, float Y, float Z, string RegionName)
	{
		variable point3f Location
		Location:Set[${X},${Y},${Z}]

		if (${RegionName.Equal["Auto"]})
			RegionName:Set["${CurrentZone.FQN}-${Time.Timestamp}-${CurrentZone.ChildCount}"]

		LastCreatedRegion:SetRegion[${CurrentZone.AddChild[point,${PointName}, ${Location}]}]
		This:Output["-----"]
		This:Output["Adding Region to map as 'Point' - (${RegionName} ${X}, ${Y}, ${Z})"]

		LastRegionAdded_Name:Set[${RegionName}]
		LastRegionAdded_X:Set[${X}]
		LastRegionAdded_Y:Set[${Y}]
		LastRegionAdded_Z:Set[${Z}]

		This:ConnectNeighbours[${LastCreatedRegion}]
	}

	method PlotSphereFromPoint(float X, float Y, float Z, float Radius=${DefaultSphereRadius}, string RegionName="auto",bool AsUnique=FALSE)
	{
		variable point3f Location
		Location:Set[${X},${Y},${Z}]

		if (${RegionName.Equal["Auto"]})
			RegionName:Set["${CurrentZone.FQN}-${Time.Timestamp}-${CurrentZone.ChildCount}"]

		if (${AsUnique})
			LastCreatedRegion:SetRegion[${CurrentZone.AddChild[sphere,${RegionName},-unique,${Radius},${Location}]}]
		else
			LastCreatedRegion:SetRegion[${CurrentZone.AddChild[sphere,${RegionName},${Radius},${Location}]}]

		This:Output["-----"]
		This:Output["Adding Region to map as 'sphere' (from point) - (${RegionName} ${X}, ${Y}, ${Z}, Radius: ${Radius})"]
		This.Max_Distance_Between_Checks:Set[${Radius}]

		LastRegionAdded_Name:Set[${RegionName}]
		LastRegionAdded_X:Set[${X}]
		LastRegionAdded_Y:Set[${Y}]
		LastRegionAdded_Z:Set[${Z}]

		This:ConnectNeighbours[${LastCreatedRegion}]
	}

	method PlotBoxFromPoint(float X, float Y, float Z, string RegionName="auto",bool AsUnique=FALSE)
	{
		variable float X1
		variable float X2
		variable float Y1
		variable float Y2
		variable float Z1
		variable float Z2

		X1:Set[${X}-${This.BoxRadius}]
		X2:Set[${X}+${This.BoxRadius}]
		Y1:Set[${Y}-3]
		Y2:Set[${Y}+3]
		Z1:Set[${Z}-${This.BoxRadius}]
		Z2:Set[${Z}+${This.BoxRadius}]

		if (${RegionName.Equal["Auto"]})
			RegionName:Set["${CurrentZone.FQN}-${Time.Timestamp}-${CurrentZone.ChildCount}"]

		if (${AsUnique})
			LastCreatedRegion:SetRegion[${CurrentZone.AddChild[box,${RegionName},-unique,${X1},${X2},${Y1},${Y2},${Z1},${Z2}]}]
		else
			LastCreatedRegion:SetRegion[${CurrentZone.AddChild[box,${RegionName},${X1},${X2},${Y1},${Y2},${Z1},${Z2}]}]
		;LastCreatedRegion:SetCustom[Note,"example"]

		This:Output["-----"]
		This:Output["Adding Region to map as 'box' - (${RegionName} ${X}, ${Y}, ${Z})"]
		LastRegionAdded_Name:Set[${RegionName}]
		LastRegionAdded_X:Set[${X}]
		LastRegionAdded_Y:Set[${Y}]
		LastRegionAdded_Z:Set[${Z}]

		This:ConnectNeighbours[${LastCreatedRegion}]
	}

	member CollisionTest(float FromX, float FromY, float FromZ, float ToX, float ToY, float ToZ)
	{
		if (${This.NoCollisionDetection})
			return FALSE

		return ${EQ2.CheckCollision[${FromX},${FromY},${FromZ},${ToX},${ToY},${ToZ}]}
	}

	method ConnectNeighbours(lnavregionref Region)
	{
		variable index:lnavregionref SurroundingRegions
		variable int RegionsFound
		variable int Shouldconnect = 0
		variable int Index = 1
		variable int Connected_To = 0
		variable int Connected_From = 0

		CurrentRegion:SetRegion[${Region}]
		if !${CurrentRegion.ID(exists)}
		{
			This:Debug[":ConnectNeighbours - CurrentRegion.ID does not exist!"]
			return
		}

		if !${PreviousRegion.FQN(exists)}
			This.PreviousRegion:SetRegion[${This.CurrentRegion}]


		variable float DistanceToCheck
		switch ${Region.Type}
		{
			case Box
				DistanceToCheck:Set[${Math.Distance[${Region.X1},${Region.Y1},${Region.X2},${Region.Y2}]} * 1.5]
				break
			case Radius
			case Sphere
				DistanceToCheck:Set[${Region.Radius} * 3.0]
				break
			case Point
				DistanceToCheck:Set[0]
				;return
				break
			default
				This:Debug[":ConnectNeighbours - Unknown Object Type ${Region.Type}"]
				return
				break
		}

		if (${PointToPointMode})
		{
			if (!${PreviousRegion.FQN.Equal[${CurrentRegion.FQN}]})
			{
				This:Debug["Connecting ${CurrentRegion.FQN} <-> ${PreviousRegion.FQN}."]
				CurrentRegion:Connect[${PreviousRegion.FQN}]
				PreviousRegion:Connect[${CurrentRegion.FQN}]
				Connected_To:Inc
				Connected_From:Inc
			}
		}
		else
		{
			;This:Debug["Checking if ${CurrentRegion.FQN} and ${PreviousRegion.FQN} ShouldConnect()"]
			if ${This.ShouldConnect[${CurrentRegion.FQN},${PreviousRegion.FQN}]}
			{
				This:Debug["Connecting ${CurrentRegion.FQN} <-> ${PreviousRegion.FQN}."]
				CurrentRegion:Connect[${PreviousRegion.FQN}]
				PreviousRegion:Connect[${CurrentRegion.FQN}]
				Connected_To:Inc
				Connected_From:Inc
			}
		}

		; Need to add in Connect to Previous spot to current spot and current spot to previous spot if no collisions
		; Scan all descendants within 5 feet of this area
		RegionsFound:Set[${CurrentZone.ChildrenWithin[SurroundingRegions,${DistanceToCheck},${CurrentRegion.CenterPoint}]}]
		;This:Debug["${RegionsFound} regions found within ${DistanceToCheck} meters -- determing if they should connect."]
		if ${RegionsFound} > 0
		{
			do
			{
				if (${SurroundingRegions.Get[${Index}].FQN.Equal[${CurrentRegion.FQN}]} || ${SurroundingRegions.Get[${Index}].FQN.Equal[${PreviousRegion.FQN}]})
					continue

				;This:Debug["Checking if ${CurrentRegion.FQN} and ${SurroundingRegions.Get[${Index}].FQN} ShouldConnect()"]
				if ${This.ShouldConnect[${CurrentRegion.FQN},${SurroundingRegions.Get[${Index}].FQN}]}
				{
					Connected_To:Inc
					Connected_From:Inc
					CurrentRegion:Connect[${SurroundingRegions.Get[${Index}].FQN}]
					SurroundingRegions.Get[${Index}]:Connect[${CurrentRegion.FQN}]
					This:Debug["Connecting ${SurroundingRegions.Get[${Index}].FQN} <-> ${CurrentRegion.FQN}."]
					if ${Connected_To} >= 8 || ${Connected_From} >= 8
						break
				}
			}
			while ${SurroundingRegions.Get[${Index:Inc}](exists)}
			This:Output["Connections To: ${Connected_To} and From: ${Connected_From}"]
		}

		This.PreviousRegion:SetRegion[${This.CurrentRegion}]
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
			This:Debug["Regions do not intersect"]
			return FALSE
		}

		if (!${This.NoCollisionDetection})
		{
			if ${This.CollisionTest[${RegionRefA.CenterPoint}, ${RegionRefB.CenterPoint}]}
			{
				This:Output["Obstruction found between ${RegionRefA.FQN} <-> ${RegionRefB.FQN} -- not connecting."]
				return FALSE
			}
		}

		if ${RegionRefA.CenterPoint.Y} > ${RegionRefB.CenterPoint.Y} + 5
			return FALSE
		elseif ${RegionRefA.CenterPoint.Y} < ${RegionRefB.CenterPoint.Y} - 5
			return FALSE
		elseif ${RegionRefB.CenterPoint.Y} > ${RegionRefA.CenterPoint.Y} + 5
			return FALSE
		elseif ${RegionRefB.CenterPoint.Y} < ${RegionRefA.CenterPoint.Y} - 5
			return FALSE


		;This:Debug["ShouldConnect() -- Returning True"]
		return TRUE
	}

	member RegionsIntersect(string RegionA, string RegionB)
	{
		variable lnavregionref RA
		variable lnavregionref RB

		RA:SetRegion[${RegionA}]
		RB:SetRegion[${RegionB}]

		if ${RA.Type.Equal[${RB.Type}]}
		{
			switch ${RA.Type}
			{
				case Box
					if ${Math.Distance[${RA.CenterPoint.X}, ${RA.CenterPoint.Z}, ${RB.CenterPoint.X}, ${RB.CenterPoint.Z}]} >= ${This.MaxBoxIntersectionDistance}
						return FALSE
					if ${Math.Distance[${RA.CenterPoint.X}, ${RA.CenterPoint.Z}, ${RB.CenterPoint.X}, ${RB.CenterPoint.Z}]} <= ${This.MinBoxIntersectionDistance}
						return FALSE
					break

				case Radius
				case Sphere
					declarevariable distance float local ${Math.Calc[${Math.Distance[${RA.CenterPoint}, ${RB.CenterPoint}]} * 2]}
					declarevariable radii float local ${Math.Calc[${RA.Radius} + ${RB.Radius}]}

					; The spheres overlap if their combined radius is larger than the distance of their centers
					if (${distance} < (${radii} * ${radii}))
						return TRUE
					else
						return FALSE

				default
					if ${Math.Distance[${RA.CenterPoint.X}, ${RA.CenterPoint.Z}, ${RB.CenterPoint.X}, ${RB.CenterPoint.Z}]} >= ${This.MaxBoxIntersectionDistance}
						return FALSE
					if ${Math.Distance[${RA.CenterPoint.X}, ${RA.CenterPoint.Z}, ${RB.CenterPoint.X}, ${RB.CenterPoint.Z}]} <= ${This.MinBoxIntersectionDistance}
						return FALSE
			}
		}
		else
		{
			;; Treat them as two boxes I guess
			if ${Math.Distance[${RA.CenterPoint.X}, ${RA.CenterPoint.Z}, ${RB.CenterPoint.X}, ${RB.CenterPoint.Z}]} >= ${This.MaxBoxIntersectionDistance}
				return FALSE
			if ${Math.Distance[${RA.CenterPoint.X}, ${RA.CenterPoint.Z}, ${RB.CenterPoint.X}, ${RB.CenterPoint.Z}]} <= ${This.MinBoxIntersectionDistance}
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
			This.TempLoc:Set[${Me.Loc}]
			This.SlopeCheck:Set[${LavishScript.RunningTime}]
		}
	}

	member IsFlat()
	{
		if ${This.IsSteep[${This.TempLoc},${Me.Loc}]}
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
		slope:Set[${Math.Cos[${vertical}/${horizontal}]}]
		if ${slope} > 45
		{
			return TRUE
		}


		;; more checks
		if ${FromY} > ${ToY} + 3
			return TRUE
		elseif ${FromY} < ${ToY} - 3
			return TRUE
		elseif ${ToY} > ${FromY} + 3
			return TRUE
		elseif ${ToY} < ${FromY} - 3
			return TRUE

		return FALSE
	}
}

#endif /* _EQ2NavMapper_ */
