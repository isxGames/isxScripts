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
;  * Added Buffs, Forms, and Randed Attack. Priority are Counters, Strip Enchantments,
;    and Push Stance.
;
; 20111027 (Zandros)
;  * Added my 1st class tab.  Currently, I added the Bard Class tab.  Nothing much
;    but it was a lot of coding.  Basically, if you are a Bard then you can set what
;    song you want and what weapons you want to equip the moment you are in combat.
;    Once you are out of combat and someone is wounded then you you can establish
;    what Rest song and Instrument you want.  Finally, if everyone is fully healed,
;    then it will default to the song you identify for travel and equip the appropriate
;    intrument.  
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
;===================================================
;===            VARIABLES                       ====
;===================================================

;; Script variables
variable int i
variable bool isRunning = TRUE
variable bool isPaused = FALSE
variable int NextDelayCheck = ${Script.RunningTime}
variable int RepairTimer = ${Script.RunningTime}

;; UI/Script toggle variables
variable bool doUseAbilities = TRUE
variable bool doUseItems = TRUE
variable bool doCounter1 = TRUE
variable bool doCounter2 = TRUE
variable bool doPushStance = TRUE
variable bool doStripEnchantments = TRUE
variable bool doAutoAttack = TRUE
variable bool doRangedAttack = TRUE
variable bool doFace = FALSE
variable bool doAutoRepairs = TRUE
variable bool doAutoRez = TRUE
variable bool doAcceptRez = FALSE
variable bool doGroupsay = FALSE
variable bool doRaidsay = FALSE
variable bool doTells = FALSE
variable bool doRift = FALSE
variable bool doFollow = FALSE
variable bool doMonotorTells = FALSE
variable string TriggerBuffing = ""
variable string Tank = Unknown
variable string CombatForm = NONE
variable string NonCombatForm = NONE
variable int StartAttack = 99

;; Bard stuff
variable string CombatSong = CombatSong
variable string PrimaryWeapon = PrimaryWeapon
variable string SecondaryWeapon = SecondaryWeapon
variable string RestSong = RestSong
variable string RestInstrument = RestInstrument
variable string TravelSong = TravelSong
variable string TravelInstrument = TravelInstrument

;; Ability name variables
variable string Counter1
variable string Counter2
variable string PushStance1
variable string StripEnchantment1

;; XML variables used to store and save data
variable settingsetref General
variable settingsetref Abilities
variable settingsetref Items
variable settingsetref Buffs
variable settingsetref TriggerBuffs
variable settingsetref BuffOnly

;; Equipment variables
variable string LastPrimary
variable string LastSecondary
variable string LastItemUsed

;; BuffBot variables
variable string PCName
variable string PCNameFull
variable(global) collection:string Tools_BuffRequestList
variable string BuffOnlyName = ""

;; Follow variables
variable int FollowDistance1 = 3
variable int FollowDistance2 = 5

;; Class Specific Routines
#include ./Tools/Class/Bard.iss
#include ./Tools/Class/Sorcerer.iss

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
	
	;-------------------------------------------
	; CLASS SPECIFIC Routines
	;-------------------------------------------
	call Bard
	call Sorcerer
	
	;-------------------------------------------
	; loop this until we exit the script
	;-------------------------------------------
	do
	{
	
		;; this allows AutoAttack to kick in
		wait .5
		
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
			call AssistTank
			call ChangeForm
			call FollowTank
			call BuffRequests
			call RepairEquipment

			;; Class Specific Routines - do these first before doing combat stuff
			call Bard
			call Sorcerer
		
			;; we only want targets that are not a Resource and not dead
			if ${Me.Target(exists)} && !${Me.Target.Type.Equal[Resource]} && !${Me.Target.IsDead}
			{
				;; execute each of these
				call StripIt
				call CounterIt
				call PushStance
				call RangedAttack
				call AutoAttack
				call UseAbilities
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

	LavishSettings[DPS]:Import[${Script.CurrentDirectory}/Tools_save.xml]
	
	General:Set[${LavishSettings[DPS].FindSet[General-${Me.FName}].GUID}]
	Abilities:Set[${LavishSettings[DPS].FindSet[Abilities-${Me.FName}].GUID}]
	Items:Set[${LavishSettings[DPS].FindSet[Items-${Me.FName}].GUID}]
	Buffs:Set[${LavishSettings[DPS].FindSet[Buffs-${Me.FName}].GUID}]
	TriggerBuffs:Set[${LavishSettings[DPS].FindSet[TriggerBuffs-${Me.FName}].GUID}]
	BuffOnly:Set[${LavishSettings[DPS].FindSet[BuffOnly-${Me.FName}].GUID}]

	doUseAbilities:Set[${General.FindSetting[doUseAbilities,TRUE]}]
	doUseItems:Set[${General.FindSetting[doUseItems,FALSE]}]
	doCounter1:Set[${General.FindSetting[doCounter1,TRUE]}]
	doCounter2:Set[${General.FindSetting[doCounter2,TRUE]}]
	doPushStance:Set[${General.FindSetting[doPushStance,TRUE]}]
	doStripEnchantments:Set[${General.FindSetting[doStripEnchantments,TRUE]}]
	doAutoAttack:Set[${General.FindSetting[doAutoAttack,TRUE]}]
	doRangedAttack:Set[${General.FindSetting[doRangedAttack,TRUE]}]
	doFace:Set[${General.FindSetting[doFace,TRUE]}]
	doAutoRepairs:Set[${General.FindSetting[doAutoRepairs,TRUE]}]
	doAutoRez:Set[${General.FindSetting[doAutoRez,TRUE]}]
	CombatForm:Set[${General.FindSetting[CombatForm,"NONE"]}]
	NonCombatForm:Set[${General.FindSetting[NonCombatForm,"NONE"]}]
	StartAttack:Set[${General.FindSetting[StartAttack,99]}]
	doGroupsay:Set[${General.FindSetting[doGroupsay,FALSE]}]
	doRaidsay:Set[${General.FindSetting[doRaidsay,FALSE]}]
	doTells:Set[${General.FindSetting[doTells,FALSE]}]
	doRift:Set[${General.FindSetting[doRift,TRUE]}]
	TriggerBuffing:Set[${General.FindSetting[TriggerBuffing,""]}]
	FollowDistance1:Set[${General.FindSetting[FollowDistance1,3]}]
	FollowDistance2:Set[${General.FindSetting[FollowDistance2,5]}]
	doMonotorTells:Set[${General.FindSetting[doMonotorTells,TRUE]}]
	
	;; Class Specific - Bard
	CombatSong:Set[${General.FindSetting[CombatSong]}]
	PrimaryWeapon:Set[${General.FindSetting[PrimaryWeapon]}]
	SecondaryWeapon:Set[${General.FindSetting[SecondaryWeapon]}]
	RestSong:Set[${General.FindSetting[RestSong]}]
	RestInstrument:Set[${General.FindSetting[RestInstrument]}]
	TravelSong:Set[${General.FindSetting[TravelSong]}]
	TravelInstrument:Set[${General.FindSetting[TravelInstrument]}]

	;-------------------------------------------
	; Reload the UI and draw our Tool window
	;-------------------------------------------
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	ui -reload -skin VGSkin "${Script.CurrentDirectory}/Tools.xml"

	;-------------------------------------------
	; Update UI from the XML Data
	;-------------------------------------------
	variable int i
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		UIElement[AbilitiesCombo@Abilities@DPS@Tools]:AddItem[${Me.Ability[${i}].Name}]
		if !${Me.Ability[${i}].IsOffensive} && !${Me.Ability[${i}].Type.Equal[Combat Art]} && !${Me.Ability[${i}].IsChain} && !${Me.Ability[${i}].IsCounter} && !${Me.Ability[${i}].IsRescue} && !${Me.Ability[${i}].Type.Equal[Song]}
		{
			if ${Me.Ability[${i}].TargetType.Equal[Self]} || ${Me.Ability[${i}].TargetType.Equal[Defensive]} || ${Me.Ability[${i}].TargetType.Equal[Group]} || ${Me.Ability[${i}].TargetType.Equal[Ally]}
			{
				UIElement[BuffsCombo@Abilities@DPS@Tools]:AddItem[${Me.Ability[${i}].Name}]
				UIElement[TriggerBuffsCombo@BuffBot@DPS@Tools]:AddItem[${Me.Ability[${i}].Name}]
			}
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
			if ${Me.Inventory[${i}].Type.Equal[Weapon]}
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
	General:AddSetting[doPushStance,${doPushStance}]
	General:AddSetting[doStripEnchantments,${doStripEnchantments}]
	General:AddSetting[doRangedAttack,${doRangedAttack}]
	General:AddSetting[doAutoAttack,${doAutoAttack}]
	General:AddSetting[doFace,${doFace}]
	General:AddSetting[doAutoRepairs,${doAutoRepairs}]
	General:AddSetting[doAutoRez,${doAutoRez}]
	General:AddSetting[CombatForm,${CombatForm}]
	General:AddSetting[NonCombatForm,${NonCombatForm}]
	General:AddSetting[StartAttack,${StartAttack}]
	General:AddSetting[doGroupsay,${doGroupsay}]
	General:AddSetting[doRaidsay,${doRaidsay}]
	General:AddSetting[doTells,${doTells}]
	General:AddSetting[doRift,${doRift}]
	General:AddSetting[doMonotorTells,${doMonotorTells}]
	General:AddSetting[FollowDistance1,${FollowDistance1}]
	General:AddSetting[FollowDistance2,${FollowDistance2}]
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
	echo "[${Time}][Tools]: ${aText}"
}

;===================================================
;===       ATOM - PawnSpawned                   ====
;===================================================
atom(script) PawnSpawned(string aID, string aName, string aLevel, string aType)
{
	if ${doRift} && !${aType.Find[NPC]}
	{
		;; ID, Level and Type sometimes generates 0 or NULL
		EchoIt "[${aID}], lvl=${aLevel}, ${aName}, ${aType}"
		PCName:Set[${aName.Token[1," "]}]
		Tools_BuffRequestList:Set["${PCName}", "Buff"]
	}
}

;===================================================
;===       ATOM - Monitor Chat Event            ====
;===================================================
atom(script) ChatEvent(string aText, string ChannelNumber, string ChannelName)
{
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
	while ${VG.InGlobalRecovery} || !${Me.Ability["Torch"].IsReady}
	{
		call AutoAttack
	}
	call UseItems
}

;===================================================
;===       I AM CASTING SUB-ROUTINE             ====
;===================================================
function IsCasting()
{
	wait 5
	while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady} || ${VG.InGlobalRecovery}
	{
		call CounterIt
		call AutoAttack
	}
	call UseItems
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
		declare	${AbilityVariable} string script "${ABILITY}"
		return
	}

	;-------------------------------------------
	; Otherwise, new Ability is named "None"
	;-------------------------------------------
	declare	${AbilityVariable} string script "None"
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
			if ${doCounter1}
			{
				if ${Me.Ability[${CounterA}].IsReady} && ${Me.Ability[${CounterA}].TimeRemaining}==0
				{
					VGExecute "/reactioncounter 1"
					wait 1
					call GlobalCooldown
				}
			}
			if ${doCounter2}
			{
				if ${Me.Ability[${CounterB}].IsReady} && ${Me.Ability[${CounterB}].TimeRemaining}==0
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
function:bool OkayToAttack()
{
	if (!${Me.IsGrouped} || ${Me.InCombat} || ${Pawn[Name,${Tank}].CombatState}>0) && ${Me.Target(exists)} && !${Me.Target.IsDead} && (${Me.Target.Type.Find[NPC]} || ${Me.Target.Type.Equal[AggroNPC]}) && ${Me.TargetHealth}<=${StartAttack}
	{
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
			call UseAbility "${Iterator.Key}"
		}
		Iterator:Next
	}
}

;===================================================
;===        ASSIST TANK SUBROUTINE              ====
;===================================================
function AssistTank()
{
	;; we want to assist the tank
	if !${Me.Target(exists)} || (${Me.Target(exists)} && ${Me.Target.IsDead})
	{
		wait 5
		if ${Pawn[Name,${Tank}](exists)}
		{
			;; assist the tank only if the tank is in combat and less than 50 meters away
			if ${Pawn[Name,${Tank}].CombatState}>0 && ${Pawn[Name,${Tank}].Distance}<=50
			{
				EchoIt "Assisting ${Tank}"
				VGExecute /cleartargets
				waitframe
				VGExecute "/assist ${Tank}"
				waitframe
				wait 20 ${Me.TargetHealth}>0
			}
		}
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
			;; Use the ability if it is ready and does not exist on target or myself
			call OkayToAttack
			;if ${Return} && ${Me.Ability[${Iterator.Key}].IsReady} && !${Me.TargetMyDebuff[${Iterator.Key}](exists)} && !${Me.Effect[${Iterator.Key}](exists)}
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
;===               Use Items                    ====
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

		Me.Ability[${ABILITY}]:Use
		call IsCasting
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
					wait 1
					Me.Inventory[${Iterator.Key}]:Use
					LastItemUsed:Set[${Iterator.Key}]
					wait 2
					
					if ${LastPrimary.Equal[${LastSecondary}]}
					{
						Me.Inventory[${LastPrimary}]:Equip[Primary Hand]
						wait 1
					}
					else
					{
						Me.Inventory[${LastPrimary}]:Equip[Primary Hand]
						Me.Inventory[${LastSecondary}]:Equip[Secondary Hand]
						wait 1
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
;===        BUFF AREA SUBROUTINE                ====
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
	if !${Me.Ability["Torch"].IsReady}
	{
		return
	}

	if ${Tools_BuffRequestList.FirstKey(exists)}
	{
		variable iterator Iterator
		variable bool WeBuffed
		variable bool Okay2Buff = FALSE
		
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
					if ${Pawn[name,${Tools_BuffRequestList.CurrentKey}].Name.Find[${Iterator.Key}]} || ${Pawn[name,${Tools_BuffRequestList.CurrentKey}].Title.Find[${Iterator.Key}]}
					{
						Okay2Buff:Set[TRUE]
					}
					Iterator:Next
				}
				
				if ${Okay2Buff}
				{
					Pawn[name,${Tools_BuffRequestList.CurrentKey}]:Target
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
							do
							{
								if !${Me.DTarget(exists)} || ${Me.DTarget.Distance}>25
								{
									break
								}
								waitframe
							}
							while ${Me.IsCasting} || ${VG.InGlobalRecovery} || !${Me.Ability["Torch"].IsReady}
									
							;; cast the buff
							if ${Me.Ability[${Iterator.Key}].IsReady}
							{
								call UseAbility "${Iterator.Key}"
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
		if ${Pawn[name,${Tank}](exists)}
		{
			;; did target move out of rang?
			if ${Pawn[name,${Tank}].Distance}>=${FollowDistance2}
			{
				variable bool DidWeMove = FALSE
				;; start moving until target is within range
				while !${isPaused} && ${doFollow} && ${Pawn[name,${Tank}](exists)} && ${Pawn[name,${Tank}].Distance}>=${FollowDistance1} && ${Pawn[name,${Tank}].Distance}<45
				{
					Pawn[name,${Tank}]:Face
					VG:ExecBinding[moveforward]
					DidWeMove:Set[TRUE]
					wait .25
				}
				;; if we moved then we want to stop moving
				if ${DidWeMove}
				{
					VG:ExecBinding[moveforward,release]
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
