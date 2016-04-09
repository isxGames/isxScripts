;***************OgreMove for EQ2OgreHarvest Version 1.00**************
#include "${LavishScript.HomeDirectory}/Scripts/EQ2OgreCommon/OgreNav_Lib.inc"

function main(string Location, float X, float Y, float Z)
{
	call ChangeDefaults
	declarevariable ConditionsOb ModifiedConditionsObject script
	declarevariable InformationOb ModifiedInformationObject script

	variable int xx
	while ${Script[EQ2OgreHarvestMain](exists)} && !${EQ2OgreHarvestStop}
	{
		while !${EQ2OgreHarvestNextLoc.Length} || ${EQ2OgreHarvestNextLoc.Equal[None]} || ${EQ2OgreHarvestMovementTypeAllowed.NotEqual[Resource]} || ${EQ2OgreHarvestResourceID} == 0
			wait 5

		if ${Nav.ForceStopped}
		{
			;echo ${Time}: MoveThread: Nav:Starting..
			Nav:Start
		}

		EQ2OgreHarvestAllowPathing:Set[FALSE]
		call OgreNav "${EQ2OgreHarvestNextLoc}" ${EQ2OgreHarvestX} ${EQ2OgreHarvestY} ${EQ2OgreHarvestZ}
		if ${EQ2OgreHarvestResourceID} > 0
		{
			if ${Nav.OgreNavStatus.Equal[STUCK]}
			{
				EQ2OgreHarvestIgnoreNodes:Set[${EQ2OgreHarvestResourceID},${EQ2OgreHarvestResourceID}]
				EQ2OgreHarvestResourceID:Set[0]
				Nav:Status[Idle]
				OgreNavStuck:Set[0]
				EQ2OgreHarvestNextLoc:Set[None]
			}
			if !${Actor[${EQ2OgreHarvestResourceID}](exists)}
				EQ2OgreHarvestResourceID:Set[0]

			EQ2OgreHarvestMovementTypeAllowed:Set[NONE]
		}		
	}
}
;Need an atom to execute that will stop current movement
atom BreakCurrentMovement()
{
	Nav:Stop
}
function ChangeDefaults()
{
	declarevariable Nav waypointNavigator script
	Nav.DistanceToMoveBackToPath:Set[9999]
	Nav.Precision:Set[2.8]
}

objectdef ModifiedConditionsObject
{
	member:bool Checks()
	{
		if !${b_OB_Paused} && !${Me.IsHated} && ${EQ2OgreHarvestMovementTypeAllowed.Equal[Resource]}
		{
			return TRUE
		}
		else
		{
			;Using a blanket "Else" so if ANY conditions are not met, movement is stopped
			return FALSE
		}
	}
}
objectdef ModifiedInformationObject
{
	method AlreadyThere()
	{
		EQ2OgreHarvestNextLoc:Set[None]
		EQ2OgreHarvestX:Set[0]
		EQ2OgreHarvestY:Set[0]
		EQ2OgreHarvestZ:Set[0]
	}
	method DestNotFound()
	{
		echo EQ2OH: ${Time}: Destination not supplied or found. Where do you want to go?
	}
}