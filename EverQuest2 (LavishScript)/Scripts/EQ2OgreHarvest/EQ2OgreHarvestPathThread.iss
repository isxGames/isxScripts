;***************OgreMove for EQ2OgreHarvest Version 1.00**************

#include "${LavishScript.HomeDirectory}/Scripts/EQ2OgreCommon/OgreNav_Lib.inc"

variable bool PathPointCompleted=FALSE
variable int PathPointNumber=1
function main(string Location, float X, float Y, float Z)
{
	call ChangeDefaults
	declarevariable ConditionsOb ModifiedConditionsObject script
	declarevariable InformationOb ModifiedInformationObject script

	variable int xx
	while ${Script[EQ2OgreHarvestMain](exists)} && !${EQ2OgreHarvestStop}
	{
		while !${EQ2OgreHarvestAllowPathing} || !${UIElement[${ChkBoxPathModeID}].Checked} || !${UIElement[${LstBoxOHNavPathsID}].Items} || ${EQ2OgreHarvestMovementTypeAllowed.NotEqual[Path]}
			wait 5

		if ${Nav.ForceStopped}
		{
			echo ${Time}: Nav:Starting..
			Nav:Start
		}

		call OgreNav "${UIElement[${LstBoxOHNavPathsID}].Item[${PathPointNumber}]}"

		if ${Nav.OgreNavStatus.Equal[STUCK]}
		{
			echo EQ2OgreHarvestPathThread reporting we are stuck
			UIElement[${CmdOHEndID}]:LeftClick
			wait 10
			;Short wait to allow the ending of the script to happen
		}
		if ${PathPointCompleted}
		{
			PathPointCompleted:Set[FALSE]
			PathPointNumber:Inc
		}
		;if PathPointNumber is > Listbox.Items and Loop path is checked, then reset PathPointNumber to 1, otherwise, end OgreHarvest
		if ${PathPointNumber} > ${UIElement[${LstBoxOHNavPathsID}].Items}
		{
			if ${UIElement[${ChkBoxLoopPathModeID}].Checked}
				PathPointNumber:Set[1]
			else
				UIElement[${CmdOHEndID}]:LeftClick
		}
		;wait 10
	}
}
;Need an atom to execute that will stop current movement
atom BreakCurrentMovement()
{
	Nav:Stop
}
atom BreakCurrentMovementRoutine()
{
	Nav:StopRoutineOnlyNotMovement
}
function ChangeDefaults()
{
	declarevariable Nav waypointNavigator script
	Nav.DistanceToMoveBackToPath:Set[9999]
}

objectdef ModifiedConditionsObject
{
	member:bool Checks()
	{
		if !${b_OB_Paused} && !${Me.IsHated} && ${EQ2OgreHarvestAllowPathing} && ${EQ2OgreHarvestMovementTypeAllowed.Equal[Path]}
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
		PathPointCompleted:Set[TRUE]
	}
	method DestNotFound()
	{
		echo EQ2OH: ${Time}: Destination not supplied or found. Where do you want to go?
	}
}