;-----------------------------------------------------------------------------------------------
; VG2Dot.iss
;
; Description - a handy sorc tool for handling 2-dot Elementals
; -----------
; * Loots
; * Hunts
; * Regen Energy
; * Identify Immunities
; * Preconfigured to handle Fire, Ice, Arcane, and Earth Elementals
;
; Revision History
; ----------------
; 20120211 (Zandros)
; * Renamed this from vgtwodot to VG2Dot.  Cleaned-up the folders and files and implemented
;   the LavishNav hunting routines that will map the area and move to waypoints.  Also,
;   fixed several routines to ensure a smoother and better play.
;
; 20120203 (Zandros)
; * Minor adjustments improving Item Management
;
; 20120114 (Zandros)
; * Added Accept Rez, added return to safe spot if no mobs around, added AutoSell and AutoDelete
;
; 20120112 (Zandros)
; * Added ajustable loot variables and tab
;
; 20120110 (Zandros)
; * Fixed the ping-pong between corpses when looting.  Instead of skipping
;   the corpse with loot, it will target the nearest AggroNPC next to the corse
;   resulting better chances to safely loot corpses.  Rewrote the moveto routine
;   and toggling Hunt will stop moving and hunting.
;
; 20120106 (Zandros)
; * changed the wa loot is handled, will no longer loot if AggroNPC is nearby
;   and changed the way how hunting for targets... way faster than before!
;
; 20111225 (Zandros)
; * Merry Christmas!  Fixed 2 bugs that wouldn't allow attacking the target and
;   identifying target immunity (resists)
;
; 20111224 (Zandros)
; * Improved many routines
;
; 2009 (mmoAddict)
; * Original author of this script
;
;
;===================================================
;===               Includes                     ====
;===================================================
;
#include ./VG2Dot/Includes/FindTarget.iss
#include ./VG2Dot/Includes/MobResists.iss
#include ./VG2Dot/Includes/ItemListTools.iss
#include ./VG2Dot/Includes/Obj_Navigator.iss


;===================================================
;===               Variables                    ====
;===================================================

;; system variables
variable int i
variable bool isRunning = TRUE
variable bool doFire = TRUE
variable bool doArcane = TRUE
variable bool doColdIce = TRUE
variable bool doPhysical = TRUE
variable bool doForget = FALSE
variable string FocusType = "Quartz"
variable string BarrierType = "Force"
variable string LastTargetName = "None"
variable int64 LastTargetID = 0
variable int WhatStepWeOn = 0
variable int TotalKills = 0
variable bool doAcceptRez = FALSE
variable bool doReturnHome = FALSE
variable float HomeX
variable float HomeY
variable int NextItemListCheck = ${Script.RunningTime}
variable bool doChaosVolley = FALSE
variable filepath DebugFilePath = "${Script.CurrentDirectory}/Saves"


;; Loot variables
variable int LootNearRange = 8
variable int LootMaxRange = 40
variable int LootCheckForAggroRadius = 20
variable collection:int64 BlackListTarget

;; UI - Hunt Tab
variable bool doCheckLineOfSight = TRUE
variable bool NoLineOfSight = FALSE
variable bool doCheckForAdds = FALSE
variable bool doCheckForObstacles = TRUE
variable int PullDistance = 22
variable int MaxDistance = 30
variable int MinimumLevel = ${Me.Level}
variable int MaximumLevel = ${Me.Level}
variable int DifficultyLevel = 2
variable bool NeedMoreEnergy = FALSE
variable bool doNPC = FALSE
variable bool doAggroNPC = TRUE

;; Navigator variables
variable int TotalWayPoints = 0
variable int CurrentWayPoint = 0
variable bool doRandomWayPoints = FALSE
variable bool CountUp = FALSE
variable bool doRestartToWP1 = FALSE
variable string CurrentChunk
variable bool BUMP = FALSE

;; initialize our objects
variable(global) Obj_Navigator Navigate

;; XML variables used to store and save data
variable settingsetref Arcane
variable settingsetref Fire
variable settingsetref ColdIce
variable settingsetref Physical
variable settingsetref options
variable settingsetref Buffs
variable settingsetref MyPath

;; UI toggles - excessively alot of toggles
variable bool Do1 = FALSE
variable bool Do2 = FALSE
variable bool Do3 = FALSE
variable bool Do4 = FALSE
variable bool Do5 = FALSE
variable bool Do6 = FALSE
variable bool Do7 = FALSE
variable bool Do8 = FALSE
variable bool Do9 = FALSE
variable bool Do10 = FALSE
variable bool Do11 = FALSE

;===================================================
;===               Main Routine                 ====
;===================================================
function main()
{
	;-------------------------------------------
	; INITIALIZE - setup script
	;-------------------------------------------
	call Initialize

	;-------------------------------------------
	; LOOP THIS INDEFINITELY
	;-------------------------------------------
	while ${isRunning}
	{
		;; Get all buffs up
		call CheckBuffs

		;; Miscellaneous heals, energy regen, and loot
		call MandatoryChecks

		;; Identify target immunuties
		call SetImmunities

		;; cycle through each routine
		call GoDoSomething

		;; If we are in a group then might as well control aggro
		call Forget
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;===================================================
;===         Initialize Subroutine              ====
;===================================================
function Initialize()
{
	;-------------------------------------------
	; Load ISXVG or exit script
	;-------------------------------------------
	ext -require isxvg
	wait 100 ${ISXVG.IsReady}
	if !${ISXVG.IsReady}
	{
		echo "Unable to load ISXVG, exiting script"
		endscript VG2Dot
	}
	echo "Started VG2Dot Script"
	wait 30 ${Me.Chunk(exists)}

	;-------------------------------------------
	; Delete our debug file so that it doesn't get too big
	;-------------------------------------------
	if ${DebugFilePath.FileExists[/Debug.txt]}
		rm "${DebugFilePath}/Debug.txt"

	;-------------------------------------------
	; Reload the UI
	;-------------------------------------------
	call loadxmls
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	wait 5
	ui -reload -skin VGSkin "${Script.CurrentDirectory}/VG2Dot.xml"
	UIElement[VG2Dot]:SetWidth[280]
	UIElement[VG2Dot]:SetHeight[270]
	wait 5

	;-------------------------------------------
	; Populate the UI
	;-------------------------------------------
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if !${Me.Ability[${i}].IsOffensive} && !${Me.Ability[${i}].Type.Equal[Combat Art]} && !${Me.Ability[${i}].IsChain} && !${Me.Ability[${i}].IsCounter} && !${Me.Ability[${i}].IsRescue} && !${Me.Ability[${i}].Type.Equal[Song]}
		{
			if ${Me.Ability[${i}].TargetType.Equal[Self]} || ${Me.Ability[${i}].TargetType.Equal[Defensive]} || ${Me.Ability[${i}].TargetType.Equal[Group]} || ${Me.Ability[${i}].TargetType.Equal[Ally]}
				UIElement[BuffsCombo@Miscfrm@Misc@VGT@VG2Dot]:AddItem[${Me.Ability[${i}].Name}]
		}
	}
	if ${BarrierType.Equal[Force]}
		UIElement[BarrierType@Miscfrm@Misc@VGT@VG2Dot]:SelectItem[1]
	if ${BarrierType.Equal[Fire]}
		UIElement[BarrierType@Miscfrm@Misc@VGT@VG2Dot]:SelectItem[2]
	if ${BarrierType.Equal[Chromatic]}
		UIElement[BarrierType@Miscfrm@Misc@VGT@VG2Dot]:SelectItem[3]
	if ${FocusType.Equal[Quartz]}
		UIElement[FocusType@Miscfrm@Misc@VGT@VG2Dot]:SelectItem[1]
	if ${FocusType.Equal[Aquamarine]}
		UIElement[FocusType@Miscfrm@Misc@VGT@VG2Dot]:SelectItem[2]
	if ${FocusType.Equal[Diamond]}
		UIElement[FocusType@Miscfrm@Misc@VGT@VG2Dot]:SelectItem[3]
	if ${FocusType.Equal[Quicksilver]}
		UIElement[FocusType@Miscfrm@Misc@VGT@VG2Dot]:SelectItem[4]
	if ${FocusType.Equal[Opal]}
		UIElement[FocusType@Miscfrm@Misc@VGT@VG2Dot]:SelectItem[5]

	BuildBuffs

	;-------------------------------------------
	; Find highest level of abilities
	;-------------------------------------------
	;; === BARRIERS ===
	call SetHighestAbility "ForceBarrier" "Force Barrier"
	call SetHighestAbility "FireBarrier" "Fire Barrier"
	call SetHighestAbility "ChromaticBarrier" "Chromatic Barrier"
	;; === FOCUS ===
	call SetHighestAbility "ConjureQuartzFocus" "Conjure Quartz Focus"
	call SetHighestAbility "ConjureAquamarineFocus" "Conjure Aquamarine Focus"
	call SetHighestAbility "ConjureDiamondFocus" "Conjure Diamond Focus"
	call SetHighestAbility "ConjureQuicksilverFocus" "Conjure Quicksilver Focus"
	call SetHighestAbility "ConjureOpalFocus" "Conjure Opal Focus"
	;; === BUFFS ===
	call SetHighestAbility "ArcaneMantle" "Arcane Mantle"
	call SetHighestAbility "ElementalMantle" "Elemental Mantle"
	call SetHighestAbility "AsayasInsight" "Asaya's Insight"
	call SetHighestAbility "NullingWard" "Nulling Ward"
	call SetHighestAbility "SeradonsVision" "Seradon's Vision"
	call SetHighestAbility "SeeInvisibility" "See Invisibility"
	call SetHighestAbility "ChromaticHalo" "Chromatic Halo"
	;; === MISC ===
	call SetHighestAbility "Forget" "Forget"
	call SetHighestAbility "Disenchant" "Disenchant"
	;; === COUNTERS ===
	call SetHighestAbility "Disperse" "${Disperse}"
	call SetHighestAbility "Reflect" "${Reflect}"


	;-------------------------------------------
	; Put in our inventory all our Focus Items
	;-------------------------------------------
	if ${Me.Ability[${ConjureQuartzFocus}](exists)}
	{
		if !${Me.Inventory[Quartz Focus](exists)}
			call executeability "${ConjureQuartzFocus}"
	}
	if ${Me.Ability[${ConjureAquamarineFocus}](exists)}
	{
		if !${Me.Inventory[Aquamarine Focus](exists)}
			call executeability "${ConjureAquamarineFocus}"
	}
	if ${Me.Ability[${ConjureDiamondFocus}](exists)}
	{
		if !${Me.Inventory[Diamond Focus](exists)}
			call executeability "${ConjureDiamondFocus}"
	}
	if ${Me.Ability[${ConjureQuicksilverFocus}](exists)}
	{
		if !${Me.Inventory[Quicksilver Focus](exists)}
			call executeability "${ConjureQuicksilverFocus}"
	}
	if ${Me.Ability[${ConjureOpalFocus}](exists)}
	{
		if !${Me.Inventory[Opal Focus](exists)}
			call executeability "${ConjureOpalFocus}"
	}

	;; Add in our events
	Event[VG_onPawnStatusChange]:AttachAtom[PawnStatusChange]
	Event[VG_OnIncomingText]:AttachAtom[InventoryChatEvent]
	Event[VG_OnIncomingText]:AttachAtom[ChatEvent]
	Event[VG_OnIncomingCombatText]:AttachAtom[ChatEvent]
	Event[VG_onAlertText]:AttachAtom[AlertEvent]


	;; Turn mapping ON
	Navigate:StartMapping
}


;===================================================
;===        GoDoSomething Routine               ====
;===================================================
function GoDoSomething()
{
	;; return if we do not exist in the game
	if !${Me(exists)}
		return

	;; increment our step
	WhatStepWeOn:Inc
	if ${WhatStepWeOn}>11
		WhatStepWeOn:Set[1]

	;; go call the routine Do1 thru Do7
	if ${Do${WhatStepWeOn}}
		call Do${WhatStepWeOn}
}

;===================================================
;===        MandatoryChecks Routine             ====
;===================================================
function MandatoryChecks()
{
	;; return if we do not exist in the game
	if !${Me(exists)}
		return

	waitframe

	;; Execute any queued commands
	if ${QueuedCommands}
	{
		ExecuteQueued
		FlushQueued
	}

	;; Check our Health!!
	if ${Me.HealthPct} < 70 && ${Me.Inventory[Great Roseberries].IsReady}
	{
		Me.Inventory[Great Roseberries]:Use
		wait 3
	}
	if ${Me.EnergyPct} < 50 && ${Me.Inventory[Large MottleBerries].IsReady}
	{
		Me.Inventory[Large MottleBerries]:Use
		wait 3
	}
	if ${Me.HealthPct} < 60 && ${Me.Ability[Conduct].IsReady}
	{
		Pawn[${Me}]:Target
		call executeability "Conduct"
	}

	;; if target doesn't exist or its dead then we will do one of these
	if !${Me.Target(exists)} || ${Me.Target.IsDead}
	{
		;; Get next target if we have an encounter
		if ${Me.Encounter}>0
		{
			Pawn[ID,${Me.Encounter[1].ID}]:Target
			wait 5
			return
		}
	}

	;; Grab an encounter
	if ${Me.Encounter}>0
		call TargetEncounter

	;; if we are not looting then clear the target if it is dead
	if !${Do5}
	{
		if ${Me.Target.IsDead}
		{
			VGExecute /cleartargets
			wait 3
		}
	}

	;; check only once every other second
	if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextItemListCheck}]}/1000]}>=1
	{
		if !${Me.InCombat} && ${Me.Encounter}==0 && !${Me.Target.Type.Equal[AggroNPC]}
		{
			if ${doAutoSell} && ${Me.Target.Type.Equal[Merchant]}
				call SellItemList
			if ${doDeleteSell} || ${doDeleteNoSell}
				call DeleteItemList
		}
		NextItemListCheck:Set[${Script.RunningTime}]
	}

	;; attempt to counter if target is casting
	call CounterIt

}

;===================================================
;===            SetImmunities Atom              ====
;===================================================
function SetImmunities()
{
	;; this will reset the target bug
	if ${Me.InCombat} && !${Me.Target(exists)}
	{
		VGExecute "/cleartargets"
		wait 5
		return
	}

	;; Reset all immunities
	doArcane:Set[TRUE]
	doFire:Set[TRUE]
	doColdIce:Set[TRUE]
	doPhysical:Set[TRUE]

	;; Now, toggle off which ability based upon the target's immunity
	if ${Me.Target(exists)}
	{
		;; Ensure difficulty of target doesn't exist when you do not have a target
		wait 5 ${Me.TargetAsEncounter.Difficulty(exists)}

		;
		; Target Buffs usuly takes 1 second to register
		; which is needed to determine what immunity it has
		;
		;wait 10 ${Me.TargetBuff}>0

		if ${Me.TargetBuff[Electric Form](exists)}
		{
			doArcane:Set[FALSE]
			if !${MobResists.Type.Equal[Arcane]}
			{
				AddArcane "${Me.Target.Name}"
				BuildArcane
				call LavishSave
			}
		}
		if ${Me.TargetBuff[Molten Form](exists)} || ${Me.TargetBuff[Fire Form](exists)}
		{
			doFire:Set[FALSE]
			if !${MobResists.Type.Equal[Fire]} && ${Do8}
			{
				AddFire "${Me.Target.Name}"
				BuildFire
				call LavishSave
			}
		}
		if ${Me.TargetBuff[Ice Form](exists)} || ${Me.TargetBuff[Cold Form](exists)} || ${Me.TargetBuff[Frozen Form](exists)}
		{
			doColdIce:Set[FALSE]
			if !${MobResists.Type.Equal[ColdIce]} && ${Do8}
			{
				AddColdIce "${Me.Target.Name}"
				BuildColdIce
				call LavishSave
			}
		}
		if ${Me.TargetBuff[Earth Form](exists)}
		{
			doPhysical:Set[FALSE]
			if !${MobResists.Type.Equal[Physical]} && ${Do8}
			{
				AddPhysical "${Me.Target.Name}"
				BuildPhysical
				call LavishSave
			}
		}
	}
}

;===================================================
;===             FIRE RESISTANT TARGET          ====
;===================================================
function Do1()
{
	;; we want a live target that is within range
	if !${Me.Target(exists)} || ${Me.Target.IsDead} || ${Me.Target.Distance} > ${Math.Calc[${PullDistance}+1]}
		return

	LastTargetID:Set[${Me.Target.ID}]

	if (${doNPC} && ${Me.Target.Type.Equal[NPC]}) || (${doAggroNPC} && ${Me.Target.Type.Equal[AggroNPC]})
	{
		;; Use these abilities if target is immune to fire
		if ${MobResists.Type.Equal[Fire]} || !${doFire}
		{
			if ${doChaosVolley}
			{
				if ${Me.Ability[Superior Chaos Volley].IsReady} && !${Me.Effect[Chaotic Feedback](exists)}
					call executeability "Superior Chaos Volley"
				if ${Me.Ability[Superior Chaos Volley].IsReady} && ${Me.Effect[Chaotic Feedback](exists)} && ${Me.Effect[Chaotic Feedback].Description.Equal["Spell Damage: +2%"]}
					call executeability "Superior Chaos Volley"
				if ${Me.Ability[Superior Chaos Volley].IsReady} && ${Me.Effect[Chaotic Feedback](exists)} && ${Me.Effect[Chaotic Feedback].Description.Equal["Spell Damage: +5%"]}
					call executeability "Superior Chaos Volley"
				if ${Me.Ability[Superior Chaos Volley].IsReady} && ${Me.Effect[Chaotic Feedback](exists)} && ${Me.Effect[Chaotic Feedback].Description.Equal["Spell Damage: +10%"]} && ${Me.Effect[Chaotic Feedback].TimeRemaining} < 4
					call executeability "Superior Chaos Volley"
			}
			if ${Me.Ability[Cold Wave VII].IsReady}
			{
				call executeability "Cold Wave VII"
				return
			}
			if ${Me.Ability[Inidria's Frigid Blast].IsReady}
			{
				call executeability "Inidria's Frigid Blast"
				return
			}
			if ${Me.Ability[Mimic VII](exists)} && ${Me.Ability[Mimic VII].IsReady}
			{
				call executeability "Mimic VII"
				return
			}
			if ${Me.Ability[Mimic VI](exists)} && ${Me.Ability[Mimic VI].IsReady}
			{
				call executeability "Mimic VI"
				return
			}
			if ${Me.Ability[Seradon's Falling Comet](exists)} && ${Me.Ability[Quickening Jolt].IsReady} && ${Me.Ability[Seradon's Falling Comet].IsReady}
			{
				Me.Ability[Quickening Jolt]:Use
				call executeability "Seradon's Falling Comet"
				return
			}
			if ${Me.Ability[Quickening Jolt].IsReady} && ${Me.Ability[Seradon's Falling Star III].IsReady}
			{
				Me.Ability[Quickening Jolt]:Use
				call executeability "Seradon's Falling Star III"
				return
			}
			if ${Me.Ability[Seradon's Falling Comet](exists)} && ${Me.Ability[Seradon's Falling Comet].IsReady}
			{
				call executeability "Seradon's Falling Comet"
				return
			}
			if ${Me.Ability[Seradon's Falling Star III].IsReady}
			{
				call executeability "Seradon's Falling Star III"
				return
			}
			if ${Me.Ability[Superior Chaos Volley].IsReady}
			{
				call executeability "Superior Chaos Volley"
				return
			}
		}
	}
}

;===================================================
;===            ICE RESISTANT TARGET            ====
;===================================================
function Do2()
{
	;; we want a live target that is within range
	if !${Me.Target(exists)} || ${Me.Target.IsDead} || ${Me.Target.Distance} > ${Math.Calc[${PullDistance}+1]}
		return

	LastTargetID:Set[${Me.Target.ID}]

	if (${doNPC} && ${Me.Target.Type.Equal[NPC]}) || (${doAggroNPC} && ${Me.Target.Type.Equal[AggroNPC]})
	{
		;; Use these abilities if target is immune to Cold/Ice
		if ${MobResists.Type.Equal[ColdIce]} || !${doColdIce}
		{
			if ${doChaosVolley}
			{
				if ${Me.Ability[Superior Chaos Volley].IsReady} && !${Me.Effect[Chaotic Feedback](exists)}
					call executeability "Superior Chaos Volley"
				if ${Me.Ability[Superior Chaos Volley].IsReady} && ${Me.Effect[Chaotic Feedback](exists)} && ${Me.Effect[Chaotic Feedback].Description.Equal["Spell Damage: +2%"]}
					call executeability "Superior Chaos Volley"
				if ${Me.Ability[Superior Chaos Volley].IsReady} && ${Me.Effect[Chaotic Feedback](exists)} && ${Me.Effect[Chaotic Feedback].Description.Equal["Spell Damage: +5%"]}
					call executeability "Superior Chaos Volley"
				if ${Me.Ability[Superior Chaos Volley].IsReady} && ${Me.Effect[Chaotic Feedback](exists)} && ${Me.Effect[Chaotic Feedback].Description.Equal["Spell Damage: +10%"]} && ${Me.Effect[Chaotic Feedback].TimeRemaining} < 4
					call executeability "Superior Chaos Volley"
			}
			if ${Me.Ability[Inidria's Inferno III].IsReady}
			{
				call executeability "Inidria's Inferno III"
				return
			}
			if ${Me.Ability[Incinerate IV].IsReady}
			{
				call executeability "Incinerate IV"
				return
			}
			if ${Me.Ability[Mimic VII](exists)} && ${Me.Ability[Mimic VII].IsReady}
			{
				call executeability "Mimic VII"
				return
			}
			if ${Me.Ability[Mimic VI].IsReady}
			{
				call executeability "Mimic VI"
				return
			}
			if ${Me.Ability[Amplify Destruction].IsReady} && ${Me.Ability[Char VI].IsReady}
			{
				Me.Ability[Amplify Destruction]:Use
				call executeability "Char VI"
				return
			}
			if ${Me.Ability[Amplify Acuity].IsReady} && ${Me.Ability[Char VI].IsReady}
			{
				Me.Ability[Amplify Acuity]:Use
				call executeability "Char VI"
				return
			}
			if ${Me.Ability[Char VI].IsReady}
			{
				call executeability "Char VI"
				return
			}
			if ${Me.Ability[Superior Chaos Volley].IsReady}
			{
				call executeability "Superior Chaos Volley"
				return
			}
		}
	}
}

;===================================================
;===         ELECTRIC RESISTANT TARGET          ====
;===================================================
function Do3()
{
	;; we want a live target that is within range
	if !${Me.Target(exists)} || ${Me.Target.IsDead} || ${Me.Target.Distance} > ${Math.Calc[${PullDistance}+1]}
		return

	LastTargetID:Set[${Me.Target.ID}]

	if (${doNPC} && ${Me.Target.Type.Equal[NPC]}) || (${doAggroNPC} && ${Me.Target.Type.Equal[AggroNPC]})
	{
		;; Use these abilities if target is immune to Arcane
		if ${MobResists.Type.Equal[Arcane]} || !${doArcane}
		{
			if ${Me.Ability[Inidria's Inferno III].IsReady}
			{
				call executeability "Inidria's Inferno III"
				return
			}
			if ${Me.Ability[Incinerate IV].IsReady}
			{
				call executeability "Incinerate IV"
				return
			}
			if ${Me.Ability[Char VI].IsReady}
			{
				call executeability "Char VI"
				return
			}
			if ${Me.Ability[Seradon's Falling Comet](exists)} && ${Me.Ability[Quickening Jolt].IsReady} && ${Me.Ability[Seradon's Falling Comet].IsReady}
			{
				Me.Ability[Quickening Jolt]:Use
				call executeability "Seradon's Falling Comet"
				return
			}
			if ${Me.Ability[Quickening Jolt].IsReady} && ${Me.Ability[Seradon's Falling Star III].IsReady}
			{
				Me.Ability[Quickening Jolt]:Use
				call executeability "Seradon's Falling Star III"
				return
			}
			if ${Me.Ability[Seradon's Falling Comet](exists)} && ${Me.Ability[Seradon's Falling Comet].IsReady}
			{
				call executeability "Seradon's Falling Comet"
				return
			}
			if ${Me.Ability[Seradon's Falling Star III].IsReady}
			{
				call executeability "Seradon's Falling Star III"
				return
			}
			if ${Me.Ability[Blinding Fire II].IsReady}
			{
				call executeability "Blinding Fire II"
				return
			}
		}
	}
}

;===================================================
;===          GO ALL OUT TARGET (Earth)         ====
;===================================================
function Do4()
{
	;; we want a live target that is within range
	if !${Me.Target(exists)} || ${Me.Target.IsDead} || ${Me.Target.Distance} > ${Math.Calc[${PullDistance}+1]}
		return

	LastTargetID:Set[${Me.Target.ID}]

	if (${doNPC} && ${Me.Target.Type.Equal[NPC]}) || (${doAggroNPC} && ${Me.Target.Type.Equal[AggroNPC]})
	{
		;; go all out routine
		if ${MobResists.Type.Equal[None]} || ${MobResists.Type.Equal[Physical]}
		{
			if ${doChaosVolley}
			{
				if ${Me.Ability[Superior Chaos Volley].IsReady} && !${Me.Effect[Chaotic Feedback](exists)}
					call executeability "Superior Chaos Volley"
				if ${Me.Ability[Superior Chaos Volley].IsReady} && ${Me.Effect[Chaotic Feedback](exists)} && ${Me.Effect[Chaotic Feedback].Description.Equal["Spell Damage: +2%"]}
					call executeability "Superior Chaos Volley"
				if ${Me.Ability[Superior Chaos Volley].IsReady} && ${Me.Effect[Chaotic Feedback](exists)} && ${Me.Effect[Chaotic Feedback].Description.Equal["Spell Damage: +5%"]}
					call executeability "Superior Chaos Volley"
				if ${Me.Ability[Superior Chaos Volley].IsReady} && ${Me.Effect[Chaotic Feedback](exists)} && ${Me.Effect[Chaotic Feedback].Description.Equal["Spell Damage: +10%"]} && ${Me.Effect[Chaotic Feedback].TimeRemaining} < 4
					call executeability "Superior Chaos Volley"
			}
			if ${Me.Ability[Inidria's Inferno III].IsReady}
			{
				call executeability "Inidria's Inferno III"
				return
			}
			if ${Me.Ability[Incinerate IV].IsReady}
			{
				call executeability "Incinerate IV"
				return
			}
			if ${Me.Ability[Mimic VII](exists)} && ${Me.Ability[Mimic VII].IsReady}
			{
				call executeability "Mimic VII"
				return
			}
			if ${Me.Ability[Mimic VI].IsReady}
			{
				call executeability "Mimic VI"
				return
			}
			if ${Me.Ability[Seradon's Falling Comet](exists)} && ${Me.Ability[Amplify Destruction].IsReady} && ${Me.Ability[Seradon's Falling Comet].IsReady}
			{
				Me.Ability[Amplify Destruction]:Use
				call executeability "Seradon's Falling Comet"
				return
			}
			if ${Me.Ability[Seradon's Falling Comet](exists)} && ${Me.Ability[Quickening Jolt].IsReady} && ${Me.Ability[Seradon's Falling Comet].IsReady}
			{
				Me.Ability[Quickening Jolt]:Use
				call executeability "Seradon's Falling Comet"
				return
			}
			if ${Me.Ability[Seradon's Falling Comet](exists)} && ${Me.Ability[Amplify Acuity].IsReady} && ${Me.Ability[Seradon's Falling Comet].IsReady}
			{
				Me.Ability[Amplify Acuity]:Use
				call executeability "Seradon's Falling Comet"
				return
			}
			if ${Me.Ability[Quickening Jolt].IsReady} && ${Me.Ability[Amplify Destruction].IsReady} && !${Me.Ability[Seradon's Falling Comet](exists)}
			{
				Me.Ability[Amplify Destruction]:Use
				call executeability "Seradon's Falling Star III"
				return
			}
			if ${Me.Ability[Quickening Jolt].IsReady} && ${Me.Ability[Seradon's Falling Star III].IsReady} && !${Me.Ability[Seradon's Falling Comet](exists)}
			{
				Me.Ability[Quickening Jolt]:Use
				call executeability "Seradon's Falling Star III"
				return
			}
			if ${Me.Ability[Quickening Jolt].IsReady} && ${Me.Ability[Amplify Acuity].IsReady} && !${Me.Ability[Seradon's Falling Comet](exists)}
			{
				Me.Ability[Amplify Acuity]:Use
				call executeability "Seradon's Falling Star III"
				return
			}
			if ${Me.Ability[Seradon's Falling Comet](exists)} && ${Me.Ability[Seradon's Falling Comet].IsReady}
			{
				call executeability "Seradon's Falling Comet"
				return
			}
			if ${Me.Ability[Seradon's Falling Star III].IsReady} && !${Me.Ability[Seradon's Falling Comet](exists)}
			{
				call executeability "Seradon's Falling Star III"
				return
			}
			if ${Me.Ability[Char VI].IsReady}
			{
				call executeability "Char VI"
				return
			}
			if ${Me.Ability[Superior Chaos Volley].IsReady}
			{
				call executeability "Superior Chaos Volley"
				return
			}
		}
	}
}

;===================================================
;===            HANDLE ALL LOOTING              ====
;===================================================
function Do5()
{
	call LootSomething
}

;===================================================
;===            HUNTING ROUTINE                 ====
;===================================================
function Do6()
{
	;; we are dead so stop hunting
	if ${Me.HealthPct} <= 0 || ${GV[bool,DeathReleasePopup]}
	{
		Do6:Set[False]
		return
	}

	;; go find a target that is within 80 meters
	if !${Me.Target(exists)} && ${Me.Encounter}<1 && !${Me.InCombat}
	{
		;; echo that we need more health/energy
		if !${NeedMoreEnergy}
		{
			if (${Me.Energy}>0 && ${Me.EnergyPct}<=40) || ${Me.HealthPct}<80
			{
				NeedMoreEnergy:Set[TRUE]
				vgecho RESTING:  Health or Energy is below 80%
			}
		}
		
		if ${NeedMoreEnergy}
		{
			if (${Me.Energy}>0 && ${Me.EnergyPct}<40) || ${Me.HealthPct}<40
			{
				variable string EatThis = Nothing
				if ${Me.Inventory[exactname,Fresh Berries](exists)}
					EatThis:Set["Fresh Berries"]
				if ${Me.Inventory[exactname,Fresh Fish](exists)}
					EatThis:Set["Fresh Fish"]
				if ${Me.Inventory[exactname,Shiny Red Apple](exists)}
					EatThis:Set["Shiny Red Apple"]
				if ${Me.Inventory[exactname,Block of Cheese](exists)}
					EatThis:Set["Block of Cheese"]
				if ${Me.Inventory[exactname,Loaf of Honey](exists)}
					EatThis:Set["Loaf of Honey"]
				if ${Me.Inventory[exactname,Loaf of Honey Bread](exists)}
					EatThis:Set["Loaf of Honey Bread"]
				if ${Me.Inventory[exactname,Hard Boiled Egg](exists)}
					EatThis:Set["Hard Boiled Egg"]
				if ${Me.Inventory[exactname,Var Stew](exists)}
					EatThis:Set["Var Stew"]

				vgecho "Eating:  ${EatThis}"
				if ${Me.Inventory[exactname,"${EatThis}"](exists)}
				{
					wait 30 ${Me.Inventory[exactname,"${EatThis}"].IsReady}
						waitframe
					Me.Inventory["${EatThis}"]:Use
					wait 5
				}
			}
		
			;; loop this to regain more energy
			while ${Me.HealthPct}<90 || (${Me.Energy}>0 && ${Me.EnergyPct}<90) || (${Me.Endurance}>0 && ${Me.EndurancePct}<50)
			{
				if ${Me.Target(exists)} || ${Me.Encounter}>0 || ${Me.InCombat}
					break
				if ${Me.Energy}>0
				{
					EchoIt "Resting: My Energy=${Me.EnergyPct}, My Health=${Me.HealthPct}, My Endurance=${Me.EndurancePct}"
					vgecho "Resting: My Energy=${Me.EnergyPct}, My Health=${Me.HealthPct}, My Endurance=${Me.EndurancePct}"
				}
				else
				{
					EchoIt "Resting: My Health=${Me.HealthPct}, My Endurance=${Me.EndurancePct}"
					vgecho "Resting: My Health=${Me.HealthPct}, My Endurance=${Me.EndurancePct}"
				}
				
				wait 50 ${Me.Target(exists)} || ${Me.Encounter}>0
				waitframe
			}

			;; Always stand up
			VGExecute "/stand"
		}
	
/*	
		;; echo that we need more health/energy
		if (${Me.EnergyPct}<30 || ${Me.HealthPct}<30) && !${NeedMoreEnergy}
		{
			NeedMoreEnergy:Set[TRUE]
			vgecho RESTING FOR MORE HEALTH/ENERGY BEFORE HUNTING
			
			variable string EatThis = None
			if ${Me.Inventory[Block of Cheese](exists)}
				EatThis:Set["Block of Cheese"]
			if ${Me.Inventory[Loaf of Honey](exists)}
				EatThis:Set["Loaf of Honey"]
			if ${Me.Inventory[Hard Boiled Egg](exists)}
				EatThis:Set["Hard Boiled Egg"]
			
			vgecho "Eating:  ${EatThis}"
			Me.Inventory[${EatThis}]:Use
			wait 50
		}
		
		;; loop this to regain more energy
		while !${Me.Target(exists)} && ${Me.Encounter}<1 && !${Me.InCombat} && (${Me.EnergyPct}<=80 || ${Me.HealthPct}<=80) && ${NeedMoreEnergy}
		{
			EchoIt "Resting- My Energy=${Me.EnergyPct}, My Health=${Me.HealthPct}"
			vgecho "Resting- My Energy=${Me.EnergyPct}, My Health=${Me.HealthPct}"
			wait 50 ${Me.Target(exists)} || ${Me.Encounter}>0
			waitframe
		}

		VGExecute "/stand"
*/		
		;; some sorcs need mana to fight, especially back to back fighting
		if ${Me.EnergyPct}>=80 && ${Me.HealthPct}>=80
		{
			;; reset our flag
			NeedMoreEnergy:Set[FALSE]

			call FindTarget ${MaxDistance}
			if !${Me.Target(exists)}
				call MoveToWayPoint
		}
	}

	;; Move Closer to target
	if ${Me.Target(exists)} && !${Me.Target.IsDead} && ${Me.Target.Distance}>${PullDistance} && ${Me.Target.Distance}<=99
	{
		if (${doNPC} && ${Me.Target.Type.Equal[NPC]}) || (${doAggroNPC} && ${Me.Target.Type.Equal[AggroNPC]})
			call MoveCloser ${PullDistance}
	}
}

;===================================================
;===                     Do07                   ====
;===================================================
function Do7()
{
	if ${Do7} 
	{
		if !${Me.InCombat} && !${Me.Target(exists)} && ${Me.Encounter}>0
		{
			;; Gather Energy while not in combat
			if ${Me.EnergyPct}<30 && ${Me.Ability[Gather Energy].IsReady}
			{
				vgecho "Gathering Energy"
				call executeability "Gather Energy"
				wait 180 ${Me.Target(exists)} || ${Me.InCombat} || ${Me.Encounter}>0
				return
			}

			;; Use the Meditation Stone while in combat if our Energy drops below 20%
			if ${Me.EnergyPct}<20 && !${Me.InCombat}
			{
				if ${Me.Inventory[Meditation Stone](exists)} && ${Me.Inventory[Meditation Stone].IsReady} && !${Me.Ability[Gather Energy].IsReady}
				{
					if !${Me.DTarget.Name.Equal[${Me.FName}]}
					{
						Pawn[me]:Target
						waitframe
					}
					Me.Inventory[Meditation Stone]:Use
					wait 5
				}
			}
		}
		
	}
	return
}

;===================================================
;===                     Do8                    ====
;===================================================
function Do8()
{
	;; Auto add immunities
}

;===================================================
;===                     Do9                    ====
;===================================================
function Do9()
{
	;; DECON SHANDREL JUNK
	if !${Me.InCombat}
	{
		if ${Me.Inventory[Deconstruction Kit](exists)}
		{
			if ${Me.Inventory[Shandrel's](exists)} && ${Me.Inventory[Shandrel's].Description.Find[This relic]}
			{
				echo "Deconstructing:  ${Me.Inventory[Shandrel's].Name}"
				vgecho "Deconstructing:  ${Me.Inventory[Shandrel's].Name}"
				Me.Inventory[Deconstruction Kit]:Use
				wait 5
				Me.Inventory[Shandrel's]:DeconstructToResource
				wait 10
			}
		}
	}
	return
}

;===================================================
;===                     Do10                   ====
;===================================================
function Do10()
{
	if ${doAcceptRez}
	{
		;; Accept that rez
		VGExecute "/rezaccept"

		;; allow time to relocate after accepting rez
		wait 80

		;; target our nearest corpse
		VGExecute "/targetmynearestcorpse"
		wait 10

		;; drag it closer if we are still out of range
		if ${Me.Target.Distance}>5 && ${Me.Target.Distance}<21
		{
			VGExecute "/corpsedrag"
			wait 5
		}

		;; loot our tombstone and clear our target
		VGExecute "/lootall"
		waitframe
		VGExecute "/cleartargets"
		waitframe

		EchoIt "Accepted Rez and looted my tombstone"
		doAcceptRez:Set[FALSE]
	}
}

;===================================================
;===                     Do11                   ====
;===================================================
function Do11()
{
	if ${doReturnHome}
	{
		call MoveToWayPoint
		doReturnHome:Set[FALSE]
	}
}

;===================================================
;===               Execute Ability              ====
;===================================================
function executeability(string x_ability)
{
	if ${Me.Target(exists)}
	{
		Me.Target:Face
	}
	Me.Ability[${x_ability}]:Use
	wait 3
	call debug "Casting: ${x_ability}"
	call FixLineOfSight
	while !${VG2Dot.AreWeReady}
	{
		call CounterIt
		waitframe
	}
	wait 3
}

;===================================================
;===                  Debug                     ====
;===================================================
function debug(string Text)
{
	redirect -append "${DebugFilePath}/Debug.txt" echo "[${Time}] ${Text}"
	echo [${Time}][vg2dot] --> "${Text}"
}

;===================================================
;===               Load XML Data                ====
;===================================================
function loadxmls()
{
	LavishSettings[VG2Dot]:Clear

	LavishSettings:AddSet[VG2Dot]
	LavishSettings[VG2Dot]:AddSet[Buffs]
	LavishSettings[VG2Dot]:AddSet[options]
	LavishSettings[VG2Dot]:AddSet[MyPath]
	LavishSettings[VG2Dot]:Import[${LavishScript.CurrentDirectory}/scripts/VG2Dot/Saves/${Me.FName}.xml]

	LavishSettings[MobResists]:Clear
	LavishSettings:AddSet[MobResists]
	LavishSettings[MobResists]:AddSet[Arcane]
	LavishSettings[MobResists]:AddSet[Fire]
	LavishSettings[MobResists]:AddSet[ColdIce]
	LavishSettings[MobResists]:AddSet[Physical]
	LavishSettings[MobResists]:Import[${LavishScript.CurrentDirectory}/scripts/VG2Dot/Saves/Mobs.xml]

	Buffs:Set[${LavishSettings[VG2Dot].FindSet[Buffs]}]
	options:Set[${LavishSettings[VG2Dot].FindSet[options]}]
	MyPath:Set[${LavishSettings[VG2Dot].FindSet[MyPath]}]
	Arcane:Set[${LavishSettings[MobResists].FindSet[Arcane]}]
	Fire:Set[${LavishSettings[MobResists].FindSet[Fire]}]
	ColdIce:Set[${LavishSettings[MobResists].FindSet[ColdIce]}]
	Physical:Set[${LavishSettings[MobResists].FindSet[Physical]}]

	doForget:Set[${options.FindSetting[doForget,${doForget}]}]
	BarrierType:Set[${options.FindSetting[BarrierType,${BarrierType}]}]
	FocusType:Set[${options.FindSetting[FocusType,${FocusType}]}]

	Do1:Set[${options.FindSetting[Do1,${Do1}]}]
	Do2:Set[${options.FindSetting[Do2,${Do2}]}]
	Do3:Set[${options.FindSetting[Do3,${Do3}]}]
	Do4:Set[${options.FindSetting[Do4,${Do4}]}]
	Do5:Set[${options.FindSetting[Do5,${Do5}]}]
	;Do6:Set[${options.FindSetting[Do6,${Do6}]}]
	Do7:Set[${options.FindSetting[Do7,${Do7}]}]
	Do8:Set[${options.FindSetting[Do8,${Do8}]}]
	Do9:Set[${options.FindSetting[Do9,${Do9}]}]
	Do10:Set[${options.FindSetting[Do10,${Do10}]}]
	Do11:Set[${options.FindSetting[Do11,${Do11}]}]

	;; import our item manager settings
	doAutoSell:Set[${options.FindSetting[doAutoSell,${doAutoSell}]}]
	doDeleteSell:Set[${options.FindSetting[doDeleteSell,${doDeleteSell}]}]
	doDeleteNoSell:Set[${options.FindSetting[doDeleteNoSell,${doDeleteNoSell}]}]

	;; import loot settings
	LootCheckForAggroRadius:Set[${options.FindSetting[LootCheckForAggroRadius,${LootCheckForAggroRadius}]}]
	LootNearRange:Set[${options.FindSetting[LootNearRange,${LootNearRange}]}]
	LootMaxRange:Set[${options.FindSetting[LootMaxRange,${LootMaxRange}]}]

	;; import Hunt variables
	doCheckLineOfSight:Set[${options.FindSetting[doCheckLineOfSight,${doCheckLineOfSight}]}]
	doNPC:Set[${options.FindSetting[doNPC,${doNPC}]}]
	doAggroNPC:Set[${options.FindSetting[doAggroNPC,${doAggroNPC}]}]
	doCheckForAdds:Set[${options.FindSetting[doCheckForAdds,${doCheckForAdds}]}]
	doCheckForObstacles:Set[${options.FindSetting[doCheckForObstacles,${doCheckForObstacles}]}]
	PullDistance:Set[${options.FindSetting[PullDistance,${PullDistance}]}]
	MaxDistance:Set[${options.FindSetting[MaxDistance,${MaxDistance}]}]
	MinimumLevel:Set[${options.FindSetting[MinimumLevel,${Me.Level}]}]
	MaximumLevel:Set[${options.FindSetting[MaximumLevel,${Me.Level}]}]

	;; setup our paths
	if ${Me.Chunk(exists)}
	{
		if !${MyPath.FindSet[${Me.Chunk}](exists)}
		{
			EchoIt "Adding (${Me.Chunk}) Chunk Region to Config"
			MyPath:AddSet[${Me.Chunk}]
			CurrentWayPoint:Set[0]
			TotalWayPoints:Set[0]
			MyPath.FindSet[${Me.Chunk}]:Clear
			Navigate:ClearAll
		}
		else
		{
			TotalWayPoints:Set[${MyPath[${Me.Chunk}].FindSetting[TotalWayPoints,0]}]
			call FindNearestWayPoint
			CurrentWayPoint:Set[${Return}]
			if ${CurrentWayPoint}<1
				CurrentWayPoint:Set[1]
			EchoIt "TotalWayPoints Found in ${Me.Chunk}: ${TotalWayPoints}, Closest WayPoint is ${CurrentWayPoint}"
		}
	}

}

;===================================================
;===        Lavish Save Routine                 ====
;===================================================
function LavishSave()
{
	;; cut down on the loading times
	if !${LavishSettings[VG2Dot].FindSet[options](exists)}
	{
		;; build and import Settings
		LavishSettings[VG2Dot]:Clear
		LavishSettings:AddSet[VG2Dot]
		LavishSettings[VG2Dot]:AddSet[Buffs]
		LavishSettings[VG2Dot]:AddSet[options]
		LavishSettings[VG2Dot]:AddSet[MyPath]
		LavishSettings[VG2Dot]:Import[${LavishScript.CurrentDirectory}/scripts/VG2Dot/Saves/${Me.FName}.xml]

		LavishSettings[MobResists]:Clear
		LavishSettings:AddSet[MobResists]
		LavishSettings[MobResists]:AddSet[Arcane]
		LavishSettings[MobResists]:AddSet[Fire]
		LavishSettings[MobResists]:AddSet[ColdIce]
		LavishSettings[MobResists]:AddSet[Physical]
		LavishSettings[MobResists]:Import[${LavishScript.CurrentDirectory}/scripts/VG2Dot/Saves/Mobs.xml]
	}

	;; update our pointers
	options:Set[${LavishSettings[VG2Dot].FindSet[options]}]
	MyPath:Set[${LavishSettings[VG2Dot].FindSet[MyPath]}]

	options:AddSetting[doForget,${doForget}]
	options:AddSetting[BarrierType,${BarrierType}]
	options:AddSetting[FocusType,${FocusType}]

	options:AddSetting[Do1,${Do1}]
	options:AddSetting[Do2,${Do2}]
	options:AddSetting[Do3,${Do3}]
	options:AddSetting[Do4,${Do4}]
	options:AddSetting[Do5,${Do5}]
	options:AddSetting[Do6,${Do6}]
	options:AddSetting[Do7,${Do7}]
	options:AddSetting[Do8,${Do8}]
	options:AddSetting[Do9,${Do9}]
	options:AddSetting[Do10,${Do10}]
	options:AddSetting[Do11,${Do11}]

	;; update our loot variables
	options:AddSetting[LootCheckForAggroRadius,${LootCheckForAggroRadius}]
	options:AddSetting[LootNearRange,${LootNearRange}]
	options:AddSetting[LootMaxRange,${LootMaxRange}]

	;; update our item manage variables
	options:AddSetting[doAutoSell,${doAutoSell}]
	options:AddSetting[doDeleteSell,${doDeleteSell}]
	options:AddSetting[doDeleteNoSell,${doDeleteNoSell}]

	;; update our hunt variables
	options:AddSetting[doCheckLineOfSight,${doCheckLineOfSight}]
	options:AddSetting[doNPC,${doNPC}]
	options:AddSetting[doAggroNPC,${doAggroNPC}]
	options:AddSetting[doCheckForAdds,${doCheckForAdds}]
	options:AddSetting[doCheckForObstacles,${doCheckForObstacles}]
	options:AddSetting[PullDistance,${PullDistance}]
	options:AddSetting[MaxDistance,${MaxDistance}]
	options:AddSetting[MinimumLevel,${MinimumLevel}]
	options:AddSetting[MaximumLevel,${MaximumLevel}]

	LavishSettings[VG2Dot]:Export[${LavishScript.CurrentDirectory}/scripts/VG2Dot/Saves/${Me.FName}.xml]
	LavishSettings[MobResists]:Export[${LavishScript.CurrentDirectory}/scripts/VG2Dot/Saves/Mobs.xml]
}

;===================================================
;===                   Exit                     ====
;===================================================
atom atexit()
{
	VG:ExecBinding[moveforward,release]
	VG:ExecBinding[movebackward,release]
	call LavishSave
	ui -unload "${Script.CurrentDirectory}/VG2Dot.xml"
}

;===================================================
;===             Buffs Subroutine               ====
;===================================================
function CheckBuffs()
{
	;; always keep this toggled on even when in/out of combat
	if ${Me.Ability[Chromatic Halo](exists)} && ${Me.Ability[Chromatic Halo].IsReady} && !${Me.Effect[Chromatic Halo](exists)}
		call executeability "Chromatic Halo"

	;; we do not want to continue if we are in combat
	if ${Me.InCombat} || ${Me.Encounter}>0 || ${Me.Target(exists)}
		return

	;; loop through all our buffs and see which we need to cast
	variable iterator Iterator
	variable string temp
	Buffs:GetSettingIterator[Iterator]
	while ${Iterator.Key(exists)}
	{
		;; Use the ability if it is ready and does not exist on self
		if ${Me.Ability[${Iterator.Key}].IsReady} && !${Me.Effect[${Iterator.Key}](exists)}
			call executeability "${Iterator.Key}"
		Iterator:Next
	}

	;; Handle type of Barrier we want
	switch ${BarrierType}
	{
	Case Force
		call CastBuff "${ForceBarrier}"
		break

	Case Fire
		call CastBuff "${FireBarrier}"
		break

	Case Chromatic
		call CastBuff "${ChromaticBarrier}"
		break
	Default
		break
	}

	;; Hande type of Focus we want
	switch ${FocusType}
	{
	Case Quartz
		if ${Me.Ability[Conjure Quartz Focus](exists)} && !${Me.Effect[Quartz Focus Essence](exists)}
		{
			Me.Inventory[Quartz Focus]:Use
			wait 15
		}
		break
	Case Aquamarine
		if ${Me.Ability[Conjure Aquamarine Focus](exists)} && !${Me.Effect[Aquamarine Focus Essence](exists)}
		{
			Me.Inventory[Aquamarine Focus]:Use
			wait 15
		}
		break
	Case Diamond
		if ${Me.Ability[Conjure Diamond Focus](exists)} && !${Me.Effect[Diamond Focus Essence](exists)}
		{
			Me.Inventory[Diamond Focus]:Use
			wait 15
		}
		break
	Case Quicksilver
		if ${Me.Ability[Conjure Quicksilver Focus](exists)} && !${Me.Effect[Quicksilver Focus Essence](exists)}
		{
			Me.Inventory[Quicksilver Focus]:Use
			wait 15
		}
		break
	Case Opal
		if ${Me.Ability[Conjure Opal Focus](exists)} && !${Me.Effect[Opal Focus Essence](exists)}
		{
			Me.Inventory[Opal Focus]:Use
			wait 15
		}
		break
	Default
		break
	}
}

function:bool CastBuff(string ABILITY)
{
	if ${Me.Ability[${ABILITY}](exists)} && !${Me.Effect[${ABILITY}](exists)}
	{
		if !${Me.DTarget.Name.Equal[${Me.FName}]}
		{
			Pawn[me]:Target
			waitframe
		}
		;; loop this while checking for crits and furious
		while !${VG2Dot.AreWeReady}
			waitframe
		call executeability "${ABILITY}"
		wait 100 ${Me.Effect[${ABILITY}](exists)}
		wait 5
		return TRUE
	}
	return FALSE
}

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
	; Return if Ability already exists - based upon current level
	;-------------------------------------------
	if ${Me.Ability["${AbilityName}"](exists)} && ${Me.Ability[${ABILITY}].LevelGranted}<=${Me.Level}
	{
		echo "[${Time}][vg2dot] --> ${AbilityVariable}:  Level=${Me.Ability[${ABILITY}].LevelGranted} - ${ABILITY}"
		declare	${AbilityVariable}	string	script "${ABILITY}"
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

	;-------------------------------------------
	; If Ability exist then return
	;-------------------------------------------
	if ${Me.Ability["${ABILITY}"](exists)} && ${Me.Ability["${ABILITY}"].LevelGranted}<=${Me.Level}
	{
		echo "[${Time}][vg2dot] --> ${AbilityVariable}:  Level=${Me.Ability[${ABILITY}].LevelGranted} - ${ABILITY}"
		declare	${AbilityVariable}	string	script "${ABILITY}"
		return
	}

	;-------------------------------------------
	; Otherwise, new Ability is named "None"
	;-------------------------------------------
	echo "[${Time}][vg2dot] --> ${AbilityVariable}:  None"
	declare	${AbilityVariable}	string	script "None"
	return
}

function Forget()
{
	;; we want a live target that is within range
	if !${Me.Target(exists)} || ${Me.Target.IsDead} || ${Me.Target.Distance} > 23
		return

	;; deaggro the mob
	if ${doForget} && ${Me.IsGrouped} && ${Me.TargetHealth}<70
		call executeability "${Forget}"
}

;===================================================
;===         UI Tools for Buffs                 ====
;===================================================
atom(global) AddBuff(string aName)
{
	if ( ${aName.Length} > 1 )
		LavishSettings[VG2Dot].FindSet[Buffs]:AddSetting[${aName}, ${aName}]
}
atom(global) RemoveBuff(string aName)
{
	if ( ${aName.Length} > 1 )
		Buffs.FindSetting[${aName}]:Remove
}
atom(global) BuildBuffs()
{
	variable iterator Iterator
	Buffs:GetSettingIterator[Iterator]
	UIElement[BuffsList@Miscfrm@Misc@VGT@VG2Dot]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[BuffsList@Miscfrm@Misc@VGT@VG2Dot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	variable int i = 0
	Buffs:Clear
	while ${i:Inc} <= ${UIElement[BuffsList@Miscfrm@Misc@VGT@VG2Dot].Items}
		LavishSettings[VG2Dot].FindSet[Buffs]:AddSetting[${UIElement[BuffsList@Miscfrm@Misc@VGT@VG2Dot].Item[${i}].Text}, ${UIElement[BuffsList@Miscfrm@Misc@VGT@VG2Dot].Item[${i}].Text}]
}

;===================================================
;===         Catch target death                 ====
;===================================================
atom(script) PawnStatusChange(string ChangeType, int64 PawnID, string PawnName)
{
	if ${PawnID}==${LastTargetID} && ${ChangeType.Equal[NowDead]}
	{
		TotalKills:Inc
		EchoIt "Total Kills = ${TotalKills}"
		vgecho "Total Kills = ${TotalKills}"
	}
}

;===================================================
;===         Monitor Status Alerts              ====
;===================================================
atom(script) AlertEvent(string Text, int ChannelNumber)
{
	EchoIt "[Channel=${ChannelNumber}] ${Text}"
	if ${ChannelNumber}==22
	{
		if ${Text.Find[Invalid target]}
		{
			BlackListTarget:Set[${Me.Target.ID},${Me.Target.ID}]
			VGExecute "/cleartargets"
		}
	}
}


;===================================================
;===       ATOM - Monitor Chat Event            ====
;===================================================
atom(script) ChatEvent(string Text, string ChannelNumber, string ChannelName)
{
	EchoIt "[Channel=${ChannelNumber}] ${Text}"

	;; Accept Rez
	if ${ChannelNumber}==32
	{
		if ${Text.Find[is trying to resurrect you with]}
		{
			variable string PCName
			variable string PCNameFull
			PCNameFull:Set[${Text.Token[2,">"].Token[1,"<"]}]
			PCName:Set[${PCNameFull.Token[1," "]}]
			if ${Pawn[name,${PCName}].Title.Find[${Pawn[me].Title}]}
			{
				doAcceptRez:Set[TRUE]
				vgecho "Accepting REZ from ${PCName}"
			}
			else
			{
				vgecho "Did not accept REZ from ${PCName}"
			}
		}
	}
	if ${ChannelNumber}==26
	{
		;; this may be different for each class
		if ${Text.Find[and it is dispersed!]}
		{
			variable string bText
			bText:Set[${Text.Mid[${Text.Find['s ]},${Text.Length}]}]
			bText:Set[${bText.Left[${Math.Calc[${bText.Length}-21]}]}]
			bText:Set[${bText.Right[${Math.Calc[${bText.Length}-3]}]}]
			vgecho "<Purple=>COUNTERED: <Yellow=>${bText}"
		}
	}
	
	if ${ChannelNumber}==38
	{
		if ${Text.Find["The corpse has nothing on it for you."]}
			BlackListTarget:Set[${Me.Target.ID},${Me.Target.ID}]
	}
	if ${ChannelNumber}==0 || ${ChannelNumber}==1
	{
		if ${Text.Find["You must harvest this before you can loot it!"]}
			BlackListTarget:Set[${Me.Target.ID},${Me.Target.ID}]
	
		if ${Text.Find["You are not wielding the proper weapon type to use that ability"]}
		{
			EchoIt "Unable to use Ra'Jin Flare - No Shurikens in inventory"
			doRangedWeapon:Set[FALSE]
		}

		if ${Text.Find["no line of sight to your target"]} || ${Text.Find[You can't see your target]}
		{
			EchoIt "Face issue chatevent fired, facing target"
			Me.Target:Face
			NoLineOfSight:Set[TRUE]
		}
	}
	
}

;===================================================
;===   COUNTER IT - this will counter a spell   ====
;===================================================
function CounterIt()
{
	if ${isRunning}
	{
		; in order to counter we have to be able to ID the ability
		if !${Me.TargetCasting.Equal[None]}
		{
			if ${Me.Ability[${Disperse}].IsReady} && ${Me.Ability[${Disperse}].TimeRemaining}==0
			{
				VGExecute "/reactioncounter 1"
				wait 2
				while !${VG2Dot.AreWeReady}
					wait 1
			}
			if ${Me.Ability[${Reflect}].IsReady} && ${Me.Ability[${Reflect}].TimeRemaining}==0
			{
				VGExecute "/reactioncounter 2"
				wait 2
				while !${VG2Dot.AreWeReady}
					wait 1
			}
		}
	}
}


;***************************************************************************************************************
;***************************************************************************************************************
;***************************************************************************************************************
;***************************************************************************************************************



;===================================================
;===            HANDLE ALL LOOTING              ====
;===================================================
function LootSomething()
{
	if ${Me.Target(exists)}
	{
		;; we do not want to try looting if our target is alive
		if !${Me.Target.IsDead}
			return
	
		;; Loot the corpse right now if it is in range!
		if ${Me.Target.Distance}<5
			call LootCorpse

		;; Let's move closer to the corpse
		elseif ${Me.Target.Distance}>=5 && ${Me.Target.Distance}<=${LootNearRange}
		{
			;; If we are hunting then check for and target nearest AggroNPC if within range of corpse
			if ${Do6} && ${Pawn[AggroNPC,from,${Me.Target.X},${Me.Target.Y},${Me.Target.Z},radius,${LootCheckForAggroRadius}](exists)}
			{
				Pawn[AggroNPC,from,${Me.Target.X},${Me.Target.Y},${Me.Target.Z},radius,${LootCheckForAggroRadius}]:Target
				wait 3
				echo "[${Time}] Aquiring new AggroNPC target within ${LootCheckForAggroRadius} meters radius of corpse"
				return
			}

			;; Begin moving closer
			call MoveCloser 2

			;; Now Loot the corpse
			call LootCorpse
		}
		
		;; No matter what, we are clearing our target because we no longer need it
		VGExecute "/cleartargets"
		wait 5
	}

	;;
	;; Time to find us some corpses to loot
	;;

	;; if not in combat and have no encounters then search for corpses to loot
	if !${Me.InCombat} && ${Me.Encounter}==0
	{
		waitframe
		variable int TotalPawns
		variable index:pawn CurrentPawns
		TotalPawns:Set[${VG.GetPawns[CurrentPawns]}]

		for (i:Set[1] ; ${i}<${TotalPawns} && ${CurrentPawns.Get[${i}].Distance}<=${LootMaxRange} && !${Me.InCombat} && ${Me.Encounter}==0 ; i:Inc)
		{
			if ${CurrentPawns.Get[${i}].Type.Equal[Corpse]} && ${CurrentPawns.Get[${i}].ContainsLoot} 
			;if ${CurrentPawns.Get[${i}].Type.Equal[Corpse]}
			{
				;; only target corpses if we are not hunting and within 5 meters of us
				;if !${Do6} && ${CurrentPawns.Get[${i}].Distance}>5
				;	continue
				
				;; loot only corpses that belongs to us
				if !${CurrentPawns.Get[${i}].Owner.Find[${Me.FName}]}
					continue

				;; we do not want to retarget same corpse twice
				if ${BlackListTarget.Element[${CurrentPawns.Get[${i}].ID}](exists)} || !${CurrentPawns.Get[${i}].ContainsLoot}
					continue
				
				if !${Pawn[id,${CurrentPawns.Get[${i}].ID}].HaveLineOfSightTo}
					continue

				;; skip looting if there are any AggroNPC's near corpse and we are hunting
				;if ${Do6} && ${Pawn[AggroNPC,from,${CurrentPawns.Get[${i}].X},${CurrentPawns.Get[${i}].Y},${CurrentPawns.Get[${i}].Z},radius,${LootCheckForAggroRadius}](exists)}
				if ${Pawn[AggroNPC,from,${CurrentPawns.Get[${i}].X},${CurrentPawns.Get[${i}].Y},${CurrentPawns.Get[${i}].Z},radius,${LootCheckForAggroRadius}](exists)}
				{
					EchoIt "Aquiring new AggroNPC target within ${LootCheckForAggroRadius} meters radius of corpse"
					Pawn[AggroNPC,from,${CurrentPawns.Get[${i}].X},${CurrentPawns.Get[${i}].Y},${CurrentPawns.Get[${i}].Z},radius,${LootCheckForAggroRadius}]:Target
					wait 3
					return
				}

				;; target the corpse
				Pawn[id,${CurrentPawns.Get[${i}].ID}]:Target
				wait 3

				;; if we are hunting then face target and move closer
				;if ${Do6}
				;{
				call MoveCloser 2
				;}

				;; Now Loot the corpse
				call LootCorpse

				;; get next corpse
				continue
			}
		}
	}
}

;===================================================
;===        SUBROUTINE TO LOOTING               ====
;===================================================
function LootCorpse()
{
	if ${Me.Target(exists)} && ${Me.Target.IsDead} && ${Me.Target.Distance}<5
	{
		;; wait up to 1/2 second for loot to register
		wait 5 ${Me.Target.ContainsLoot}

		;; start looting only if within range
		if ${Me.Target.Distance}<5
		{
			;; start the loot process
			Loot:BeginLooting
			wait 5 ${Me.IsLooting} && ${Loot.NumItems}

			;; start looting 1 item at a time, gaurantee to get all items
			if ${Me.IsLooting}
			{
				BlackListTarget:Set[${Me.Target.ID},${Me.Target.ID}]
				if ${Loot.NumItems}
				{
					;; start highest to lowest, last item will close loot
					for ( i:Set[${Loot.NumItems}] ; ${i}>0 ; i:Dec )
					{
						if !${Loot.Item[${i}](exists)}
							vgecho Item does not exist yet
						wait 5 ${Loot.Item[${i}](exists)}
						vgecho *Looting: ${Loot.Item[${i}]}
						Loot.Item[${i}]:Loot
					}
					waitframe
				}
				else
				{
					;; sometimes, we just have to loot everything if we can't determine how many items to loot
					Loot:LootAll
				}

				;; End looting if we are still looting
				wait 2
				if ${Me.IsLooting}
					Loot:EndLooting
			}
		}

		;; No matter what, we are clearing our target because we no longer need it
		VGExecute "/cleartargets"
		wait 5
	}
}


;===================================================
;===        MOVE CLOSER TO TARGET               ====
;===================================================
function MoveCloser(int Distance=4)
{
	;;;;;;;;;;
	;; we only want to move if target doesn't exist
	waitframe
	if !${Me.Target.ContainsLoot}
	{
		if !${Me.Target(exists)} || !${Do6}
			return
	}

	;;;;;;;;;;
	;; Only move if target has a valid position
	if ${Me.Target.X}==0 || ${Me.Target.Y}==0
	{
		vgecho X and Y = 0
		VGExecute /cleartargets
		wait 10
		return
	}

	;; Let's face the target
	call FaceTarget

	;;;;;;;;;;
	;; Set our variables and turn on our bump monitor
	BUMP:Set[FALSE]
	variable float X = ${Me.X}
	variable float Y = ${Me.Y}
	variable float Z = ${Me.Z}
	variable int bailOut
	bailOut:Set[${Math.Calc[${LavishScript.RunningTime}+(10000)]}]
	Event[VG_onHitObstacle]:AttachAtom[Bump]

	;;;;;;;;;;
	;; Loop this until we are within range of target or our timer has expired which is 10 seconds
	while ${Me.Target(exists)} && ${Me.Target.Distance}>=${Distance} && ${LavishScript.RunningTime}<${bailOut}
	{
		;; face target and move forward
		Me.Target:Face
		VG:ExecBinding[moveforward]

		;; did we bump into something?
		if ${BUMP}
		{
			;; try moving right or backwards if we didn't move
			if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}<250
			{
				;; move right for half a second
				VG:ExecBinding[StrafeRight]
				wait 5
				VG:ExecBinding[StrafeRight,release]

				;; try moving backward if we didn't move
				if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}<250
				{
					VG:ExecBinding[moveforward,release]
					VG:ExecBinding[movebackward]
					VG:ExecBinding[StrafeRight]
					wait 4
					VG:ExecBinding[StrafeRight,release]
					wait 2
					VG:ExecBinding[movebackward,release]
				}
				continue
			}
			BUMP:Set[FALSE]
		}

		;; update our location
		X:Set[${Me.X}]
		Y:Set[${Me.Y}]
		Z:Set[${Me.Z}]
	}

	;;;;;;;;;;
	;; stop moving forward and turn off our bump monitor
	VG:ExecBinding[moveforward,release]
	Event[VG_onHitObstacle]:DetachAtom[Bump]

	;;;;;;;;;;
	;; we timed out so clear our target and try again
	if ${BUMP}
	{
		VGExecute /cleartargets
		wait 10
	}
}

;===================================================
;===     BUMP ROUTINE USED BY MOVE ROUTINE      ====
;===================================================
atom Bump(string Name)
{
	BUMP:Set[TRUE]
}

;===================================================
;===     Calculate closest waypoint             ====
;===================================================
function:int FindNearestWayPoint()
{
	;;;;;;;;;;
	;; cycle through all our waypoints finding nearest one
	;; to our current location
	if ${TotalWayPoints}
	{
		variable int i
		variable int ClosestDistance = 999999
		variable int ClosestWayPoint = 1
		variable point3f Destination

		for ( i:Set[1] ; ${i}<=${TotalWayPoints} ; i:Inc )
		{
			; set destination location X,Y,Z
			MyPath:Set[${LavishSettings[VG2Dot].FindSet[MyPath]}]
			Destination:Set[${MyPath.FindSet[${Me.Chunk}].FindSetting[WP-${i}]}]

			if ${Math.Distance["${Me.Location}","${Destination}"]} < ${ClosestDistance}
			{
				ClosestWayPoint:Set[${i}]
				ClosestDistance:Set[${Math.Distance["${Me.Location}","${Destination}"]}]
			}
		}
		;EchoIt "Distance to WP-${ClosestWayPoint} is ${ClosestDistance}"
		return ${ClosestWayPoint}
	}
	return 0
}


;===================================================
;===         Save current waypoint              ====
;===================================================
atom(script) AddWayPoint()
{
	;; increase our total waypoints
	TotalWayPoints:Inc

	;; store our settings for quick reference
	MyPath:Set[${LavishSettings[VG2Dot].FindSet[MyPath]}]
	MyPath.FindSet[${Me.Chunk}]:AddSetting[TotalWayPoints, ${TotalWayPoints}]
	MyPath.FindSet[${Me.Chunk}]:AddSetting[WP-${TotalWayPoints}, "${Me.Location}"]

	;; save our settings
	call LavishSave

	;; LavishNav: add point name to path
	Navigate:AddNamedPoint[WP-${TotalWayPoints}]

	;; echo that we added our waypoint
	EchoIt "Added WP-${TotalWayPoints} to ${Me.Chunk}"
}


;===================================================
;===        Clear current waypoint              ====
;===================================================
atom(script) ClearWayPoints()
{
	;; clear our variables
	CurrentWayPoint:Set[0]
	TotalWayPoints:Set[0]

	;; clear our path settings
	MyPath.FindSet[${Me.Chunk}]:Clear

	;; save everything
	call LavishSave

	;; LavishNav: reset our path
	Navigate:ClearAll

	;; echo that we cleared our path and waypoints
	EchoIt "Cleared all Waypoints for ${Me.Chunk}"
}

;===================================================
;===     Handles movement to next waypoint      ====
;===================================================
function(script) MoveToWayPoint()
{
	;;;;;;;;;;
	;; do absolutely nothing until we get a waypoint
	if !${Do6} || ${TotalWayPoints}==0
		return

	;;;;;;;;;;
	;; reset waypoint if outside of range
	if ${CurrentWayPoint}<1 || ${CurrentWayPoint}>${TotalWayPoints}
	{
		EchoIt "Starting at WP-1"
		CurrentStatus:Set[Starting at WP-1]
		CurrentWayPoint:Set[1]
	}

	;;;;;;;;;;
	;; return if we are already navigating to a waypoint
	if ${Navigate.isMoving}
	{
		CurrentStatus:Set[Moving to WP-${CurrentWayPoint}]
		return
	}

	;;;;;;;;;;
	;; calculate our distance to the waypoint
	variable point3f Destination = ${MyPath.FindSet[${Me.Chunk}].FindSetting[WP-${CurrentWayPoint}]}
	EchoIt "[WP-${CurrentWayPoint}][Distance from = ${Math.Distance[${Me.Location},${Destination}].Int}]"

	;;;;;;;;;;
	;; if we are in range of our destination then its time to go to next waypoint
	if ${Math.Distance["${Me.Location}","${Destination}"]} < 1000
	{
		;; reset current way point if equals total way points or more
		if ${CurrentWayPoint}>=${TotalWayPoints}
		{
			CurrentWayPoint:Set[${TotalWayPoints}]
			CountUp:Set[FALSE]
		}

		;; reset current way point if equals 1 or less
		if ${CurrentWayPoint}<=1
		{
			CurrentWayPoint:Set[1]
			CountUp:Set[TRUE]
		}

		;; adjust out current way point to move up or down
		if ${CountUp}
		{
			CurrentWayPoint:Inc
		}
		else
		{
			CurrentWayPoint:Dec
		}
	}

	;;;;;;;;;;
	;; LavishNav: Move to a Point
	EchoIt "Attempting to move to WP-${CurrentWayPoint}"
	Navigate:MoveToPoint[WP-${CurrentWayPoint}]

	;; allow time to register we are moving
	wait 40 ${Navigate.isMoving}

	EchoIt "isMoving=${Navigate.isMoving}"

	;;;;;;;;;;
	;; loop this while we are moving to waypoint
	while ${Navigate.isMoving}
	{
		Action:Set[Moving to WP-${CurrentWayPoint}]

		;; keep looking for a target
		call FindTarget ${MaxDistance}

		;; stop moving if we paused or picked up an encounter
		if ${isPaused} || ${Me.Encounter}>0 || ${Me.InCombat} || ${Me.Target(exists)} || !${Do6}
		{
			Navigate:Stop
			VG:ExecBinding[moveforward,release]
			wait 1
		}
	}

	;;;;;;;;;;
	;; if we have an encounter then target it
	if ${Encounter}>0
	{
		Action:Set[ENCOUNTER]
		Pawn[ID,${Me.Encounter[1].ID}]:Target
		wait 3
		return
	}

	;;;;;;;;;;
	;; if we have a target then face it
	if ${Me.Target(exists)}
	{
		Action:Set[Attacking ${Me.Target.Name}]
		call FaceTarget
		wait 2
	}
}


variable int LoSRetries = 0
function FixLineOfSight()
{
	if ${NoLineOfSight}
	{
		if ${Me.Target(exists)}
		{
			LoSRetries:Inc
			if ${LoSRetries}>=3
			{
				BlackListTarget:Set[${Me.Target.ID},${Me.Target.ID}]
				VGExecute "/cleartargets"
				wait 3
				NoLineOfSight:Set[FALSE]
			}
			else
			{
				EchoIt "Fixing Line of Sight"
				VG:ExecBinding[moveforward,release]
				VG:ExecBinding[movebackward]
				VG:ExecBinding[StrafeRight]
				wait 4
				VG:ExecBinding[StrafeRight,release]
				wait 2
				VG:ExecBinding[movebackward,release]
			}
			return
		}
		else
		{
			NoLineOfSight:Set[FALSE]
		}
	}
	if !${NoLineOfSight}
		LoSRetries:Set[0]
}

;===================================================
;===         FACE TARGET SUBROUTINE             ====
;===================================================
function FaceTarget()
{
	;; face only if target exists
	if ${Do6}
	{
		if ${Me.Target(exists)}
		{
			CalculateAngles
			if ${AngleDiffAbs} > 45
			{
				variable int i = ${Math.Calc[20-${Math.Rand[40]}]}
				EchoIt "Facing within ${i} degrees of ${Me.Target.Name}"
				VG:ExecBinding[turnright,release]
				wait 1
				VG:ExecBinding[turnleft,release]
				wait 1
				if ${AngleDiff}>0
				{
					VG:ExecBinding[turnright]
					while ${AngleDiff} > ${i} && ${Me.Target(exists)} && !${isPaused} && ${isRunning}
						CalculateAngles
					VG:ExecBinding[turnleft,release]
					wait 1
					VG:ExecBinding[turnright,release]
					wait 1
					return
				}
				if ${AngleDiff}<0
				{
					VG:ExecBinding[turnleft]
					while ${AngleDiff} < ${i} && ${Me.Target(exists)} && !${isPaused} && ${isRunning}
						CalculateAngles
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
	}
}

variable int AngleDiff = 0
variable int AngleDiffAbs = 0

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
			result:Set[${Math.Calc[${result} - 360]}]
		while ${result} < -180
			result:Set[${Math.Calc[${result} + 360]}]
		AngleDiff:Set[${result}]
		AngleDiffAbs:Set[${Math.Abs[${result}]}]
	}
	else
	{
		AngleDiff:Set[0]
		AngleDiffAbs:Set[0]
	}
}

;===================================================
;===     WE ARE DEAD - DO NOTHING ROUTINE       ====
;===================================================
function WeAreDead()
{
	isPaused:Set[TRUE]
}

;===================================================
;===     Display to console what we are doing   ====
;===================================================
atom(script) EchoIt(string aText)
{
	redirect -append "${DebugFilePath}/Debug.txt" echo "[${Time}] ${aText}"
	echo "[${Time}][VG2Dot]: ${aText}"
}

;===================================================
;===    Switch target to an encounter           ====
;===================================================
function TargetEncounter()
{
	if ${Me.Encounter}>0
	{
		variable int Dist = 999
		variable int Enc = 0
		variable int64 Id = 0

		if ${Me.Target(exists)}
		{
			Dist:Set[${Me.Target.Distance}]
			Id:Set[${Me.Target.ID}]
		}

		for ( i:Set[1] ; ${i}<=${Me.Encounter} ; i:Inc )
		{
			if ${Me.FName.Equal[${Me.Encounter[${i}].Target}]}
			{
				if ${Me.Encounter[${i}].Distance}<${Dist}
				{
					Enc:Set[${i}]
					Dist:Set[${Me.Encounter[${i}].Distance}]
					Id:Set[${Me.Encounter[${i}].ID}]
				}
			}
		}

		if ${Enc}>0
		{
			EchoIt "Id=${Id}, Enc=${Enc}, MyTargetID=${Me.Target.ID}"
			if ${Me.Target.ID}!=${Id}
			{
				EchoIt "Grabbing nearest encounter on me"
				face ${Pawn[id,${Me.Encounter[${Enc}].ID}].X} ${Pawn[id,${Me.Encounter[${Enc}].ID}].Y}
				Pawn[id,${Me.Encounter[${Enc}].ID}]:Target
				wait 10
				return
			}
		}
	}
}


objectdef Obj_Commands
{
	variable string PassiveAbility = "Racial Inheritance:"

	method Initialize()
	{
		variable int i
		for (i:Set[1] ; ${Me.Ability[${i}](exists)} ; i:Inc)
			if ${Me.Ability[${i}].Name.Find[Racial Inheritance:]}
				This.PassiveAbility:Set[${Me.Ability[${i}].Name}]
	}

	method Shutdown()
	{
	}

	member:bool AreWeReady()
	{
		if ${Me.Ability[${This.PassiveAbility}].IsReady} && !${Me.IsCasting} && !${VG.InGlobalRecovery}
			return TRUE
		return FALSE
	}
	
}
variable(global) Obj_Commands VG2Dot