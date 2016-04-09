#define ALARM "${Script.CurrentDirectory}/Sounds/ping.wav"


;===================================================
;===            USE ABILITY                     ====
;===================================================
function UseAbility(string ABILITY)
{
	if !${Me.Ability[${ABILITY}].IsReady}
		return
	if ${Me.ToPawn.IsStunned}
		return
	if !${Me.Ability[${ABILITY}](exists)}
		return
	if ${Me.Effect[${ABILITY}](exists)}
		return
	if ${Me.Ability[${ABILITY}].LevelGranted}>${Me.Level}
		return
	if ${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.Ability[${ABILITY}].EnergyCost}>${Me.Energy}
		return
	if ${Me.Ability[${ABILITY}].EnduranceCost(exists)} && ${Me.Ability[${ABILITY}].EnduranceCost}>${Me.Endurance}
		return
	if (!${Me.Target(exists)} || ${Me.Target.IsDead}) && (${Me.Ability[${ABILITY}].TargetType.Equal[Offensive]} || ${Me.Ability[${ABILITY}].IsOffensive})
		return
	if ${Me.TargetMyDebuff[${ABILITY}](exists)}
		return
	if ${Pawn[me].IsMounted}
		return
		
	;; return if we do not want to use any of these abilities
	if ${Me.Ability[${ABILITY}].IsOffensive}
	{
		;; check these 
		if !${doPhysical} && ${Me.Ability[${ABILITY}].School.Find[Physical]}
			return
		if !${doSpiritual} && ${Me.Ability[${ABILITY}].School.Find[Spiritual]}
			return
		if !${doCold} && ${Me.Ability[${ABILITY}].School.Find[Cold]}
			return
		if !${doMelee} && ${Me.Ability[${ABILITY}].Type.Equal[Combat Art]}
			return
		if !${doRangedAttack} && ${Me.Ability[${ABILITY}].Type.Equal[Ranged Attack]}
			return
		if !${doSpell} && ${Me.Ability[${ABILITY}].Type.Equal[Spell]}
			return

		;; Check mob immunities and TargetBuffs
		call OkayToAttack "${ABILITY}"
		if !${Return}
		{
			;vgecho "NotOkayToAttack=${ABILITY}"
			
			call MeleeAttackOff
			if ${Me.HavePet}
				VGExecute "/pet backoff"			
			return
		}

		;; Melee Form
		if ${Me.Ability[${ABILITY}].Type.Equal[Combat Art]} && !${Me.CurrentForm.Name.Equal[${MeleeForm}]}
		{
			Me.Form[${MeleeForm}]:ChangeTo
			wait 3
		}
		;; Extra Spell Damage Form
		if ${Me.Ability[${ABILITY}].Type.Equal[Spell]} && !${Me.CurrentForm.Name.Equal[${SpellForm}]}
		{
			Me.Form[${SpellForm}]:ChangeTo
			wait 3
		}
	}

	;; Extra Healing Form
	if !${Me.Ability[${ABILITY}].IsOffensive} && !${Me.CurrentForm.Name.Equal[${HealingForm}]}
	{
		Me.Form[${HealingForm}]:ChangeTo
		wait 3
	}

	
	if ${Me.Ability[${ABILITY}].IsReady}
	{
		Me.Ability[${ABILITY}]:Use
		EchoIt "UseAbility: ${ABILITY}"
		wait 7
		if !${Me.Ability[${ABILITY}].IsReady}
			ExecutedAbility:Set[${ABILITY}]
	}
}

;===================================================
;===            CAST NOW ABILITY                ====
;===================================================
function CastNow(string ABILITY)
{
	if !${Me.Ability[${ABILITY}].IsReady}
		return
	if ${Me.ToPawn.IsStunned}
		return
	if !${Me.Ability[${ABILITY}](exists)}
		return
	if ${Me.Ability[${ABILITY}].LevelGranted}>${Me.Level}
		return
	if ${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.Ability[${ABILITY}].EnergyCost}>${Me.Energy}
		return
	if ${Me.Ability[${ABILITY}].EnduranceCost(exists)} && ${Me.Ability[${ABILITY}].EnduranceCost}>${Me.Endurance}
		return
	if ${Pawn[me].IsMounted}
		return

	;; return if we do not want to use any of these abilities
	if ${Me.Ability[${ABILITY}].IsOffensive}
	{
		;; check these 
		if ${Me.TargetMyDebuff[${ABILITY}](exists)}
			return
		if !${doPhysical} && ${Me.Ability[${ABILITY}].School.Find[Physical]}
			return
		if !${doSpiritual} && ${Me.Ability[${ABILITY}].School.Find[Spiritual]}
			return
		if !${doCold} && ${Me.Ability[${ABILITY}].School.Find[Cold]}
			return

		call OkayToAttack "${ABILITY}"
		if !${Return}
		{
			;vgecho "NotOkayToAttack=${ABILITY}"
			
			call MeleeAttackOff
			if ${Me.HavePet}
				VGExecute "/pet backoff"			
			return
		}

	}

	;; Extra Healing Form
	if !${Me.Ability[${ABILITY}].IsOffensive} && !${Me.CurrentForm.Name.Equal[${HealingForm}]}
	{
		Me.Form[${HealingForm}]:ChangeTo
		wait 3
	}
	
	if ${Me.Ability[${ABILITY}].IsReady}
	{
		Me.Ability[${ABILITY}]:Use
		EchoIt "UseAbility: ${ABILITY}"
		wait 7
		if !${Me.Ability[${ABILITY}].IsReady}
			ExecutedAbility:Set[${ABILITY}]
	}
}

;===================================================
;===       USE ABILITY ON SELF                  ====
;===================================================
function UseAbilitySelf(string ABILITY)
{
	if !${Me.Ability[${ABILITY}].IsReady}
		return
	if ${Me.ToPawn.IsStunned}
		return
	if !${Me.Ability[${ABILITY}](exists)}
		return
	if ${Me.Effect[${ABILITY}](exists)}
		return
	if ${Me.TargetMyDebuff[${ABILITY}](exists)}
		return
	if ${Me.Ability[${ABILITY}].LevelGranted}>${Me.Level}
		return
	if ${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.Ability[${ABILITY}].EnergyCost}>${Me.Energy}
		return
	if ${Me.Ability[${ABILITY}].EnduranceCost(exists)} && ${Me.Ability[${ABILITY}].EnduranceCost}>${Me.Endurance}
		return
	 if ${Pawn[me].IsMounted}
		return
	if !${Me.DTarget.Name.Equal[${Me.FName}]}
	{
		Pawn[Me]:Target
		waitframe
	}

	VGExecute /stand

	if ${Me.Ability[${ABILITY}].IsReady}
	{
		Me.Ability[${ABILITY}]:Use
		EchoIt "UseAbilitySelf: ${ABILITY}"
		wait 5
		if !${Me.Ability[${ABILITY}].IsReady}
			ExecutedAbility:Set[${ABILITY}]
	}
}

;===================================================
;===       USE ABILITY ON OTHER                 ====
;===================================================
function UseAbilityOther(int GroupNumber, string ABILITY)
{
	if !${Me.Ability[${ABILITY}].IsReady}
		return
	if ${Me.ToPawn.IsStunned}
		return
	if !${Me.Ability[${ABILITY}](exists)}
		return
	if ${Me.Effect[${ABILITY}](exists)}
		return
	if ${Me.TargetMyDebuff[${ABILITY}](exists)}
		return
	if ${Me.Ability[${ABILITY}].LevelGranted}>${Me.Level}
		return
	if ${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.Ability[${ABILITY}].EnergyCost}>${Me.Energy}
		return
	if ${Me.Ability[${ABILITY}].EnduranceCost(exists)} && ${Me.Ability[${ABILITY}].EnduranceCost}>${Me.Endurance}
		return
	 if ${Pawn[me].IsMounted}
		return
		
	if ${GroupNumber}
	{
		Pawn[id,${Group[${GroupNumber}].ID}]:Target
		waitframe
	}

	VGExecute /stand

	if ${Me.Ability[${ABILITY}].IsReady}
	{
		Me.Ability[${ABILITY}]:Use
		EchoIt "UseAbilitySelf: ${ABILITY}"
		wait 5
		if !${Me.Ability[${ABILITY}].IsReady}
			ExecutedAbility:Set[${ABILITY}]
	}
}

;===================================================
;===           USE PET ABILITY                  ====
;===================================================
function UsePetAbility(string ABILITY)
{
	if !${Me.Pet.Ability[${ABILITY}].IsReady}
		return

	VGExecute /stand

	call OkayToAttack
	if !${Return}
	{
		call MeleeAttackOff
		if ${Me.HavePet}
			VGExecute "/pet backoff"			
		return
	}
	
	Me.Pet.Ability[${ABILITY}]:Use
	EchoIt "UsePetAbility: ${ABILITY}"
	wait 5
	if !${Me.Pet.Ability[${ABILITY}].IsReady}
		ExecutedAbility:Set[${ABILITY}]
}


;===================================================
;===            SUMMON PET                      ====
;===================================================
function SummonPet(string ABILITY)
{
	if ${Me.Pet(exists)}
	{
		if !${doSummonPets}
			VGExecute /pet dismiss
			wait 3
		return
	}
	if !${doSummonPets}
		return
	if !${Me.Ability[${ABILITY}].IsReady}
		return
	if ${Me.ToPawn.IsStunned}
		return
	if !${Me.Ability[${ABILITY}](exists)}
		return
	if ${Me.Ability[${ABILITY}].LevelGranted}>${Me.Level}
		return
	if ${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.Ability[${ABILITY}].EnergyCost}>${Me.Energy}
		return
	if ${Me.Ability[${ABILITY}].EnduranceCost(exists)} && ${Me.Ability[${ABILITY}].EnduranceCost}>${Me.Endurance}
		return
	 if ${Pawn[me].IsMounted}
		return

	VGExecute /stand

	if ${Me.Ability[${ABILITY}].IsReady}
	{
		Me.Ability[${ABILITY}]:Use
		EchoIt "SummonPet: ${ABILITY}"
		wait 5
		if !${Me.Ability[${ABILITY}].IsReady}
			ExecutedAbility:Set[${ABILITY}]
	}
}

;===================================================
;===        START MELEE ATTACKS                 ====
;===================================================
function MeleeAttackOn()
{
	if ${doMelee} && ${Me.Target.Distance}<5
	{
		;; Turn on auto-attack
		if !${GV[bool,bIsAutoAttacking]} || !${Me.Ability[Auto Attack].Toggled}
		{
			if ${Me.Ability[Auto Attack].IsReady}
			{
				Me.Ability[Auto Attack]:Use
				wait 10 ${GV[bool,bIsAutoAttacking]} && ${Me.Ability[Auto Attack].Toggled}
				return
			}
		}
	}
	else
	{
		call MeleeAttackOff
	}
}	


;===================================================
;===        STOP MELEE ATTACKS                  ====
;===================================================
function MeleeAttackOff()
{
	if ${GV[bool,bIsAutoAttacking]} || ${Me.Ability[Auto Attack].Toggled}
	{
		;; Turn off auto-attack if target is not a resource
		if !${Me.Target.Type.Equal[Resource]}
		{
			EchoIt "Turning off Melee Attacks"
			Me.Ability[Auto Attack]:Use
			wait 20 !${GV[bool,bIsAutoAttacking]} && !${Me.Ability[Auto Attack].Toggled}
		}
	}
}


;===================================================
;===        FOLLOW TANK SUB-ROUTINE             ====
;===================================================
function FollowTank()
{
	if ${doFollow}
	{
		if ${FollowDistance1}<1
			FollowDistance1:Set[1]
			
		if ${FollowDistance2}<=${FollowDistance1}
			FollowDistance2:Set[${Math.Calc[${FollowDistance1}+1]}]
			
		
		if ${Pawn[name,${Tank}](exists)} && ${Pawn[name,${Tank}].Distance}>=${FollowDistance2} && ${Pawn[name,${Tank}].Distance}<70
		{

		
/*		
			if !${Tank.Find[${Me.DTarget.Name}]}
			{
				Pawn[name,${Tank}]:Target
				wait 3
			}

			variable float X = ${Me.X}
			variable float Y = ${Me.Y}
			variable bool isSprinting = FALSE
			
			isFollowing:Set[FALSE]
			VGExecute /Follow
			wait 3
			if ${isFollowing}
			{
				while ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>0
				{
					X:Set[${Me.X}]
					Y:Set[${Me.Y}]
					if ${Me.DTarget.Name(exists)} && ${Pawn[name,${Tank}].Distance}<=${FollowDistance1} && ${isFollowing}
					{
						isFollowing:Set[FALSE]
						VGExecute /Follow
						break
					}
					wait 3
				}
			}
*/

			if ${Pawn[name,${Tank}](exists)} && ${Pawn[name,${Tank}].Distance}>=${FollowDistance1}
			{
				variable bool DidWeMove = FALSE
				;; start moving until target is within range
				while !${isPaused} && ${doFollow} && ${Pawn[name,${Tank}](exists)} && ${Pawn[name,${Tank}].Distance}>=${FollowDistance1}
				{
					DidWeMove:Set[TRUE]
					Pawn[name,${Tank}]:Face
					VG:ExecBinding[moveforward]
				}
				;; if we moved then we want to stop moving
				if ${DidWeMove}
					VG:ExecBinding[moveforward,release]
			}
		}
	}
}

;===================================================
;===         FACE TARGET SUBROUTINE             ====
;===================================================
function FaceTarget()
{
	if !${doFace}
		return
	
	if !${Me.Target(exists)}
		return
	
	if ${Me.Target.Distance}<1
		return

	CalculateAngles
	if ${AngleDiffAbs} > 60 
	{
		VGExecute /stand
		waitframe
		
		variable int i = ${Math.Calc[10-${Math.Rand[20]}]}
		EchoIt "Facing within ${i} degrees of ${Me.Target.Name}"
		VG:ExecBinding[turnright,release]
		wait 1
		VG:ExecBinding[turnleft,release]
		wait 1
		if ${AngleDiff}>0
		{
			VG:ExecBinding[turnright]
			while ${AngleDiff} > ${i} && ${Me.Target(exists)} && !${isPaused} && ${isRunning} && ${doFace}
			{
				CalculateAngles
			}
			VG:ExecBinding[turnleft,release]
			wait 1
			VG:ExecBinding[turnright,release]
			wait 1
			return
		}
		if ${AngleDiff}<0
		{
			VG:ExecBinding[turnleft]
			while ${AngleDiff} < ${i} && ${Me.Target(exists)} && !${isPaused} && ${isRunning} && ${doFace}
			{
				CalculateAngles
			}
			VG:ExecBinding[turnright,release]
			wait 1
			VG:ExecBinding[turnleft,release]
			wait 1
			return
		}
		VG:ExecBinding[turnright,release]
		wait 1
		VG:ExecBinding[turnleft,release]
		wait 1
	}
}


;===================================================
;===     CALCULATE TARGET'S ANGLE FROM YOU      ====
;===================================================
atom(script) CalculateAngles()
{
	if ${Me.Target(exists)}
	{
		variable float temp1 = ${Math.Calc[${Me.Y} - ${Me.Target.Y}]}
		variable float temp2 = ${Math.Calc[${Me.X} - ${Me.Target.X}]}
		variable float result = ${Math.Calc[${Math.Atan[${temp1},${temp2}]} - 90]}

		result:Set[${Math.Calc[${result} + (${result} < 0) * 360]}]
		result:Set[${Math.Calc[${result} - ${Me.Heading}]}]
		while ${result} > 180
		{
			result:Set[${Math.Calc[${result} - 360]}]
		}
		while ${result} < -180
		{
			result:Set[${Math.Calc[${result} + 360]}]
		}
		AngleDiff:Set[${result}]
		AngleDiffAbs:Set[${Math.Abs[${result}]}]
	}
	else
	{
		AngleDiff:Set[0]
		AngleDiffAbs:Set[0]
	}
}
variable int AngleDiff = 0
variable int AngleDiffAbs = 0

/*
;===================================================
;===          FIX LINE OF SIGHT                 ====
;===================================================
function FixLineOfSight()
{
	NoLineOfSight:Set[FALSE]
	LoSRetries:Inc
	if ${LoSRetries}>=3
	{
		VGExecute "/cleartargets"
		wait 3
	}
	else
	{
		EchoIt "Fixing Line of Sight"
		Me.Target:Face
		waitframe
		VG:ExecBinding[moveforward,release]
		wait 1
		VG:ExecBinding[movebackward]
		wait 2
		VG:ExecBinding[StrafeRight]
		wait 4
		VG:ExecBinding[StrafeRight,release]
		wait 1
		VG:ExecBinding[StrafeLeft]
		wait 4
		VG:ExecBinding[StrafeLeft,release]
		wait 1
		VG:ExecBinding[movebackward,release]
		wait 1
		VGExecute "/pet Guard"
		wait 15
	}
}
variable int LoSRetries = 0
variable bool NoLineOfSight = FALSE

*/

;===================================================
;===      SetHighestAbility Routine             ====
;===================================================
function SetHighestAbility(string AbilityVariable, string AbilityName)
{


	declare L int local 8
	declare ABILITY string local ${AbilityName}
	declare AbilityLevels[8] string local

	AbilityLevels[1]:Set[I]
	AbilityLevels[2]:Set[II]
	AbilityLevels[3]:Set[III]
	AbilityLevels[4]:Set[IV]
	AbilityLevels[5]:Set[V]
	AbilityLevels[6]:Set[VI]
	AbilityLevels[7]:Set[VII]
	AbilityLevels[8]:Set[VIII]

	;-------------------------------------------
	; return if Ability already exists - based upon current level
	;-------------------------------------------
	if ${Me.Ability["${AbilityName}"](exists)} && ${Me.Ability[${ABILITY}].LevelGranted}<=${Me.Level}
	{
		EchoIt "--> ${AbilityVariable}: ${ABILITY} - Level=${Me.Ability[${ABILITY}].LevelGranted}"
		declare	${AbilityVariable}	string	global "${ABILITY}"
		return
	}

	;-------------------------------------------
	; Find highest Ability level - based upon current level
	;-------------------------------------------
	do
	{
		if ${Me.Ability["${AbilityName} ${AbilityLevels[${L}]}"](exists)} && ${Me.Ability["${AbilityName} ${AbilityLevels[${L}]}"].LevelGranted}<=${Me.Level}
		{
			ABILITY:Set["${AbilityName} ${AbilityLevels[${L}]}"]
			break
		}
	}
	while (${L:Dec}>0)
	
	if !${Me.Ability["${ABILITY}"](exists)}
	{
		L:Set[8]
		do
		{
			if ${Me.Ability["${AbilityName} ${AbilityLevels[${L}]} "](exists)} && ${Me.Ability["${AbilityName} ${AbilityLevels[${L}]} "].LevelGranted}<=${Me.Level}
			{
				ABILITY:Set["${AbilityName} ${AbilityLevels[${L}]} "]
				break
			}
		}
		while (${L:Dec}>0)
	}

	;-------------------------------------------
	; If Ability exist then return
	;-------------------------------------------
	if ${Me.Ability["${ABILITY}"](exists)} && ${Me.Ability["${ABILITY}"].LevelGranted}<=${Me.Level}
	{
		EchoIt "--> ${AbilityVariable}: ${ABILITY} - Level=${Me.Ability[${ABILITY}].LevelGranted}"
		declare	${AbilityVariable}	string	global "${ABILITY}"
		return
	}

	;-------------------------------------------
	; Otherwise, new Ability is named "None"
	;-------------------------------------------
	EchoIt "--> ${AbilityVariable}: None"
	declare	${AbilityVariable}	string	global "None"
	return
}


;===================================================
;===          ATOM - PLAY A SOUND               ====
;===================================================
atom(script) PlaySound(string Filename)
{
	System:APICall[${System.GetProcAddress[WinMM.dll,PlaySound].Hex},Filename.String,0,"Math.Dec[22001]"]
}


;===================================================
;===       ATOM - ECHO A STRING OF TEXT         ====
;===================================================
atom(script) EchoIt(string aText)
{
	if ${doEcho}
	{
		echo "[${Time}][VG-Shaman]: ${aText}"
	}
}

;===================================================
;===   OKAY TO ATTACK - returns TRUE/FALSE      ====
;===================================================
function:bool OkayToAttack(string ABILITY="None")
{
	if (!${Me.IsGrouped} || ${Me.InCombat} || ${Pawn[Name,${Tank}].CombatState}>0) && ${Me.Target(exists)} && !${Me.Target.IsDead} && (${Me.Target.Type.Find[NPC]} || ${Me.Target.Type.Equal[AggroNPC]}) && ${Me.TargetHealth}<=${StartAttack}
	{
		if ${isPaused}
			return FALSE
		if !${Me.Target(exists)}
			return FALSE
		if ${Me.Target.IsDead}
			return FALSE
		if !${Me.TargetHealth(exists)}
			return FALSE
		if ${GV[bool,bHarvesting]}
			return FALSE
		if !${Me.Target.Type.Find[NPC](exists)}
			return FALSE
		if ${Me.TargetBuff[Furious](exists)} || ${Me.TargetBuff[Furious Rage](exists)}
			return FALSE
		if ${Me.Effect[Devout Foeman I](exists)} || ${Me.Effect[Devout Foeman II](exists)} || ${Me.Effect[Devout Foeman III](exists)}
			return FALSE
		if ${Me.TargetBuff[Rust Shield](exists)}
			return FALSE
		if  ${Me.TargetBuff[Charge Imminent](exists)}
			return FALSE
		if ${Me.Effect[Mark of Verbs](exists)}
			return FALSE
		if ${Me.TargetBuff[Major Disease: Fire Advocate](exists)}
			return FALSE
		if ${Me.TargetBuff[Major Enchantment: Ulvari Flame](exists)}
			return FALSE
		if ${Me.Effect[Marshmallow Madness](exists)}
			return FALSE
		if ${Me.TargetBuff[Aura of Death](exists)}
			return FALSE
		if ${Me.TargetBuff[Planar Shield](exists)}
			return FALSE
		if ${Me.TargetBuff[Frightful Aura](exists)}
			return FALSE
		
			
		;; we definitely do not want to be hitting any of these mobs!
		if ${Me.Target.Name.Equal[Corrupted Essence]}
			return FALSE
		if ${Me.Target.Name.Equal[Corrupted Residue]}
			return FALSE
			
		;-------------------------------------------
		; Check PHYSICAL resistances
		;-------------------------------------------
		if ${Me.Ability[${ABILITY}].School.Find[Physical]}
		{
			if !${doPhysical}
				return FALSE
			if ${Me.TargetBuff[Earth Form](exists)}
				return FALSE
			switch "${Me.Target.Name}"
			{
				case Summoned Earth Elemental
					return FALSE

				case Wing Grafted Slasher
					return FALSE

				case Enraged Death Hound
					return FALSE

				case Flarehound
					return FALSE

				case Lesser Flarehound
					return FALSE

				case Greater Flarehound
					return FALSE

				case Ravenous Flarehound
					return FALSE

				case Lirikin
					return FALSE

				case Nathrix
					return FALSE

				case Shonaka
					return FALSE

				case Wisil
					return FALSE

				case Filtha
					return FALSE

				case SILIUSAURUS
					return FALSE

				case ARCHON TRAVIX
					return FALSE

				case Earthen Marauder
					return FALSE

				case Earthen Resonator
					return FALSE

				case Cartheon Devourer
					return FALSE

				case Rock Elemental
					return FALSE

				case Cartheon Soulslasher
					return FALSE

				case Cartheon Abomination
					return FALSE

				case Glowing Infineum
					return FALSE

				case Living Infineum
					return FALSE

				case Spawn of Infineum
					return FALSE

				case Myconid Fungal Ravager
					return FALSE

				case Xakrin Sage
					return FALSE

				case Hound of Rahz
					return FALSE

				case Ancient Juggernaut
					return FALSE

				case Xakrin Razarclaw
					return FALSE

				case Assaulting Death Hound
					return FALSE

				case Blood-crazed Ettercap
					return FALSE

				case Lixirikin
					return FALSE

				case Flarehound Watcher
					return FALSE

				case Nefarious Titan
					return FALSE

				case Nefarious Elemental
					return FALSE

				case Enraged Convocation
					return FALSE

				Default
					break
			}
		}

		;-------------------------------------------
		; Check ARCANE resistances
		;-------------------------------------------
		if ${Me.Ability[${ABILITY}].School.Find[Arcane]}
		{
			if !${doArcane}
				return FALSE
			if ${Me.TargetBuff[Electric Form](exists)}
				return FALSE
			switch "${Me.Target.Name}"
			{
				case Descrier Sentry
					return FALSE

				case Summoned Air Elemental
					return FALSE

				case Descrier Psionicist
					return FALSE

				case Descrier Dreadwatcher
					return FALSE

				case Sub-Warden Mer
					return FALSE

				case OVERWARDEN
					return FALSE

				case Omac
					return FALSE

				case Salrin
					return FALSE

				case Bandori
					return FALSE

				case Guardian B27
					return FALSE

				case Energized Marauder
					return FALSE

				case Energized Resonator
					return FALSE

				case Electric Elemental
					return FALSE

				case Lesser Electric Elemental
					return FALSE

				case Greater Electric Elemental
					return FALSE

				case Energized Elemental
					return FALSE

				case Construct of Lightning
					return FALSE

				case Cartheon Wingwraith
					return FALSE

				case Source of Arcane Energy
					return FALSE

				case Ancient Infector
					return FALSE

				case Cartheon Archivist
					return FALSE

				case Cartheon Arcanist
					return FALSE

				case Cartheon Scholar
					return FALSE

				case Eyelord Seeker
					return FALSE

				case Mechanized Stormsuit
					return FALSE

				Default
					break
			}
		}

		;-------------------------------------------
		; Check FIRE resistances
		;-------------------------------------------
		if ${Me.Ability[${ABILITY}].School.Find[Fire]}
		{
			if !${doFire}
				return FALSE
			if (${Me.TargetBuff[Molten Form](exists)} || ${Me.TargetBuff[Fire Form](exists)})
				return FALSE
			switch "${Me.Target.Name}"
			{
				case Mechanized Pyromaniac
					return FALSE

				Default
					break
			}
		}

		;-------------------------------------------
		; Check ICE/COLD resistances
		;-------------------------------------------
		if (${Me.Ability[${ABILITY}].School.Find[Ice]} || ${Me.Ability[${ABILITY}].School.Find[Cold]})
		{
			if !${doCold}
				return FALSE
			if (${Me.TargetBuff[Ice Form](exists)} || ${Me.TargetBuff[Cold Form](exists)} || ${Me.TargetBuff[Frozen Form](exists)})
				return FALSE
			switch "${Me.Target.Name}"
			{
				Default
					break
			}
		}

		;-------------------------------------------
		; Check MENTAL resistances
		;-------------------------------------------
		if ${Me.Ability[${ABILITY}].School.Find[Mental]}
		{
			if !${doMental}
				return FALSE
			switch "${Me.Target.Name}"
			{
				Default
					break
			}
		}

		;-------------------------------------------
		; Check SPIRITUAL resistances
		;-------------------------------------------
		if ${Me.Ability[${ABILITY}].School.Find[Spiritual]}
		{
			if !${doSpiritual}
				return FALSE
			switch "${Me.Target.Name}"
			{
				Default
					break
			}
		}
		
		return TRUE
	}
	return FALSE
}

;===================================================
;===           BUFFAREA SUB-ROUTINE             ====
;===================================================
function BuffArea()
{	
	;-------------------------------------------
	; Start/Stop our BuffArea script
	;-------------------------------------------
	if ${Script[BuffArea](exists)}
	{
		endscript BuffArea
	}
	elseif !${Script[BuffArea](exists)}
	{
		run ./VG-Shaman/BuffArea.iss
	}
}