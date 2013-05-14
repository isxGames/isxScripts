variable bool WarriorRunOnce = TRUE
variable int NextWarriorCheck = ${Script.RunningTime}

variable bool doHate = FALSE

function Warrior()
{
	if !${Me.Class.Equal[Warrior]}
		return
	
	;; we only want to run this once
	if ${WarriorRunOnce}
	{
		UIElement[WarriorRunOnce@Class@DPS@Tools]:Show
		WarriorRunOnce:Set[FALSE]
		
		SetHighestAbility "Protect" "Protect"
		SetHighestAbility "StingingCut" "Stinging Cut"
		SetHighestAbility "Taunt" "Taunt"
		SetHighestAbility "InfuriatingShot" "Infuriating Shot"
		SetHighestAbility "ShoutofDefiance" "Shout of Defiance"
		SetHighestAbility "SavageCut" "Savage Cut"


	}

	;call ReadyCheck	

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Group Healing
	if ${Me.IsGrouped}
	{
		if ${Me.Encounter}>0
		{
			;;always grab encounters on any group members
			for ( i:Set[1] ; ${i}<=${Me.Encounter} ; i:Inc )
			{
				if !${Me.Encounter[${i}].Target.Find[${Me.FName}]} && !${Me.FName.Equal[${Me.ToT}]} && ${Me.Encounter[${i}].Health}>0
				{
					EchoIt "Grabbing: ${Me.Encounter[${i}].Name} who's on ${Me.Encounter[${i}].Target}"

					VGExecute /cleartargets
					wait 1
					Pawn[ID,${Me.Encounter[${i}].ID}]:Target
					wait 3

					Me.Target:Face
					break
				}
			}
		}

		if ${Me.Target(exists)} && ${Me.ToT(exists)}
		{
			;;adds Hate
			if ${doHate} && !${Me.Target.IsDead} && !${Me.ToT.Name.Find[${Me.FName}]} && !${Me.TargetBuff["Immunity: Force Target"](exists)}
			{
				echo InfuriatingShot1
				VGExecute /assistoffensive
				wait 2
				call ReadyCheck	
				if ${Me.DTarget.Name(exists)} && ${Me.Ability[${InfuriatingShot}].IsReady}
				{
					echo InfuriatingShot2
					call UseAbility "${InfuriatingShot}"
					return
				}
			}
			;; force taunt for 4 seconds, 10m, cooldown 12s
			if !${Me.Target.IsDead} && !${Me.ToT.Name.Find[${Me.FName}]} && !${Me.TargetBuff["Immunity: Force Target"](exists)}
			{
				echo Protect1
				VGExecute /assistoffensive
				wait 2
				call ReadyCheck	
				if ${Me.DTarget.Name(exists)} && ${Me.Ability[${Protect}].IsReady}
				{
					echo Protect2
					call UseAbility "${Protect}"
					return
				}
			}
			;; force taunt for 6 seconds, 25m, cooldown 1 minute
			if ${doHate} && !${Me.Target.IsDead} && !${Me.ToT.Name.Find[${Me.FName}]} && !${Me.TargetBuff["Immunity: Force Target"](exists)}
			{
				VGExecute /assistoffensive
				wait 2
				call ReadyCheck	
				if ${Me.DTarget.Name(exists)} && ${Me.Ability[${ShoutofDefiance}].IsReady}
				{
					call UseAbility "${ShoutofDefiance}"
					return
				}
			}
			if ${doHate} && ${Me.Target.Distance}<5
			{
				;; crit that adds hate over 16 seconds
				if ${Me.Ability[${StingingCut}].TriggeredCountdown}>0 && ${Me.Ability[${StingingCut}].EnduranceCost}<${Me.Endurance}
				{
					call ReadyCheck	
					call UseAbility "${StingingCut}"
				}
				;; These will always adds Hate
				call UseAbility "${SavageCut}"
				call UseAbility "${Taunt}"
			}
		}
	}
}