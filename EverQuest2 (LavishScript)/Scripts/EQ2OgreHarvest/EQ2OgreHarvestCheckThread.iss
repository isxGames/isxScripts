;***************OgreCheck for EQ2OgreHarvest Version 1.00**************
#include OgreNav_Lib_ModifiedForEQ2OgreHarvestCheck.inc
function main(string Location, float X, float Y, float Z)
{
	call ChangeDefaults
	declarevariable ConditionsOb ModifiedConditionsObject script
	declarevariable InformationOb ModifiedInformationObject script

	while ${Script[EQ2OgreHarvestMain](exists)}
	{
		;If it does not equal "Checking" we don't have to check anything...
		while !${EQ2OgreHarvestCheckResourceStatus.Equal[Checking]}
			wait 2
			
		;echo "(${Time}) CheckThread:: Moving to ${EQ2OgreHarvestCheckResourceX} ${EQ2OgreHarvestCheckResourceY} ${EQ2OgreHarvestCheckResourceZ}"
		call OgreNav "Loc" ${EQ2OgreHarvestCheckResourceX} ${EQ2OgreHarvestCheckResourceY} ${EQ2OgreHarvestCheckResourceZ}
		if ${Return}
			EQ2OgreHarvestCheckResourceStatus:Set[Valid]
		else
			EQ2OgreHarvestCheckResourceStatus:Set[Invalid]
	}

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
		if !${Paused} && ${AllowAH} && !${Me.IsHated}
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