/*  SETUP ABILITIES v1.1 - by Zandros

Description:  Find highest abilities.  Doing this at start of script is much faster
than finding the highest ability each time you cast a spell.

25 Dec 2009 - Patched so that it works with Mentorship!

*/

;===================================================
;===   Setup Abilites - Put your spells here    ====
;===================================================
function SetupAbilities()
{
	;; Echo a line
	if ${doEcho}
	EchoIt "--> -------------------------------------"

	;-------------------------------------------
	; Declare Base Abilities
	;-------------------------------------------
	;; === DOTS ===
	call SetHighestAbility "Dot1" "Temporal Shift"
	call SetHighestAbility "Dot2" "Compression Sphere"
	call SetHighestAbility "Dot3" "Psychic Schism"
	;; === AE ===
	call SetHighestAbility "AE1" "Dementia"
	call SetHighestAbility "AE2" "Thought Surge"
	call SetHighestAbility "AE3" "Chronoshift"
	;; === NUKES ===
	call SetHighestAbility "Nuke1" "Corporeal Smash"
	call SetHighestAbility "Nuke2" "Corporeal Hammer"
	call SetHighestAbility "Nuke3" "Psionic Blast"
	call SetHighestAbility "Nuke4" "Thought Pulse"
	call SetHighestAbility "Nuke5" "Mental Blast"
	;; === CHAINS ===
	call SetHighestAbility "Chain1" "Mindfire"
	call SetHighestAbility "Chain2" "Telekinetic Blast"
	call SetHighestAbility "Chain3" "Temporal Fracture"
	;; === COUNTERS ===
	call SetHighestAbility "Counter1" "Nullifying Field"
	call SetHighestAbility "Counter2" "Psychic Mutation"
	;; === REGEN DOTS ===
	;;
	;; MANUALLY MODIFY THESE TO WHAT REGEN DOT YOU WANT TO USE!
	;;
	call SetHighestAbility "RegenDot1" "Compression Sphere VIII"
	call SetHighestAbility "RegenDot2" "Psychic Schism IV"
	;; === DEFENSE ===
	call SetHighestAbility "Defense1" "Psionic Barrier"
	call SetHighestAbility "Defense2" "Diamond Skin"
	call SetHighestAbility "Defense3" "Mass Amnesia"

/*
	;; === BUFFS ===
	call SetHighestAbility "BloodFeast" "Blood Feast"
	call SetHighestAbility "SeraksMantle" "Serak's Mantle"
	call SetHighestAbility "HealthGraft" "Health Graft"
	call SetHighestAbility "SeraksAugmentation" "Serak's Augmentation"
	call SetHighestAbility "Vitalize" "Vitalize"
	call SetHighestAbility "MentalInfusion" "Mental Infusion"
	call SetHighestAbility "CerebralGraft" "Cerebral Graft"
	call SetHighestAbility "LifeGraft" "Life Graft"
	call SetHighestAbility "MentalStimulation" "Mental Stimulation"
	call SetHighestAbility "Regeneration" "Regeneration"
	call SetHighestAbility "FavorOfTheLifeGiver" "Favor of the Life Giver"
	call SetHighestAbility "ConstructsAugmentation" "Construct's Augmentation"
	;; === MISC ===
*/

}


