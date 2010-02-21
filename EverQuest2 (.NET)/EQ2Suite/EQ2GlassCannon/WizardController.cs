using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using EQ2.ISXEQ2;
using EQ2SuiteLib;

namespace EQ2GlassCannon
{
	public class WizardController : SorcererController
	{
		protected List<string> m_astrFlametongueTargets = new List<string>();
		protected string m_strIceShieldTarget = string.Empty;
		protected string m_strGiftCallout = string.Empty;

		protected uint m_uiSTRINTBuffAbilityID = 0;
		protected uint m_uiElementalBuffAbilityID = 0;
		protected uint m_uiSnowFilledStepsAbilityID = 0;
		protected uint m_uiMailOfFrostAbilityID = 0;
		protected uint m_uiFlametongueAbilityID = 0;
		protected uint m_uiGiftAbilityID = 0;
		protected uint m_uiIceshapeAbilityID = 0;
		protected uint m_uiSurgeAbilityID = 0;
		protected uint m_uiFireshapeAbilityID = 0;
		protected uint m_uiFieryBlastAbilityID = 0;

		protected uint m_uiWarmBloodedPassiveAbilityID = 0;

		protected uint m_uiColdDamageShieldAbilityID = 0;
		protected uint m_uiFurnaceOfRoAbilityID = 0;
		protected uint m_uiFirestormAbilityID = 0;
		protected uint m_uiGreenColdAEAbilityID = 0;
		protected uint m_uiStormOfLightningAbilityID = 0;
		protected uint m_uiRaysOfDisintegrationAbilityID = 0;
		protected uint m_uiStormingTempestAbilityID = 0;
		protected uint m_uiProtoflameAbilityID = 0;
		protected uint m_uiHailStormAbilityID = 0;
		protected uint m_uiFusionAbilityID = 0;
		protected uint m_uiIceCometAbilityID = 0;
		protected uint m_uiBallOfFireAbilityID = 0;
		protected uint m_uiImmolationAbilityID = 0;
		protected uint m_uiMagmaChamberAbilityID = 0;
		protected uint m_uiElementalDebuffAbilityID = 0;
		protected uint m_uiIncinerateAbilityID = 0;
		protected uint m_uiLightningBurstAbilityID = 0;
		protected uint m_uiSingleDeaggroAbilityID = 0;

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferStringList("Wizard.FlametongueTargets", m_astrFlametongueTargets);
			ThisFile.TransferString("Wizard.IceShieldTarget", ref m_strIceShieldTarget);
			ThisFile.TransferString("Wizard.GiftCallout", ref m_strGiftCallout);
			return;
		}

		/************************************************************************************/
		protected override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_uiSTRINTBuffAbilityID = SelectHighestTieredAbilityID("Tyrant's Pact");
			m_uiElementalBuffAbilityID = SelectHighestTieredAbilityID("Fortify Elements");
			m_uiSnowFilledStepsAbilityID = SelectHighestAbilityID("Snow-filled Steps");
			m_uiMailOfFrostAbilityID = SelectHighestAbilityID("Mail of Frost");
			m_uiHateTransferAbilityID = SelectHighestTieredAbilityID("Converge");
			m_uiFlametongueAbilityID = SelectHighestTieredAbilityID("Ro's Blade");
			m_uiSinglePowerFeedAbilityID = SelectHighestTieredAbilityID("Mana Intromission");
			m_uiGiftAbilityID = SelectHighestTieredAbilityID("Frigid Gift");
			m_uiIceshapeAbilityID = SelectHighestAbilityID("Iceshape");
			m_uiSurgeAbilityID = SelectHighestTieredAbilityID("Surge of Ro");
			m_uiFireshapeAbilityID = SelectHighestAbilityID("Fireshape");
			m_uiFieryBlastAbilityID = SelectHighestAbilityID("Fiery Blast");

			m_uiWarmBloodedPassiveAbilityID = SelectHighestAbilityID("Warm Blooded");

			m_uiColdDamageShieldAbilityID = SelectHighestTieredAbilityID("Iceshield");
			m_uiFurnaceOfRoAbilityID = SelectHighestTieredAbilityID("Furnace of Ro");
			m_uiFirestormAbilityID = SelectHighestTieredAbilityID("Firestorm");
			m_uiGreenColdAEAbilityID = SelectHighestTieredAbilityID("Glacial Wind");
			m_uiStormOfLightningAbilityID = SelectHighestTieredAbilityID("Storm of Lightning");
			m_uiRaysOfDisintegrationAbilityID = SelectHighestAbilityID("Rays of Disintegration");
			m_uiStormingTempestAbilityID = SelectHighestTieredAbilityID("Storming Tempest");
			m_uiProtoflameAbilityID = SelectHighestTieredAbilityID("Protoflame");
			m_uiHailStormAbilityID = SelectHighestAbilityID("Hail Storm");
			m_uiFusionAbilityID = SelectHighestTieredAbilityID("Fusion");
			m_uiIceCometAbilityID = SelectHighestTieredAbilityID("Ice Comet");
			m_uiBallOfFireAbilityID = SelectHighestTieredAbilityID("Ball of Fire");
			m_uiImmolationAbilityID = SelectHighestTieredAbilityID("Immolation");
			m_uiMagmaChamberAbilityID = SelectHighestTieredAbilityID("Magma Chamber");
			m_uiElementalDebuffAbilityID = SelectHighestTieredAbilityID("Ice Spears");
			m_uiIncinerateAbilityID = SelectHighestTieredAbilityID("Incinerate");
			m_uiLightningBurstAbilityID = SelectHighestTieredAbilityID("Solar Flare");
			m_uiSingleDeaggroAbilityID = SelectHighestTieredAbilityID("Cease");

			return;
		}

		/************************************************************************************/
		protected override bool DoNextAction()
		{
			if (base.DoNextAction() || MeActor.IsDead)
				return true;

			GetOffensiveTargetActor();
			bool bOffensiveTargetEngaged = EngageOffensiveTarget();

			if (IsCasting)
			{
				if (bOffensiveTargetEngaged && CastAmbidextrousCasting())
					return true;

				return true;
			}

			if (AttemptCureArcane())
				return true;
			if (UseRegenItem())
				return true;
			if (CastEmergencyPowerFeed())
				return true;

			if (m_bCheckBuffsNow)
			{
				if (CheckToggleBuff(m_uiWardOfSagesAbilityID, true))
					return true;
				if (CheckToggleBuff(m_uiMagisShieldingAbilityID, true))
					return true;
				if (CheckToggleBuff(m_uiMailOfFrostAbilityID, true))
					return true;
				if (CheckToggleBuff(m_uiElementalBuffAbilityID, true))
					return true;
				if (CheckToggleBuff(m_uiSTRINTBuffAbilityID, true))
					return true;
				if (CheckSingleTargetBuffs(m_uiFlametongueAbilityID, m_astrFlametongueTargets))
					return true;
				if (CheckSingleTargetBuff(m_uiHateTransferAbilityID, m_astrHateTransferTargets))
					return true;
				if (CheckRacialBuffs())
					return true;
				if (CheckKingdomOfSkyPet())
					return true;
				if (CheckToggleBuff(m_uiSnowFilledStepsAbilityID, true))
					return true;
				StopCheckingBuffs();
			}

			if (bOffensiveTargetEngaged)
			{
				/// Find the distance to the mob. Especially important for PBAE usage.
				bool bDumbfiresAdvised = AreDumbfiresAdvised();
				bool bTempBuffsAdvised = AreTempOffensiveBuffsAdvised();

				if (CastHOStarter())
					return true;

				if (IsIdle)
				{
					/// Cast these temp buffs before other spells or conditions can separate them.
					/// Iceshape and Gift always go together, and Fireshape and Surge always go together.
					if (IsAbilityMaintained(m_uiIceshapeAbilityID))
					{
						if (CastAbilityOnSelf(m_uiGiftAbilityID))
						{
							SpamSafeGroupSay(m_strGiftCallout);
							return true;
						}
					}
					else if (IsAbilityMaintained(m_uiSurgeAbilityID))
					{
						if (CastAbilityOnSelf(m_uiFireshapeAbilityID))
							return true;
					}

					if (bTempBuffsAdvised)
					{
						/// These temp buffs are sensitive to the damage type;
						/// don't do shit while Iceshape or Gift is on the group from another player.
						if (!IsBeneficialEffectPresent(m_uiIceshapeAbilityID) && !IsBeneficialEffectPresent(m_uiGiftAbilityID))
						{
							/// Iceshape and Fireshape are optional AA abilities but tightly woven into the use of Gift and Surge.
							/// To keep this code concise, "nonexistant" is treated the same as "ready".
							bool bIceshapeReady = (m_uiIceshapeAbilityID == 0 || IsAbilityReady(m_uiIceshapeAbilityID));
							bool bFireshapeReady = (m_uiFireshapeAbilityID == 0 || IsAbilityReady(m_uiFireshapeAbilityID));

							/// Consider using Iceshape/Gift if Fireshape/Surge aren't up.
							/// Gift has the shorter duration so it gets cast last and its availability becomes the prerequisite.
							if (!IsAbilityMaintained(m_uiFireshapeAbilityID) && !IsAbilityMaintained(m_uiSurgeAbilityID) && IsAbilityReady(m_uiGiftAbilityID))
							{
								if (CastAbilityOnSelf(m_uiIceshapeAbilityID))
									return true;

								/// Unnecessary (see above).
								/*if (CastAbilityOnSelf(m_uiGiftAbilityID))
								{
									SpamSafeGroupSay(m_strGiftCallout);
									return true;
								}*/
							}

							/// Consider using Fireshape/Surge if Iceshape/Gift aren't up.
							/// Fireshape has the shorter duration so it gets cast last and its availability becomes the prerequisite.
							else if (!IsAbilityMaintained(m_uiIceshapeAbilityID) && !IsAbilityMaintained(m_uiGiftAbilityID) && bFireshapeReady)
							{
								if (CastAbilityOnSelf(m_uiSurgeAbilityID))
									return true;

								/// Unnecessary (see above).
								/*if (CastAbilityonSelf(m_uiFireshapeAbilityID))
									return true;*/
							}
						}

						if (CastAbility(m_uiFieryBlastAbilityID))
							return true;
					}

					/// Deaggros.
					if (m_bIHaveAggro)
					{
						if (CastAbility(m_uiSingleDeaggroAbilityID))
							return true;
						if (CastAbility(m_uiGeneralGreenDeaggroAbilityID))
							return true;
						if (UseDeaggroItems())
							return true;
					}

					/// Cast Furnace of Ro. This is a static pet, permanent location. Very weird beast.
					/// You use it to debuff heat; thus it would be dumb to use it while all spells are cold based.
					if (m_bUseBlueAEs && !IsAbilityMaintained(m_uiFurnaceOfRoAbilityID) && !IsBeneficialEffectPresent(m_uiIceshapeAbilityID))
					{
						/// We're making a guesstimate that the pet's radius is 6 meters,
						/// including margin space for any NPC's that may come into its path en route to the PC's.
						if (m_OffensiveTargetActor.IsNamed || GetBlueOffensiveAbilityCompatibleTargetCount(m_uiFurnaceOfRoAbilityID, 6.0) > 3)
						{
							if (CastAbility(m_uiFurnaceOfRoAbilityID))
								return true;
						}
					}

					/// FIRST BLOOD: Extreme AE opportunities should receive top priority,
					/// and never subordinate to boilerplate cast orders.
					if (CastGreenOffensiveAbility(m_uiGreenColdAEAbilityID, 6))
						return true;
					if (CastBlueOffensiveAbility(m_uiFirestormAbilityID, 7))
						return true;
					if (CastGreenOffensiveAbility(m_uiStormOfLightningAbilityID, 8))
						return true;

					/// We attempt these in two places:
					/// - Here at the beginning for the debuffs, and
					/// - Down the list for the DPS.
					if (!IsAbilityMaintained(m_uiElementalDebuffAbilityID, m_iOffensiveTargetID) && CastAbility(m_uiElementalDebuffAbilityID))
						return true;
					if (m_uiWarmBloodedPassiveAbilityID != 0 && !IsAbilityMaintained(m_uiImmolationAbilityID, m_iOffensiveTargetID) && CastAbility(m_uiImmolationAbilityID))
						return true;

					/// Cast Iceshield.
					if (IsAbilityReady(m_uiColdDamageShieldAbilityID))
					{
						string strTargetName = string.Empty;

						if (string.IsNullOrEmpty(m_strIceShieldTarget))
						{
							/// Select whoever has aggro.
							Actor AggroWhore = m_OffensiveTargetActor.Target();
							if (AggroWhore.IsValid && AggroWhore.Type == "PC")
								strTargetName = AggroWhore.Name;
						}
						else
							strTargetName = m_strIceShieldTarget;

						/// The downside of this check is that it omits pets.
						if (m_FriendDictionary.ContainsKey(strTargetName))
						{
							int iTargetActorID = m_FriendDictionary[strTargetName].ToActor().ID;

							/// Don't refresh it on someone who still has ticks left. The calculated dps goes way down.
							if (!IsAbilityMaintained(m_uiColdDamageShieldAbilityID, iTargetActorID) &&
								CastAbility(m_uiColdDamageShieldAbilityID, strTargetName, true))
							{
								return true;
							}
						}
					}

					if (CastFusion())
						return true;

					/// AE time!!
					if (CastGreenOffensiveAbility(m_uiGreenColdAEAbilityID, 3))
						return true;
					if (CastBlueOffensiveAbility(m_uiFirestormAbilityID, 4))
						return true;
					if (CastGreenOffensiveAbility(m_uiStormOfLightningAbilityID, 5))
						return true;

					if (CastAbility(m_uiStormingTempestAbilityID))
						return true;

					if (bDumbfiresAdvised && !IsAbilityMaintained(m_uiProtoflameAbilityID) && CastAbility(m_uiProtoflameAbilityID))
						return true;

					/// AE time!!
					if (CastGreenOffensiveAbility(m_uiGreenColdAEAbilityID, 2))
						return true;
					if (CastBlueOffensiveAbility(m_uiFirestormAbilityID, 3))
						return true;
					if (CastGreenOffensiveAbility(m_uiStormOfLightningAbilityID, 4))
						return true;

					if (m_bUseBlueAEs && CastAbility(m_uiHailStormAbilityID))
						return true;

					/// Freehand Sorcery for Ice Comet.
					if (IsAbilityReady(m_uiIceCometAbilityID) && CastAbilityOnSelf(m_uiFreehandSorceryAbilityID))
						return true;

					if (CastAbility(m_uiIceCometAbilityID))
						return true;
				}

				/// Uninterruptable; can be cast while running.
				if (CastAbility(m_uiBewildermentAbilityID))
					return true;
				if (CastAbility(m_uiThunderclapAbilityID))
					return true;

				if (IsIdle)
				{
					if (CastAbility(m_uiRaysOfDisintegrationAbilityID))
						return true;
					if (CastAbility(m_uiBallOfFireAbilityID))
						return true;
					if (CastAbility(m_uiImmolationAbilityID))
						return true;
					if (CastAbility(m_uiMagmaChamberAbilityID))
						return true;
					if (CastAbility(m_uiFlamesOfVeliousAbilityID))
						return true;
					if (CastAbility(m_uiLoreAndLegendAbilityID))
						return true;
					if (CastAbility(m_uiElementalDebuffAbilityID))
						return true;
					if (CastAbility(m_uiIncinerateAbilityID))
						return true;
					if (CastAbility(m_uiLightningBurstAbilityID))
						return true;
					if (UseOffensiveItems())
						return true;

					/// AE spells for when every single other thing is exhausted (very rare).
					if (CastBlueOffensiveAbility(m_uiFirestormAbilityID, 1))
						return true;
					if (CastGreenOffensiveAbility(m_uiStormOfLightningAbilityID, 1))
						return true;
				}
			}

			return false;
		}

		/************************************************************************************/
		/// <summary>
		/// Casts Fusion. This spell deserves special consideration because it is a directional PBAE.
		/// </summary>
		/// <returns></returns>
		protected bool CastFusion()
		{
			if (m_bUseBlueAEs && m_OffensiveTargetActor != null)
			{
				CachedAbility FusionAbility = GetAbility(m_uiFusionAbilityID, true);
				if (FusionAbility != null && m_OffensiveTargetActor.Distance <= FusionAbility.m_fEffectRadius)
				{
					/// Freehand Sorcery for Fusion.
					if (CastAbilityOnSelf(m_uiFreehandSorceryAbilityID))
						return true;

					if (CastAbility(m_uiFusionAbilityID))
					{
						/// Fusion is directional.
						m_OffensiveTargetActor.DoFace();
						return true;
					}
				}
			}

			return false;
		}
	}
}
