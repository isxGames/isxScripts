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
#include ./vgtwodot/MoveCloser.iss
#include ./vgtwodot/KB_MoveTo.iss
#include ./vgtwodot/MobResists.iss

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
variable int WhatStepWeOn = 0
variable string LastTargetName = "None"
variable int64 LastTargetID = 0

;; reference variables
variable settingsetref Arcane
variable settingsetref Fire
variable settingsetref ColdIce
variable settingsetref Physical
variable settingsetref options

;; UI toggles - excessively alot of toggles
variable bool Do1
variable bool Do2
variable bool Do3
variable bool Do4
variable bool Do5
variable bool Do6
variable bool Do7
variable bool Do8
variable bool Do9

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
		wait 3
		call SetImmunities
		call MandatoryChecks
		call GoDoSomething
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
		endscript BM1
	}
	echo "Started vgtwodot Script"
	wait 30 ${Me.Chunk(exists)}


	;-------------------------------------------
	; Reload the UI
	;-------------------------------------------
	call loadxmls
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	ui -reload  -skin VGSkin "${Script.CurrentDirectory}/vgtwodot.xml"
	UIElement[vgtwodot]:SetWidth[170]
	UIElement[vgtwodot]:SetHeight[230]
	
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
	if ${WhatStepWeOn}>=9
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

	;; Clear the target if it is dead
	if ${Me.Target.IsDead} && ${Pawn[${Me.Target}].Type.Equal[Corpse]} && !${Pawn[${Me.Target}].ContainsLoot}
	{
		VGExecute /cleartargets
		wait 3
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
		if ${LastTargetName.NotEqual[${Me.Target.Name}]}
		{
			wait 7
			LastTargetName:Set[${Me.Target.Name}]
		}
		
		if ${LastTargetID}!=${Me.Target.ID}
		{
			wait 7
			LastTargetID:Set[${Me.Target.ID}]
		}

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
		if ${Me.TargetBuff[Ice Form](exists)} ||${Me.TargetBuff[Cold Form](exists)} ||${Me.TargetBuff[Frozen Form](exists)}
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
	if !${Me.Target(exists)} || ${Me.Target.IsDead} || ${Me.Target.Distance} > 20
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
	if !${Me.Target(exists)} || ${Me.Target.IsDead} || ${Me.Target.Distance} > 20
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
	if !${Me.Target(exists)} || ${Me.Target.IsDead} || ${Me.Target.Distance} > 20
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
	if !${Me.Target(exists)} || ${Me.Target.IsDead} || ${Me.Target.Distance} > 20
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
	;; if there are no corpses around...then why bother.
	if !${Pawn[Corpse](exists)} && !${Me.IsLooting}
	{
		return
	}
	

	;; loot the target if its within range
	if ${Me.Target.IsDead} && ${Pawn[${Me.Target}].Type.Equal[Corpse]} && ${Pawn[${Me.Target}].ContainsLoot} && ${Me.Target.Distance}<5
	{
		VGExecute /Lootall
		wait 10 !${Me.Target.ContainsLoot} && !${Me.IsLooting}
		VGExecute "/cleartargets"
		wait 10 !${Me.Target(exists)}
	}

	;; if not in combat and have no encounters then search for corpses to loot
	if !${Me.InCombat} && ${Me.Encounter}==0
	{
		variable int TotalPawns
		variable index:pawn CurrentPawns
		TotalPawns:Set[${VG.GetPawns[CurrentPawns]}]
	
		for (i:Set[1] ; ${i}<${TotalPawns} && ${CurrentPawns.Get[${i}].Distance}<20 && !${Me.InCombat} && ${Me.Encounter}==0 ; i:Inc)
		{
			echo [${i}] Type=${CurrentPawns.Get[${i}].Type}, Distance=${CurrentPawns.Get[${i}].Distance}, HasLoot=${CurrentPawns.Get[${i}].ContainsLoot}
			if ${CurrentPawns.Get[${i}].Type.Equal[Corpse]} && ${CurrentPawns.Get[${i}].Distance}<20 && ${CurrentPawns.Get[${i}].ContainsLoot}
			{
				;; target the corpse
				Pawn[id,${CurrentPawns.Get[${i}].ID}]:Target
				wait 10 ${Me.Target.ContainsLoot}
				
				;; move closer to corpse
				if ${Me.Target.Distance}>5 && ${Me.Target.Distance}<20
				{
					call movetoobject ${Me.Target.ID} 4 0
				}
				
				;; loot the corpse
				VGExecute /Lootall
				wait 10 !${Me.Target.ContainsLoot} && !${Me.IsLooting}
				if ${Me.Target.ContainsLoot} || ${Me.IsLooting}
				{
					break
				}
				
				;; clear the target
				VGExecute "/cleartargets"
				wait 10 !${Me.Target(exists)}
				
				;; get next corpse
				continue
			}
		}	
	}
}

;===================================================
;===            HANDLE ALL LOOTING              ====
;===================================================
function Do6()
{
	;; go find a target that is 80 meters, 3-dot or less, level range from 1 to 60
	if !${Me.Target(exists)} && ${Me.Encounter} < 1 && !${Me.InCombat}
	{
		call FindTarget AggroNPC 80 3 1 60
	}
	
	;; Move Closer to target
	if ${Me.Target(exists)} && !${Me.Target.IsDead} && ${Me.Target.Distance}>20 && ${Me.Target.Distance}<=80
	{
		call movetoobject ${Me.Target.ID} 20 0
		wait 5
	}
}

;===================================================
;===                     Do07                   ====
;===================================================
function Do7()
{
	if ${Do7}
	{
		if ${Me.Ability[Gather Energy].IsReady}
		{
			vgecho "Gathering Energy"
			call executeability "Gather Energy"
			wait 180
			return
		}
	}
	return
}

;===================================================
;===                     Do8                   ====
;===================================================
function Do8()
{
	
}


;===================================================
;===  Auto Decon - Not being called by anything ====
;===================================================
function decon()
{
	if !${Me.InCombat} && ${Me.Inventory[Shandrel](exists)}
	{
		Me.Inventory[Deconstruction Kit]:Use
		wait 5
		Me.Inventory[Shandrel].Container:DeconstructToResource
		wait 4
	}
	return
}

;===================================================
;===               Execute Ability              ====
;===================================================
function executeability(string x_ability)
{
	face ${Me.Target.X} ${Me.Target.Y}
	Me.Ability[${x_ability}]:Use
	wait 2
	call debug ${x_ability}
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
	echo [${Time}] "${Text}"
}

;===================================================
;===               Load XML Data                ====
;===================================================
function loadxmls()
{
	LavishSettings[vgtwodot]:Clear

	LavishSettings:AddSet[vgtwodot]
	LavishSettings[vgtwodot]:AddSet[options]
	LavishSettings[vgtwodot]:Import[${LavishScript.CurrentDirectory}/scripts/vgtwodot/Saves/${Me.FName}.xml]

	LavishSettings:AddSet[MobResists]
	LavishSettings[MobResists]:AddSet[Arcane]
	LavishSettings[MobResists]:AddSet[Fire]
	LavishSettings[MobResists]:AddSet[ColdIce]
	LavishSettings[MobResists]:AddSet[Physical]
	LavishSettings[MobResists]:Import[${LavishScript.CurrentDirectory}/scripts/vgtwodot/Saves/Mobs.xml]

	options:Set[${LavishSettings[vgtwodot].FindSet[options]}]
	Arcane:Set[${LavishSettings[MobResists].FindSet[Arcane]}]
	Fire:Set[${LavishSettings[MobResists].FindSet[Fire]}]
	ColdIce:Set[${LavishSettings[MobResists].FindSet[ColdIce]}]
	Physical:Set[${LavishSettings[MobResists].FindSet[Physical]}]

	Do1:Set[${options.FindSetting[Do1,${Do1}]}]
	Do2:Set[${options.FindSetting[Do2,${Do2}]}]
	Do3:Set[${options.FindSetting[Do3,${Do3}]}]
	Do4:Set[${options.FindSetting[Do4,${Do4}]}]
	Do5:Set[${options.FindSetting[Do5,${Do5}]}]
	Do6:Set[${options.FindSetting[Do6,${Do6}]}]
	Do7:Set[${options.FindSetting[Do7,${Do7}]}]
	Do8:Set[${options.FindSetting[Do8,${Do8}]}]
}
;===================================================
;===        Lavish Save Routine                 ====
;===================================================
function LavishSave()
{
	options:AddSetting[Do1,${Do1}]
	options:AddSetting[Do2,${Do2}]
	options:AddSetting[Do3,${Do3}]
	options:AddSetting[Do4,${Do4}]
	options:AddSetting[Do5,${Do5}]
	options:AddSetting[Do6,${Do6}]
	options:AddSetting[Do7,${Do7}]
	options:AddSetting[Do8,${Do8}]

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


