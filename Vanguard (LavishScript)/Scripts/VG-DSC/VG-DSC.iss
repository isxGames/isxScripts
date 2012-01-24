;-----------------------------------------------------------------------------------------------
; VG-DSC.iss 
;
; Description - Script for Disciples
; -----------
; * Buff Bot 
; * Auto Attack turns on and off
; * Generate Endowments
;
; Revision History
; ----------------
; 20120116 (Zandros)
;  * A simple script that handles combat, no UI support
;
; 20120119 (Zandros)
;  * Added the UI that allows you to change various setting in combat as
;    well as a visual display to show you the Actio being performed and the
;    Ability being executed.  No routines for saving your settings to file.
;

;===================================================
;===            VARIABLES                       ====
;===================================================

;; Script variables
variable int i
variable bool isRunning = TRUE
variable bool isPaused = FALSE
variable bool isSitting = FALSE
variable int NextFormCheck = ${Script.RunningTime}
variable string LastAction = Nothing
variable string Tank
variable string temp
variable int EndowmentStep = 1
variable bool doTankEndowementOfLife = TRUE


;; UI/Script setting variables
variable int ChangeFormPct = 60
variable int FeignDeathPct = 20
variable int RacialAbilityPct = 30
variable int Crit_HealPct = 40
variable int BreathOfLifePct = 50
variable int KissOfHeavenPct = 60
variable int LaoJinFlashPct = 70
variable int Crit_DPS_RaJinFlarePct = 80
variable int StartAttack = 100
variable string ExecutedAbility = None
variable string TargetsTarget = "No Target"

;; to be added
variable bool doAutoAttack = FALSE
variable bool doRangedAttack = FALSE
variable bool doPushStance = FALSE
variable bool doFaceTarget = FALSE
variable bool doSprint = FALSE
variable bool doFollow = FALSE
variable int Speed = 100


;; Immunity variables
variable bool doPhysical = TRUE
variable bool doSpiritual = TRUE

;; Includes
#include ./VG-DSC/Includes/FindAction.iss

;===================================================
;===            MAIN SCRIPT                     ====
;===================================================
function main()
{
	;; keep looping this until we end the script
	while ${isRunning}
	{
		;;;;;;;;;;
		;; Make sure autoAttack is turned on/off, this will catch those abilities you manually 
		;; tried executing
		if ${Me(exists)}
		{
			call AutoAttack
			while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady} || ${VG.InGlobalRecovery}
			{
				call AutoAttack
			}
		}

		;;;;;;;;;;
		;; Slow this script down to 10 checks per second.  By having this wait here
		;; will improve FPS and allow AutoAttack to register.
		wait 1
		
			
		;;;;;;;;;;
		;; Default action will be "Idle"
		Action:Set[Idle]
		
		;;;;;;;;;;
		;; Calling this will update the variable "Action" based upon any
		;; triggered events
		if !${isPaused}
		{
			FindAction
		}
		
		;;;;;;;;;;
		;; Update the display that shows the Acttion of what we are doing
		;; and this also makes sure we don't repeatedly show the LastAction
		if ${LastAction.NotEqual[${Action}]}
		{
			LastAction:Set[${Action}]
			EchoIt "Action=${Action}"
			if ${isSitting}
			{
				VGExecute /stand
				wait 5
				isSitting:Set[FALSE
			}
		}
		
		;;;;;;;;;;
		;; Update the display that shows the Target's Target
		if ${Me.Target(exists)}
		{
			temp:Set[${Me.ToT.Name}]
			if ${temp.Equal[NULL]}
			{
				TargetsTarget:Set[No Target]
			}
			else
			{
				TargetsTarget:Set[${Me.ToT.Name}]
			}
		}

		;;;;;;;;;;
		;; The variable "Action" is set by the FindAction routine which is
		;; the name of the routine we want to call.  Doing it this way will
		;; cut back lots of coding as well as easier tracking of what we are doing
		call ${Action}
	}
}

;===================================================
;===    This is called when the script ends     ====
;===================================================
function atexit()
{
	;;;;;;;;;;
	;; Unload our UI
	ui -unload "${Script.CurrentDirectory}/VG-DSC.xml"
	
	EchoIt "Stopped Tools Script"
}

;===================================================
;===     Display to console what we are doing   ====
;===================================================
atom(script) EchoIt(string aText)
{
	echo "[${Time}][VG-DSC]: ${aText}"
}

;===================================================
;===    Idle and anything during downtime       ====
;===================================================
function Idle()
{
	;;;;;;;;;;
	;; Update what we are doing
	ExecutedAbility:Set[None]
	
	;;;;;;;;;;
	;; not in combat so get our Jin up!
	if !${Me.InCombat} && ${Me.Encounter}==0 && ${Me.Stat[Adventuring,Jin]}<=2
	{
		if !${Me.Effect[${Meditate}](exists)}
		{
			call UseAbility "${Meditate}"
			isSitting:Set[TRUE]
			wait 20 ${Me.Effect[${Meditate}](exists)}
			
			;; Keep looping this until we have 20 Jin or exit out of Meditate
			while !${Me.InCombat} && ${Me.Stat[Adventuring,Jin]}<20 && ${Me.Encounter}==0 && ${Me.Effect[${Meditate}](exists)}
			{
				waitframe
			}
		}
	}
}
;===================================================
;===   Setup the UI, load variables, et cetera  ====
;===================================================
function Initialize()
{
	;;;;;;;;;;
	;; Load ISXVG or exit script
	if !${ISXVG.IsReady}
	{
		echo "Reloading the extention ISXVG that makes this possible"
	}
	ext -require isxvg
	wait 100 ${ISXVG.IsReady}
	if !${ISXVG.IsReady}
	{
		echo "Unable to load ISXVG, exiting script"
		endscript VG-DSC
	}
	wait 30 ${Me.Chunk(exists)}
	EchoIt "Started VG-DSC Script"
	
	;;;;;;;;;;
	;; We do not want to run this again
	Initialized:Set[TRUE]

	;;;;;;;;;;
	;; Calculate Highest Level of all abilities to a variable.  By doing so
	;; will allow us to Mentor down as well as reconfiguring each time we level
	SetHighestAbility "AstralGale" "Astral Gale"
	SetHighestAbility "AstralWalk" "Astral Walk"
	SetHighestAbility "AstralWind" "Astral Wind"
	SetHighestAbility "Awakening" "Awakening"
	SetHighestAbility "BaitingStrike" "Baiting Strike "
	SetHighestAbility "BlessedWind" "Blessed Wind"
	SetHighestAbility "BloomingRidgeHand" "Blooming Ridge Hand"
	SetHighestAbility "BreathOfRenewal" "Breath of Renewal"
	SetHighestAbility "CelestialBreeze" "Celestial Breeze"
	SetHighestAbility "Clarity" "Clarity"
	SetHighestAbility "ConcordantHand" "Concordant Hand"
	SetHighestAbility "ConcordantPalm" "Concordant Palm"
	SetHighestAbility "CycloneKick" "Cyclone Kick"
	SetHighestAbility "Dodge" "Dodge"
	SetHighestAbility "EnfeeblingShuriken" "Enfeebling Shuriken"
	SetHighestAbility "FallingPetal" "Falling Petal"
	SetHighestAbility "FavorOfTheCrow" "Favor of the Crow"
	SetHighestAbility "FeignDeath" "Feign Death"
	SetHighestAbility "Feint" "Feint"
	SetHighestAbility "FistOfDiscord" "Fist of Discord"
	SetHighestAbility "FleetingFeet" "Fleeting Feet"
	SetHighestAbility "GraspOfDiscord" "Grasp of Discord"
	SetHighestAbility "ImpenetrableMind" "Impenetrable Mind"
	SetHighestAbility "InnerFocus" "Inner Focus"
	SetHighestAbility "InnerLight" "Inner Light"
	SetHighestAbility "KissOfHeaven" "Kiss of Heaven"
	SetHighestAbility "KissOfTorment" "Kiss of Torment"
	SetHighestAbility "KissOfTheSlug" "Kiss of the Slug"
	SetHighestAbility "KnifeHand" "Knife Hand"
	SetHighestAbility "LaoJinFlare" "Lao'Jin Flare"
	SetHighestAbility "LeechsGrasp" "Leech's Grasp"
	SetHighestAbility "Meditate" "Meditate"
	SetHighestAbility "MindlessClutch" "Mindless Clutch"
	SetHighestAbility "PalmOfDiscord" "Palm of Discord"
	SetHighestAbility "ParalyzingSweep" "Paralyzing Sweep"
	SetHighestAbility "ParalyzingTouch" "Paralyzing Touch"
	SetHighestAbility "Purify" "Purify"
	SetHighestAbility "RaJinFlare" "Ra'Jin Flare"
	SetHighestAbility "Reincarnate" "Reincarnate"
	SetHighestAbility "SoulCutter" "Soul Cutter"
	SetHighestAbility "StanceWheel" "Stance Wheel"
	SetHighestAbility "SummonSymbolOfUnity" "Summon Symbol of Unity"
	SetHighestAbility "SunFist" "Sun Fist"
	SetHighestAbility "SunAndMoonDiscipline" "Sun and Moon Discipline"
	SetHighestAbility "SuperiorSunFist" "Superior Sun Fist"
	SetHighestAbility "TouchOfDiscord" "Touch of Discord"
	;; Spiritual - the only one
	SetHighestAbility "TouchOfWoe" "Touch of Woe"
	;; Physical - the only one
	SetHighestAbility "TouchOfTheOx" "Touch of the Ox"
	SetHighestAbility "VoidHand" "Void Hand"
	SetHighestAbility "WhiteLotusStrike" "White Lotus Strike"
	SetHighestAbility "WisdomOfTheGrasshopper" "Wisdom of the Grasshopper"

	;; abilities I do not have
	SetHighestAbility "ResilientGrasshopper" "Resilient Grasshopper"
	SetHighestAbility "ConcordantSplendor" "Concordant Splendor"
	SetHighestAbility "PetalSplitsEarth" "Petal Splits Earth"
	SetHighestAbility "FocusedSonicBlast" "Focused Sonic Blast"
	SetHighestAbility "BlessedWhirl" "Blessed Whirl"
	SetHighestAbility "BreathOfLife" "Breath of Life"
	SetHighestAbility "LaoJinFlash" "Lao'Jin Flash"
	
	;;;;;;;;;;
	;; Reload the UI and draw our Tool window,putting a waitframe here
	;; allows enough time for loading the UI from disk
	waitframe
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	waitframe
	ui -reload -skin VGSkin "${Script.CurrentDirectory}/VG-DSC.xml"
	waitframe	
	
	;;;;;;;;;;
	;; We only need to check our inventory one time for this item
	;; because if we constantly check we risk crashing as well as slowing
	;; down
	hasScepterOfTheForgotten:Set[FALSE]
	if ${Me.Inventory[Scepter of the Forgotten](exists)}
	{
		hasScepterOfTheForgotten:Set[TRUE]
	}

	;;;;;;;;;;
	;; Set our DTarget to the Tank
	Tank:Set[${Me.FName}]
	if ${Me.DTarget.ID(exists)}
	{
		Tank:Set[${Me.DTarget.Name}]
	}
	EchoIt "-----------------------"
	EchoIt "Tank is set to ${Tank}"
	vgecho "Tank is set to ${Tank}"
}

;===================================================
;===    ChangeForm: Celestial Tiger             ====
;===================================================
function Form_CelestialTiger()
{
	ExecutedAbility:Set[Form... Celestial Tiger]
	Me.Form[Celestial Tiger]:ChangeTo
	wait .5
}

;===================================================
;===    ChangeForm: Immortal Jade Dragon        ====
;===================================================
function Form_ImmortalJadeDragon()
{
	ExecutedAbility:Set[Form... Immortal Jade Dragon]
	Me.Form[Immortal Jade Dragon]:ChangeTo
	wait .5
}

;===================================================
;===    Cast:  Inner Light                      ====
;===================================================
function Buff_InnerLight()
{
	call UseAbility "${InnerLight}"
	wait 10 ${Me.Effect[${InnerLight}](exists)}
}

;===================================================
;===    Cast:  Resilient Grasshopper            ====
;===================================================
function Buff_ResilientGrasshopper()
{
	call UseAbility "${ResilientGrasshopper}"
	wait 10 ${Me.Effect[${ResilientGrasshopper}](exists)}}
}

;===================================================
;===    Use item: Scepter of the Forgotten      ====
;===================================================
function Buff_AuraOfRulers()
{
	variable string DiplomacyHeldItem
	variable bool doEquipDiplomacyHeldItem = FALSE

	ExecutedAbility:Set[Item... Scepter of the Forgotten]
	
	;; check to see if we have an item in the Diplomacy Held Item slot
	if ${Me.Inventory[CurrentEquipSlot,Diplomacy Held Item](exists)}
	{
		DiplomacyHeldItem:Set[${Me.Inventory[CurrentEquipSlot,Diplomacy Held Item]}]
		doEquipDiplomacyHeldItem:Set[TRUE]
	}

	;; now equip it and use it
	Me.Inventory[Scepter of the Forgotten]:Equip
	wait 3
	Me.Inventory[Scepter of the Forgotten]:Use
	wait 3	
	
	;; restore previous item
	if ${doEquipDiplomacyHeldItem}
	{
		Me.Inventory[${DiplomacyHeldItem}]:Equip[Diplomacy Held Item]
		wait 3
	}
}

;===================================================
;===    Make sure we assist the tank            ====
;===================================================
function AssistTank()
{
	ExecutedAbility:Set[None]
	EchoIt "Assisting ${Tank}"
	VGExecute /cleartargets
	waitframe
	VGExecute "/assist ${Tank}"
	waitframe
	wait 20 ${Me.TargetHealth}>0
}

;===================================================
;===    Switch target to an encounter           ====
;===================================================
function TargetEncounter()
{
	for ( i:Set[1] ; ${i}<=${Me.Encounter} ; i:Inc )
	{
		if ${Me.FName.Equal[${Me.Encounter[${i}].Target}]}
		{
			ExecutedAbility:Set[Grabbing encounter on me]
			EchoIt "Grabbing encounter on me"
			face ${Pawn[id,${Me.Encounter[${i}].ID}].X} ${Pawn[id,${Me.Encounter[${i}].ID}].Y}
			Pawn[id,${Me.Encounter[${i}].ID}]:Target
			wait 5
			return
		}
	}
	ExecutedAbility:Set[Grabbing 1st encounter]
	EchoIt "Grabbing 1st encounter"
	face ${Pawn[id,${Me.Encounter[1].ID}].X} ${Pawn[id,${Me.Encounter[1].ID}].Y}
	Pawn[id,${Me.Encounter[1].ID}]:Target
	wait 5
}

;===================================================
;===   This is how we will start the fight      ====
;===================================================
function PullTarget()
{
	if ${Me.Target.Distance}<=30 && ${Me.Ability[${RaJinFlare}].IsReady}
	{
		call RaJinFlare
		if ${Return}
		{
			wait 10
			if ${Me.Encounter}>1
			{
				ExecutedAbility:Set[We pulled too many]
				EchoIt "We pulled too many"
				call FeignDeath
			}
		}
	}
}

;===================================================
;===    THis is how we will feign death         ====
;===================================================
function FeignDeath()
{
	;; get our HOT up
	call KissOfHeaven
	;; pretend we are dead
	call UseAbility "${FeignDeath}"
	if ${Return}
	{
		;; wait 3 seconds
		VGExecute /cleartargets
		wait 30
		
		;; start healing self if we need it
		if ${Me.HealthPct}<80
		{
			call BreathOfLife
		}
		return TRUE
	}
	return FALSE
}


;===================================================
;===        RACIAL ABILITY                      ====
;===================================================
function:bool RacialAbility()
{
	call UseAbility "${RacialAbility}"
	if ${Return}
	{
		return TRUE
	}
	return FALSE
}

;===================================================
;===    This is our primary heal                ====
;===================================================
function:bool LaoJinFlash()
{
	;; Higher version
	if ${Me.Ability[${LaoJinFlash}](exists)}
	{
		call UseAbility "${LaoJinFlash}"
		if ${Return}
		{
			return TRUE
		}
		return FALSE
	}
	else
	{
		call LaoJinFlare
		if ${Return}
		{
			return TRUE
		}
		return FALSE
	}
}

;===================================================
;===   This is our primary heal (lesser version ====
;===================================================
function:bool LaoJinFlare()
{
	;; Lower version
	call UseAbility "${LaoJinFlare}"
	if ${Return}
	{
		return TRUE
	}
	return FALSE
}
		
;===================================================
;===    Secondary heal                          ====
;===================================================
function:bool BreathOfLife()
{
	;; higher version
	if ${Me.Ability[${BreathOfLife}](exists)}
	{
		call UseAbility "${BreathOfLife}"
		if ${Return}
		{
			return TRUE
		}
		return FALSE
	}
	else
	{
		call BreathOfRenewal
		if ${Return}
		{
			return TRUE
		}
		return FALSE
	}
}

;===================================================
;===   Secondary heal (lesser)                  ====
;===================================================
function:bool BreathOfRenewal()
{
	;; lower version
	call UseAbility "${BreathOfRenewal}"
	if ${Return}
	{
		return TRUE
	}
	return FALSE
}
	
;===================================================
;===   CHAIN:  HEALING SERIES                   ====
;===================================================
function Crit_HealSeries()
{
	while ${Me.Ability[${ConcordantSplendor}].TriggeredCountdown} || ${Me.Ability[${ConcordantPalm}].TriggeredCountdown} || ${Me.Ability[${ConcordantHand}].TriggeredCountdown}
	{
		ExecutedAbility:Set[/reactionchain 1... Concordan Series]
		VGExecute "/reactionchain 1"
		call GlobalCooldown
		waitframe
	}
}

;===================================================
;===   CRIT:  KISS OF TORMENT                   ====
;===================================================
function Crit_KissOfTorment()
{
	while ${Me.Ability[${KissOfTorment}].TriggeredCountdown}
	{
		ExecutedAbility:Set[/reactioncounter 2... KissOfTorment]
		VGExecute "/reactioncounter 2"
		call GlobalCooldown
		waitframe
	}
}

;===================================================
;===   CRIT:  SUN FIST SERIES                   ====
;===================================================
function Crit_SunFist()
{
	;;;;;;;;;;
	;; Use this when our Jin is low
	while ${Me.Ability[${SuperiorSunFist}].TriggeredCountdown} && ${Me.Ability[${SunFist}].TriggeredCountdown}
	{
		ExecutedAbility:Set[/reactioncounter 5... SunFist Series]
		VGExecute "/reactioncounter 5"
		call GlobalCooldown
		waitframe
	}
}

;===================================================
;===   This is where we want to force a crit    ====
;===================================================
function:bool BuildCrit()
{
	;;;;;;;;;;
	;; Might as well get Purity up and then force a crit
	;; if we are successful then cast Blessed Whirl,
	;; otherwise, we will execute Void Hand
	;; if all else fails then we will cast Breath of Life
	call UseAbility "${Purity}"
	call UseAbility "${Clarity}"
	if ${Return}
	{
		call BlessedWhirl
		if ${Return}
		{
			;; we should still have a crit up
			return TRUE
		}
		call VoidHand
		if ${Return}
		{
			;; we should still have a crit up
			return TRUE
		}
		;; we should still have a crit up
		return TRUE
	}
	;; otherwise we are going to use our 1.5 second heal
	call BreathOfLife
}

;===================================================
;===        BLESSED WHIRL                       ====
;===================================================
function:bool BlessedWhirl()
{
	;; higher version
	if ${Me.Ability[${BlessedWhirl}](exists)}
	{
		call UseAbility "${BlessedWhirl}"
		if ${Return}
		{
			return TRUE
		}
		return FALSE
	}
	else
	{
		call BlessedWind
		if ${Return}
		{
			return TRUE
		}
		return FALSE
	}
}


;===================================================
;===         BLESSED WIND                       ====
;===================================================
function:bool BlessedWind()
{
	;; lower version
	call UseAbility "${BlessedWind}"
	if ${Return}
	{
		return TRUE
	}
	return FALSE
}

;===================================================
;==        HOT:  KISS OF HEAVEN                 ====
;===================================================
function:bool KissOfHeaven()
{
	call UseAbility "${KissOfHeaven}"
	if ${Return}
	{
		return TRUE
	}
	return FALSE
}


;===================================================
;===   regain endurance:  LEECH'S GRASP         ====
;===================================================
function:bool LeechsGrasp()
{
	call UseAbility "${LeechsGrasp}"
	if ${Return}
	{
		return TRUE
	}
	return FALSE
}

;===================================================
;===       ENDOWEMENT OF MASTERY                ====
;===================================================
function Endowment_Mastery()
{
	;;;;;;;;;;
	;; Executing a series of abilities generates a beneficial buff:  reduces 10% energy and endurance costs to all within 10m
	;; this will ignore everything else while it is in this loop thus we risk dying or the tank might die
	if !${Me.Effect[Endowment of Mastery](exists)} && ${Me.Ability[${SoulCutter}].IsReady} && ${Me.Ability[${VoidHand}].IsReady} && ${Me.Ability[${KnifeHand}].IsReady} 
	{
		if ${EndowmentStep} == 1
		{
			call SoulCutter
			if ${Return}
			{
				EndowmentStep:Set[2]
			}
		}
		if ${EndowmentStep} == 2
		{
			call VoidHand
			if ${Return}
			{
				EndowmentStep:Set[3]
			}
		}
		if ${EndowmentStep} == 3
		{
			call KnifeHand
			if ${Return}
			{
				EndowmentStep:Set[1]
			}
		}
	}
}

;===================================================
;===       ENDOWEMENT OF ENMITY                 ====
;===================================================
function Endowment_Enmity()
{
	;;;;;;;;;;
	;; Executing a series of abilities generates a beneficial buff:  increase 10% damage for self
	;; this will ignore everything else while it is in this loop thus we risk dying or the tank might die
	if !${Me.Effect[Endowment of Enmity](exists)} && ${Me.Ability[${CycloneKick}].IsReady} && ${Me.Ability[${RaJinFlare}].IsReady}
	{
		if ${EndowmentStep} == 1
		{
			call CycloneKick
			if ${Return}
			{
				EndowmentStep:Set[2]
			}
		}
		if ${EndowmentStep} == 2
		{
			call RaJinFlare
			if ${Return}
			{
				EndowmentStep:Set[1]
			}
		}
	}
}

;===================================================
;===       ENDOWEMENT OF LIFE                   ====
;===================================================
function Endowment_Life()
{
	;;;;;;;;;;
	;; Executing a series of abilities generates a beneficial buff:  increase DTarget's health and regenerates our jin
	;; this is where we want to make sure we set the DTarget to whom we want to get the benefits of this, ie the Tank
	if ${Me.Ability[${BlessedWind}].IsReady} && ${Me.Ability[${CycloneKick}].IsReady} && ${Me.Ability[${VoidHand}].IsReady}
	{
		if ${EndowmentStep} == 1
		{
			call BlessedWhirl
			if ${Return}
			{
				EndowmentStep:Set[2]
			}
		}
		if ${EndowmentStep} == 2
		{
			call CycloneKick
			if ${Return}
			{
				EndowmentStep:Set[3]
			}
		}
		if ${EndowmentStep} == 3
		{
			if !${Me.Effect[Endowment of Life](exists)}
			{
				;; target myself if we do not have the buff
				if !${Me.DTarget.Name.Equal[${Me.FName}]}
				{
					Pawn[me]:Target
					wait 3
				}
			}
			else
			{
				if !${Me.DTarget.Name.Equal[${Tank}]}
				{
					;; otherwise, target the tank
					doTankEndowementOfLife:[FALSE]
					Pawn[${Tank}]:Target
					wait 3
				}
			}
			call VoidHand
			if ${Return}
			{
				EndowmentStep:Set[1]
			}
		}
	}
}
	
;===================================================
;===       BLOOMING RIDGE HAND                  ====
;===================================================
function BloomingRidgeHand()
{
	call UseAbility "${BloomingRidgeHand}"
	if ${Return}
	{
		return TRUE
	}
	return FALSE
}

;===================================================
;===    regain energy:  MINDLESS CLUTCH         ====
;===================================================
function MindlessClutch()
{
	call UseAbility "${MindlessClutch}"
	if ${Return}
	{
		return TRUE
	}
	return FALSE
}



;===================================================
;===     CRIT:  PETAl SERIES (Adds to healing)  ====
;===================================================
function Crit_PetalSeries()
{
	;;;;;;;;;;
	;; This add more to our healing so we want to ensure this is always up
	while ${Me.Ability[${FallingPetal}].TriggeredCountdown} || ${Me.Ability[${PetalSplitsEarth}].TriggeredCountdown} || ${Me.Ability[${WhiteLotusStrike}].TriggeredCountdown}
	{
		ExecutedAbility:Set[/reactionchain 2... Petal Series]
		VGExecute "/reactionchain 2"
		call GlobalCooldown
		waitframe
	}
}

;===================================================
;===    CRIT:  DISCORD SERIES (DPS)             ====
;===================================================
function Crit_DPS()
{
	while ${Me.Ability[${TouchOfDiscord}].TriggeredCountdown} || ${Me.Ability[${FocusedSonicBlast}].TriggeredCountdown} || ${Me.Ability[${PalmOfDiscord}].TriggeredCountdown} || ${Me.Ability[${FistOfDiscord}].TriggeredCountdown}
	{
		ExecutedAbility:Set[/reactionchain 3... Discord Series]
		VGExecute "/reactionchain 3"
		call GlobalCooldown
		waitframe
	}
}

;===================================================
;===   RANGED DAMAGE:  RA'JIN FLARE             ====
;===================================================
function:bool RaJinFlare()
{
	call UseAbility "${RaJinFlare}"
	if ${Return}
	{
		return TRUE
	}
	return FALSE
}


;===================================================
;===       KNIFE HAND                           ====
;===================================================
function:bool KnifeHand()
{
	call UseAbility "${KnifeHand}"
	if ${Return}
	{
		return TRUE
	}
	return FALSE
}

;===================================================
;===        VOID HAND                           ====
;===================================================
function:bool VoidHand()
{
	call UseAbility "${VoidHand}"
	if ${Return}
	{
		return TRUE
	}
	return FALSE
}

;===================================================
;===      SOUL CUTTER                           ====
;===================================================
function:bool SoulCutter()
{
	call UseAbility "${SoulCutter}"
	if ${Return}
	{
		return TRUE
	}
	return FALSE
}

;===================================================
;===     CYCLONE KICK (higher chance for Crit)  ====
;===================================================
function:bool CycloneKick()
{
	call UseAbility "${CycloneKick}"
	if ${Return}
	{
		return TRUE
	}
	return FALSE
}

;===================================================
;===        SET HIGHEST ABILITY                 ====
;===================================================
atom(script) SetHighestAbility(string AbilityVariable, string AbilityName)
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
	AbilityLevels[9]:Set[IX]

	;-------------------------------------------
	; Return if Ability already exists - based upon current level
	;-------------------------------------------
	if ${Me.Ability["${AbilityName}"](exists)} && ${Me.Ability[${ABILITY}].LevelGranted}<=${Me.Level}
	{
		EchoIt "[${AbilityVariable}] = ${ABILITY}"
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
		EchoIt "[${AbilityVariable}] = ${ABILITY}"
		declare	${AbilityVariable} string script "${ABILITY}"
		return
	}

	;-------------------------------------------
	; Otherwise, new Ability is named "None"
	;-------------------------------------------
	EchoIt "[${AbilityVariable}] = None"
	declare	${AbilityVariable} string script "None"
	return
}

;===================================================
;===       USE ABILITY                          ====
;===================================================
function:bool UseAbility(string ABILITY)
{
	if !${Me.Ability[${ABILITY}](exists)} || ${Me.Ability[${ABILITY}].LevelGranted}>${Me.Level}
	{
		return FALSE
	}
	
	;; this will stop attacks if we are not supposed to attack
	if ${Me.Ability[${ABILITY}].School.Find[Attack]} || ${Me.Ability[${ABILITY}].School.Find[Counterattack]}
	{
		call OkayToAttack
		if !${Return}
		{
			return FALSE
		}
	}

	;; this will ensure the ability is ready to use
	call IsCasting
	
	if ${Me.Ability[${ABILITY}].IsReady}
	{
		if ${Me.Ability[${ABILITY}].JinCost}>0 || ${Me.Ability[${ABILITY}].EnduranceCost}>0 || ${Me.Ability[${ABILITY}].EnergyCost}>0
		{
			;EchoIt "${ABILITY}:  JinCost=${Me.Ability[${ABILITY}].JinCost}<=${Me.Stat[Adventuring,Jin]}, EnduranceCost=${Me.Ability[${ABILITY}].EnduranceCost}<=${Me.Endurance}, EnergyCost=${Me.Ability[${ABILITY}].EnergyCost}<=${Me.Energy}"
			;; check if we have enough Jin
			if ${Me.Ability[${ABILITY}].JinCost}>=${Me.Stat[Adventuring,Jin]}
			{
				EchoIt "1-${ABILITY}:  JinCost=${Me.Ability[${ABILITY}].JinCost}<=${Me.Stat[Adventuring,Jin]}, EnduranceCost=${Me.Ability[${ABILITY}].EnduranceCost}<=${Me.Endurance}, EnergyCost=${Me.Ability[${ABILITY}].EnergyCost}<=${Me.Energy}"
				return FALSE
			}
			;; check if we have enough endurance
			if ${Me.Ability[${ABILITY}].EnduranceCost}>=${Me.Endurance}
			{
				EchoIt "2-${ABILITY}:  JinCost=${Me.Ability[${ABILITY}].JinCost}<=${Me.Stat[Adventuring,Jin]}, EnduranceCost=${Me.Ability[${ABILITY}].EnduranceCost}<=${Me.Endurance}, EnergyCost=${Me.Ability[${ABILITY}].EnergyCost}<=${Me.Energy}"
				return FALSE
			}
			;; check if we have enough energy
			if ${Me.Ability[${ABILITY}].EnergyCost}>=${Me.Energy}
			{
				EchoIt "3-${ABILITY}:  JinCost=${Me.Ability[${ABILITY}].JinCost}<=${Me.Stat[Adventuring,Jin]}, EnduranceCost=${Me.Ability[${ABILITY}].EnduranceCost}<=${Me.Endurance}, EnergyCost=${Me.Ability[${ABILITY}].EnergyCost}<=${Me.Energy}"
				return FALSE
			}
		}
		Me.Ability[${ABILITY}]:Use
		ExecutedAbility:Set[${ABILITY}]
		EchoIt "UseAbility: ${ABILITY}"
		wait 3
		call IsCasting
		return TRUE
	}
	return FALSE
}

;===================================================
;===      HANDLES GLOBAL COOLDOWNS              ====
;===================================================
function GlobalCooldown()
{
	wait 3
	while ${VG.InGlobalRecovery} || !${Me.Ability["Torch"].IsReady}
	{
		call AutoAttack
	}
}

;===================================================
;===     HANDLES WHILE CASTING/COOLDOWNS        ====
;===================================================
function IsCasting()
{
	while ${Me.IsCasting}
	{
		waitframe
	}
	while (${VG.InGlobalRecovery} || ${Me.ToPawn.IsStunned} || !${Me.Ability[Torch].IsReady})
	{
		wait 2
	}
}

;===================================================
;===    AUTO ATTACK:  ON/OFF                    ====
;===================================================
function:bool AutoAttack()
{
	call OkayToAttack
	if ${Return} && ${Me.Target.Distance}<5
	{
		;; turn on auto-attack
		if !${GV[bool,bIsAutoAttacking]} || !${Me.Ability[Auto Attack].Toggled}
		{
			;vgecho "Turning AutoAttack ON"
			Me.Ability[Auto Attack]:Use
			wait 10 ${GV[bool,bIsAutoAttacking]} && ${Me.Ability[Auto Attack].Toggled}
			return
		}
	}
	else
	{
		;; turn off
		call MeleeAttackOff
	}
}	

;===================================================
;===       MELEE ATTACKS OFF SUB-ROUTINE        ====
;===================================================
function MeleeAttackOff()
{
	if ${GV[bool,bIsAutoAttacking]} || ${Me.Ability[Auto Attack].Toggled}
	{
		;; Turn off auto-attack if target is not a resource
		if !${Me.Target.Type.Equal[Resource]}
		{
			if ${Me.TargetBuff[Furious](exists)} || ${Me.TargetBuff[Furious Rage](exists)}
			{
				vgecho "FURIOUS"
			}
			if ${Me.Effect[Devout Foeman I](exists)} || ${Me.Effect[Devout Foeman II](exists)} || ${Me.Effect[Devout Foeman III](exists)}
			{
				vgecho "Devout Foeman"
			}
			if ${Me.TargetBuff[Rust Shield](exists)} || ${Me.Effect[Mark of Verbs](exists)} || ${Me.TargetBuff[Charge Imminent](exists)}
			{
				vgecho "Rust Shield/Mark of Verbs/Charge Imminent"
			}
			if ${Me.TargetBuff[Major Disease: Fire Advocate](exists)}
			{
				vgecho "Fire Advocate"
			}

			vgecho "Turning AutoAttack OFF"

			Me.Ability[Auto Attack]:Use
			wait 15 !${GV[bool,bIsAutoAttacking]} && !${Me.Ability[Auto Attack].Toggled}
		}
	}
}

;===================================================
;===          OKAY TO ATTACK                    ====
;===================================================
function:bool OkayToAttack()
{
	;;;;;;;;;;
	;; The following are things I found we do not want to attack through
	if ${Me.Target(exists)} && !${Me.Target.IsDead} && ${Me.TargetHealth}<=${StartAttack}
	{
		;; target must be an NPC or AggroNPC
		if ${Me.Target.Type.Find[NPC]} || ${Me.Target.Type.Equal[AggroNPC]}
		{
			;; make sure we are in combat, tank is in combat, or we are not in a group
			if !${Me.IsGrouped} || ${Me.InCombat} || ${Pawn[Name,${Tank}].CombatState}>0
			{
				if !${Me.TargetHealth(exists)}
				{
					return FALSE
				}
				if ${Me.TargetBuff[Furious](exists)} || ${Me.TargetBuff[Furious Rage](exists)}
				{
					return FALSE
				}
				if ${Me.Effect[Devout Foeman I](exists)} || ${Me.Effect[Devout Foeman II](exists)} || ${Me.Effect[Devout Foeman III](exists)}
				{
					return FALSE
				}
				if ${Me.TargetBuff[Rust Shield](exists)} || ${Me.Effect[Mark of Verbs](exists)} || ${Me.TargetBuff[Charge Imminent](exists)}
				{
					return FALSE
				}
				if ${Me.TargetBuff[Major Disease: Fire Advocate](exists)}
				{
					return FALSE
				}
				if ${Me.Effect[Marshmallow Madness](exists)}
				{
					return FALSE
				}
				
				;; we definitely do not want to be hitting any of these mobs!
				if ${Me.Target.Name.Equal[Corrupted Essence]}
				{
					return FALSE
				}
				if ${Me.Target.Name.Equal[Corrupted Residue]}
				{
					return FALSE
				}
				
				;; Now, let's face the target
				if ${doFaceTarget}
				{
					Me.Target:Face
				}
				return TRUE
			}
		}
	}
	return FALSE
}
