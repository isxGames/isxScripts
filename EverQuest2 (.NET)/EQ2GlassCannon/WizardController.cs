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

		public int m_iSTRINTBuffAbilityID = -1;
		public int m_iElementalBuffAbilityID = -1;
		public int m_iSnowFilledStepsAbilityID = -1;
		public int m_iMailOfFrostAbilityID = -1;
		public int m_iFlametongueAbilityID = -1;
		public int m_iGiftAbilityID = -1;
		public int m_iIceshapeAbilityID = -1;
		public int m_iSurgeAbilityID = -1;
		public int m_iFireshapeAbilityID = -1;

		public int m_iColdDamageShieldAbilityID = -1;
		public int m_iForgeOfRoAbilityID = -1;
		public int m_iBlueHeatAEAbilityID = -1;
		public int m_iGreenColdAEAbilityID = -1;
		public int m_iGreenMagicAEAbilityID = -1;
		public int m_iRaysOfDisintegrationAbilityID = -1;
		public int m_iSurgingTempestAbilityID = -1;
		public int m_iProtoflameAbilityID = -1;
		public int m_iHailStormAbilityID = -1;
		public int m_iFusionAbilityID = -1;
		public int m_iIceCometAbilityID = -1;
		public int m_iBallOfFireAbilityID = -1;
		public int m_iImmolationAbilityID = -1;
		public int m_iSingleStunNukeAbilityID = -1;
		public int m_iElementalDebuffAbilityID = -1;
		public int m_iUnresistableDotAbilityID = -1;
		public int m_iLightningBurstAbilityID = -1;
		public int m_iSingleDeaggroAbilityID = -1;

		/************************************************************************************/
		public override void TransferINISettings(PlayerController.TransferType eTransferType)
		{
			base.TransferINISettings(eTransferType);

			TransferINIStringList(eTransferType, "Wizard.FlametongueTargets", m_astrFlametongueTargets);
			TransferINIString(eTransferType, "Wizard.IceShieldTarget", ref m_strIceShieldTarget);
			TransferINIString(eTransferType, "Wizard.GiftCallout", ref m_strGiftCallout);
			return;
		}

		/************************************************************************************/
		public override void InitializeKnowledgeBook()
		{
			base.InitializeKnowledgeBook();

			m_iSTRINTBuffAbilityID = SelectHighestTieredAbilityID("Tyrant's Pact", 7);
			m_iElementalBuffAbilityID = SelectHighestTieredAbilityID("Fortify Elements", 7);
			m_iSnowFilledStepsAbilityID = SelectHighestAbilityID("Snow-filled Steps");
			m_iMailOfFrostAbilityID = SelectHighestAbilityID("Mail of Frost");
			m_iHateTransferAbilityID = SelectHighestTieredAbilityID("Converge", 6);
			m_iFlametongueAbilityID = SelectHighestTieredAbilityID("Ro's Blade", 7);
			m_iGiftAbilityID = SelectHighestTieredAbilityID("Frigid Gift", 5);
			m_iIceshapeAbilityID = SelectHighestAbilityID("Iceshape");
			m_iSurgeAbilityID = SelectHighestTieredAbilityID("Surge of Ro", 5);
			m_iFireshapeAbilityID = SelectHighestAbilityID("Fireshape");
			m_iColdDamageShieldAbilityID = SelectHighestTieredAbilityID("Iceshield", 6);
			m_iForgeOfRoAbilityID = SelectHighestTieredAbilityID("Furnace of Ro", 3);
			m_iBlueHeatAEAbilityID = SelectHighestTieredAbilityID("Firestorm", 7);
			m_iGreenColdAEAbilityID = SelectHighestTieredAbilityID("Glacial Wind", 6);
			m_iGreenMagicAEAbilityID = SelectHighestTieredAbilityID("Storm of Lightning", 7);
			m_iRaysOfDisintegrationAbilityID = SelectHighestAbilityID("Rays of Disintegration");
			m_iSurgingTempestAbilityID = SelectHighestTieredAbilityID("Storming Tempest", 3);
			m_iProtoflameAbilityID = SelectHighestTieredAbilityID("Protoflame", 4);
			m_iHailStormAbilityID = SelectHighestAbilityID("Hail Storm");
			m_iFusionAbilityID = SelectHighestTieredAbilityID("Fusion", 3);
			m_iIceCometAbilityID = SelectHighestTieredAbilityID("Ice Comet", 4);
			m_iBallOfFireAbilityID = SelectHighestTieredAbilityID("Ball of Fire", 6);
			m_iImmolationAbilityID = SelectHighestTieredAbilityID("Immolation", 7);
			m_iSingleStunNukeAbilityID = SelectHighestTieredAbilityID("Magma Chamber", 7);
			m_iElementalDebuffAbilityID = SelectHighestTieredAbilityID("Ice Spears", 8);
			m_iUnresistableDotAbilityID = SelectHighestTieredAbilityID("Incinerate", 8);
			m_iLightningBurstAbilityID = SelectHighestTieredAbilityID("Solar Flare", 9);
			m_iSingleDeaggroAbilityID = SelectHighestTieredAbilityID("Cease", 7);

			return;
		}

		/************************************************************************************/
		public override bool DoNextAction()
		{
			base.DoNextAction();

			if (Me.CastingSpell || MeActor.IsDead)
				return true;

			if (AttemptCureArcane())
				return true;

			if (m_bCheckBuffsNow)
			{
				if (CheckToggleBuff(m_iWardOfSagesAbilityID, true))
					return true;

				if (CheckToggleBuff(m_iMagisShieldingAbilityID, true))
					return true;

				if (CheckToggleBuff(m_iMailOfFrostAbilityID, true))
					return true;

				if (CheckToggleBuff(m_iElementalBuffAbilityID, true))
					return true;

				if (CheckToggleBuff(m_iSTRINTBuffAbilityID, true))
					return true;

				if (CheckSingleTargetBuffs(m_iFlametongueAbilityID, m_astrFlametongueTargets, true, false))
					return true;

				if (CheckSingleTargetBuffs(m_iHateTransferAbilityID, m_strHateTransferTarget, true, true))
					return true;

				if (CheckRacialBuffs())
					return true;

				if (CheckToggleBuff(m_iSnowFilledStepsAbilityID, true))
					return true;

				StopCheckingBuffs();
			}

			GetOffensiveTargetActor();
			if (!EngageOffensiveTargetActor())
				return false;

			if (m_OffensiveTargetActor != null)
			{
				/// Find the distance to the mob.  Especially important for PBAE usage.
				double fDistance = GetActorDistance2D(MeActor, m_OffensiveTargetActor);
				bool bDumbfiresAdvised = (m_OffensiveTargetActor.IsEpic && m_OffensiveTargetActor.Health > 25) || (m_OffensiveTargetActor.IsHeroic && m_OffensiveTargetActor.Health > 90) || (m_OffensiveTargetActor.Health > 95);
				bool bTempBuffsAdvised = AreTempOffensiveBuffsAdvised();
				int iEncounterSize = m_OffensiveTargetActor.EncounterSize;

				if (CastHOStarter())
					return true;

				/// Emergency crowd control.
				if (m_bSpamCrowdControl)
				{
					/// Debuff ASAP.
					if (!IsAbilityMaintained(m_iElementalDebuffAbilityID) && CastAbility(m_iElementalDebuffAbilityID))
						return true;

					if (m_OffensiveTargetActor.CanTurn && !m_OffensiveTargetActor.IsEpic && CastAbility(m_iSingleStunNukeAbilityID))
						return true;

					/// Melee interrupt.
					if (CastAbility(m_iAmbidexterousCastingAbilityID))
						return true;
				}

				if (MeActor.IsIdle)
				{
					/// FIRST BLOOD: Extreme AE opportunities should receive top priority,
					/// and never subordinate to boilerplate cast orders.
					if (CastGreenOffensiveAbility(m_iGreenColdAEAbilityID, 6))
						return true;
					if (CastBlueOffensiveAbility(m_iBlueHeatAEAbilityID, 7))
						return true;
					if (CastGreenOffensiveAbility(m_iGreenMagicAEAbilityID, 8))
						return true;

					/// Deaggros.
					if (m_bSpamCrowdControl || m_bIHaveAggro)
					{
						if (CastAbility(m_iSingleDeaggroAbilityID))
							return true;

						if (CastAbility(m_iGeneralGreenDeaggroAbilityID))
							return true;
					}

					/// We attempt this in two places:
					/// - Here at the beginning for the debuff, and
					/// - Down the list for the DPS.
					if (!IsAbilityMaintained(m_iElementalDebuffAbilityID) && CastAbility(m_iElementalDebuffAbilityID))
						return true;

					if (IsAbilityReady(m_iColdDamageShieldAbilityID))
					{
						if (string.IsNullOrEmpty(m_strIceShieldTarget))
						{
							/// Use Iceshield on whoever has aggro.
							Actor AggroWhore = m_OffensiveTargetActor.Target();
							if (AggroWhore.IsValid && m_FriendDictionary.ContainsKey(AggroWhore.Name))
							{
								if (CastAbility(m_iColdDamageShieldAbilityID, AggroWhore.Name, true))
									return true;
							}
						}
						else
						{
							if (CastAbility(m_iColdDamageShieldAbilityID, m_strIceShieldTarget, true))
								return true;
						}
					}

					/// Cast these temp buffs before other spells that can trigger them or separate them.
					/// Iceshape and Gift always go together, and Fireshape and Surge always go together.
					if (bTempBuffsAdvised)
					{
						/// These temp buffs are sensitive to the damage type;
						/// don't do shit while Iceshape or Gift is on the group from another player.
						if (!IsBeneficialEffectPresent(m_iIceshapeAbilityID) && !IsBeneficialEffectPresent(m_iGiftAbilityID))
						{
							/// Iceshape and Fireshape are optional AA abilities but tightly woven into the use of Gift and Surge.
							/// To keep this code concise, "nonexistant" is treated the same as "ready".
							bool bIceshapeReady = (m_iIceshapeAbilityID == -1 || IsAbilityReady(m_iIceshapeAbilityID));
							bool bFireshapeReady = (m_iFireshapeAbilityID == -1 || IsAbilityReady(m_iFireshapeAbilityID));

							/// Consider using Iceshape/Gift if Fireshape/Surge aren't up.
							/// Gift has the shorter duration so it gets cast last and its availability becomes the prerequisite.
							if (!IsAbilityMaintained(m_iFireshapeAbilityID) && !IsAbilityMaintained(m_iSurgeAbilityID) && IsAbilityReady(m_iGiftAbilityID))
							{
								if (CastAbility(m_iIceshapeAbilityID))
									return true;

								if (CastAbility(m_iGiftAbilityID))
								{
									SpamSafeGroupSay(m_strGiftCallout);
									return true;
								}
							}

							/// Consider using Fireshape/Surge if Iceshape/Gift aren't up.
							/// Fireshape has the shorter duration so it gets cast last and its availability becomes the prerequisite.
							else if (!IsAbilityMaintained(m_iIceshapeAbilityID) && !IsAbilityMaintained(m_iGiftAbilityID) && bFireshapeReady)
							{
								if (CastAbility(m_iSurgeAbilityID))
									return true;

								if (CastAbility(m_iFireshapeAbilityID))
									return true;
							}
						}
					}

					if (m_bUseBlueAEs && (fDistance <= 10.0f))
					{
						/// Freehand Sorcery for Fusion.
						if (IsAbilityReady(m_iFusionAbilityID) && CastAbility(m_iFreehandSorceryAbilityID, Me.Name, true))
							return true;

						if (CastAbility(m_iFusionAbilityID))
						{
							/// Fusion is directional.
							m_OffensiveTargetActor.DoFace();
							return true;
						}
					}

					/// AE time!!
					if (CastGreenOffensiveAbility(m_iGreenColdAEAbilityID, 3))
						return true;
					if (CastBlueOffensiveAbility(m_iBlueHeatAEAbilityID, 4))
						return true;
					if (CastGreenOffensiveAbility(m_iGreenMagicAEAbilityID, 5))
						return true;

					if (bDumbfiresAdvised && !IsAbilityMaintained(m_iForgeOfRoAbilityID) && CastBlueOffensiveAbility(m_iForgeOfRoAbilityID, 1))
						return true;

					if (CastAbility(m_iSurgingTempestAbilityID))
						return true;

					if (bDumbfiresAdvised && !IsAbilityMaintained(m_iProtoflameAbilityID) && CastAbility(m_iProtoflameAbilityID))
						return true;

					/// AE time!!
					if (CastGreenOffensiveAbility(m_iGreenColdAEAbilityID, 2))
						return true;
					if (CastBlueOffensiveAbility(m_iBlueHeatAEAbilityID, 3))
						return true;
					if (CastGreenOffensiveAbility(m_iGreenMagicAEAbilityID, 4))
						return true;

					if (CastAbility(m_iHailStormAbilityID))
						return true;

					/// Freehand Sorcery for Ice Comet.
					if (IsAbilityReady(m_iIceCometAbilityID) && CastAbility(m_iFreehandSorceryAbilityID, Me.Name, true))
						return true;

					if (CastAbility(m_iIceCometAbilityID))
						return true;
				}

				/// Uninterruptable; can be cast while running.
				if (CastAbility(m_iBewildermentAbilityID))
					return true;
				if (CastAbility(m_iThunderclapAbilityID))
					return true;

				if (MeActor.IsIdle)
				{
					if (CastAbility(m_iBallOfFireAbilityID))
						return true;

					if (CastAbility(m_iImmolationAbilityID))
						return true;

					if (CastAbility(m_iSingleStunNukeAbilityID))
						return true;

					/// I haven't calculated the best place for this spell yet.
					if (CastAbility(m_iRaysOfDisintegrationAbilityID))
						return true;

					if (CastAbility(m_iIceFlameAbilityID))
						return true;

					if (CastAbility(m_iLoreAndLegendAbilityID))
						return true;

					if (CastAbility(m_iElementalDebuffAbilityID))
						return true;

					if (CastAbility(m_iUnresistableDotAbilityID))
						return true;

					if (CastAbility(m_iLightningBurstAbilityID))
						return true;

					/// AE spells for when every single other thing is exhausted (very rare).
					if (CastBlueOffensiveAbility(m_iBlueHeatAEAbilityID, 1))
						return true;
					if (CastGreenOffensiveAbility(m_iGreenMagicAEAbilityID, 1))
						return true;
				}
			}

			return false;
		}
	}
}
