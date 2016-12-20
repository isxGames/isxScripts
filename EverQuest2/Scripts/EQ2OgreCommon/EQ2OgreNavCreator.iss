/** -----------------------------------------------------------------------------------------------
 New NavCreator by Kannkor (Hotshot). Written from scratch, based off of EQ2NavCreator written by Amadeus
 Version 1.03
	- Added auto plotting options: Auto Plotting (same as current, plots while you move) and Auto Avoid (makes all points you walk over marked as avoid)
	- Fixed zoning so it saves when you zone.
	- Made it so you can't "delete" too fast to where you delete the zone file.
	- Save is now F11
	- Save and exit is now F12
	- Exit WITHOUT saving is now Control F12
 Version 1.02b
	- Removed wait 1 to see if it can speed up the mapping
	- Added Exit without saving
	- Added option to save as XML also. Note: Loading will ALWAYS load from the LSO first. So rename/delete the LSO if you want to load an XML file.
-----------------------------------------------------------------------------------------------


To-do list

**/



variable float XZBoxRadius=1
variable float YUpBoxRadius=1
variable float YDownBoxRadius=0.5
variable float MaxDistanceBetweenBoxes=3

variable float X1
variable float X2
variable float Y1
variable float Y2
variable float Z1
variable float Z2

variable(global) int EQ2OgreNavCreatorHUDX=250
variable(global) int EQ2OgreNavCreatorHUDY=180
variable(global) int EQ2OgreNavCreatorHUDInc=20
variable(global) int EQ2OgreNavCreatorCurrentPointHUDX=750
variable(global) int EQ2OgreNavCreatorCurrentPointHUDY=180

variable bool AllowConnections=TRUE
variable lnavregion LastPoint
variable lnavregion CurrentPoint
variable lnavregion EQ2OgreNavRegion
variable(global) lnavconnection EQ2OgreNavConnection

variable collection:string RegionConnectionsToBeRemoved

variable(global) bool EQ2OgreMapperAddCustomPointBool=FALSE
variable(global) bool EQ2OgreMapperExitWithoutSaveBool=FALSE
variable(global) bool EQ2OgreMapperExitAndSaveBool=FALSE
variable(global) bool EQ2OgreMapperMarkAsAvoidBool=FALSE
variable(global) bool EQ2OgreMapperDeletePointBool=FALSE
variable(global) bool EQ2OgreMapperSaveXMLCopyBool=FALSE
variable(global) bool EQ2OgreMapperSaveBool=FALSE
variable(global) string EQ2OgreMapperPlottingType=Auto Plotting

variable string CustomPointName=NULL
variable(global) string EQ2OgreNavCreatorLastNamedPoint=None

variable string ZoneVar
;I use a Zone variable to ensure the lavish tree we create is deleted, and the zone we start in is the file we save also incase you zone.

#include "${LavishScript.HomeDirectory}/Scripts/EQ2OgreCommon/OgreMapController.inc"

function main()
{
	;Delcare the Nav Object
	declare OgreNavMapperOb OgreNavMapperObject
	OgreNavMapperOb:ImportIt

	Script:Squelch
	bind EQ2OgreNavCreatorAutoPlottingBind Shift+F1 "EQ2OgreMapperPlottingType:Set[Auto Plotting]"
	bind EQ2OgreNavCreatorAddCustomPointBind F2 EQ2OgreMapperAddCustomPointBool:Set[TRUE]
	bind EQ2OgreNavCreatorMarkAsAvoidBind F3 EQ2OgreMapperMarkAsAvoidBool:Set[TRUE]
	bind EQ2OgreNavCreatorAutoAvoidBind Shift+F3 "EQ2OgreMapperPlottingType:Set[Auto Avoid]"
	bind EQ2OgreNavCreatorDeletePointBind F4 EQ2OgreMapperDeletePointBool:Set[TRUE]
	bind EQ2OgreNavCreatorSaveXMLCopyBind F8 EQ2OgreMapperSaveXMLCopyBool:Toggle
	bind EQ2OgreNavCreatorSaveBind F11 EQ2OgreMapperSaveBool:Set[TRUE]
	bind EQ2OgreNavCreatorSaveAndExitBind F12 EQ2OgreMapperExitAndSaveBool:Set[TRUE]
	bind EQ2OgreNavCreatorExitWithoutSaveBind Ctrl+F12 EQ2OgreMapperExitWithoutSaveBool:Set[TRUE]


	HUD -add EQ2OgreNavCreatorAutoPlottingHUD ${EQ2OgreNavCreatorHUDX},${EQ2OgreNavCreatorHUDY:Inc[${EQ2OgreNavCreatorHUDInc}]} "Shift+F1 - Turn plotting to auto plotting (default)."
	HUD -add EQ2OgreNavCreatorCustomAddPointHUD ${EQ2OgreNavCreatorHUDX},${EQ2OgreNavCreatorHUDY:Inc[${EQ2OgreNavCreatorHUDInc}]} "F2 - Re-name and make unique point."
	HUD -add EQ2OgreNavCreatorLastNamedPointAddedHUD ${Math.Calc[${EQ2OgreNavCreatorHUDX}+30].Int},${EQ2OgreNavCreatorHUDY:Inc[${EQ2OgreNavCreatorHUDInc}]} "Last unique point added: \${EQ2OgreNavCreatorLastNamedPoint}"
	HUD -add EQ2OgreNavCreatorMarkAsAvoidHUD ${EQ2OgreNavCreatorHUDX},${EQ2OgreNavCreatorHUDY:Inc[${EQ2OgreNavCreatorHUDInc}]} "F3 - Make current point as AVOID."
	HUD -add EQ2OgreNavCreatorAutoAvoidHUD ${EQ2OgreNavCreatorHUDX},${EQ2OgreNavCreatorHUDY:Inc[${EQ2OgreNavCreatorHUDInc}]} "Shift+F3 - Turn plotting to auto AVOID plotting."
	HUD -add EQ2OgreNavCreatorDeletePointHUD ${EQ2OgreNavCreatorHUDX},${EQ2OgreNavCreatorHUDY:Inc[${EQ2OgreNavCreatorHUDInc}]} "F4 - Delete current point (method of removing unique)."

	HUD -add EQ2OgreNavCreatorSaveXMLCopyHUD ${EQ2OgreNavCreatorHUDX},${EQ2OgreNavCreatorHUDY:Inc[${EQ2OgreNavCreatorHUDInc}]} "F8 - Save as XML also [${EQ2OgreMapperSaveXMLCopyBool}]"
	HUD -add EQ2OgreNavCreatorSaveHUD ${EQ2OgreNavCreatorHUDX},${EQ2OgreNavCreatorHUDY:Inc[${EQ2OgreNavCreatorHUDInc}]} "F11 - Save."
	HUD -add EQ2OgreNavCreatorSaveAndExitHUD ${EQ2OgreNavCreatorHUDX},${EQ2OgreNavCreatorHUDY:Inc[${EQ2OgreNavCreatorHUDInc}]} "F12 - Save and Exit."
	HUD -add EQ2OgreNavCreatorExitWithoutSaveHUD ${EQ2OgreNavCreatorHUDX},${EQ2OgreNavCreatorHUDY:Inc[${EQ2OgreNavCreatorHUDInc}]} "Control+F12 - Exit - NO SAVE."
	HUD -add EQ2OgreNavCreatorTotalPointsHUD ${EQ2OgreNavCreatorHUDX},${EQ2OgreNavCreatorHUDY:Inc[${EQ2OgreNavCreatorHUDInc}]} "Total points: \${Script[EQ2OgreNavCreator].VariableScope.EQ2OgreNavRegion.ChildCount}"

	;**Below is information about the current point you are on**
	HUD -add EQ2OgreNavCreatorCurrentPointTypeHUD ${EQ2OgreNavCreatorCurrentPointHUDX},${EQ2OgreNavCreatorCurrentPointHUDY:Inc[${EQ2OgreNavCreatorHUDInc}]} "Current plotting type: ${EQ2OgreMapperPlottingType}"
	HUD -add EQ2OgreNavCreatorCurrentPointNameHUD ${EQ2OgreNavCreatorCurrentPointHUDX},${EQ2OgreNavCreatorCurrentPointHUDY:Inc[${EQ2OgreNavCreatorHUDInc}]} "Current point Name: \${Script[EQ2OgreNavCreator].VariableScope.EQ2OgreNavRegion.BestContainer[${Me.Loc}].Name}"
	HUD -add EQ2OgreNavCreatorCurrentPointUniqueHUD ${EQ2OgreNavCreatorCurrentPointHUDX},${EQ2OgreNavCreatorCurrentPointHUDY:Inc[${EQ2OgreNavCreatorHUDInc}]} "Current point Unique?: \${Script[EQ2OgreNavCreator].VariableScope.EQ2OgreNavRegion.BestContainer[${Me.Loc}].Unique}"
	HUD -add EQ2OgreNavCreatorCurrentPointAvoidHUD ${EQ2OgreNavCreatorCurrentPointHUDX},${EQ2OgreNavCreatorCurrentPointHUDY:Inc[${EQ2OgreNavCreatorHUDInc}]} "Valid point?: \${Script[EQ2OgreNavCreator].VariableScope.EQ2OgreNavRegion.BestContainer[${Me.Loc}].AllPointsValid}"


	Script:Unsquelch

	while 1
	{
		AllowConnections:Set[TRUE]

		if ${EQ2OgreMapperExitAndSaveBool} || ${ZoneVar.NotEqual[${Zone}]} || ${EQ2OgreMapperExitWithoutSaveBool}
			Script:End
		if ${EQ2OgreMapperSaveBool}
		{
			call ExportIt
			EQ2OgreMapperSaveBool:Set[FALSE]
			continue
		}
		if ${EQ2OgreMapperMarkAsAvoidBool} || ( ${EQ2OgreMapperPlottingType.Equal[Auto Avoid]} && ${EQ2OgreNavRegion.BestContainer[${Me.Loc}].ID}!=${EQ2OgreNavRegion.ID} )
		{
			if !${EQ2OgreNavRegion.BestContainer[${Me.Loc}].AllPointsValid}
				continue
			;OgreNavMapperOb:MarkAvoid
			OgreNavMapperOb:RemoveBox
			AllowConnections:Set[FALSE]
			OgreNavMapperOb:WorkTheMagic
			EQ2OgreMapperMarkAsAvoidBool:Set[FALSE]
			continue
		}
		if ${EQ2OgreMapperDeletePointBool}
		{
			if ${EQ2OgreNavRegion.BestContainer[${Me.Loc}].ID}==${EQ2OgreNavRegion.ID}
				continue
			OgreNavMapperOb:RemoveBox
			EQ2OgreMapperDeletePointBool:Set[FALSE]
			continue
		}

		if ${EQ2OgreMapperAddCustomPointBool}
		{
			OgreNavMapperOb:SetBoxAroundMe
			call CustomAddBox
			if ${CustomPointName.NotEqual[NULL]}
			{
				OgreNavMapperOb:AddCustomPoint
			}
			EQ2OgreMapperAddCustomPointBool:Set[FALSE]
			CustomPointName:Set[NULL]
		}
		else
		{
			OgreNavMapperOb:WorkTheMagic
		}

		waitframe
	}

	;***How many Children do we have?
	;echo Child Count: ${EQ2OgreNavRegion.ChildCount}

}
function CustomAddBox()
{
	InputBox "Enter a name for the custom point"
	if ${UserInput.Length}
		CustomPointName:Set[${UserInput}]
}
objectdef OgreNavMapperObject
{
	method Initialize(string Name)
	{
		ZoneVar:Set[${Zone}]
	}
	method WorkTheMagic()
	{
		This:SetBoxAroundMe
		if ${This.CheckIfBoxMapped}
		{
			This:LoadCurrentAndPreviousPoints
			;If the point is mapped, we need not do anything
			return
		}
		else
		{
			;Point is not mapped. Lets add the point, connect the last point since it is valid (we just ran from it)
			;then connect the surrounding poings
			This:AddBox

			;If AllowConnections is FALSE, we will skip the adding connections.
			if !${AllowConnections}
				return
			else
				This:MarkAsAllPoints
			This:ConnectLastPoint
			This:ConnectSurroundingRegions
		}
		
	}
	method AddCustomPoint()
	{
		;If we are already on a mapped region, delete it first so we can add in our own and not to "double" up on the same spot.
		if ${This.CheckIfBoxMapped}
			This:RemoveBox
		EQ2OgreNavCreatorLastNamedPoint:Set[${CustomPointName}]
		This:CustomAddBox[${CustomPointName}]
		This:ConnectLastPoint
		This:ConnectSurroundingRegions
	}
	member:bool CollisionCheck(float CCX1, float CCY1, float CCZ1, float CCX2, float CCY2, float CCZ2, float HeightMod=0.5)
	{
		if !${EQ2.CheckCollision[${CCX1},${Math.Calc[${CCY1}+${HeightMod}]},${CCZ1},${CCX2},${Math.Calc[${CCY2}+${HeightMod}]},${CCZ2}]}
			return TRUE
	}
	member:bool DistanceCheck(float CCX1, float CCY1, float CCZ1, float CCX2, float CCY2, float CCZ2)
	{
		if ${Math.Distance[${CCX1},${CCY1},${CCZ1},${CCX2},${CCY2},${CCZ2}]} < ${MaxDistanceBetweenBoxes}
			return TRUE
	}
	method LoadCurrentAndPreviousPoints()
	{
		LastPoint:SetRegion[${CurrentPoint.ID}]
		CurrentPoint:SetRegion[${EQ2OgreNavRegion.BestContainer[${Me.Loc}].ID}]
	}
	member:bool CheckIfBoxMapped()
	{
		if ${EQ2OgreNavRegion.BestContainer[${Me.Loc}].ID}==${EQ2OgreNavRegion.ID}
		{
			;echo ${Me.Loc} is not mapped. BestContainer ( ${EQ2OgreNavRegion.BestContainer[${Me.Loc}].ID} ) is the same as the Region ( ${EQ2OgreNavRegion.ID} )
			return FALSE
		}
		else
		{
			;echo ${Me.Loc} is mapped. BestContainer ( ${EQ2OgreNavRegion.BestContainer[${Me.Loc}].ID} ) is NOT the same as the Region ( ${EQ2OgreNavRegion.ID} )
			return TRUE
		}
	}
	method RemoveBox()
	{
		RegionConnectionsToBeRemoved:Set[${EQ2OgreNavRegion.BestContainer[${Me.Loc}].Name},${EQ2OgreNavRegion.BestContainer[${Me.Loc}].Name}]
		;echo Adding ${EQ2OgreNavRegion.BestContainer[${Me.Loc}].Name} To the RegionConnectionsToBeRemoved ( ${RegionConnectionsToBeRemoved.Element[${EQ2OgreNavRegion.BestContainer[${Me.Loc}].Name}]} )
		EQ2OgreNavRegion.BestContainer[${Me.Loc}]:Remove
	}
	method MarkAvoid()
	{
		EQ2OgreNavRegion.BestContainer[${Me.Loc}]:SetAvoid[TRUE]
		EQ2OgreNavRegion.BestContainer[${Me.Loc}]:SetAllPointsValid[FALSE]
	}
	method AddBox()
	{
		;echo Adding Box around ${Me.Loc}
		;EQ2OgreNavRegion:AddChild[box,"auto",${X1},${X2},${Y1},${Y2},${Z1},${Z2}]
		LastPoint:SetRegion[${CurrentPoint.ID}]
		CurrentPoint:SetRegion[${EQ2OgreNavRegion.AddChild[box,"auto",${X1},${X2},${Y1},${Y2},${Z1},${Z2}]}]
		CurrentPoint:SetAllPointsValid[${AllowConnections}]
	}
	method CustomAddBox(string BoxName)
	{
		echo Adding custom Box ( ${BoxName} ) around ${Me.Loc}
		;EQ2OgreNavRegion:AddChild[box,${BoxName},-unique,${X1},${X2},${Y1},${Y2},${Z1},${Z2}]
		;LastPoint:SetRegion[${CurrentPoint.ID}]
		CurrentPoint:SetRegion[${EQ2OgreNavRegion.AddChild[box,${BoxName},-unique,${X1},${X2},${Y1},${Y2},${Z1},${Z2}]}]
		CurrentPoint:SetAllPointsValid[${AllowConnections}]
	}
	method SetBoxAroundMe()
	{
		X1:Set[${Me.X}-${XZBoxRadius}]
		X2:Set[${Me.X}+${XZBoxRadius}]
		Y1:Set[${Me.Y}-${YDownBoxRadius}]
		Y2:Set[${Me.Y}+${YUpBoxRadius}]
		Z1:Set[${Me.Z}-${XZBoxRadius}]
		Z2:Set[${Me.Z}+${XZBoxRadius}]
	}
	method ConnectLastPoint()
	{
		if !${CurrentPoint.AllPointsValid} || !${LastPoint.AllPointsValid} || ${CurrentPoint}==${LastPoint} || ${CurrentPoint}==0 || ${LastPoint}==0 || ${CurrentPoint}==${EQ2OgreNavRegion.ID} || ${LastPoint}==${EQ2OgreNavRegion.ID}
		{
			echo Can't connect points: ${CurrentPoint}==${LastPoint} || ${CurrentPoint}==0 || ${LastPoint}==0 || ${CurrentPoint}==${EQ2OgreNavRegion.ID} || ${LastPoint}==${EQ2OgreNavRegion.ID}
		}
		else
		{
			EQ2OgreNavRegion.FindRegion[${CurrentPoint}]:Connect[${LastPoint}]
			EQ2OgreNavRegion.FindRegion[${LastPoint}]:Connect[${CurrentPoint}]
		}
	}
	method ConnectSurroundingRegions()
	{
		variable index:lnavregionref SurroundingRegions
		variable int RegionsFound
		variable int TempCounter=1
		variable float DistanceToCheck=5

		;This shouldn't ever be called, but may as well save the CPU cycles if it is
		if !${CurrentPoint.AllPointsValid}
		{
			echo The current point ( CurrentPoint.ID: ${CurrentPoint.ID} ) is flagged as not able to have connections ( Currentpoint.AllPointsValid: ${CurrentPoint.AllPointsValid} ), but we are inside of the ConnectSurroundingRegions method. Please bug report this.
		}
		RegionsFound:Set[${EQ2OgreNavRegion.ChildrenWithin[SurroundingRegions,${DistanceToCheck},${CurrentPoint.CenterPoint}]}]
		if ${RegionsFound} > 0
		{
			do
			{
				;if ${SurroundingRegions.Get[${TempCounter}].ID}==${CurrentPoint.ID} || ${SurroundingRegions.Get[${TempCounter}].ID}==${LastPoint.ID}
				if ${SurroundingRegions.Get[${TempCounter}].ID}==${CurrentPoint.ID} || !${SurroundingRegions.Get[${TempCounter}].AllPointsValid}
					continue

				if ${This.DistanceCheck[${CurrentPoint.CenterPoint},${SurroundingRegions.Get[${TempCounter}].CenterPoint}]} && ${This.CollisionCheck[${CurrentPoint.CenterPoint},${SurroundingRegions.Get[${TempCounter}].CenterPoint}]}
				{
					;CurrentRegion:Connect[${SurroundingRegions.Get[${TempCounter}].FQN}]
					;SurroundingRegions.Get[${TempCounter}]:Connect[${CurrentRegion.FQN}]
					EQ2OgreNavRegion.FindRegion[${CurrentPoint}]:Connect[${SurroundingRegions.Get[${TempCounter}].ID}]
					EQ2OgreNavRegion.FindRegion[${SurroundingRegions.Get[${TempCounter}].ID}]:Connect[${CurrentPoint}]
				}
			}
			while ${SurroundingRegions.Get[${TempCounter:Inc}](exists)}
		}
	}
	method ImportIt()
	{

		OgreMapControllerOb:LoadMap[${ZoneVar}]
		EQ2OgreNavRegion:SetRegion[${LavishNav.FindRegion[${ZoneVar}].ID}]
	}
	method ExportIt()
	{
		echo Method: Saving to: [${ZoneFilePath}${ZoneVar}.xml]
		EQ2OgreNavRegion:Export[${ZoneFilePath}${ZoneVar}.xml]
	}
}
function ExportIt()
{

	echo Function: Saving to: [${ZoneFilePath}${ZoneVar}.lso]
	EQ2OgreNavRegion:Export[-lso,${ZoneFilePath}${ZoneVar}.lso]
	if ${EQ2OgreMapperSaveXMLCopyBool}
	{
		echo Saving an XML copy also.
		EQ2OgreNavRegion:Export[${ZoneFilePath}${ZoneVar}.xml]
	}
}
function CleanUpConnections()
{
	if ${RegionConnectionsToBeRemoved.Used}>0
	{
		echo Cleaning up ${RegionConnectionsToBeRemoved.Used}. This will take up to a minute please wait.
		;One at a time, go through every single Child (Box) and see if it contains RegionConnectionsToBeRemoved, if it does, clear it.
		
		variable lnavregionref NavRef
		variable int EQ2OgreNavCounter
		EQ2OgreNavCounter:Set[0]

		NavRef:SetRegion[${LavishNav.FindRegion[${Zone}].Children}]
		while ${NavRef.Region(exists)}
		{
			if !${RegionConnectionsToBeRemoved.FirstKey(exists)}
				return
			do
			{
				if ${NavRef.GetConnection[${RegionConnectionsToBeRemoved.CurrentKey}](exists)}
				{
					echo (NoUni) ABC exists in ${NavRef} ${NavRef.Name} ConnectionID: ${NavRef.GetConnection[${RegionConnectionsToBeRemoved.CurrentKey}].ID}
					EQ2OgreNavConnection:SetConnection[${NavRef.GetConnection[${RegionConnectionsToBeRemoved.CurrentKey}].ID}]
					EQ2OgreNavConnection:Remove
					;echo ABC exists in ${NavRef} ${NavRef.Name} ConnectionID: ${NavRef.GetConnection[${RegionConnectionsToBeRemoved.CurrentKey}].ID}
				}
				elseif ${NavRef.GetConnection[${RegionConnectionsToBeRemoved.CurrentKey}.${EQ2OgreNavRegion.Name}](exists)}
				{
					echo (UniAdded)ABC exists in ${NavRef} ${NavRef.Name} ConnectionID: ${NavRef.GetConnection[${RegionConnectionsToBeRemoved.CurrentKey}.${EQ2OgreNavRegion.Name}].ID}
					EQ2OgreNavConnection:SetConnection[${NavRef.GetConnection[${RegionConnectionsToBeRemoved.CurrentKey}.${EQ2OgreNavRegion.Name}].ID}]
					EQ2OgreNavConnection:Remove
					;echo ABC exists in ${NavRef} ${NavRef.Name} ConnectionID: ${NavRef.GetConnection[${RegionConnectionsToBeRemoved.CurrentKey}.${EQ2OgreNavRegion.Name}].ID}
				}
				NavRef:SetRegion[${NavRef.Next}]
			}
			while ${RegionConnectionsToBeRemoved.NextKey(exists)}
		}
	
	}
	else
		echo No connections to be cleaned up.
}
atom atexit()
{
	Script:Squelch

	bind -delete EQ2OgreNavCreatorAutoPlottingBind
	bind -delete EQ2OgreNavCreatorAutoAvoidBind
	bind -delete EQ2OgreNavCreatorAddCustomPointBind
	bind -delete EQ2OgreNavCreatorSaveXMLCopyBind
	bind -delete EQ2OgreNavCreatorExitWithoutSaveBind
	bind -delete EQ2OgreNavCreatorSaveAndExitBind
	bind -delete EQ2OgreNavCreatorMarkAsAvoidBind
	bind -delete EQ2OgreNavCreatorDeletePointBind
	bind -delete EQ2OgreNavCreatorSaveBind

	HUD -remove EQ2OgreNavCreatorAutoPlottingHUD
	HUD -remove EQ2OgreNavCreatorAutoAvoidHUD
	HUD -remove EQ2OgreNavCreatorSaveXMLCopyHUD
	HUD -remove EQ2OgreNavCreatorLastNamedPointAddedHUD
	HUD -remove EQ2OgreNavCreatorCustomAddPointHUD
	HUD -remove EQ2OgreNavCreatorSaveAndExitHUD
	HUD -remove EQ2OgreNavCreatorExitWithoutSaveHUD
	HUD -remove EQ2OgreNavCreatorTotalPointsHUD
	HUD -remove EQ2OgreNavCreatorDeletePointHUD 
	HUD -remove EQ2OgreNavCreatorMarkAsAvoidHUD 
	HUD -remove EQ2OgreNavCreatorDeletePointHUD
	HUD -remove EQ2OgreNavCreatorSaveHUD

	HUD -remove EQ2OgreNavCreatorCurrentPointTypeHUD
	HUD -remove EQ2OgreNavCreatorCurrentPointNameHUD 
	HUD -remove EQ2OgreNavCreatorCurrentPointUniqueHUD
	HUD -remove EQ2OgreNavCreatorCurrentPointAvoidHUD

	Script:Unsquelch

	if ${EQ2OgreMapperExitAndSaveBool} || ${ZoneVar.NotEqual[${Zone}]}
	{
		call CleanUpConnections
		call ExportIt
	}
	elseif ${EQ2OgreMapperExitWithoutSaveBool}
		echo Exiting without saving.
	OgreMapControllerOb:UnLoadMap[${ZoneVar}]

	echo Exiting EQ2OgreNavCreator
}