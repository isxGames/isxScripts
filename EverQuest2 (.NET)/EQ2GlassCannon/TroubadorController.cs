using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2GlassCannon
{
	public class TroubadorController : BardController
	{
		#region INI settings
		public bool m_bBuffCastingSkill = false;
		public bool m_bBuffSpellProc = false;
		public bool m_bBuffManaRegen = false;
		public bool m_bBuffDefense = false;
		public bool m_bBuffHaste = false;
		public bool m_bBuffDehate = false;
		public bool m_bBuffSTRSTA = false;
		public bool m_bBuffReflect = false;
		public bool m_bBuffHealthRegen = false;
		public bool m_bBuffArcaneResistance = false;
		public bool m_bBuffElementalResistance = false;
		public string m_strMaestroCallout = "POTM INC (32 sec) - Spam your taunts and hostile spells NOW (guaranteed +800 mental dmg proc).";
		public string m_strUpbeatTempoTarget = string.Empty;
		public string m_strJestersCapRequestSubstring = "JC ME";
		public string m_strJestersCapCallout = "JESTER'S CAP ON >> {0} <<";
		#endregion

		#region Ability ID's
		public int m_iGroupCastingSkillBuffAbilityID = -1;
		public int m_iGroupSpellProcBuffAbilityID = -1;
		public int m_iGroupManaRegenBuffAbilityID = -1;
		public int m_iGroupDefenseBuffAbilityID = -1;
		public int m_iGroupHasteBuffAbilityID = -1;
		public int m_iGroupDehateBuffAbilityID = -1;
		public int m_iGroupSTRSTABuffAbilityID = -1;
		public int m_iGroupReflectBuffAbilityID = -1;
		public int m_iGroupHealthRegenBuffAbilityID = -1;
		public int m_iGroupArcaneBuffAbilityID = -1;
		public int m_iGroupElementalBuffAbilityID = -1;
		public int m_iSelfAGIINTBuffAbilityID = -1;
		public int m_iResonanceAbilityID = -1;
		public int m_iHarmonizationAbilityID = -1;
		public int m_iUpbeatTempoAbilityID = -1;

		public int m_iMaestroAbilityID = -1;
		public int m_iJestersCapAbilityID = -1;

		public int m_iCountersongDebuffAbilityID = -1;
		public int m_iSingleMentalSnareDebuffAbilityID = -1;
		public int m_iSingleDefenseDebuffAbilityID = -1;
		public int m_iSingleResistDebuffAbilityID = -1;
		public int m_iSingleINTDebuffAbilityID = -1;
		public int m_iGreenResistDebuffAbilityID = -1;
		public int m_iGreenSkillDebuffAbilityID = -1;
		public int m_iGreenWISDebuffAbilityID = -1;

		public int m_iSingleLongRangeNukeAbilityID = -1;
		public int m_iSingleShortRangeNukeAbilityID = -1;
		public int m_iSinglePowerSiphonNukeAbilityID = -1;
		public int m_iSinglePowerDrainAttackAbilityID = -1;
		public int m_iSingleMentalAttackPairAbilityID = -1;
		public int m_iSingleMezAbilityID = -1;
		public int m_iGreenInterruptAbilityID = -1;
		public int m_iGreenInstantKnockdownAbilityID = -1;
		#endregion

		/************************************************************************************/
		public override void TransferINISettings(TransferType eTransferType)
		{
			base.TransferINISettings(eTransferType);

			TransferINIBool(eTransferType, "Troubador.BuffCastingSkill", ref m_bBuffCastingSkill);
			TransferINIBool(eTransferType, "Troubador.BuffSpellProc", ref m_bBuffSpellProc);
			TransferINIBool(eTransferType, "Troubador.BuffManaRegen", ref m_bBuffManaRegen);
			TransferINIBool(eTransferType, "Troubador.BuffDefense", ref m_bBuffDefense);
			TransferINIBool(eTransferType, "Troubador.BuffHaste", ref m_bBuffHaste);
			TransferINIBool(eTransferType, "Troubador.BuffDehate", ref m_bBuffDehate);
			TransferINIBool(eTransferType, "Troubador.BuffSTRSTA", ref m_bBuffSTRSTA);
			TransferINIBool(eTransferType, "Troubador.BuffReflect", ref m_bBuffReflect);
			TransferINIBool(eTransferType, "Troubador.BuffHealthRegen", ref m_bBuffHealthRegen);
			TransferINIBool(eTransferType, "Troubador.BuffArcaneResistance", ref m_bBuffArcaneResistance);
			TransferINIBool(eTransferType, "Troubador.BuffElementalResistance", ref m_bBuffElementalResistance);
			TransferINIString(eTransferType, "Troubador.MaestroCallout", ref m_strMaestroCallout);
			TransferINIString(eTransferType, "Troubador.UpbeatTempoTarget", ref m_strUpbeatTempoTarget);
			TransferINIString(eTransferType, "Troubador.JestersCapRequestSubstring", ref m_strJestersCapRequestSubstring);
			TransferINIString(eTransferType, "Troubador.JestersCapCallout", ref m_strJestersCapCallout);
			return;
		}

		/************************************************************************************/
		public override void InitializeKnowledgeBook()
		{
			base.InitializeKnowledgeBook();

			m_iGroupCastingSkillBuffAbilityID = SelectHighestAbilityID(
				"Magical Boon",
				"Minstrel's Luck",
				"Minstrel's Fortune",
				"Swan Song",
				"Dove Song",
				"Song of Magic");

			m_iGroupSpellProcBuffAbilityID = SelectHighestAbilityID(
				"Aria of Excitement",
				"Aria of Inspiration",
				"Aria of Exaltation",
				"Aria of Acclamation",
				"Aria of Magic");

			m_iGroupManaRegenBuffAbilityID = SelectHighestAbilityID(
				"Bria's Stirring Ballad",
				"Bria's Thrilling Ballad",
				"Bria's Exalting Ballad",
				"Bria's Glorifying Ballad",
				"Bria's Inspiring Ballad",
				"Power Ballad"); // Once again, Aeralik just said fuck it.

			m_iGroupDefenseBuffAbilityID = SelectHighestAbilityID(
				"Insatiable Ardor",
				"Daelor's Luminary Ballad",
				"Graceful Avoidance",
				"Balletic Avoidance",
				"Performer Avoidance");

			m_iGroupHasteBuffAbilityID = SelectHighestAbilityID(
				"Merciless Melody",
				"Gerard's Resonant Sonata",
				"Invigorating Opus",
				"Exhilarating Opus",
				"Rousing Opus",
				"Allegretto");

			m_iGroupDehateBuffAbilityID = SelectHighestAbilityID(
				"Alin's Soothing Serenade",
				"Alin's Calming Serenade",
				"Alin's Tranquil Serenade",
				"Alin's Serene Serenade");

			m_iGroupSTRSTABuffAbilityID = SelectHighestAbilityID(
				"Raxxyl's Fortitude Song",
				"Raxxyl's Rousing Tune",
				"Raxxyl's Energizing Harmony",
				"Raxxyl's Vivacious Descant",
				"Raxxyl's Brash Descant",
				"Raxxyl's Brazen Descant",
				"Fortifying Song");

			m_iGroupReflectBuffAbilityID = SelectHighestAbilityID("Requiem of Reflection");

			m_iGroupHealthRegenBuffAbilityID = SelectHighestAbilityID(
				"Quiron's Joyous Celebration",
				"Quiron's Ecstatic Celebration",
				"Quiron's Blissful Celebration",
				"Rejuvenating Celebration");

			m_iGroupArcaneBuffAbilityID = SelectHighestAbilityID(
				"Arcane Chorus",
				"Arcane Symphony",
				"Arcane Concerto",
				"Arcane Dissertation",
				"Arcane Tempo");

			m_iGroupElementalBuffAbilityID = SelectHighestAbilityID(
				"Elemental Chorus",
				"Elemental Concerto",
				"Elemental Tempo");

			m_iSelfAGIINTBuffAbilityID = SelectHighestAbilityID(
				"Performer's Talent",
				"Elise's Ditty",
				"Daelis' Dance of Blades",
				"Daelis' Jig of Blades",
				"Daelis' Frolicking of Blades",
				"March of Blades");

			m_iResonanceAbilityID = SelectHighestAbilityID("Resonance");
			m_iHarmonizationAbilityID = SelectHighestAbilityID("Harmonization");
			m_iUpbeatTempoAbilityID = SelectHighestAbilityID("Upbeat Tempo");

			m_iMaestroAbilityID = SelectHighestAbilityID(
				"Precision of the Maestro",
				"Perfection of the Maestro");

			m_iJestersCapAbilityID = SelectHighestAbilityID("Jester's Cap");
			m_iCountersongDebuffAbilityID = SelectHighestAbilityID("Countersong");

			m_iSingleMentalSnareDebuffAbilityID = SelectHighestAbilityID(
				"Sybil's Slowing Chant",
				"Sybil's Shuddering Sonnet",
				"Guviena's Disparate Chant",
				"Guviena's Slothful Chant",
				"Guviena's Apathetic Chant",
				"Depressing Chant");

			m_iSingleDefenseDebuffAbilityID = SelectHighestAbilityID(
				"Lore's Shuddering Song",
				"Lore's Snapping Sonnet",
				"Lore's Lurching Limerick",
				"Lore's Magniloquent Roust",
				"Lore's Euphistic Romp",
				"Vexing Verses");

			m_iSingleResistDebuffAbilityID = SelectHighestAbilityID(
				"Brilliant Blade",
				"Taffo's Brilliant Blade",
				"Walt's Thirsting Thrust",
				"Taffo's Dazzling Ditty",
				"Dancing Blade",
				"Bright Blade");

			m_iSingleINTDebuffAbilityID = SelectHighestAbilityID(
				"Night Blade",
				"Midnight Blade",
				"Luckblade",
				"Clara's Midnight Cadence",
				"Startling Shriek",
				"Clara's Midnight Tempo",
				"Night Strike");
			
			m_iGreenResistDebuffAbilityID = SelectHighestAbilityID(
				"Zander's Choral Rebuff",
				"Magic Rebuff",
				"Spell Rebuff");
			
			m_iGreenSkillDebuffAbilityID = SelectHighestAbilityID(
				"Demoralizing Processional",
				"Dispirited Processional");

			m_iGreenWISDebuffAbilityID = SelectHighestAbilityID(
				"Kian's Destructive Anthem",
				"Kian's Devastating Anthem",
				"Kian's Catastrophic Anthem",
				"Chaos Anthem");

			m_iSingleLongRangeNukeAbilityID = SelectHighestAbilityID(
				"Shrill",
				"Piercing Shrill",
				"Dissenting Shrill",
				"Exquisite Shrill",
				"Flawless Shrill",
				"Perfect Shrill",
				"Reverberating Shrill");

			m_iSingleShortRangeNukeAbilityID = SelectHighestAbilityID(
				"Eli's Thunderous Hymn",
				"Eli's Thunderous Anthem",
				"Eli's Thunderous Chorus",
				"Eli's Thunderous Drumming",
				"Thunderous Overture");

			m_iSinglePowerSiphonNukeAbilityID = SelectHighestAbilityID(
				"Swindle Essence",
				"Purloin Essence",
				"Pilfer Essence",
				"Steal Essence",
				"Tap Essence");

			m_iSinglePowerDrainAttackAbilityID = SelectHighestAbilityID(
				"Deafening Strike",
				"Deafening Blade",
				"Deafening Thrust",
				"Sandra's Deafening Strike",
				"Sandra's Befuddling Incursion",
				"Sandra's Bewildering Incursion",
				"Draining Incursion");

			m_iSingleMentalAttackPairAbilityID = SelectHighestAbilityID(
				"Sparkling Blade",
				"Fulgent Blade",
				"Elegant Blade",
				"Courtly Blade",
				"Noble Blade",
				"Ceremonial Blade");

			m_iSingleMezAbilityID = SelectHighestAbilityID(
				"Lullaby",
				"Reverie",
				"Peaceful Melody");

			m_iGreenInterruptAbilityID = SelectHighestAbilityID(
				"Alin's Keening Lamentation",
				"Alin's Melodic Refrain",
				"Alin's Coruscating Concord",
				"Alin's Incandescent",
				"Painful Lamentations");
			
			m_iGreenInstantKnockdownAbilityID = SelectHighestAbilityID(
				"Breathtaking Bellow",
				"Awesome Bellow",
				"Mighty Bellow");

			return;
		}

		/************************************************************************************/
		public override bool DoNextAction()
		{
			if (base.DoNextAction())
				return true;

			if (Me.CastingSpell || MeActor.IsDead)
				return true;

			if (!MeActor.IsStealthed && m_bCheckBuffsNow)
			{
				if (CheckToggleBuff(m_iGroupCastingSkillBuffAbilityID, m_bBuffCastingSkill))
					return true;

				if (CheckToggleBuff(m_iGroupSpellProcBuffAbilityID, m_bBuffSpellProc))
					return true;

				if (CheckToggleBuff(m_iGroupManaRegenBuffAbilityID, m_bBuffManaRegen))
					return true;

				if (CheckToggleBuff(m_iGroupDefenseBuffAbilityID, m_bBuffDefense))
					return true;

				if (CheckToggleBuff(m_iGroupHasteBuffAbilityID, m_bBuffHaste))
					return true;

				if (CheckToggleBuff(m_iGroupDehateBuffAbilityID, m_bBuffDehate))
					return true;

				if (CheckToggleBuff(m_iGroupSTRSTABuffAbilityID, m_bBuffSTRSTA))
					return true;

				if (CheckToggleBuff(m_iGroupReflectBuffAbilityID, m_bBuffReflect))
					return true;

				if (CheckToggleBuff(m_iGroupHealthRegenBuffAbilityID, m_bBuffHealthRegen))
					return true;

				if (CheckToggleBuff(m_iGroupArcaneBuffAbilityID, m_bBuffArcaneResistance))
					return true;

				if (CheckToggleBuff(m_iGroupElementalBuffAbilityID, m_bBuffElementalResistance))
					return true;

				if (CheckToggleBuff(m_iSelfAGIINTBuffAbilityID, true))
					return true;

				if (CheckToggleBuff(m_iResonanceAbilityID, true))
					return true;

				if (CheckToggleBuff(m_iHarmonizationAbilityID, true))
					return true;

				if (CheckSingleTargetBuffs(m_iUpbeatTempoAbilityID, m_strUpbeatTempoTarget, true, false))
					return true;

				if (CheckToggleBuff(m_iAllegroAbilityID, true))
					return true;

				if (CheckToggleBuff(m_iDontKillTheMessengerAbilityID, true))
					return true;

				if (CheckToggleBuff(m_iDexterousSonataAbilityID, true))
					return true;

				if (CheckToggleBuff(m_iFortissimoAbilityID, true))
					return true;

				if (CheckToggleBuff(m_iGroupRunSpeedBuffAbilityID, true))
					return true;

				if (CheckRacialBuffs())
					return true;

				StopCheckingBuffs();
			}

			/// Decide if the offensive target is still legitimate. If so, attempt to target it.
			GetOffensiveTargetActor();
			if (m_OffensiveTargetActor != null)
			{
				/// Find the distance to the mob.  Especially important for PBAE usage.
				bool bTempBuffsAdvised = (m_OffensiveTargetActor.IsEpic && m_OffensiveTargetActor.Health > 25) || (m_OffensiveTargetActor.IsHeroic && m_OffensiveTargetActor.Health > 90) || (m_OffensiveTargetActor.Health > 95);
				int iEncounterSize = m_OffensiveTargetActor.EncounterSize;

				if (CastNextMez(m_iSingleMezAbilityID))
					return true;

				if (!EngageOffensiveTargetActor())
					return false;

				/// We put the stealth check so early on because it is so easily wasted by the wrong thing.
				if (MeActor.IsStealthed && CastAbility(m_iSingleINTDebuffAbilityID))
					return true;

				if (CastHOStarter())
					return true;

				if (bTempBuffsAdvised)
				{
					if (!IsBeneficialEffectPresent(m_iMaestroAbilityID) && CastAbility(m_iMaestroAbilityID))
					{
						/// Right now we're just making a dumb assumption that the player has the VP mythical because that's the easy thing to do.
						SpamSafeRaidSay(m_strMaestroCallout);
						return true;
					}
				}

				/// Instant cast interrupt/knockback.
				if (m_bUseGreenAEs && (m_bSpamCrowdControl || IsBeneficialEffectPresent(m_iMaestroAbilityID)))
				{
					if (CastAbility(m_iGreenInstantKnockdownAbilityID))
						return true;
				}

				/// AE interrupt nuke.
				if (m_bUseGreenAEs && (m_bSpamCrowdControl || (iEncounterSize > 2 && IsBeneficialEffectPresent(m_iMaestroAbilityID))))
				{
					if (CastAbility(m_iGreenInterruptAbilityID))
						return true;
				}

				/// Offensive skill booster. Do this before combat arts; unlike spells, CA's can be lost on a miss.
				if (CastAbility(m_iRhythmBladeAbilityID))
					return true;

				/// Fast stealth.
				if (CastAbility(m_iBumpAbilityID))
					return true;

				if (CastAbility(m_iSingleMentalSnareDebuffAbilityID))
					return true;

				if (CastAbility(m_iGreenResistDebuffAbilityID))
					return true;

				if (CastAbility(m_iGreenSkillDebuffAbilityID))
					return true;

				if (CastAbility(m_iGreenWISDebuffAbilityID))
					return true;

				if (CastAbility(m_iGreenSTRAGIDebuffAbilityID))
					return true;

				if (CastAbility(m_iSingleDefenseDebuffAbilityID))
					return true;

				if (CastAbility(m_iHalfElfMitigationDebuffAbilityID))
					return true;

				if (CastAbility(m_iSingleResistDebuffAbilityID))
					return true;

				/// This stealth enables the last of our debuffs.
				/// On the very next DoNextAction(), we'll see ourselves stealthed and execute the INT debuff.
				if (IsAbilityReady(m_iSingleINTDebuffAbilityID) && !IsAbilityMaintained(m_iSingleINTDebuffAbilityID) && CastAbility(m_iShroudAbilityID))
					return true;

				if (CastAbility(m_iLoreAndLegendAbilityID))
					return true;

				/*
				Evasive Maneuvers = 4077.2
				Ceremonial Blade = 3245.7
				Reverberating Shrill = 2016.1
				Turnstrike = 1708
				Draining Incursion = 1448.9
				Tap Essence = 1310.2
				Thunderous Overture = 907.3
				*/

				if (CastAbility(m_iEvasiveManeuversAbilityID))
					return true;

				if (CastAbility(m_iSingleMentalAttackPairAbilityID))
					return true;

				if (CastAbility(m_iSingleLongRangeNukeAbilityID))
					return true;

				/// AE avoid, though we use it as generic DPS.
				if (CastAbility(m_iTurnstrikeAbilityID))
					return true;

				if (CastAbility(m_iSinglePowerDrainAttackAbilityID))
					return true;

				if (CastAbility(m_iSinglePowerSiphonNukeAbilityID))
					return true;

				if (CastAbility(m_iSingleShortRangeNukeAbilityID))
					return true;
			}

			return false;
		}
	}
}
