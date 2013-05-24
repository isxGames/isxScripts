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
		
		SetHighestAbility "Protect" "Protect"
		SetHighestAbility "StingingCut" "Stinging Cut"
		SetHighestAbility "Taunt" "Taunt"
		SetHighestAbility "InfuriatingShot" "Infuriating Shot"
		SetHighestAbility "ShoutofDefiance" "Shout of Defiance"
		SetHighestAbility "SavageCut" "Savage Cut"


	}

	;call ReadyCheck	

}