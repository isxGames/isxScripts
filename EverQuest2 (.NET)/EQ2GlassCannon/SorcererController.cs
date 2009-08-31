using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2.ISXEQ2;

namespace EQ2GlassCannon
{
	public class SorcererController : MageController
	{
		public List<string> m_astrHateTransferTargets = new List<string>();
		public bool m_bUsePowerFeed = true;
		public double m_fPowerFeedThresholdRatio = 0.05;

		protected uint m_uiWardOfSagesAbilityID = 0;
		protected uint m_uiIceFlameAbilityID = 0;
		protected uint m_uiThunderclapAbilityID = 0;
		protected uint m_uiHateTransferAbilityID = 0;
		protected uint m_uiFreehandSorceryAbilityID = 0;
		protected uint m_uiAmbidexterousCastingAbilityID = 0;
		protected uint m_uiGeneralGreenDeaggroAbilityID = 0;
		protected uint m_uiSinglePowerFeedAbilityID = 0;

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_uiWardOfSagesAbilityID = SelectHighestAbilityID("Ward of Sages");
			m_uiIceFlameAbilityID = SelectHighestTieredAbilityID("Flames of Velious");
			m_uiThunderclapAbilityID = SelectHighestAbilityID("Thunderclap");
			m_uiFreehandSorceryAbilityID = SelectHighestAbilityID("Freehand Sorcery");
			m_uiAmbidexterousCastingAbilityID = SelectHighestAbilityID("Ambidexterous Casting");
			m_uiGeneralGreenDeaggroAbilityID = SelectHighestAbilityID("Concussive");

			return;
		}

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferStringList("Sorceror.HateTransferTargets", m_astrHateTransferTargets);
			ThisFile.TransferBool("Sorceror.UsePowerFeed", ref m_bUsePowerFeed);
			ThisFile.TransferDouble("Sorceror.PowerFeedThresholdRatio", ref m_fPowerFeedThresholdRatio);

			return;
		}

		/************************************************************************************/
		public bool CastAmbidextrousCasting()
		{
			/// Ambidextrous Casting behaves as a combat art and will turn on auto attack if used.
			if (!m_bAutoAttack)
				return false;

			CachedAbility AmbidextrousCastingAbility = GetAbility(m_uiAmbidexterousCastingAbilityID, true);
			if (AmbidextrousCastingAbility != null)
			{
				if (AmbidextrousCastingAbility.TotalCastTimeSpan > CastTimeRemaining)
					return false;

				/// Because we're not tracking the cast timer, this can be a bit spammy.
				if (CastSimultaneousAbility(m_uiAmbidexterousCastingAbilityID))
					return true;
			}

			return false;
		}

		/************************************************************************************/
		public bool CastEmergencyPowerFeed()
		{
			if (!m_bUsePowerFeed || !MeActor.IsIdle)
				return false;

			if (!CanAffordAbilityCost(m_uiSinglePowerFeedAbilityID))
				return false;

			string strLowestPowerName = string.Empty;
			int iLowestPowerAmount = int.MaxValue;
			foreach (VitalStatus ThisStatus in EnumVitalStatuses(true))
			{
				if (ThisStatus.m_bIsDead)
					continue;

				if (ThisStatus.m_iCurrentPower < ThisStatus.m_iMaximumPower)
				{
					/// Select the most vulnerable member, not the biggest power gap.
					/// We're only interested in helping out priests.
					/// Any threshold too high and the fucking sorceror will be powerhealing instead of dps'ing.
					if (ThisStatus.PowerRatio < m_fPowerFeedThresholdRatio && ThisStatus.m_iCurrentPower < iLowestPowerAmount && ThisStatus.IsPriest)
					{
						strLowestPowerName = ThisStatus.m_strName;
						iLowestPowerAmount = ThisStatus.m_iCurrentPower;
					}
				}
			}

			if (!string.IsNullOrEmpty(strLowestPowerName))
			{
				if (CastAbility(m_uiSinglePowerFeedAbilityID, strLowestPowerName, true))
					return true;
			}

			return false;
		}
	}
}
