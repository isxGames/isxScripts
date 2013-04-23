;--------------------------------------------------------------------------
; VG-Shaman.iss
;
; Description - A script that will assist you in playing your Shaman.
; It will handle healing, manage your pet, and exploit weakness that
; are generated from your pet or other players.  It is designed to
; save your energy for heals and maximize usage of your endurance for
; crits.  It's not a DPS script.
;
; Notes - currently, this script is designed for Rakurr (Wolf)
;
; (Turn all pet abilities off except for: Intimidate and Scent of Blood)

; -----------
; * Heals: (everything can be toggled on/off)
;    -Small Heals (Remedy)
;    -Big Heals (Restoration)
;    -Emergency Heal (Intercession & Panacea)
;    -Group Heal (Life Ward)
;    -Aegis of Life (for the Tank and Player)
;    -Toggle to heal group members only
;
; * Miscellaneous:
;    -Follow
;    -Loot
;    -Face
;    -Shroud (go stealth)
;    -Delay (slow things down)
;
; * Combat Toggles (everything can be turned on/off)
;    -Start Attack (health of the target to begin attacking)
;    -Physical/Spiritual/Cold abilities
;    -Melee/Spells abilities
;    -Ranged (use it if you have it)
;    -Weapon (will automatically toggle off if you have no clickie)
;    -deBuff (Lethargy & Curse of Fraility)
;    -deAggro (Snarl to reduce hate)
;    -Pet (summons or dismiss your pet)
;
; Revision History
; ----------------
; 20130401 (Zandros)
; * Wrote the basics of the routine
;
; 20130408 (Zandros)
; * Modified the routines to focus on exploiting weaknesses so that
;   you can benefit from the extra damage.  Be sure to turn off all 
;   pet abilities except for: Intimidate and Scent of Blood
;
; 20130411 (Zandros)
; * Changed the way how group healing works.  It now detects what
;   healing ability to use for which person needing the heal. Group
;   type heals or group members only will work correctly and not be 
;   wasted on someone that is not in your group (such as in a raid)
;
; 20130412 (Zandros)
; * Built a loot routine that works great.  Finds your tombstone and
;   drags it closer to you.  Target's lootable corpses within 5 meters
;
; 20130415 (Zandros)
; * Built monitoring routines to handle certain messages received by 
;   alert, chat, and combat messages
;
; 20130418 (Zandros)
; * Built the UI with adjustable settings and remembers your settings
;
; 20130421 (Zandros)
; * Fixed Ranged Attack (wrong variable being used) and also fixed
;   cold based abilities (again, wrong variable being used).  Changed
;   how forms are toggled based upon the type of ability used.  Also
;   changed how Life Ward works  
;
; 20130422 (Zandros)
; * GlobalRecover was not working so I wrote my own routine that is 
;   similar to it.  Every player has some form of Racial Inheritance
;   so I used it to determine if the ability is ready or not.  Also, 
;   fixed changing forms so that it works correctly and made heals
;   priority over attacks.
;
; 20130423 (Zandros)
; * Added BuffArea routine (scans for PCs, checks if buff exists, and
;   buffs PC with ability that is 15 levels higher than they are).
;   Removed the redundancy checks for AutoAttack and removes Shroud when
;   unchecked.  Also, included a check to see if you are eating.
;
;
;===================================================
;===               Includes                     ====
;===================================================
;
#include ./VG-Shaman/Includes/Routines.iss
#include ./VG-Shaman/Includes/Monitors.iss
#include ./VG-Shaman/Includes/Healing.iss
#include ./VG-Shaman/Includes/Objects.iss

variable bool doEcho = TRUE
variable bool isRunning = TRUE
variable bool isPaused = FALSE

variable int i
variable int DelayAttack = 4
variable int StartAttack = 99
variable int DifficultyLevel = 9
variable int NextAction = ${Script.RunningTime}
variable int RegenEnergyTimer = ${Script.RunningTime}
variable int UseWeaponTimer = ${Script.RunningTime}
variable int TempTimer = ${Script.RunningTime}
variable string Totem = "Rakurr"
variable string temp


;; UI - Main Tab
variable string Action = "Idle"
variable string LastAction = "Nothing"
variable string ExecutedAbility = "None"
variable string TargetsTarget = "No Target"

variable bool WeAreDead = FALSE
variable bool doFace = FALSE

variable float timeCheck = 1
variable int startXP = ${Me.XP}
variable int lastXP = ${Me.XP}

variable bool doNPC = TRUE
variable bool doAggroNPC = TRUE

variable bool doDebuff = TRUE

variable bool doLoot = TRUE
variable bool doDeAggro = TRUE

variable bool doSummonPets = TRUE
variable bool doLethargy = TRUE
variable bool doCurseofFrailty = TRUE
variable bool doHuntersShroud = FALSE
variable bool doLevitate = FALSE

variable string Tank = ${Me.FName}
variable int64 TankID = ${Pawn[exactname,${Me.FName}].ID}
variable string PetName = "Fido"
variable bool doAreWeSitting = FALSE


variable bool doPhysical = TRUE
variable bool doSpiritual = TRUE
variable bool doCold = TRUE
variable bool doMelee = TRUE
variable bool doRangedAttack = TRUE
variable bool doSpell = TRUE

;; Forms
variable string HealingForm = "Mien of the Mystic"
variable string MeleeForm = "Spirit Bond: Skamadiz"
variable string EnergyForm = "Spirit Bond: Krigus"
variable string SpellForm = "Spirit Bond: Nag-Suul"

;; Items
variable bool doUseWeapon = FALSE
variable string LastPrimary = "TEMP"
variable string LastSecondary = "TEMP"
variable bool haveZephyrkinShield = FALSE


;; Follow variables
variable bool doFollow = FALSE
variable int FollowDistance1 = 3
variable int FollowDistance2 = 5

;; Heal variables
variable bool doTankOnly = FALSE
variable bool doGroupOnly = FALSE
variable bool doSmallHeal = TRUE
variable bool doBigHeal = TRUE
variable bool doEmrgHeal = TRUE
variable bool doAegisofLife = FALSE
variable bool doLifeWard = TRUE
variable int SmallHealPct = 65
variable int BigHealPct = 50
variable int EmrgHealPct = 35
variable int LifeWardPct = 85
variable int AegisofLifePct = 80

;; XML variables used to store and save data
variable settingsetref General

variable(global) Obj_Commands Check

#define ALARM "${Script.CurrentDirectory}/Sounds/ping.wav"



;===================================================
;===            MAIN SCRIPT                     ====
;===================================================
function main()
{
	;; Initialize our settings
	call Startup

	;-------------------------------------------
	; LOOP THIS INDEFINITELY
	;-------------------------------------------
	while ${isRunning}
	{
		call HandleCoolDown
		call AlwaysCheck
		call GoDoSomething
	}
}


;===================================================
;===          HANDLE COOLDOWNS                  ====
;===================================================
function HandleCoolDown()
{
	if ${isPaused} || !${Check.AreWeReady} || ${Check.AreWeEating} || ${Me.IsCasting} || ${GV[bool,DeathReleasePopup]} || ${Pawn[me].IsMounted} || ${Me.Effect[Invulnerability Login Effect](exists)}
	{
		if ${isPaused}
			call MeleeAttackOff
		while ${isPaused} || !${Check.AreWeReady} || ${Check.AreWeEating} || ${Me.IsCasting} || ${GV[bool,DeathReleasePopup]} || ${Pawn[me].IsMounted} || ${Me.Effect[Invulnerability Login Effect](exists)}
		{
			waitframe
			if ${Me.IsCasting}
				ExecutedAbility:Set[${Me.Casting}]
			if ${Me.ToPawn.IsStunned}
				call MeleeAttackOff
			if ${Pawn[me].IsMounted}
				call MeleeAttackOff
			if ${Me.Effect[Invulnerability Login Effect](exists)}
				call MeleeAttackOff
			if ${GV[bool,DeathReleasePopup]}
			{
				WeAreDead:Set[TRUE]
				call MeleeAttackOff
			}
		}
		
		call ReadyCheck
	}
}


;===================================================
;===      GO DO SOMETHING ROUTINE               ====
;===================================================
function GoDoSomething()
{
	if !${Me.Target(exists)}
		call DownTime
	if ${Me.Target(exists)}
		call HandleTarget
}


;;;;;;;
;; safe range is 4-8 during melee toggled on
function ReadyCheck()
{
	while !${Check.AreWeReady}
	{
		while !${Check.AreWeReady}
			waitframe
		wait ${DelayAttack}
	}
}
	

;===================================================
;===      ALWAYS CHECK ROUTINE                  ====
;===================================================
function AlwaysCheck()
{
	;;;;;;;
	;; Always clear your target
	if ${Me.Target.IsDead} && !${doLoot}
	{
		wait 10
		VGExecute /cleartargets
		wait 3
	}
	
	;;;;;;;
	;; Fix that 0 health problem
	if ${Me.DTarget(exists)}
	{
		if ${Me.DTargetHealth}<1
		{
			wait 10
			if ${Me.DTargetHealth}<1
			{
				VGExecute "/cleartargets"
				wait 3
			}
		}
	}
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; The following are my heal routines
	;; 
	variable int GroupNumber = 0
	variable int LowestHealth = 100
	variable int Range = 0
	variable bool isGroupMember = FALSE
	GroupNumber:Set[0]
	LowestHealth:Set[100]
	Range:Set[0]
	isGroupMember:Set[FALSE]
	
	;;;;;;;;;;
	;; Set our variables
	if !${Me.IsGrouped}
	{
		GroupNumber:Set[0]
		LowestHealth:Set[${Me.HealthPct}]
		isGroupMember:Set[TRUE]
	}

	;;;;;;;;;;
	;; Set our variables
	if ${Me.IsGrouped}
	{
		;; Scan everyone
		if !${doGroupOnly}
		{
			for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
			{
				if ${Group[${i}].Distance}<30 && ${Group[${i}].Health}>0 && ${Group[${i}].Health}<=${LowestHealth}
				{
					GroupNumber:Set[${i}]
					LowestHealth:Set[${Group[${i}].Health}]
					Range:Set[${Group[${i}].Distance}]
					if ${GroupMemberList.Element["${Group[${i}].Name}"](exists)}
						isGroupMember:Set[TRUE]
				}
			}
		}
		
		;; Scan only group members
		if ${doGroupOnly}
		{
			for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
			{
				if ${GroupMemberList.Element["${Group[${i}].Name}"](exists)}
				{
					if ${Group[${i}].Distance}<30 && ${Group[${i}].Health}>0 && ${Group[${i}].Health}<=${LowestHealth}
					{
						GroupNumber:Set[${i}]
						LowestHealth:Set[${Group[${i}].Health}]
						Range:Set[${Group[${i}].Distance}]
						isGroupMember:Set[TRUE]
					}
				}
			}
		}
	}

	call ReadyCheck

	;; Ensure tank is always set to our DTarget during combat
	if ${Pawn[Name,${Tank}](exists)} && ${Pawn[Name,${Tank}].CombatState}>0
	{
		if !${Me.DTarget.Name.Equal[${Tank}]}
		{
			Pawn[name,${Tank}]:Target
			wait 7 ${Me.DTargetHealth(exists)}
		}
		;; always cast Aegis of Life on the tank
		if ${Me.DTarget.Name.Equal[${Tank}]}
		{
			if ${doAegisofLife} && ${Me.DTargetHealth}<${AegisofLifePct}
			{
				;; ifAegis of Life is Ready then fire off the +10% Healing clickie
				if ${haveZephyrkinShield} && ${Me.Ability[${AegisofLife}].IsReady}
				{
					if ${Me.Inventory["Zephyrkin, Eye of the Mistral Storm"].IsReady}
					{
						EchoIt "Using: Zephyrkin, Eye of the Mistral Storm"
						vgecho "Using: Zephyrkin, Eye of the Mistral Storm"
						Me.Inventory[${LastSecondary}]:Unequip
						Me.Inventory["Zephyrkin, Eye of the Mistral Storm"]:Equip
						wait 2
						Me.Inventory["Zephyrkin, Eye of the Mistral Storm"]:Use
						Me.Inventory[${LastSecondary}]:Equip
						wait 3
					}
				}		
				call UseAbility "${AegisofLife}"
			}
			;; if tank is in our group
			if ${doEmrgHeal} && ${isGroupMember}
			{
				if ${Pawn[Name,${Tank}].Distance}<30 && ${Me.DTargetHealth}<${PanaceaPct}
					call CastNow "${Panacea}"
				if ${Pawn[Name,${Tank}].Distance}<10 && ${Me.DTargetHealth}<${EmrgHealPct}
					call CastNow "${Intercession}"
			}
		}
		;; Yourself
		if ${doEmrgHeal} && ${Me.HealthPct}<${PanaceaPct}
			call UseAbilitySelf "${Panacea}"
	}
	
	;;;;;;;;;;
	;; These abilities require the person to be in a group to work
	;; DTarget does not need to be set
	if ${isGroupMember} && ${Range}<10
	{
		;; Cast if health<=85, range<10, group members only
		if ${doLifeWard} && ${LowestHealth}<${LifeWardPct}
			call CastNow "${LifeWard}"
		if ${doLifeWard} && ${Me.Pet(exists)} && ${Me.Pet.Health}<${LifeWardPct}
			call CastNow "${LifeWard}"
		;; Cast if health<=35, range<10, group members only
		if ${doEmrgHeal} && ${LowestHealth}<${EmrgHealPct} && ${Me.InCombat}
			call CastNow "${Intercession}"
	}
	
	;;;;;;;;;;
	;; Small/Big Heal
	if ${Range}<30
	{
		;; Cast if health<=55, range<30, anyone
		if ${doSmallHeal}
		{
			if !${GroupNumber} && ${LowestHealth}<${SmallHealPct}
				call UseAbilitySelf "${Remedy}"
			if ${GroupNumber} && ${LowestHealth}<${SmallHealPct}
				call UseAbilityOther ${GroupNumber} "${Remedy}"
			if ${Me.DTarget(exists)} && !${Me.Pet.Name.Equal[${Me.DTarget.Name}]} && ${Me.DTargetHealth}<${SmallHealPct}
				call UseAbility "${Remedy}"
			if ${Me.Pet(exists)} && ${Me.Pet.Health}<${SmallHealPct}
				call CastNow "${HealAttendant}"
		}

		;; Cast if health<=55, range<30, anyone
		if ${doBigHeal}
		{
			if !${GroupNumber} && ${LowestHealth}<${BigHealPct}
				call UseAbilitySelf "${Restoration}"
			if ${GroupNumber} && ${LowestHealth}<${BigHealPct}
				call UseAbilityOther ${GroupNumber} "${Restoration}"
			if ${Me.DTarget(exists)} && !${Me.Pet.Name.Equal[${Me.DTarget.Name}]} && ${Me.DTargetHealth}<${BigHealPct}
				call UseAbility "${Restoration}"
			if ${Me.Pet(exists)} && ${Me.Pet.Health}<${BigHealPct}
				call CastNow "${HealAttendant}"
		}
	}

	;;;;;;;;;;
	;; Toggle on/off our 4 second healing tick (turn off to regain endurance fast)
	if ${Me.HealthPct}<=90 && !${Me.Ability[${BosridsGift}].Toggled}
		call UseAbilitySelf "${BosridsGift}"
	if ${Me.HealthPct}>=95 && ${Me.Ability[${BosridsGift}].Toggled}
		VGExecute /can \"${BosridsGift}\"
		
	;; Heal our pet
	if ${Me.HavePet} && ${Me.Pet(exists)}
	{
		;; Heal the pet
		if ${Me.Pet.Health}<55
			call CastNow "${HealAttendant}"
	}

	
	;-------------------------------------------
	; ASSIST TANK - always assist when tank is in combat
	;-------------------------------------------
	if !${Me.FName.Find[${Tank}]}
	{
		if ${Pawn[name,${Tank}](exists)}
		{
			;; assist the tank only if the tank is in combat and less than 50 meters away
			if ${Pawn[name,${Tank}].CombatState}>0 && ${Pawn[name,${Tank}].Distance}<=50
			{
				;; assist tank only if we are not in combat, target is dead, or we do not have a target
				if !${Me.Target(exists)}
				{
					VGExecute /cleartargets
					waitframe
					VGExecute "/assist ${Tank}"
					wait 10 ${Me.TargetAsEncounter.Difficulty(exists)}
				}
			}
		}
	}

	;; Grab that next encounter!
	if ${Me.Encounter}
	{
		if ${Pawn[Name,${Tank}](exists)}
		{
			;; assist the tank only if the tank is in combat and less than 50 meters away
			if ${Pawn[Name,${Tank}].CombatState}==0 && ${Pawn[Name,${Tank}].Distance}<=50
			{
				VGExecute /cleartargets
				waitframe
				Pawn[id,${Me.Encounter[1].ID}]:Target
				wait 10 ${Me.TargetAsEncounter.Difficulty(exists)}
			}
			call FaceTarget
			VGExecute "/pet Attack"
			waitframe
		}
	}

	;;;;;;;;;;
	;; Follow the tank routine
	call FollowTank	
}


;===================================================
;===            DOWN TIME                       ====
;===================================================
function DownTime()
{
	;; always reset this
	doLethargy:Set[TRUE]
	
	if ${doFindGroupMembers}
		call FindGroupMembers
	
	;; Ensure difficulty of target doesn't exist when you do not have a target
	wait 5 !${Me.TargetAsEncounter.Difficulty(exists)}
	
	;; this will reset the target bug
	if ${Me.InCombat} && !${Me.Target(exists)}
	{
		VGExecute "/cleartargets"
		wait 3
		return
	}

	;; Remove Curses, Poisons, and Diseases
	for ( i:Set[1] ; ${i}<=${Me.Effect.Count} && ${Me.Effect[${i}].Name(exists)} ; i:Inc )
	{
		if ${Me.Effect[${i}].Name.Find[Poison]} || ${Me.Effect[${i}].Name.Find[Disease]}
		{
			call UseAbilitySelf "${Purge}"
		}
		if ${Me.Effect[${i}].Name.Find[Curse]}
		{
			call UseAbilitySelf "${RemoveCurse}"
		}
	}

	;;;;;;;
	;; Cast the strongest buff and buffs that stack with it
	if ${Me.Ability[${SpiritsBountifulBlessing}](exists)}
	{
		call UseAbilitySelf "${SpiritsBountifulBlessing}"
		if ${Me.Effect[${SpiritsBountifulBlessing}](exists)}
		{
			call UseAbilitySelf "${RakurrsGiftofGrace}"
			call UseAbilitySelf "${RakurrsGiftofSpeed}"
			call UseAbilitySelf "${BoonofRakurr}"
		}
	}

	;;;;;;;
	;; Cast the second strongest buff as needed
	if ${Me.Ability[Favor of the Hunter](exists)} && !${Me.Ability[${SpiritsBountifulBlessing}](exists)} && ${Me.Effect[${SpiritsBountifulBlessing}](exists)}
		call UseAbilitySelf "Favor of the Hunter"
	
	;;;;;;;
	;; Set flag to not cast lesser buffs if any of these exists
	variable bool doLesserBuff = TRUE
	if ${Me.Effect[${SpiritsBountifulBlessing}](exists)}
		doLesserBuff:Set[FALSE]
	if ${Me.Effect[Gift of Boqobol](exists)}	
		doLesserBuff:Set[FALSE]
	if ${Me.Effect[Gift of the Oracle](exists)}	
		doLesserBuff:Set[FALSE]
	if ${Me.Effect[Infusion of Spirit](exists)}	
		doLesserBuff:Set[FALSE]

	if ${doLesserBuff}
	{
		call UseAbilitySelf "${RakurrsGiftofGrace}"
		call UseAbilitySelf "${RakurrsGiftofSpeed}"
		call UseAbilitySelf "${BoonofRakurr}"
		call UseAbilitySelf "${SpiritofRakurr}"
		call UseAbilitySelf "${Infusion}"
		call UseAbilitySelf "${OraclesSight}"
		call UseAbilitySelf "${BoonofBoqobol}"
		call UseAbilitySelf "${BoonofBosrid}"
		call UseAbilitySelf "${BoonofRakurr}"
		if !${Me.Effect[${RakurrsGiftofSpeed}](exists)}	
			call UseAbilitySelf "${SpeedofRakurr}"
		if !${Me.Effect[${RakurrsGiftofGrace}](exists)}	
			call UseAbilitySelf "${RakurrsGrace}"
	}

	call UseAbilitySelf "${SkinofRakurr}"
	if ${Me.Effect["Rakurr Form: Illusion"](exists)}
		VGExecute /can \"Rakurr Form: Illusion\"

	call UseAbilitySelf "${LifeWard}"
	
	;; toggle on our small heall every 4 seconds
	if ${Me.HealthPct}<80 && !${Me.Ability[${BosridsGift}].Toggled}
		call UseAbility "${BosridsGift}"
	;; toggle off our small heall every 4 seconds
	if ${Me.HealthPct}>=95 && ${Me.Ability[${BosridsGift}].Toggled}
	{
		VGExecute /can \"${BosridsGift}\"
		wait 10 ${VG.InGlobalRecovery} || ${Me.IsCasting}
	}

	;; Summon our Pet
	call SummonPet "${SummonAttendantofRakurr}"
	
	;; Levitate
	if ${doLevitate}
		call UseAbilitySelf "${BoonofAlcipus}"
	
	;; Go Invis
	if ${doHuntersShroud}
		call UseAbilitySelf "${HuntersShroud}"
	elseif ${Me.Ability[${HuntersShroud}].Toggled}
		VGExecute /can \"${HuntersShroud}\"
	
	
}

;===================================================
;===           HANDLE TARGET                    ====
;===================================================
function HandleTarget()
{
	;; Delay only if we can't ID the target (lag does that)
	if !${Me.TargetAsEncounter.Difficulty(exists)}
		wait 25 ${Me.TargetAsEncounter.Difficulty(exists)} && ${Me.TargetHealth(exists)}
		
	;; Attack NPC
	if ${doNPC} && (${Me.Target.Type.Equal[NPC]} || ${Me.InCombat})
		call AttackTarget
		
	;; Attack AggroNPC
	if ${doAggroNPC} && (${Me.Target.Type.Equal[AggroNPC]} || ${Me.InCombat})
		call AttackTarget
}

;===================================================
;===           ATTACK TARGET ROUTINE            ====
;===================================================
function AttackTarget()
{
	;; return if target's health is above our StartAttack
	if ${Me.TargetHealth}>${StartAttack} && ${Pawn[id,${Me.Target.ID}].CombatState}==0
		return
		
	if ${Me.TargetHealth}>${StartAttack} && !${Me.ToT.Name.Find[${Me.FName}]}
		return
		
	;; do not bother to attack it if it is too tough
	wait 10 ${Me.TargetAsEncounter.Difficulty(exists)}

	;; match target dificulty to that of the hunt script
	if ${Script[VG-Hunt](exists)}
	{
		DifficultyLevel:Set[${Script[VG-Hunt].Variable[DifficultyLevel]}]
		if ${Me.TargetAsEncounter.Difficulty}>${DifficultyLevel} && ${Pawn[id,${Me.Target.ID}].CombatState}==0
		{
			VGExecute "/cleartargets"
			return
		}
	}

	;; face our target within 10 degrees
	call FaceTarget
	
	;; Backup if we are too close
	if ${Me.Target(exists)} && ${Me.Target.Distance}<1
	{
		while ${Me.Target(exists)} && ${Me.Target.Distance}<1
		{
			Me.Target:Face
			VG:ExecBinding[movebackward]
		}
		VG:ExecBinding[movebackward,release]
	}

	;; Send in our Pet
	if ${Me.HavePet} && ${Me.Pet(exists)}
	{
		;; send the pet in
		if ${Pawn[${PetName}].CombatState}==0
		{
			VGExecute /pet Attack

			TempTimer:Set[${Script.RunningTime}]
			while ${Math.Calc[${Math.Calc[${Script.RunningTime}-${TempTimer}]}/1000]}<3 && !${Me.InCombat} && ${Me.Target(exists)}
				call FaceTarget
		}
	}

	call ReadyCheck
	
	
	;; Reduce Hate - use only if you have a pet or in a group
	if ${doDeAggro} && ${Me.ToT.Name.Find[${Me.FName}]} && (${Me.Pet(exists)} || ${Me.IsGrouped})
		call CastNow "${Snarl}"
	
	;; Cannibalize health for some energy every 3 seconds
	if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${RegenEnergyTimer}]}/1000]} > 4
	{
		if ${Me.HealthPct}>70 && ${Me.EnergyPct}<80 && !${Me.Effect["Scent of Blood"](exists)}
		{
			call UseAbility "${RitualofSacrifice}"
			RegenEnergyTimer:Set[${Script.RunningTime}]
		}
	}

	if ${Me.HealthPct}<55 || (${Me.Pet(exists)} && ${Me.Pet.Health}<55)
		return

	;; Remove Curses, Poisons, and Diseases
	for ( i:Set[1] ; ${i}<=${Me.Effect.Count} && ${Me.Effect[${i}].Name(exists)} ; i:Inc )
	{
		if ${Me.Effect[${i}].Name.Find[Poison]} || ${Me.Effect[${i}].Name.Find[Disease]}
		{
			call UseAbilitySelf "${Purge}"
		}
		if ${Me.Effect[${i}].Name.Find[Curse]}
		{
			call UseAbilitySelf "${RemoveCurse}"
		}
	}
	
	;; Put our deBuffs on the target
	if ${doDebuff}
	{
		;; Slows target's attack speed
		if ${doLethargy}
			call CastNow "${Lethargy}"
		;; deBuffs the targets
		if ${doCurseofFrailty}
			call CastNow "${CurseofFrailty}"
	}
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; The following are my Melee Attacks
	;;
	if ${Me.Target.Distance}<5
	{
		;; Auto Crit for 6 seconds!
		if ${Me.Effect["Scent of Blood"](exists)}
		{
			call CastNow "${AvataroftheHunter}"
			call UseAbility "${Hamstring}"
			call UseAbility "${BiteofNagSuul}"
			call UseAbility "${HammerofKrigus}"
			call UseAbility "${KissofNagSuul}"
		}

		;; save some Endurance for Crits
		if ${Me.Endurance}>=45
		{
			;; This exploits Torn Throat every 20 seconds
			if ${Me.TargetWeakness["Torn Throat"](exists)}
				call UsePetAbility "Eviscerate"

			;; This exploits Shaken every 20 seconds
			if !${Me.TargetWeakness["Flesh Rend"](exists)}
				call UseAbility "${TearingClaw}"
			if ${Me.TargetWeakness["Flesh Rend"](exists)}
				call UsePetAbility "Maim"

			;; This exploits Bleeding every 20 seconds
			if ${Me.TargetWeakness["Bleeding"](exists)}
				call UseAbility "${StrikeofSkamadiz}"

			;; This exploits Bitten every 10 seconds
			if !${Me.TargetWeakness["Bitten "](exists)}
				call UseAbility "${ViciousBite}"
			if ${Me.TargetWeakness["Bitten "](exists)}
				call UsePetAbility "Bloody Fang"

			call UseAbility "${BiteofNagSuul}"
			call UseAbility "${HammerofKrigus}"
		}
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; The following are my Spell Attacks
	;;
	
	;; This exploits Chilled every 30 seconds
	if ${Me.TargetWeakness[Chilled](exists)}
		call UseAbility "${SpiritStrike}"
	
	;; This exploits Burning every 8 seconds
	if ${Me.TargetWeakness[Burning](exists)}
		call UseAbility "${WintersRoar}"
	
	;; Load these Dots up
	if ${Me.EnergyPct}>50
	{
		call UseAbility "${KissofNagSuul}"
		call UseAbility "${BaneofKrigus}"
		call UseAbility "${Hoarfrost}"
	}

	;; Reduce Hate
	if ${doDeAggro}
		call CastNow "${Snarl}"
	
	;; USE WEAPON ABILITY
	if ${doUseWeapon}
	{
		;; check once every 5 seconds
		if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${UseWeaponTimer}]}/1000]}>5
		{
			if ${Me.Inventory[${LastPrimary}].IsReady} && !${Me.IsCasting} && !${VG.InGlobalRecovery}
			{
				Me.Inventory[${LastPrimary}]:Use
				do
				{
					wait 2
				}
				while ${VG.InGlobalRecovery}
				EchoIt "[${Time}] UseWeapon: ${LastPrimary}"
				waitframe
				;; reset the timer
				UseWeaponTimer:Set[${Script.RunningTime}]
				return
			}
		}
	}
	
	;; Lastly, use our Ranged Attack
	if ${doRangedAttack}
		call UseAbility "Ranged Attack"

		;; Turn On/Off Auto Attack
	call MeleeAttackOn
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;===================================================
;===     ATOM - CALLED AT END OF SCRIPT         ====
;===================================================
function atexit()
{
	;; Unload BuffArea routine
	if ${Script[BuffArea](exists)}
	{
		endscript BuffArea
	}

	;; Update our settings
	General:AddSetting[StartAttack,${StartAttack}]
	General:AddSetting[DelayAttack,${DelayAttack}]
	General:AddSetting[doFace,${doFace}]
	General:AddSetting[doNPC,${doNPC}]
	General:AddSetting[doAggroNPC,${doAggroNPC}]
	General:AddSetting[doDebuff,${doDebuff}]
	General:AddSetting[doLoot,${doLoot}]
	General:AddSetting[doDeAggro,${doDeAggro}]
	General:AddSetting[doSummonPets,${doSummonPets}]
	General:AddSetting[doHuntersShroud,${doHuntersShroud}]
	General:AddSetting[doLevitate,${doLevitate}]
	General:AddSetting[doPhysical,${doPhysical}]
	General:AddSetting[doSpiritual,${doSpiritual}]
	General:AddSetting[doCold,${doCold}]
	General:AddSetting[doMelee,${doMelee}]
	General:AddSetting[doRangedAttack,${doRangedAttack}]
	General:AddSetting[doSpell,${doSpell}]
	General:AddSetting[doUseWeapon,${doUseWeapon}]
	General:AddSetting[doFollow,${doFollow}]
	General:AddSetting[FollowDistance1,${FollowDistance1}]
	General:AddSetting[FollowDistance2,${FollowDistance2}]
	General:AddSetting[doTankOnly,${doTankOnly}]
	General:AddSetting[doGroupOnly,${doGroupOnly}]
	General:AddSetting[doSmallHeal,${doSmallHeal}]
	General:AddSetting[doBigHeal,${doBigHeal}]
	General:AddSetting[doEmrgHeal,${doEmrgHeal}]
	General:AddSetting[doLifeWard,${doLifeWard}]
	General:AddSetting[doAegisofLife,${doAegisofLife}]
	General:AddSetting[EmrgHealPct,${EmrgHealPct}]
	General:AddSetting[SmallHealPct,${SmallHealPct}]
	General:AddSetting[BigHealPct,${BigHealPct}]
	General:AddSetting[LifeWardPct,${LifeWardPct}]
	General:AddSetting[AegisofLifePct,${AegisofLifePct}]
	General:AddSetting[doFakeDeath,${doFakeDeath}]
	
	;; save our settings to file
	LavishSettings[SHA]:Export[${Script.CurrentDirectory}/Saves/SHA_Save.xml]

	;; Unload our UI
	ui -unload "${Script.CurrentDirectory}/VG-Shaman.xml"

	;; Say we are done
	EchoIt "Stopped VG-Shaman Script"
}


function Startup()
{
	EchoIt "Started Easy Script"

	;; === HEALS ===
	call SetHighestAbility "AegisofLife" "Aegis of Life"
	call SetHighestAbility "BosridsGift" "Bosrid's Gift"
	call SetHighestAbility "Panacea" "Panacea"
	call SetHighestAbility "Remedy" "Remedy"
	call SetHighestAbility "Restoration" "Restoration"
	call SetHighestAbility "TotemicUnion" "Totemic Union"
	call SetHighestAbility "Intercession" "Intercession"
	;; === CRIT ===
	call SetHighestAbility "ThroatRip" "Throat Rip"
	call SetHighestAbility "FistoftheEarth" "Fist of the Earth"
	call SetHighestAbility "GelidBlast" "Gelid Blast"
	call SetHighestAbility "UmbraBurst" "Umbra Burst"
	call SetHighestAbility "ThroatRip" "Throat Rip"
	call SetHighestAbility "SpearoftheAncestors" "Spear of the Ancestors"
	
	;; === MELEE ===
	call SetHighestAbility "BiteofNagSuul" "Bite of Nag-Suul"
	call SetHighestAbility "HammerofKrigus" "Hammer of Krigus"
	call SetHighestAbility "StrikeofSkamadiz" "Strike of Skamadiz"
	call SetHighestAbility "TearingClaw" "Tearing Claw"
	call SetHighestAbility "ViciousBite" "Vicious Bite"
	;; === DOTS ===
	call SetHighestAbility "BaneofKrigus" "Bane of Krigus"
	call SetHighestAbility "FleshRot" "Flesh Rot"
	call SetHighestAbility "Hoarfrost" "Hoarfrost"
	call SetHighestAbility "Lethargy" "Lethargy"
	call SetHighestAbility "SpiritStrike" "Spirit Strike"
	call SetHighestAbility "WintersRoar" "Winter's Roar"
	call SetHighestAbility "KissofNagSuul" "Kiss of Nag-Suul"

	;; === NUKES ===
	;; === BUFFS ===
	call SetHighestAbility "BoonofBoqobol" "Boon of Boqobol"
	call SetHighestAbility "BoonofBosrid" "Boon of Bosrid"
	call SetHighestAbility "BoonofAlcipus" "Boon of Alcipus"
	call SetHighestAbility "Infusion" "Infusion"
	call SetHighestAbility "LifeWard" "Life Ward"
	call SetHighestAbility "OraclesSight" "Oracle's Sight"
	call SetHighestAbility "RakurrsGrace" "Rakurr's Grace"
	call SetHighestAbility "SkinofRakurr" "Skin of Rakurr"
	call SetHighestAbility "SpiritofRakurr" "Spirit of Rakurr"
	call SetHighestAbility "SpeedofRakurr" "Speed of Rakurr"
	call SetHighestAbility "BoonofRakurr" "Boon of Rakurr"
	call SetHighestAbility "RakurrsGiftofSpeed" "Rakurr's Gift of Speed"
	call SetHighestAbility "RakurrsGiftofGrace" "Rakurr's Gift of Grace"
	call SetHighestAbility "AvataroftheHunter" "Avatar of the Hunter"
	call SetHighestAbility "AvataroftheMystic" "Avatar of the Mystic"
	call SetHighestAbility "FavoroftheHunter" "Favor of the Hunter"
	call SetHighestAbility "SpiritsBountifulBlessing" "Spirit's Bountiful Blessing"

	
	;; === PET STUFF ===
	call SetHighestAbility "SummonAttendantofRakurr" "Summon Attendant of Rakurr"
	call SetHighestAbility "HealAttendant" "Heal Attendant"
	;; === MISC ===
	call SetHighestAbility "GraspofGoromund" "Grasp of Goromund"
	call SetHighestAbility "RitualofSacrifice" "Ritual of Sacrifice"
	call SetHighestAbility "Snarl" "Snarl"
	call SetHighestAbility "Hamstring" "Hamstring"
	call SetHighestAbility "HuntersShroud" "Hunter's Shroud"
	call SetHighestAbility "CurseofFrailty" "Curse of Frailty"
	call SetHighestAbility "Purge" "Purge"
	call SetHighestAbility "RemoveCurse" "Remove Curse"
	
	;; Set Forms
	if ${Me.Form["Strong Spirit Bond: Skamadiz"](exists)}
		MeleeForm:Set["Strong Spirit Bond: Skamadiz"]
	if ${Me.Form["Strong Spirit Bond: Krigus"](exists)}
		EnergyForm:Set["Strong Spirit Bond: Krigus"]
	if ${Me.Form["Strong Spirit Bond: Nag-Suul"](exists)}
		SpellForm:Set["Strong Spirit Bond: Nag-Suul"]

	;;;;;;;;;;;;;;
	;; Put weapon checks here so that we do not crash the script.
	;; If the script crashes, it's better here than fighting a mob
	if ${Me.Inventory[CurrentEquipSlot,Primary Hand](exists)}
	{
		LastPrimary:Set[${Me.Inventory[CurrentEquipSlot,Primary Hand]}]
		waitframe
	}
	if ${Me.Inventory[CurrentEquipSlot,Secondary Hand](exists)}
	{
		LastSecondary:Set[${Me.Inventory[CurrentEquipSlot,Secondary Hand]}]
		waitframe
	}
	if ${Me.Inventory[CurrentEquipSlot,Two Hands](exists)}
	{
		LastPrimary:Set[${Me.Inventory[CurrentEquipSlot,Two Hands]}]
		waitframe
	}
	if ${Me.Inventory["Zephyrkin, Eye of the Mistral Storm"](exists)}
	{
		haveZephyrkinShield:Set[TRUE]
		waitframe
	}


	;; preset Tank & TankID
	if ${Me.DTarget(exists)}
	{
		Tank:Set[${Me.DTarget.Name}]
		TankID:Set[${Me.DTarget.ID}]
	}
		
		
	;-------------------------------------------
	; Build and Import XML Data
	;-------------------------------------------
	LavishSettings[SHA]:Clear
	LavishSettings:AddSet[SHA]
	LavishSettings[SHA]:AddSet[General-${Me.FName}]
	LavishSettings[SHA]:Import[${Script.CurrentDirectory}/Saves/SHA_Save.xml]

	General:Set[${LavishSettings[SHA].FindSet[General-${Me.FName}].GUID}]

	StartAttack:Set[${General.FindSetting[StartAttack,99]}]
	DelayAttack:Set[${General.FindSetting[DelayAttack,3]}]
	doFace:Set[${General.FindSetting[doFace,TRUE]}]
	doNPC:Set[${General.FindSetting[doNPC,TRUE]}]
	doAggroNPC:Set[${General.FindSetting[doAggroNPC,TRUE]}]
	doDebuff:Set[${General.FindSetting[doDebuff,TRUE]}]
	doLoot:Set[${General.FindSetting[doLoot,TRUE]}]
	doDeAggro:Set[${General.FindSetting[doDeAggro,TRUE]}]
	doSummonPets:Set[${General.FindSetting[doSummonPets,TRUE]}]
	doHuntersShroud:Set[${General.FindSetting[doHuntersShroud,FALSE]}]
	doLevitate:Set[${General.FindSetting[doLevitate,FALSE]}]
	doPhysical:Set[${General.FindSetting[doPhysical,TRUE]}]
	doSpiritual:Set[${General.FindSetting[doSpiritual,TRUE]}]
	doCold:Set[${General.FindSetting[doCold,TRUE]}]
	doMelee:Set[${General.FindSetting[doMelee,TRUE]}]
	doRangedAttack:Set[${General.FindSetting[doRangedAttack,TRUE]}]
	doSpell:Set[${General.FindSetting[doSpell,TRUE]}]
	doUseWeapon:Set[${General.FindSetting[doUseWeapon,TRUE]}]
	;doFollow:Set[${General.FindSetting[doFollow,TRUE]}]
	FollowDistance1:Set[${General.FindSetting[FollowDistance1,3]}]
	FollowDistance2:Set[${General.FindSetting[FollowDistance2,5]}]
	doTankOnly:Set[${General.FindSetting[doTankOnly,FALSE]}]
	doGroupOnly:Set[${General.FindSetting[doGroupOnly,FALSE]}]
	doSmallHeal:Set[${General.FindSetting[doSmallHeal,TRUE]}]
	doBigHeal:Set[${General.FindSetting[doBigHeal,TRUE]}]
	doEmrgHeal:Set[${General.FindSetting[doEmrgHeal,TRUE]}]
	doLifeWard:Set[${General.FindSetting[doLifeWard,TRUE]}]
	doAegisofLife:Set[${General.FindSetting[doAegisofLife,FALSE]}]
	SmallHealPct:Set[${General.FindSetting[SmallHealPct,65]}]
	BigHealPct:Set[${General.FindSetting[BigHealPct,50]}]
	EmrgHealPct:Set[${General.FindSetting[EmrgHealPct,35]}]
	LifeWardPct:Set[${General.FindSetting[LifeWardPct,85]}]
	AegisofLifePct:Set[${General.FindSetting[AegisofLifePct,80]}]


	;; Turn on our events
	Event[OnFrame]:AttachAtom[SHA_AlwaysCheck]
	Event[VG_OnIncomingText]:AttachAtom[SHA_ChatEvent]
	Event[VG_OnIncomingCombatText]:AttachAtom[SHA_ChatEvent]
	Event[VG_OnPawnSpawned]:AttachAtom[SHA_PawnSpawned]
	Event[VG_onAlertText]:AttachAtom[SHA_AlertEvent]

	
	;; Load the UI
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	wait 5
	ui -reload -skin VGSkin "${Script.CurrentDirectory}/VG-Shaman.xml"
	wait 5
	
	

	;Script:Squelch
	;declare	TotalKills	int	global	0
	;declare	tempXPHour	int	global	0
	;declare	TotalKillsHour	int	global	0
	;TotalKills:Set[0]
	;tempXPHour:Set[0]
	;TotalKillsHour:Set[0]
	;HUD -add KillsHUD 850,855 		"  CoolDown: ${VG.InGlobalRecovery}"
	;HUD -add XPHUD 850,870 			"   Casting: ${Me.IsCasting}"
	;HUD -add IsDeadHUD 850,885	 	"AreWeReady: ${Check.AreWeReady}"
	;HUD -add TypeHUD 850,900		"    Eating: ${Check.AreWeEating}"
	;HUD -add FormHUD 850,915		"   Posture: ${Pawn[me].Posture}"
	;Script:Unsquelch
	
	VGExecute "/setfog 444444, 999999, 100, 100, 240"
}


