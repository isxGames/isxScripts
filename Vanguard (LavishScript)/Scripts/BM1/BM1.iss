;===================================================
;===            VARIABLES                       ====
;===================================================

;; Assist / Follow
variable string Tank = Unknown
variable string OffTank = Unknown
variable string Follow = Unknown

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
variable int DelayAttack = 5
variable int Speed = 100
variable int AngleDiff = 0
variable int AngleDiffAbs = 0
variable int FollowDistance1 = 3
variable int FollowDistance2 = 7
variable int64 CurrentTargetID = 0
variable int64 LastTargetID = 0
variable bool doEcho = TRUE
variable bool isPaused = TRUE
variable bool isRunning = TRUE
variable bool isFurious = FALSE
variable bool doAcceptRez = FALSE
variable bool RemoveCurse = FALSE
variable bool RemovePoison = FALSE
variable bool doEchoShadowRain = FALSE
variable bool doFindGroupMembers = TRUE
variable bool doSymbioteRequest = FALSE
variable bool doFollow = FALSE
variable(global) bool doBuffArea = FALSE
variable bool doSprint = TRUE
variable bool doFace = TRUE
variable bool UseAbilities = TRUE
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
variable bool doRemoveHate = FALSE
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
variable bool doBloodFeast = TRUE

;; Collection variables
variable(global) collection:string SymbioteRequestList

;; Delay Timers
variable int NextShadowRain = ${Script.RunningTime}
variable int NextDelayCheck = ${Script.RunningTime}
variable int NextSpeedCheck = ${Script.RunningTime}
variable int NextAttackCheck = ${Script.RunningTime}

;; Defines - you will need to add this to every Include file if you plan on using it
#define ALARM "${Script.CurrentDirectory}/ping.wav"

;; Includes - 
#include ./BM1/Includes/FindAction.iss
#include ./BM1/Includes/PerformAction.iss
#include ./BM1/Includes/SubRoutines.iss
#include ./BM1/Includes/AttackRoutines.iss
#include ./BM1/Includes/Atoms.iss
#include ./BM1/Includes/Objects.iss
#include ./BM1/Includes/Immunities.iss
#include ./BM1/Includes/VitalHeals.iss
;#include ./BM1/Includes/BuffArea.iss

;===================================================
;===            MAIN SCRIPT                     ====
;===================================================
function main()
{
	;-------------------------------------------
	; INITIALIZE - setup script
	;-------------------------------------------
	call Initialize
	
	;-------------------------------------------
	; LOOP THIS INDEFINITELY - Find Action and then Perform Action
	;-------------------------------------------
	while ${isRunning}
	{
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
	;HUD -remove HUD-1
	;HUD -remove HUD-2
	;HUD -remove HUD-3
	;HUD -remove DPSHUD
	;HUD -remove EncounterHUD
	;HUD -remove TypeHUD
	;Script:Unsquelch
	
	Event[VG_onHitObstacle]:DetachAtom[Bump]
	Event[OnFrame]:DetachAtom[OnFrame]
	Event[OnFrame]:DetachAtom[Immunities]
	Event[VG_OnPawnSpawned]:DetachAtom[PawnSpawned]
	Event[VG_OnIncomingText]:DetachAtom[ChatEvent]
	Event[VG_OnIncomingCombatText]:DetachAtom[CombatText]


	;; Unload our UI
	ui -unload "${Script.CurrentDirectory}/BM1.xml"
	
	;; Unload Counter routine
	if ${Script[Counter](exists)}
	{
		endscript Counter
	}

	;; Unload Loot routine
	if ${Script[Loot](exists)}
	{
		endscript Loot
	}

	;; Unload BuffArea routine
	if ${Script[BuffArea](exists)}
	{
		endscript BuffArea
	}

	;; Unload Symbiote routine
	if ${Script[Symbiotes](exists)}
	{
		endscript Symbiotes
	}
	
	;; Say we are done
	echo "Stopped BM1 Script"
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
	SetHighestAbility "ConstructsAugmentation" "Construct's Augmentation"
	SetHighestAbility "FavorOfTheLifeGiver" "Favor of the Life Giver"

	SetHighestAbility "SeraksAmplification" "Serak's Amplification"
	SetHighestAbility "Inspirit" "Inspirit"
	SetHighestAbility "LifeGraft" "Life Graft"
	SetHighestAbility "MentalStimulation" "Mental Stimulation"
	SetHighestAbility "AcceleratedRegeneration" "Accelerated Regeneration"
	SetHighestAbility "CerebralGraft" "Cerebral Graft"

	SetHighestAbility "HealthGraft" "Health Graft"
	SetHighestAbility "MentalInfusion" "Mental Infusion"
	SetHighestAbility "SeraksAugmentation" "Serak's Augmentation"
	SetHighestAbility "SeraksMantle" "Serak's Mantle"
	SetHighestAbility "Vitalize" "Vitalize"

	SetHighestAbility "Regeneration" "Regeneration"
	;; === MISC ===
	SetHighestAbility "BloodFeast" "Blood Feast"
	SetHighestAbility "MentalTransmutation" "Mental Transmutation"
	SetHighestAbility "LifeHusk" "Life Husk"
	SetHighestAbility "ShelteringRune" "Sheltering Rune"
	SetHighestAbility "StripEnchantment" "Strip Enchantment"
	SetHighestAbility "RitualOfAwakening" "Ritual of Awakening"
	SetHighestAbility "Constrict" "Constrict"
	SetHighestAbility "Numb" "Numb"
	
	;; === SYMBIOTES ===
	SetHighestAbility "ConduciveSymbiote" "Conducive Symbiote"
	SetHighestAbility "FrenziedSymbiote" "Frenzied Symbiote"
	SetHighestAbility "QuickeningSymbiote" "Quickening Symbiote"
	SetHighestAbility "VitalizingSymbiote" "Vitalizing Symbiote"
	SetHighestAbility "PlatedSymbiote" "Plated Symbiote"
	SetHighestAbility "RenewingSymbiote" "Renewing Symbiote"

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
	Event[VG_onHitObstacle]:AttachAtom[Bump]
	
	;-------------------------------------------
	; Clear our collection variables
	;-------------------------------------------
	SymbioteRequestList:Clear

	;-------------------------------------------
	; Start our Counter routine running
	;-------------------------------------------
	if !${Script[Counter](exists)}
	{
		run ./BM1/Counter.iss
	}

	;-------------------------------------------
	; Start our Loot routine running
	;-------------------------------------------
	if !${Script[Loot](exists)}
	{
		run ./BM1/Loot.iss
	}
	
	;-------------------------------------------
	; SHOW OUR HUD
	;-------------------------------------------
	;Script:Squelch
	;HUD -add HUD-1 900,455 "Ready    =${Me.Ability[${BloodTribute}].IsReady}"
	;HUD -add HUD-2 900,470 "CountDown=${Me.Ability[${BloodTribute}].TriggeredCountdown}"
	;HUD -add HUD-3 900,485 "Reamining=${Me.Ability[${BloodTribute}].TimeRemaining}"
	;HUD -add HUD-4 900,900 "DPS=${Script[BM1].Variable[DPS]}, Damage=DPS=${Script[BM1].Variable[DamageDone]} "
	;HUD -add EncounterHUD 900,915 "Encounters: ${Me.Encounter}"
	;HUD -add TypeHUD 900,930 "Type: ${Me.Target.Type}"
	;Script:Unsquelch
}	


