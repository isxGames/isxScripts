;-----------------------------------------------------------------------------------------------
; VGTwoDot.iss 
;
; Description - a handy sorc tool for handling 2-dot elementals
; -----------
; * Loots
; * Hunts
; * Regen Energy
; * Identify Immunities
; * Preconfigured to handl Rire, Ice, Arcane, and Earth Elementals
;
; Revision History
; ----------------
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
#include ./vgtwodot/Common.iss
#include ./vgtwodot/FaceSlow.iss
#include ./vgtwodot/FindTarget.iss
#include ./vgtwodot/KB_MoveTo.iss
#include ./vgtwodot/MobResists.iss
#include ./vgtwodot/ItemListTools.iss

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
variable bool doCheckLineOfSight = TRUE
variable bool doForget = FALSE
variable bool BUMP = FALSE
variable string FocusType = "Quartz"
variable string BarrierType = "Force"
variable string LastTargetName = "None"
variable int64 LastTargetID = 0
variable int WhatStepWeOn = 0
variable int TotalKills = 0
variable bool NeedMoreEnergy = FALSE
variable bool doAcceptRez = FALSE
variable bool doReturnHome = FALSE
variable float HomeX
variable float HomeY
variable int NextItemListCheck = ${Script.RunningTime}


;; loot variables
variable int LootNearRange = 8
variable int LootMaxRange = 40
variable int LootCheckForAggroRadius = 20
variable collection:int64 BlackListCorpse


;; XML variables used to store and save data
variable settingsetref Arcane
variable settingsetref Fire
variable settingsetref ColdIce
variable settingsetref Physical
variable settingsetref options
variable settingsetref Buffs

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
		endscript vgtwodot
	}
	echo "Started vgtwodot Script"
	wait 30 ${Me.Chunk(exists)}


	;-------------------------------------------
	; Reload the UI
	;-------------------------------------------
	call loadxmls
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	wait 5
	ui -reload -skin VGSkin "${Script.CurrentDirectory}/vgtwodot.xml"
	UIElement[vgtwodot]:SetWidth[260]
	UIElement[vgtwodot]:SetHeight[270]
	wait 5

	;-------------------------------------------
	; Populate the UI
	;-------------------------------------------
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if !${Me.Ability[${i}].IsOffensive} && !${Me.Ability[${i}].Type.Equal[Combat Art]} && !${Me.Ability[${i}].IsChain} && !${Me.Ability[${i}].IsCounter} && !${Me.Ability[${i}].IsRescue} && !${Me.Ability[${i}].Type.Equal[Song]}
		{
			if ${Me.Ability[${i}].TargetType.Equal[Self]} || ${Me.Ability[${i}].TargetType.Equal[Defensive]} || ${Me.Ability[${i}].TargetType.Equal[Group]} || ${Me.Ability[${i}].TargetType.Equal[Ally]}
			{
				UIElement[BuffsCombo@Miscfrm@Misc@VGT@vgtwodot]:AddItem[${Me.Ability[${i}].Name}]
			}
		}
	}
	if ${BarrierType.Equal[Force]}
	{
		UIElement[BarrierType@Miscfrm@Misc@VGT@vgtwodot]:SelectItem[1]
	}
	if ${BarrierType.Equal[Fire]}
	{
		UIElement[BarrierType@Miscfrm@Misc@VGT@vgtwodot]:SelectItem[2]
	}
	if ${BarrierType.Equal[Chromatic]}
	{
		UIElement[BarrierType@Miscfrm@Misc@VGT@vgtwodot]:SelectItem[3]
	}
	
	if ${FocusType.Equal[Quartz]}
	{
		UIElement[FocusType@Miscfrm@Misc@VGT@vgtwodot]:SelectItem[1]
	}
	if ${FocusType.Equal[Aquamarine]}
	{
		UIElement[FocusType@Miscfrm@Misc@VGT@vgtwodot]:SelectItem[2]
	}
	if ${FocusType.Equal[Diamond]}
	{
		UIElement[FocusType@Miscfrm@Misc@VGT@vgtwodot]:SelectItem[3]
	}
	if ${FocusType.Equal[Quicksilver]}
	{
		UIElement[FocusType@Miscfrm@Misc@VGT@vgtwodot]:SelectItem[4]
	}
	if ${FocusType.Equal[Opal]}
	{
		UIElement[FocusType@Miscfrm@Misc@VGT@vgtwodot]:SelectItem[5]
	}
	
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

	;-------------------------------------------
	; Put in our inventory all our Focus Items
	;-------------------------------------------
	if ${Me.Ability[${ConjureQuartzFocus}](exists)}
	{
		if !${Me.Inventory[Quartz Focus](exists)}
		{
			call executeability "${ConjureQuartzFocus}"
		}
	}
	if ${Me.Ability[${ConjureAquamarineFocus}](exists)}
	{
		if !${Me.Inventory[Aquamarine Focus](exists)}
		{
			call executeability "${ConjureAquamarineFocus}"
		}
	}
	if ${Me.Ability[${ConjureDiamondFocus}](exists)}
	{
		if !${Me.Inventory[Diamond Focus](exists)}
		{
			call executeability "${ConjureDiamondFocus}"
		}
	}
	if ${Me.Ability[${ConjureQuicksilverFocus}](exists)}
	{
		if !${Me.Inventory[Quicksilver Focus](exists)}
		{
			call executeability "${ConjureQuicksilverFocus}"
		}
	}

	;; Add in our events
	Event[VG_onPawnStatusChange]:AttachAtom[PawnStatusChange]
	Event[VG_OnIncomingText]:AttachAtom[ChatEvent]	
}	

	
;===================================================
;===        GoDoSomething Routine               ====
;===================================================
function GoDoSomething()
{
	;; return if we do not exist in the game
	if !${Me(exists)}
	{
		return
	}

	;; increment our step
	WhatStepWeOn:Inc
	if ${WhatStepWeOn}>11
	{
		WhatStepWeOn:Set[1]
	}
	
	;; go call the routine Do1 thru Do7
	if ${Do${WhatStepWeOn}}
	{
		call Do${WhatStepWeOn}
	}
}
	
;===================================================
;===        MandatoryChecks Routine             ====
;===================================================
function MandatoryChecks()
{
	;; return if we do not exist in the game
	if !${Me(exists)}
	{
		return
	}
	
	waitframe

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
	if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextItemListCheck}]}/1000]}>=2
	{
		if !${Me.InCombat} && ${Me.Encounter}==0
		{
			if ${doAutoSell} && ${Me.Target.Type.Equal[Merchant]}
			{
				call SellItemList
			}
			if ${doDeleteSell} || ${doDeleteNoSell}
			{	
				call DeleteItemList	
			}
		}
		NextItemListCheck:Set[${Script.RunningTime}]
	}
}

;===================================================
;===            SetImmunities Atom              ====
;===================================================
function SetImmunities()
{
	;; Reset all immunities
	doArcane:Set[TRUE]
	doFire:Set[TRUE]
	doColdIce:Set[TRUE]
	doPhysical:Set[TRUE]
	
	;; Now, toggle off which ability based upon the target's immunity
	if ${Me.Target(exists)} && ${Me.TargetHealth(exists)}
	{
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
	if !${Me.Target(exists)} || ${Me.Target.IsDead} || ${Me.Target.Distance} > 22 || !${Me.Target.Type.Equal[AggroNPC]}
	{
		return
	}
	
	;; Use these abilities if target is immune to fire
	if ${MobResists.Type.Equal[Fire]} || !${doFire}
	{
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

;===================================================
;===            ICE RESISTANT TARGET            ====
;===================================================
function Do2()
{
	;; we want a live target that is within range
	if !${Me.Target(exists)} || ${Me.Target.IsDead} || ${Me.Target.Distance} > 22 || !${Me.Target.Type.Equal[AggroNPC]}
	{
		return
	}

	;; Use these abilities if target is immune to Cold/Ice
	if ${MobResists.Type.Equal[ColdIce]} || !${doColdIce}
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

;===================================================
;===         ELECTRIC RESISTANT TARGET          ====
;===================================================
function Do3()
{
	;; we want a live target that is within range
	if !${Me.Target(exists)} || ${Me.Target.IsDead} || ${Me.Target.Distance} > 22 || !${Me.Target.Type.Equal[AggroNPC]}
	{
		return
	}

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

;===================================================
;===          GO ALL OUT TARGET (Earth)         ====
;===================================================
function Do4()
{
	;; we want a live target that is within range
	if !${Me.Target(exists)} || ${Me.Target.IsDead} || ${Me.Target.Distance} > 22 || !${Me.Target.Type.Equal[AggroNPC]}
	{
		return
	}

	;; go all out routine
	if ${MobResists.Type.Equal[None]} || ${MobResists.Type.Equal[Physical]}
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
	
;===================================================
;===            HANDLE ALL LOOTING              ====
;===================================================
function Do5()
{
	if ${Me.Target(exists)}
	{
		;; we do not want to try looting if our target is alive
		if !${Me.Target.IsDead}
		{
			return
		}
		
		;; Loot the corpse right now if it is in range!
		if ${Me.Target.Distance}<5
		{
			call LootCorpse
		}
		
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
			call MoveCloser 4
			
			;; Now Loot the corpse
			call LootCorpse
		}
	}

	;;
	;; Time to find us some corpses to loot
	;;
	
	;; if not in combat and have no encounters then search for corpses to loot
	if !${Me.InCombat} && ${Me.Encounter}==0
	{
		variable int TotalPawns
		variable index:pawn CurrentPawns
		TotalPawns:Set[${VG.GetPawns[CurrentPawns]}]
	
		for (i:Set[1] ; ${i}<${TotalPawns} && ${CurrentPawns.Get[${i}].Distance}<=${LootMaxRange} && !${Me.InCombat} && ${Me.Encounter}==0 ; i:Inc)
		{
			if ${CurrentPawns.Get[${i}].Type.Equal[Corpse]} && ${CurrentPawns.Get[${i}].ContainsLoot}
			{
				;; we do not want to retarget same corpse twice
				if ${BlackListCorpse.Element[${CurrentPawns.Get[${i}].ID}](exists)}
				{
					continue
				}
				
				;; skip looting if there are any AggroNPC's near corpse and we are hunting
				if ${Do6} && ${Pawn[AggroNPC,from,${CurrentPawns.Get[${i}].X},${CurrentPawns.Get[${i}].Y},${CurrentPawns.Get[${i}].Z},radius,${LootCheckForAggroRadius}](exists)}
				{
					Pawn[AggroNPC,from,${CurrentPawns.Get[${i}].X},${CurrentPawns.Get[${i}].Y},${CurrentPawns.Get[${i}].Z},radius,${LootCheckForAggroRadius}]:Target
					wait 3
					echo "[${Time}] Aquiring new AggroNPC target within ${LootCheckForAggroRadius} meters radius of corpse"
					return
				}
			
				;; target the corpse
				Pawn[id,${CurrentPawns.Get[${i}].ID}]:Target
				wait 10
				
				;; Begin moving closer
				call MoveCloser 4
				
				;; Now Loot the corpse
				call LootCorpse
				
				;; get next corpse
				continue
			}
		}	
	}
}

;===================================================
;===        SUBROUTINE TO LOOTING D05           ====
;===================================================
function LootCorpse()
{
	if ${Me.Target(exists)} && ${Me.Target.IsDead}
	{
		;; we do not want to retarget same corpse twice
		BlackListCorpse:Set[${Me.Target.ID},${Me.Target.ID}]		

		;; wait up to 1 second for loot to register
		wait 10 ${Me.Target.ContainsLoot}

		;; does the corpse have any loot?
		if ${Me.Target.ContainsLoot}
		{
			;; start looting only if within range
			if ${Me.Target.Distance}<=5
			{


				;; start the loot process
				Loot:BeginLooting
				wait 20 ${Me.IsLooting} && ${Loot.NumItems}

				;; start looting 1 item at a time, gaurantee to get all items
				if ${Me.IsLooting}
				{
					;; make sure we blacklist so we don't try looting it again
					BlackListCorpse:Set[${Me.Target.ID},${Me.Target.ID}]

					if ${Loot.NumItems}
					{
						vgecho ${Loot.NumItems}
						;; start highest to lowest, last item will close loot
						for ( i:Set[${Loot.NumItems}] ; ${i}>0 ; i:Dec )
						{
							vgecho *Looting: ${Loot.Item[${i}]}
							;waitframe
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
					{
						Loot:EndLooting
					}
				}
			}
		}

		;; No matter what, we are clearing our target because we no longer need it
		VGExecute "/cleartargets"
		wait 5			
	}
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
	
	;; go find an AggroNPC that is within 80 meters
	if !${Me.Target(exists)} && ${Me.Encounter}<1 && !${Me.InCombat}
	{
		;; echo that we need more energy
		if ${Me.EnergyPct}<50 && !${NeedMoreEnergy}
		{
			NeedMoreEnergy:Set[TRUE]
			vgecho RESTING FOR MORE ENERGY BEFORE HUNTING
			return
		}
			
		;; some sorcs need mana to fight, especially back to back fighing
		if ${Me.EnergyPct}>=50
		{
			;; reset our flag
			NeedMoreEnergy:Set[FALSE]

			call FindTarget 80
			if !${Me.Target(exists)}
			{
				doReturnHome:Set[TRUE]
			}
		}
	}
	
	;; Move Closer to target
	if ${Me.Target(exists)} && !${Me.Target.IsDead} && ${Me.Target.Distance}>22 && ${Me.Target.Distance}<=99 && ${Me.Target.Type.Equal[AggroNPC]}
	{
		call MoveCloser 20
	}
	

}

;===================================================
;===                     Do07                   ====
;===================================================
function Do7()
{
	if ${Do7}
	{
		;; Gather Energy while not in combat
		if ${Me.Ability[Gather Energy].IsReady} && ${Me.EnergyPct}<30 && !${Me.InCombat}
		{
			vgecho "Gathering Energy"
			call executeability "Gather Energy"
			wait 180
			return
		}
		
		;; Use the Meditation Stone while in combat and our Energy drops below 30%
		if ${Me.InCombat} && ${Me.EnergyPct}<30
		{
			if ${Me.Inventory[Meditation Stone](exists)} && ${Me.Inventory[Meditation Stone].IsReady}
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
		if ${Me.Inventory[Deconstruction Kit](exists)} && ${Me.Inventory[Shandrel](exists)}
		{
			Me.Inventory[Deconstruction Kit]:Use
			wait 5
			Me.Inventory[Shandrel].Container:DeconstructToResource
			wait 10
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
		call MoveHome
		doReturnHome:Set[FALSE]
	}
}

;===================================================
;===               Execute Ability              ====
;===================================================
function executeability(string x_ability)
{
	face ${Me.Target.X} ${Me.Target.Y}
	Me.Ability[${x_ability}]:Use
	wait 2
	call debug "Casting: ${x_ability}"
	while ${Me.IsCasting}
	{
		wait 1
	}
	while ${VG.InGlobalRecovery}
	{
		wait 1
	}
	wait 2
}

;===================================================
;===                  Debug                     ====
;===================================================
function debug(string Text)
{
	echo [${Time}][vg2dot] --> "${Text}"
}

;===================================================
;===               Load XML Data                ====
;===================================================
function loadxmls()
{
	LavishSettings[vgtwodot]:Clear

	LavishSettings:AddSet[vgtwodot]
	LavishSettings[vgtwodot]:AddSet[Buffs]
	LavishSettings[vgtwodot]:AddSet[options]
	LavishSettings[vgtwodot]:Import[${LavishScript.CurrentDirectory}/scripts/vgtwodot/Saves/${Me.FName}.xml]

	LavishSettings[MobResists]:Clear
	LavishSettings:AddSet[MobResists]
	LavishSettings[MobResists]:AddSet[Arcane]
	LavishSettings[MobResists]:AddSet[Fire]
	LavishSettings[MobResists]:AddSet[ColdIce]
	LavishSettings[MobResists]:AddSet[Physical]
	LavishSettings[MobResists]:Import[${LavishScript.CurrentDirectory}/scripts/vgtwodot/Saves/Mobs.xml]

	Buffs:Set[${LavishSettings[vgtwodot].FindSet[Buffs]}]
	options:Set[${LavishSettings[vgtwodot].FindSet[options]}]
	Arcane:Set[${LavishSettings[MobResists].FindSet[Arcane]}]
	Fire:Set[${LavishSettings[MobResists].FindSet[Fire]}]
	ColdIce:Set[${LavishSettings[MobResists].FindSet[ColdIce]}]
	Physical:Set[${LavishSettings[MobResists].FindSet[Physical]}]

	doCheckLineOfSight:Set[${options.FindSetting[doCheckLineOfSight,${doCheckLineOfSight}]}]
	doForget:Set[${options.FindSetting[doForget,${doForget}]}]
	doAutoSell:Set[${options.FindSetting[doAutoSell,${doAutoSell}]}]
	doDeleteSell:Set[${options.FindSetting[doDeleteSell,${doDeleteSell}]}]
	doDeleteNoSell:Set[${options.FindSetting[doDeleteNoSell,${doDeleteNoSell}]}]
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
	LootCheckForAggroRadius:Set[${options.FindSetting[LootCheckForAggroRadius,${LootCheckForAggroRadius}]}]
	LootNearRange:Set[${options.FindSetting[LootNearRange,${LootNearRange}]}]
	LootMaxRange:Set[${options.FindSetting[LootMaxRange,${LootMaxRange}]}]
}

;===================================================
;===        Lavish Save Routine                 ====
;===================================================
function LavishSave()
{
	options:AddSetting[doCheckLineOfSight,${doCheckLineOfSight}]
	options:AddSetting[doForget,${doForget}]
	options:AddSetting[doAutoSell,${doAutoSell}]
	options:AddSetting[doDeleteSell,${doDeleteSell}]
	options:AddSetting[doDeleteNoSell,${doDeleteNoSell}]
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
	options:AddSetting[LootCheckForAggroRadius,${LootCheckForAggroRadius}]
	options:AddSetting[LootNearRange,${LootNearRange}]
	options:AddSetting[LootMaxRange,${LootMaxRange}]

	LavishSettings[vgtwodot]:Export[${LavishScript.CurrentDirectory}/scripts/vgtwodot/Saves/${Me.FName}.xml]
	LavishSettings[MobResists]:Export[${LavishScript.CurrentDirectory}/scripts/vgtwodot/Saves/Mobs.xml]
}

;===================================================
;===                   Exit                     ====
;===================================================
atom atexit()
{
	VG:ExecBinding[moveforward,release]
	VG:ExecBinding[movebackward,release]
	call LavishSave
	ui -unload "${Script.CurrentDirectory}/vgtwodot.xml"
}

;===================================================
;===             Buffs Subroutine               ====
;===================================================
function CheckBuffs()
{
	;; always keep this toggled on even when in/out of combat
	if ${Me.Ability[Chromatic Halo](exists)} && ${Me.Ability[Chromatic Halo].IsReady} && !${Me.Effect[Chromatic Halo](exists)}
	{
		call executeability "Chromatic Halo"
	}
	
	;; we do not want to continue if we are in combat
	if ${Me.InCombat} || ${Me.Encounter}>0 || ${Me.Target(exists)}
	{
		return
	}

	;; loop through all our buffs and see which we need to cast
	variable iterator Iterator
	variable string temp
	Buffs:GetSettingIterator[Iterator]
	while ${Iterator.Key(exists)}
	{
		;; Use the ability if it is ready and does not exist on self
		if ${Me.Ability[${Iterator.Key}].IsReady} && !${Me.Effect[${Iterator.Key}](exists)}
		{
			call executeability "${Iterator.Key}"
		}
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
		while ${Me.IsCasting} || ${VG.InGlobalRecovery} || !${Me.Ability["Torch"].IsReady}
		{
			waitframe
		}
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
	{
		return
	}
	
	;; deaggro the mob
	if ${doForget} && ${Me.IsGrouped} && ${Me.TargetHealth}<70
	{
		call executeability "${Forget}"
	}
}

;===================================================
;===         UI Tools for Buffs                 ====
;===================================================
atom(global) AddBuff(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[vgtwodot].FindSet[Buffs]:AddSetting[${aName}, ${aName}]
	}
}
atom(global) RemoveBuff(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Buffs.FindSetting[${aName}]:Remove
	}
}
atom(global) BuildBuffs()
{
	variable iterator Iterator
	Buffs:GetSettingIterator[Iterator]
	UIElement[BuffsList@Miscfrm@Misc@VGT@vgtwodot]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[BuffsList@Miscfrm@Misc@VGT@vgtwodot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	variable int i = 0
	Buffs:Clear
	while ${i:Inc} <= ${UIElement[BuffsList@Miscfrm@Misc@VGT@vgtwodot].Items}
	{
		LavishSettings[vgtwodot].FindSet[Buffs]:AddSetting[${UIElement[BuffsList@Miscfrm@Misc@VGT@vgtwodot].Item[${i}].Text}, ${UIElement[BuffsList@Miscfrm@Misc@VGT@vgtwodot].Item[${i}].Text}]
	}
}

;===================================================
;===         Catch target death                 ====
;===================================================
atom(script) PawnStatusChange(string ChangeType, int64 PawnID, string PawnName)
{
	if ${PawnID}==${LastTargetID} && ${ChangeType.Equal[NowDead]}
	{
		TotalKills:Inc
		call debug "Total Kills = ${TotalKills}"
		vgecho "Total Kills = ${TotalKills}"
	}
}

function MoveCloser(int Distance=4)
{
	if !${Me.Target(exists)}
	{
		vgecho NO TARGET
		return
	}
	
	if ${Me.Target.X}==0 || ${Me.Target.Y}==0
	{
		vgecho X and Y = 0
		VGExecute /cleartargets
		wait 10
		return
	}
	
	BUMP:Set[FALSE]
	variable float X = ${Me.X}
	variable float Y = ${Me.Y}
	variable float Z = ${Me.Z}
	Event[VG_onHitObstacle]:AttachAtom[Bump]
	variable int bailOut
	bailOut:Set[${Math.Calc[${LavishScript.RunningTime}+(10000)]}]
	
	while ${Me.Target(exists)} && ${Me.Target.Distance}>=${Distance} && ${LavishScript.RunningTime}<${bailOut}
	{
		VG:ExecBinding[moveforward]
		face ${Me.Target.X} ${Me.Target.Y}
		if ${BUMP}
		{
			if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}<250
			{
				VG:ExecBinding[StrafeRight]
				wait 5
				VG:ExecBinding[StrafeRight,release]
				if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}<250
				{
					VG:ExecBinding[moveforward,release]
					VG:ExecBinding[movebackward]
					wait 7
					VG:ExecBinding[movebackward,release]
				}
				continue
			}
			BUMP:Set[FALSE]
		}
		X:Set[${Me.X}]
		Y:Set[${Me.Y}]
		Z:Set[${Me.Z}]
	}
	VG:ExecBinding[moveforward,release]
	Event[VG_onHitObstacle]:DetachAtom[Bump]
	
	;; we timed out so clear our target and try again
	if ${BUMP}
	{
		VGExecute /cleartargets
		wait 10		
	}
}

atom Bump(string Name)
{
	BUMP:Set[TRUE]
}

function MoveHome()
{
	BUMP:Set[FALSE]
	variable float X = ${Me.X}
	variable float Y = ${Me.Y}
	variable float Z = ${Me.Z}
	variable int bailOut
	bailOut:Set[${Math.Calc[${LavishScript.RunningTime}+(1200)]}]
	
	if ${Math.Distance[${Me.X},${Me.Y},${HomeX},${HomeY}]}>500 && ${Do6} && ${LavishScript.RunningTime}<${bailOut}
	{
		Event[VG_onHitObstacle]:AttachAtom[Bump]
		echo [${Time}] Moving to Home at ${Math.Calc[${Math.Distance[${Me.X},${Me.Y},${HomeX},${HomeY}]}/100].Int} meters away
		vgecho Moving to Home at ${Math.Calc[${Math.Distance[${Me.X},${Me.Y},${HomeX},${HomeY}]}/100].Int} meters away
		while ${Math.Distance[${Me.X},${Me.Y},${HomeX},${HomeY}]}>500 && ${Do6} && ${LavishScript.RunningTime}<${bailOut}
		{
			if ${Do6} || ${Me.Target(exists)}
			{
				if ${Me.EnergyPct}>=50
				{
					;; reset our flag
					NeedMoreEnergy:Set[FALSE]
					call FindTarget 40
					if ${Me.Target(exists)}
					{
						echo [${Time}] Found a target while returning home
						vgecho Found a target while returning home
						;; break out of the while loop
						break
					}
				}
			}			

			face ${HomeX} ${HomeY}
			VG:ExecBinding[moveforward]
			wait 1

			if ${BUMP}
			{
				if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}<250
				{
					VG:ExecBinding[StrafeRight]
					wait 5
					VG:ExecBinding[StrafeRight,release]
					if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}<250
					{
						VG:ExecBinding[moveforward,release]
						VG:ExecBinding[movebackward]
						wait 5
						VG:ExecBinding[movebackward,release]
					}
					continue
				}
				BUMP:Set[FALSE]
			}
			
			X:Set[${Me.X}]
			Y:Set[${Me.Y}]
			Z:Set[${Me.Z}]
		}
		VG:ExecBinding[moveforward,release]
		Event[VG_onHitObstacle]:DetachAtom[Bump]
		echo Stopped at ${Math.Calc[${Math.Distance[${Me.X},${Me.Y},${HomeX},${HomeY}]}/100].Int} meters from starting point
		vgecho Stopped at ${Math.Calc[${Math.Distance[${Me.X},${Me.Y},${HomeX},${HomeY}]}/100].Int} meters from starting point
	}
	if ${LavishScript.RunningTime}>=${bailOut} && ${BUMP}
	{
		echo WE ARE STUCK... waiting here for repops
		vgecho WE ARE STUCK... waiting here for repops
	}
}


;===================================================
;===       ATOM - Monitor Chat Event            ====
;===================================================
atom(script) ChatEvent(string aText, string ChannelNumber, string ChannelName)
{
	;; Accept Rez
	if ${ChannelNumber}==32
	{
		if ${aText.Find[is trying to resurrect you with]}
		{
			variable string PCName
			variable string PCNameFull
			PCNameFull:Set[${aText.Token[2,">"].Token[1,"<"]}]
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
}
