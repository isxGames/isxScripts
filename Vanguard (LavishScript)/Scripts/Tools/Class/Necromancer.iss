variable bool NecroRunOnce = TRUE
variable int NextNecroCheck = ${Script.RunningTime}
variable int AbominationStartAttack = 99
variable string AbominationName = "Stinky"
variable bool doSummonAbomination = FALSE
variable bool doNecropsy = FALSE
function Necromancer()
{
	;; return if your class is not a Bard
	if !${Me.Class.Equal[Necromancer]}
	{
		return
	}
	
	;; we only want to run this once
	if ${NecroRunOnce}
	{
		;; show the Bard tab in UI
		UIElement[Necromancer@Class@DPS@Tools]:Show
		
		; Calculate Highest Level
		SetHighestAbility "AwakenAbomination" "Awaken Abomination"
		SetHighestAbility "BloodRite" "Blood Rite"
		SetHighestAbility "BoneSpike" "Bone Spike"
		SetHighestAbility "CripplingBlight" "Crippling Blight"
		SetHighestAbility "Torment" "Torment"
		SetHighestAbility "VileRitual" "Vile Ritual"
		;; Crits
		SetHighestAbility "SealedFate" "Sealed Fate"
		SetHighestAbility "BoneChill" "Bone Chill"
		NecroRunOnce:Set[FALSE]
	}
	
	;; Name your pet
	if ${Me.Pet(exists)}
	{
		if ${Me.Pet.Name.Length}>1 && ${AbominationName.Length}>1 && !${Me.Pet.Name.Equal["${AbominationName}"]}
		{
			VGExecute /petname "${AbominationName}"
		}
	}
	
	
	;; toggle on/off our energy regen
	if ${Me.HealthPct}<50 || ${Me.EnergyPct}>90
	{
		if ${Me.Effect[Transmogrify](exists)}
		{
			Call UseAbility "Transmogrify"
		}
	}
	else
	{
		if !${Me.Effect[Transmogrify](exists)}
		{
			Call UseAbility "Transmogrify"
		}
	}
	
	;; get next encounter
	if ${Me.Encounter}>0
	{
		if !${Me.Target(exists)} || ${Me.Target.IsDead}
		{
			Pawn[id,${Me.Encounter[1].ID}]:Target
			wait 5 
			if ${Me.HavePet}
			{
				VGExecute /pet Attack
				return
			}
		}
	}

	if !${Me.InCombat}
	{
		;; go summon your pet
		if ${doSummonAbomination} && !${Me.HavePet} && !${Pawn[exactname,${AbominationName}](exists)} && ${Me.Encounter}==0
		{
			if !${Pawn[Me].IsMounted}
			{
				call UseAbility "${AwakenAbomination}"
				wait 10
			}
		}
		
		if ${Me.Target(exists)}
		{
			;; Go Loot the corpse if it is close
			if ${Me.Target.IsDead} && ${Me.Target.Distance}<5
			{
				wait 5 ${Me.Target.ContainsLoot}
				if ${Me.Target.ContainsLoot}
				{
					Loot:BeginLooting
					wait 5 ${Me.IsLooting} && ${Loot.NumItems}
					Loot:LootAll
					wait 2
					if ${Me.IsLooting}
					{
						Loot:EndLooting
					}
				}
				if ${doNecropsy} && ${Me.Encounter}==0
				{
					;; must wait else Necropsy will get nothing
					wait 10
					wait 10 !${VG.InGlobalRecovery} && ${Me.Ability["Torch"].IsReady} && !${Me.IsCasting}
					if !${Me.Target(exists)}
					{
						Pawn[Corpse]:Target
						wait 5
					}
					call UseAbility "Necropsy"
					if ${Me.IsLooting}
					{
						vgecho "Looted after Necropsy"
						Loot:LootAll
						wait 2
						if ${Me.IsLooting}
						{
							Loot:EndLooting
						}
					}
					if ${Me.Target.ContainsLoot}
					{
						Loot:BeginLooting
						wait 5 ${Me.IsLooting} && ${Loot.NumItems}
						Loot:LootAll
						wait 2
						if ${Me.IsLooting}
						{
							Loot:EndLooting
						}
					}
				}
				VGExecute /cleartargets
				wait 5
			}
		}
	}

	if ${Me.InCombat}
	{
		if ${Me.HavePet} && ${Pawn[${AbominationName}].CombatState}==0
		{
			if ${Me.Target(exists)}
			{
				VGExecute /pet Attack
			}
			else
			{
				VGExecute /pet Guard
			}
			wait 3
		}
		if !${Me.DTarget.Name.Equal[${AbominationName}]}
		{
			Pawn[${AbominationName}]:Target
			wait 3
		}
		if ${Me.DTarget.Name.Equal[${AbominationName}]}
		{
			;; Heal Pet
			if ${Me.HealthPct}>50 && ${Me.DTargetHealth}<50
			{
				call UseAbility "${BloodRite}"
			}
		}
	}

	;; This forces the pet to attack
	if ${Me.Target(exists)} && !${Me.Target.IsDead} && ${Me.Target.Distance}>5 && (${Me.Target.Type.Equal[NPC]} || ${Me.Target.Type.Equal[AggroNPC]}) && ${Me.TargetHealth}<=${AbominationStartAttack} && ${Me.TargetHealth}>0
	{
		if ${Me.HavePet} && ${Pawn[${AbominationName}].CombatState}==0
		{
			VGExecute /pet Attack
			wait 5
		}
	}
	
	;; use any crits
	call NecroCrits
}	
	
	
	
;===================================================
;===       CRIT/FINISH SUB-ROUTINE              ====
;===================================================
function NecroCrits()
{
	;; scan all encounters and target the one on me
	if ${Me.Encounter} && ${Me.HavePet}
	{
		for ( i:Set[1] ; ${i}<=${Me.Encounter} ; i:Inc )
		{
			if ${Me.FName.Find[${Me.Encounter[${i}].Target}]}
			{
				Pawn[id,${Me.Encounter[${i}].ID}]:Target
				wait 3
				if ${Me.HavePet}
				{
					VGExecute /pet Attack
					wait 3
				}
				break
			}
		}
	}
	
	if ${Me.Target(exists)} && ${Me.InCombat}
	{
		;; tell your pet to build aggro
		if ${Me.HavePet} && ${Pawn[${AbominationName}].CombatState}>0 
		{
			if ${Me.Pet.Ability[Sneer].IsReady}
			{
				VGExecute /pet Attack
				wait 3
				Me.Pet.Ability[Sneer]:Use
				wait 3
			}
		}
	
		;; return if no crits
		if ${Me.Ability[${SealedFate}].TriggeredCountdown}==0 && ${Me.Ability[${BoneChill}].TriggeredCountdown}==0
		{
			return
		}

		;; PHYSICAL FINISHER - A devistating DOT
		call OkayToAttack "${SealedFate}"
		if ${Return} && ${Me.Ability[${SealedFate}].IsReady} && ${Me.Ability[${SealedFate}].TimeRemaining}==0
		{
			Me.Ability[${SealedFate}]:Use
			call GlobalCooldown
		}

		;; COLD FINISHER - Instant crit
		call OkayToAttack "${BoneChill}"
		if ${Return} && ${Me.Ability[${BoneChill}].IsReady} && ${Me.Ability[${BoneChill}].TimeRemaining}==0
		{
			Me.Ability[${BoneChill}]:Use
			call GlobalCooldown
		}
	}
}
	
