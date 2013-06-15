;-----------------------------------------------------------------------------------------------
; Tools.iss 
;
; Description - a small tool
; -----------
; * Buff Bot 
; * Assist and follow tank
; * Cycles through list of selected abilities
; * Cycles through list of items to use
; * Swaps weapons instantly to use item abilities (-clickies-)
; * Preconfigure Counters, Strip Enchantments, and Push Stance
; * Auto Attack turns on and off
;
; Revision History
; ----------------
; 20130525 (Zandros)
;  * Fixed tells because using a ".Key" in a find does not work, but saving to a variable does
;
; 20130523 (Zandros)
;  * Added a basic tank tab for tanks (Rescues, reduce hate, and increase hate). 
;    Also, added a toggle for all Hate modifying abilities as well as basic Loot.
;
; 20130512 (Zandros)
;  * Added a basic healing tab for healers.
;
; 20130506 (Zandros)
;  * Fixed the GlobalCooldown routine so that the script would function correctly
;
; 20120112 (Zandros)
; * Added a tab called 'Counters' which now gives you full control which ability
;   you want to counter.  As you identify the target's ability, it will automatically
;   populate the text box so that all you need to do is click the 'Add' button or
;   if you know in advance then you can manually type it in.
;
; 20120102 (Zandros)
; * Added (Physical, Arcane, Mental, Fire, Cold/Ice, Spiritual), Foraging, and a
;   new class tab... Necromancer.  Nothing fancy and still have a ways to go.
;
; 20111229 (Zandros)
; * Items will now cycle through each one, just make sure the item is on one of
;   you hotbars.
;
; 20111224 (Zandros)
; * Added Tell logging and pinging
;
; 20111217 (Zandros)
; * Added Buff Area - check if have buff and if not then buff; added Force Buff Area - 
;   will buff without checking if the buff exists.
;
; 20111130 (Zandros)
; * Added follow tank routine
;
; 20111128 (Zandros)
; * Added Buff Only List that supports both PC Names and Guild Names
;
; 20111107 (Zandros)
; * Added Auto Accept Rez and auto target to repair gear
;
; 20111104 (Zandros)
;  * Added BuffBot to script.  This will allow you to monitor tells, group messages,
;    and raid messages for a trigger phrase to begin buffing.  It can also buff all
;    those that just rifted.
;
; 20111028 (Zandros)
;  * Added Buffs, Forms, and Ranged Attack. Priority are Counters, Strip Enchantments,
;    and Push Stance.
;
; 20111027 (Zandros)
;  * Added my 1st class tab.  Currently, I added the Bard Class tab.  Nothing much
;    but it was a lot of coding.  Basically, if you are a Bard then you can set what
;    song you want and what weapons you want to equip the moment you are in combat.
;    Once you are out of combat and someone is wounded then you you can establish
;    what Rest song and Instrument you want.  Finally, if everyone is fully healed,
;    then it will default to the song you identify for travel and equip the appropriate
;    instrument.  
;
; 20111008 (Zandros)
;  * Major work was done.  Recreated the UI to support adding your own abilities
;    and items to use, and all settings are saved under your player's name.  There
;    are no delays when swapping weapons and using items, and will only start
;    attacking if both yourself and the target is in state of combat.
;
; 20111001 (Zandros)
;  * Added pushing stances and Auto Attack
;
; 20111001 (Zandros)
;  * A simple script that handles counters and stripping enchantments
;
;
;===================================================
;===            VARIABLES                       ====
;===================================================

;; Script variables
variable int i
variable int j
variable bool isRunning = TRUE
variable bool isPaused = FALSE
variable int NextDelayCheck = ${Script.RunningTime}
variable int RepairTimer = ${Script.RunningTime}
variable int64 LastTargetID = 0
variable int64 LastLootID = 0
variable collection:string Hate_Abilities
variable collection:int64 HarvestBlackList
variable collection:int64 LootBlackList


;; UI/Script toggle variables
variable bool doUseAbilities = FALSE
variable bool doUseItems = FALSE
variable bool doCounter1 = FALSE
variable bool doCounter2 = FALSE
variable bool doCounter1Only = FALSE
variable bool doCounter2Only = FALSE
variable bool doPushStance = FALSE
variable bool doStripEnchantments = FALSE
variable bool doForage = FALSE
variable bool doAutoAttack = FALSE
variable bool doRangedAttack = FALSE
variable bool doFace = FALSE
variable bool doAutoRepairs = FALSE
variable bool doAutoRez = FALSE
variable bool doAcceptRez = FALSE
variable bool doHate = FALSE
variable bool doLoot = FALSE
variable bool doGroupsay = FALSE
variable bool doRaidsay = FALSE
variable bool doTells = FALSE
variable bool doRift = FALSE
variable bool doFollow = FALSE
variable bool doMonotorTells = FALSE
variable bool doHarvest = TRUE
variable int HarvestRange = 10
variable string TriggerBuffing = ""
variable string Tank = Unknown
variable string CombatForm = None
variable string NonCombatForm = None
variable int StartAttack = 99

;; Immunity variables
variable bool doPhysical = TRUE
variable bool doArcane = TRUE
variable bool doFire = TRUE
variable bool doIce = TRUE
variable bool doSpiritual = TRUE
variable bool doMental = TRUE

;; Bard stuff
variable string CombatSong = None
variable string PrimaryWeapon = None
variable string SecondaryWeapon = None
variable string RestSong = None
variable string RestInstrument = None
variable string TravelSong = None
variable string TravelInstrument = None

;; Healing Stuff
variable collection:int GroupMemberList
variable collection:int HoTMemberList
variable bool doFindGroupMembers = TRUE
variable bool doGroupOnly = FALSE
variable bool doSmallHeal = TRUE
variable bool doBigHeal = TRUE
variable bool doGroupHeal = TRUE
variable bool doInstantHeal = TRUE
variable bool doHoT = TRUE
variable int BigHealPct = 50
variable int SmallHealPct = 65
variable int GroupHealPct = 70
variable int InstantHealPct = 70
variable int HoTPct = 80
variable string SmallHeal = None
variable string BigHeal = None
variable string GroupHeal = None
variable string InstantHeal = None
variable string HoT = None

;; Tank Stuff
variable bool doRescue1 = FALSE
variable bool doRescue2 = FALSE
variable bool doRescue3 = FALSE
variable bool doReduceHate = FALSE
variable bool doIncreaseHate = FALSE
variable bool doCheckEncounters = TRUE
variable string Rescue1 = None
variable string Rescue2 = None
variable string Rescue3 = None
variable string ReduceHate = None
variable string IncreaseHate = None
variable string TargetOnWho = None

;; Ability name variables
variable string Counter1 = None
variable string Counter2 = None
variable string PushStance1 = None
variable string StripEnchantment1 = None
variable string Forage = "Forage"

;; XML variables used to store and save data
variable settingsetref General
variable settingsetref Abilities
variable settingsetref Items
variable settingsetref Buffs
variable settingsetref TriggerBuffs
variable settingsetref BuffOnly
variable settingsetref Counters1
variable settingsetref Counters2

;; Equipment variables
variable string LastPrimary = None
variable string LastSecondary = None
variable string LastItemUsed = None

;; BuffBot variables
variable string PCName = None
variable string PCNameFull = None
variable(global) collection:string Tools_BuffRequestList
variable string BuffOnlyName = ""

;; Follow variables
variable int FollowDistance1 = 3
variable int FollowDistance2 = 5

;; Class Specific Routines
#include ./Tools/Class/Bard.iss
#include ./Tools/Class/Sorcerer.iss
#include ./Tools/Class/Ranger.iss
#include ./Tools/Class/Necromancer.iss
#include ./Tools/Class/Cleric.iss
#include ./Tools/Class/Warrior.iss

;; Defines - good within this script
#define ALARM "${Script.CurrentDirectory}/ping.wav"

;; Logging path
variable string LogThis = "${Script.CurrentDirectory}/ChatLog.txt"

;===================================================
;===            MAIN SCRIPT                     ====
;===================================================
function main()
{
	;-------------------------------------------
	; INITIALIZE - setup script
	;-------------------------------------------
	call Initialize
	EchoIt "Ready"
	
	;-------------------------------------------
	; CLASS SPECIFIC Routines
	;-------------------------------------------
	;call Bard
	;call Sorcerer
	;call Ranger
	;call Necromancer
	;call Cleric
	;call Warrior
	
	;-------------------------------------------
	; loop this until we exit the script
	;-------------------------------------------
	do
	{
		;; check and accept Rez
		call RezAccept

		;; execute any queued commands
		if ${QueuedCommands}
		{
			ExecuteQueued
			FlushQueued
		}
		
		if !${isPaused}
		{
			;; Always check these
			call Loot
			call FollowTank
			call ManageHeals
			call HarvestIt
			
			;; check these once every second
			if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextDelayCheck}]}/1000]}>1
			{
				;; Always check these
				call AssistTank
				call ChangeForm
				call BuffRequests
				call RepairEquipment
				call Forage
				call Tombstone
				NextDelayCheck:Set[${Script.RunningTime}]
			}

			;; Class Specific Routines - do these first before doing combat stuff
			call Bard
			call Sorcerer
			call Ranger
			call Necromancer
			call Cleric
			call Warrior
			
			;; we only want targets that are not a Resource and not dead
			call OkayToAttack
			if ${Return}
			{
				;; execute each of these
				call CounterIt
				call StripIt
				call PushStance
				call UseAbilities
				call RangedAttack
				call AutoAttack
				call UseItems
			}
			else
			{
				;; our target is a Resource or is dead
				call MeleeAttackOff
				call CheckBuffs
			}
		}
		else 
		{
			;; we are paused
			call MeleeAttackOff
			call ChangeForm
			HarvestBlackList:Clear
			LootBlackList:Clear
		}
	}
	while ${isRunning}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;   S U B R O U T I N E S   ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;===================================================
;===     INITIALIZE - sets everything up        ====
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
		endscript Tools
	}
	wait 30 ${Me.Chunk(exists)}
	EchoIt "Started Tools Script"
	
	;-------------------------------------------
	; Identify your Class Abilities
	; (only use the base name of the ability)
	;-------------------------------------------
	switch "${Me.Class}"
	{
		case Blood Mage
			Counter1:Set[Dissolve]
			Counter2:Set[Metamorphism]
			PushStance1:Set[None]
			StripEnchantment1:Set[Strip Enchantment]
			break
		
		case Psionicist
			Counter1:Set[Nullifying Field]
			Counter2:Set[Psychic Mutation]
			PushStance1:Set[None]
			StripEnchantment1:Set[None]
			break

		case Sorcerer
			Counter1:Set[Disperse]
			Counter2:Set[Reflect]
			PushStance1:Set[None]
			StripEnchantment1:Set[Disenchant]
			break
			
		case Dread Knight
			Counter1:Set[None]
			Counter2:Set[None]
			PushStance1:Set[None]
			StripEnchantment1:Set[Despoil]
			break

		case Disciple
			Counter1:Set[None]
			Counter2:Set[None]
			PushStance1:Set[Stance Wheel]
			StripEnchantment1:Set[None]
			break
			
		case Druid
			Counter1:Set[Dissipate]
			Counter2:Set[Healing Turn]
			PushStance1:Set[None]
			StripEnchantment1:Set[None]
			break

		case Bard
			Counter1:Set[None]
			Counter2:Set[None]
			PushStance1:Set[None]
			StripEnchantment1:Set[Asilam's Disenchanting Cry]
			break

		case Necromancer 
			Counter1:Set[Annul Magic]
			Counter2:Set[None]
			PushStance1:Set[None]
			StripEnchantment1:Set[None]
			break

		Default
			Counter1:Set[None]
			Counter2:Set[None]
			PushStance1:Set[None]
			StripEnchantment1:Set[None]
			break
	}

	;-------------------------------------------
	; Set Forage
	;-------------------------------------------
	if !${Me.Ability[Forage](exists)}
	{
		Forage:Set[None]
	}
	
	;-------------------------------------------
	; Calculate Highest Level
	;-------------------------------------------
	SetHighestAbility "CounterA" "${Counter1}"
	SetHighestAbility "CounterB" "${Counter2}"
	SetHighestAbility "PushStance" "${PushStance1}"
	SetHighestAbility "StripEnchantment" "${StripEnchantment1}"

	;-------------------------------------------
	; Build and Import XML Data
	;-------------------------------------------
	LavishSettings[DPS]:Clear
	LavishSettings:AddSet[DPS]
	LavishSettings[DPS]:AddSet[General-${Me.FName}]
	LavishSettings[DPS]:AddSet[Abilities-${Me.FName}]
	LavishSettings[DPS]:AddSet[Items-${Me.FName}]
	LavishSettings[DPS]:AddSet[Buffs-${Me.FName}]
	LavishSettings[DPS]:AddSet[TriggerBuffs-${Me.FName}]
	LavishSettings[DPS]:AddSet[BuffOnly-${Me.FName}]
	LavishSettings[DPS]:AddSet[Counters1-${Me.FName}]
	LavishSettings[DPS]:AddSet[Counters2-${Me.FName}]

	LavishSettings[DPS]:Import[${Script.CurrentDirectory}/Tools_save.xml]
	
	General:Set[${LavishSettings[DPS].FindSet[General-${Me.FName}].GUID}]
	Abilities:Set[${LavishSettings[DPS].FindSet[Abilities-${Me.FName}].GUID}]
	Items:Set[${LavishSettings[DPS].FindSet[Items-${Me.FName}].GUID}]
	Buffs:Set[${LavishSettings[DPS].FindSet[Buffs-${Me.FName}].GUID}]
	TriggerBuffs:Set[${LavishSettings[DPS].FindSet[TriggerBuffs-${Me.FName}].GUID}]
	BuffOnly:Set[${LavishSettings[DPS].FindSet[BuffOnly-${Me.FName}].GUID}]
	Counters1:Set[${LavishSettings[DPS].FindSet[Counters1-${Me.FName}].GUID}]
	Counters2:Set[${LavishSettings[DPS].FindSet[Counters2-${Me.FName}].GUID}]

	doUseAbilities:Set[${General.FindSetting[doUseAbilities,FALSE]}]
	doUseItems:Set[${General.FindSetting[doUseItems,FALSE]}]
	doCounter1:Set[${General.FindSetting[doCounter1,FALSE]}]
	doCounter2:Set[${General.FindSetting[doCounter2,FALSE]}]
	doCounter1Only:Set[${General.FindSetting[doCounter1Only,FALSE]}]
	doCounter2Only:Set[${General.FindSetting[doCounter2Only,FALSE]}]
	doPushStance:Set[${General.FindSetting[doPushStance,FALSE]}]
	doStripEnchantments:Set[${General.FindSetting[doStripEnchantments,FALSE]}]
	doForage:Set[${General.FindSetting[doForage,FALSE]}]
	doAutoAttack:Set[${General.FindSetting[doAutoAttack,FALSE]}]
	doRangedAttack:Set[${General.FindSetting[doRangedAttack,FALSE]}]
	doFace:Set[${General.FindSetting[doFace,FALSE]}]
	doAutoRepairs:Set[${General.FindSetting[doAutoRepairs,FALSE]}]
	doAutoRez:Set[${General.FindSetting[doAutoRez,FALSE]}]
	doHate:Set[${General.FindSetting[doHate,FALSE]}]
	doLoot:Set[${General.FindSetting[doLoot,FALSE]}]
	CombatForm:Set[${General.FindSetting[CombatForm,"NONE"]}]
	NonCombatForm:Set[${General.FindSetting[NonCombatForm,"NONE"]}]
	StartAttack:Set[${General.FindSetting[StartAttack,99]}]
	doGroupsay:Set[${General.FindSetting[doGroupsay,FALSE]}]
	doRaidsay:Set[${General.FindSetting[doRaidsay,FALSE]}]
	doTells:Set[${General.FindSetting[doTells,FALSE]}]
	doRift:Set[${General.FindSetting[doRift,FALSE]}]
	TriggerBuffing:Set[${General.FindSetting[TriggerBuffing,""]}]
	FollowDistance1:Set[${General.FindSetting[FollowDistance1,3]}]
	FollowDistance2:Set[${General.FindSetting[FollowDistance2,5]}]
	doMonotorTells:Set[${General.FindSetting[doMonotorTells,FALSE]}]
	doPhysical:Set[${General.FindSetting[doPhysical,TRUE]}]
	doArcane:Set[${General.FindSetting[doArcane,TRUE]}]
	doFire:Set[${General.FindSetting[doFire,TRUE]}]
	doIce:Set[${General.FindSetting[doIce,TRUE]}]
	doSpiritual:Set[${General.FindSetting[doSpiritual,TRUE]}]
	doMental:Set[${General.FindSetting[doMental,TRUE]}]
	doHarvest:Set[${General.FindSetting[doHarvest,TRUE]}]
	HarvestRange:Set[${General.FindSetting[HarvestRange,10]}]
	
	;; Class Specific - Bard
	CombatSong:Set[${General.FindSetting[CombatSong,"NONE"]}]
	PrimaryWeapon:Set[${General.FindSetting[PrimaryWeapon,"NONE"]}]
	SecondaryWeapon:Set[${General.FindSetting[SecondaryWeapon,"NONE"]}]
	RestSong:Set[${General.FindSetting[RestSong,"NONE"]}]
	RestInstrument:Set[${General.FindSetting[RestInstrument,"NONE"]}]
	TravelSong:Set[${General.FindSetting[TravelSong,"NONE"]}]
	TravelInstrument:Set[${General.FindSetting[TravelInstrument,"NONE"]}]
	
	;; Class Specific - Healers
	doSmallHeal:Set[${General.FindSetting[doSmallHeal]}]
	doBigHeal:Set[${General.FindSetting[doBigHeal]}]
	doGroupHeal:Set[${General.FindSetting[doGroupHeal]}]
	doInstantHeal:Set[${General.FindSetting[doInstantHeal]}]
	doHoT:Set[${General.FindSetting[doHoT]}]
	SmallHealPct:Set[${General.FindSetting[SmallHealPct]}]
	BigHealPct:Set[${General.FindSetting[BigHealPct]}]
	GroupHealPct:Set[${General.FindSetting[GroupHealPct]}]
	InstantHealPct:Set[${General.FindSetting[InstantHealPct]}]
	HoTPct:Set[${General.FindSetting[HoTPct]}]
	SmallHeal:Set[${General.FindSetting[SmallHeal,"NONE"]}]
	BigHeal:Set[${General.FindSetting[BigHeal,"NONE"]}]
	GroupHeal:Set[${General.FindSetting[GroupHeal,"NONE"]}]
	InstantHeal:Set[${General.FindSetting[InstantHeal,"NONE"]}]
	HoT:Set[${General.FindSetting[HoT,"NONE"]}]
	
	;; Class Specific - Tanks
	doRescue1:Set[${General.FindSetting[doRescue1]}]
	doRescue2:Set[${General.FindSetting[doRescue2]}]
	doRescue3:Set[${General.FindSetting[doRescue3]}]
	doReduceHate:Set[${General.FindSetting[doReduceHate]}]
	doIncreaseHate:Set[${General.FindSetting[doIncreaseHate]}]
	doCheckEncounters:Set[${General.FindSetting[doCheckEncounters]}]
	Rescue1:Set[${General.FindSetting[Rescue1,"NONE"]}]
	Rescue2:Set[${General.FindSetting[Rescue2,"NONE"]}]
	Rescue3:Set[${General.FindSetting[Rescue3,"NONE"]}]
	ReduceHate:Set[${General.FindSetting[ReduceHate,"NONE"]}]
	IncreaseHate:Set[${General.FindSetting[IncreaseHate,"NONE"]}]

	;; Class Specific - Necromancer
	AbominationName:Set[${General.FindSetting[AbominationName,"Stinky"]}]
	doSummonAbomination:Set[${General.FindSetting[doSummonAbomination,FALSE]}]
	AbominationStartAttack:Set[${General.FindSetting[AbominationStartAttack,99]}]
	doNecropsy:Set[${General.FindSetting[doNecropsy,FALSE]}]
	
	;-------------------------------------------
	; Reload the UI and draw our Tool window
	;-------------------------------------------
	waitframe
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	waitframe
	ui -reload -skin VGSkin "${Script.CurrentDirectory}/Tools.xml"
	waitframe
	
	;-------------------------------------------
	; Update UI from the XML Data
	;-------------------------------------------
	variable int i
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		UIElement[AbilitiesCombo@Abilities@DPS@Tools]:AddItem[${Me.Ability[${i}].Name}]
		if !${Me.Ability[${i}].IsOffensive} && !${Me.Ability[${i}].Type.Equal[Combat Art]} && !${Me.Ability[${i}].IsChain} && !${Me.Ability[${i}].IsCounter} && !${Me.Ability[${i}].IsRescue} && !${Me.Ability[${i}].Type.Equal[Song]}
		{
			if ${Me.Ability[${i}].TargetType.Equal[Self]} || ${Me.Ability[${i}].TargetType.Equal[Defensive]} || ${Me.Ability[${i}].TargetType.Find[Group]} || ${Me.Ability[${i}].TargetType.Equal[Ally]}
			{
				UIElement[BuffsCombo@Abilities@DPS@Tools]:AddItem[${Me.Ability[${i}].Name}]
				UIElement[TriggerBuffsCombo@BuffBot@DPS@Tools]:AddItem[${Me.Ability[${i}].Name}]
			}
		}
		if !${Me.Ability[${i}].IsOffensive} && ${Me.Ability[${i}].Type.Equal[Spell]}
		{
			if ${Me.Ability[${i}].TargetType.Equal[Self]} || ${Me.Ability[${i}].TargetType.Equal[Defensive]} || ${Me.Ability[${i}].TargetType.Find[Group]} || ${Me.Ability[${i}].TargetType.Equal[Ally]}
			{
				if ${Me.Ability[${i}].Description.Find[Heal]} || ${Me.Ability[${i}].Description.Find[Restore]}
				{
					UIElement[SmallHeal@Heals@DPS@Tools]:AddItem[${Me.Ability[${i}].Name}]
					UIElement[BigHeal@Heals@DPS@Tools]:AddItem[${Me.Ability[${i}].Name}]
					UIElement[GroupHeal@Heals@DPS@Tools]:AddItem[${Me.Ability[${i}].Name}]
					UIElement[InstantHeal@Heals@DPS@Tools]:AddItem[${Me.Ability[${i}].Name}]
					UIElement[HoT@Heals@DPS@Tools]:AddItem[${Me.Ability[${i}].Name}]
				}
			}
		}
		if ${Me.Ability[${i}].IsRescue} || ${Me.Ability[${i}].Description.Find[to target you]}
		{
			UIElement[Rescue1@Tanks@DPS@Tools]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[Rescue2@Tanks@DPS@Tools]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[Rescue3@Tanks@DPS@Tools]:AddItem[${Me.Ability[${i}].Name}]
		}
		if ${Me.Ability[${i}].Description.Find[less hate]} || ${Me.Ability[${i}].Description.Find[decrease hate]} || ${Me.Ability[${i}].Description.Find[reduce hate]}
			UIElement[ReduceHate@Tanks@DPS@Tools]:AddItem[${Me.Ability[${i}].Name}]
		elseif ${Me.Ability[${i}].Description.Find[hate]} || ${Me.Ability[${i}].Description.Find[hatred]}
		{
			UIElement[IncreaseHate@Tanks@DPS@Tools]:AddItem[${Me.Ability[${i}].Name}]
			Hate_Abilities:Set["${Me.Ability[${i}].Name}", "${Me.Ability[${i}].Name}"]
		}
		
	}
	for (i:Set[1] ; ${i} <= ${Me.Form} ; i:Inc)
	{
		UIElement[CombatForm@Abilities@DPS@Tools]:AddItem[${Me.Form[${i}].Name}]
		UIElement[NonCombatForm@Abilities@DPS@Tools]:AddItem[${Me.Form[${i}].Name}]
	}
	for (i:Set[1] ; ${i}<=${Me.Inventory} ; i:Inc)
	{
		;; dump everything here
		UIElement[ItemsCombo@Abilities@DPS@Tools]:AddItem[${Me.Inventory[${i}].Name}]


		;; delete these once the broken features are fixed "Me.Inventory[].xxxx"
		;UIElement[PrimaryWeapon@Bard@Class@DPS@Tools]:AddItem[${Me.Inventory[${i}].Name}]
		;UIElement[SecondaryWeapon@Bard@Class@DPS@Tools]:AddItem[${Me.Inventory[${i}].Name}]
		UIElement[RestInstrument@Bard@Class@DPS@Tools]:AddItem[${Me.Inventory[${i}].Name}]
		UIElement[TravelInstrument@Bard@Class@DPS@Tools]:AddItem[${Me.Inventory[${i}].Name}]
		
		
		;;THE FOLLOWING FEATURES ARE BROKEN

		if ${Me.Inventory[${i}].Type.Equal[Weapon]} || ${Me.Inventory[${i}].Type.Equal[Shield]}
		{
			;; Only Weapons here
			if ${Me.Inventory[${i}].Type.Equal[Weapon]} && !${Me.Inventory[${i}].DefaultEquipSlot.Equal[Secondary Hand]}
			{
				UIElement[PrimaryWeapon@Bard@Class@DPS@Tools]:AddItem[${Me.Inventory[${i}].Name}]
			}
			;; both Weapons and Sheilds here
			UIElement[SecondaryWeapon@Bard@Class@DPS@Tools]:AddItem[${Me.Inventory[${i}].Name}]
		}
		
		if (${Me.Inventory[${i}].Keyword2.Find[Instrument]})
		{
			;; Bard - add instruments 
			;UIElement[RestInstrument@Bard@Class@DPS@Tools]:AddItem[${Me.Inventory[${i}].Name}]
			;UIElement[TravelInstrument@Bard@Class@DPS@Tools]:AddItem[${Me.Inventory[${i}].Name}]
		}

	}

	;; class Specific - Bard
	for (i:Set[1] ; ${i} <= ${Songs} ; i:Inc)
	{
		UIElement[CombatSong@Bard@Class@DPS@Tools]:AddItem[${Songs[${i}].Name}]
		UIElement[RestSong@Bard@Class@DPS@Tools]:AddItem[${Songs[${i}].Name}]
		UIElement[TravelSong@Bard@Class@DPS@Tools]:AddItem[${Songs[${i}].Name}]
	}

	;; Now select the items based upon what we had saved
	Tools_BuildItems
	Tools_BuildAbilities
	Tools_BuildForms
	Tools_BuildBuffs
	Tools_BuildTriggerBuffs
	Tools_BuildBuffsOnly

	;;Class Specific - Bard Stuff
	for (i:Set[1] ; ${i} <= ${UIElement[CombatSong@Bard@Class@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[CombatSong@Bard@Class@DPS@Tools].Item[${i}].Text.Equal[${CombatSong}]}
		{
			UIElement[CombatSong@Bard@Class@DPS@Tools]:SelectItem[${i}]
		}
	}
	for (i:Set[1] ; ${i} <= ${UIElement[PrimaryWeapon@Bard@Class@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[PrimaryWeapon@Bard@Class@DPS@Tools].Item[${i}].Text.Equal[${PrimaryWeapon}]}
		{
			UIElement[PrimaryWeapon@Bard@Class@DPS@Tools]:SelectItem[${i}]
		}
	}
	for (i:Set[1] ; ${i} <= ${UIElement[SecondaryWeapon@Bard@Class@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[SecondaryWeapon@Bard@Class@DPS@Tools].Item[${i}].Text.Equal[${SecondaryWeapon}]}
		{
			UIElement[SecondaryWeapon@Bard@Class@DPS@Tools]:SelectItem[${i}]
		}
	}
	for (i:Set[1] ; ${i} <= ${UIElement[RestSong@Bard@Class@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[RestSong@Bard@Class@DPS@Tools].Item[${i}].Text.Equal[${RestSong}]}
		{
			UIElement[RestSong@Bard@Class@DPS@Tools]:SelectItem[${i}]
		}
	}
	for (i:Set[1] ; ${i} <= ${UIElement[RestInstrument@Bard@Class@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[RestInstrument@Bard@Class@DPS@Tools].Item[${i}].Text.Equal[${RestInstrument}]}
		{
			UIElement[RestInstrument@Bard@Class@DPS@Tools]:SelectItem[${i}]
		}
	}
	for (i:Set[1] ; ${i} <= ${UIElement[TravelSong@Bard@Class@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[TravelSong@Bard@Class@DPS@Tools].Item[${i}].Text.Equal[${TravelSong}]}
		{
			UIElement[TravelSong@Bard@Class@DPS@Tools]:SelectItem[${i}]
		}
	}
	for (i:Set[1] ; ${i} <= ${UIElement[TravelInstrument@Bard@Class@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[TravelInstrument@Bard@Class@DPS@Tools].Item[${i}].Text.Equal[${TravelInstrument}]}
		{
			UIElement[TravelInstrument@Bard@Class@DPS@Tools]:SelectItem[${i}]
		}
	}
	for (i:Set[1] ; ${i} <= ${UIElement[SmallHeal@Heals@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[SmallHeal@Heals@DPS@Tools].Item[${i}].Text.Equal[${SmallHeal}]}
		{	
			UIElement[SmallHeal@Heals@DPS@Tools]:SelectItem[${i}]
		}
	}
	for (i:Set[1] ; ${i} <= ${UIElement[BigHeal@Heals@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[BigHeal@Heals@DPS@Tools].Item[${i}].Text.Equal[${BigHeal}]}
		{
			UIElement[BigHeal@Heals@DPS@Tools]:SelectItem[${i}]
		}
	}
	for (i:Set[1] ; ${i} <= ${UIElement[GroupHeal@Heals@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[GroupHeal@Heals@DPS@Tools].Item[${i}].Text.Equal[${GroupHeal}]}
		{
			UIElement[GroupHeal@Heals@DPS@Tools]:SelectItem[${i}]
		}
	}
	for (i:Set[1] ; ${i} <= ${UIElement[HoT@Heals@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[HoT@Heals@DPS@Tools].Item[${i}].Text.Equal[${HoT}]}
		{
			UIElement[HoT@Heals@DPS@Tools]:SelectItem[${i}]
		}
	}
	for (i:Set[1] ; ${i} <= ${UIElement[InstantHeal@Heals@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[InstantHeal@Heals@DPS@Tools].Item[${i}].Text.Equal[${InstantHeal}]}
		{
			UIElement[InstantHeal@Heals@DPS@Tools]:SelectItem[${i}]
		}
	}
	for (i:Set[1] ; ${i} <= ${UIElement[Rescue1@Tanks@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[Rescue1@Tanks@DPS@Tools].Item[${i}].Text.Equal[${Rescue1}]}
		{
			UIElement[Rescue1@Tanks@DPS@Tools]:SelectItem[${i}]
		}
	}
	for (i:Set[1] ; ${i} <= ${UIElement[Rescue2@Tanks@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[Rescue2@Tanks@DPS@Tools].Item[${i}].Text.Equal[${Rescue2}]}
		{
			UIElement[Rescue2@Tanks@DPS@Tools]:SelectItem[${i}]
		}
	}
	for (i:Set[1] ; ${i} <= ${UIElement[Rescue3@Tanks@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[Rescue3@Tanks@DPS@Tools].Item[${i}].Text.Equal[${Rescue3}]}
		{
			UIElement[Rescue3@Tanks@DPS@Tools]:SelectItem[${i}]
		}
	}
	for (i:Set[1] ; ${i} <= ${UIElement[ReduceHate@Tanks@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[ReduceHate@Tanks@DPS@Tools].Item[${i}].Text.Equal[${ReduceHate}]}
		{
			UIElement[ReduceHate@Tanks@DPS@Tools]:SelectItem[${i}]
		}
	}
	for (i:Set[1] ; ${i} <= ${UIElement[IncreaseHate@Tanks@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[IncreaseHate@Tanks@DPS@Tools].Item[${i}].Text.Equal[${IncreaseHate}]}
		{
			UIElement[IncreaseHate@Tanks@DPS@Tools]:SelectItem[${i}]
		}
	}
	
	;-------------------------------------------
	; Enable Events - this event is automatically removed at shutdown
	;-------------------------------------------
	Event[VG_OnIncomingText]:AttachAtom[ChatEvent]	
	Event[VG_OnPawnSpawned]:AttachAtom[PawnSpawned]
}

;===================================================
;===     ATEXIT - called when the script ends   ====
;===================================================
function atexit()
{
	;; Unload Tools_BuffArea routine
	if ${Script[Tools_BuffArea](exists)}
	{
		endscript Tools_BuffArea
	}

	;; update our toggle settings
	General:AddSetting[doUseAbilities,${doUseAbilities}]
	General:AddSetting[doUseItems,${doUseItems}]
	General:AddSetting[doCounter1,${doCounter1}]
	General:AddSetting[doCounter2,${doCounter2}]
	General:AddSetting[doCounter1Only,${doCounter1Only}]
	General:AddSetting[doCounter2Only,${doCounter2Only}]
	General:AddSetting[doPushStance,${doPushStance}]
	General:AddSetting[doStripEnchantments,${doStripEnchantments}]
	General:AddSetting[doForage,${doForage}]
	General:AddSetting[doAutoAttack,${doAutoAttack}]
	General:AddSetting[doRangedAttack,${doRangedAttack}]
	General:AddSetting[doFace,${doFace}]
	General:AddSetting[doAutoRepairs,${doAutoRepairs}]
	General:AddSetting[doAutoRez,${doAutoRez}]
	General:AddSetting[doHate,${doHate}]
	General:AddSetting[doLoot,${doLoot}]
	General:AddSetting[CombatForm,${CombatForm}]
	General:AddSetting[NonCombatForm,${NonCombatForm}]
	General:AddSetting[doHarvest,${doHarvest}]
	General:AddSetting[HarvestRange,${HarvestRange}]
	General:AddSetting[StartAttack,${StartAttack}]
	General:AddSetting[doGroupsay,${doGroupsay}]
	General:AddSetting[doRaidsay,${doRaidsay}]
	General:AddSetting[doTells,${doTells}]
	General:AddSetting[doRift,${doRift}]
	General:AddSetting[doMonotorTells,${doMonotorTells}]
	General:AddSetting[FollowDistance1,${FollowDistance1}]
	General:AddSetting[FollowDistance2,${FollowDistance2}]
	General:AddSetting[doPhysical,${doPhysical}]
	General:AddSetting[doArcane,${doArcane}]
	General:AddSetting[doFire,${doFire}]
	General:AddSetting[doIce,${doIce}]
	General:AddSetting[doSpiritual,${doSpiritual}]
	General:AddSetting[doMental,${doMental}]
	General:AddSetting[TriggerBuffing,${TriggerBuffing}]
	if ${TriggerBuffing.Length}==0
	{
		General:AddSetting[TriggerBuffing,""]
	}

	;; update class specific - Bard
	General:AddSetting[CombatSong,${CombatSong}]
	General:AddSetting[PrimaryWeapon,${PrimaryWeapon}]
	General:AddSetting[SecondaryWeapon,${SecondaryWeapon}]
	General:AddSetting[RestSong,${RestSong}]
	General:AddSetting[RestInstrument,${RestInstrument}]
	General:AddSetting[TravelSong,${TravelSong}]
	General:AddSetting[TravelInstrument,${TravelInstrument}]
	
	;; update class specific - Healers
	General:AddSetting[doSmallHeal,${doSmallHeal}]
	General:AddSetting[doBigHeal,${doBigHeal}]
	General:AddSetting[doGroupHeal,${doGroupHeal}]
	General:AddSetting[doInstantHeal,${doInstantHeal}]
	General:AddSetting[doHoT,${doHoT}]
	General:AddSetting[SmallHealPct,${SmallHealPct}]
	General:AddSetting[BigHealPct,${BigHealPct}]
	General:AddSetting[GroupHealPct,${GroupHealPct}]
	General:AddSetting[InstantHealPct,${InstantHealPct}]
	General:AddSetting[HoTPct,${HoTPct}]
	General:AddSetting[SmallHeal,${SmallHeal}]
	General:AddSetting[BigHeal,${BigHeal}]
	General:AddSetting[GroupHeal,${GroupHeal}]
	General:AddSetting[InstantHeal,${InstantHeal}]
	General:AddSetting[HoT,${HoT}]

	;; update class specific - Tanks
	General:AddSetting[doRescue1,${doRescue1}]
	General:AddSetting[doRescue2,${doRescue2}]
	General:AddSetting[doRescue3,${doRescue3}]
	General:AddSetting[doReduceHate,${doReduceHate}]
	General:AddSetting[doIncreaseHate,${doIncreaseHate}]
	General:AddSetting[Rescue1,${Rescue1}]
	General:AddSetting[Rescue2,${Rescue2}]
	General:AddSetting[Rescue3,${Rescue3}]
	General:AddSetting[ReduceHate,${ReduceHate}]
	General:AddSetting[IncreaseHate,${IncreaseHate}]
	General:AddSetting[doCheckEncounters,${doCheckEncounters}]
	
	;; update class specific - Necromancer
	General:AddSetting[AbominationName,${AbominationName}]
	General:AddSetting[doSummonAbomination,${doSummonAbomination}]
	General:AddSetting[AbominationStartAttack,${AbominationStartAttack}]
	General:AddSetting[doNecropsy,${doNecropsy}]
	
	;; save our settings to file
	LavishSettings[DPS]:Export[${Script.CurrentDirectory}/Tools_Save.xml]

	;; Unload our UI
	ui -unload "${Script.CurrentDirectory}/Tools.xml"
	
	;; Say we are done
	EchoIt "Stopped Tools Script"
}

;===================================================
;===       ATOM - ECHO A STRING OF TEXT         ====
;===================================================
atom(script) EchoIt(string aText)
{
	echo "[${Time}][Tools] ${aText}"
}

;===================================================
;===       ATOM - PawnSpawned                   ====
;===================================================
atom(script) PawnSpawned(string aID, string aName, string aLevel, string aType)
{
	if ${doRift}
	{
		if ${aType.Equal[PC]} || ${aType.Equal[Group Member]} || !${aType(exists)}
		{
			;; ID, Level and Type sometimes generates 0 or NULL
			EchoIt "[${aID}], lvl=${aLevel}, ${aName}, ${aType}"
			PCName:Set[${aName.Token[1," "]}]
			Tools_BuffRequestList:Set["${PCName}", "Buff"]
		}
	}
}

;===================================================
;===       ATOM - Monitor Chat Event            ====
;===================================================
atom(script) ChatEvent(string aText, string ChannelNumber, string ChannelName)
{
	echo [${ChannelNumber}] ${aText}

	;; Log all tells to a file and play a sound
	if ${doMonotorTells} && ${ChannelNumber}==15
	{
		Redirect -append "${LogThis}" echo "[${Time}][Tools]: ${aText}"
		PlaySound ALARM
	}

	;; Ready Check!
	if ${aText.Find[You have received a raid ready check.]}
	{
		EchoIt "[${ChannelNumber}] ${aText}"
		PlaySound ALARM
	}

	if ${ChannelNumber}==0 && ${aText.Find[You can't attack with that type of weapon.]}
	{
		EchoIt "[${ChannelNumber}]${aText}"
		doWeaponCheck:Set[FALSE]
		if ${GV[bool,bIsAutoAttacking]} || ${Me.Ability[Auto Attack].Toggled}
		{
			Me.Ability[Auto Attack]:Use
		}
		;UIElement[doAutoAttack@Abilities@DPS@Tools]:UnsetChecked
		vgecho "Melee Off - can't attack with that weapon"
	}
	
	if ${ChannelNumber}==1
	{
		if ${aText.Equal[You do not have enough skill to begin harvesting this resource.]}
		{
			HarvestBlackList:Set[${Me.Target.ID},${Me.Target.ID}]
			VGExecute /cleartargets
			return
		}
		if ${aText.Equal[That resource has already been harvested]}
		{
			HarvestBlackList:Set[${Me.Target.ID},${Me.Target.ID}]
			VGExecute /cleartargets
			return
		}
	}

	if ${ChannelNumber}==26
	{
		;; this may be different for each class
		if ${aText.Find[and it is dispersed!]}
		{
			variable string bText
			bText:Set[${aText.Mid[${aText.Find['s ]},${aText.Length}]}]
			bText:Set[${bText.Left[${Math.Calc[${bText.Length}-21]}]}]
			bText:Set[${bText.Right[${Math.Calc[${bText.Length}-3]}]}]
			vgecho "<Purple=>COUNTERED: <Yellow=>${bText}"
		}
	}

	;; Someone said something in group
	if ${doGroupsay} && ${ChannelNumber}==8 && ${aText.Find[${TriggerBuffing}]}
	{
		EchoIt "GROUP = ${aText}"
		PCNameFull:Set[${aText.Token[2,">"].Token[1,"<"]}]
		PCName:Set[${PCNameFull.Token[1," "]}]
		Tools_BuffRequestList:Set["${PCName}", "Buff"]
	}
	;; Someone said something in raid (Guild = 11)
	if ${doRaidsay} && ${ChannelNumber}==9 && ${aText.Find[${TriggerBuffing}]}
	{
		EchoIt "RAID = ${aText}"
		PCNameFull:Set[${aText.Token[2,">"].Token[1,"<"]}]
		PCName:Set[${PCNameFull.Token[1," "]}]
		Tools_BuffRequestList:Set["${PCName}", "Buff"]
	}
	;; Someone sent us a tell
	if ${doTells} && ${ChannelNumber}==15 && ${aText.Find[${TriggerBuffing}]}
	{
		EchoIt "TELL = ${aText}"
		PCNameFull:Set[${aText.Token[2,">"].Token[1,"<"]}]
		PCName:Set[${PCNameFull.Token[1," "]}]
		Tools_BuffRequestList:Set["${PCName}", "Buff"]
	}

	;; Accept Rez
	if ${ChannelNumber}==32
	{
		if ${aText.Find[is trying to resurrect you with]}
		{
			PlaySound ALARM
			doAcceptRez:Set[TRUE]
		}
	}
}


;===================================================
;===          ATOM - PLAY A SOUND               ====
;===================================================
atom(script) PlaySound(string Filename)
{
	System:APICall[${System.GetProcAddress[WinMM.dll,PlaySound].Hex},Filename.String,0,"Math.Dec[22001]"]
}

;===================================================
;===       Handle Global Cooldowns              ====
;===================================================
function GlobalCooldown()
{
	wait 5
	if ${VG.InGlobalRecovery} || !${Tools.AreWeReady}
	{
		while ${VG.InGlobalRecovery} || !${Tools.AreWeReady}
		{
			call AutoAttack
		}
		wait 2
	}
	call UseItems
}

;===================================================
;===       I AM CASTING SUB-ROUTINE             ====
;===================================================
function IsCasting()
{
	wait 5
	if ${Me.IsCasting} || ${VG.InGlobalRecovery} || !${Tools.AreWeReady}
	{
		while ${Me.IsCasting} || ${VG.InGlobalRecovery} || !${Tools.AreWeReady}
		{
			call CounterIt
			call AutoAttack
			call FollowTank
		}
		wait 2
	}
	call UseItems
}

function ReadyCheck()
{
	while !${Tools.AreWeReady}
	{
		while !${Tools.AreWeReady}
			waitframe
		wait 4
	}
}

;===================================================
;===       ATOM - SET HIGHEST ABILITIES         ====
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
		declare	${AbilityVariable}	string	script "${ABILITY}"
		;echo "${AbilityVariable}=${ABILITY}"
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
			;echo "${AbilityVariable}=${ABILITY}"
			break
		}
	}
	while (${L:Dec}>0)

	;-------------------------------------------
	; If Ability exist then return
	;-------------------------------------------
	if ${Me.Ability["${ABILITY}"](exists)} && ${Me.Ability["${ABILITY}"].LevelGranted}<=${Me.Level}
	{
		declare	${AbilityVariable} string script "${ABILITY}"
		;echo "${AbilityVariable}=${ABILITY}"
		return
	}

	;-------------------------------------------
	; Otherwise, new Ability is named "None"
	;-------------------------------------------
	declare	${AbilityVariable} string script "None"
	;echo "${AbilityVariable}=${ABILITY}"
	return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;  R O U T I N E S   ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;===================================================
;===   COUNTER IT - this will counter a spell   ====
;===================================================
function CounterIt()
{
	if !${isPaused} && ${isRunning}
	{
		; in order to counter we have to be able to ID the ability
		if !${Me.TargetCasting.Equal[None]}
		{
			variable bool Okay2Counter
			variable iterator Iterator
		
			;; target is casting so update UI to show casted ability
			UIElement[Counter1@Counters@DPS@Tools]:SetText[${Me.TargetCasting}]
			UIElement[Counter2@Counters@DPS@Tools]:SetText[${Me.TargetCasting}]

			if ${doCounter1}
			{
				Okay2Counter:Set[TRUE]
				if ${doCounter1Only}
				{
					Okay2Counter:Set[FALSE]
					Counters1:GetSettingIterator[Iterator]
					
					;; loop thru the Counter1List
					while ( ${Iterator.Key(exists)} )
					{
						if !${Iterator.Key.Equal[NULL]}
						{
							if ${Me.TargetCasting.Equal[${Iterator.Key}]}
							{
								Okay2Counter:Set[TRUE]
								break
							}
						}
						Iterator:Next
					}
				}
			
				if ${Okay2Counter} && ${Me.Ability[${CounterA}].IsReady} && ${Me.Ability[${CounterA}].TimeRemaining}==0
				{
					VGExecute "/reactioncounter 1"
					wait 1
					call GlobalCooldown
				}
			}
			if ${doCounter2}
			{
				Okay2Counter:Set[TRUE]
				if ${doCounter2Only}
				{
					Okay2Counter:Set[FALSE]
					Counters2:GetSettingIterator[Iterator]
					
					;; loop thru the Counter2List
					while ( ${Iterator.Key(exists)} )
					{
						if !${Iterator.Key.Equal[NULL]}
						{
							if ${Me.TargetCasting.Equal[${Iterator.Key}]}
							{
								Okay2Counter:Set[TRUE]
								break
							}
						}
						Iterator:Next
					}
				}

				if ${Okay2Counter} && ${Me.Ability[${CounterB}].IsReady} && ${Me.Ability[${CounterB}].TimeRemaining}==0
				{
					VGExecute "/reactioncounter 2"
					wait 1
					call GlobalCooldown
				}
			}
		}
	}
}

;===================================================
;=== STRIP IT - this will remove an enchantment ====
;===================================================
function StripIt()
{
	if ${doStripEnchantments} && !${isPaused} && ${isRunning}
	{
		if ${Me.Target(exists)} && ${Me.Target.HaveLineOfSightTo} && (${Me.Target.Type.Equal[NPC]} || ${Me.Target.Type.Equal[AggroNPC]})
		{
			if ${Me.Ability[${StripEnchantment}].IsReady}
			{
				variable bool doStripIt = FALSE
				variable string StripThisEnchantment = "None"
			
				; loop through all target buffs finding confirmed enchantment we can stip
				for (i:Set[1] ; ${i}<=${Me.TargetBuff} ; i:Inc)
				{
					;; Enchantments - Minor thru Greater
					if ${Me.TargetBuff[${i}].Name.Find[Enchantment]}
					{
						StripThisEnchantment:Set[${Me.TargetBuff[${i}].Name}]
						doStripIt:Set[TRUE]
						break
					}
					;; Dark Celerity
					elseif ${Me.TargetBuff[${i}].Name.Find[Dark Celerity]}
					{
						StripThisEnchantment:Set[${Me.TargetBuff[${i}].Name}]
						doStripIt:Set[TRUE]
						break
					}
					;; Vigor
					elseif ${Me.TargetBuff[${i}].Name.Find[Vigor]}
					{
						StripThisEnchantment:Set[${Me.TargetBuff[${i}].Name}]
						doStripIt:Set[TRUE]
						break
					}
					;; Thick Skin
					elseif ${Me.TargetBuff[${i}].Name.Find[Thick Skin]}
					{
						StripThisEnchantment:Set[${Me.TargetBuff[${i}].Name}]
						doStripIt:Set[TRUE]
						break
					}
					;; Lightning Barrier
					elseif ${Me.TargetBuff[${i}].Name.Find[Lightning]}
					{
						StripThisEnchantment:Set[${Me.TargetBuff[${i}].Name}]
						doStripIt:Set[TRUE]
						break
					}
					;; Chaos Shield
					elseif ${Me.TargetBuff[${i}].Name.Find[Chaos]}
					{
						StripThisEnchantment:Set[${Me.TargetBuff[${i}].Name}]
						doStripIt:Set[TRUE]
						break
					}
					;; Annulment Field
					elseif ${Me.TargetBuff[${i}].Name.Find[Annulment]}
					{
						StripThisEnchantment:Set[${Me.TargetBuff[${i}].Name}]
						doStripIt:Set[TRUE]
						break
					}
					;; Touch of Fire
					elseif ${Me.TargetBuff[${i}].Name.Find[Touch of Fire]}
					{
						StripThisEnchantment:Set[${Me.TargetBuff[${i}].Name}]
						doStripIt:Set[TRUE]
						break
						
					}
					;; Holy Armor - Hard To Remove
					elseif ${Me.TargetBuff[${i}].Name.Find[Holy Armor]}
					{
						StripThisEnchantment:Set[${Me.TargetBuff[${i}].Name}]
						doStripIt:Set[TRUE]
						break
					}
					;; Rust Shield - Hard To Remove
					elseif ${Me.TargetBuff[${i}].Name.Find[Rust Shield]}
					{
						StripThisEnchantment:Set[${Me.TargetBuff[${i}].Name}]
						doStripIt:Set[TRUE]
						break
					}
				}

				;-------------------------------------------
				; we do not know what enchantment will get removed so just remove something
				;-------------------------------------------
				if ${doStripIt} && !${isPaused} && ${isRunning}
				{
					Me.Ability[${StripEnchantment}]:Use
					call IsCasting

					;; check to see if enchantment was removed
					wait 10 !${Me.TargetBuff[${StripThisEnchantment}](exists)}
					if !${Me.TargetBuff[${StripThisEnchantment}](exists)}
					{
						EchoIt "STRIPPED: ${StripThisEnchantment}"
						vgecho "<Purple=>STRIPPED: <Yellow=>${StripThisEnchantment}"
					}
				}
			}
		}
	}
}

;===================================================
;===   PUSH STANCE - this will push the stance  ====
;===================================================
function PushStance()
{
	if ${doPushStance} && !${isPaused} && ${isRunning}
	{
		if ${Me.Target(exists)} && ${Me.Target.HaveLineOfSightTo} && (${Me.Target.Type.Equal[NPC]} || ${Me.Target.Type.Equal[AggroNPC]})
		{
			if ${Me.Ability[${PushStance}].IsReady}
			{
				variable bool doPushIt = FALSE
				variable string StripThisStance = "None"
			
				; loop through all target buffs finding confirmed stances we can push
				for (i:Set[1] ; ${i}<=${Me.TargetBuff} ; i:Inc)
				{
					;; Stances - Minor thru Greater
					if ${Me.TargetBuff[${i}].Name.Find[Stance]}
					{
						StripThisStance:Set[${Me.TargetBuff[${i}].Name}]
						doPushIt:Set[TRUE]
						break
					}
				}
				;-------------------------------------------
				; we have an idea there is a stance so let's try pushing it
				;-------------------------------------------
				if ${doPushIt} && !${isPaused} && ${isRunning}
				{
					Me.Ability[${PushStance}]:Use
					call IsCasting

					;; check to see if stance was pushed
					wait 10 !${Me.TargetBuff[${StripThisStance}](exists)}
					if !${Me.TargetBuff[${StripThisStance}](exists)}
					{
						EchoIt "PUSHED: ${StripThisStance}"
						vgecho "<Purple=>PUSHED: <Yellow=>${StripThisStance}"
					}
				}
			}
		}
	}
}

;===================================================
;===   OKAY TO ATTACK - returns TRUE/FALSE      ====
;===================================================
function:bool OkayToAttack(string ABILITY="None")
{
	if !${Me.Target(exists)}
		return FALSE
		
	;; Delay only if we can't ID the target (lag does that)
	if !${Me.TargetAsEncounter.Difficulty(exists)}
		wait 10 ${Me.TargetAsEncounter.Difficulty(exists)} && ${Me.TargetHealth(exists)}

	;if (!${Me.IsGrouped} || ${Me.InCombat} || ${Pawn[Name,${Tank}].CombatState}>0) && ${Me.Target(exists)} && !${Me.Target.IsDead} && (${Me.Target.Type.Find[NPC]} || ${Me.Target.Type.Equal[AggroNPC]}) && ${Me.TargetHealth}<=${StartAttack}
	if !${Me.Target.IsDead} && (${Me.Target.Type.Find[NPC]} || ${Me.Target.Type.Equal[AggroNPC]}) && ${Me.TargetHealth}<=${StartAttack}
	{
		;if ${Me.TargetHealth}<1 || !${Me.TargetHealth(exists)}
		;{
		;	return FALSE
		;}
		;if !${doHate} && (${Me.Ability[${ABILITY}].Description.Find[hate]} || ${Me.Ability[${ABILITY}].Description.Find[hatred]})
		if !${doHate} && ${Hate_Abilities.Element["${ABILITY}"](exists)}
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

		;-------------------------------------------
		; Check PHYSICAL resistances
		;-------------------------------------------
		if ${Me.Ability[${ABILITY}].School.Find[Physical]}
		{
			if !${doPhysical}
			{
				return FALSE
			}
			if ${Me.TargetBuff[Earth Form](exists)}
			{
				return FALSE
			}
			switch "${Me.Target.Name}"
			{
				case Summoned Earth Elemental
					return FALSE

				case Wing Grafted Slasher
					return FALSE

				case Enraged Death Hound
					return FALSE

				case Lesser Flarehound
					return FALSE

				case Lirikin
					return FALSE

				case Nathrix
					return FALSE

				case Shonaka
					return FALSE

				case Wisil
					return FALSE

				case Filtha
					return FALSE

				case SILIUSAURUS
					return FALSE

				case ARCHON TRAVIX
					return FALSE

				case Earthen Marauder
					return FALSE

				case Earthen Resonator
					return FALSE

				case Cartheon Devourer
					return FALSE

				case Rock Elemental
					return FALSE

				case Cartheon Soulslasher
					return FALSE

				case Cartheon Abomination
					return FALSE

				case Glowing Infineum
					return FALSE

				case Living Infineum
					return FALSE

				case Spawn of Infineum
					return FALSE

				case Myconid Fungal Ravager
					return FALSE

				case Xakrin Sage
					return FALSE

				case Hound of Rahz
					return FALSE

				case Ancient Juggernaut
					return FALSE

				case Xakrin Razarclaw
					return FALSE

				case Assaulting Death Hound
					return FALSE

				case Blood-crazed Ettercap
					return FALSE

				case Flarehound
					return FALSE

				case Lixirikin
					return FALSE

				case Flarehound Watcher
					return FALSE

				case Nefarious Titan
					return FALSE

				case Nefarious Elemental
					return FALSE

				case Enraged Convocation
					return FALSE

				Default
					break
			}
		}

		;-------------------------------------------
		; Check ARCANE resistances
		;-------------------------------------------
		if ${Me.Ability[${ABILITY}].School.Find[Arcane]}
		{
			if !${doArcane}
			{
				return FALSE
			}
			if ${Me.TargetBuff[Electric Form](exists)}
			{
				return FALSE
			}
			switch "${Me.Target.Name}"
			{
				case Descrier Sentry
					return FALSE

				case Summoned Air Elemental
					return FALSE

				case Descrier Psionicist
					return FALSE

				case Descrier Dreadwatcher
					return FALSE

				case Sub-Warden Mer
					return FALSE

				case OVERWARDEN
					return FALSE

				case Omac
					return FALSE

				case Salrin
					return FALSE

				case Bandori
					return FALSE

				case Guardian B27
					return FALSE

				case Energized Marauder
					return FALSE

				case Energized Resonator
					return FALSE

				case Electric Elemental
					return FALSE

				case Lesser Electric Elemental
					return FALSE

				case Greater Electric Elemental
					return FALSE

				case Energized Elemental
					return FALSE

				case Construct of Lightning
					return FALSE

				case Cartheon Wingwraith
					return FALSE

				case Source of Arcane Energy
					return FALSE

				case Ancient Infector
					return FALSE

				case Cartheon Archivist
					return FALSE

				case Cartheon Arcanist
					return FALSE

				case Cartheon Scholar
					return FALSE

				case Eyelord Seeker
					return FALSE

				case Mechanized Stormsuit
					return FALSE

				Default
					break
			}
		}

		;-------------------------------------------
		; Check FIRE resistances
		;-------------------------------------------
		if ${Me.Ability[${ABILITY}].School.Find[Fire]}
		{
			if !${doFire}
			{
				return FALSE
			}
			if (${Me.TargetBuff[Molten Form](exists)} || ${Me.TargetBuff[Fire Form](exists)})
			{
				return FALSE
			}
			switch "${Me.Target.Name}"
			{
				case Mechanized Pyromaniac
					return FALSE

				Default
					break
			}
		}

		;-------------------------------------------
		; Check ICE/COLD resistances
		;-------------------------------------------
		if (${Me.Ability[${ABILITY}].School.Find[Ice]} || ${Me.Ability[${ABILITY}].School.Find[Cold]})
		{
			if !${doIce}
			{
				return FALSE
			}
			if (${Me.TargetBuff[Ice Form](exists)} || ${Me.TargetBuff[Cold Form](exists)} || ${Me.TargetBuff[Frozen Form](exists)})
			{
				return FALSE
			}
			switch "${Me.Target.Name}"
			{
				Default
					break
			}
		}

		;-------------------------------------------
		; Check MENTAL resistances
		;-------------------------------------------
		if ${Me.Ability[${ABILITY}].School.Find[Mental]}
		{
			if !${doMental}
			{
				return FALSE
			}
			switch "${Me.Target.Name}"
			{
				Default
					break
			}
		}

		;-------------------------------------------
		; Check SPIRITUAL resistances
		;-------------------------------------------
		if ${Me.Ability[${ABILITY}].School.Find[Spiritual]}
		{
			if !${doSpiritual}
			{
				return FALSE
			}
			switch "${Me.Target.Name}"
			{
				Default
					break
			}
		}
		
		;; this is sloppy but works
		if ${doFace}
		{
			Me.Target:Face
		}
		return TRUE
	}
	
	return FALSE
}

;===================================================
;===   AUTO ATTACK - this will turn On/Off  ====
;===================================================
function:bool AutoAttack()
{
	call OkayToAttack
	if ${Return} && ${doAutoAttack} && ${Me.Target.Distance}<5
	{
		;; Turn on auto-attack
		if !${GV[bool,bIsAutoAttacking]} || !${Me.Ability[Auto Attack].Toggled}
		{
			if ${doWeaponCheck}
			{
				vgecho "Turning AutoAttack ON"
				Me.Ability[Auto Attack]:Use
				wait 10 ${GV[bool,bIsAutoAttacking]} && ${Me.Ability[Auto Attack].Toggled}
				return
			}
			
/*		
			if ${doWeaponCheck}
			{
				waitframe
				if "${Me.Inventory[CurrentEquipSlot,"Primary Hand"].Type.Equal[Weapon]}" || "${Me.Inventory[CurrentEquipSlot,"Two Hand"].Type.Equal[Weapon]}"
				{
					waitframe
					vgecho "Turning AutoAttack ON"
					Me.Ability[Auto Attack]:Use
					wait 10 ${GV[bool,bIsAutoAttacking]} && ${Me.Ability[Auto Attack].Toggled}
					return
				}
				doWeaponCheck:Set[FALSE]
			}
*/
		}
	}
	else
	{
		call MeleeAttackOff
	}
}	
variable bool doWeaponCheck = TRUE

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
	
	if !${Me.InCombat} && !${Me.Target(exists)} && ${Me.Encounter}==0
	{
		if !${doWeaponCheck}
		{
			wait 5
		}
		doWeaponCheck:Set[TRUE]
	}
}

;===================================================
;===       RANGED ATTACK - Use it               ====
;===================================================
function RangedAttack()
{
	call OkayToAttack
	if ${Return} && ${doRangedAttack}
	{
		if ${Me.Ability[Ranged Attack](exists)}
		{
			call UseAbility "Ranged Attack"
		}
	}
}


;===================================================
;===             Check Buffs                    ====
;===================================================
function CheckBuffs()
{
	variable iterator Iterator
	variable string temp
	Buffs:GetSettingIterator[Iterator]
	while ${Iterator.Key(exists)} && !${isPaused} && ${isRunning}
	{
		;; we do not want to recast the berry spell if they already exist in your inventory
		if ${anIter.Key.Find[berries]}
		{
			temp:Set[${anIter.Key.Token[1," "]}]
			if ${Me.Inventory[${temp}](exists)} || ${Me.Inventory[Tiny ${temp}](exists)} || ${Me.Inventory[Small ${temp}](exists)} || ${Me.Inventory[Large ${temp}](exists)} || ${Me.Inventory[Great ${temp}](exists)}
			{
				anIter:Next
				continue
			}
		}
		
		;; Use the ability if it is ready and does not exist on self
		if ${Me.Ability[${Iterator.Key}].IsReady} && !${Me.Effect[${Iterator.Key}](exists)}
		{
			Pawn[Me]:Target
			wait 3
			Me.Ability["${Iterator.Key}"]:Use
			call IsCasting
		}
		Iterator:Next
	}
}

;===================================================
;===        ASSIST TANK SUBROUTINE              ====
;===================================================
function AssistTank()
{
	if !${Tank.Find[${Me.FName}]}
	{
		if ${Pawn[Name,${Tank}](exists)}
		{
			;; assist the tank only if the tank is in combat and less than 50 meters away
			if ${Pawn[Name,${Tank}].CombatState}>0 && ${Pawn[Name,${Tank}].Distance}<=50 && !${Pawn[Name,${Tank}].IsDead}
			{
				if (${Me.Target(exists)} && !${Me.ToT.Name.Find[${Tank}](exists)}) || (!${Me.Target(exists)} || (${Me.Target(exists)} && ${Me.Target.IsDead}))
				{
					EchoIt "Assisting ${Tank}"
					VGExecute "/assist ${Tank}"
					waitframe
				}
			}
			elseif ${Me.Encounter}>0 && (!${Me.Target(exists)} || (${Me.Target(exists)} && ${Me.Target.IsDead}))
			{
				EchoIt "Grabbing Next Encounter"
				VGExecute /cleartargets
				waitframe
				Pawn[id,${Me.Encounter[1].ID}]:Target
				wait 3
			}
		}
	}
	elseif ${Me.Encounter}>0 && (!${Me.Target(exists)} || (${Me.Target(exists)} && ${Me.Target.IsDead}))
	{
		EchoIt "Grabbing Next Encounter"
		VGExecute /cleartargets
		waitframe
		Pawn[id,${Me.Encounter[1].ID}]:Target
		wait 3
	}
}

;===================================================
;===              Use Abilities                 ====
;===================================================
function UseAbilities()
{
	if ${doUseAbilities} && !${isPaused} && ${isRunning}
	{
		variable iterator Iterator
		Abilities:GetSettingIterator[Iterator]
		while ${Iterator.Key(exists)} && !${isPaused} && ${isRunning} && !${Me.Target.IsDead}
		{
			;; use the ability if it is ready and does not exist on target
			call OkayToAttack "${Iterator.Key}"
			if ${Return} && ${Me.Ability[${Iterator.Key}].IsReady} && !${Me.TargetMyDebuff[${Iterator.Key}](exists)}
			{
				if ${Me.Ability[${Iterator.Key}].BloodUnionRequired} > ${Me.BloodUnion}
				{
					echo "Not Enough Blood Union for ${Iterator.Key}, Required=${Me.Ability[${Iterator.Key}].BloodUnionRequired}, Have=${Me.BloodUnion}"
					Iterator:Next
				}
				if ${Me.Ability[${Iterator.Key}].IsCounter} || ${Me.Ability[${Iterator.Key}].IsChain}
				{
					if ${Me.Ability[${Iterator.Key}].TriggeredCountdown}==0
					{
						echo ${Iterator.Key} - Counter/Chain - Skipping
						Iterator:Next
					}
				}
				call UseAbility "${Iterator.Key}"
			}
			Iterator:Next
		}
	}
}


;===================================================
;===               Use Ability                  ====
;===================================================
function:bool UseAbility(string ABILITY)
{
	if !${Me.Ability[${ABILITY}](exists)} || ${Me.Ability[${ABILITY}].LevelGranted}>${Me.Level}
	{
		echo "${ABILITY} does not exist or too high a level to use"
		return FALSE
	}
	
	;-------------------------------------------
	; These have priority over everything
	;-------------------------------------------
	call CounterIt
	call StripIt
	call PushStance
	call SorcCrits
	call RangerCrits
	call NecroCrits
	
	;-------------------------------------------
	; execute ability only if it is ready
	;-------------------------------------------
	if ${Me.Ability[${ABILITY}].IsReady}
	{
		;; no hate abilities
		;if !${doHate} && (${Me.Ability[${ABILITY}].Description.Find[hate]} || ${Me.Ability[${ABILITY}].Description.Find[hatred]})
		if !${doHate} && ${Hate_Abilities.Element["${ABILITY}"](exists)}
		{
			return FALSE
		}
	
		;; return if we do not have enough energy
		if ${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.Ability[${ABILITY}].EnergyCost}>${Me.Energy}
		{
			;echo "Not enought Energy for ${ABILITY}"
			return FALSE
		}
		;; return if we do not have enough Endurance
		if ${Me.Ability[${ABILITY}].EnduranceCost(exists)} && ${Me.Ability[${ABILITY}].EnduranceCost}>${Me.Endurance}
		{
			;echo "Not enought Endurance for ${ABILITY}"
			return FALSE
		}
		if ${Me.Effect[${ABILITY}](exists)}
			return FALSE
		if ${Me.TargetMyDebuff[${ABILITY}](exists)}
			return FALSE
		if ${Pawn[me].IsMounted}
			return FALSE

		Me.Ability[${ABILITY}]:Use
		call IsCasting
		EchoIt "UseAbility (${ABILITY})"
		return TRUE
	}
	return FALSE
}

;===================================================
;===               Use Ability                  ====
;===================================================
function:bool ForceAbility(string ABILITY)
{
	if !${Me.Ability[${ABILITY}](exists)} || ${Me.Ability[${ABILITY}].LevelGranted}>${Me.Level}
	{
		echo "${ABILITY} does not exist or too high a level to use"
		return FALSE
	}
	
	;-------------------------------------------
	; execute ability only if it is ready
	;-------------------------------------------
	if ${Me.Ability[${ABILITY}].IsReady}
	{
		;; no hate abilities
		;if !${doHate} && (${Me.Ability[${ABILITY}].Description.Find[hate]} || ${Me.Ability[${ABILITY}].Description.Find[hatred]})
		if !${doHate} && ${Hate_Abilities.Element["${ABILITY}"](exists)}
		{
			return FALSE
		}
	
		;; return if we do not have enough energy
		if ${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.Ability[${ABILITY}].EnergyCost}>${Me.Energy}
		{
			;echo "Not enought Energy for ${ABILITY}"
			return FALSE
		}
		;; return if we do not have enough Endurance
		if ${Me.Ability[${ABILITY}].EnduranceCost(exists)} && ${Me.Ability[${ABILITY}].EnduranceCost}>${Me.Endurance}
		{
			;echo "Not enought Endurance for ${ABILITY}"
			return FALSE
		}
		if ${Pawn[me].IsMounted}
			return FALSE

		Me.Ability[${ABILITY}]:Use
		call IsCasting
		EchoIt "UseAbility (${ABILITY})"
		return TRUE
	}
	return FALSE
}


;===================================================
;===               Use Items                    ====
;===================================================
function:bool UseAbilityNoCoolDown(string ABILITY)
{
	if !${Me.Ability[${ABILITY}](exists)} || ${Me.Ability[${ABILITY}].LevelGranted}>${Me.Level}
	{
		echo "${ABILITY} does not exist or too high a level to use"
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
			;echo "Not enought Energy for ${ABILITY}"
			return FALSE
		}
		;; return if we do not have enough Endurance
		if ${Me.Ability[${ABILITY}].EnduranceCost(exists)} && ${Me.Ability[${ABILITY}].EnduranceCost}>${Me.Endurance}
		{
			;echo "Not enought Endurance for ${ABILITY}"
			return FALSE
		}
		if ${Me.TargetMyDebuff[${ABILITY}](exists)}
			return FALSE
		if ${Pawn[me].IsMounted}
			return FALSE

		Me.Ability[${ABILITY}]:Use
		wait 5
		EchoIt "UseAbility (${ABILITY})"
		
		if ${ABILITY.Equal[${HoT}]}
			HoTMemberList:Set["${Me.DTarget.Name.Token[1," "]}", ${Math.Calc[${Script.RunningTime}+17000]}]
		
		return TRUE
	}
	return FALSE
}

;===================================================
;===               Use Items                    ====
;===================================================
function UseItems()
{
	call OkayToAttack
	if ${Return} && ${doUseItems} && !${isPaused} && ${isRunning}
	{	
		;
		; Make sure every item you plan on using is on one of your Hot Bars;
		; otherwise, it will not equip it and skip to the next item
		;
		variable iterator Iterator
		Items:GetSettingIterator[Iterator]

		;; keep looping until we reached the last item used
		while ${Iterator.Key(exists)} && !${LastItemUsed.Equal[${Iterator.Key}]}
		{
			Iterator:Next
		}

		;; get the next one
		Iterator:Next
		
		;; if it doesn't exist then reset to the 1st one
		if !${Iterator.Key(exists)}
		{
			Iterator:First
		}

		while ${Iterator.Key(exists)} && !${isPaused} && ${isRunning} && !${Me.Target.IsDead}
		{
			if ${Me.Inventory[${Iterator.Key}].IsReady}
			{
				;
				; The following checks will cause the system to crash over time;
				; is it needed, only if you do not want many error messages
				;
				if ${Me.Inventory[${Iterator.Key}].Type.Equal[Weapon]} || ${Me.Inventory[${Iterator.Key}].Type.Equal[Shield]} || ${Me.Inventory[${Iterator.Key}].Type.Equal[Instrument]}
				{
					;
					; save our current equiped itemes
					;
					if ${Me.Inventory[CurrentEquipSlot,Primary Hand](exists)}
					{
						LastPrimary:Set[${Me.Inventory[CurrentEquipSlot,Primary Hand]}]
					}
					if ${Me.Inventory[CurrentEquipSlot,Secondary Hand](exists)}
					{
						LastSecondary:Set[${Me.Inventory[CurrentEquipSlot,Secondary Hand]}]
					}
					if ${Me.Inventory[CurrentEquipSlot,Two Hands](exists)}
					{
						LastPrimary:Set[${Me.Inventory[CurrentEquipSlot,Two Hands]}]
						LastSecondary:Set[${LastPrimary}]
					}
					
					;
					; use the item if already equiped
					;
					if ${LastPrimary.Equal[${Iterator.Key}]} || ${LastSecondary.Equal[${Iterator.Key}]}
					{
						Me.Inventory[${Iterator.Key}]:Use
						LastItemUsed:Set[${Iterator.Key}]
						wait 2
						Iterator:Next
						continue
					}
					
					;
					; otherwise, equip the item, use it, then equip old items
					;
					Me.Inventory[${Iterator.Key}]:Equip
					wait 2
					Me.Inventory[${Iterator.Key}]:Use
					LastItemUsed:Set[${Iterator.Key}]
					wait 2
					
					if ${LastPrimary.Equal[${LastSecondary}]}
					{
						Me.Inventory[${LastSecondary}]:Equip[Secondary Hand]
						Me.Inventory[${LastPrimary}]:Equip[Primary Hand]
						wait 2
					}
					else
					{
						Me.Inventory[${LastPrimary}]:Equip[Primary Hand]
						wait 2
					}
					return
				}
				else
				{
					;; sometimes th
					Me.Inventory[${Iterator.Key}]:Use
					LastItemUsed:Set[${Iterator.Key}]
					wait 2
				}
			}
			Iterator:Next
		}
	}
}

;===================================================
;===           FORAGE SUBROUTINE                ====
;===================================================
function Forage()
{
	if ${doForage} && ${Forage.Equal[Forage]}
	{
		;; we in combat so set the flag and return
		if ${Me.InCombat} || ${Me.Encounter}>0
		{
			return
		}

		;; go ahead and forage the area
		call UseAbility "${Forage}"
		wait 10 ${Me.IsLooting}
		if ${Me.IsLooting}
		{
			Loot:LootAll
			wait 2
			if ${Me.IsLooting}
			{
				Loot:EndLooting
			}
			Okay2Forage:Set[FALSE]
		}
	}
}
	
;===================================================
;===          BUFF AREA SUBROUTINE              ====
;===================================================
function BuffArea()
{
	;-------------------------------------------
	; Start/Stop our BuffArea script
	;-------------------------------------------
	if ${Script[Tools_BuffArea](exists)}
	{
		endscript Tools_BuffArea
	}
	elseif !${Script[Tools_BuffArea](exists)}
	{
		run ./Tools/Tools_BuffArea.iss TRUE
	}
}


;===================================================
;===       FORCE BUFF AREA SUBROUTINE           ====
;===================================================
function ForceBuffArea()
{
	;-------------------------------------------
	; Start/Stop our BuffArea script
	;-------------------------------------------
	if ${Script[Tools_BuffArea](exists)}
	{
		endscript Tools_BuffArea
	}
	elseif !${Script[Tools_BuffArea](exists)}
	{
		run ./Tools/Tools_BuffArea.iss FALSE
	}
}


;===================================================
;===        BUFF REQUESTS SUBROUTINE            ====
;===================================================
function BuffRequests()
{
	if ${Me.IsCasting} || ${VG.InGlobalRecovery} || !${Tools.AreWeReady}
	{
		return
	}

	if ${Tools_BuffRequestList.FirstKey(exists)}
	{
		variable iterator Iterator
		variable bool WeBuffed
		variable bool Okay2Buff = FALSE
		variable string Temp
		
		do
		{
			if ${Pawn[name,${Tools_BuffRequestList.CurrentKey}](exists)} && ${Pawn[name,${Tools_BuffRequestList.CurrentKey}].Distance}<25 && ${Pawn[name,${Tools_BuffRequestList.CurrentKey}].HaveLineOfSightTo}
			{
				;; set our Iterator to BuffOnly
				BuffOnly:GetSettingIterator[Iterator]

				;; if nothing is in the buffonly list then might as well we buff everyone
				if !${Iterator.Key(exists)}
				{
					Okay2Buff:Set[TRUE]
				}
				
				;; cycle through all our BuffOnly checking if they exist by name or by guild
				while ${Iterator.Key(exists)}
				{
					;; Using a Key in a find does not work, but saving to a variable does
					Temp:Set[${Iterator.Key}]
					if ${Pawn[name,${Tools_BuffRequestList.CurrentKey}].Name.Find[${Temp}]} || ${Pawn[name,${Tools_BuffRequestList.CurrentKey}].Title.Find[${Temp}]}
					{
						Okay2Buff:Set[TRUE]
						break
					}
					Iterator:Next
				}
				
				if ${Okay2Buff}
				{
					Pawn[name,${Tools_BuffRequestList.CurrentKey}]:Target
					wait 3
					wait 10 ${Me.DTarget.Name.Find[${Tools_BuffRequestList.CurrentKey}]}
					
					if ${Me.DTarget.Name.Find[${Tools_BuffRequestList.CurrentKey}]}
					{
						;; set out Iterator to TriggerBuffs
						TriggerBuffs:GetSettingIterator[Iterator]
						
						;; set our flagg to we have not buffed anyone
						WeBuffed:Set[FALSE]
						
							
						;; cycle through all our trigger buffs to ensure we casted them
						while ${Iterator.Key(exists)} && !${isPaused} && ${isRunning}
						{
							Temp:Set[${Iterator.Key}]
							if !${Me.DTarget(exists)} || ${Me.DTarget.Distance}>25
								break
							if !${Tools.AreWeReady}
							{
								while !${Tools.AreWeReady} && ${Me.DTarget(exists)} && ${Me.DTarget.Distance}<25
									wait frame
								wait 3
							}
							
							EchoIt "*Buffing ${Me.DTarget.Name} - ${Temp}"
									
							;; cast the buff
							if ${Me.Ability[${Temp}].IsReady}
							{
								call ForceAbility "${Temp}"
								if ${Return}
								{
									WeBuffed:Set[TRUE]
								}
							}
							Iterator:Next
						}
								
						;; announce we buffed someone
						if ${WeBuffed}
						{
							vgecho "Buffed: ${Tools_BuffRequestList.CurrentKey}"
						}
					}
				}
			}
		}
		while ${Tools_BuffRequestList.NextKey(exists)}
		Tools_BuffRequestList:Clear
	}
}

;===================================================
;===              Change Form                   ====
;===================================================
function ChangeForm()
{
	if ${Me.InCombat}
	{
		if !${Me.CurrentForm.Name.Equal[${CombatForm}]}
		{
			Me.Form[${CombatForm}]:ChangeTo
			wait .5
		}
		return
	}
	if !${Me.CurrentForm.Name.Equal[${NonCombatForm}]}
	{
		Me.Form[${NonCombatForm}]:ChangeTo
		wait .5
	}
}

;===================================================
;===           REZ ACCEPT SUB-ROUTINE           ====
;===================================================
function RezAccept()
{
	if ${doAcceptRez}
	{
		;; Accept that rez
		VGExecute "/rezaccept"

		;; allow time to relocate after accepting rez
		wait 40
		
		;; target our nearest corpse
		VGExecute "/targetmynearestcorpse"
		wait 10
		
		;; drag it closer if we are still out of range
		if ${Me.Target.Distance}>5 && ${Me.Target.Distance}<21
		{
			VGExecute "/corpsedrag"
			wait 10 ${Me.Target.Distance}<=5
		}
		
		;; loot our tombstone and clear our target
		VGExecute "/lootall"
		waitframe
		VGExecute "/cleartargets"
		waitframe
		
		vgecho "Accepted Rez and Looted my tombstone"
		doAcceptRez:Set[FALSE]
	}
}

;===================================================
;===           AUTO REPAIR SUB-ROUTINE          ====
;===================================================
function RepairEquipment()
{
	if ${doAutoRepairs}
	{
		;; check once every other second
		if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${RepairTimer}]}/1000]}<1
		{
			return
		}

		;; reset the timer
		RepairTimer:Set[${Script.RunningTime}]
		
		;; total items in inventory
		variable int TotalItems = 0
		
		;; define our index
		variable index:item CurentItems
		
		;; populate our index and update total items in inventory
		TotalItems:Set[${Me.GetInventory[CurentItems]}]

		;; counter
		variable int i = 0

		;; Essence of Replenishment
		if ${Pawn[Essence of Replenishment](exists)}
		{
			if ${Pawn[Essence of Replenishment].Distance}<5
			{
				;; loop through all items checking durability
				for (i:Set[1] ; ${i}<=${TotalItems} ; i:Inc)
				{
					if ${CurentItems.Get[${i}].Durability}>=0 && ${CurentItems.Get[${i}].Durability}<95
					{
						Pawn[Essence of Replenishment]:Target
						wait 10 ${Me.Target.Name.Find[Replenishment]}
						if ${Me.Target.Name.Find[Replenishment]}
						{
							Merchant:Begin[Repair]
							wait 3
							Merchant:RepairAll
							Merchant:End
							vgecho Repaired equipment
							VGExecute "/cleartargets"
						}
						return
					}
				}
			}
		}

		;; Merchant Djinn
		if ${Pawn[Merchant Djinn](exists)}
		{
			if ${Pawn[Merchant Djinn].Distance}<5
			{
				;; loop through all items checking durability
				for (i:Set[1] ; ${i}<=${TotalItems} ; i:Inc)
				{
					if ${CurentItems.Get[${i}].Durability}>=0 && ${CurentItems.Get[${i}].Durability}<95
					{
						Pawn[Merchant Djinn]:Target
						wait 10 ${Me.Target.Name.Find[Merchant Djinn]}
						if ${Me.Target.Name.Find[Merchant Djinn]}
						{
							Merchant:Begin[Repair]
							wait 3
							Merchant:RepairAll
							Merchant:End
							vgecho Repaired equipment
							VGExecute "/cleartargets"
						}
						return
					}
				}
			}
		}
		;; Reparitron 5703
		if ${Pawn[Reparitron 5703](exists)}
		{
			if ${Pawn[Reparitron 5703].Distance}<5
			{
				;; loop through all items checking durability
				for (i:Set[1] ; ${i}<=${TotalItems} ; i:Inc)
				{
					if ${CurentItems.Get[${i}].Durability}>=0 && ${CurentItems.Get[${i}].Durability}<95
					{
						Pawn[Reparitron 5703]:Target
						wait 10 ${Me.Target.Name.Find[Reparitron 5703]}
						if ${Me.Target.Name.Find[Reparitron 5703]}
						{
							Merchant:Begin[Repair]
							wait 3
							Merchant:RepairAll
							Merchant:End
							vgecho Repaired equipment
							VGExecute "/cleartargets"
						}
						return
					}
				}
			}
		}
		
		;; Merchant
		if ${Me.Target.Type.Equal[Merchant]}
		{
			;; loop through all items checking durability
			for (i:Set[1] ; ${i}<=${TotalItems} ; i:Inc)
			{
				if ${CurentItems.Get[${i}].Durability}>=0 && ${CurentItems.Get[${i}].Durability}<95
				{
					echo Repairing  ${CurentItems.Get[${i}].Name}
					Merchant:Begin[Repair]
					wait 3
					Merchant:RepairAll
					Merchant:End
					vgecho Repaired equipment
					return
				}
			}
		}
	}
}

;===================================================
;===        FOLLOW TANK SUB-ROUTINE             ====
;===================================================
function FollowTank()
{
	if ${doFollow}
	{
		if ${Pawn[exactname,${Tank}](exists)}
		{
			if ${FollowDistance1}<1
				FollowDistance1:Set[1]
				
			if ${FollowDistance2}<=${FollowDistance1}
				FollowDistance2:Set[${Math.Calc[${FollowDistance1}+1]}]
				
			;; did target move out of rang?
			if ${Pawn[exactname,${Tank}].Distance}>${FollowDistance2}
			{
				variable bool DidWeMove = FALSE
				
				;; start moving until target is within range
				while !${isPaused} && ${doFollow} && ${Pawn[exactname,${Tank}](exists)} && ${Pawn[exactname,${Tank}].Distance}>=${FollowDistance1} && ${Pawn[exactname,${Tank}].Distance}<80
				{
					Pawn[exactname,${Tank}]:Face
					VG:ExecBinding[moveforward]
					DidWeMove:Set[TRUE]
				}
				;; if we moved then we want to stop moving
				if ${DidWeMove}
				{
					waitframe
					VG:ExecBinding[moveforward,release]
					waitframe
				}
			}
		}
	}
}

;===================================================
;===         UI Tools for Abilities             ====
;===================================================
atom(global) Tools_AddAbilities(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[DPS].FindSet[Abilities-${Me.FName}]:AddSetting[${aName}, ${aName}]

	}
}
atom(global) Tools_RemoveAbilities(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Abilities.FindSetting[${aName}]:Remove
	}
}
atom(global) Tools_BuildAbilities()
{
	variable iterator Iterator
	Abilities:GetSettingIterator[Iterator]
	UIElement[AbilitiesList@Abilities@DPS@Tools]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[AbilitiesList@Abilities@DPS@Tools]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	variable int i = 0
	Abilities:Clear
	while ${i:Inc} <= ${UIElement[AbilitiesList@Abilities@DPS@Tools].Items}
	{
		
		LavishSettings[DPS].FindSet[Abilities-${Me.FName}]:AddSetting[${UIElement[AbilitiesList@Abilities@DPS@Tools].Item[${i}].Text}, ${UIElement[AbilitiesList@Abilities@DPS@Tools].Item[${i}].Text}]
	}
}

;===================================================
;===         UI Tools for Items                 ====
;===================================================
atom(global) Tools_AddItems(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[DPS].FindSet[Items-${Me.FName}]:AddSetting[${aName}, ${aName}]
	}
}
atom(global) Tools_RemoveItems(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Items.FindSetting[${aName}]:Remove
	}
}
atom(global) Tools_BuildItems()
{
	variable iterator Iterator
	Items:GetSettingIterator[Iterator]
	UIElement[ItemsList@Abilities@DPS@Tools]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[ItemsList@Abilities@DPS@Tools]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	variable int i = 0
	Items:Clear
	while ${i:Inc} <= ${UIElement[ItemsList@Abilities@DPS@Tools].Items}
	{
		LavishSettings[DPS].FindSet[Items-${Me.FName}]:AddSetting[${UIElement[ItemsList@Abilities@DPS@Tools].Item[${i}].Text}, ${UIElement[ItemsList@Abilities@DPS@Tools].Item[${i}].Text}]
	}
}

;===================================================
;===         UI Tools for Buffs                 ====
;===================================================
atom(global) Tools_AddBuff(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[DPS].FindSet[Buffs-${Me.FName}]:AddSetting[${aName}, ${aName}]
	}
}
atom(global) Tools_RemoveBuff(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Buffs.FindSetting[${aName}]:Remove
	}
}
atom(global) Tools_BuildBuffs()
{
	variable iterator Iterator
	Buffs:GetSettingIterator[Iterator]
	UIElement[BuffsList@Abilities@DPS@Tools]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[BuffsList@Abilities@DPS@Tools]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	variable int i = 0
	Buffs:Clear
	while ${i:Inc} <= ${UIElement[BuffsList@Abilities@DPS@Tools].Items}
	{
		LavishSettings[DPS].FindSet[Buffs-${Me.FName}]:AddSetting[${UIElement[BuffsList@Abilities@DPS@Tools].Item[${i}].Text}, ${UIElement[BuffsList@Abilities@DPS@Tools].Item[${i}].Text}]
	}
}

;===================================================
;===         UI Tools for Buff Only             ====
;===================================================
atom(global) Tools_AddBuffOnly(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[DPS].FindSet[BuffOnly-${Me.FName}]:AddSetting[${aName}, ${aName}]
	}
}
atom(global) Tools_RemoveBuffOnly(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		BuffOnly.FindSetting[${aName}]:Remove
	}
}
atom(global) Tools_BuildBuffsOnly()
{
	variable iterator Iterator
	BuffOnly:GetSettingIterator[Iterator]
	UIElement[BuffOnlyList@BuffBot@DPS@Tools]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[BuffOnlyList@BuffBot@DPS@Tools]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	variable int i = 0
	BuffOnly:Clear
	while ${i:Inc} <= ${UIElement[BuffOnlyList@BuffBot@DPS@Tools].Items}
	{
		LavishSettings[DPS].FindSet[BuffOnly-${Me.FName}]:AddSetting[${UIElement[BuffOnlyList@BuffBot@DPS@Tools].Item[${i}].Text}, ${UIElement[BuffOnlyList@BuffBot@DPS@Tools].Item[${i}].Text}]
	}
}

;===================================================
;===        UI Tools for Build Forms            ====
;===================================================
atom(global) Tools_BuildForms()
{
	variable int i
	for (i:Set[1] ; ${i} <= ${UIElement[CombatForm@Abilities@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[CombatForm@Abilities@DPS@Tools].Item[${i}].Text.Equal[${CombatForm}]}
		{
			UIElement[CombatForm@Abilities@DPS@Tools]:SelectItem[${i}]
		}
	}
	for (i:Set[1] ; ${i} <= ${UIElement[NonCombatForm@Abilities@DPS@Tools].Items} ; i:Inc)
	{
		if ${UIElement[NonCombatForm@Abilities@DPS@Tools].Item[${i}].Text.Equal[${NonCombatForm}]}
		{
			UIElement[NonCombatForm@Abilities@DPS@Tools]:SelectItem[${i}]
		}
	}
}

;===================================================
;===         UI Tools for Trigger Buffs         ====
;===================================================
atom(global) Tools_AddTriggerBuff(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[DPS].FindSet[TriggerBuffs-${Me.FName}]:AddSetting[${aName}, ${aName}]
	}
}
atom(global) Tools_RemoveTriggerBuff(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		TriggerBuffs.FindSetting[${aName}]:Remove
	}
}
atom(global) Tools_BuildTriggerBuffs()
{
	variable iterator Iterator
	TriggerBuffs:GetSettingIterator[Iterator]
	UIElement[TriggerBuffsList@BuffBot@DPS@Tools]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		if !${Iterator.Key.Equal[NULL]}
		{
			UIElement[TriggerBuffsList@BuffBot@DPS@Tools]:AddItem[${Iterator.Key}]
		}
		Iterator:Next
	}
	variable int i = 0
	TriggerBuffs:Clear
	while ${i:Inc} <= ${UIElement[TriggerBuffsList@BuffBot@DPS@Tools].Items}
	{
		LavishSettings[DPS].FindSet[TriggerBuffs-${Me.FName}]:AddSetting[${UIElement[TriggerBuffsList@BuffBot@DPS@Tools].Item[${i}].Text}, ${UIElement[TriggerBuffsList@BuffBot@DPS@Tools].Item[${i}].Text}]
	}
}

;===================================================
;===         UI Tools for Counters1             ====
;===================================================
atom(global) Tools_AddCounter1(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[DPS].FindSet[Counters1-${Me.FName}]:AddSetting[${aName}, ${aName}]
	}
}
atom(global) Tools_RemoveCounter1(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Counters1.FindSetting[${aName}]:Remove
	}
}
atom(global) Tools_BuildCounter1()
{
	variable iterator Iterator
	Counters1:GetSettingIterator[Iterator]
	UIElement[Counter1List@Counters@DPS@Tools]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		if !${Iterator.Key.Equal[NULL]}
		{
			UIElement[Counter1List@Counters@DPS@Tools]:AddItem[${Iterator.Key}]
		}
		Iterator:Next
	}
	variable int i = 0
	Counters1:Clear
	while ${i:Inc} <= ${UIElement[Counter1List@Counters@DPS@Tools].Items}
	{
		LavishSettings[DPS].FindSet[Counters1-${Me.FName}]:AddSetting[${UIElement[Counter1List@Counters@DPS@Tools].Item[${i}].Text}, ${UIElement[Counter1List@Counters@DPS@Tools].Item[${i}].Text}]
	}
}

;===================================================
;===         UI Tools for Counters2             ====
;===================================================
atom(global) Tools_AddCounter2(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[DPS].FindSet[Counters2-${Me.FName}]:AddSetting[${aName}, ${aName}]
	}
}
atom(global) Tools_RemoveCounter2(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Counters2.FindSetting[${aName}]:Remove
	}
}
atom(global) Tools_BuildCounter2()
{
	variable iterator Iterator
	Counters2:GetSettingIterator[Iterator]
	UIElement[Counter2List@Counters@DPS@Tools]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		if !${Iterator.Key.Equal[NULL]}
		{
			UIElement[Counter2List@Counters@DPS@Tools]:AddItem[${Iterator.Key}]
		}
		Iterator:Next
	}
	variable int i = 0
	Counters2:Clear
	while ${i:Inc} <= ${UIElement[Counter2List@Counters@DPS@Tools].Items}
	{
		LavishSettings[DPS].FindSet[Counters2-${Me.FName}]:AddSetting[${UIElement[Counter2List@Counters@DPS@Tools].Item[${i}].Text}, ${UIElement[Counter2List@Counters@DPS@Tools].Item[${i}].Text}]
	}
}

objectdef Obj_Commands
{
	;; identify the Passive Ability
	variable string PassiveAbility = "Racial Inheritance:"
	variable int TankGN

	;; initialize when objectdef is created
	method Initialize()
	{
		variable int i
		for (i:Set[1] ; ${Me.Ability[${i}](exists)} ; i:Inc)
		{
			if ${Me.Ability[${i}].Name.Find[Racial Inheritance:]}
				This.PassiveAbility:Set[${Me.Ability[${i}].Name}]
		}
	}

	;; called when script is shut down
	method Shutdown()
	{
	}

	;; external command
	member:bool AreWeReady()
	{
		if ${Me.Ability[${This.PassiveAbility}].IsReady}
			return TRUE
		return FALSE
	}
	
	member:bool AreWeEating()
	{
		variable int i
		for (i:Set[1]; ${Me.Effect[${i}](exists)}; i:Inc)
		{
			if ${Me.Effect[${i}].IsBeneficial}
			{
				if ${Me.Effect[${i}].Description.Find[Health:]} && ${Me.Effect[${i}].Description.Find[Energy:]} && ${Me.Effect[${i}].Description.Find[over]} && ${Me.Effect[${i}].Description.Find[seconds]}
					return TRUE
			}
		}
		return FALSE
	}
	
	member:int TankHealth(string Tank)
	{
		if ${Tank.Find[${Me.FName}]}
			return ${Me.HealthPct}
		
		if ${Me.IsGrouped}
		{
			if ${Tank.Find[${Group[${This.TankGN}].Name}]}
				return ${Group[${This.TankGN}].Health}
			
			variable int i
			for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
			{
				if ${Tank.Find[${Group[${i}].Name}]}
				{
					This.TankGN:Set[${i}]
					return ${Group[${This.TankGN}].Health}
				}
			}
		}
		return 100
	}
}
variable(global) Obj_Commands Tools

;===================================================
;===   SUBROUTINE - FIND GROUP MEMBERS          ====
;===================================================
function FindGroupMembers()
{
	if !${doFindGroupMembers}
		return
		
	;; reset our variables
	GroupMemberList:Clear
	doFindGroupMembers:Set[FALSE]
	
	if ${Me.IsGrouped}
	{
		for (i:Set[1]; ${i}<=6; i:Inc)
		{
			;; Clear our Target
			VGExecute /cleartargets
			wait 1 !${Me.DTarget(exists)}
			
			;; Target a Group Member (1-6)
			VGExecute "/targetgroupmember ${i}"
			wait 1 ${Me.DTarget(exists)}
			
			;; Add Name to GroupMemberList
			if ${Me.DTarget(exists)}
			{
				GroupMemberList:Set["${Me.DTarget.Name.Token[1," "]}", ${Me.DTarget.ID}]
				vgecho "Group Member[${i}] = ${Me.DTarget.Name}"
			}
			
			if !${Me.DTarget(exists)}
				vgecho "Group Member[${i}] = does not exist"
		}
	}
}

;===================================================
;===   SUBROUTINE - Harvest Target              ====
;===================================================
function HarvestIt()
{
	if !${doHarvest}
		return
		
	if !${Me.Target(exists)}
	{
		;-------------------------------------------
		; Populate our CurrentPawns variable
		;-------------------------------------------
		variable int TotalPawns
		variable index:pawn CurrentPawns
		variable bool doHarvestItem = FALSE
		variable int Distance = ${HarvestRange}

		TotalPawns:Set[${VG.GetPawns[CurrentPawns]}]

		;-------------------------------------------
		; Cycle through 30 nearest Pawns in area that are AggroNPC
		;-------------------------------------------
		for (i:Set[1];  ${i}<=${TotalPawns} && ${CurrentPawns.Get[${i}].Distance}<${Distance};  i:Inc)
		{
			;vgecho [${i}] [Harvestable=${CurrentPawns.Get[${i}].IsHarvestable(exists)}] [Type=${CurrentPawns.Get[${i}].Type}] [Name=${CurrentPawns.Get[${i}].Name}]
			;; next if we've blacklisted the target
			if ${HarvestBlackList.Element[${CurrentPawns.Get[${i}].ID}](exists)}
				continue
	
			;; next if it is not harvestable
			if !${CurrentPawns.Get[${i}].IsHarvestable(exists)}
				continue
				
			if ${CurrentPawns.Get[${i}].Type.Equal[Corpse]} || ${CurrentPawns.Get[${i}].Type.Equal[Resource]}
			{
				;; Lumberjacking
				if ${CurrentPawns.Get[${i}].Name.Find[Tree]} || ${CurrentPawns.Get[${i}].Name.Find[Root]}
				{
					if ${Me.Stat[Harvesting,Lumberjacking]}>0 && ${CurrentPawns.Get[${i}].Name.Find[Weakened]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Lumberjacking]}>=100 && ${CurrentPawns.Get[${i}].Name.Find[Barbed]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Lumberjacking]}>=200 && ${CurrentPawns.Get[${i}].Name.Find[Dry]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Lumberjacking]}>=300 && ${CurrentPawns.Get[${i}].Name.Find[Knotted]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Lumberjacking]}>=400 && ${CurrentPawns.Get[${i}].Name.Find[Dusky]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Lumberjacking]}>=500 && ${CurrentPawns.Get[${i}].Name.Find[Aged]}
						doHarvestItem:Set[TRUE]
				}
				
				;; Skinning
				if ${Me.Stat[Harvesting,Skinning]}>0 && ${CurrentPawns.Get[${i}].Type.Equal[Corpse]}
					doHarvestItem:Set[TRUE]
					
				;; Reaping
				if ${CurrentPawns.Get[${i}].Name.Find[Plant]}
				{
					if ${Me.Stat[Harvesting,Reaping]}>0 && ${CurrentPawns.Get[${i}].Name.Find[Jute]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Reaping]}>=100 && ${CurrentPawns.Get[${i}].Name.Find[Cotton]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Reaping]}>=200 && ${CurrentPawns.Get[${i}].Name.Find[Firegrass]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Reaping]}>=300 && ${CurrentPawns.Get[${i}].Name.Find[Silkbloom]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Reaping]}>=400 && ${CurrentPawns.Get[${i}].Name.Find[Vielthread]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Reaping]}>=500 && ${CurrentPawns.Get[${i}].Name.Find[Steelweave]}
						doHarvestItem:Set[TRUE]
				}
				
				;; Mining
				if ${CurrentPawns.Get[${i}].Name.Find[Node]} || ${CurrentPawns.Get[${i}].Name.Find[Vein]}
				{
					if ${Me.Stat[Harvesting,Mining]}>0 && ${CurrentPawns.Get[${i}].Name.Equal[Metal Node]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Mining]}>=100 && ${CurrentPawns.Get[${i}].Name.Equal[Large Metal Node]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Mining]}>=200 && ${CurrentPawns.Get[${i}].Name.Equal[Rich Metal Node]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Mining]}>=300 && ${CurrentPawns.Get[${i}].Name.Equal[Metal Vein]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Mining]}>=400 && ${CurrentPawns.Get[${i}].Name.Equal[Large Metal Vein]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Mining]}>=500 && ${CurrentPawns.Get[${i}].Name.Equal[Rich Metal Vein]}
						doHarvestItem:Set[TRUE]
				}
				
				;; Quarrying
				if ${CurrentPawns.Get[${i}].Name.Find[Cluster]} || ${CurrentPawns.Get[${i}].Name.Find[Deposit]}
				{
					if ${Me.Stat[Harvesting,Quarrying]}>0 && ${CurrentPawns.Get[${i}].Name.Equal[Small Mineral Cluster]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Quarrying]}>=100 && ${CurrentPawns.Get[${i}].Name.Equal[Medium Mineral Cluster]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Quarrying]}>=200 && ${CurrentPawns.Get[${i}].Name.Equal[Large Mineral Cluster]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Quarrying]}>=300 && ${CurrentPawns.Get[${i}].Name.Equal[Small Mineral Deposit]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Quarrying]}>=400 && ${CurrentPawns.Get[${i}].Name.Equal[Medium Mineral Deposit]}
						doHarvestItem:Set[TRUE]
					if ${Me.Stat[Harvesting,Quarrying]}>=500 && ${CurrentPawns.Get[${i}].Name.Equal[Large Mineral Deposit]}
						doHarvestItem:Set[TRUE]
				}
			}
	
				
			;; we only want corpses or resources
			if ${doHarvestItem}
			{
				;; target it and blacklist target from future scans
				Pawn[id,${CurrentPawns.Get[${i}].ID}]:Target
				wait 3
				HarvestBlackList:Set[${Me.Target.ID},${Me.Target.ID}]
				break
			}
		}
	}
	
	if !${Me.Target(exists)}
		return
		
	if !${Me.Target.IsHarvestable}
		return
		
	variable string leftofname
	leftofname:Set[${Me.Target.Name.Left[6]}]
	if ${Me.Target.Distance}>5 && ${Me.Target.Distance}<${Distance} && ${Me.ToPawn.CombatState}==0 && !${leftofname.Equal[remain]}
	{
		while ${Me.Target.Distance}>=15
		{
			VG:ExecBinding[moveforward]
			face ${Me.Target.X} ${Me.Target.Y}
			if !${Me.Target(exists)} || !${isRunning} || ${isPaused}
					break
		}

		;; change posture to walking
		if ${Me.Target.Distance}>=4
			VGExecute /walk
		
		;; loop until target doesn't exist or inside 4 meters
		while ${Me.Target.Distance}>=4
		{
			VG:ExecBinding[moveforward]
			face ${Me.Target.X} ${Me.Target.Y}
			if !${Me.Target(exists)} || !${isRunning} || ${isPaused}
					break
		}

		;; stop moving forward
		VG:ExecBinding[moveforward,release]

		;; change our posture back to running
		VGExecute /run
	}

	if !${Me.InCombat} && ${Me.Target(exists)} && ${Me.Target.Distance}<5 && ${Me.Target.IsHarvestable}
	{
		Me.Ability[Auto Attack]:Use
		wait 10
	}

	if ${Me.InCombat} && ${Me.Encounter}==0
	{
		HarvestBlackList:Set[${Me.Target.ID},${Me.Target.ID}]
		while ${Me.InCombat} && ${Me.Encounter}==0
			waitframe
		VGExecute "/cleartargets"
		wait 3
	}	

	if !${GV[bool,bHarvesting]} && ${Me.Ability[Auto Attack].Toggled}
	{
		VGExecute /autoattack
		wait 10
		VGExecute "/cleartargets"
	}
	
	VGExecute "/hidewindow Harvesting"
	VGExecute "/hidewindow Bonus Yield"
	
	if ${Me.InCombat}
		return

	for (i:Set[0] ; ${Me.Inventory[${i:Inc}].Name(exists)} ; )
	{
		if ${Me.Inventory[${i}].Description.Find[resource]} && ${Me.Inventory[${i}].Type.Equal[Miscellaneous]} && ${Me.Inventory[${i}].Quantity}>=20
		{
			EchoIt "Consolidate: ${Me.Inventory[${i}]}"
			Me.Inventory[${i}]:StartConvert
			wait 10
			VG:ConvertItem
			wait 10
		}
	}
}

function Tombstone()
{
	if !${Me.Target(exists)} && ${Pawn[Tombstone,range,25].Name.Find[${Me.FName}](exists)}
	{
		VGExecute "/targetmynearestcorpse"
		wait 5
	}
	if ${Me.Target(exists)} && ${Me.Target.Name.Find[Tombstone]} && ${Me.Target.Name.Find[${Me.FName}]}
	{
		VGExecute "/corpsedrag"
		VGExecute "/lootall"
		wait 5
	}
}

function ManageHeals()
{
	;; update our group members
	if ${doFindGroupMembers}
		call FindGroupMembers
	
	;; This will force the ability to become ready before continuing
	;; so that we do not miss a heal
	call ReadyCheck	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Group Healing
	if ${Me.IsGrouped}
	{
		variable int GroupNumber = 0
		variable int LowestHealth = 100
		variable int Range = 0
		variable int TotalWounded = 0
		variable bool isGroupMember = FALSE
		GroupNumber:Set[0]
		LowestHealth:Set[100]
		Range:Set[0]
		isGroupMember:Set[FALSE]
		TotalWounded:Set[0]


		for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
		{
			if ${GroupMemberList.Element["${Group[${i}].Name}"](exists)}
			{
				if ${Group[${i}].Distance}<10 && ${Group[${i}].Health}>0 && ${Group[${i}].Health}<=${GroupHealPct}
				{
					TotalWounded:Inc
					isGroupMember:Set[TRUE]
				}
			}
		}
		
		;; Scan only group members
		if ${doGroupOnly}
		{
			for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
			{
				if ${GroupMemberList.Element["${Group[${i}].Name}"](exists)}
				{
					if ${Group[${i}].Distance}<30 && ${Group[${i}].Health}>0 && ${Group[${i}].Health}<=${LowestHealth}
					{
						GroupNumber:Set[${i}]
						LowestHealth:Set[${Group[${i}].Health}]
						Range:Set[${Group[${i}].Distance}]
						isGroupMember:Set[TRUE]
					}
				}
			}
		}
		else
		{
			for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
			{
				if ${Group[${i}].Distance}<30 && ${Group[${i}].Health}>0 && ${Group[${i}].Health}<=${LowestHealth}
				{
					GroupNumber:Set[${i}]
					LowestHealth:Set[${Group[${i}].Health}]
					Range:Set[${Group[${i}].Distance}]
					if ${GroupMemberList.Element["${Group[${i}].Name}"](exists)}
						isGroupMember:Set[TRUE]
				}
			}
		}
		
		if ${doGroupHeal} && ${TotalWounded}>3
		{
			call UseAbilityNoCoolDown "${GroupHeal}"
			return
		}
		
		if ${doBigHeal} && ${BigHealPct}>${LowestHealth}
		{
			if !${Group[${GroupNumber}].Name.Find[${Me.DTarget.Name}]}
			{
				Pawn[id,${Group[${GroupNumber}].ID}]:Target
				waitframe
			}
			call UseAbilityNoCoolDown "${BigHeal}"
			return
		}
		
		if ${doInstantHeal} && ${InstantHealPct}>${LowestHealth}
		{
			if !${Group[${GroupNumber}].Name.Find[${Me.DTarget.Name}]}
			{
				Pawn[id,${Group[${GroupNumber}].ID}]:Target
				waitframe
			}
			call UseAbilityNoCoolDown "${InstantHeal}"
			return
		}
		
		if ${doSmallHeal} && ${SmallHealPct}>${LowestHealth}
		{
			if !${Group[${GroupNumber}].Name.Find[${Me.DTarget.Name}]}
			{
				Pawn[id,${Group[${GroupNumber}].ID}]:Target
				waitframe
			}
			call UseAbilityNoCoolDown "${SmallHeal}"
			return
		}
		
		if ${doHoT} && ${HoTPct}>${LowestHealth}
		{
			if !${HoTMemberList.Element["${Group[${GroupNumber}].Name.Token[1," "]}"](exists)} || (${HoTMemberList.Element["${Group[${GroupNumber}].Name.Token[1," "]}"](exists)} && ${Script.RunningTime} > ${HoTMemberList.Element["${Group[${GroupNumber}].Name.Token[1," "]}"]})
			{
				if !${Group[${GroupNumber}].Name.Find[${Me.DTarget.Name}]}
				{
					Pawn[id,${Group[${GroupNumber}].ID}]:Target
					waitframe
				}
				call UseAbilityNoCoolDown "${HoT}"
				return
			}
		}
	}
	
	if !${Me.IsGrouped}
	{
		if ${doBigHeal} && ${BigHealPct}>${Me.HealthPct}
		{
			if !${Group[${GroupNumber}].Name.Find[${Me.DTarget.Name}]}
			{
				Pawn[me]:Target
				waitframe
			}
			call UseAbilityNoCoolDown "${BigHeal}"
			return
		}
		
		if ${doInstantHeal} && ${InstantHealPct}>${Me.HealthPct}
		{
			if !${Group[${GroupNumber}].Name.Find[${Me.DTarget.Name}]}
			{
				Pawn[me]:Target
				waitframe
			}
			call UseAbilityNoCoolDown "${InstantHeal}"
			return
		}

		if ${doSmallHeal} && ${SmallHealPct}>${Me.HealthPct}
		{
			if !${Group[${GroupNumber}].Name.Find[${Me.DTarget.Name}]}
			{
				Pawn[me]:Target
				waitframe
			}
			call UseAbilityNoCoolDown "${SmallHeal}"
			return
		}
		
		if ${doHoT} && ${HoTPct}>${Me.HealthPct}
		{
			if !${Group[${GroupNumber}].Name.Find[${Me.DTarget.Name}]}
			{
				Pawn[me]:Target
				waitframe
			}
			call UseAbilityNoCoolDown "${HoT}"
			return
		}
	}
}

function ManageTanks()
{
	call OkayToAttack
	if !${Return}
		return
		
	if ${Me.Class.Equal[Warrior]} || ${Me.Class.Equal[Paladin]} || ${Me.Class.Equal[Dread Knight]}
	{
		variable int j
		variable string TargetOnWho
		variable bool doRescue = FALSE

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Grab Targets not on me
		if ${Me.IsGrouped} && (${doRescue1} || ${doRescue2} || ${doRescue3} || ${doReduceHate})
		{
			if ${doCheckEncounters} && ${Me.Encounter}>0
			{
				;;always grab encounters on any group members
				for ( i:Set[1] ; ${i}<=${Me.Encounter} ; i:Inc )
				{
					;; is target on me?
					if !${Me.Encounter[${i}].Target.Find[${Me.FName}]}
					{
						;; is target within 10m of me?
						if ${Me.Encounter[${i}].Health}>0 && ${Me.Encounter[${i}].Distance}<10
						{
							;; save who the target is on
							TargetOnWho:Set[${Me.Encounter[${i}].Target}]
							
							;; scan group members
							for ( j:Set[1] ; ${Group[${j}].ID(exists)} ; j:Inc )
							{
								;; is there a match?
								if ${Group[${j}].Name.Find[${TargetOnWho}]}
								{
									;; make sure it is not a tank
									if !${Group[${j}].Class.Equal[Warrior]} && !${Group[${j}].Class.Equal[Dread Knight]} && !${Group[${j}].Class.Equal[Paladin]}
									{
										EchoIt "Grabbing: ${Me.Encounter[${i}].Name} who's on ${TargetOnWho} (${Group[${j}].Class})"
										doRescue:Set[TRUE]
										Pawn[ID,${Me.Encounter[${i}].ID}]:Target
										wait 1
										VGExecute /assistoffensive
										wait 1
										Me.Target:Face
										break
									}
								}
							}
						}
					}
				}
			}
			
			if ${Me.Target(exists)} && ${Me.ToT(exists)} && ${Me.Target.Distance}<10
			{
				;; save who the target is on
				TargetOnWho:Set[${Me.ToT}]
				
				;; scan group members
				for ( j:Set[1] ; ${Group[${j}].ID(exists)} ; j:Inc )
				{
					;; is there a match?
					if ${Group[${j}].Name.Find[${TargetOnWho}]}
					{
						;; make sure it is not a tank
						if !${Group[${j}].Class.Equal[Warrior]} && !${Group[${j}].Class.Equal[Dread Knight]} && !${Group[${j}].Class.Equal[Paladin]}
						{
							EchoIt "RESCUE:  My target is on ${TargetOnWho} (${Group[${j}].Class})"
							doRescue:Set[TRUE]
							VGExecute /assistoffensive
							wait 1
							break
						}
					}
				}

				;; rescue our DTarget
				;if ${doRescue} && !${Me.Target.IsDead} && !${Me.ToT.Name.Find[${Me.FName}]} && !${Me.TargetBuff["Immunity: Force Target"](exists)}
				if !${Me.Target.IsDead} && !${Me.ToT.Name.Find[${Me.FName}]} && !${Me.TargetBuff["Immunity: Force Target"](exists)}
				{
					call ReadyCheck	
					
					;; reduce DTarget's hate
					if ${doReduceHate}
					{
						if ${Me.DTarget.Name(exists)} && ${Me.Ability[${ReduceHate}].IsReady}
							call UseAbility "${ReduceHate}"
					}

					if ${doRescue1} && ${Me.Ability[${Rescue1}].IsReady}
					{
						if ${Me.DTarget.Name(exists)} && ${Me.Ability[${Rescue1}].IsReady}
						{
							call UseAbility "${Rescue1}"
							return
						}
					}
					if ${doRescue2} && ${Me.Ability[${Rescue2}].IsReady}
					{
						if ${Me.DTarget.Name(exists)} && ${Me.Ability[${Rescue2}].IsReady}
						{
							call UseAbility "${Rescue2}"
							return
						}
					}
					if ${doRescue3} && ${Me.Ability[${Rescue3}].IsReady}
					{
						if ${Me.DTarget.Name(exists)} && ${Me.Ability[${Rescue3}].IsReady}
						{
							call UseAbility "${Rescue3}"
							return
						}
					}
				}
				
				;; increase our hate
				if ${doIncreaseHate}
					call UseAbility "${IncreaseHate}"
			}
		}
	}
}

function Loot()
{
	if ${doLoot}
	{
		if ${Me.IsLooting}
		{
			LastLootID:Set[${Me.Target.ID}]
			VGExecute "/LootAll"
			wait 3
			if ${Me.IsLooting}
				Loot:EndLooting
			VGExecute "/cleartargets"
			wait 3
			return
		}
		
		if !${Me.Target(exists)}
		{
			;-------------------------------------------
			; Populate our CurrentPawns variable
			;-------------------------------------------
			variable int TotalPawns
			variable index:pawn CurrentPawns

			TotalPawns:Set[${VG.GetPawns[CurrentPawns]}]

			;-------------------------------------------
			; Cycle through 30 nearest Pawns in area that are AggroNPC
			;-------------------------------------------
			for (i:Set[1];  ${i}<=${TotalPawns} && ${CurrentPawns.Get[${i}].Distance}<5;  i:Inc)
			{
				if ${LootBlackList.Element[${CurrentPawns.Get[${i}].ID}](exists)}
					continue
		
				;; next if it is not harvestable
				if ${CurrentPawns.Get[${i}].ContainsLoot} || ${CurrentPawns.Get[${i}].Name.Find["remains of"](exists)}
				{
					;; we only want corpses or resources
					if ${CurrentPawns.Get[${i}].Type.Equal[Corpse]} || ${CurrentPawns.Get[${i}].Type.Equal[Resource]}
					{
						;; target it and blacklist target from future scans
						Pawn[id,${CurrentPawns.Get[${i}].ID}]:Target
						wait 3
						LootBlackList:Set[${Me.Target.ID},${Me.Target.ID}]
						break
					}
				}
			}
		}

		if !${Me.Target(exists)}
			return
		
		if ${Me.Target.ContainsLoot} || ${Me.Target.Name.Find["remains of"](exists)}
		{
			LootBlackList:Set[${Me.Target.ID},${Me.Target.ID}]
			VGExecute "/LootAll"
			wait 3
			if ${Me.IsLooting}
				Loot:EndLooting
		}
		
		if ${Me.Target.IsDead}
		{
			VGExecute "/cleartargets"
			wait 3
		}
	}
}