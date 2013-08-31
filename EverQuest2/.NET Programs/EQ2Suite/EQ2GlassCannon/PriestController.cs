using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2SuiteLib;

namespace EQ2GlassCannon
{
	public class PriestController : PlayerController
	{
		#region INI settings
		protected bool m_bCastCureCurse = true;
		protected bool m_bPrioritizeCureCurse = true;
		protected bool m_bCastDebuffs = true;
		protected bool m_bCastDamageSpells = true;
		protected string m_strSingleRezCallout = "REZZING << {0} >>";
		protected string m_strGroupRezCallout = "REZZING GROUP << {0} >>";
		protected string m_strRaidRezCallout = "REZZING RAID << {0} >>";
		protected bool m_bBuffGroupWaterBreathing = true;
		protected List<string> m_astrSingleWaterBreathingTargets = new List<string>();
		protected bool m_bBuffPhysicalMitigation = true;
		protected StanceType m_eShadowsHealStance = StanceType.Neither;
		protected double m_fHealThresholdRatio = 0.95;
		#endregion

		protected uint m_uiCureAbilityID = 0;
		protected uint m_uiCureCurseAbilityID = 0;
		protected uint m_uiGeneralGroupCureAbilityID = 0;
		protected uint m_uiGeneralSingleDeathSaveAbilityID = 0;
		protected uint m_uiGeneralNonCombatRezAbilityID = 0;
		protected uint m_uiGroupMitigationBuffAbilityID = 0;
		protected uint m_uiGroupWaterBreathingAbilityID = 0;
		protected uint m_uiSingleWaterBreathingAbilityID = 0;
		protected uint m_uiSpiritOfTheWolfAbilityID = 0;
		protected uint m_uiRaidNonCombatRezAbilityID = 0;
		protected uint m_uiShadowsOffensiveHealStance = 0;
		protected uint m_uiShadowsDefensiveHealStance = 0;

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferBool("Priest.CastCureCurse", ref m_bCastCureCurse);
			ThisFile.TransferBool("Priest.PrioritizeCureCurse", ref m_bPrioritizeCureCurse);
			ThisFile.TransferBool("Priest.CastDebuffs", ref m_bCastDebuffs);
			ThisFile.TransferBool("Priest.CastDamageSpells", ref m_bCastDamageSpells);
			ThisFile.TransferString("Priest.SingleRezCallout", ref m_strSingleRezCallout);
			ThisFile.TransferString("Priest.GroupRezCallout", ref m_strGroupRezCallout);
			ThisFile.TransferString("Priest.RaidRezCallout", ref m_strRaidRezCallout);
			ThisFile.TransferBool("Priest.BuffGroupWaterBreathing", ref m_bBuffGroupWaterBreathing);
			//ThisFile.TransferStringList("Priest.SingleWaterBreathingTargets", m_astrSingleWaterBreathingTargets);
			ThisFile.TransferBool("Priest.BuffPhysicalMitigation", ref m_bBuffPhysicalMitigation);
			ThisFile.TransferEnum<StanceType>("Priest.ShadowsHealStance", ref m_eShadowsHealStance);
			ThisFile.TransferDouble("Priest.HealThresholdRatio", ref m_fHealThresholdRatio);

			return;
		}

		/************************************************************************************/
		protected override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_uiCureAbilityID = SelectHighestAbilityID("Cure");
			m_uiCureCurseAbilityID = SelectHighestAbilityID("Cure Curse");
			m_uiGeneralNonCombatRezAbilityID = SelectHighestAbilityID("Revive");
			m_uiSingleWaterBreathingAbilityID = SelectHighestAbilityID("Enduring Breath");
			m_uiSpiritOfTheWolfAbilityID = SelectHighestAbilityID("Spirit of the Wolf");
			m_uiLoreAndLegendAbilityID = SelectHighestAbilityID("Master's Smite");
			m_uiRaidNonCombatRezAbilityID = SelectHighestAbilityID("Supplication of the Fallen");
			return;
		}

		/************************************************************************************/
		/// <summary>
		/// This class is used to decide cure priority.
		/// An excellent cure candidate could potentially be out of range,
		/// so we needed this more comprehensive ranking solution.
		/// </summary>
		protected class SingleCureEvaluationKey : IComparable<SingleCureEvaluationKey>
		{
			public readonly int m_iPotentialCurseCures = 0;
			public readonly int m_iPotentialCures = 0;
			public readonly int m_iActorID = -1;

			public SingleCureEvaluationKey(
				int iPotentialCurseCures,
				int iPotentialCures,
				int iActorID)
			{
				m_iPotentialCurseCures = iPotentialCurseCures;
				m_iPotentialCures = iPotentialCures;
				m_iActorID = iActorID;
				return;
			}

			/// <summary>
			/// We try to have higher priority cures go to the beginning of the list instead of the end.
			/// </summary>
			public int CompareTo(SingleCureEvaluationKey OtherEvaluation)
			{
				int iComparison = -1;

				iComparison = m_iPotentialCurseCures.CompareTo(OtherEvaluation.m_iPotentialCurseCures);
				if (iComparison != 0)
					return iComparison;

				iComparison = m_iPotentialCures.CompareTo(OtherEvaluation.m_iPotentialCures);
				if (iComparison != 0)
					return iComparison;

				/// Actor ID is just a magic number used to prevent duplicate keys.
				iComparison = m_iActorID.CompareTo(OtherEvaluation.m_iActorID);
				if (iComparison != 0)
					return iComparison;

				return 0;
			}
		}

		/************************************************************************************/
		/// <summary>
		/// General purpose cure function for priests.
		/// Evaluates detrimental effects, decides whether single cure or group cure is more appropriate,
		/// and then executes it.
		/// </summary>
		/// <param name="iGroupCureAbilityID"></param>
		/// <param name="bCanGroupTrauma"></param>
		/// <param name="bCanGroupArcane"></param>
		/// <param name="bCanGroupNoxious"></param>
		/// <param name="bCanGroupElemental"></param>
		/// <returns></returns>
		public bool AttemptCures(bool bCanGroupTrauma, bool bCanGroupArcane, bool bCanGroupNoxious, bool bCanGroupElemental)
		{
			if ((!m_bCastCures && !m_bCastCureCurse) || !IsIdle)
				return false;

			bool bTrySingleCure = m_bCastCures && IsAbilityReady(m_uiCureAbilityID);
			bool bTryGroupCure = m_bCastCures && IsAbilityReady(m_uiGeneralGroupCureAbilityID);
			bool bTryCureCurse = m_bCastCureCurse && IsAbilityReady(m_uiCureCurseAbilityID);
			if (!bTrySingleCure && !bTryGroupCure && !bTryCureCurse)
				return false;

			SortedDictionary<SingleCureEvaluationKey, string> CurePriorityList = new SortedDictionary<SingleCureEvaluationKey, string>();
			int iGroupCureCandidateCount = 0;

			foreach (VitalStatus ThisStatus in EnumVitalStatuses(m_bCureUngroupedMainTank))
			{
				int iPotentialCuresAtOnce = 0;
				bool bGroupCurable = false;

				if (ThisStatus.m_iTrauma > 0)
				{
					bGroupCurable = (bGroupCurable || bCanGroupTrauma);
					iPotentialCuresAtOnce++;
				}
				if (ThisStatus.m_iArcane > 0)
				{
					bGroupCurable = (bGroupCurable || bCanGroupArcane);
					iPotentialCuresAtOnce++;
				}
				if (ThisStatus.m_iNoxious > 0)
				{
					bGroupCurable = (bGroupCurable || bCanGroupNoxious);
					iPotentialCuresAtOnce++;
				}
				if (ThisStatus.m_iElemental > 0)
				{
					bGroupCurable = (bGroupCurable || bCanGroupElemental);
					iPotentialCuresAtOnce++;
				}

				if (bGroupCurable)
					iGroupCureCandidateCount++;

				if (ThisStatus.m_iCursed > 0 || iPotentialCuresAtOnce > 0)
				{
					SingleCureEvaluationKey NewKey =
						new SingleCureEvaluationKey(
							ThisStatus.m_iCursed,
							iPotentialCuresAtOnce,
							ThisStatus.m_Actor.ID);
					CurePriorityList.Add(NewKey, ThisStatus.m_Actor.Name);
				}
			}

			/// There's no strict rule on when to cast a group cure; we just fudge it here.
			if (bTryGroupCure && iGroupCureCandidateCount >= 3)
				return CastAbilityOnSelf(m_uiGeneralGroupCureAbilityID);

			else if (CurePriorityList.Count > 0)
			{
				/// Go down the list until we find someone we can cure, who is within range.
				foreach (KeyValuePair<SingleCureEvaluationKey, string> ThisPair in CurePriorityList)
				{
					if (bTryCureCurse && (ThisPair.Key.m_iPotentialCurseCures > 0) && CastAbility(m_uiCureCurseAbilityID, ThisPair.Value, true))
						return true;

					if (bTrySingleCure && (ThisPair.Key.m_iPotentialCures > 0) && CastAbility(m_uiCureAbilityID, ThisPair.Value, true))
						return true;
				}
			}

			return false;
		}

		/************************************************************************************/
		public bool CheckSpiritOfTheWolf()
		{
			/// This is a distracting spell when over 30 effects are maintained; the bot will never see it after it gets put up.
			/// So unfortunately we hide it for now.
			return false;

			/// We use a simple logic: if I'm not in combat and *I* don't have SOW, then I cast it on myself.
			//return (m_iSpiritOfTheWolfAbilityID != -1) && !Me.IsHated && !IsBeneficialEffectPresent(m_iSpiritOfTheWolfAbilityID) && CastAbilityOnSelf(m_iSpiritOfTheWolfAbilityID);
		}

		/************************************************************************************/
		public bool CheckWaterBreathingBuffs()
		{
			/// Only spend time casting the buffs if we need to.
			/// This is not time we want to take up during a big fight.
			if (MeActor.IsSwimming || !IsInCombat)
			{
				if (m_bBuffGroupWaterBreathing)
				{
					if (CheckToggleBuff(m_uiGroupWaterBreathingAbilityID, true))
						return true;
				}

				/// Blah. This won't work because Enduring Breath isn't a maintained spell.
				/// Leave it blank in the configuration for now.
				if (CheckSingleTargetBuffs(m_uiSingleWaterBreathingAbilityID, m_astrSingleWaterBreathingTargets))
					return true;
			}
			else
			{
				if (CheckToggleBuff(m_uiGroupWaterBreathingAbilityID, m_bBuffGroupWaterBreathing))
					return true;
			}

			return false;
		}

		/************************************************************************************/
		public bool CheckShadowsHealStanceBuffs()
		{
			return CheckStanceBuff(m_uiShadowsOffensiveHealStance, m_uiShadowsDefensiveHealStance, m_eShadowsHealStance);
		}

		/************************************************************************************/
		protected bool CastNonCombatRaidRez(string strNearestDeadName)
		{
			if (!IsIdle)
				return false;

			if (!CastAbility(m_uiRaidNonCombatRezAbilityID, strNearestDeadName, false))
				return false;

			SpamSafeRaidSay(m_strRaidRezCallout, strNearestDeadName);
			return true;
		}

		/************************************************************************************/
		/// <summary>
		/// Arguably this could be exposed to all subclasses,
		/// but it's only useful for classes that potentially never cast offensively.
		/// </summary>
		public bool IsIllusionistSoothingMindActive()
		{
			return IsBeneficialEffectPresent("Soothing Mind");
		}

		/************************************************************************************/
		/// <summary>
		/// Arguably this could be exposed to all subclasses...
		/// </summary>
		public bool IsClericDivineRecoveryActive()
		{
			return IsBeneficialEffectPresent("Divine Recovery");
		}
	}
}
