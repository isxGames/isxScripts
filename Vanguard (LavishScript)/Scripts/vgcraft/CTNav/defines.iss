#if CTNAVIGATOR_DEBUGGING
#macro DebugPrint(str)
  Navigator:EchoHUD["str"]
#endmac
#else
#macro DebugPrint(str)
	Navigator:NoEcho["str"]
#endmac
#endif

#if CTNAVIGATOR_TRACE_EXEC
#macro DebugTrace(str)
  Navigator:EchoHUD["Trace: str"]
#endmac
#else
#macro DebugTrace(str)
	Navigator:NoEcho["str"]
#endmac
#endif

#define NAVIGATION_DIRECT 0
#define NAVIGATION_MAP 1
#define NAVIGATION_STUCK 2
#define NAVIGATION_ARRIVED 3

/*************************************************************************************
	The following would need to be redefined for any use of this script in a new game,
	or if Vanguard (or ISXVG) significantly changed the way movement is done.

	-- CyberTech
*************************************************************************************/

#macro Game_MoveForward()
	VG:ExecBinding[movebackward,release]
	VG:ExecBinding[moveforward]
#endmac

#macro Game_MoveBackward()
	VG:ExecBinding[moveforward,release]
	VG:ExecBinding[movebackward]
#endmac

/** Turning **/
#macro Game_TurnLeft()
	VG:ExecBinding[turnright,release]
	VG:ExecBinding[turnleft]
#endmac

#macro Game_TurnRight()
	VG:ExecBinding[turnleft,release]
	VG:ExecBinding[turnright]
#endmac

#macro Game_StopTurning()
	VG:ExecBinding[turnleft,release]
	VG:ExecBinding[turnright,release]
#endmac

/** Strafing **/
#macro Game_StrafeLeft()
	VG:ExecBinding[straferight,release]
	VG:ExecBinding[strafeleft]
#endmac

#macro Game_StrafeRight()
	VG:ExecBinding[strafeleft,release]
	VG:ExecBinding[straferight]
#endmac

#macro Game_StopStrafing()
	VG:ExecBinding[strafeleft,release]
	VG:ExecBinding[straferight,release]
#endmac

#macro Game_StopMoving()
	VG:ExecBinding[moveforward,release]
	VG:ExecBinding[movebackward,release]
	VG:ExecBinding[turnleft,release]
	VG:ExecBinding[turnright,release]
	VG:ExecBinding[strafeleft,release]
	VG:ExecBinding[straferight,release]
#endmac

#macro Game_UseDoor()
	VG:ExecBinding[UseDoorEtc]
#endmac