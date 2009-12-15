using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2.ISXEQ2;
using EQ2SuiteLib;

namespace EQ2GlassCannon
{
	public class SorcererController : MageController
	{
		protected enum KingdomOfSkyPetType
		{
			None = 0,
			AnimatedTome, /// 2.9% spell crit @80
			Gargoyle, /// 4.0% less hate gain @80
			Drake, /// 2.0% reuse haste @80
		}

		protected List<string> m_astrHateTransferTargets = new List<string>();
		protected bool m_bUsePowerFeed = true;
		protected double m_fPowerFeedThresholdRatio = 0.05;
		protected KingdomOfSkyPetType m_eKingdomOfSkyPet = KingdomOfSkyPetType.AnimatedTome;

		protected uint m_uiWardOfSagesAbilityID = 0;
		protected uint m_uiFlamesOfVeliousAbilityID = 0;
		protected uint m_uiThunderclapAbilityID = 0;
		protected uint m_uiHateTransferAbilityID = 0;
		protected uint m_uiFreehandSorceryAbilityID = 0;
		protected uint m_uiAmbidexterousCastingAbilityID = 0;
		protected uint m_uiGeneralGreenDeaggroAbilityID = 0;
		protected uint m_uiSinglePowerFeedAbilityID = 0;
		protected uint m_uiSummonAnimatedTomeAbilityID = 0;
		protected uint m_uiSummonGargoyleAbilityID = 0;
		protected uint m_uiSummonDrakeAbilityID = 0;

		/************************************************************************************/
		protected override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_uiWardOfSagesAbilityID = SelectHighestAbilityID("Ward of Sages");
			m_uiFlamesOfVeliousAbilityID = SelectHighestTieredAbilityID("Flames of Velious");
			m_uiThunderclapAbilityID = SelectHighestAbilityID("Thunderclap");
			m_uiFreehandSorceryAbilityID = SelectHighestAbilityID("Freehand Sorcery");
			m_uiAmbidexterousCastingAbilityID = SelectHighestAbilityID("Ambidexterous Casting");
			m_uiGeneralGreenDeaggroAbilityID = SelectHighestAbilityID("Concussive");
			m_uiSummonAnimatedTomeAbilityID = SelectHighestAbilityID("Summon Animated Tome");
			m_uiSummonGargoyleAbilityID = SelectHighestAbilityID("Summon Gargoyle");
			m_uiSummonDrakeAbilityID = SelectHighestAbilityID("Summon Drake");
			return;
		}

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferStringList("Sorceror.HateTransferTargets", m_astrHateTransferTargets);
			ThisFile.TransferBool("Sorceror.UsePowerFeed", ref m_bUsePowerFeed);
			ThisFile.TransferDouble("Sorceror.PowerFeedThresholdRatio", ref m_fPowerFeedThresholdRatio);
			ThisFile.TransferEnum<KingdomOfSkyPetType>("Sorceror.KingdomOfSkyPet", ref m_eKingdomOfSkyPet);

			return;
		}

		/************************************************************************************/
		protected bool CheckKingdomOfSkyPet()
		{
			if (!IsIdle)
				return false;

			/// Cancel the wrong pet.
			if (m_eKingdomOfSkyPet != KingdomOfSkyPetType.AnimatedTome && CancelMaintained(m_uiSummonAnimatedTomeAbilityID, true))
				return true;
			if (m_eKingdomOfSkyPet != KingdomOfSkyPetType.Gargoyle && CancelMaintained(m_uiSummonGargoyleAbilityID, true))
				return true;
			if (m_eKingdomOfSkyPet != KingdomOfSkyPetType.Drake && CancelMaintained(m_uiSummonDrakeAbilityID, true))
				return true;

			/// Cast the correct pet.
			if (!MeActor.InCombatMode || m_bSummonPetDuringCombat)
			{
				if (m_eKingdomOfSkyPet == KingdomOfSkyPetType.AnimatedTome && !IsAbilityMaintained(m_uiSummonAnimatedTomeAbilityID) && CastAbilityOnSelf(m_uiSummonAnimatedTomeAbilityID))
					return true;
				if (m_eKingdomOfSkyPet == KingdomOfSkyPetType.Gargoyle && !IsAbilityMaintained(m_uiSummonGargoyleAbilityID) && CastAbilityOnSelf(m_uiSummonGargoyleAbilityID))
					return true;
				if (m_eKingdomOfSkyPet == KingdomOfSkyPetType.Drake && !IsAbilityMaintained(m_uiSummonDrakeAbilityID) && CastAbilityOnSelf(m_uiSummonDrakeAbilityID))
					return true;
			}

			/// Now hide the pet if it is visible.
			/// When not visible, it doesn't even appear on the actor map.
			/// This is non-essential; don't fuck with it during combat.
			if (!MeActor.InCombatMode)
			{
				bool bPetFound = false;
				string strGuildName = string.Format("{0}'s familiar", Name);
				foreach (Actor ThisActor in EnumActors())
				{
					/// This is just a weird set of conditions that I have found to be the case with the AA pet.
					if (ThisActor.Guild == strGuildName && ThisActor.IsAPet && ThisActor.IsIdle && ThisActor.InCombatMode)
					{
						bPetFound = true;
						break;
					}
				}
				
				if (bPetFound)
					RunCommand(1, "/pet hide");
			}

			return false;
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
			if (!m_bUsePowerFeed || !IsIdle)
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
