;===================================================
;===            VARIABLES                       ====
;===================================================

;; Script variables
variable int i
variable bool isRunning = TRUE
variable bool doStripEnchantments = TRUE
variable bool doCounter1 = TRUE
variable bool doCounter2 = TRUE
variable bool doPushStance = TRUE
variable string StripThisEnchantment
variable string StripEnchantment1
variable string Counter1
variable string Counter2
variable string StancePush1
variable int NextDelayCheck = ${Script.RunningTime}

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
		call CounterIt
		
		;-------------------------------------------
		; 1/2 Second Delay creates
		;-------------------------------------------
		if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextDelayCheck}]}/500]}>1
		{
			NextDelayCheck:Set[${Script.RunningTime}]
			call StripIt
			call PushStance
		}
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;   S U B R O U T I N E S   ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;===================================================
;===     ATEXIT - called when the script ends   ====
;===================================================
function atexit()
{
	;; Unload our UI
	ui -unload "${Script.CurrentDirectory}/Tools.xml"
	
	;; Say we are done
	EchoIt "Stopped Tools Script"
}

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
			StripEnchantment1:Set[Strip Enchantment]
			StancePush1:Set[None]
			break
		
		Psionicist
			Counter1:Set[Nullifying Field]
			Counter2:Set[Psychic Mutation]
			StripEnchantment1:Set[None]
			StancePush1:Set[None]
			break

		case Sorceror
			Counter1:Set[Disperse]
			Counter2:Set[Reflect]
			StripEnchantment1:Set[Disenchant]
			StancePush1:Set[None]
			break
			
		case Dread Knight
			Counter1:Set[None]
			Counter2:Set[None]
			StripEnchantment1:Set[Despoil]
			StancePush1:Set[None]
			break

		case Disciple
			Counter1:Set[None]
			Counter2:Set[None]
			StripEnchantment1:Set[None]
			StancePush1:Set[Stance Wheel]
			break
			
		case Druid
			Counter1:Set[Dissipate]
			Counter2:Set[Healing Turn]
			StripEnchantment1:Set[None]
			StancePush1:Set[None]
			break

		case Bard
			Counter1:Set[None]
			Counter2:Set[None]
			StripEnchantment1:Set[Asilam's Disenchanting Cry]
			StancePush1:Set[None]
			break

		case Necromancer 
			Counter1:Set[Annul Magic]
			Counter2:Set[None]
			StripEnchantment1:Set[None]
			StancePush1:Set[None]
			break

		Default
			Counter1:Set[None]
			Counter2:Set[None]
			StripEnchantment1:Set[None]
			StancePush1:Set[None]
			break
	}
	
	;-------------------------------------------
	; Calculate Highest Level
	;-------------------------------------------
	SetHighestAbility "CounterA" "${Counter1}"
	SetHighestAbility "CounterB" "${Counter2}"
	SetHighestAbility "StripEnchantment" "${StripEnchantment1}"
	SetHighestAbility "StancePush" "${StancePush1}"

	;-------------------------------------------
	;; Reload the UI and draw our Tool window
	;-------------------------------------------
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	ui -reload -skin VGSkin "${Script.CurrentDirectory}/Tools.xml"

	;-------------------------------------------
	; Enable Events - these events are automatically removed at shutdown
	;-------------------------------------------
	Event[VG_OnIncomingText]:AttachAtom[ChatEvent]	
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
	redirect -append "${LavishScript.CurrentDirectory}/Scripts/Parse/Chat-${ChannelNumber}.txt" echo "[${Time}][${ChannelNumber}][(${Me.TargetHealth})${Me.Target.Name}][${aText}]"
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
		waitframe
	}
}

;===================================================
;===       I AM CASTING SUB-ROUTINE             ====
;===================================================
function IsCasting()
{
	wait 5
	while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
	{
		waitframe
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
	; in order to counter we have to be able to ID the ability
	if !${Me.TargetCasting.Equal[None]}
	{
		if ${doCounter1}
		{
			if ${Me.Ability[${CounterA}].IsReady} && ${Me.Ability[${CounterA}].TimeRemaining}==0
			{
				;vgecho "${Counter1}:  ${Me.TargetCasting}"
				VGExecute "/reactioncounter 1"
				call GlobalCooldown
			}
		}
		if ${doCounter2}
		{
			if ${Me.Ability[${CounterB}].IsReady} && ${Me.Ability[${CounterB}].TimeRemaining}==0
			{
				;vgecho "${Counter2}:  ${Me.TargetCasting}"
				VGExecute "/reactioncounter 2"
				call GlobalCooldown
			}
		}
	}
}

;===================================================
;=== STRIP IT - this will remove an enchantment ====
;===================================================
function StripIt()
{
	if ${doStripEnchantments}
	{
		if ${Me.Target(exists)} && ${Me.Target.HaveLineOfSightTo}
		{
			if ${Me.Ability[${StripEnchantment}].IsReady}
			{
				variable bool doStripIt = FALSE
			
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
				if ${doStripIt}
				{
					Me.Ability[${StripEnchantment}]:Use
					Call IsCasting

					;; check to see enchantment was removed
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
	if ${doPushStance}
	{
	}
}
