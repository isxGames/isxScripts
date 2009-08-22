using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2.ISXEQ2;

namespace EQ2GlassCannon
{
	public class SorcererController : MageController
	{
		public string m_strHateTransferTarget = string.Empty;
		public bool m_bUsePowerFeed = true;
		public double m_fPowerFeedThresholdRatio = 0.05;

		public int m_iWardOfSagesAbilityID = -1;
		public int m_iIceFlameAbilityID = -1;
		public int m_iThunderclapAbilityID = -1;
		public int m_iHateTransferAbilityID = -1;
		public int m_iFreehandSorceryAbilityID = -1;
		public int m_iAmbidexterousCastingAbilityID = -1;
		public int m_iGeneralGreenDeaggroAbilityID = -1;
		public int m_iSinglePowerFeedAbilityID = -1;

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_iWardOfSagesAbilityID = SelectHighestAbilityID("Ward of Sages");

			m_iIceFlameAbilityID = SelectHighestAbilityID(
				"Ice Flame",
				"Glacialflame",
				"Flames of Velious");

			m_iThunderclapAbilityID = SelectHighestAbilityID("Thunderclap");
			m_iFreehandSorceryAbilityID = SelectHighestAbilityID("Freehand Sorcery");
			m_iAmbidexterousCastingAbilityID = SelectHighestAbilityID("Ambidexterous Casting");
			m_iGeneralGreenDeaggroAbilityID = SelectHighestAbilityID("Concussive");

			return;
		}

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferString("Sorceror.HateTransferTarget", ref m_strHateTransferTarget);
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

			/// It fucks up our casting timer but IsCasting is resilient enough to manage.
			CachedAbility AmbidextrousCastingAbility = GetAbility(m_iAmbidexterousCastingAbilityID, true);
			if (AmbidextrousCastingAbility != null)
			{
				TimeSpan TotalCastTimeSpan = TimeSpan.FromSeconds(AmbidextrousCastingAbility.m_fCastTimeSeconds + AmbidextrousCastingAbility.m_fRecoveryTimeSeconds);
				if (TotalCastTimeSpan > CastTimeRemaining)
					return false;

				if (CastAbility(m_iAmbidexterousCastingAbilityID))
					return true;
			}

			return false;
		}

		/************************************************************************************/
		public bool CastEmergencyPowerFeed()
		{
			if (!m_bUsePowerFeed || !MeActor.IsIdle)
				return false;

			if (!CanAffordAbilityCost(m_iSinglePowerFeedAbilityID))
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
				if (CastAbility(m_iSinglePowerFeedAbilityID, strLowestPowerName, true))
					return true;
			}

			return false;
		}
	}
}
