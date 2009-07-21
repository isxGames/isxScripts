using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2.ISXEQ2;

namespace EQ2GlassCannon
{
	public class PriestController : PlayerController
	{
		#region INI settings
		public bool m_bCastCureCurse = true;
		public bool m_bPrioritizeCureCurse = true;
		public bool m_bCastDebuffs = true;
		public bool m_bCastDamageSpells = true;
		public string m_strSingleRezCallout = "REZZING << {0} >>";
		public string m_strGroupRezCallout = "REZZING GROUP << {0} >>";
		public bool m_bBuffGroupWaterBreathing = true;
		#endregion

		public int m_iCureAbilityID = -1;
		public int m_iCureCurseAbilityID = -1;
		public int m_iGeneralGroupCureAbilityID = -1;
		public int m_iGeneralSingleDeathSaveAbilityID = -1;
		public int m_iGeneralNonCombatRezAbilityID = -1;
		public int m_iGroupWaterBreathingAbilityID = -1;
		public int m_iSpiritOfTheWolfAbilityID = -1;

		/************************************************************************************/
		protected override void TransferINISettings(PlayerController.TransferType eTransferType)
		{
			base.TransferINISettings(eTransferType);

			TransferINIBool(eTransferType, "Priest.CastCureCurse", ref m_bCastCureCurse);
			TransferINIBool(eTransferType, "Priest.PrioritizeCureCurse", ref m_bPrioritizeCureCurse);
			TransferINIBool(eTransferType, "Priest.CastDebuffs", ref m_bCastDebuffs);
			TransferINIBool(eTransferType, "Priest.CastDamageSpells", ref m_bCastDamageSpells);
			TransferINIString(eTransferType, "Priest.SingleRezCallout", ref m_strSingleRezCallout);
			TransferINIString(eTransferType, "Priest.GroupRezCallout", ref m_strGroupRezCallout);
			TransferINIBool(eTransferType, "Priest.BuffGroupWaterBreathing", ref m_bBuffGroupWaterBreathing);

			return;
		}

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_iCureAbilityID = SelectHighestAbilityID("Cure");
			m_iCureCurseAbilityID = SelectHighestAbilityID("Cure Curse");
			m_iGeneralNonCombatRezAbilityID = SelectHighestAbilityID("Revive");
			m_iSpiritOfTheWolfAbilityID = SelectHighestAbilityID("Spirit of the Wolf");
			m_iLoreAndLegendAbilityID = SelectHighestAbilityID("Master's Smite");
			return;
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
			if (!m_bCastCures || Me.IsMoving)
				return false;

			bool bGroupCureAvailable = IsAbilityReady(m_iGeneralGroupCureAbilityID);
			if (!IsAbilityReady(m_iCureAbilityID) && !bGroupCureAvailable)
				return false;

			string strBestSingleCureCandidate = string.Empty;
			int iMostPotentialCuresAtOnce = 0;
			int iTotalTraumaBearers = 0;
			int iTotalArcaneBearers = 0;
			int iTotalNoxiousBearers = 0;
			int iTotalElementalBearers = 0;

			foreach (VitalStatus ThisStatus in EnumVitalStatuses(m_bCureMainTank))
			{
				/// Example: If a group-wide effect is in place,
				/// and then a horrible single-target effect is placed on,
				/// the best cure candidate will have 2 effects as opposed to 1 like everyone else.
				/// This works on Wuoshi for instance.
				int iPotentialCuresAtOnce = 0;

				if (ThisStatus.m_iTrauma > 0)
				{
					iTotalTraumaBearers++;
					iPotentialCuresAtOnce++;
				}
				if (ThisStatus.m_iArcane > 0)
				{
					iTotalArcaneBearers++;
					iPotentialCuresAtOnce++;
				}
				if (ThisStatus.m_iNoxious > 0)
				{
					iTotalNoxiousBearers++;
					iPotentialCuresAtOnce++;
				}
				if (ThisStatus.m_iElemental > 0)
				{
					iTotalElementalBearers++;
					iPotentialCuresAtOnce++;
				}

				if (iPotentialCuresAtOnce > iMostPotentialCuresAtOnce && string.IsNullOrEmpty(strBestSingleCureCandidate))
					strBestSingleCureCandidate = ThisStatus.m_strName;
			}

			/// There's no strict rule on when to cast a group cure; we just fudge it here.
			if (bGroupCureAvailable &&
				(
				(bCanGroupTrauma && iTotalTraumaBearers >= 3) ||
				(bCanGroupArcane && iTotalArcaneBearers >= 3) ||
				(bCanGroupNoxious && iTotalNoxiousBearers >= 3) ||
				(bCanGroupElemental && iTotalElementalBearers >= 3)
				)
				)
			{
				return CastAbility(m_iGeneralGroupCureAbilityID, Me.Name, true);
			}
			else if (!string.IsNullOrEmpty(strBestSingleCureCandidate))
			{
				return CastAbility(m_iCureAbilityID, strBestSingleCureCandidate, true);
			}

			if (m_bCastCureCurse)
			{
			}

			return false;
		}

		/************************************************************************************/
		public void EvaluateHealSituation(
			ref bool bBuffsAdvisable,
			ref string strHealTarget,
			ref bool bGroupHealNeeded,
			ref string strRezTarget,
			ref bool bGroupRezNeeded)
		{
		}

		/************************************************************************************/
		public bool CheckSpiritOfTheWolf()
		{
			/// This is a distracting spell when over 30 effects are maintained; the bot will never see it after it gets put up.
			/// So unfortunately we hide it for now.
			return false;

			/// We use a simple logic: if I'm not in combat and *I* don't have SOW, then I cast it on myself.
			//return (m_iSpiritOfTheWolfAbilityID != -1) && !Me.IsHated && !IsBeneficialEffectPresent(m_iSpiritOfTheWolfAbilityID) && CastAbility(m_iSpiritOfTheWolfAbilityID, Me.Name, true);
		}

		/************************************************************************************/
		public bool CheckGroupWaterBreathingBuff()
		{
			if (m_bBuffGroupWaterBreathing)
			{
				/// Only turn it back on if we need to.
				if ((MeActor.IsSwimming || !MeActor.InCombatMode) && CheckToggleBuff(m_iGroupWaterBreathingAbilityID, true))
					return true;
			}
			else
			{
				if (CheckToggleBuff(m_iGroupWaterBreathingAbilityID, false))
					return true;
			}

			return false;
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
