using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2GlassCannon
{
	public class EnchanterController : MageController
	{
		#region INI settings
		public bool m_bBuffRegen = true;
		public bool m_bUseManaFlow = true;
		public double m_fManaFlowThresholdRatio = 0.9;
		#endregion

		public int m_iMainRegenBuffAbilityID = -1;
		public int m_iManaFlowAbilityID = -1;
		public int m_iChronosiphoningAbilityID = -1;
		public int m_iManaRegenReactiveAbilityID = -1;
		public int m_iNullifyingStaffAbilityID = -1;
		public int m_iSpellbladeCounterAbilityID = -1;
		public int m_iPeaceOfMindAbilityID = -1;
		public int m_iBlinkAbilityID = -1;

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_iManaFlowAbilityID = SelectHighestAbilityID("Mana Flow");
			m_iChronosiphoningAbilityID = SelectHighestAbilityID("Chronosiphoning");
			m_iManaRegenReactiveAbilityID = SelectHighestTieredAbilityID("Mana Cloak");
			m_iNullifyingStaffAbilityID = SelectHighestAbilityID("Nullifying Staff");
			m_iSpellbladeCounterAbilityID = SelectHighestAbilityID("Spellblade's Counter");
			m_iPeaceOfMindAbilityID = SelectHighestAbilityID("Peace of Mind");
			m_iBlinkAbilityID = SelectHighestAbilityID("Blink");

			return;
		}

		/************************************************************************************/
		protected override void TransferINISettings(PlayerController.TransferType eTransferType)
		{
			base.TransferINISettings(eTransferType);

			TransferINIBool(eTransferType, "Enchanter.BuffRegen", ref m_bBuffRegen);
			TransferINIBool(eTransferType, "Enchanter.UseManaFlow", ref m_bUseManaFlow);
			TransferINIDouble(eTransferType, "Enchanter.ManaFlowThresholdRatio", ref m_fManaFlowThresholdRatio);

			return;
		}

		/************************************************************************************/
		public bool CheckManaFlow()
		{
			if (!m_bUseManaFlow || !MeActor.IsIdle || !IsAbilityReady(m_iManaFlowAbilityID))
				return false;

			/// Mana Flow requires 10%; make sure we have 15%.
			double fMyPowerRatio = ((double)Me.Power / (double)Me.MaxPower);
			if (fMyPowerRatio < 0.15f)
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
					if (fPowerRatio < m_fManaFlowThresholdRatio && ThisStatus.m_iCurrentPower < iLowestPowerAmount)
					{
						strLowestPowerName = ThisStatus.m_strName;
						iLowestPowerAmount = ThisStatus.m_iCurrentPower;
					}
				}
			}

			if (!string.IsNullOrEmpty(strLowestPowerName))
			{
				if (CastAbility(m_iManaFlowAbilityID, strLowestPowerName, true))
					return true;
			}

			return false;
		}
	}
}
