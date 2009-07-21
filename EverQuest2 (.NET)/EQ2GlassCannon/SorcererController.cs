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
		protected override void TransferINISettings(TransferType eTransferType)
		{
			base.TransferINISettings(eTransferType);

			TransferINIString(eTransferType, "Sorceror.HateTransferTarget", ref m_strHateTransferTarget);
			TransferINIBool(eTransferType, "Sorceror.UsePowerFeed", ref m_bUsePowerFeed);

			return;
		}

		/************************************************************************************/
		public bool AttemptEmergencyPowerFeed()
		{
			if (!m_bUsePowerFeed || !MeActor.IsIdle || !IsAbilityReady(m_iSinglePowerFeedAbilityID))
				return false;

			Ability ThisAbility = Me.Ability(m_iSinglePowerFeedAbilityID);
			if (Me.Health < ThisAbility.HealthCost)
				return false;

			string strLowestPowerName = string.Empty;
			int iLowestPowerAmount = int.MaxValue;
			foreach (VitalStatus ThisStatus in EnumVitalStatuses(true))
			{
				if (ThisStatus.m_bIsDead)
					continue;

				if (ThisStatus.m_iCurrentPower < ThisStatus.m_iMaximumPower)
				{
					double fPowerRatio = (double)ThisStatus.m_iCurrentPower / (double)ThisStatus.m_iMaximumPower;

					/// Select the most vulnerable member, not the biggest power gap.
					/// We're only interested in helping out priests.
					if (fPowerRatio < 0.30 && ThisStatus.m_iCurrentPower < iLowestPowerAmount && ThisStatus.IsPriest)
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
