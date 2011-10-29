;-----------------------------------------------------------------------------------------------
; Tools.iss 
;
; Description - a small tool
; -----------
; * Cycles through list of selected abilities
; * Cycles through list of items to use
; * Swaps weapons instantly to use item abilities (-clickies-)
; * Preconfigure Counters, Strip Enchantments, and Push Stance
; * Auto Attack turns on and off
;
; Revision History
; ----------------
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

;; Equipment variables
variable string LastPrimary
variable string LastSecondary

;; Class Specific Routines
#include ./Tools/Class/Bard.iss

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
	
	;-------------------------------------------
	; loop this until we exit the script
	;-------------------------------------------
	do
	{
		;; this allows AutoAttack to kick in
		wait 5
		
		if !${isPaused}
		{
			;; Always check these
			call AssistTank
			call ChangeForm
			call StripIt

			;; Class Specific Routines - do these first before doing combat stuff
			call Bard
		
			;; we only want targets that are not a Resource and not dead
			if ${Me.Target(exists)} && !${Me.Target.Type.Equal[Resource]} && !${Me.Target.IsDead}
			{
				;; execute each of these
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
		
		Psionicist
			Counter1:Set[Nullifying Field]
			Counter2:Set[Psychic Mutation]
			PushStance1:Set[None]
			StripEnchantment1:Set[None]
			break

		case Sorceror
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

	LavishSettings[DPS]:Import[${Script.CurrentDirectory}/Tools_save.xml]
	
	General:Set[${LavishSettings[DPS].FindSet[General-${Me.FName}].GUID}]
	Abilities:Set[${LavishSettings[DPS].FindSet[Abilities-${Me.FName}].GUID}]
	Items:Set[${LavishSettings[DPS].FindSet[Items-${Me.FName}].GUID}]
	Buffs:Set[${LavishSettings[DPS].FindSet[Buffs-${Me.FName}].GUID}]

	doUseAbilities:Set[${General.FindSetting[doUseAbilities,TRUE]}]
	doUseItems:Set[${General.FindSetting[doUseItems,FALSE]}]
	doCounter1:Set[${General.FindSetting[doCounter1,TRUE]}]
	doCounter2:Set[${General.FindSetting[doCounter2,TRUE]}]
	doPushStance:Set[${General.FindSetting[doPushStance,TRUE]}]
	doStripEnchantments:Set[${General.FindSetting[doStripEnchantments,TRUE]}]
	doAutoAttack:Set[${General.FindSetting[doAutoAttack,TRUE]}]
	doRangedAttack:Set[${General.FindSetting[doRangedAttack,TRUE]}]
	doFace:Set[${General.FindSetting[doFace,TRUE]}]
	CombatForm:Set[${General.FindSetting[CombatForm,"NONE"]}]
	NonCombatForm:Set[${General.FindSetting[NonCombatForm,"NONE"]}]
	StartAttack:Set[${General.FindSetting[StartAttack,99]}]

	
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
	BuildItems
	BuildAbilities
	BuildForms
	BuildBuffs

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
}

;===================================================
;===     ATEXIT - called when the script ends   ====
;===================================================
function atexit()
{
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
	General:AddSetting[CombatForm,${CombatForm}]
	General:AddSetting[NonCombatForm,${NonCombatForm}]
	General:AddSetting[StartAttack,${StartAttack}]

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
;===       ATOM - Monitor Chat Event            ====
;===================================================
atom(script) ChatEvent(string aText, string ChannelNumber, string ChannelName)
{
	if ${ChannelNumber}==0 && ${aText.Find[You can't attack with that type of weapon.]}
	{
		EchoIt "[${ChannelNumber}]${aText}"
		doAutoAttack:Set[FALSE]
		UIElement[doAutoAttack@Abilities@DPS@Tools]:UnsetChecked
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
					call GlobalCooldown
				}
			}
			if ${doCounter2}
			{
				if ${Me.Ability[${CounterB}].IsReady} && ${Me.Ability[${CounterB}].TimeRemaining}==0
				{
					VGExecute "/reactioncounter 2"
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
	if (${Me.InCombat} || ${Pawn[Name,${Tank}].CombatState}>0) && ${Me.Target(exists)} && !${Me.Target.IsDead} && (${Me.Target.Type.Find[NPC]} || ${Me.Target.Type.Equal[AggroNPC]}) && ${Me.TargetHealth}<=${StartAttack}
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
				waitframe
				if ${Me.Inventory[CurrentEquipSlot,"Primary Hand"].Type.Equal[Weapon]} || ${Me.Inventory[CurrentEquipSlot,"Two Hand"].Type.Equal[Weapon]}
				{
					waitframe
					vgecho "Turning AutoAttack ON"
					Me.Ability[Auto Attack]:Use
					wait 10 ${GV[bool,bIsAutoAttacking]} && ${Me.Ability[Auto Attack].Toggled}
					return
				}
				doWeaponCheck:Set[FALSE]
			}
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
	doWeaponCheck:Set[TRUE]
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
	Buffs:GetSettingIterator[Iterator]
	while ${Iterator.Key(exists)} && !${isPaused} && ${isRunning}
	{
		;; Use the abilit if it is ready and does not exist on target or myself
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
			if ${Return} && ${Me.Ability[${Iterator.Key}].IsReady} && !${Me.TargetMyDebuff[${Iterator.Key}](exists)} && !${Me.Effect[${Iterator.Key}](exists)}
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
function UseAbility(string ABILITY)
{
	if !${Me.Ability[${ABILITY}](exists)} || ${Me.Ability[${ABILITY}].LevelGranted}>${Me.Level}
	{
		echo "${ABILITY} does not exist or too high a level to use"
		return
	}
	
	;-------------------------------------------
	; These have priority over everything
	;-------------------------------------------
	call CounterIt
	call StripIt
	call PushStance
	
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
	}
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
		while ${Iterator.Key(exists)} && !${isPaused} && ${isRunning} && !${Me.Target.IsDead}
		{
			if ${Me.Inventory[${Iterator.Key}].IsReady}
			{
				if ${Me.Inventory[${Iterator.Key}].Type.Equal[Weapon]} || ${Me.Inventory[${Iterator.Key}].Type.Equal[Shield]} || ${Me.Inventory[${Iterator.Key}].Type.Equal[Instrument]}
				{
					;
					; The above checks will cause the system to crash over time;
					; is it needed, only if you do not want many error messages
					;
					waitframe
					LastPrimary:Set[${Me.Inventory[CurrentEquipSlot,Primary Hand]}]
					LastSecondary:Set[${Me.Inventory[CurrentEquipSlot,Secondary Hand]}]
					Me.Inventory[${Iterator.Key}]:Equip
					Me.Inventory[${Iterator.Key}]:Use
					if ${LastPrimary.Equal[LastSecondary]}
					{
						Me.Inventory[${LastPrimary}]:Equip[Primary Hand]
					}
					else
					{
						Me.Inventory[${LastPrimary}]:Equip[Primary Hand]
						Me.Inventory[${LastSecondary}]:Equip[Secondary Hand]
					}
				}
				else
				{
					Me.Inventory[${Iterator.Key}]:Use
				}
			}
			waitframe
			Iterator:Next
		}
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
;===         UI Tools for Abilities             ====
;===================================================
atom(global) AddAbilities(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[DPS].FindSet[Abilities-${Me.FName}]:AddSetting[${aName}, ${aName}]

	}
}
atom(global) RemoveAbilities(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Abilities.FindSetting[${aName}]:Remove
	}
}
atom(global) BuildAbilities()
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
atom(global) AddItems(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[DPS].FindSet[Items-${Me.FName}]:AddSetting[${aName}, ${aName}]
	}
}
atom(global) RemoveItems(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Items.FindSetting[${aName}]:Remove
	}
}
atom(global) BuildItems()
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
atom(global) AddBuff(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[DPS].FindSet[Buffs-${Me.FName}]:AddSetting[${aName}, ${aName}]
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

atom(global) BuildForms()
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


