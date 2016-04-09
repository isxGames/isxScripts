variable bool ClericRunOnce = TRUE
variable int NextClericCheck = ${Script.RunningTime}
function Cleric()
{
	;; return if your class is not a Bard
	if !${Me.Class.Equal[Cleric]}
		return
	
	;; we only want to run this once
	if ${ClericRunOnce}
	{
		;; show the Cleric tab in UI
		UIElement[Cleric@Class@DPS@Tools]:Show
		ClericRunOnce:Set[FALSE]
		
		
		declare "Alleviate" string local "Alleviate"
		declare "HealingTouch" string local "Healing Touch"
		declare "Rejuvenate" string local "Rejuvenate"
		declare "Pacify" string local "Pacify"
		
	}
	
	if ${Me.Target(exists)} && ${Me.ToT(exists)}
	{
		if !${Me.Target.IsDead} && ${Me.ToT.Name.Find[${Me.FName}]}
			call UseAbility "${Pacify}"			
	}
}