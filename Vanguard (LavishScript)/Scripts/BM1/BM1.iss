;===================================================
;===            VARIABLES                       ====
;===================================================

;; Tank / Assist
variable string Tank = Unknown

; Healing variables
variable int HealCheck = 50
variable int HealGroupNumber
variable int LifeTapCheck = 80
variable int LifeTapGroupNumber = 0
variable int TotalWounded = 0
variable bool HealNow
variable bool SafeToDPS
variable bool doCritWait = FALSE
variable bool doCritHealOnly = TRUE
variable bool doTankOnly = FALSE
variable bool doHealGroupOnly = FALSE
variable string GROUP1 = Unknown1
variable string GROUP2 = Unknown2
variable string GROUP3 = Unknown3
variable string GROUP4 = Unknown4
variable string GROUP5 = Unknown5
variable string GROUP6 = Unknown6
variable int GN1 = 0
variable int GN2 = 0
variable int GN3 = 0
variable int GN4 = 0
variable int GN5 = 0
variable int GN6 = 0

;; Script Variables
variable int h
variable int i
variable int j
variable int TankGN
variable int StartAttack = 99
variable int AngleDiff = 0
variable int AngleDiffAbs = 0
variable int64 CurrentTargetID = 0
variable int64 LastTargetID = 0
variable bool doEcho = TRUE
variable bool isRunning = TRUE
variable bool isPaused = TRUE
variable bool isFurious = FALSE
variable bool doAcceptRez = TRUE
variable bool RemoveCurse = FALSE
variable bool RemovePoison = FALSE
variable bool doEchoShadowRain = FALSE
variable bool doFindGroupMembers = TRUE
variable bool doFollow = FALSE
variable bool doBuffArea = FALSE
variable bool doSprint = TRUE
variable bool doFace = TRUE
variable int Speed = 100
variable int DelayAttack = 5
variable int FollowDistance1 = 3
variable int FollowDistance2 = 7
variable string PreviousForm
variable string CounteredAbility
variable string CurrentChunk
variable string CurrentTarget 
variable string StripThisEnchantment

;; DPS Variables
variable int DPS = 0
variable int DamageDone = 0
variable int TimeFought = 0
variable int ParseDamage = 0
variable int EndAttackTime = 0
variable int StartAttackTime = 0
variable bool ResetParse = FALSE

;; Ability Toggles
variable bool doAssist = TRUE
variable bool doAE = TRUE
variable bool doDots = TRUE
variable bool doMeleeAttacks = TRUE
variable bool doLifeTaps = TRUE
variable bool doSkip = TRUE
variable bool doCrits = TRUE
variable bool doCounters = TRUE
variable bool doWeakness = TRUE
variable bool doClickies = TRUE
variable bool doLootAll = FALSE
variable bool doRemoveHate = TRUE
variable bool doVitalHeals = TRUE
variable bool doStripEnchantments = TRUE
variable bool doDissolve = TRUE
variable bool doMetamorphism = TRUE
variable bool doExsanguinate = TRUE
variable bool doBloodTribute = TRUE
variable bool doFleshRend = TRUE
variable bool doBloodSpray = TRUE
variable bool doDespoil = TRUE
variable bool doEntwiningVein = TRUE
variable bool doBloodthinner = TRUE
variable bool doBurstingCyst = TRUE
variable bool doUnionOfBlood = TRUE
variable bool doExplodingCyst = TRUE
variable bool doBloodLettingRitual = TRUE
variable bool doScarletRitual = TRUE
variable bool doSeveringRitual = TRUE

;; Delay Timers
variable int NextShadowRain = ${Script.RunningTime}
variable int NextDelayCheck = ${Script.RunningTime}
variable int NextSpeedCheck = ${Script.RunningTime}
variable int NextAttackCheck = ${Script.RunningTime}

;; Includes
#include ./BM1/Includes/FindAction.iss
#include ./BM1/Includes/PerformAction.iss
#include ./BM1/Includes/SubRoutines.iss
#include ./BM1/Includes/AttackRoutines.iss
#include ./BM1/Includes/Atoms.iss
#include ./BM1/Includes/Objects.iss
#include ./BM1/Includes/Immunities.iss
#include ./BM1/Includes/VitalHeals.iss
#include ./BM1/Includes/BuffArea.iss

;; Defines
#define ALARM "${Script.CurrentDirectory}/ping.wav"


;===================================================
;===            MAIN SCRIPT                     ====
;===================================================
function main()
{
	;PlaySound ALARM
	;variable string xText
	;variable string yText
	;yText:Set[Nexus Portal's <highlight>Planar Curse: Zodiac</color> deals <highlight>1863</color> planar damage to Thundercloud.]
	;yText:Set[${yText.Mid[${yText.Find[</color> planar damage to]},${yText.Length}].Token[2,>].Token[1,.]}]
	;yText:Set[${yText.Right[${Math.Calc[${yText.Length}-17]}]}]
	;echo "[${yText}]"

	;-------------------------------------------
	; INITIALIZE - setup script
	;-------------------------------------------
	call Initialize
	
	;-------------------------------------------
	; LOOP THIS INDEFINITELY
	;-------------------------------------------
	while ${isRunning}
	{
		call QueuedCommand
		FindAction
		call PerformAction
	}
}

;===================================================
;===     ATOM - CALLED AT END OF SCRIPT         ====
;===================================================
function atexit()
{
	;-------------------------------------------
	; Remove our HUDs
	;-------------------------------------------
	;Script:Squelch
	;HUD -remove NameHUD
	;HUD -remove CastingHUD
	;HUD -remove ToTHUD
	;HUD -remove DPSHUD
	;HUD -remove EncounterHUD
	;HUD -remove TypeHUD
	;Script:Unsquelch

	;; Unload our UI
	ui -unload "${Script.CurrentDirectory}/BM1.xml"
	
	;; Unload Counter routine
	if ${Script[Counter](exists)}
	{
		endscript Counter
	}
		
	;; Say we are done
	EchoIt "Stopped PSI Script"
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
	EchoIt "Started BM Script"
	wait 30 ${Me.Chunk(exists)}
	CurrentChunk:Set[${Me.Chunk}]

	;; Setup and Declare Abilities
	;; === CHAINS ===
	SetHighestAbility "Exsanguinate" "Exsanguinate"
	SetHighestAbility "BloodTribute" "Blood Tribute"
	SetHighestAbility "FleshRend" "Flesh Rend"
	SetHighestAbility "BloodSpray" "Blood Spray"
	;; === COUNTERS ===
	SetHighestAbility "Dissolve" "Dissolve"
	SetHighestAbility "Metamorphism" "Metamorphism"
	;; === DOTS ===
	SetHighestAbility "BurstingCyst" "Bursting Cyst"
	SetHighestAbility "UnionOfBlood" "Union of Blood"
	SetHighestAbility "ExplodingCyst" "Exploding Cyst"
	SetHighestAbility "BloodLettingRitual" "Blood Letting Ritual"
	;; === AE ===
	SetHighestAbility "SeveringRitual" "Severing Ritual"
	SetHighestAbility "BloodThief" "Blood Thief"
	;; === LIFETAPS ===
	SetHighestAbility "Despoil" "Despoil"
	SetHighestAbility "EntwiningVein" "Entwining Vein"
	SetHighestAbility "Bloodthinner" "Bloodthinner"
	;; === NUKE/FINISHER ===
	SetHighestAbility "ScarletRitual" "Scarlet Ritual"
	;; === HEALS ===
	SetHighestAbility "InfuseHealth" "Infuse Health"
	SetHighestAbility "BloodGift" "Blood Gift"
	SetHighestAbility "PhysicalTransmutation" "Physical Transmutation"
	SetHighestAbility "RecoveringBurst" "Recovering Burst"
	SetHighestAbility "SuperiorRecoveringBurst" "Superior Recovering Burst"
	;; === HOTs ===
	SetHighestAbility "FleshMendersRitual" "Flesh Mender's Ritual"
	SetHighestAbility "TransfusionOfSerak" "Transfusion of Serak"
	;; === BUFFS ===
	SetHighestAbility "BloodFeast" "Blood Feast"
	SetHighestAbility "SeraksMantle" "Serak's Mantle"
	SetHighestAbility "HealthGraft" "Health Graft"
	SetHighestAbility "SeraksAugmentation" "Serak's Augmentation"
	SetHighestAbility "Vitalize" "Vitalize"
	SetHighestAbility "MentalInfusion" "Mental Infusion"
	SetHighestAbility "CerebralGraft" "Cerebral Graft"
	SetHighestAbility "LifeGraft" "Life Graft"
	SetHighestAbility "MentalStimulation" "Mental Stimulation"
	SetHighestAbility "Regeneration" "Regeneration"
	SetHighestAbility "FavorOfTheLifeGiver" "Favor of the Life Giver"
	SetHighestAbility "ConstructsAugmentation" "Construct's Augmentation"
	;; === MISC ===
	SetHighestAbility "MentalTransmutation" "Mental Transmutation"
	SetHighestAbility "LifeHusk" "Life Husk"
	SetHighestAbility "ShelteringRune" "Sheltering Rune"
	SetHighestAbility "StripEnchantment" "Strip Enchantment"
	SetHighestAbility "RitualOfAwakening" "Ritual of Awakening"
	SetHighestAbility "Numb" "Numb"
	
	;; Set Tank based upon DTarget
	if !${Me.DTarget.ID(exists)}
	{
		Pawn[me]:Target
		wait 5
	}
	Tank:Set[${Me.DTarget.Name}]

	;; Load our Settings
	;LoadXMLSettings	

	;; Reload the UI
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	ui -reload -skin VGSkin "${Script.CurrentDirectory}/BM1.xml"

	;-------------------------------------------
	; Enable Events - these events are automatically removed at shutdown
	;-------------------------------------------
	Event[VG_OnIncomingCombatText]:AttachAtom[CombatText]
	Event[VG_OnIncomingText]:AttachAtom[ChatEvent]
	Event[VG_OnPawnSpawned]:AttachAtom[PawnSpawned]
	Event[OnFrame]:AttachAtom[Immunities]
	Event[OnFrame]:AttachAtom[OnFrame]
	
	;-------------------------------------------
	; Get our Counter routine running
	;-------------------------------------------
	if !${Script[Counter](exists)}
	{
		run ./BM1/Counter.iss
	}

	
	;-------------------------------------------
	; SHOW OUR HUD
	;-------------------------------------------
	;Script:Squelch
	;HUD -add ToTHUD 900,855 "ToT: ${Me.ToT.Name}"
	;HUD -add CastingHUD 900,870 "Casting: ${Me.TargetCasting}"
	;HUD -add NameHUD 900,885 "Status: ${Script[BM1].Variable[PerformAction]}"
	;HUD -add DPSHUD 900,900 "DPS=${Script[BM1].Variable[DPS]}, Damage=DPS=${Script[BM1].Variable[DamageDone]} "
	;HUD -add EncounterHUD 900,915 "Encounters: ${Me.Encounter}"
	;HUD -add TypeHUD 900,930 "Type: ${Me.Target.Type}"
	;Script:Unsquelch
}	


