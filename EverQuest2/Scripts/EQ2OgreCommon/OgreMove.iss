;***************OgreMove for EQ2OgreBot: Version 1.01****************
;**Handles moving to 1 location.**
#include OgreNav_Lib.inc

function main(string Location, float X, float Y, float Z)
{
	call ChangeDefaults
	declarevariable Conditions ModifiedConditionsObject script

	if ${Location.Equal[list]}
		Nav:List
	else
	{
		;// echo 	call OgreNav "${Location}" ${X} ${Y} ${Z}
		call OgreNav "${Location}" ${X} ${Y} ${Z}
	}
}

function ChangeDefaults()
{
	declarevariable Nav waypointNavigator script
	Nav.TargetRequired:Set[TRUE]
	Nav.Precision:Set[1.5]
	Nav.PrecisionToDestination:Set[1.5]
}