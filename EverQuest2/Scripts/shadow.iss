;-----------------------------------------------------------------------------------------------
;shadow.iss
;by pygar
;usage: run shadow <actorName> <distance>
;example: run shadow pygar 3
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
#define QUIT f7

function main(string ShadowTarget, float srange)
{
	squelch bind quit "QUIT" 	FollowTask:Set[1]
	sTarget:Set[ShadowTarget]

	do
	{
		while ${Actor[${ShadowTarget}](exists)} && !${Actor[${ShadowTarget}].IsDead}
		{
			if ${Actor[${ShadowTarget}].Distance}>${srange}
			{
				Script[EQ2Bot]:Pause
				call FastMove ${Actor[${ShadowTarget}].ID} ${srange}
				Script[EQ2Bot]:Resume
			}
			waitframe
		}

	}
	while ${FollowTask}
}

function FastMove(uint sTarget, float range)
{
	variable float xDist
	variable float SavDist=${Math.Distance[${Me.X},${Me.Z},${Actor[${sTarget}].X},${Actor[${sTarget}].Z}]}
	variable int xTimer

	if ${range}<3
		range:Set[3]

	if ${Math.Distance[${Me.X},${Me.Z},${Actor[${sTarget}].X},${Actor[${sTarget}].Z}]}>85
		return "INVALIDLOC"

	face ${Actor[${sTarget}].X} ${Actor[${sTarget}].Z}]}
	press -hold ${forward}
	xTimer:Set[${Script.RunningTime}]

	while ${Math.Distance[${Me.X},${Me.Z},${Actor[${sTarget}].X},${Actor[${sTarget}].Z}]}>${range}
	{
		xDist:Set[${Math.Distance[${Me.X},${Me.Z},${Actor[${sTarget}].X},${Actor[${sTarget}].Z}]}]

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

		face ${Actor[${sTarget}].X} ${Actor[${sTarget}].Z}]}
	}


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