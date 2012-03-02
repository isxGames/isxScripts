;-----------------------------------------------------------------------------------------------
; VG-DSC.iss
;
; Description - Script for Disciples
; -----------
; * Attacks your target
; * Auto Attack turns on and off
; * Generate and maintain Endowments
; * Item List Manager (Sells/Deletes/Decons)
; * LavishNav for hunting
;
; Revision History
; ----------------
; 20120116 (Zandros)
;  * A simple script that handles combat, no UI support
;
; 20120119 (Zandros)
; * Added the UI that allows you to change various setting in combat as
;   well as a visual display to show you the Actio being performed and the
;   Ability being executed.  No routines for saving your settings to file.
;
; 20120128 (Zandros)
; * Added saving variables; added Item List Manager which will allow you to
;   delete non-sellable items (trash), sell items for profit, and decon items; also,
;   added basic looting routines
;
; 20120130 (Zandros)
; * Implementing my version of LavishNav so that it can map an area and move around
;   obstacles.  This will be used for hunting.
;
; 20120203 (Zandros)
; * Fixed many things such as:  what to do if you run out of Shurikens, what if the
;   target push you out of melee range, what if you get too many Encounters....
;
; 20120207 (Zandros)
; * Added bump and line of sight routines.  If you can't hit the target is will backup
;   and try again.  If it still can't hit the target it will clear all targets and go look
;   for a new target.
;
; 20120212 (Zandros)
; * Added toggles to control type of target to attack (AggroNPC and NPC).  Made some minor
;   adjustments to the routines "Endowment of Life", "MoveToMeleeDistance", and "PullTarget".
;   If you notice a small delay when targetting and moving, it is because the script is waiting
;   for the target's health to be anything other than 0 or NULL.
;
; 20120213 (Zandros)
; * Will now use "Varaelian Orb of the Moon and Stars" or "Queldoral, Bounty of the Gods" to
;   generate 2000 shurikens "Sun Strik of Vol Anari"
;
; 20120216 (Zandros)
; * Several new things added and fixed.  Feign Death will now break free after 5 seconds or when
;   there are no AggroNPC within 10 meters.  You will now pop a Merchant to repair your gear when the 
;   durability reaches 50% or when your bag space has 2 or less free spots.  If you are not rezzed
;   when you die and teleported back to the Altar, it will summon your corpse and camp out.  It
;   will also camp if it detects a server shutdown.
;
; 20120218 (Zandros)
; * Made a quick fix for selling your loot... it now sells quickly.  Added in the routine to
;   replenish shurikens using "Tam Thi's Gift".  Updated the event log to show what channel the
;   message belongs to.  
;
; 20120225 (Zandros)
; * Added ISXIM allowing you to use Yahoo Instant Messenger to receive messages as well as
; send commands to your script.  Fixed a problem with what appears to be the script locking
; up when you are not looting and the target dies... it now clears the target or fetch the next
; encounter.
;
;===================================================
;===            VARIABLES                       ====
;===================================================

;; Script variables
variable int i
variable bool isRunning = TRUE
variable bool isPaused = FALSE
variable bool isSitting = FALSE
variable bool doJustDied = FALSE
variable bool doServerShutdown = FALSE
variable bool doTankEndowementOfLife = TRUE
variable bool doRangedWeapon = TRUE
variable bool FeignDeathFailed = FALSE
variable string Tank = ${Me.FName}
variable string Follow = ${Me.FName}
variable string temp
variable string LastAction = Nothing
variable int EndowmentStep = 1
variable int NextFormCheck = ${Script.RunningTime}
variable int NextItemListCheck = ${Script.RunningTime}
variable int64 LastTargetID = 0
variable int TotalKills = 0
variable filepath DebugFilePath = "${Script.CurrentDirectory}/Saves"
variable int HuntStartTime = ${Script.RunningTime}

;; create Shurikens
variable bool doCreateShurikens = FALSE
variable string CreateShurikensItem
variable string CreatedShurikens


;; UI - Main Tab
variable int ChangeFormPct = 60
variable int FeignDeathPct = 20
variable int FeignDeathEncounters = 3
variable int RacialAbilityPct = 30
variable int Crit_HealPct = 40
variable int BreathOfLifePct = 50
variable int KissOfHeavenPct = 60
variable int LaoJinFlashPct = 70
variable int Crit_DPS_RaJinFlarePct = 80
variable int StartAttack = 100
variable string ExecutedAbility = None
variable string TargetsTarget = "No Target"
variable bool doBuffArea = FALSE


;; UI - Loot Tab
variable bool doLoot = FALSE
variable int LootNearRange = 8
variable int LootMaxRange = 40
variable int LootCheckForAggroRadius = 20
variable collection:int64 BlackListTarget


;; UI - Hunt Tab
variable bool doHunt = FALSE
variable bool doCheckLineOfSight = TRUE
variable bool NoLineOfSight = FALSE
variable bool doCheckForAdds = FALSE
variable bool doCheckForObstacles = TRUE
variable int PullDistance = 22
variable int MaximumDistance = 40
variable int MinimumLevel = ${Me.Level}
variable int MaximumLevel = ${Me.Level}
variable int DifficultyLevel = 2
variable bool NeedMoreEnergy = FALSE
variable bool doNPC = FALSE
variable bool doAggroNPC = TRUE
variable bool doLootMyTombstone = FALSE
variable bool doCamp = FALSE



;; Navigator variables
variable int TotalWayPoints = 0
variable int CurrentWayPoint = 0
variable bool doRandomWayPoints = FALSE
variable bool CountUp = FALSE
variable bool doRestartToWP1 = FALSE
variable string CurrentChunk
variable bool BUMP = FALSE


;; XML variables used to store and save data
variable settingsetref Settings
variable settingsetref MyPath


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
#include ./VG-DSC/Includes/ItemListTools.iss
#include ./VG-DSC/Includes/FindTarget.iss
#include ./VG-DSC/Includes/Events.iss
#include ./VG-DSC/Includes/Obj_Navigator.iss
#include ./VG-DSC/Includes/Obj_YahooIM.iss


;; initialize our objects
variable(global) Obj_Navigator Navigate
variable(global) Obj_YahooIM YahooIM

;===================================================
;===            MAIN SCRIPT                     ====
;===================================================
function main()
{

	;; keep looping this until we end the script
	while ${isRunning}
	{
		;;;;;;;;;;
		;; keep resetting this until we start hunting
		if !${doHunt}
		{
			HuntStartTime:Set[${Script.RunningTime}]
		}
		
		;;;;;;;;;;
		;; Make sure autoAttack is turned on/off, this will catch those abilities you manually
		;; tried executing
		if ${Me(exists)}
		{
			call AutoAttack
			while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady} || ${VG.InGlobalRecovery}
			{
				if ${Me.IsCasting}
				{
					ExecutedAbility:Set[${Me.Casting}]
				}
				call AutoAttack
			}
		}

		if !${isPaused}
		{
			if ${Me.HealthPct}<80
			{
				if !${Me.DTarget.Name.Equal[${Me.FName}]}
				{
					Pawn[me]:Target
				}
			}
			else
			{
				if !${Me.DTarget.Name.Equal[${Tank}]}
				{
					Pawn[${Tank}]:Target
				}
			}
		}
		

		;;;;;;;;;;
		;; Slow this script down.  By having this wait here
		;; will improve FPS (when using the pawn command) and
		;; allow AutoAttack to register.
		wait 2

		;;;;;;;;;;
		;; Default action will be "Idle"
		Action:Set[Idle]

		;;;;;;;;;;
		;; Calling this will update the variable "Action" based upon any
		;; triggered events
		FindAction

		;;;;;;;;;;
		;; The variable "Action" is set by the FindAction routine which is
		;; the name of the routine we want to call.  Doing it this way will
		;; cut back lots of coding as well as easier tracking of what we are doing
		call PerformAction "${Action}"
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

	;;;;;;;;;;
	;; Save our XML Settings
	SaveXMLSettings

	;;;;;;;;;;
	;; clear the VG-DSC settings from memory
	LavishSettings[VG-DSC]:Clear
	
	echo "[${Time}][VG-DSC]: Stopped VG-DSC Script"
}

;===================================================
;===     Display to console what we are doing   ====
;===================================================
atom(script) EchoIt(string Text)
{
	redirect -append "${DebugFilePath}/Debug.txt" echo "[${Time}] ${Text}"
	echo "[${Time}][VG-DSC]: ${Text}"
}

;===================================================
;===      This will execute the "Action"        ====
;===================================================
function PerformAction(string Action)
{
	;;;;;;;;;;
	;; Update the display that shows the Action of what we are doing
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
		LastTargetID:Set[${Me.Target.ID}]
		if ${temp.Equal[NULL]}
		{
			TargetsTarget:Set[No Target]
		}
		else
		{
			TargetsTarget:Set[${Me.ToT.Name}]
		}
	}

	call CreateShurikens

	;;;;;;;;;;
	;; The actual command
	call ${Action}
}

;===================================================
;===    Idle and anything during downtime       ====
;===================================================
function Idle()
{
	;;;;;;;;;;
	;; Update what we are doing
	ExecutedAbility:Set[None]

	if !${isPaused}
	{
		;;;;;;;;;;
		;; not in combat so get our Jin up!
		if !${Me.Target(exists)} && !${Me.InCombat} && ${Me.Encounter}==0 && ${Me.Stat[Adventuring,Jin]}<=2
		{
			if !${Me.Effect[${Meditate}](exists)}
			{
				Me.Ability[${Meditate}]:Use
				wait 5
				while ${Me.IsCasting}
				{
					waitframe
					if ${Me.InCombat} || ${Me.Encounter}>0 || ${Me.Target(exists)}
					{
						VGExecute /stopcast
						waitframe
						return
					}
				}
				wait 5 ${Me.Effect[${Meditate}](exists)}
				return
			}
		}

		;;;;;;;;;;
		;; check only once every other second
		if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextItemListCheck}]}/1000]}>=2
		{
			if !${Me.InCombat} && ${Me.Encounter}==0
			{
				if ${doAutoSell} && ${Me.Target.Type.Equal[Merchant]}
				{
					call SellItemList
				}
			}
			NextItemListCheck:Set[${Script.RunningTime}]
		}

		;;;;;;;;;;
		;; Loot Something
		if ${doLoot}
		{
			call LootSomething
		}

		;;;;;;;;;;
		;; if we are not looting then clear the target if it is dead
		if !${doLoot} && !${isPaused}
		{
			if ${Me.Target.IsDead}
			{
				VGExecute /cleartargets
				wait 3
			}
		}
		
		;;;;;;;;;;
		;; if target doesn't exist or its dead then we will do one of these
		if !${Me.Target(exists)} || ${Me.Target.IsDead}
		{
			;; Get next target if we have an encounter
			if ${Me.Encounter}>0
			{
				Pawn[ID,${Me.Encounter[1].ID}]:Target
				wait 5
			}
		}
		
		;;;;;;;;;;
		;; BUFF AREA
		if ${doBuffArea}
		{
			echo gonna buff area
			if !${Me.Target(exists)} && !${Me.InCombat} && ${Me.Encounter}==0 
			{
				for (i:Set[1]; ${i} < ${VG.PawnCount}; i:Inc)
				{
					if ${Pawn[${i}].Distance}>20 
					{
						break
					}
					if ${Pawn[${i}].Type.Equal[PC]} && ${Pawn[${i}].HaveLineOfSightTo}
					{
						Pawn[${i}]:Target
						wait 3
						call UseAbility "${ResilientGrasshopper}"
						waitframe
					}
				}
				doBuffArea:Set[FALSE]
			}
		}

		;;;;;;;;;;
		;; HUNT
		if ${doHunt}
		{
			;; we are dead so stop hunting
			if ${Me.HealthPct} <= 0 || ${GV[bool,DeathReleasePopup]}
			{
				doHunt:Set[False]
				return
			}

			;; go find an AggroNPC that is within 80 meters
			if !${Me.Target(exists)} && ${Me.Encounter}<1 && !${Me.InCombat} && ${Me.HealthPct}>=80
			{
				;; go find a target as long as we are not assisting someone else
				if ${Tank.Find[${Me.FName}]}
				{
					call FindTarget ${MaximumDistance}
					if !${Me.Target(exists)} && ${Follow.Find[${Me.FName}]}
					{
						call MoveToWayPoint
					}
				}
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
	wait 30 ${Me.Chunk(exists)} && ${Me.FName(exists)}
	CurrentChunk:Set[${Me.Chunk}]

	;-------------------------------------------
	; Delete our debug file so that it doesn't get too big
	;-------------------------------------------
	if ${DebugFilePath.FileExists[/Debug.txt]}
	{
		rm "${DebugFilePath}/Debug.txt"
	}
	if ${DebugFilePath.FileExists[/Event-PawnStatusChange.txt]}
	{
		rm "${DebugFilePath}/Event-PawnStatusChange.txt"
	}
	if ${DebugFilePath.FileExists[/Event-Alert.txt]}
	{
		rm "${DebugFilePath}/Event-Alert.txt"
	}
	if ${DebugFilePath.FileExists[/Event-Chat.txt]}
	{
		rm "${DebugFilePath}/Event-Chat.txt"
	}
	if ${DebugFilePath.FileExists[/Event-Combat.txt]}
	{
		rm "${DebugFilePath}/Event-Combat.txt"
	}
	if ${DebugFilePath.FileExists[/Event-Inventory.txt]}
	{
		rm "${DebugFilePath}/Event-Inventory.txt"
	}

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
	;; upgraded abilities
	SetHighestAbility "ResilientGrasshopper" "Resilient Grasshopper"
	SetHighestAbility "ConcordantSplendor" "Concordant Splendor"
	SetHighestAbility "PetalSplitsEarth" "Petal Splits Earth"
	SetHighestAbility "LaoJinFlash" "Lao'Jin Flash"
	;; abilities I do not have
	SetHighestAbility "FocusedSonicBlast" "Focused Sonic Blast"
	SetHighestAbility "BlessedWhirl" "Blessed Whirl"
	SetHighestAbility "BreathOfLife" "Breath of Life"
	;; racial ability
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${Me.Ability[${i}].Name.Find[Racial Ability:]}
		{
			RacialAbility:Set[${Me.Ability[${i}].Name}]
			EchoIt "RacialAbility] = ${RacialAbility}"
		}
	}

	;;;;;;;;;;
	;; this will load all our settings
	LoadXMLSettings

	;;;;;;;;;;
	;; Reload the UI and draw our Tool window,putting a waitframe here
	;; allows enough time for loading the UI from disk
	waitframe
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	waitframe
	ui -reload -skin VGSkin "${Script.CurrentDirectory}/VG-DSC.xml"
	UIElement[VG-DSC]:SetWidth[250]
	UIElement[VG-DSC]:SetHeight[340]
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
	Follow:Set[${Me.FName}]
	if ${Me.DTarget.ID(exists)}
	{
		Tank:Set[${Me.DTarget.Name}]
		Follow:Set[${Me.DTarget.Name}]
	}
	EchoIt "-----------------------"
	EchoIt "Tank is set to ${Tank}"
	vgecho "Tank is set to ${Tank}"

	;;;;;;;;;;
	;; Enable Events - this event is automatically removed at shutdown
	Event[VG_onPawnStatusChange]:AttachAtom[PawnStatusChange]
	Event[VG_OnIncomingText]:AttachAtom[InventoryChatEvent]
	Event[VG_OnIncomingText]:AttachAtom[ChatEvent]
	Event[VG_OnIncomingCombatText]:AttachAtom[CombatEvent]
	Event[VG_onAlertText]:AttachAtom[AlertEvent]

	;;;;;;;;;;
	;; Turn mapping ON
	Navigate:StartMapping

	;;;;;;;;;;
	;; Make sure any of these are on your hotbar!
	if ${Me.Inventory[Tam Thi's Gift](exists)}
	{
		doCreateShurikens:Set[TRUE]
		CreateShurikensItem:Set["Tam Thi's Gift"]
		CreatedShurikens:Set["Emerald Leaf Shuriken"]
		EchoIt "Found ${CreateShurikensItem}"
	}
	if ${Me.Inventory[Varaelian Orb of the Moon and Stars](exists)}
	{
		doCreateShurikens:Set[TRUE]
		CreateShurikensItem:Set["Varaelian Orb of the Moon and Stars"]
		CreatedShurikens:Set["Sun Strike of Vol Anari"]
		EchoIt "Found ${CreateShurikensItem}"
	}
	if ${Me.Inventory[Queldoral, Bounty of the Gods](exists)}
	{
		doCreateShurikens:Set[TRUE]
		CreateShurikensItem:Set["Queldoral, Bounty of the Gods"]
		CreatedShurikens:Set["Sun Strike of Vol Anari"]
		EchoIt "Found ${CreateShurikensItem}"
	}

	wait 10
}

;===================================================
;===           Handles chunking                 ====
;===================================================
function WeChunked()
{
	;;;;;;;;;;
	;; Handle chunking and loading new chunk data
	if !${CurrentChunk.Equal[${Me.Chunk}]}
	{
		wait 80 ${Me.Chunk(exists)}

		if ${Me.Chunk(exists)}
		{
			;; we chunked
			EchoIt "We chunked from ${CurrentChunk} to ${Me.Chunk}"

			;; update current chunk
			CurrentChunk:Set[${Me.Chunk}]

			;; load our new settings
			EchoIt "Loading current chunk data"
			LoadXMLSettings
		}
	}
}

;===================================================
;===         Move to melee distance             ====
;===================================================
function MoveToMeleeDistance()
{
	if ${doHunt} || ${Me.IsGrouped}
	{
		;; target nearest target
		if ${Me.Encounter}>0
		{
			if ${Me.Encounter[1].Distance}<${Me.Target.Distance}
			{
				Pawn[id,${Me.Encounter[1].ID}]:Target
				wait 1
			}
		}

		if !${doRangedWeapon} || (${doRangedWeapon} && ${Me.Target.CombatState}>0 && ${Me.Target.Distance}<10)
		{
			if ${Me.Encounter}>0 || !${Me.InCombat} || ${Me.Target.CombatState}>0
			{
				if ${Me.InCombat}
				{
					VGExecute /walk
					waitframe
				}
				call FaceTarget
				call MoveCloser 2
				Me.Target:Face
				if ${Me.Target.Distance}<1 && ${Me.Target(exists)}
				{
					while ${Me.Target.Distance}<1 && ${Me.Target(exists)} && !${isPaused} && !${Me.ToPawn.IsStunned}
					{
						VG:ExecBinding[movebackward]
					}
					VG:ExecBinding[movebackward,release]
				}
				VGExecute /run
			}
		}
	}
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
	Pawn[me]:Target
	wait 5
	call UseAbility "${ResilientGrasshopper}"
	wait 10 ${Me.Effect[${ResilientGrasshopper}](exists)}
}

;===================================================
;===    Use item: Scepter of the Forgotten      ====
;===================================================
function Buff_AuraOfRulers()
{
	if ${Me.Level}>=45
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
	doRangedWeapon:Set[TRUE]

	;; force turning off!
	if ${doHunt}
	{
		VG:ExecBinding[turnright,release]
		VG:ExecBinding[turnleft,release]
		wait 2
	}

	;; move Closer to target
	if ${Me.Target(exists)} && !${Me.Target.IsDead} && ${Me.Target.Distance}>${PullDistance} && ${Me.Target.Distance}<=99 && ${doHunt}
	{
		call FaceTarget
		call MoveCloser ${PullDistance}
		if ${Me.Ability[${EnfeeblingShuriken}].Range}<=10 || ${Me.Ability[${RaJinFlare}].Range}<=10
		{
			call FaceTarget
			call MoveCloser 3
		}
	}

	
	;; slow this mob down
	if ${Me.Ability[${EnfeeblingShuriken}](exists)}
	{
		call EnfeeblingShuriken
		if ${Return}
		{
			vgecho [${Time}] Enfeebling Shuriken, distance = ${Me.Target.Distance}
		}
	}
	
	;; try to get 3 ranged attacks in
	if ${Me.Ability[${RaJinFlare}](exists)} && ${doRangedWeapon}
	{
		wait 90 ${Me.Ability[${RaJinFlare}](exists)}
		wait 2
		call RaJinFlare
		;if ${Return}
		;{
		;	wait 2
		;	call RaJinFlare
		;	if ${Return}
		;	{
		;		wait 2
		;		call RaJinFlare
		;		if ${Return}
		;		{
		;			wait 2
		;		}
		;	}
		;}
	}

	;; for whatever reason... lets move closer to the target
	call MoveToMeleeDistance

	if !${Me.InCombat}
	{
		call VoidHand
	}

	if ${Me.Encounter}>=${FeignDeathEncounters}
	{
		ExecutedAbility:Set[We pulled too many]
		EchoIt "We pulled too many"
		call FeignDeath
	}
}

;===================================================
;===    This is how we will feign death         ====
;===================================================
function FeignDeath()
{
	if !${Me.Effect[${FeignDeath}](exists)}
	{
		;; get our HOT up
		call KissOfHeaven

		wait 10 ${Me.Ability[${FeignDeath}].IsReady}
		waitframe

		;; pretend we are dead
		if ${Me.Ability[${FeignDeath}].IsReady}
		{
			FeignDeathFailed:Set[FALSE]
			call UseAbility "${FeignDeath}"
			wait 10 ${Me.Effect[${FeignDeath}](exists)}
		}
	}

	if ${FeignDeathFailed}
	{
		EchoIt "Feign Death Failed!"
		vgecho "Feign Death Failed!
		waitframe
		VGExecute /stand
		waitframe
		VGExecute /stand
		return
	}
	
	if ${Me.Effect[${FeignDeath}](exists)}
	{

		wait 10 !${Me.InCombat}
		VGExecute /cleartargets
		waitframe
		
		variable int FeignDeathCheck = ${Script.RunningTime}
		FeignDeathCheck:Set[${Script.RunningTime}]
		while ${Me.Effect[${FeignDeath}](exists)}
		{
			wait 10
			EchoIt "Feign Death - waiting: ${Pawn[AggroNPC].Name} is ${Pawn[AggroNPC].Distance} meters away"
			vgecho "Feign Death - waiting ( ${Math.Calc[(${Script.RunningTime}-${FeignDeathCheck})/1000].Int} )"
			if ${Me.Target(exists)} || ${Me.Encounter}>0 || (${Math.Calc[(${Script.RunningTime}-${FeignDeathCheck})/1000]}>=10 && ${Me.HealthPct}>50 || ${Pawn[AggroNPC].Distance}>10 || ${Me.ToPawn.IsStunned}
			{
				EchoIt "Feign Death - breaking wait - Nearest AggronNPC is ${Pawn[AggroNPC].Distance} meters away - TargetExists=${Me.Target(exists)}, Encounters=${Me.Encounter}, Seconds=${Math.Calc[${Math.Calc[${Script.RunningTime}-${FeignDeathCheck}]}/1000].Int}"
				vgecho "Feign Death - breaking wait"
				break
			}
		}
		waitframe
		VGExecute /stand
		waitframe
		VGExecute /stand

		;; start healing self if we need it
		if ${Me.HealthPct}<80
		{
			call LaoJinFlash
		}
		
		if ${Me.HealthPct}<80
		{
			call BreathOfLife
		}
	}
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
		if ${Me.ToPawn.IsStunned} || ${Me.Effect[${FeignDeath}](exists)} || !${Me.Target(exists)} || ${isPaused}
		{
			break
		}
	}
}

;===================================================
;===   CRIT:  KISS OF TORMENT                   ====
;===================================================
function Crit_KissOfTorment()
{
	while ${Me.Ability[${KissOfTorment}].TriggeredCountdown} && !${GV[bool,DeathReleasePopup]} && !${IsPaused}
	{
		ExecutedAbility:Set[/reactioncounter 2... KissOfTorment]
		VGExecute "/reactioncounter 2"
		call GlobalCooldown
		waitframe
		if ${Me.ToPawn.IsStunned} || ${Me.Effect[${FeignDeath}](exists)} || !${Me.Target(exists)} || ${isPaused}
		{
			break
		}
	}
}

;===================================================
;===   CRIT:  SUN FIST SERIES                   ====
;===================================================
function Crit_SunFist()
{
	;;;;;;;;;;
	;; Use this when our Jin is low
	while ${Me.Ability[${SuperiorSunFist}].TriggeredCountdown} && ${Me.Ability[${SunFist}].TriggeredCountdown} && !${GV[bool,DeathReleasePopup]} && !${IsPaused}
	{
		ExecutedAbility:Set[/reactioncounter 5... SunFist Series]
		VGExecute "/reactioncounter 5"
		call GlobalCooldown
		waitframe
		if ${Me.ToPawn.IsStunned} || ${Me.Effect[${FeignDeath}](exists)} || !${Me.Target(exists)} || ${isPaused}
		{
			break
		}
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
		wait 10 ${Me.Effect[${KissOfHeaven}](exists)}
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
	if !${Me.Effect[Endowment of Enmity](exists)} && ${Me.Ability[${CycloneKick}].IsReady} && ${Me.Ability[${RaJinFlare}].IsReady} && ${doRangedWeapon}
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
				call Crit_DPS
				if ${Return}
				{
					EndowmentStep:Set[1]
					return
				}
				EndowmentStep:Set[2]
			}
		}

		if ${EndowmentStep} == 2
		{
			call CycloneKick
			if ${Return}
			{
				call Crit_DPS
				if ${Return}
				{
					EndowmentStep:Set[1]
					return
				}
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
					doTankEndowementOfLife:Set[FALSE]
					Pawn[${Tank}]:Target
					wait 3
				}
			}
			call VoidHand
			if ${Return}
			{
				call Crit_DPS
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
		;ExecutedAbility:Set[/reactionchain 2... Petal Series]
		VGExecute "/reactionchain 2"
		call GlobalCooldown
		waitframe
		if ${Me.ToPawn.IsStunned} || ${Me.Effect[${FeignDeath}](exists)} || !${Me.Target(exists)} || ${isPaused}
		{
			break
		}
	}
}

;===================================================
;===    CRIT:  DISCORD SERIES (DPS)             ====
;===================================================
function:bool Crit_DPS()
{
	if ${Me.Effect["Endowment of Life"](exists)} && ${Me.Ability["Endowment of Life"](exists)} && ${Me.Effect["Endowment of Life"].TimeRemaining}>=30
	{
		if ${Me.Ability[${FocusedSonicBlast}](exists)} || ${Me.Ability[${TouchOfDiscord}](exists)} || ${Me.Ability[${GraspOfDiscord}](exists)} || ${Me.Ability[${PalmOfDiscord}](exists)} || ${Me.Ability[${FistOfDiscord}](exists)}
		{
			while ${Me.Ability[${FocusedSonicBlast}].TriggeredCountdown} || ${Me.Ability[${TouchOfDiscord}].TriggeredCountdown} || ${Me.Ability[${GraspOfDiscord}].TriggeredCountdown} || ${Me.Ability[${PalmOfDiscord}].TriggeredCountdown} || ${Me.Ability[${FistOfDiscord}].TriggeredCountdown}
			{
				Action:Set[Crit_DPS]
				EchoIt "Action=${Action}"
				call UseAbility "${FocusedSonicBlast}"
				if ${Return} && ${Me.HealthPct}<80
				{
					return TRUE
				}
				call UseAbility "${TouchOfDiscord}"
				if ${Return} && ${Me.HealthPct}<80
				{
					return TRUE
				}
				call UseAbility "${GraspOfDiscord}"
				if ${Return} && ${Me.HealthPct}<80
				{
					return TRUE
				}
				call UseAbility "${PalmOfDiscord}"
				if ${Return} && ${Me.HealthPct}<80
				{
					return TRUE
				}
				call UseAbility "${FistOfDiscord}"
				if ${Return} && ${Me.HealthPct}<80
				{
					return TRUE
				}
				call GlobalCooldown
				waitframe
				if ${Me.ToPawn.IsStunned} || ${Me.Effect[${FeignDeath}](exists)} || !${Me.Target(exists)} || ${isPaused}
				{
					break
				}
			}
		}
	}
	return FALSE
}

;===================================================
;===   RANGED DAMAGE:  Enfeebling Shuriken      ====
;===================================================
function:bool EnfeeblingShuriken()
{
	if ${doRangedWeapon}
	{
		call UseAbility "${EnfeeblingShuriken}"
		if ${Return}
		{
			return TRUE
		}
	}
	return FALSE
}

;===================================================
;===   RANGED DAMAGE:  RA'JIN FLARE             ====
;===================================================
function:bool RaJinFlare()
{
	if ${doRangedWeapon}
	{
		call UseAbility "${RaJinFlare}"
		if ${Return}
		{
			return TRUE
		}
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
	if !${Me.Ability[${ABILITY}](exists)} || ${Me.Ability[${ABILITY}].LevelGranted}>${Me.Level} || ${Pawn[me].IsMounted} || ${Me.Effect[${FeignDeath}](exists)}
	{
		return FALSE
	}

	;; this will stop attacks if we are not supposed to attack
	if ${Me.Ability[${ABILITY}].School.Find[Attack]} || ${Me.Ability[${ABILITY}].School.Find[Counterattack]}
	{
		call FaceTarget
		call FixLineOfSight
		call MoveToMeleeDistance
		call OkayToAttack
		if !${Return}
		{
			return FALSE
		}
	}

	;; this will ensure the ability is ready to use
	VGExecute /stand
	call IsCasting

	if ${Me.Ability[${ABILITY}].IsReady}
	{
		if ${Me.Ability[${ABILITY}].JinCost}>0 || ${Me.Ability[${ABILITY}].EnduranceCost}>0 || ${Me.Ability[${ABILITY}].EnergyCost}>0
		{
			;EchoIt "${ABILITY}:  JinCost=${Me.Ability[${ABILITY}].JinCost}<=${Me.Stat[Adventuring,Jin]}, EnduranceCost=${Me.Ability[${ABILITY}].EnduranceCost}<=${Me.Endurance}, EnergyCost=${Me.Ability[${ABILITY}].EnergyCost}<=${Me.Energy}"
			;; check if we have enough Jin
			if ${Me.Ability[${ABILITY}].JinCost}>${Me.Stat[Adventuring,Jin]}
			{
				;EchoIt "1-${ABILITY}:  JinCost=${Me.Ability[${ABILITY}].JinCost}<=${Me.Stat[Adventuring,Jin]}, EnduranceCost=${Me.Ability[${ABILITY}].EnduranceCost}<=${Me.Endurance}, EnergyCost=${Me.Ability[${ABILITY}].EnergyCost}<=${Me.Energy}"
				return FALSE
			}
			;; check if we have enough endurance
			if ${Me.Ability[${ABILITY}].EnduranceCost}>${Me.Endurance}
			{
				;EchoIt "2-${ABILITY}:  JinCost=${Me.Ability[${ABILITY}].JinCost}<=${Me.Stat[Adventuring,Jin]}, EnduranceCost=${Me.Ability[${ABILITY}].EnduranceCost}<=${Me.Endurance}, EnergyCost=${Me.Ability[${ABILITY}].EnergyCost}<=${Me.Energy}"
				return FALSE
			}
			;; check if we have enough energy
			if ${Me.Ability[${ABILITY}].EnergyCost}>${Me.Energy}
			{
				;EchoIt "3-${ABILITY}:  JinCost=${Me.Ability[${ABILITY}].JinCost}<=${Me.Stat[Adventuring,Jin]}, EnduranceCost=${Me.Ability[${ABILITY}].EnduranceCost}<=${Me.Endurance}, EnergyCost=${Me.Ability[${ABILITY}].EnergyCost}<=${Me.Energy}"
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
		call FaceTarget
		waitframe
	}
	if (${VG.InGlobalRecovery} || ${Me.ToPawn.IsStunned} || !${Me.Ability[Torch].IsReady})
	{
		call FaceTarget
		while (${VG.InGlobalRecovery} || ${Me.ToPawn.IsStunned} || !${Me.Ability[Torch].IsReady})
		{
			wait 2
		}
	}
}

;===================================================
;===    AUTO ATTACK:  ON/OFF                    ====
;===================================================
function:bool AutoAttack()
{
	call OkayToAttack
	if ${Return} && ${Me.Target.Distance}<5 && ${Me.InCombat}
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
;===   OKAY TO ATTACK - No Waits or pauses      ====
;===================================================
function:bool OkayToAttack()
{
	;;;;;;;;;;
	;; Make sure we catch this... Health usually reports 0 when you 1st target it
	if ${Me.Target(exists)} && !${Me.Target.IsDead}
	{
		if ${Me.Target.CombatState}==0 && ${Me.TargetHealth}==0
		{
			;wait 10 ${Me.TargetHealth}>0
			return FALSE
		}
	}

	;;;;;;;;;;
	;; The following are things I found we do not want to attack through
	if ${Me.Target(exists)} && !${Me.Target.IsDead} && ${Me.TargetHealth}<=${StartAttack} && !${isPaused}
	{
		;; target must be an NPC or AggroNPC
		if ${Me.Target.Type.Find[NPC]} || ${Me.Target.Type.Equal[AggroNPC]}
		{
			;; make sure we are in combat, tank is in combat, or we are not in a group
			if  ${Tank.Find[${Me.FName}]} || !${Me.IsGrouped} || ${Me.InCombat} || ${Pawn[Name,${Tank}].CombatState}>0
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
				if ${doFaceTarget} && ${doHunt}
				{
					Me.Target:Face
				}
				return TRUE
			}
		}
	}
	return FALSE
}


;===================================================
;===        LOAD XML SETTINGS                   ====
;===================================================
atom(script) LoadXMLSettings(string aText)
{
	;; build and import Settings
	LavishSettings[VG-DSC]:Clear
	LavishSettings:AddSet[VG-DSC]
	LavishSettings[VG-DSC]:AddSet[Settings]
	LavishSettings[VG-DSC]:AddSet[MyPath]
	LavishSettings[VG-DSC]:Import[${Script.CurrentDirectory}/Saves/Settings.xml]

	Settings:Set[${LavishSettings[VG-DSC].FindSet[Settings].GUID}]
	MyPath:Set[${LavishSettings[VG-DSC].FindSet[MyPath].GUID}]

	;; import Main UI variables
	ChangeFormPct:Set[${Settings.FindSetting[ChangeFormPct,60]}]
	FeignDeathPct:Set[${Settings.FindSetting[FeignDeathPct,20]}]
	FeignDeathEncounters:Set[${Settings.FindSetting[FeignDeathEncounters,3]}]
	RacialAbilityPct:Set[${Settings.FindSetting[RacialAbilityPct,30]}]
	Crit_HealPct:Set[${Settings.FindSetting[Crit_HealPct,40]}]
	BreathOfLifePct:Set[${Settings.FindSetting[BreathOfLifePct,50]}]
	KissOfHeavenPct:Set[${Settings.FindSetting[KissOfHeavenPct,60]}]
	LaoJinFlashPct:Set[${Settings.FindSetting[LaoJinFlashPct,70]}]
	Crit_DPS_RaJinFlarePct:Set[${Settings.FindSetting[Crit_DPS_RaJinFlarePct,80]}]
	StartAttack:Set[${Settings.FindSetting[StartAttack,99]}]

	;; import Loot variables
	doLoot:Set[${Settings.FindSetting[doLoot,FALSE]}]
	LootNearRange:Set[${Settings.FindSetting[LootNearRange,8]}]
	LootMaxRange:Set[${Settings.FindSetting[LootMaxRange,40]}]
	LootCheckForAggroRadius:Set[${Settings.FindSetting[LootCheckForAggroRadius,20]}]

	;; import Item List variables
	doAutoSell:Set[${Settings.FindSetting[doAutoSell,FALSE]}]
	doDeleteSell:Set[${Settings.FindSetting[doDeleteSell,FALSE]}]
	doDeleteNoSell:Set[${Settings.FindSetting[doDeleteNoSell,FALSE]}]
	doAutoDecon:Set[${Settings.FindSetting[doAutoDecon,FALSE]}]

	;; import Hunt variables
	doCheckLineOfSight:Set[${Settings.FindSetting[doCheckLineOfSight,FALSE]}]
	doNPC:Set[${Settings.FindSetting[doNPC,FALSE]}]
	doAggroNPC:Set[${Settings.FindSetting[doAggroNPC,TRUE]}]
	doCheckForAdds:Set[${Settings.FindSetting[doCheckForAdds,FALSE]}]
	doCheckForObstacles:Set[${Settings.FindSetting[doCheckForObstacles,FALSE]}]
	PullDistance:Set[${Settings.FindSetting[PullDistance,20]}]
	MaximumDistance:Set[${Settings.FindSetting[MaximumDistance,40]}]
	MinimumLevel:Set[${Settings.FindSetting[MinimumLevel,${Me.Level}]}]
	MaximumLevel:Set[${Settings.FindSetting[MaximumLevel,${Me.Level}]}]
	doLootMyTombstone:Set[${Settings.FindSetting[doLootMyTombstone,TRUE]}]
	doCamp:Set[${Settings.FindSetting[doCamp,TRUE]}]
	
	;; import our Yahoo settings
	YahooHandle:Set[${Settings.FindSetting[YahooHandle,"Handle"]}]
	YahooPassword:Set[${Settings.FindSetting[YahooPassword,"Password"]}]
	YahooSendToHandle:Set[${Settings.FindSetting[YahooSendToHandle,"Send messages to"]}]
	doYahooTells:Set[${Settings.FindSetting[doYahooTells,TRUE]}]
	doYahooSays:Set[${Settings.FindSetting[doYahooSays,TRUE]}]
	doYahooEmotes:Set[${Settings.FindSetting[doYahooEmotes,TRUE]}]
	doYahooGM:Set[${Settings.FindSetting[doYahooGM,TRUE]}]

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
			{
				CurrentWayPoint:Set[1]
			}
			EchoIt "TotalWayPoints Found in ${Me.Chunk}: ${TotalWayPoints}, Closest WayPoint is ${CurrentWayPoint}"
		}
	}
}

;===================================================
;===          SAVE XML SETTINGS                 ====
;===================================================
atom(script) SaveXMLSettings(string aText)
{
	;; Create the Save directory incase it doesn't exist
	variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/VG-DSC/Saves"
	mkdir "${savePath}"

	;; cut down on the loading times
	if !${LavishSettings[VG-DSC].FindSet[Settings](exists)}
	{
		;; build and import Settings
		LavishSettings[VG-DSC]:Clear
		LavishSettings:AddSet[VG-DSC]
		LavishSettings[VG-DSC]:AddSet[Settings]
		LavishSettings[VG-DSC]:AddSet[MyPath]
		LavishSettings[VG-DSC]:Import[${Script.CurrentDirectory}/Saves/Settings.xml]
	}

	;; update our pointers
	Settings:Set[${LavishSettings[VG-DSC].FindSet[Settings]}]
	MyPath:Set[${LavishSettings[VG-DSC].FindSet[MyPath]}]

	;; update our settings
	Settings:AddSetting[ChangeFormPct,${ChangeFormPct}]
	Settings:AddSetting[FeignDeathPct,${FeignDeathPct}]
	Settings:AddSetting[FeignDeathEncounters,${FeignDeathEncounters}]
	Settings:AddSetting[RacialAbilityPct,${RacialAbilityPct}]
	Settings:AddSetting[Crit_HealPct,${Crit_HealPct}]
	Settings:AddSetting[BreathOfLifePct,${BreathOfLifePct}]
	Settings:AddSetting[KissOfHeavenPct,${KissOfHeavenPct}]
	Settings:AddSetting[LaoJinFlashPct,${LaoJinFlashPct}]
	Settings:AddSetting[Crit_DPS_RaJinFlarePct,${Crit_DPS_RaJinFlarePct}]
	Settings:AddSetting[StartAttack,${StartAttack}]

	;; update loot settings
	Settings:AddSetting[doLoot,${doLoot}]
	Settings:AddSetting[LootNearRange,${LootNearRange}]
	Settings:AddSetting[LootMaxRange,${LootMaxRange}]
	Settings:AddSetting[LootCheckForAggroRadius,${LootCheckForAggroRadius}]

	;; update our item list settings
	Settings:AddSetting[doAutoSell,${doAutoSell}]
	Settings:AddSetting[doDeleteSell,${doDeleteSell}]
	Settings:AddSetting[doDeleteNoSell,${doDeleteNoSell}]
	Settings:AddSetting[doAutoDecon,${doAutoDecon}]

	;; update our hunt variables
	Settings:AddSetting[doCheckLineOfSight,${doCheckLineOfSight}]
	Settings:AddSetting[doNPC,${doNPC}]
	Settings:AddSetting[doAggroNPC,${doAggroNPC}]
	Settings:AddSetting[doCheckForAdds,${doCheckForAdds}]
	Settings:AddSetting[doCheckForObstacles,${doCheckForObstacles}]
	Settings:AddSetting[PullDistance,${PullDistance}]
	Settings:AddSetting[MaximumDistance,${MaximumDistance}]
	Settings:AddSetting[MinimumLevel,${MinimumLevel}]
	Settings:AddSetting[MaximumLevel,${MaximumLevel}]
	Settings:AddSetting[doLootMyTombstone,${doLootMyTombstone}]
	Settings:AddSetting[doCamp,${doCamp}]
	
	;; update our Yahoo vairables
	Settings:AddSetting[YahooHandle,${YahooHandle}]
	Settings:AddSetting[YahooPassword,${YahooPassword}]
	Settings:AddSetting[YahooSendToHandle,${YahooSendToHandle}]
	Settings:AddSetting[doYahooTells,${doYahooTells}]
	Settings:AddSetting[doYahooSays,${doYahooSays}]
	Settings:AddSetting[doYahooEmotes,${doYahooEmotes}]
	Settings:AddSetting[doYahooGM,${doYahooGM}]

	;; save settings
	LavishSettings[VG-DSC]:Export[${Script.CurrentDirectory}/Saves/Settings.xml]
}


;===================================================
;===            HANDLE ALL LOOTING              ====
;===================================================
function LootSomething()
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
			call MoveCloser 2
			call FaceTarget


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
		variable int TotalPawns
		variable index:pawn CurrentPawns
		TotalPawns:Set[${VG.GetPawns[CurrentPawns]}]

		for (i:Set[1] ; ${i}<${TotalPawns} && ${CurrentPawns.Get[${i}].Distance}<=${LootMaxRange} && !${Me.InCombat} && ${Me.Encounter}==0 ; i:Inc)
		{
			if ${CurrentPawns.Get[${i}].Type.Equal[Corpse]} && ${CurrentPawns.Get[${i}].ContainsLoot}
			{
				;; only target corpses if we are not hunting and within 5 meters of us
				if !${doHunt} &&  ${CurrentPawns.Get[${i}].Distance}>5
				{
					continue
				}

				;; we do not want to retarget same corpse twice
				if ${BlackListTarget.Element[${CurrentPawns.Get[${i}].ID}](exists)}
				{
					continue
				}

				;; skip looting if there are any AggroNPC's near corpse and we are hunting
				if ${doHunt} && ${Pawn[AggroNPC,from,${CurrentPawns.Get[${i}].X},${CurrentPawns.Get[${i}].Y},${CurrentPawns.Get[${i}].Z},radius,${LootCheckForAggroRadius}](exists)}
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
				if ${doHunt}
				{
					call FaceTarget
					call MoveCloser 2
				}

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
		;; wait up to 1 second for loot to register
		wait 10 ${Me.Target.ContainsLoot}

		;; does the corpse have any loot?
		if ${Me.Target.ContainsLoot}
		{
			;; start looting only if within range
			if ${Me.Target.Distance}<5
			{
				;; start the loot process
				Loot:BeginLooting
				wait 20 ${Me.IsLooting} && ${Loot.NumItems}

				;; start looting 1 item at a time, gaurantee to get all items
				if ${Me.IsLooting}
				{
					;; make sure we blacklist so we don't try looting it again
					BlackListTarget:Set[${Me.Target.ID},${Me.Target.ID}]

					if ${Loot.NumItems}
					{
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

		;; delete these items
		Me.Inventory[ExactName,"Quality Bag"]:Delete[all]
		Me.Inventory[ExactName,"Jagged Shard of Battle"]:Delete[all]
		Me.Inventory[ExactName,"Jagged Shard of Brilliance"]:Delete[all]
		Me.Inventory[ExactName,"Jagged Shard of Wisdom"]:Delete[all]
		Me.Inventory[ExactName,"Cracked Shard of Battle"]:Delete[all]
		Me.Inventory[ExactName,"Cracked Shard of Brilliance"]:Delete[all]
		Me.Inventory[ExactName,"Cracked Shard of Wisdom"]:Delete[all]
		Me.Inventory[ExactName,"Glowing Shard of Battle"]:Delete[all]
		Me.Inventory[ExactName,"Glowing Shard of Brilliance"]:Delete[all]
		Me.Inventory[ExactName,"Glowing Shard of Wisdom"]:Delete[all]
		Me.Inventory[ExactName,"Mangled Rag of War"]:Delete[all]
		Me.Inventory[ExactName,"Bloodied Rag of War"]:Delete[all]
		Me.Inventory[ExactName,"Frayed Rag of War"]:Delete[all]
		
		;; now decon your junk, repair, and delete junk
		if !${Me.InCombat} && ${Me.Encounter}==0
		{
			if ${doAutoDecon}
			{
				call AutoDecon
			}
			
			call RepairItemList
			
			if !${Me.InCombat} && ${Me.Encounter}==0
			{
				if ${doAutoSell} 
				{
					if ${Pawn[Merchant](exists)} && ${Pawn[Merchant].Distance}<=5
					{
						EchoIt "*Targeting Merchant"
						Pawn[Merchant]:Target
						wait 5
					}
					call SellItemList
				}
				if ${doDeleteSell} || ${doDeleteNoSell}
				{
					call DeleteItemList
				}
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
	if !${Me.Target(exists)} || !${doHunt} || ${Me.ToPawn.IsStunned} || ${Me.Effect[${FeignDeath}](exists)} 
	{
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
	while ${Me.Target(exists)} && ${Me.Target.Distance}>=${Distance} && ${LavishScript.RunningTime}<${bailOut} && !${isPaused}
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
					wait 7
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
	MyPath.FindSet[${Me.Chunk}]:AddSetting[TotalWayPoints, ${TotalWayPoints}]
	MyPath.FindSet[${Me.Chunk}]:AddSetting[WP-${TotalWayPoints}, "${Me.Location}"]

	;; save our settings
	SaveXMLSettings

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
	SaveXMLSettings

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
	if !${doHunt} || ${TotalWayPoints}==0
	{
		return
	}

	;;;;;;;;;;
	;; reset waypoint if outside of range
	if ${CurrentWayPoint}<1 || ${CurrentWayPoint}>${TotalWayPoints}
	{
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
	Navigate:MoveToPoint[WP-${CurrentWayPoint}]

	;; allow time to register we are moving
	wait 40 ${Navigate.isMoving}

	;;;;;;;;;;
	;; loop this while we are moving to waypoint
	while ${Navigate.isMoving}
	{
		Action:Set[Moving to WP-${CurrentWayPoint}]

		;; keep looking for a target
		call FindTarget ${MaximumDistance}

		;; stop moving if we paused or picked up an encounter
		if ${isPaused} || ${Me.Encounter}>0 || ${Me.InCombat} || ${Me.Target(exists)} || !${doHunt} || ${Me.ToPawn.IsStunned} || ${Me.Effect[${FeignDeath}](exists)}
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
		Me.Target:Face
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
	{
		LoSRetries:Set[0]
	}
}

;===================================================
;===         FACE TARGET SUBROUTINE             ====
;===================================================
function FaceTarget()
{
	;; face only if target exists
	if ${doHunt}
	{
		if ${Me.Target(exists)}
		{
			CalculateAngles
			if ${AngleDiffAbs} > 45
			{
				variable int i = ${Math.Calc[20-${Math.Rand[40]}]}
				EchoIt "Facing within ${i} degrees of ${Me.Target.Name}"
				VG:ExecBinding[turnright,release]
				VG:ExecBinding[turnleft,release]
				if ${AngleDiff}>0
				{
					VG:ExecBinding[turnright]
					while ${AngleDiff} > ${i} && ${Me.Target(exists)} && !${isPaused} && ${isRunning} && !${Me.Effect[${FeignDeath}](exists)} && !${Me.ToPawn.IsStunned}
					{
						CalculateAngles
					}
					VG:ExecBinding[turnright,release]
					VG:ExecBinding[turnleft,release]
					return
				}
				if ${AngleDiff}<0
				{
					VG:ExecBinding[turnleft]
					while ${AngleDiff} < ${i} && ${Me.Target(exists)} && !${isPaused} && ${isRunning} && !${Me.Effect[${FeignDeath}](exists)} && !${Me.ToPawn.IsStunned}
					{
						CalculateAngles
					}
					VG:ExecBinding[turnright,release]
					VG:ExecBinding[turnleft,release]
					return
				}
				VG:ExecBinding[turnright,release]
				VG:ExecBinding[turnleft,release]
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
		{
			result:Set[${Math.Calc[${result} - 360]}]
		}
		while ${result} < -180
		{
			result:Set[${Math.Calc[${result} + 360]}]
		}
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

}

;===================================================
;===       CREATE MORE SHURIKENS                ====
;===================================================
function:bool CreateShurikens()
{
	if ${doCreateShurikens}
	{
		if ${Me.Inventory[${CreateShurikensItem}].IsReady}
		{
			if ${CreateShurikensItem.Equal["Tam Thi's Gift"]}
			{
				;; if we are out of shurikens then make some more
				if ${Me.Inventory[Emerald Leaf Shuriken].Quantity}<=0
				{
					Me.Inventory[Tam Thi's Gift]:Use
					vgecho "<Green=>Creating:  <Yellow=>${CreatedShurikens}"
					wait 10
				}
				
				;; this will always equip the stack with the highest amount of shurikens
				if ${Me.Inventory[Emerald Leaf Shuriken](exists)}
				{
					Me.Inventory[Emerald Leaf Shuriken]:Equip
					waitframe
				}
				return TRUE
			}

			;; total Shurikens
			variable int Shurikens = 0

			;; total items in inventory
			variable int TotalItems = 0

			;; define our index
			variable index:item CurrentItems

			;; populate our index and update total items in inventory
			TotalItems:Set[${Me.GetInventory[CurrentItems]}]

			;; counter
			variable int i = 0

			;; loop through all items
			for (i:Set[1] ; ${i}<=${TotalItems} ; i:Inc)
			{
				if ${CurrentItems.Get[${i}].Name.Find[${CreatedShurikens}]}
				{
					Shurikens:Inc[${CurrentItems.Get[${i}].Quantity}]
				}
			}

			if ${Shurikens}<2000
			{
				Me.Inventory[${CreateShurikensItem}]:Use
				vgecho "<Green=>Creating:  <Yellow=>${CreatedShurikens}"
				wait 20
			}
			if ${Shurikens}<2000
			{
				return TRUE
			}
		}
		return FALSE
	}
	return TRUE
}

;===================================================
;===        FOLLOW PLAYER SUB-ROUTINE           ====
;===================================================
function FollowPlayer()
{
	;; start moving until target is within range
	variable bool AreWeMoving = FALSE
	while !${isPaused} && ${Pawn[name,${Follow}](exists)} && ${Pawn[name,${Follow}].Distance}>=2 && ${Pawn[name,${Follow}].Distance}<45
	{
		Pawn[name,${Follow}]:Face
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

function CampOut()
{
	;; this wait is in case we just released the corpse
	wait 50

	if ${doJustDied}
	{
	
		;; check the altar for any tombstones
		Pawn[Altar]:DoubleClick
		wait 7
		if ${Me.Target.Name.Equal[Altar]}
		{
			Dialog[General,"I'd like to summon my earthly remains."]:Select 
			wait 7
			Altar[Corpse,1]:Summon
			wait 7
			Altar[Corpse,1]:Cancel
		}
		
		;; allow time for the tombstone to appear
		wait 10

		;; target and loot our tombstone
		if ${Pawn[Tombstone](exists)}
		{
			for (i:Set[0]; ${i:Inc} <= ${VG.PawnCount}; i:Inc)
			{
				if ${Pawn[${i}].Name.Find[Tombstone]} && ${Pawn[${i}].Name.Find[${Me}]}
				{
					VGExecute /targetm
					wait 5
					if ${Pawn[${i}].Distance}>5 && ${Pawn[${i}].Distance}<21
					{
						VGExecute /cor
						waitframe
					}
					VGExecute /Lootall
					waitframe
					VGExecute "/cleartargets"
				}
			}
		}
		
		while !${Me.InCombat} && ${Me.Encounter}==0 && !${isPaused}
		{
			call CreateShurikens
			if ${Return}
			{
				break
			}
			wait 10
		}
	}

	EchoIt "CAMPING"
	vgecho "Camping"
	waitframe
	VGExecute /camp
	wait 152 ${Me.InCombat}
	if !${Me.InCombat}
	{
		endscript VG-DSC
		waitframe
	}
}

function WeAreStunned()
{
	EchoIt "We are Stunned!"
	while ${Me.ToPawn.IsStunned} && !${isPaused} && !${Me.Effect[${FeignDeath}](exists)}
	{
		wait 2
	}
}

function WeAreMounted()
{
	EchoIt "We are on a Mount!"
	while ${Me.ToPawn.IsMounted} && !${isPaused} && !${Me.Effect[${FeignDeath}](exists)}
	{
		wait 2
	}
}

function Meditating()
{
	EchoIt "We are Meditating!"
	waitframe
	while ${Me.Effect[${Meditate}](exists)} && !${isPaused} && !${Me.Effect[${FeignDeath}](exists)}
	{
		isSitting:Set[TRUE]
		;; Keep looping this until we have 20 Jin or exit out of Meditate
		if ${Me.InCombat} || ${Me.Stat[Adventuring,Jin]}>=19 || ${Me.Encounter}>0 || ${isPaused}
		{
			EchoIt "Breaking out of Meditation"
			break
		}

		wait 2
	}
	VGExecute /stand
	waitframe
	VGExecute /stand
}



