/*
	CTNavigator startup script
	
	Consists of:
		AutoMapper
		Navigator
		CollisionMath
		FaceClass
	
	-- CyberTech (cybertech@gmail.com)
	
*/

#define CTNAVIGATOR_DEBUGGING 0
#define CTNAVIGATOR_TRACE_EXEC 0

#include defines.iss
#include obj_CollisionMath.iss
#include obj_AutoMapper.iss
#include obj_FaceClass.iss
#include obj_Navigator.iss

variable(global) obj_Navigator Navigator

function main()
{
	if !${ISXVG.IsReady}
	{
		echo "ISXVG Not Ready..."
		Script:End
	}

	do
		{
			waitframe
		}
	while 1
}
