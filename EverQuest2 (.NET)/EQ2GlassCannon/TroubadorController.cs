using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2.ISXEQ2;

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
		public bool m_bAllowShroudForNightStrike = false;
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
		public int m_iRaidArcaneBuffAbilityID = -1;
		public int m_iRaidElementalBuffAbilityID = -1;
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
		public int m_iGreenInterruptNukeAbilityID = -1;
		public int m_iGreenInstantKnockdownAbilityID = -1;
		#endregion

		/************************************************************************************/
		protected override void TransferINISettings(TransferType eTransferType)
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
			TransferINIBool(eTransferType, "Troubador.AllowShroudForNightStrike", ref m_bAllowShroudForNightStrike);
			TransferINIString(eTransferType, "Troubador.MaestroCallout", ref m_strMaestroCallout);
			TransferINIString(eTransferType, "Troubador.UpbeatTempoTarget", ref m_strUpbeatTempoTarget);
			TransferINIString(eTransferType, "Troubador.JestersCapRequestSubstring", ref m_strJestersCapRequestSubstring);
			TransferINIString(eTransferType, "Troubador.JestersCapCallout", ref m_strJestersCapCallout);
			return;
		}

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_iGroupCastingSkillBuffAbilityID = SelectHighestTieredAbilityID("Song of Magic");
			m_iGroupSpellProcBuffAbilityID = SelectHighestTieredAbilityID("Aria of Magic");
			m_iGroupManaRegenBuffAbilityID = SelectHighestTieredAbilityID("Bria's Inspiring Ballad");
			m_iGroupDefenseBuffAbilityID = SelectHighestTieredAbilityID("Graceful Avoidance");
			m_iGroupHasteBuffAbilityID = SelectHighestTieredAbilityID("Allegretto");
			m_iGroupDehateBuffAbilityID = SelectHighestTieredAbilityID("Alin's Serene Serenade");
			m_iGroupSTRSTABuffAbilityID = SelectHighestTieredAbilityID("Raxxyl's Rousing Tune");
			m_iGroupReflectBuffAbilityID = SelectHighestAbilityID("Requiem of Reflection");
			m_iGroupHealthRegenBuffAbilityID = SelectHighestTieredAbilityID("Rejuvenating Celebration");
			m_iRaidArcaneBuffAbilityID = SelectHighestTieredAbilityID("Arcane Symphony");
			m_iRaidElementalBuffAbilityID = SelectHighestTieredAbilityID("Elemental Concerto");
			m_iSelfAGIINTBuffAbilityID = SelectHighestTieredAbilityID("Daelis' Dance of Blades");
			m_iResonanceAbilityID = SelectHighestAbilityID("Resonance");
			m_iHarmonizationAbilityID = SelectHighestAbilityID("Harmonization");
			m_iUpbeatTempoAbilityID = SelectHighestAbilityID("Upbeat Tempo");
			m_iMaestroAbilityID = SelectHighestTieredAbilityID("Perfection of the Maestro");
			m_iJestersCapAbilityID = SelectHighestAbilityID("Jester's Cap");
			m_iCountersongDebuffAbilityID = SelectHighestAbilityID("Countersong");
			m_iSingleMentalSnareDebuffAbilityID = SelectHighestTieredAbilityID("Depressing Chant");
			m_iSingleDefenseDebuffAbilityID = SelectHighestTieredAbilityID("Vexing Verses");
			m_iSingleResistDebuffAbilityID = SelectHighestTieredAbilityID("Dancing Blade");
			m_iSingleINTDebuffAbilityID = SelectHighestTieredAbilityID("Night Strike");
			m_iGreenResistDebuffAbilityID = SelectHighestTieredAbilityID("Zander's Choral Rebuff");
			m_iGreenSkillDebuffAbilityID = SelectHighestTieredAbilityID("Demoralizing Processional");
			m_iGreenWISDebuffAbilityID = SelectHighestTieredAbilityID("Chaos Anthem");
			m_iSingleLongRangeNukeAbilityID = SelectHighestTieredAbilityID("Perfect Shrill");
			m_iSingleShortRangeNukeAbilityID = SelectHighestTieredAbilityID("Thunderous Overture");
			m_iSinglePowerSiphonNukeAbilityID = SelectHighestTieredAbilityID("Tap Essence");
			m_iSinglePowerDrainAttackAbilityID = SelectHighestTieredAbilityID("Sandra's Deafening Strike");
			m_iSingleMentalAttackPairAbilityID = SelectHighestTieredAbilityID("Ceremonial Blade");
			m_iSingleMezAbilityID = SelectHighestTieredAbilityID("Lullaby");
			m_iGreenInterruptNukeAbilityID = SelectHighestTieredAbilityID("Painful Lamentations");
			m_iGreenInstantKnockdownAbilityID = SelectHighestTieredAbilityID("Breathtaking Bellow");

			return;
		}

		/************************************************************************************/
		public override bool DoNextAction()
		{
			if (base.DoNextAction())
				return true;

			if (Me.CastingSpell || MeActor.IsDead)
				return true;

			if (DisarmChests())
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

				if (CheckToggleBuff(m_iRaidArcaneBuffAbilityID, m_bBuffArcaneResistance))
					return true;

				if (CheckToggleBuff(m_iRaidElementalBuffAbilityID, m_bBuffElementalResistance))
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
				/// Troubadors only have one stealth attack.
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
				if (m_bUseGreenAEs && IsBeneficialEffectPresent(m_iMaestroAbilityID))
				{
					if (CastAbility(m_iGreenInstantKnockdownAbilityID))
						return true;
				}

				/// AE interrupt nuke.
				if (IsBeneficialEffectPresent(m_iMaestroAbilityID))
				{
					if (CastGreenOffensiveAbility(m_iGreenInterruptNukeAbilityID, 2))
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

				if (CastAbility(m_iLoreAndLegendAbilityID))
					return true;

				if (CastAbility(m_iSingleDefenseDebuffAbilityID))
					return true;

				if (CastAbility(m_iHalfElfMitigationDebuffAbilityID))
					return true;

				if (CastAbility(m_iSingleResistDebuffAbilityID))
					return true;

				/// We now cast stealth to allow the use of our INT debuff, Night Strike.
				/// On the very next DoNextAction(), we'll see ourselves stealthed and execute the debuff.
				/// It takes some luck though. We cast stealth but the server doesn't tell us we're stealthed yet,
				/// so we use other spells and break the stealth on accident.
				if (!IsAbilityMaintained(m_iSingleINTDebuffAbilityID))
				{
					Ability DebuffAbility = Me.Ability(m_iSingleINTDebuffAbilityID);
					if (DebuffAbility.TimeUntilReady == 0.0f) /// IsReady will always be false if not stealthed.
					{
						if (CastAbility(m_iBumpAbilityID))
							return true;

						if (m_bAllowShroudForNightStrike && CastAbility(m_iShroudAbilityID))
							return true;
					}
				}

				/*********************************
				From here on out, it's dps spells.

				Evasive Maneuvers = 4077.2
				Ceremonial Blade = 3245.7
				Reverberating Shrill = 2016.1
				Turnstrike = 1708
				Draining Incursion = 1448.9
				Tap Essence = 1310.2
				Thunderous Overture = 907.3
				*********************************/

				if (CastGreenOffensiveAbility(m_iGreenInterruptNukeAbilityID, 3))
					return true;

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

				if (CastGreenOffensiveAbility(m_iGreenInterruptNukeAbilityID, 2))
					return true;


				/// Nuke of last resort.
				if (CastGreenOffensiveAbility(m_iGreenInterruptNukeAbilityID, 1))
					return true;
			}

			return false;
		}
	}
}
