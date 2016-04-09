variable bool WarriorRunOnce = TRUE
variable int NextWarriorCheck = ${Script.RunningTime}

function Warrior()
{
	if !${Me.Class.Equal[Warrior]}
		return
	
	;; we only want to run this once
	if ${WarriorRunOnce}
	{
		UIElement[Warrior@Class@DPS@Tools]:Show
		WarriorRunOnce:Set[FALSE]

		declare "Protect" string local "Protect"
		declare "Stinging Cut" string local "Protect"
		declare "Taunt" string local "Taunt"
		declare "InfuriatingShot" string local "Infuriating Shot"
		declare "ShoutofDefiance" string local "Shout of Defiance"
		declare "SavageCut" string local "Savage Cut"
	}
}