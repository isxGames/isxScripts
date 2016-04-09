variable bool RangerRunOnce = TRUE
variable int NextRangerCheck = ${Script.RunningTime}
function Ranger()
{
	;; return if your class is not a Bard
	if !${Me.Class.Equal[Ranger]}
		return

	;; forces this only to run once every .2 seconds
	if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextRangerCheck}]}/100]}<2
	{
		return
	}
	NextRangerCheck:Set[${Script.RunningTime}]

	
	;; we only want to run this once
	if ${RangerRunOnce}
	{
		;; show the Bard tab in UI
		UIElement[Ranger@Class@DPS@Tools]:Show

		; Calculate Highest Level
		declare "Windsong" string local "Windsong"
		declare "Rancor" string local "Rancor"
		declare "DeadlyShot" string local "Deadly Shot"
		declare "ShockingArrow" string local "Shocking Arrow"
		declare "CriticalShot" string local "Critical Shot"
		RangerRunOnce:Set[FALSE]
	}
	
	if ${Me.Target(exists)} && !${Me.Target.IsDead} && ${Me.Target.Distance}>5 && ${Me.TargetHealth}<=${StartAttack}
	{
		call UseAbility "${DeadlyShot}"
		call UseAbility "${DeadlyShot}"
		call UseAbility "${ShockingArrow}"
		call UseAbility "${CriticalShot}"
	}
	
	;; use any crits
	call RangerCrits

}	
	
	
	
;===================================================
;===       CRIT/FINISH SUB-ROUTINE              ====
;===================================================
function RangerCrits()
{
	if ${Me.Target(exists)} && ${Me.InCombat} && ${Me.Target.Distance}<25 && ${Me.EndurancePct}>=10
	{
		;; return if no crits
		if ${Me.Ability[${Windsong}].TriggeredCountdown}==0 && ${Me.Ability[${Rancor}].TriggeredCountdown}==0
		{
			return
		}

		;; FINISHER - Flurry of melee attacks
		call OkayToAttack "${Windsong}"
		if ${Return} && ${Me.Ability[${Windsong}].IsReady} && ${Me.Ability[${Windsong}].TimeRemaining}==0
		{
			Me.Ability[${Windsong}]:Use
			call GlobalCooldown
		}

		;; COUNTERATTACK
		call OkayToAttack "${Rancor}"
		if ${Return} && ${Me.Ability[${Rancor}].IsReady} && ${Me.Ability[${Rancor}].TimeRemaining}==0
		{
			Me.Ability[${Rancor}]:Use
			call GlobalCooldown
		}
	}
}
	
