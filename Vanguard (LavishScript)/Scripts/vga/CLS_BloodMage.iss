;********************************************
function BloodMage_DownTime()
{
	;; This function should only be called outside of combat (ie, 'downtime')\
	call BM_CheckEnergy
	variable bool DoSmallHeal = FALSE
	variable bool OkToCastSpells

	if ${Me.Effect[translucence](exists)}
	OkToCastSpells:Set[FALSE]
	else
	OkToCastSpells:Set[TRUE]

	if (${Me.HealthPct} < 70 && ${Me.EnergyPct} > 70)
	DoSmallHeal:Set[TRUE]
	elseif 	(${Me.HealthPct} < 50 && ${Me.EnergyPct} > 50)
	DoSmallHeal:Set[TRUE]

	if (${DoSmallHeal} && ${OkToCastSpells})
	{
		Me.ToPawn:Target
		waitframe
		call checkabilitytocast "${SmallHeal}"
		if ${Return}
		{
			;echo "BM_DownTime()-Debug:: Casting '${SmallHeal}'"
			call executeability "${SmallHeal}" "Heal" "Neither"
			return
		}
	}

	;-----------------------------------------
	; Replenish our Blood Vials
	;-----------------------------------------
	if ${Me.Inventory[Vial of Blood].Quantity}<3 && ${Me.HealthPct}>90
	{
		;echo "BM_BloodVials()-Debug:: casting Siphon Blood"
		call executeability "Siphon Blood" "NoCheck" "Neither"
	}

}
;********************************************
function BloodMage_PreCombat()
{

}
;********************************************
function BloodMage_Opener()
{

}
;********************************************
function BloodMage_Combat()
{
	;-----------------------------------------
	; Need to convert health to mana
	;-----------------------------------------
	call BM_CheckEnergy

}
;********************************************
function BloodMage_Emergency()
{

}
;********************************************
function BloodMage_PostCombat()
{

}
;********************************************
function BloodMage_PostCasting()
{

}

function BM_PreHealRoutine()
{
	;; This function is called before the primary Healcheck() routine.   The primary Healcheck() routine will be called immediatley after
	;; this.

	/* ==================================================================================== */
	;-------------------------------------------
	;Set our variables
	;-------------------------------------------
	variable int gn
	variable int low
	variable int i


	;-------------------------------------------
	;Find lowest health
	;-------------------------------------------
	if ${Me.IsGrouped}
	{
		gn:Set[0]
		low:Set[100]

		for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
		{
			if ${Group[${i}].Distance}<25 && ${Group[${i}].Health}>0 && ${Group[${i}].Health}<${low}
			{
				gn:Set[${i}]
				low:Set[${Group[${i}].Health}]
			}
		}
	}

	;-------------------------------------------
	; Patch if we are solo
	;-------------------------------------------
	if !${Me.IsGrouped}
	{
		gn:Set[0]
		low:Set[${Me.HealthPct}]
	}

	;-------------------------------------------
	; Let main script heal the wounded, DTarget already set
	;-------------------------------------------
	if ${low}<90
	{
		if ${Me.HealthPct}<70 && !${Me.IsGrouped}
		{
			Pawn[me]:Target
			call checkabilitytocast "${SmallHeal}"
			if ${Return}
			{

				if ${doNonCombatStance} && !${Me.Effect[${NonCombatStance}](exists)}
				{
					Me.Form[${NonCombatStance}]:ChangeTo
				}
				echo "BM_PreHealRoutine()-Debug:: casting ${SmallHeal}"
				call executeability "${SmallHeal}" "Heal" "Neither"
				return
			}
		}

		Pawn[id,${Group[${gn}].ID}]:Target
		return CONTINUE
	}

	;-------------------------------------------
	; Otherwise, LIFETAP lowest health
	;-------------------------------------------
	if (${Me.InCombat} || ${Me.ToPawn.CombatState} == 1)
	{
		if (${Me.Target(exists)} && ${Me.Target.CombatState} != 0 && !${Me.Target.IsDead})
		{

			;-------------------------------------------
			; Change stance to COMBAT to do more damage!
			;-------------------------------------------
			if ${doCombatStance} && !${Me.Effect[${CombatStance}](exists)}
			{
				Me.Form[${CombatStance}]:ChangeTo
			}

			;-------------------------------------------
			; Despoil will LIFETAP self
			;-------------------------------------------
			if ${Me.Ability[${BMSingleTargetLifeTap1}].IsReady} && (!${Me.IsGrouped} || ${Group[${gn}].Name.Equal[${Me.FName}]})
			{
				echo "BM_PreHealRoutine()-Debug:: Casting '${BMSingleTargetLifeTap1}'"
				call executeability "${Me.Ability[${BMSingleTargetLifeTap1}].Name}" "Lifetap" "Neither"
				if !${Group(exists)} && ${Me.HealthPct} > 50
				return HEALSDONE
				else
				return CONTINUE
			}
			;-------------------------------------------
			; Entwining Vein will LIFETAP whomever is your DTarget
			;-------------------------------------------
			elseif (${Me.Ability[${BMSingleTargetLifeTap2}].IsReady})
			{
				Pawn[id,${Group[${gn}].ID}]:Target
				echo "BM_PreHealRoutine()-Debug:: Casting '${BMSingleTargetLifeTap2}'"
				call executeability "${Me.Ability[${BMSingleTargetLifeTap2}].Name}" "Lifetap" "Neither"
				if !${Group(exists)} && ${Me.HealthPct} > 50
				return HEALSDONE
				else
				return CONTINUE
			}
		}
	}
	return CONTINUE
	/* ==================================================================================== */

	;; Solo play
	if !${Group(exists)}
	{
		if (${Me.HealthPct} >= 72)
		return HEALSDONE

		if (${Me.InCombat} || ${Me.ToPawn.CombatState} == 1)
		{
			if (${Me.Target(exists)} && ${Me.Target.CombatState} != 0 && !${Me.Target.IsDead})
			{
				if (${Me.Ability[${BMSingleTargetLifeTap1}].IsReady})
				{
					echo "BM_PreHealRoutine()-Debug:: Casting '${BMSingleTargetLifeTap1}'"
					call executeability "${Me.Ability[${BMSingleTargetLifeTap1}].Name}" "Lifetap" "Neither"
					if !${Group(exists)} && ${Me.HealthPct} > 50
					return HEALSDONE
					else
					return CONTINUE
				}
				elseif (${Me.Ability[${BMSingleTargetLifeTap2}].IsReady})
				{
					echo "BM_PreHealRoutine()-Debug:: Casting '${BMSingleTargetLifeTap2}'"
					call executeability "${Me.Ability[${BMSingleTargetLifeTap2}].Name}" "Lifetap" "Neither"
					if !${Group(exists)} && ${Me.HealthPct} > 50
					return HEALSDONE
					else
					return CONTINUE
				}
			}
		}
	}

	return CONTINUE
}

function BM_CheckBloodUnion()
{
	variable int BloodUnion
	BloodUnion:Set[${Me.BloodUnion}]

	;; For now...
	if ${BloodUnion} < 3
	return


	;; In Combat
	if (${Me.InCombat} || ${Me.ToPawn.CombatState} != 0)
	{
		if (${Me.Target(exists)} && ${Me.Target.CombatState} != 0 && !${Me.Target.IsDead})
		{
			if (${BloodUnion} >= 3)
			{
				if (${Group(exists)} && ${Me.DTarget(exists)} && ${Me.DTargetHealth} < 90)
				{
					if (${Me.Ability[${BMBloodUnionSingleTargetHOT}].IsReady})
					{
						echo "BM_CheckBloodUnion()-Debug:: casting '${BMBloodUnionSingleTargetHOT}'"
						call executeability "${BMBloodUnionSingleTargetHOT}" "Heal" "Neither"
						return
					}
				}

				if (${BloodUnion} >= 4)
				{
					if (${Me.Ability[${BMBloodUnionDumpDPSSpell}].IsReady})
					{
						echo "BM_CheckBloodUnion()-Debug:: casting '${BMBloodUnionDumpDPSSpell}'"
						call executeability "${BMBloodUnionDumpDPSSpell}" "NoCheck" "Neither"
						return
					}
				}
			}
		}
	}

	return
}

function BM_CheckEnergy()
{
	if ${Me.Effect[translucence](exists)}
	return


	if (${Me.EnergyPct} > 80)
	return
	if !${Me.Ability[${BMHealthToEnergySpell}].IsReady}
	return

	if ${Me.HealthPct} > 50
	{
		call executeability "${Me.Ability[${BMHealthToEnergySpell}].Name}" "utility" "Neither"
		return
	}
	if ${Me.EnergyPct} < 50 && ${Me.HealthPct} > 35
	{
		call executeability "${Me.Ability[${BMHealthToEnergySpell}].Name}" "utility" "Neither"
		return
	}
	;; TODO -- Make the final value in this next line UI settable (ie, "Never cast if health is lower than: xxx")
	if ${Me.EnergyPct} < 20 && ${Me.Health} > 300
	{
		call executeability "${Me.Ability[${BMHealthToEnergySpell}].Name}" "utility" "Neither"
		return
	}

}
function BM_Burst()
{
	DoBurstNow:Set[FALSE]

}


