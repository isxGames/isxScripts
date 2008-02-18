;-----------------------------------------------------------------------------------------------
;shadow.iss
;by pygar
;usage: run shadow <actorName> <distance>
;example: run shadow pygar 1
;
;Description:
;Designed to be run in partner with other scripts to force a bot to stay within x range of
;another actor.  This could be a groupmember, raid member, a mob, a npc, etc.  My usage of this
;is to force my ranged bots to adjust to position of a human player I trust to combat epics
;with knockbacks or jousting.
;-----------------------------------------------------------------------------------------------


;===================================================
;===        Keyboard Configuration              ====
;===================================================
variable string forward=w
variable int FollowTask

function main(string ShadowTarget, float srange)
{
	squelch bind quit "QUIT" "FollowTask:Set[0]"
	FollowTask:Set[1]
	Script[EQ2Bot].Variable[NoMovement]:Set[TRUE]
	do
	{
		do
		{
			if ${Actor[${ShadowTarget}].Distance}>${srange}
			{
				call FastMove ${Actor[${ShadowTarget}].X} ${Actor[${ShadowTarget}].Z} ${srange}
			}
			waitframe
		}
		while ${Actor[${ShadowTarget}](exists)} && !${Actor[].IsDead}
	}
	while ${FollowTask}
}

function FastMove(float X, float Z, float range)
{
	variable float xDist
	variable float SavDist=${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}
	variable int xTimer

	if !${X} || !${Z}
	{
		return "INVALIDLOC"
	}

	if ${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}>25
	{
		return "INVALIDLOC"
	}

	face ${X} ${Z}

	press -hold ${forward}


	xTimer:Set[${Script.RunningTime}]

	do
	{
		xDist:Set[${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}]

		if ${Math.Calc[${SavDist}-${xDist}]}<0.8
		{
			if (${Script.RunningTime}-${xTimer})>500
			{
				isstuck:Set[TRUE]
				press -release ${forward}
				wait 20 !${Me.IsMoving}
				return "STUCK"
			}
		}
		else
		{
			xTimer:Set[${Script.RunningTime}]
			SavDist:Set[${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}]
		}

		face ${X} ${Z}
	}
	while ${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}>${range}

	press -release ${forward}
	wait 20 !${Me.IsMoving}

	return "SUCCESS"
}

function atexit()
{
	if ${Me.IsMoving}
	{
		press -release ${forward}
		Script[EQ2Bot].Variable[NoMovement]:Set[FALSE]
	}
}