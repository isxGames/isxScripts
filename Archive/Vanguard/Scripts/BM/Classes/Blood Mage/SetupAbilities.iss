/*  BLOOD MAGE SETUP ABILITIES v1.0 - by Zandros

Description:  This is the configure file for the
class BLOOD MAGE.  Make your changes here and add
in your own scripts by including them here.
*/

/* MUST INCLUDES "FILES" FOR ALL CLASSES AND EDIT TO CLASS*/
#include ./BM/Classes/Blood Mage/ChatEvent.iss
#include ./BM/Classes/Blood Mage/MobImmune.iss
#include ./BM/Classes/Blood Mage/Heal.iss
#include ./BM/Classes/Blood Mage/InCombat.iss
#include ./BM/Classes/Blood Mage/NotInCombat.iss
#include ./BM/Classes/Blood Mage/ShutDown.iss

/* UNIQUE INCLUDES FOR BLOOD MAGE */
#include ./BM/Classes/Blood Mage/BloodVials.iss
#include ./BM/Classes/Blood Mage/RegenMana.iss
#include ./BM/Classes/Blood Mage/Translucence.iss
#include ./BM/Classes/Blood Mage/Symbiotes.iss
#include ./BM/Classes/Blood Mage/Buffs.iss
#include ./BM/Classes/Blood Mage/DisEnchant.iss

/* VARIABLES */
variable bool doLifeTap = TRUE
variable bool CritNow = TRUE
variable bool doSymbiotes = TRUE
variable bool doDisEnchant = TRUE
variable bool doHOT = FALSE
variable bool doHotTimer = TRUE
variable string Version = "1.6"

;===================================================
;===   Called at Startup to set ability names   ====
;===================================================
function SetupAbilities()
{
	;; Echo a line
	if ${doEcho}
		echo "[${Time}][VG:BM] --> -------------------------------------"

	;-------------------------------------------
	; Start Events
	;-------------------------------------------
	Event[VG_onAlertText]:AttachAtom[InvisabilityEvent]

	;-------------------------------------------
	; Declare Base Abilities - Blood Mage
	;-------------------------------------------

	declare		Despoil		string		script
	call GetHighestAbility "Despoil"
	Despoil:Set[${Return}]

	declare		EntwiningVein		string		script
	call GetHighestAbility "Entwining Vein"
	EntwiningVein:Set[${Return}]

	declare		UnionOfBlood		string		script
	call GetHighestAbility "Union of Blood"
	UnionOfBlood:Set[${Return}]

	declare		BurstingCyst		string		script
	call GetHighestAbility "Bursting Cyst"
	BurstingCyst:Set[${Return}]

	declare		ExplodingCyst		string		script
	call GetHighestAbility "Exploding Cyst"
	ExplodingCyst:Set[${Return}]

	declare		BloodLettingRitual		string		script
	call GetHighestAbility "Blood Letting Ritual"
	BloodLettingRitual:Set[${Return}]

	declare		ScarletRitual		string		script
	call GetHighestAbility "Scarlet Ritual"
	ScarletRitual:Set[${Return}]
	
	declare		Dissolve		string		script
	call GetHighestAbility "Dissolve"
	Dissolve:Set[${Return}]

	declare		Metamorphism		string		script
	call GetHighestAbility "Metamorphism"
	Metamorphism:Set[${Return}]

	declare		Exsanguinate		string		script
	call GetHighestAbility "Exsanguinate"
	Exsanguinate:Set[${Return}]

	declare		BloodTribute		string		script
	call GetHighestAbility "Blood Tribute"
	BloodTribute:Set[${Return}]

	declare		FleshRend		string		script
	call GetHighestAbility "Flesh Rend"
	FleshRend:Set[${Return}]

	declare		MentalTransmutation		string		script
	call GetHighestAbility "Mental Transmutation"
	MentalTransmutation:Set[${Return}]
	
	declare		InfuseHealth		string		script
	call GetHighestAbility "Infuse Health"
	InfuseHealth:Set[${Return}]

	declare		BloodGift		string		script
	call GetHighestAbility "Blood Gift"
	BloodGift:Set[${Return}]

	declare		FleshMendersRitual		string		script
	call GetHighestAbility "Flesh Mender's Ritual"
	FleshMendersRitual:Set[${Return}]

	declare		TransfusionOfSerak		string		script
	call GetHighestAbility "Transfusion of Serak"
	TransfusionOfSerak:Set[${Return}]

	declare		PhysicalTransmutation		string		script
	call GetHighestAbility "Physical Transmutation"
	PhysicalTransmutation:Set[${Return}]

	declare		RecoveringBurst		string		script
	call GetHighestAbility "Recovering Burst"
	RecoveringBurst:Set[${Return}]
	
	declare		LifeHusk		string		script
	call GetHighestAbility "Life Husk"
	LifeHusk:Set[${Return}]
	
	declare		ShelteringRune		string		script
	call GetHighestAbility "Sheltering Rune"
	ShelteringRune:Set[${Return}]
	
	declare		StripEnchantment		string		script
	call GetHighestAbility "Strip Enchantment"
	StripEnchantment:Set[${Return}]
	
	declare		BloodFeast		string		script
	call GetHighestAbility "Blood Feast"
	BloodFeast:Set[${Return}]

	declare		SeraksMantle		string		script
	call GetHighestAbility "Serak's Mantle"
	SeraksMantle:Set[${Return}]
	
	declare		HealthGraft		string		script
	call GetHighestAbility "Health Graft"
	HealthGraft:Set[${Return}]

	declare		Vitalize		string		script
	call GetHighestAbility "Vitalize"
	Vitalize:Set[${Return}]

	declare		SeraksAugmentation		string		script
	call GetHighestAbility "Serak's Augmentation"
	SeraksAugmentation:Set[${Return}]

	declare		MentalInfusion		string		script
	call GetHighestAbility "Mental Infusion"
	MentalInfusion:Set[${Return}]

	declare		CerebralGraft		string		script
	call GetHighestAbility "Cerebral Graft"
	CerebralGraft:Set[${Return}]

	declare		LifeGraft		string		script
	call GetHighestAbility "Life Graft"
	LifeGraft:Set[${Return}]

	declare		MentalStimulation		string		script
	call GetHighestAbility "Mental Stimulation"
	MentalStimulation:Set[${Return}]

	declare		Regeneration		string		script
	call GetHighestAbility "Regeneration"
	Regeneration:Set[${Return}]

	;; Echo a line
	if ${doEcho}
		echo "[${Time}][VG:BM] --> -------------------------------------"

	;-------------------------------------------
	; Setup any Keybindings
	;-------------------------------------------
	bind -press ATTACK CTRL+A "Script[BM]:QueueCommand[call AttackTarget]"


}


;===================================================
;===      GetHighestAbility Routine             ====
;===================================================
function GetHighestAbility(string AbilityName)
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
	;AbilityLevels[9]:Set[IX]
	;AbilityLevels[10]:Set[X]
	;AbilityLevels[11]:Set[XI]
	;AbilityLevels[12]:Set[XII]
	;AbilityLevels[13]:Set[XIII]
	;AbilityLevels[14]:Set[XIV]
	;AbilityLevels[15]:Set[XV]
	;AbilityLevels[16]:Set[XVI]
	;AbilityLevels[17]:Set[XVII]
	;AbilityLevels[18]:Set[XVIII]
	;AbilityLevels[19]:Set[XIX]
	;AbilityLevels[20]:Set[XX]

	;-------------------------------------------
	; Return if Ability already exists
	;-------------------------------------------
	if ${Me.Ability["${AbilityName}"](exists)}
		return ${AbilityName}

	;-------------------------------------------
	; Find highest Ability level
	;-------------------------------------------
	do
	{
		if ${Me.Ability["${AbilityName} ${AbilityLevels[${L}]}"](exists)}
		{
			ABILITY:Set["${AbilityName} ${AbilityLevels[${L}]}"]
			break
		}
	}
	while (${L:Dec}>0)

	;-------------------------------------------
	; If Ability exist then return
	;-------------------------------------------
	if ${Me.Ability["${ABILITY}"](exists)}
	{
		if ${doEcho}
			echo "[${Time}][VG:BM] --> ${AbilityName}:  ${ABILITY}"
		return ${ABILITY}
	}

	;-------------------------------------------
	; Otherwise, new Ability is named "None"
	;-------------------------------------------
	if ${doEcho}
		echo "[${Time}][VG:BM] --> ${AbilityName}:  None"
	return "None"
}


