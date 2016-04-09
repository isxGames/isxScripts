;***************OgreMove for EQ2OgreBot: Version 1.00****************
;**Handles moving to 1 location.**
#include OgreNav_Lib.inc

function main(string Location, int X, int Y, int Z)
{
	call ChangeDefaults
	declarevariable Conditions ModifiedConditionsObject script

	call OgreNav "${Location}" ${X} ${Y} ${Z}
}

function ChangeDefaults()
{
	declarevariable Nav waypointNavigator script
	Nav.TargetRequired:Set[TRUE]
	Nav.Precision:Set[2]
}