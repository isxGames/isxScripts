using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using InnerSpaceAPI;
using System.Threading;
using EQ2.ISXEQ2;

namespace EQ2GlassCannon
{
	public class WizardController : SorcererController
	{
		public List<string> m_astrFlametongueTargets = new List<string>();
		public string m_strIceShieldTarget = string.Empty;
		public string m_strGiftCallout = string.Empty;

		public uint m_uiSTRINTBuffAbilityID = 0;
		public uint m_uiElementalBuffAbilityID = 0;
		public uint m_uiSnowFilledStepsAbilityID = 0;
		public uint m_uiMailOfFrostAbilityID = 0;
		public uint m_uiFlametongueAbilityID = 0;
		public uint m_uiGiftAbilityID = 0;
		public uint m_uiIceshapeAbilityID = 0;
		public uint m_uiSurgeAbilityID = 0;
		public uint m_uiFireshapeAbilityID = 0;

		public uint m_uiColdDamageShieldAbilityID = 0;
		public uint m_uiFurnaceOfRoAbilityID = 0;
		public uint m_uiBlueHeatAEAbilityID = 0;
		public uint m_uiGreenColdAEAbilityID = 0;
		public uint m_uiGreenMagicAEAbilityID = 0;
		public uint m_uiRaysOfDisintegrationAbilityID = 0;
		public uint m_uiStormingTempestAbilityID = 0;
		public uint m_uiProtoflameAbilityID = 0;
		public uint m_uiHailStormAbilityID = 0;
		public uint m_uiFusionAbilityID = 0;
		public uint m_uiIceCometAbilityID = 0;
		public uint m_uiBallOfFireAbilityID = 0;
		public uint m_uiImmolationAbilityID = 0;
		public uint m_uiSingleStunNukeAbilityID = 0;
		public uint m_uiElementalDebuffAbilityID = 0;
		public uint m_uiUnresistableDotAbilityID = 0;
		public uint m_uiLightningBurstAbilityID = 0;
		public uint m_uiSingleDeaggroAbilityID = 0;

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
		public override void RefreshKnowledgeBook()
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
			m_uiColdDamageShieldAbilityID = SelectHighestTieredAbilityID("Iceshield");
			m_uiFurnaceOfRoAbilityID = SelectHighestTieredAbilityID("Furnace of Ro");
			m_uiBlueHeatAEAbilityID = SelectHighestTieredAbilityID("Firestorm");
			m_uiGreenColdAEAbilityID = SelectHighestTieredAbilityID("Glacial Wind");
			m_uiGreenMagicAEAbilityID = SelectHighestTieredAbilityID("Storm of Lightning");
			m_uiRaysOfDisintegrationAbilityID = SelectHighestAbilityID("Rays of Disintegration");
			m_uiStormingTempestAbilityID = SelectHighestTieredAbilityID("Storming Tempest");
			m_uiProtoflameAbilityID = SelectHighestTieredAbilityID("Protoflame");
			m_uiHailStormAbilityID = SelectHighestAbilityID("Hail Storm");
			m_uiFusionAbilityID = SelectHighestTieredAbilityID("Fusion");
			m_uiIceCometAbilityID = SelectHighestTieredAbilityID("Ice Comet");
			m_uiBallOfFireAbilityID = SelectHighestTieredAbilityID("Ball of Fire");
			m_uiImmolationAbilityID = SelectHighestTieredAbilityID("Immolation");
			m_uiSingleStunNukeAbilityID = SelectHighestTieredAbilityID("Magma Chamber");
			m_uiElementalDebuffAbilityID = SelectHighestTieredAbilityID("Ice Spears");
			m_uiUnresistableDotAbilityID = SelectHighestTieredAbilityID("Incinerate");
			m_uiLightningBurstAbilityID = SelectHighestTieredAbilityID("Solar Flare");
			m_uiSingleDeaggroAbilityID = SelectHighestTieredAbilityID("Cease");

			return;
		}

		/************************************************************************************/
		public override bool DoNextAction()
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
			if (UseSpellGeneratedHealItem())
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

				if (CheckSingleTargetBuffs(m_uiHateTransferAbilityID, m_strHateTransferTarget))
					return true;

				if (CheckRacialBuffs())
					return true;

				if (CheckToggleBuff(m_uiSnowFilledStepsAbilityID, true))
					return true;

				StopCheckingBuffs();
			}

			if (bOffensiveTargetEngaged)
			{
				/// Find the distance to the mob.  Especially important for PBAE usage.
				double fDistance = GetActorDistance2D(MeActor, m_OffensiveTargetActor);
				bool bDumbfiresAdvised = (m_OffensiveTargetActor.IsEpic && m_OffensiveTargetActor.Health > 25) || (m_OffensiveTargetActor.IsHeroic && m_OffensiveTargetActor.Health > 90);
				bool bTempBuffsAdvised = AreTempOffensiveBuffsAdvised();

				if (CastHOStarter())
					return true;

				if (MeActor.IsIdle)
				{
					/// Cast Furnace of Ro. This is a static pet, permanent location. Very weird beast.
					if (m_bUseBlueAEs && !IsAbilityMaintained(m_uiFurnaceOfRoAbilityID))
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
					if (CastBlueOffensiveAbility(m_uiBlueHeatAEAbilityID, 7))
						return true;
					if (CastGreenOffensiveAbility(m_uiGreenMagicAEAbilityID, 8))
						return true;

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

					/// We attempt this in two places:
					/// - Here at the beginning for the debuff, and
					/// - Down the list for the DPS.
					if (!IsAbilityMaintained(m_uiElementalDebuffAbilityID) && CastAbility(m_uiElementalDebuffAbilityID))
						return true;

					if (IsAbilityReady(m_uiColdDamageShieldAbilityID))
					{
						if (string.IsNullOrEmpty(m_strIceShieldTarget))
						{
							/// Use Iceshield on whoever has aggro.
							Actor AggroWhore = m_OffensiveTargetActor.Target();
							if (AggroWhore.IsValid && m_FriendDictionary.ContainsKey(AggroWhore.Name))
							{
								if (CastAbility(m_uiColdDamageShieldAbilityID, AggroWhore.Name, true))
									return true;
							}
						}
						else
						{
							if (CastAbility(m_uiColdDamageShieldAbilityID, m_strIceShieldTarget, true))
								return true;
						}
					}

					/// Cast these temp buffs before other spells that can trigger them or separate them.
					/// Iceshape and Gift always go together, and Fireshape and Surge always go together.
					if (bTempBuffsAdvised)
					{
						/// These temp buffs are sensitive to the damage type;
						/// don't do shit while Iceshape or Gift is on the group from another player.
						if (!IsBeneficialEffectPresent(m_uiIceshapeAbilityID) && !IsBeneficialEffectPresent(m_uiGiftAbilityID))
						{
							/// Iceshape and Fireshape are optional AA abilities but tightly woven into the use of Gift and Surge.
							/// To keep this code concise, "nonexistant" is treated the same as "ready".
							bool bIceshapeReady = (m_uiIceshapeAbilityID == -1 || IsAbilityReady(m_uiIceshapeAbilityID));
							bool bFireshapeReady = (m_uiFireshapeAbilityID == -1 || IsAbilityReady(m_uiFireshapeAbilityID));

							/// Consider using Iceshape/Gift if Fireshape/Surge aren't up.
							/// Gift has the shorter duration so it gets cast last and its availability becomes the prerequisite.
							if (!IsAbilityMaintained(m_uiFireshapeAbilityID) && !IsAbilityMaintained(m_uiSurgeAbilityID) && IsAbilityReady(m_uiGiftAbilityID))
							{
								if (CastAbility(m_uiIceshapeAbilityID))
									return true;

								if (CastAbility(m_uiGiftAbilityID))
								{
									SpamSafeGroupSay(m_strGiftCallout);
									return true;
								}
							}

							/// Consider using Fireshape/Surge if Iceshape/Gift aren't up.
							/// Fireshape has the shorter duration so it gets cast last and its availability becomes the prerequisite.
							else if (!IsAbilityMaintained(m_uiIceshapeAbilityID) && !IsAbilityMaintained(m_uiGiftAbilityID) && bFireshapeReady)
							{
								if (CastAbility(m_uiSurgeAbilityID))
									return true;

								if (CastAbility(m_uiFireshapeAbilityID))
									return true;
							}
						}
					}

					/// Cast Fusion. This deserves special consideration because it is a directional PBAE.
					if (m_bUseBlueAEs)
					{
						CachedAbility FusionAbility = GetAbility(m_uiFusionAbilityID, true);
						if (FusionAbility != null && fDistance <= FusionAbility.m_fEffectRadius)
						{
							/// Freehand Sorcery for Fusion.
							if (CastAbility(m_uiFreehandSorceryAbilityID, Me.Name, true))
								return true;

							if (CastAbility(m_uiFusionAbilityID))
							{
								/// Fusion is directional.
								m_OffensiveTargetActor.DoFace();
								return true;
							}
						}
					}

					/// AE time!!
					if (CastGreenOffensiveAbility(m_uiGreenColdAEAbilityID, 3))
						return true;
					if (CastBlueOffensiveAbility(m_uiBlueHeatAEAbilityID, 4))
						return true;
					if (CastGreenOffensiveAbility(m_uiGreenMagicAEAbilityID, 5))
						return true;


					if (CastAbility(m_uiStormingTempestAbilityID))
						return true;

					if (bDumbfiresAdvised && !IsAbilityMaintained(m_uiProtoflameAbilityID) && CastAbility(m_uiProtoflameAbilityID))
						return true;

					/// AE time!!
					if (CastGreenOffensiveAbility(m_uiGreenColdAEAbilityID, 2))
						return true;
					if (CastBlueOffensiveAbility(m_uiBlueHeatAEAbilityID, 3))
						return true;
					if (CastGreenOffensiveAbility(m_uiGreenMagicAEAbilityID, 4))
						return true;

					if (m_bUseBlueAEs && CastAbility(m_uiHailStormAbilityID))
						return true;

					/// Freehand Sorcery for Ice Comet.
					if (IsAbilityReady(m_uiIceCometAbilityID) && CastAbility(m_uiFreehandSorceryAbilityID, Me.Name, true))
						return true;

					if (CastAbility(m_uiIceCometAbilityID))
						return true;
				}

				/// Uninterruptable; can be cast while running.
				if (CastAbility(m_uiBewildermentAbilityID))
					return true;
				if (CastAbility(m_uiThunderclapAbilityID))
					return true;

				if (MeActor.IsIdle)
				{
					if (CastAbility(m_uiRaysOfDisintegrationAbilityID))
						return true;

					if (CastAbility(m_uiBallOfFireAbilityID))
						return true;

					if (CastAbility(m_uiImmolationAbilityID))
						return true;

					if (CastAbility(m_uiSingleStunNukeAbilityID))
						return true;

					if (CastAbility(m_uiIceFlameAbilityID))
						return true;

					if (CastAbility(m_uiLoreAndLegendAbilityID))
						return true;

					if (CastAbility(m_uiElementalDebuffAbilityID))
						return true;

					if (CastAbility(m_uiUnresistableDotAbilityID))
						return true;

					if (CastAbility(m_uiLightningBurstAbilityID))
						return true;

					if (UseOffensiveItems())
						return true;

					/// AE spells for when every single other thing is exhausted (very rare).
					if (CastBlueOffensiveAbility(m_uiBlueHeatAEAbilityID, 1))
						return true;
					if (CastGreenOffensiveAbility(m_uiGreenMagicAEAbilityID, 1))
						return true;
				}
			}

			return false;
		}
	}
}
