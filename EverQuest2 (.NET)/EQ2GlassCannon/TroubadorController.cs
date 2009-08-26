using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2.ISXEQ2;

namespace EQ2GlassCannon
{
	public class TroubadorController : BardController
	{
		public class PlayerRequest
		{
			public DateTime m_Timestamp = DateTime.Now;

			public TimeSpan Age
			{
				get
				{
					return DateTime.Now - m_Timestamp;
				}
			}

			public string m_strName = string.Empty;
			public PlayerRequest(string strName)
			{
				m_strName = strName;
				return;
			}
		}

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
		public string m_strUpbeatTempoTarget = string.Empty;
		public string m_strJestersCapRequestSubstring = "JC ME";
		public string m_strJestersCapCallout = "JESTER'S CAP ON >> {0} <<";
		public double m_fJestersCapRequestTimeoutMinutes = 1.0;
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
		public int m_iSingleRangedAttackAbilityID = -1;
		public int m_iGreenInterruptNukeAbilityID = -1;
		public int m_iGreenInstantKnockdownAbilityID = -1;
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
			ThisFile.TransferString("Troubador.UpbeatTempoTarget", ref m_strUpbeatTempoTarget);
			ThisFile.TransferCaselessString("Troubador.JestersCapRequestSubstring", ref m_strJestersCapRequestSubstring);
			ThisFile.TransferString("Troubador.JestersCapCallout", ref m_strJestersCapCallout);
			ThisFile.TransferDouble("Troubador.JestersCapRequestTimeoutMinutes", ref m_fJestersCapRequestTimeoutMinutes);
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
			m_iSingleRangedAttackAbilityID = SelectHighestTieredAbilityID("Singing Shot");
			m_iGreenInterruptNukeAbilityID = SelectHighestTieredAbilityID("Painful Lamentations");
			m_iGreenInstantKnockdownAbilityID = SelectHighestTieredAbilityID("Breathtaking Bellow");

			return;
		}

		/************************************************************************************/
		public override bool DoNextAction()
		{
			if (base.DoNextAction() || MeActor.IsDead)
				return true;

			if (IsCasting)
			{
				return true;
			}

			if (UseSpellGeneratedHealItem())
				return true;
			if (DisarmChests())
				return true;
			if (CastJestersCap())
				return true;

			if (m_bCheckBuffsNow && MeActor.IsStealthed && !MeActor.InCombatMode)
			{
				/// I'm sick and tired of Shroud lingering on after combat.
				if (CancelMaintained(m_iShroudAbilityID, true))
					return true;
			}
			else if (m_bCheckBuffsNow && !MeActor.IsStealthed)
			{
				/// Time is of the essence when rebuffing after a wipe!
				if (!MeActor.InCombatMode && CheckToggleBuff(m_iGroupRunSpeedBuffAbilityID, true))
					return true;

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

				if (CheckSingleTargetBuffs(m_iUpbeatTempoAbilityID, m_strUpbeatTempoTarget))
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

				if (!EngageOffensiveTarget())
					return false;

				/// We put the stealth check so early on because it is so easily wasted by the wrong thing.
				/// Troubadors only have one stealth attack.
				if (MeActor.IsStealthed && CastAbility(m_iSingleINTDebuffAbilityID))
					return true;

				if (m_bIHaveAggro)
				{
					if (CastAbility(m_iEvasiveManeuversAbilityID))
						return true;

					if (CastAbility(m_iSingleDeaggroAbilityID))
						return true;

					if (UseDeaggroItems())
						return true;
				}

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

				if (CastLoreAndLegendAbility())
					return true;

				if (CastAbility(m_iSingleDefenseDebuffAbilityID))
					return true;

				if (CastAbility(m_iHalfElfMitigationDebuffAbilityID))
					return true;

				if (CastAbilityFromFlankingOrBehind(m_iSingleResistDebuffAbilityID))
					return true;

				/// We now cast stealth to allow the use of our INT debuff, Night Strike.
				/// On the very next DoNextAction(), we'll see ourselves stealthed and execute the debuff.
				/// It takes some luck though. We cast stealth but the server doesn't tell us we're stealthed yet,
				/// so we use other spells and break the stealth on accident.
				if (!IsAbilityMaintained(m_iSingleINTDebuffAbilityID))
				{
					CachedAbility DebuffAbility = GetAbility(m_iSingleINTDebuffAbilityID, true);
					if (DebuffAbility != null && DebuffAbility.m_fTimeUntilReady == 0.0) /// IsReady will always be false if not stealthed.
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

				/// Not sure where in cast order this goes yet.
				if (Me.RangedAutoAttackOn && CastAbility(m_iSingleRangedAttackAbilityID))
					return true;

				if (CastGreenOffensiveAbility(m_iGreenInterruptNukeAbilityID, 2))
					return true;

				if (UseOffensiveItems())
					return true;

				/// Nuke of last resort.
				if (CastGreenOffensiveAbility(m_iGreenInterruptNukeAbilityID, 1))
					return true;
			}

			return false;
		}

		/************************************************************************************/
		public override bool OnIncomingChatText(int iChannel, string strFrom, string strMessage)
		{
			if (base.OnIncomingChatText(iChannel, strFrom, strMessage))
				return true;

			string strTrimmedMessage = strMessage.Trim();
			string strLowerCaseMessage = strTrimmedMessage.ToLower();

			/// All processing will be deferred to DoNextAction().
			if (strLowerCaseMessage.Contains(m_strJestersCapRequestSubstring))
			{
				PlayerRequest NewRequest = new PlayerRequest(strFrom);
				m_JestersCapQueue.Enqueue(NewRequest);
				Program.Log("Jester's Cap request from {0}.", strFrom);
				return true;
			}

			return false;
		}

		/************************************************************************************/
		public bool CastJestersCap()
		{
			if (!IsAbilityReady(m_iJestersCapAbilityID))
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

				if (!CastAbility(m_iJestersCapAbilityID, ThisRequest.m_strName, true))
					continue;

				SpamSafeRaidSay(m_strJestersCapCallout, ThisRequest.m_strName);
				return true;
			}

			return false;
		}
	}
}
