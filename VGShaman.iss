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
variable int version = 20100831.01
;------------------------------------------------
function main()
{
	ext -require isxvg
	do
	{
		waitframe
	}
	while !${ISXVG.IsReady}
	
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
	Tank:Set[${Me.DTarget.Name}]
	TankID:Set[${Me.DTarget.ID}]
	FollowT:Set[${Tank}]
	FollowID:Set[${TankID}]
	wait 10

	; Load up the UI panel
	ui -reload "${UISkin}"
	ui -reload -skin VGSkin "${UIFile}"
	wait 20
	call SetBuffButtons

	do
	{
		if "${Paused}"
		{
			do
			{
				if ${QueuedCommands}
					ExecuteQueued
				wait 1
			}
			while "${Paused} && ${isRunning}"
		}
		if ${isRunning}
		{
			if ${Me.ToPawn.IsStunned}
			{
				do
				{
					waitframe
				}
				while ${Me.ToPawn.IsStunned}
			}
			if ${doFollow}
			{
				doMove:Set[TRUE]
				call Check_Dist
			}
			else
			{
				doMove:Set[FALSE]
			}
			call SelfBuff
			call Check_Health
			call Fight
			call Harvest
			call Cannibalize
			if ${doLoot} && ${Me.Target.Type.Equal[Corpse]}
			{
				call Loot
			}
			if ${QueuedCommands}
				ExecuteQueued
		}
	}
	while ${isRunning}
}

;================================================
function Check_Dist()
{
	if ${Pawn[${FollowT}].Distance} > ${FollowDist}
	{
		call MoveCloser ${Pawn[${FollowT}].X} ${Pawn[${FollowT}].Y} ${FollowDist}
		;call movetoobject ${Pawn[${FollowT}].ID} ${FollowDist} 0
	}
}

;================================================
function Check_Health()
{
	if "${Me.DTarget.ID}!=${TankID}"
	{
		Pawn[id,${TankID}]:Target
	}
	if "${Me.HealthPct}<${MeHealPct}"
	{
		Pawn[me]:Target
		Me.Ability[${HealSmall}]:Use
		Pawn[id,${TankID}]:Target
		call MeCasting
	}
	if "${Me.DTargetHealth}==0 && !${Pawn[id,${TankID}].IsDead}"
	{
		Pawn[me]:Target
		wait 5
		Pawn[id,${TankID}]:Target
		wait 10
		return
	}
	if "${Me.DTargetHealth}<${HealEmgPct} && !${Me.IsCasting} && ${Me.Ability[${HealEmg}].IsReady} && ${Me.Energy}>${Me.Ability[${HealEmg}].EnergyCost}"
	{
		Me.Ability[${HealEmg}]:Use
		call MeCasting
		return
	}
	if "${Me.DTargetHealth}<${HealSmallPct} && !${Me.IsCasting} && ${Me.Ability[${HealSmall}].IsReady} && ${Me.Energy}>${Me.Ability[${HealSmall}].EnergyCost}"
	{
		Me.Ability[${HealSmall}]:Use
		call MeCasting
		return
	}
	if "${Me.DTargetHealth}<${HealBigPct} && !${Me.IsCasting} && ${Me.Ability[${HealBig}].IsReady} && ${Me.Energy}>${Me.Ability[${HealBig}].EnergyCost}"
	{
		Me.Ability[${HealBig}]:Use
		call MeCasting
		return
	}
	if "${Me.DTargetHealth}<${HealReactPct} && !${Me.IsCasting} && ${Me.Ability[${HealReactive}].IsReady} && !${reactiveInUse}"
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
	  if "${Hurt}"
	  {
	  	Pawn[id,${Group[${Lowest}].ID}]:Target
	  	wait 5
			Me.Ability[${HealSmall}]:Use
			call MeCasting
			return
	  }
	}
	if "${Me.HavePet} && ${Me.Pet.Health}<=35 && ${Me.Ability[${HealPet1}].IsReady} && ${Me.EnergyPct}>20"
	{
		Me.Ability[${HealPet1}]:Use
		call MeCasting
	}
}

;===========================================================================
function Loot()
{
	if "!${Me.Target(exists)}" 
	{
		return
	}
	if "${Me.Target.Type.Equal[Corpse]}"
	{
		if "!${Me.IsLooting}"
		{
			Me.Target:LootAll
			do
			{
				waitframe
			}
			while "${Me.IsLooting}"
			wait 5
			VGExecute "/cleartargets"
		}
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
	}
	while "${Me.IsCasting}"
	wait 5
	do
	{
		wait 1
	}
	while "${VG.InGlobalRecovery}"
	waitframe
}

;================================================
function Harvest()
{
	if "${doAutoHarvest} && (${Me.Target.Type.Equal[Resource]} || ${Me.Target.IsHarvestable}) && ${Me.Target.Distance}<5 && ${Me.ToPawn.CombatState}==0"
	{
		VGExecute /autoattack
		wait 10
	}
}

;================================================
function Fight()
{
	if "${Pawn[${Tank}].Name(exists)} && ${Pawn[${Tank}].Distance}<=40"
	{
		VGExecute /assist ${Tank}
	}
	if "!${Me.Target(exists)} || ${Me.Target.Type.Equal[Corpse]} || ${Me.TargetHealth}==0 || (${Me.IsGrouped} && ${Me.Target.Owner(exists)} && !${Me.Target.OwnedByMe}) || !${Me.Target.HaveLineOfSightTo}" 
	{
		return
	}
	if "(${Me.Target.Type.Equal[NPC]} || ${Me.Target.Type.Equal[AggroNPC]}) && ${Me.TargetHealth}<${EngagePct} && ${Me.DTarget.CombatState}==1"
	{
		if "${doMeleeMove} && ${Me.Target.Distance}>5 && ${Me.Target.Distance}<12 && ${Me.TargetHealth}<${EngagePct}"
		{
			call MoveCloser ${Me.Target.X} ${Me.Target.Y} 3
			;call movetoobject ${Me.Target.ID} 3 1
		}
		if "${Me.HavePet} && ${Me.Pet.ToPawn.CombatState}==0"
		{
			VGExecute /pet attack
		}
		if "${doFace} && (${doSlow} || ${doDots} || ${doDebuff} || ${doMelee} || ${doNuke}) && ${Me.Target.Distance}<=15"
		{
			;face ${Me.Target.X} ${Me.Target.Y}
			Face:Pawn[${Me.Target.ID}]
		}
		if "${Me.Ability[${Finisher1}].IsReady}"
		{
			Me.Ability[${Finisher1}]:Use
			call MeCasting
			return
		}
		if "${Me.Ability[${Finisher2}].IsReady}"
		{
			Me.Ability[${Finisher2}]:Use
			call MeCasting
			return
		}
		if "${Me.Ability[${Finisher3}].IsReady}"
		{
			Me.Ability[${Finisher3}]:Use
			call MeCasting
			return
		}
		if "${doSlow} && !${Me.TargetMyDebuff[${Slow1}](exists)} && ${Me.TargetHealth}>=20 && ${Me.Target.HaveLineOfSightTo} && ${Me.Encounter}<3"
		{
			Me.Ability[${Slow1}]:Use
			call MeCasting
			return
		}
		if "${doDebuff} && !${Me.TargetMyDebuff[${Debuff1}](exists)} && ${Me.TargetHealth}>=20 && ${Me.Target.HaveLineOfSightTo} && ${Me.Encounter}<3"
		{
			Me.Ability[${Debuff1}]:Use
			call MeCasting
			return
		}
		if ${Me.HavePet}
		{
			if ${Me.Pet.Ability[${PetAbility1}].IsReady}
			{
				Me.Pet.Ability[${PetAbility1}]:Use
			}
			if ${Me.Pet.Ability[${PetAbility2}].IsReady}
			{
				Me.Pet.Ability[${PetAbility2}]:Use
			}
			if ${Me.Pet.Ability[${PetAbility3}].IsReady}
			{
				Me.Pet.Ability[${PetAbility3}]:Use
			}
		}
		if "${doDots} && ${Me.TargetHealth}>=20 && ${Me.EnergyPct}>30"
		{
			if "!${Me.TargetMyDebuff[${Dot1}](exists)}"
			{
				Me.Ability[${Dot1}]:Use
				call MeCasting
				return
			}
			if "!${Me.TargetMyDebuff[${Dot2}](exists)}"
			{
				Me.Ability[${Dot2}]:Use
				call MeCasting
				return
			}
		}
		if ${doMelee} && ${Me.Target.Distance}<=4
		{
			Me.Target:Face
			if "${Me.Ability[${Melee1}].IsReady} && ${Me.Endurance}>30"
			{
				if ${Me.Target.Distance}>5 && ${doMeleeMove}
					call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4
					;call movetoobject ${Me.Target.ID} 4 1
				Me.Ability[${Melee1}]:Use
				call MeCasting
				return
			}
			if "${Me.Ability[${Melee6}].IsReady} && ${Me.Endurance}>15"
			{
				if ${Me.Target.Distance}>5 && ${doMeleeMove}
					call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4
					;call movetoobject ${Me.Target.ID} 4 1
				Me.Ability[${Melee6}]:Use
				call MeCasting
				return
			}
			if "!${Me.TargetMyDebuff[${Melee5}](exists)} && ${Me.Ability[${Melee5}].IsReady} && ${Me.Endurance}>30"
			{
				if ${Me.Target.Distance}>5 && ${doMeleeMove}
					call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4
					;call movetoobject ${Me.Target.ID} 4 1
				Me.Ability[${Melee5}]:Use
				call MeCasting
				return
			}
			if "!${Me.TargetMyDebuff[${Melee2}](exists)} && ${Me.Ability[${Melee2}].IsReady} && ${Me.Endurance}>30"
			{
				if ${Me.Target.Distance}>5 && ${doMeleeMove}
					call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4
					;call movetoobject ${Me.Target.ID} 4 1
				Me.Ability[${Melee2}]:Use
				call MeCasting
				return
			}
			if "!${Me.TargetMyDebuff[${Melee3}](exists)} && ${Me.Ability[${Melee3}].IsReady} && ${Me.Endurance}>30"
			{
				if ${Me.Target.Distance}>5 && ${doMeleeMove}
					call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4
					;call movetoobject ${Me.Target.ID} 4 1
				Me.Ability[${Melee3}]:Use
				call MeCasting
				return
			}
			if "!${Me.TargetMyDebuff[${Melee4}](exists)} && ${Me.Ability[${Melee4}].IsReady} && ${Me.Endurance}>30"
			{
				if ${Me.Target.Distance}>5 && ${doMeleeMove}
					call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4
					;call movetoobject ${Me.Target.ID} 4 1
				Me.Ability[${Melee4}]:Use
				call MeCasting
				return
			}
		}
		if "${doNuke} && ${Me.EnergyPct}>60"
		{
			if "${Me.Ability[${Nuke2}].IsReady}"
			{
				Me.Ability[${Nuke2}]:Use
				call MeCasting
				return
			}
			if "${Me.Ability[${Nuke1}].IsReady}"
			{
				Me.Ability[${Nuke1}]:Use
				call MeCasting
				return
			}
		}
	}
}

;================================================
function Cannibalize()
{
	if "${Me.DTargetHealth}>70"
	{
		if "${Me.EnergyPct}<=85 && ${Me.HealthPct}>=50 && ${Me.InCombat} && ${Me.Ability[${HealthCanni1}].IsReady}"
		{
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
	  return
	}
}

;================================================
function buffGroup()
{
	call buffPlayer ${Me.FName}
	if ${Me.IsGrouped}
	{
		bGMember:Set[1]
		do
		{
			call buffPlayer "${Group[${bGMember}].Name}"
		}
		while ${Group[${bGMember:Inc}].ID(exists)}
	}
	else
	{
		call buffPlayer "${Tank}"
	}
	nextBuff:Set[1]
	if ${GroupBuff[1].Length}>0
	{
		do
		{
			do
			{
				waitframe
			}
			while !${Me.Ability[${GroupBuff[${nextBuff}]}].IsReady}
			Me.Ability[${GroupBuff[${nextBuff}]}]:Use
			call MeCasting
		}
		while ${GroupBuff[${nextBuff:Inc}].Length}>0
	}
}

;================================================
function buffPlayer(string player2buff)
{
	Pawn[${player2buff}]:Target
	wait 5
	nextBuff:Set[1]
	do
	{
		do
		{
			waitframe
		}
		while !${Me.Ability[${Buff[${nextBuff}]}].IsReady}
		Me.Ability[${Buff[${nextBuff}]}]:Use
		call MeCasting
	}
	while ${Buff[${nextBuff:Inc}].Length}>0
}

;================================================
function shortbuffGroup(string shortbuff)
{
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

;================================================
function shortbuffPlayer(string shortbuff2, string player2buff)
{
	Pawn[${player2buff}]:Target
	wait 5
	do
	{
		waitframe
	}
	while !${Me.Ability[${shortbuff2}].IsReady}
	Me.Ability[${shortbuff2}]:Use
	call MeCasting
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
	Pawn[${player2buff}]:Target
	wait 5
	do
	{
		waitframe
	}
	while !${Me.Ability[${RezStone}].IsReady}
	Me.Ability[${RezStone}]:Use
	call MeCasting
}

;================================================
function rezPlayer(string player2buff)
{
	Pawn[${player2buff}]:Target
	if ${Me.InCombat}
	{
		wait 5
		do
		{
			waitframe
		}
		while !${Me.Ability[${CombatRez}].IsReady}
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
		while !${Me.Ability[${Rez}].IsReady}
		Me.Ability[${Rez}]:Use
		call MeCasting
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
