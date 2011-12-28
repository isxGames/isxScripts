
variable bool SorcRunOnce = TRUE
variable int NextSorcCheck = ${Script.RunningTime}
variable int NextSorcLocCheck = ${Script.RunningTime}
variable point3f SorcLocation = ${Me.Location}
function Sorcerer()
{
	;; forces this only to run once every .2 seconds
	if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextSorcCheck}]}/100]}<2
	{
		return
	}
	NextSorcCheck:Set[${Script.RunningTime}]

	;; return if your class is not a Bard
	if !${Me.Class.Equal[Sorcerer]}
	{
		return
	}
	
	;; we only want to run this once
	if ${SorcRunOnce}
	{
		;; show the Bard tab in UI
		UIElement[Sorcerer@Class@DPS@Tools]:Show
		
		; Calculate Highest Level
		SetHighestAbility "Incinerate" "Incinerate"
		SetHighestAbility "Mimic" "Mimic"
		SorcRunOnce:Set[FALSE]
	}
	
	;; use any crits
	call SorcCrits
	
	
	if ${Math.Distance[${Me.Location},${SorcLocation}]}>25
	{
		NextSorcLocCheck:Set[${Script.RunningTime}]
		SorcLocation:Set[${Me.Location}]
	}
	if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextSorcLocCheck}]}/1000]}>4
	{
		if !${Me.InCombat} && ${Me.Ability[Gather Energy].IsReady} && ${Me.EnergyPct}<=40
		{
			vgecho "Gathering Energy"
			call UseAbility "Gather Energy"
			wait 180
			return
		}
	}

	;if ${Me.Target(exists)} && !${Me.InCombat} && ${Me.Target.Distance}<25 && ${Me.EnergyPct}>=20 && ${Me.TargetHealth}<=${StartAttack}
	;{
	;	call UseAbilities
	;}
}	
	
	
	
;===================================================
;===       CRIT/FINISH SUB-ROUTINE              ====
;===================================================
function SorcCrits()
{
	;; return if no crits
	if ${Me.Ability[${Incinerate}].TriggeredCountdown}==0 && ${Me.Ability[${Mimic}].TriggeredCountdown}==0
	{
		return
	}
	

	;; FIRE CRIT
	if ${Me.Ability[${Incinerate}].IsReady} && ${Me.Ability[${Incinerate}].TimeRemaining}==0
	{
		Me.Ability[${Incinerate}]:Use
		call GlobalCooldown
	}

	;; ARCANE CRIT
	if ${Me.Ability[${Mimic}].IsReady} && ${Me.Ability[${Mimic}].TimeRemaining}==0
	{
		Me.Ability[${Mimic}]:Use
		call GlobalCooldown
	}
}
	
