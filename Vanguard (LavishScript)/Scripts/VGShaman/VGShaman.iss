/*
* Shaman Heal Bot Script
* Written By: Zeek
*
* Special Thanks To:
*	Amadeus & Lax: Withtout which
*    this script would Not be possible.
* 	Dontdoit: Assistance with code/testing and ui.
*
* Zandros: Patched to work with with latest ISXVG
*    with some minor improvements
*/
#include ./VGShaman/ZTG/includeVariables.iss
#include ./VGShaman/ZTG/includeSHM.iss
#include ./VGShaman/Includes/moveCloser.iss
#include ./VGShaman/Includes/Obj_Face.iss
;#include ./VGShaman/Common/moveto.iss
;#include ./VGShaman/Common/faceslow.iss

variable obj_Face Face

variable string UIFile = "${Script.CurrentDirectory}/ZTG/VGShamanUI.xml"
variable string UISkin = "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"

variable bool isRunning = TRUE
variable bool Paused = TRUE
variable bool doSlow = TRUE
variable bool doDots = FALSE
variable bool doDebuff = FALSE
variable bool doNuke = FALSE
variable bool doMelee = FALSE
variable bool doMeleeMove = FALSE
variable bool doLoot = FALSE
variable bool doFollow = TRUE
variable bool doFace = TRUE
variable bool doAutoHarvest = FALSE
variable bool reactiveInUse = FALSE
variable string PausedText = "Paused"
variable int MeHealPct = 60
variable int HealEmgPct = 30
variable int HealSmallPct = 50
variable int HealBigPct = 65
variable int HealReactPct = 85
variable int RestHealPct = 70
variable int FollowDist = 6
variable int EngagePct = 95
variable string Tank
variable int64 TankID
variable string FollowT
variable int64 FollowID
variable int GMember
variable int bGMember
variable int GBCount
variable int Hurt
variable int Lowest
variable int nextBuff
variable string CurrentChunk
variable bool doEcho = TRUE
variable int NextDelayCheck = ${Script.RunningTime}
variable int version = 20110903.01

;------------------------------------------------
function main()
{
	ext -require isxvg
	wait 100 ${ISXVG.IsReady}
	if !${ISXVG.IsReady}
	{
		echo "Unable to load ISXVG, exiting script"
		endscript VGShaman
	}
	EchoIt "Started VGShaman Script"
	wait 30 ${Me.Chunk(exists)}
	CurrentChunk:Set[${Me.Chunk}]
	
	
	Event[VG_onGroupMemberBooted]:AttachAtom[VG_Group_Change]
	Event[VG_onGroupMemberAdded]:AttachAtom[VG_Group_Change]
	Event[VG_onGroupJoined]:AttachAtom[VG_Group_Change]
	Event[VG_onGroupFormed]:AttachAtom[VG_Group_Change]
	Event[VG_onGroupDisbanded]:AttachAtom[VG_Group_Change]
	Event[VG_onGroupBooted]:AttachAtom[VG_Group_Change]
	Event[VG_onGroupMemberCountChange]:AttachAtom[VG_Group_Change]

	;; This event is added and used by MoveCloser
	Event[VG_onHitObstacle]:AttachAtom[Bump]

	call SetVariables
	call SetAbilities
	
	EchoIt "Prepping UI..."

	Tank:Set[${Me.DTarget.Name}]
	TankID:Set[${Me.DTarget.ID}]
	FollowT:Set[${Tank}]
	FollowID:Set[${TankID}]

	; Load up the UI panel
	ui -reload "${UISkin}"
	ui -reload -skin VGSkin "${UIFile}"
	wait 5
	call SetBuffButtons
	
	EchoIt "Ready"

	do
	{
		;; we are useless if we are stunned
		if ${Me.ToPawn.IsStunned}
		{
			do
			{
				waitframe
			}
			while ${Me.ToPawn.IsStunned}
		}
		
		;; check if we need to stop all melee attacks
		call CheckMeleeAttacks

		;; handle all queued commands
		if ${QueuedCommands}
		{
			ExecuteQueued
		}

		;; perform this if we are not paused
		if !${Paused}
		{
			;; check to see if we need to move once every 1/2 second, saves FPS
			if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextDelayCheck}]}/500]}>1
			{
				call Check_Dist
				call Harvest
				call Loot
				call Check_Health
				;call SelfBuff
				call Cannibalize
				NextDelayCheck:Set[${Script.RunningTime}]
			}
			
			;; go attack the target if we have one
			call Fight
		}
	}
	while ${isRunning}
}

;================================================
function:bool CheckMeleeAttacks()
{
	variable bool StopAttacks = FALSE
	if ${Me.Target(exists)} && ${Me.Target.Distance}<30 && ${Me.Target.HaveLineOfSightTo} && !${Me.Target.IsDead}
	{
		;-------------------------------------------
		; FURIOUS - we do not want to plow through Furious with melee attacks (melee)
		;-------------------------------------------
		if ${Me.TargetBuff[Furious](exists)} || ${Me.TargetBuff[Furious Rage](exists)} || ${isFurious}
		{
			StopAttacks:Set[TRUE]
		}
		;-------------------------------------------
		; TARGETBUFFS - we do not want to attack during these (melee/spells)
		;-------------------------------------------
		if ${Me.TargetBuff[Aura of Death](exists)} || ${Me.TargetBuff[Frightful Aura](exists)}
		{
			StopAttacks:Set[TRUE]
		}
		elseif ${Me.TargetBuff[Major Enchantment: Ulvari Flame](exists)} || ${Me.Effect[Mark of Verbs](exists)}
		{
			StopAttacks:Set[TRUE]
		}
		elseif ${Me.TargetBuff[Major Disease: Fire Advocate](exists)} || ${Me.Effect[Devout Foeman I](exists)} || ${Me.Effect[Devout Foeman II](exists)} || ${Me.Effect[Devout Foeman III](exists)}
		{
			StopAttacks:Set[TRUE]
		}
		elseif ${Me.Target.Type.Equal[Group Member]} || ${Me.Target.Type.Equal[Pet]}
		{
			StopAttacks:Set[TRUE]
		}
		elseif ${Me.Target.Distance}>5
		{
			StopAttacks:Set[TRUE]
		}
	}
	if !${Me.Target(exists)}
	{
		StopAttacks:Set[TRUE]
	}
	
	if ${StopAttacks}
	{
		call MeleeAttackOff
		return TRUE
	}
	return FALSE
}

;================================================
function MeleeAttackOff()
{
	if ${GV[bool,bIsAutoAttacking]}
	{
		;; Turn off auto-attack if target is not a resource
		if !${Me.Target.Type.Equal[Resource]}
		{
			Me.Ability[Auto Attack]:Use
			wait 10 !${GV[bool,bIsAutoAttacking]}
		}
	}
}

;================================================
function Check_Dist()
{
	if ${doFollow}
	{
		if ${Pawn[name,${FollowT}](exists)}
		{
			;; did target move out of rang?
			if ${Pawn[name,${FollowT}].Distance}>=${FollowDist} && !${Paused}
			{
				variable bool AreWeMoving = FALSE
				;; start moving until target is within range
				while !${Paused} && ${Pawn[name,${FollowT}](exists)} && ${Pawn[name,${FollowT}].Distance}>=${FollowDist} && ${Pawn[name,${FollowT}].Distance}<45
				{
					Pawn[name,${FollowT}]:Face
					VG:ExecBinding[moveforward]
					AreWeMoving:Set[TRUE]
					wait .5
				}
				;; if we moved then we want to stop moving
				if ${AreWeMoving}
				{
					VG:ExecBinding[moveforward,release]
				}
			}
		}
	}
}

;================================================
function Check_Health()
{
	if "${Me.DTarget.ID}!=${TankID}"
	{
		Pawn[id,${TankID}]:Target
	}
	if "!${Paused} && ${Me.HealthPct}<${MeHealPct}"
	{
		Pawn[me]:Target
		Me.Ability[${HealSmall}]:Use
		Pawn[id,${TankID}]:Target
		call MeCasting
	}
	if "!${Paused} && ${Me.DTargetHealth}==0 && !${Pawn[id,${TankID}].IsDead}"
	{
		Pawn[me]:Target
		wait 5
		Pawn[id,${TankID}]:Target
		wait 10
		return
	}
	if "!${Paused} && ${Me.DTargetHealth}<${HealEmgPct} && !${Me.IsCasting} && ${Me.Ability[${HealEmg}].IsReady} && ${Me.Energy}>${Me.Ability[${HealEmg}].EnergyCost}"
	{
		Me.Ability[${HealEmg}]:Use
		call MeCasting
		return
	}
	if "!${Paused} && ${Me.DTargetHealth}<${HealSmallPct} && !${Me.IsCasting} && ${Me.Ability[${HealSmall}].IsReady} && ${Me.Energy}>${Me.Ability[${HealSmall}].EnergyCost}"
	{
		Me.Ability[${HealSmall}]:Use
		call MeCasting
		return
	}
	if "!${Paused} && ${Me.DTargetHealth}<${HealBigPct} && !${Me.IsCasting} && ${Me.Ability[${HealBig}].IsReady} && ${Me.Energy}>${Me.Ability[${HealBig}].EnergyCost}"
	{
		Me.Ability[${HealBig}]:Use
		call MeCasting
		return
	}
	if "!${Paused} && ${Me.DTargetHealth}<${HealReactPct} && !${Me.IsCasting} && ${Me.Ability[${HealReactive}].IsReady} && !${reactiveInUse}"
	{
		reactiveInUse:Set[TRUE]
		Execute TimedCommand 450 Script[VGShaman].Variable[reactiveInUse]:Set[FALSE]
		Me.Ability[${HealReactive}]:Use
		call MeCasting
		return
	}
	if "${Me.IsGrouped}"
	{
		Lowest:Set[1]
		Hurt:Set[0]
		GMember:Set[1]
		do
		{
			if "${Group[${GMember}].ID(exists)} && ${Group[${GMember}].Distance}<=25 && ${Group[${GMember}].Health}<${RestHealPct} && ${Group[${GMember}].Health}>0"
			{
				if "${Group[${GMember}].Health}<=${If["${Group[${Lowest}].Health}",${Group[${Lowest}].Health},100]}"
				{
					Lowest:Set[${GMember}]
					Hurt:Set[1]
				}
			}
		}
		while "${GMember:Inc}<=5"
		if "!${Paused} && ${Hurt}"
		{
			Pawn[id,${Group[${Lowest}].ID}]:Target
			wait 5
			Me.Ability[${HealSmall}]:Use
			call MeCasting
			return
		}
	}
	if "!${Paused} && ${Me.HavePet} && ${Me.Pet.Health}<=35 && ${Me.Ability[${HealPet1}].IsReady} && ${Me.EnergyPct}>20"
	{
		Me.Ability[${HealPet1}]:Use
		call MeCasting
	}
}

;===========================================================================
function Loot()
{
	if ${doLoot} && !${Paused} && ${Me.Target(exists)} && ${Me.Target.IsDead} && ${Me.Target.Type.Equal[Corpse]}
	{
		;; if we are not looting then start looting
		if !${Me.IsLooting}
		{
			Loot:BeginLooting
			wait 10 ${Loot.NumItems}
		}
		
		;; start looting 1 item at a time, gaurantee to get all items
		if ${Me.IsLooting}
		{
			if ${Loot.NumItems}
			{
				variable int i
				for ( i:Set[${Loot.NumItems}] ; ${i}>0 ; i:Dec )
				{
					Loot.Item[${i}]:Loot
				}
			}
			else
			{
				Loot:LootAll
			}
		}
		
		;; this will actually stop everything until you deal with the loot, need a timer of some form to break out
		do
		{
			waitframe
		}
		while ${Me.IsLooting}
		
		;; clear target
		VGExecute "/cleartargets"
		wait 5
	}
}

;================================================
function MeCasting()
{
	wait 5
	do
	{
		if ${doFace} && ${Me.Target.ID}
		{
			Face:Pawn[${Me.Target.ID}]
			;face ${Me.Target.X} ${Me.Target.Y}
		}
		waitframe
		call CheckMeleeAttacks
	}
	while "${Me.IsCasting}"
	wait 5
	do
	{
		wait 1
		call CheckMeleeAttacks
	}
	while "${VG.InGlobalRecovery}"
	waitframe
}

;================================================
function Harvest()
{
	if "!${Paused} && ${doAutoHarvest} && (${Me.Target.Type.Equal[Resource]} || ${Me.Target.IsHarvestable}) && ${Me.Target.Distance}<5 && ${Me.ToPawn.CombatState}==0"
	{
		VGExecute /autoattack
		wait 10
	}
}

;================================================
function Fight()
{
	if "!${Paused} && ${Pawn[${Tank}].Name(exists)} && ${Pawn[${Tank}].Distance}<=40"
	{
		VGExecute /assist ${Tank}
	}
	if "${Paused} || !${Me.Target(exists)} || ${Me.Target.Type.Equal[Corpse]} || ${Me.TargetHealth}==0 || (${Me.IsGrouped} && ${Me.Target.Owner(exists)} && !${Me.Target.OwnedByMe}) || !${Me.Target.HaveLineOfSightTo}"
	{
		return
	}
	if "!${Paused} && (${Me.Target.Type.Equal[NPC]} || ${Me.Target.Type.Equal[AggroNPC]}) && ${Me.TargetHealth}<${EngagePct} && ${Me.DTarget.CombatState}==1"
	{
		;-------------------------------------------
		; MOVE CLOSER
		;-------------------------------------------
		if "!${Paused} && ${doFace} && (${doSlow} || ${doDots} || ${doDebuff} || ${doMelee} || ${doNuke}) && ${Me.Target.Distance}<=15"
		{
			Face:Pawn[${Me.Target.ID}]
		}
		if "!${Paused} && ${doMeleeMove} && ${Me.Target.Distance}>5 && ${Me.Target.Distance}<12 && ${Me.TargetHealth}<${EngagePct}"
		{
			echo Moving closer to target
			call MoveCloser ${Me.Target.X} ${Me.Target.Y} 3
			;call movetoobject ${Me.Target.ID} 3 1
		}
		
		;-------------------------------------------
		; SEND PET IN TO ATTACK
		;-------------------------------------------
		if !${Paused} && ${Me.HavePet}
		{
			;; tell pet to start attacking
			if ${Me.Pet.ToPawn.CombatState}==0
			{
				VGExecute /pet attack
			}
			if !${Paused} && ${Me.Pet.Ability[${PetAbility1}].IsReady} && ${Me.Pet.Ability[${PetAbility1}](exists)}
			{
				Me.Pet.Ability[${PetAbility1}]:Use
			}
			if !${Paused} && ${Me.Pet.Ability[${PetAbility2}].IsReady} && ${Me.Pet.Ability[${PetAbility2}](exists)}
			{
				Me.Pet.Ability[${PetAbility2}]:Use
			}
			if !${Paused} && ${Me.Pet.Ability[${PetAbility3}].IsReady} && ${Me.Pet.Ability[${PetAbility3}](exists)}
			{
				Me.Pet.Ability[${PetAbility3}]:Use
			}
		}
		
		;-------------------------------------------
		; CRIT/CHAIN/FINISHERS
		;-------------------------------------------
		if !${Paused} && ${Me.Ability[${Finisher3}].TriggeredCountdown}>0
		{
			if ${Me.Ability[${Finisher2}].IsReady}
			{
				call SpellForm
				call UseAbility "${Finisher2}"
				if ${Return}
				{
					return
				}
			}
			if ${Me.Ability[${Finisher1}].IsReady}
			{
				call MeleeForm
				call UseAbility "${Finisher1}"
				if ${Return}
				{
					return
				}
			}
			if ${Me.Ability[${Finisher3}].IsReady}
			{
				call SpellForm
				call UseAbility "${Finisher3}"
				if ${Return}
				{
					return
				}
			}
		}

		;-------------------------------------------
		; SLOW
		;-------------------------------------------
		if !${Paused} && ${doSlow} && !${Me.TargetMyDebuff[${Slow1}](exists)} && ${Me.TargetHealth}>=20 && ${Me.Target.HaveLineOfSightTo} && ${Me.Encounter}<3
		{
			call SaveEnergyForm
			call UseAbility "${Slow1}"
			if ${Return}
			{
				return
			}
		}
		
		;-------------------------------------------
		; DEBUFF
		;-------------------------------------------
		if "!${Paused} && ${doDebuff} && !${Me.TargetMyDebuff[${Debuff1}](exists)} && ${Me.TargetHealth}>=20 && ${Me.Target.HaveLineOfSightTo} && ${Me.Encounter}<3"
		{
			call SaveEnergyForm
			call UseAbility "${Debuff1}"
			if ${Return}
			{
				return
			}
		}
		
		;-------------------------------------------
		; DOTS
		;-------------------------------------------
		if !${Paused} && ${doDots} && ${Me.TargetHealth}>=20 && ${Me.EnergyPct}>30
		{
			if "!${Paused} && !${Me.TargetMyDebuff[${Dot1}](exists)} && ${Me.Ability[${Dot1}].IsReady} && ${Me.Ability[${Dot1}](exists)}"
			{
			
				call SpellForm
				call UseAbility "${Dot1}"
				if ${Return}
				{
					return
				}
			}
			if "!${Paused} && !${Me.TargetMyDebuff[${Dot2}](exists)} && ${Me.Ability[${Dot2}].IsReady} && ${Me.Ability[${Dot2}](exists)}"
			{
				call SpellForm
				call UseAbility "${Dot2}"
				if ${Return}
				{
					return
				}
			}
		}

		;-------------------------------------------
		; MELEE
		;-------------------------------------------
		if !${Paused} && ${doMelee} && ${Me.Target.Distance}<=4
		{
			;; Face the target
			Me.Target:Face
			
			;; Hamstring
			if "!${Paused} && ${Me.Ability[${Melee6}].IsReady} && ${Me.Ability[${Melee6}](exists)} && ${Me.Endurance}>15"
			{
				if ${Me.Target.Distance}>5 && ${doMeleeMove}
				{
					EchoIt "Moving Closer to ${Me.Target.Name}"
					call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4
				}
				call MeleeForm
				call UseAbility "${Melee6}"
				if ${Return}
				{
					return
				}
			}
			
			;; HammerOfKrigus - 27 Endurance, 60 second DeBuff (STR & CON)
			if "!${Paused} && !${Me.TargetMyDebuff[${Melee2}](exists)} && ${Me.Ability[${Melee2}].IsReady} && ${Me.Ability[${Melee2}](exists)} && ${Me.Endurance}>30"
			{
				if ${Me.Target.Distance}>5 && ${doMeleeMove}
				{
					EchoIt "Moving Closer to ${Me.Target.Name}"
					call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4
				}
				call MeleeForm
				call UseAbility "${Melee2}"
				if ${Return}
				{
					return
				}
			}

			;; BiteOfNagSuul - 27 Endurance, 40 second damage buff
			if "!${Paused} && !${Me.TargetMyDebuff[${Melee5}](exists)} && ${Me.Ability[${Melee5}].IsReady} && ${Me.Ability[${Melee5}](exists)} && ${Me.Endurance}>30"
			{
				if ${Me.Target.Distance}>5 && ${doMeleeMove}
				{
					EchoIt "Moving Closer to ${Me.Target.Name}"
					call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4
				}
				call MeleeForm
				call UseAbility "${Melee5}"
				if ${Return}
				{
					return
				}
			}
			
			;; ViciousBite - 28 Endurance (adds weakness:  Bitten)
			if "!${Paused} && !${Me.TargetMyDebuff[${Melee4}](exists)} && ${Me.Ability[${Melee4}].IsReady} && ${Me.Ability[${Melee4}](exists)} && ${Me.Endurance}>30"
			{
				if ${Me.Target.Distance}>5 && ${doMeleeMove}
				{
					EchoIt "Moving Closer to ${Me.Target.Name}"
					call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4
				}
				call MeleeForm
				call UseAbility "${Melee4}"
				if ${Return}
				{
					return
				}
			}

			;; Strike of Skamadiz - 24 Endurance (adds weakness:  Shaken, exploits weakness:  Bleeding"
			if "!${Paused} && ${Me.Ability[${Melee1}].IsReady} && ${Me.Ability[${Melee1}](exists)} && ${Me.Endurance}>30"
			{
				if ${Me.Target.Distance}>5 && ${doMeleeMove}
				{
					EchoIt "Moving Closer to ${Me.Target.Name}"
					call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4
				}
				call MeleeForm
				call UseAbility "${Melee1}"
				if ${Return}
				{
					return
				}
			}
		
			;; TearingClaw - 22 Endurance (adds weakness:  Flesh Rend)
			if "!${Paused} && !${Me.TargetMyDebuff[${Melee3}](exists)} && ${Me.Ability[${Melee3}].IsReady} && ${Me.Ability[${Melee3}](exists)} && ${Me.Endurance}>30"
			{
				if ${Me.Target.Distance}>5 && ${doMeleeMove}
				{
					EchoIt "Moving Closer to ${Me.Target.Name}"
					call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4
				}
				call MeleeForm
				call UseAbility "${Melee3}"
				if ${Return}
				{
					return
				}
			}
		}
			
		;-------------------------------------------
		; NUKES - reserve some energy for heals
		;-------------------------------------------
		if !${Paused} && ${doNuke} && ${Me.EnergyPct}>60
		{
			;; WintersRoar - 250 Energy, 3 second immobilize, 8 second recast
			if "!${Paused} && ${Me.Ability[${Nuke1}].IsReady} && ${Me.Ability[${Nuke1}](exists)}"
			{
				call SpellForm
				call UseAbility "${Nuke1}"
				if ${Return}
				{
					return
				}
			}
			
			;; SpiritStrike - 205 Energy (adds weakness:  Shaken, exploits weakness:  Chilled)
			if "!${Paused} && ${Me.Ability[${Nuke2}].IsReady} && ${Me.Ability[${Nuke2}](exists)}"
			{
				call SpellForm
				call UseAbility "${Nuke2}"
				if ${Return}
				{
					return
				}
			}
		}
	}
}

;================================================
function MeleeForm()
{
	if ${Me.Form["Spirit Bond: Skamadiz"](exists)}
	{
		if !${Me.CurrentForm.Name.Equal["Spirit Bond: Skamadiz"]}
		{
			Me.Form["Spirit Bond: Skamadiz"]:ChangeTo
			wait .5
		}
	}
}

;================================================
function SpellForm()
{
	if ${Me.Form["Spirit Bond: Nag-Suul"](exists)}
	{
		if !${Me.CurrentForm.Name.Equal["Spirit Bond: Nag-Suul"]}
		{
			Me.Form["Spirit Bond: Nag-Suul"]:ChangeTo
			wait .5
		}
	}
}

;================================================
function SaveEnergyForm()
{
	if ${Me.Form["Spirit Bond: Krigus"](exists)}
	{
		if !${Me.CurrentForm.Name.Equal["Spirit Bond: Krigus"]}
		{
			Me.Form["Spirit Bond: Krigus"]:ChangeTo
			wait .5
		}
	}
}

;================================================
function HealingForm()
{
	if ${Me.Form["Mien of the Mystic"](exists)}
	{
		if !${Me.CurrentForm.Name.Equal["Mien of the Mystic"]}
		{
			Me.Form["Mien of the Mystic"]:ChangeTo
			wait .5
		}
	}
}


;================================================
function Cannibalize()
{
	if "!${Paused} && ${Me.DTargetHealth}>70"
	{
		if "${Me.EnergyPct}<=85 && ${Me.HealthPct}>=50 && ${Me.InCombat} && ${Me.Ability[${HealthCanni1}].IsReady} && ${Me.Ability[${HealthCanni1}](exists)}"
		{
			echo HealthCanni1 - ${HealthCanni1}
			Me.Ability["${HealthCanni1}"]:Use
			do
			{
				wait 5
			}
			while "${Me.IsCasting}"
		}
	}
}

;================================================
function SetBuffButtons()
{
	wait 10
	if ${Me.IsGrouped}
	{
		UIElement[BST@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[BT@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[BG@Buffs@VGShaman Main@VGShaman]:Show
		UIElement[BG1@Buffs@VGShaman Main@VGShaman]:Show

		UIElement[RunST@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[RunT@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[RunG@Buffs@VGShaman Main@VGShaman]:Show
		UIElement[Run1@Buffs@VGShaman Main@VGShaman]:Show

		UIElement[EBST@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[EBT@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[EBG@Buffs@VGShaman Main@VGShaman]:Show
		UIElement[EB1@Buffs@VGShaman Main@VGShaman]:Show

		UIElement[LevST@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[LevT@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[LevG@Buffs@VGShaman Main@VGShaman]:Show
		UIElement[Lev1@Buffs@VGShaman Main@VGShaman]:Show


		UIElement[RSST@Rez@VGShaman Main@VGShaman]:Hide
		UIElement[RST@Rez@VGShaman Main@VGShaman]:Hide
		UIElement[RSG@Rez@VGShaman Main@VGShaman]:Show
		UIElement[RS1@Rez@VGShaman Main@VGShaman]:Show

		UIElement[RezT@Rez@VGShaman Main@VGShaman]:Hide
		UIElement[Rez1@Rez@VGShaman Main@VGShaman]:Show
		UIElement[RezTextT@Rez@VGShaman Main@VGShaman]:Hide
		UIElement[RezText1@Rez@VGShaman Main@VGShaman]:Show
		GBCount:Set[2]
		do
		{
			if ${Group[${GBCount}].ID(exists)}
			{
				UIElement[BG${GBCount}@Buffs@VGShaman Main@VGShaman]:Show
				UIElement[Run${GBCount}@Buffs@VGShaman Main@VGShaman]:Show
				UIElement[EB${GBCount}@Buffs@VGShaman Main@VGShaman]:Show
				UIElement[Lev${GBCount}@Buffs@VGShaman Main@VGShaman]:Show
				UIElement[RS${GBCount}@Rez@VGShaman Main@VGShaman]:Show
				UIElement[Rez${GBCount}@Rez@VGShaman Main@VGShaman]:Show
				UIElement[RezText${GBCount}@Rez@VGShaman Main@VGShaman]:Show
			}
			else
			{
				UIElement[BG${GBCount}@Buffs@VGShaman Main@VGShaman]:Hide
				UIElement[Run${GBCount}@Buffs@VGShaman Main@VGShaman]:Hide
				UIElement[EB${GBCount}@Buffs@VGShaman Main@VGShaman]:Hide
				UIElement[Lev${GBCount}@Buffs@VGShaman Main@VGShaman]:Hide
				UIElement[RS${GBCount}@Rez@VGShaman Main@VGShaman]:Hide
				UIElement[Rez${GBCount}@Rez@VGShaman Main@VGShaman]:Hide
				UIElement[RezText${GBCount}@Rez@VGShaman Main@VGShaman]:Hide
			}
		}
		while ${GBCount:Inc}<6
	}
	else
	{
		UIElement[BST@Buffs@VGShaman Main@VGShaman]:Show
		UIElement[BT@Buffs@VGShaman Main@VGShaman]:Show
		UIElement[BG@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[BG1@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[BG2@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[BG3@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[BG4@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[BG5@Buffs@VGShaman Main@VGShaman]:Hide

		UIElement[RunST@Buffs@VGShaman Main@VGShaman]:Show
		UIElement[RunT@Buffs@VGShaman Main@VGShaman]:Show
		UIElement[RunG@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[Run1@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[Run2@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[Run3@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[Run4@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[Run5@Buffs@VGShaman Main@VGShaman]:Hide

		UIElement[EBST@Buffs@VGShaman Main@VGShaman]:Show
		UIElement[EBT@Buffs@VGShaman Main@VGShaman]:Show
		UIElement[EBG@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[EB1@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[EB2@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[EB3@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[EB4@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[EB5@Buffs@VGShaman Main@VGShaman]:Hide

		UIElement[LevST@Buffs@VGShaman Main@VGShaman]:Show
		UIElement[LevT@Buffs@VGShaman Main@VGShaman]:Show
		UIElement[LevG@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[Lev1@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[Lev2@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[Lev3@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[Lev4@Buffs@VGShaman Main@VGShaman]:Hide
		UIElement[Lev5@Buffs@VGShaman Main@VGShaman]:Hide

		UIElement[RezTextT@Rez@VGShaman Main@VGShaman]:Show
		UIElement[RezText1@Rez@VGShaman Main@VGShaman]:Hide
		UIElement[RezText2@Rez@VGShaman Main@VGShaman]:Hide
		UIElement[RezText3@Rez@VGShaman Main@VGShaman]:Hide
		UIElement[RezText4@Rez@VGShaman Main@VGShaman]:Hide
		UIElement[RezText5@Rez@VGShaman Main@VGShaman]:Hide

		UIElement[RSST@Rez@VGShaman Main@VGShaman]:Show
		UIElement[RST@Rez@VGShaman Main@VGShaman]:Show
		UIElement[RSG@Rez@VGShaman Main@VGShaman]:Hide
		UIElement[RS1@Rez@VGShaman Main@VGShaman]:Hide
		UIElement[RS2@Rez@VGShaman Main@VGShaman]:Hide
		UIElement[RS3@Rez@VGShaman Main@VGShaman]:Hide
		UIElement[RS4@Rez@VGShaman Main@VGShaman]:Hide
		UIElement[RS5@Rez@VGShaman Main@VGShaman]:Hide

		UIElement[RezT@Rez@VGShaman Main@VGShaman]:Show
		UIElement[Rez1@Rez@VGShaman Main@VGShaman]:Hide
		UIElement[Rez2@Rez@VGShaman Main@VGShaman]:Hide
		UIElement[Rez3@Rez@VGShaman Main@VGShaman]:Hide
		UIElement[Rez4@Rez@VGShaman Main@VGShaman]:Hide
		UIElement[Rez5@Rez@VGShaman Main@VGShaman]:Hide
	}
	;
}

;================================================
function SelfBuff()
{
	if "${Me.CurrentForm.Name.Equal[Unbound]}"
	{
		Me.Form[${DefaultForm}]:ChangeTo
		wait 20
	}
	
	;; this will buff individual and group buffs
	call buffPlayer "${Me.FName}"
}

;================================================
function buffGroup()
{
	;; Start with self
	call buffPlayer "${Me.FName}"
	
	
	if ${Me.IsGrouped}
	{
		;; this will buff the whole raid (slow, needs serious rewrite)
		bGMember:Set[1]
		do
		{
			call buffPlayer "${Group[${bGMember}].Name}"
		}
		while ${Group[${bGMember:Inc}].ID(exists)}
	}
	else
	{
		;; buff the Tank if not in group
		call buffPlayer "${Tank}"
	}
	
/*
	;; This will run through the Group Buffs
	nextBuff:Set[1]
	if ${GroupBuff[1].Length}>0
	{
		do
		{
			if ${Me.Ability[${GroupBuff[${nextBuff}]}](exists)}
			{
				do
				{
					waitframe
				}
				while !${Me.Ability["Torch"].IsReady}
				Me.Ability[${GroupBuff[${nextBuff}]}]:Use
				call MeCasting
			}
		}
		while ${GroupBuff[${nextBuff:Inc}].Length}>0
	}
*/
}

;================================================
function buffPlayer(string player2buff)
{
	;; buff only if player is in range
	if ${Pawn[name,${player2buff}](exists)} && ${Pawn[name,${player2buff}].Distance}<25
	{
		vgecho "Buffing:(SUCCESS) ${player2buff}"
		Pawn[${player2buff}]:Target
		wait 5

		
		;; if this GroupBuff exists then we only want to cast these
		if ${Me.Ability[${SpiritsBoutifulBlessing}](exists)}
		{
			;; 1st cast: Spirit Boutiful Blessing
			while !${Me.Ability["Torch"].IsReady} && ${Pawn[name,${player2buff}].Distance}<25
			{
				waitframe
			}
			Me.Ability[${SpiritsBoutifulBlessing}]:Use
			call MeCasting
			
			;; 2nd cast: Favor of the Flame
			while !${Me.Ability["Torch"].IsReady} && ${Pawn[name,${player2buff}].Distance}<25
			{
				waitframe
			}
			Me.Ability[${FavorOfTheFlame}]:Use
			call MeCasting
			
			;; 3rd cast: Acuity
			while !${Me.Ability["Torch"].IsReady} && ${Pawn[name,${player2buff}].Distance}<25
			{
				waitframe
			}
			Me.Ability[${Acuity}]:Use
			call MeCasting
			
			;; done
			return
		}
		
		;; loop through all the available buffs that doesn't buff a group
		nextBuff:Set[1]
		do
		{
			if ${Me.Ability[${Buff[${nextBuff}]}](exists)}
			{
				while !${Me.Ability["Torch"].IsReady} && ${Pawn[name,${player2buff}].Distance}<25
				{
					waitframe
				}
				Me.Ability[${Buff[${nextBuff}]}]:Use
				call MeCasting
			}
		}
		while ${Buff[${nextBuff:Inc}].Length}>0
	}
	else
	{
		vgecho "Buffing: (FAILED) ${player2buff}"
	}
}

;================================================
function shortbuffGroup(string shortbuff)
{
	if ${Me.Ability[${shortbuff}](exists)}
	{
		vgecho Buff: ${shortbuff}
		call shortbuffPlayer "${shortbuff}" "${Me.FName}"
		if ${Me.IsGrouped}
		{
			bGMember:Set[1]
			do
			{
				call shortbuffPlayer "${shortbuff}" "${Group[${bGMember}].Name}"
			}
			while ${Group[${bGMember:Inc}].ID(exists)}
		}
		else
		{
			call shortbuffPlayer "${shortbuff}" "${Tank}"
		}
	}
}

;================================================
function shortbuffPlayer(string shortbuff2, string player2buff)
{
	vgecho Buff: ${shortbuff2}, Player=${player2buff}
	if ${Me.Ability[${shortbuff2}](exists)}
	{
		if ${Pawn[name,${player2buff}](exists)} && ${Pawn[name,${player2buff}].Distance}<25
		{
			Pawn[${player2buff}]:Target
			wait 5
			do
			{
				waitframe
			}
			while !${Me.Ability["Torch"].IsReady}
			Me.Ability[${shortbuff2}]:Use
			call MeCasting
		}
	}
}

;================================================
function stoneGroup()
{
	if ${Me.IsGrouped}
	{
		bGMember:Set[1]
		do
		{
			call stonePlayer "${Group[${bGMember}].Name}"
		}
		while ${Group[${bGMember:Inc}].ID(exists)}
	}
	else
	{
		call stonePlayer "${Tank}"
	}
}

;================================================
function stonePlayer(string player2buff)
{
	vgecho Stone: ${player2buff}
	if ${Me.Ability[${RezStone}](exists)}
	{
		if ${Pawn[name,${player2buff}](exists)}
		{
			Pawn[${player2buff}]:Target
			wait 5
			do
			{
				waitframe
			}
			while !${Me.Ability["Torch"].IsReady}
			Me.Ability[${RezStone}]:Use
			call MeCasting
		}
	}
}

;================================================
function rezPlayer(string player2buff)
{
	vgecho CombatRez: ${player2buff}
	if ${Me.Ability[${CombatRez}](exists)}
	{
		if ${Pawn[name,${player2buff}](exists)}
		{
			Pawn[${player2buff}]:Target
			if ${Me.InCombat}
			{
				wait 5
				do
				{
					waitframe
				}
				while !${Me.Ability["Torch"].IsReady}
				Me.Ability[${CombatRez}]:Use
				call MeCasting
			}
			else
			{
				wait 5
				do
				{
					waitframe
				}
				while !${Me.Ability["Torch"].IsReady}
				Me.Ability[${Rez}]:Use
				call MeCasting
			}
		}
	}
}

;================================================
atom(script) VG_Group_Change()
{
	QueueCommand "call SetBuffButtons"
}

;================================================
function atexit()
{
	; Unload up the UI panel
	ui -unload "${UIFile}"
	ui -unload "${UISkin}"

	Event[VG_onHitObstacle]:DetachAtom[Bump]
	Event[VG_onGroupMemberCountChange]:DetachAtom[VG_Group_Change]
	Event[VG_onGroupMemberBooted]:DetachAtom[VG_Group_Change]
	Event[VG_onGroupMemberAdded]:DetachAtom[VG_Group_Change]
	Event[VG_onGroupJoined]:DetachAtom[VG_Group_Change]
	Event[VG_onGroupFormed]:DetachAtom[VG_Group_Change]
	Event[VG_onGroupDisbanded]:DetachAtom[VG_Group_Change]
	Event[VG_onGroupBooted]:DetachAtom[VG_Group_Change]
	; If ISXEVG isn't loaded, then no reason to run this script.
	echo VGShaman is now ending.
	if (!${ISXVG(exists)})
	{
		return
	}
}
;===================================================
;===              USE AN ABILITY                ====
;===  called from within AttackTarget routine   ====
;===================================================
function:bool UseAbility(string ABILITY)
{
	;-------------------------------------------
	; return if ability does not exist
	;-------------------------------------------
	if !${Me.Ability[${ABILITY}](exists)} || ${Me.Ability[${ABILITY}].LevelGranted}>${Me.Level}
	{
		return FALSE
	}

	;-------------------------------------------
	; execute ability only if it is ready
	;-------------------------------------------
	if ${Me.Ability[${ABILITY}].IsReady}
	{
		;; return if we do not have enough energy
		if ${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.Ability[${ABILITY}].EnergyCost}>${Me.Energy}
		{
			EchoIt "Not enought Energy for ${ABILITY}"
			return FALSE
		}
		;; return if we do not have enough endurance
		if ${Me.Ability[${ABILITY}].EnduranceCost(exists)} && ${Me.Ability[${ABILITY}].EnduranceCost}>${Me.Endurance}
		{
			EchoIt "Not enought Endurance for ${ABILITY}"
			return FALSE
		}
		;; return if the target is outside our range
		if !${Me.Ability[${ABILITY}].TargetInRange} && !${Me.Ability[${ABILITY}].TargetType.Equal[Self]}
		{
			EchoIt "Target not in range for ${ABILITY}"
			return FALSE
		}

		;; now execute the ability
		EchoIt "Used ${ABILITY}"
		Me.Ability[${ABILITY}]:Use

		call MeCasting

		;; say we executed ability successfully
		return TRUE
	}
	;; say we did not execute the ability
	return FALSE
}

