;
;===================================================
;===               DEFINES                      ====
;===================================================
#define ALARM "${Script.CurrentDirectory}/ping.wav"
;
;===================================================
;===     DEFINE/INITIALIZE OUR OBJECTIVES       ====
;===================================================
;variable obj_Face Face
;variable obj_Move Move
;
;===================================================
;===         VARIABLES USED BY UI               ====
;===================================================
;; Main
variable string Version = "1.0"
variable bool doEcho = TRUE
variable bool isPaused = TRUE
variable bool isRunning = TRUE
variable int StartAttack = 100
variable string Tank
variable string CurrentAction = "Loading Variables"
variable string TargetsTarget = "No Target"
variable string CombatForm
variable string NonCombatForm
;; Toggles
variable bool doFace
variable bool doMove
variable bool doCycleTargets
variable bool doAutoRez
variable bool doAutoRepair
variable bool doConsumables
variable bool doSprint
variable int Speed
variable bool doCancelBuffs
variable bool doSound
;; Abilities
variable bool doRanged
variable bool doMelee
variable bool doRescues
variable bool doCounters
variable bool doChains
variable bool doHatred
;; Counters
variable bool doRetaliate
variable bool doVengeance
;; Rescues
variable bool doSeethingHatred
variable bool doScourge
variable bool doNexusOfHatred
;; Hatred/AE
variable bool doProvoke
variable bool doTorture
variable bool doBlackWind
variable bool doScytheOfDoom
;; Chains
variable bool doHexOfIllOmen
variable bool doIncite
variable bool doShieldOfFear
variable bool doVileStrike
variable bool doWrack
;; Melee
variable bool doVexingStrike
variable bool doMalice
variable bool doMutilate
variable bool doRavagingDarkness
variable bool doSlay
variable bool doBacklash
;; Loot
variable bool doLoot
variable bool doRaidLoot
variable bool doLootOnly
variable int LootDelay
variable string LootOnly
variable bool doLootEcho
;; Hunt
variable bool doHunt = FALSE
variable int MobMinLevel
variable int MobMaxLevel
variable int ConCheck
variable int Distance
variable float HomeX
variable float HomeY
variable float HomeZ
;
;===================================================
;===       VARIABLES USED BY SCRIPT             ====
;===================================================
variable bool doForm = TRUE
variable bool FURIOUS = FALSE
variable int LastDowntimeCall=${Script.RunningTime}
variable int NextUpdateDisplay = ${Script.RunningTime}
variable bool doCycleTargetsReady = TRUE
;
