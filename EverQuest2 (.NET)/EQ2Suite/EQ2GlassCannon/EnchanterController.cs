using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2SuiteLib;

namespace EQ2GlassCannon
{
	public class EnchanterController : MageController
	{
		#region INI settings
		protected bool m_bBuffArcaneResistance = false;
		protected bool m_bBuffRegen = true;
		protected bool m_bUseManaFlow = true;
		protected double m_fManaFlowThresholdRatio = 0.9;
		protected string m_strPeaceOfMindCallout = "Peace of Mind INC (20 sec, damage proc on any offensive action)";
		#endregion

		#region Ability IDs
		protected uint m_uiArcaneBuffAbilityID = 0;
		protected uint m_uiMainRegenBuffAbilityID = 0;
		protected uint m_uiManaFlowAbilityID = 0;
		protected uint m_uiChronosiphoningAbilityID = 0;
		protected uint m_uiManaCloakAbilityID = 0;
		protected uint m_uiNullifyingStaffAbilityID = 0;
		protected uint m_uiSpellbladeCounterAbilityID = 0;
		protected uint m_uiPeaceOfMindAbilityID = 0;
		protected uint m_uiBlinkAbilityID = 0;
		#endregion

		/************************************************************************************/
		protected override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_uiManaFlowAbilityID = SelectHighestAbilityID("Mana Flow");
			m_uiChronosiphoningAbilityID = SelectHighestAbilityID("Chronosiphoning");
			m_uiManaCloakAbilityID = SelectHighestTieredAbilityID("Mana Cloak");
			m_uiNullifyingStaffAbilityID = SelectHighestAbilityID("Nullifying Staff");
			m_uiSpellbladeCounterAbilityID = SelectHighestAbilityID("Spellblade's Counter");
			m_uiPeaceOfMindAbilityID = SelectHighestAbilityID("Peace of Mind");
			m_uiBlinkAbilityID = SelectHighestAbilityID("Blink");

			return;
		}

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferBool("Enchanter.BuffArcaneResistance", ref m_bBuffArcaneResistance);
			ThisFile.TransferBool("Enchanter.BuffRegen", ref m_bBuffRegen);
			ThisFile.TransferBool("Enchanter.UseManaFlow", ref m_bUseManaFlow);
			ThisFile.TransferDouble("Enchanter.ManaFlowThresholdRatio", ref m_fManaFlowThresholdRatio);
			ThisFile.TransferString("Enchanter.PeaceOfMindCallout", ref m_strPeaceOfMindCallout);

			return;
		}

		/************************************************************************************/
		protected bool CheckManaFlow()
		{
			if (!m_bUseManaFlow || !IsIdle || !IsAbilityReady(m_uiManaFlowAbilityID))
				return false;

			/// Mana Flow requires 10%; make sure we have 15%.
			VitalStatus MyStatus = null;
			if (GetVitalStatus(Name, ref MyStatus) && MyStatus.PowerRatio < 0.15f)
				return false;

			string strLowestPowerName = string.Empty;
			int iLowestPowerAmount = int.MaxValue;
			foreach (VitalStatus ThisStatus in EnumVitalStatuses(true))
			{
				if (ThisStatus.m_bIsDead)
					continue;

				if (ThisStatus.m_iCurrentPower < ThisStatus.m_iMaximumPower)
				{
					double fPowerRatio = ThisStatus.PowerRatio;

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
				if (CastAbility(m_uiManaFlowAbilityID, strLowestPowerName, true))
					return true;
			}

			return false;
		}
	}
}
