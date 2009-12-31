using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2SuiteLib;

namespace EQ2GlassCannon
{
	public class TroubadorController : BardController
	{
		public Queue<PlayerRequest> m_JestersCapQueue = new Queue<PlayerRequest>();

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
		public List<string> m_astrUpbeatTempoTargets = new List<string>();
		public string m_strJestersCapRequestSubstring = "JC ME";
		public string m_strJestersCapCallout = "JESTER'S CAP ON >> {0} <<";
		public double m_fJestersCapRequestTimeoutMinutes = 1.0;
		#endregion

		#region Ability ID's
		protected uint m_uiGroupCastingSkillBuffAbilityID = 0;
		protected uint m_uiGroupSpellProcBuffAbilityID = 0;
		protected uint m_uiGroupManaRegenBuffAbilityID = 0;
		protected uint m_uiGroupDefenseBuffAbilityID = 0;
		protected uint m_uiGroupHasteBuffAbilityID = 0;
		protected uint m_uiGroupDehateBuffAbilityID = 0;
		protected uint m_uiGroupSTRSTABuffAbilityID = 0;
		protected uint m_uiGroupReflectBuffAbilityID = 0;
		protected uint m_uiGroupHealthRegenBuffAbilityID = 0;
		protected uint m_uiRaidArcaneBuffAbilityID = 0;
		protected uint m_uiRaidElementalBuffAbilityID = 0;
		protected uint m_uiSelfAGIINTBuffAbilityID = 0;
		protected uint m_uiResonanceAbilityID = 0;
		protected uint m_uiHarmonizationAbilityID = 0;
		protected uint m_uiUpbeatTempoAbilityID = 0;

		protected uint m_uiMaestroAbilityID = 0;
		protected uint m_uiJestersCapAbilityID = 0;

		protected uint m_uiCountersongDebuffAbilityID = 0;
		protected uint m_uiSingleMentalSnareDebuffAbilityID = 0;
		protected uint m_uiSingleDefenseDebuffAbilityID = 0;
		protected uint m_uiSingleResistDebuffAbilityID = 0;
		protected uint m_uiSingleINTDebuffAbilityID = 0;
		protected uint m_uiGreenResistDebuffAbilityID = 0;
		protected uint m_uiGreenSkillDebuffAbilityID = 0;
		protected uint m_uiGreenWISDebuffAbilityID = 0;

		protected uint m_uiSingleLongRangeNukeAbilityID = 0;
		protected uint m_uiSingleShortRangeNukeAbilityID = 0;
		protected uint m_uiSinglePowerSiphonNukeAbilityID = 0;
		protected uint m_uiSinglePowerDrainAttackAbilityID = 0;
		protected uint m_uiSingleMentalAttackPairAbilityID = 0;
		protected uint m_uiSingleMezAbilityID = 0;
		protected uint m_uiSingleRangedAttackAbilityID = 0;
		protected uint m_uiGreenInterruptNukeAbilityID = 0;
		protected uint m_uiGreenInstantKnockdownAbilityID = 0;
		#endregion

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferBool("Troubador.BuffCastingSkill", ref m_bBuffCastingSkill);
			ThisFile.TransferBool("Troubador.BuffSpellProc", ref m_bBuffSpellProc);
			ThisFile.TransferBool("Troubador.BuffManaRegen", ref m_bBuffManaRegen);
			ThisFile.TransferBool("Troubador.BuffDefense", ref m_bBuffDefense);
			ThisFile.TransferBool("Troubador.BuffHaste", ref m_bBuffHaste);
			ThisFile.TransferBool("Troubador.BuffDehate", ref m_bBuffDehate);
			ThisFile.TransferBool("Troubador.BuffSTRSTA", ref m_bBuffSTRSTA);
			ThisFile.TransferBool("Troubador.BuffReflect", ref m_bBuffReflect);
			ThisFile.TransferBool("Troubador.BuffHealthRegen", ref m_bBuffHealthRegen);
			ThisFile.TransferBool("Troubador.BuffArcaneResistance", ref m_bBuffArcaneResistance);
			ThisFile.TransferBool("Troubador.BuffElementalResistance", ref m_bBuffElementalResistance);
			ThisFile.TransferBool("Troubador.AllowShroudForNightStrike", ref m_bAllowShroudForNightStrike);
			ThisFile.TransferString("Troubador.MaestroCallout", ref m_strMaestroCallout);
			ThisFile.TransferStringList("Troubador.UpbeatTempoTargets", m_astrUpbeatTempoTargets);
			ThisFile.TransferCaselessString("Troubador.JestersCapRequestSubstring", ref m_strJestersCapRequestSubstring);
			ThisFile.TransferString("Troubador.JestersCapCallout", ref m_strJestersCapCallout);
			ThisFile.TransferDouble("Troubador.JestersCapRequestTimeoutMinutes", ref m_fJestersCapRequestTimeoutMinutes);
			return;
		}

		/************************************************************************************/
		protected override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_uiGroupCastingSkillBuffAbilityID = SelectHighestTieredAbilityID("Song of Magic");
			m_uiGroupSpellProcBuffAbilityID = SelectHighestTieredAbilityID("Aria of Magic");
			m_uiGroupManaRegenBuffAbilityID = SelectHighestTieredAbilityID("Bria's Inspiring Ballad");
			m_uiGroupDefenseBuffAbilityID = SelectHighestTieredAbilityID("Graceful Avoidance");
			m_uiGroupHasteBuffAbilityID = SelectHighestTieredAbilityID("Allegretto");
			m_uiGroupDehateBuffAbilityID = SelectHighestTieredAbilityID("Alin's Serene Serenade");
			m_uiGroupSTRSTABuffAbilityID = SelectHighestTieredAbilityID("Raxxyl's Rousing Tune");
			m_uiGroupReflectBuffAbilityID = SelectHighestAbilityID("Requiem of Reflection");
			m_uiGroupHealthRegenBuffAbilityID = SelectHighestTieredAbilityID("Rejuvenating Celebration");
			m_uiRaidArcaneBuffAbilityID = SelectHighestTieredAbilityID("Arcane Symphony");
			m_uiRaidElementalBuffAbilityID = SelectHighestTieredAbilityID("Elemental Concerto");
			m_uiSelfAGIINTBuffAbilityID = SelectHighestTieredAbilityID("Daelis' Dance of Blades");
			m_uiResonanceAbilityID = SelectHighestAbilityID("Resonance");
			m_uiHarmonizationAbilityID = SelectHighestAbilityID("Harmonization");
			m_uiUpbeatTempoAbilityID = SelectHighestAbilityID("Upbeat Tempo");
			m_uiMaestroAbilityID = SelectHighestTieredAbilityID("Perfection of the Maestro");
			m_uiJestersCapAbilityID = SelectHighestAbilityID("Jester's Cap");
			m_uiCountersongDebuffAbilityID = SelectHighestAbilityID("Countersong");
			m_uiSingleMentalSnareDebuffAbilityID = SelectHighestTieredAbilityID("Depressing Chant");
			m_uiSingleDefenseDebuffAbilityID = SelectHighestTieredAbilityID("Vexing Verses");
			m_uiSingleResistDebuffAbilityID = SelectHighestTieredAbilityID("Dancing Blade");
			m_uiSingleINTDebuffAbilityID = SelectHighestTieredAbilityID("Night Strike");
			m_uiGreenResistDebuffAbilityID = SelectHighestTieredAbilityID("Zander's Choral Rebuff");
			m_uiGreenSkillDebuffAbilityID = SelectHighestTieredAbilityID("Demoralizing Processional");
			m_uiGreenWISDebuffAbilityID = SelectHighestTieredAbilityID("Chaos Anthem");
			m_uiSingleLongRangeNukeAbilityID = SelectHighestTieredAbilityID("Perfect Shrill");
			m_uiSingleShortRangeNukeAbilityID = SelectHighestTieredAbilityID("Thunderous Overture");
			m_uiSinglePowerSiphonNukeAbilityID = SelectHighestTieredAbilityID("Tap Essence");
			m_uiSinglePowerDrainAttackAbilityID = SelectHighestTieredAbilityID("Sandra's Deafening Strike");
			m_uiSingleMentalAttackPairAbilityID = SelectHighestTieredAbilityID("Ceremonial Blade");
			m_uiSingleMezAbilityID = SelectHighestTieredAbilityID("Lullaby");
			m_uiSingleRangedAttackAbilityID = SelectHighestTieredAbilityID("Singing Shot");
			m_uiGreenInterruptNukeAbilityID = SelectHighestTieredAbilityID("Painful Lamentations");
			m_uiGreenInstantKnockdownAbilityID = SelectHighestTieredAbilityID("Breathtaking Bellow");

			return;
		}

		/************************************************************************************/
		protected override bool DoNextAction()
		{
			if (base.DoNextAction() || MeActor.IsDead)
				return true;

			if (IsCasting)
			{
				return true;
			}

			if (UseRegenItem())
				return true;
			if (DisarmChests())
				return true;
			if (CastJestersCap())
				return true;

			if (m_bCheckBuffsNow && MeActor.IsStealthed && !MeActor.InCombatMode)
			{
				/// I'm sick and tired of Shroud lingering on after combat.
				if (CancelMaintained(m_uiShroudAbilityID, true))
					return true;
			}
			else if (m_bCheckBuffsNow && !MeActor.IsStealthed)
			{
				/// Time is of the essence when rebuffing after a wipe!
				if (!MeActor.InCombatMode && CheckToggleBuff(m_uiGroupRunSpeedBuffAbilityID, true))
					return true;
				if (CheckToggleBuff(m_uiGroupCastingSkillBuffAbilityID, m_bBuffCastingSkill))
					return true;
				if (CheckToggleBuff(m_uiGroupSpellProcBuffAbilityID, m_bBuffSpellProc))
					return true;
				if (CheckToggleBuff(m_uiGroupManaRegenBuffAbilityID, m_bBuffManaRegen))
					return true;
				if (CheckToggleBuff(m_uiGroupDefenseBuffAbilityID, m_bBuffDefense))
					return true;
				if (CheckToggleBuff(m_uiGroupHasteBuffAbilityID, m_bBuffHaste))
					return true;
				if (CheckToggleBuff(m_uiGroupDehateBuffAbilityID, m_bBuffDehate))
					return true;
				if (CheckToggleBuff(m_uiGroupSTRSTABuffAbilityID, m_bBuffSTRSTA))
					return true;
				if (CheckToggleBuff(m_uiGroupReflectBuffAbilityID, m_bBuffReflect))
					return true;
				if (CheckToggleBuff(m_uiGroupHealthRegenBuffAbilityID, m_bBuffHealthRegen))
					return true;
				if (CheckToggleBuff(m_uiRaidArcaneBuffAbilityID, m_bBuffArcaneResistance))
					return true;
				if (CheckToggleBuff(m_uiRaidElementalBuffAbilityID, m_bBuffElementalResistance))
					return true;
				if (CheckToggleBuff(m_uiSelfAGIINTBuffAbilityID, true))
					return true;
				if (CheckToggleBuff(m_uiResonanceAbilityID, true))
					return true;
				if (CheckToggleBuff(m_uiHarmonizationAbilityID, true))
					return true;
				if (CheckSingleTargetBuff(m_uiUpbeatTempoAbilityID, m_astrUpbeatTempoTargets))
					return true;
				if (CheckToggleBuff(m_uiAllegroAbilityID, true))
					return true;
				if (CheckToggleBuff(m_uiDontKillTheMessengerAbilityID, true))
					return true;
				if (CheckToggleBuff(m_uiDexterousSonataAbilityID, true))
					return true;
				if (CheckToggleBuff(m_uiFortissimoAbilityID, true))
					return true;
				if (CheckToggleBuff(m_uiGroupRunSpeedBuffAbilityID, true))
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

				if (CastNextMez(m_uiSingleMezAbilityID))
					return true;

				if (!EngageOffensiveTarget())
					return false;

				/// We put the stealth check so early on because it is so easily wasted by the wrong thing.
				/// Troubadors only have one stealth attack.
				if (MeActor.IsStealthed && CastAbility(m_uiSingleINTDebuffAbilityID))
					return true;

				if (m_bIHaveAggro)
				{
					if (CastAbility(m_uiEvasiveManeuversAbilityID))
						return true;

					if (CastAbility(m_uiSingleDeaggroAbilityID))
						return true;

					if (UseDeaggroItems())
						return true;
				}

				if (CastHOStarter())
					return true;

				if (bTempBuffsAdvised)
				{
					if (!IsBeneficialEffectPresent(m_uiMaestroAbilityID) && CastAbility(m_uiMaestroAbilityID))
					{
						/// Right now we're just making a dumb assumption that the player has the VP mythical because that's the easy thing to do.
						SpamSafeRaidSay(m_strMaestroCallout);
						return true;
					}
				}

				/// Instant cast interrupt/knockback.
				if (m_bUseGreenAEs && IsBeneficialEffectPresent(m_uiMaestroAbilityID))
				{
					if (CastAbility(m_uiGreenInstantKnockdownAbilityID))
						return true;
				}

				/// AE interrupt nuke.
				if (IsBeneficialEffectPresent(m_uiMaestroAbilityID))
				{
					if (CastGreenOffensiveAbility(m_uiGreenInterruptNukeAbilityID, 2))
						return true;
				}

				/// Offensive skill booster. Do this before combat arts; unlike spells, CA's can be lost on a miss.
				if (CastAbility(m_uiRhythmBladeAbilityID))
					return true;

				if (CastAbility(m_uiSingleMentalSnareDebuffAbilityID))
					return true;

				if (CastAbility(m_uiGreenResistDebuffAbilityID))
					return true;

				if (CastAbility(m_uiGreenSkillDebuffAbilityID))
					return true;

				if (CastAbility(m_uiGreenWISDebuffAbilityID))
					return true;

				if (CastAbility(m_uiGreenSTRAGIDebuffAbilityID))
					return true;

				if (CastLoreAndLegendAbility())
					return true;

				if (CastAbility(m_uiSingleDefenseDebuffAbilityID))
					return true;

				if (CastAbility(m_uiHalfElfMitigationDebuffAbilityID))
					return true;

				if (CastAbilityFromFlankingOrBehind(m_uiSingleResistDebuffAbilityID))
					return true;

				/// We now cast stealth to allow the use of our INT debuff, Night Strike.
				/// On the very next DoNextAction(), we'll see ourselves stealthed and execute the debuff.
				/// It takes some luck though. We cast stealth but the server doesn't tell us we're stealthed yet,
				/// so we use other spells and break the stealth on accident.
				if (!IsAbilityMaintained(m_uiSingleINTDebuffAbilityID))
				{
					CachedAbility DebuffAbility = GetAbility(m_uiSingleINTDebuffAbilityID, true);
					if (DebuffAbility != null && DebuffAbility.m_fTimeUntilReady == 0.0) /// IsReady will always be false if not stealthed.
					{
						if (CastAbility(m_uiBumpAbilityID))
							return true;

						if (m_bAllowShroudForNightStrike && CastAbility(m_uiShroudAbilityID))
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

				if (CastGreenOffensiveAbility(m_uiGreenInterruptNukeAbilityID, 3))
					return true;

				if (CastAbility(m_uiEvasiveManeuversAbilityID))
					return true;

				if (CastAbility(m_uiSingleMentalAttackPairAbilityID))
					return true;

				if (CastAbility(m_uiSingleLongRangeNukeAbilityID))
					return true;

				/// AE avoid, though we use it as generic DPS.
				if (CastAbility(m_uiTurnstrikeAbilityID))
					return true;

				if (CastAbility(m_uiSinglePowerDrainAttackAbilityID))
					return true;

				if (CastAbility(m_uiSinglePowerSiphonNukeAbilityID))
					return true;

				if (CastAbility(m_uiSingleShortRangeNukeAbilityID))
					return true;

				/// Not sure where in cast order this goes yet.
				if (Me.RangedAutoAttackOn && CastAbility(m_uiSingleRangedAttackAbilityID))
					return true;

				if (CastGreenOffensiveAbility(m_uiGreenInterruptNukeAbilityID, 2))
					return true;

				if (UseOffensiveItems())
					return true;

				/// Nuke of last resort.
				if (CastGreenOffensiveAbility(m_uiGreenInterruptNukeAbilityID, 1))
					return true;
			}

			return false;
		}

		/************************************************************************************/
		protected override bool OnLogChat(EQ2ParseEngine.ChatEventArgs NewArgs)
		{
			if (base.OnLogChat(NewArgs))
				return true;

			string strTrimmedMessage = NewArgs.Message.Trim();
			string strLowerCaseMessage = strTrimmedMessage.ToLower();

			/// All processing will be deferred to DoNextAction().
			if (strLowerCaseMessage.Contains(m_strJestersCapRequestSubstring))
			{
				PlayerRequest NewRequest = new PlayerRequest(NewArgs.SourceActorName);
				m_JestersCapQueue.Enqueue(NewRequest);
				Program.Log("Jester's Cap request from {0}.", NewArgs.SourceActorName);
				return true;
			}

			return false;
		}

		/************************************************************************************/
		public bool CastJestersCap()
		{
			if (!IsAbilityReady(m_uiJestersCapAbilityID))
				return false;

			while (m_JestersCapQueue.Count > 0)
			{
				PlayerRequest ThisRequest = m_JestersCapQueue.Dequeue();
				if (!m_FriendDictionary.ContainsKey(ThisRequest.m_strName))
				{
					Program.Log("Jester's Cap rejected on {0}; not a friend.", ThisRequest.m_strName);
					continue;
				}

				if (ThisRequest.Age > TimeSpan.FromMinutes(m_fJestersCapRequestTimeoutMinutes))
				{
					Program.Log("Jester's Cap rejected on {0}; request timed out.", ThisRequest.m_strName);
					continue;
				}

				if (!CastAbility(m_uiJestersCapAbilityID, ThisRequest.m_strName, true))
					continue;

				SpamSafeRaidSay(m_strJestersCapCallout, ThisRequest.m_strName);
				return true;
			}

			return false;
		}
	}
}
