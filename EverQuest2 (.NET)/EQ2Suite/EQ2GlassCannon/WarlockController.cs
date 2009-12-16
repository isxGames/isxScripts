/* Berrbe says on eq2flames that this is his cast order for 1 target:
Netherealm
Gift
Acid storm(when mob is coming)
acid
Vacuum field
Aura
acid
Armageddon(do it 3rd since acid/aura have fast cast and hopefully debuffs will be applied by then!)
Distortion
Acid again
Absolution
Flames
encase
Keep acid running/don't over cas it.
*/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2SuiteLib;

namespace EQ2GlassCannon
{
	/// <summary>
	/// NOTE: The warlock implementation is not yet complete.
	/// </summary>
	public class WarlockController : SorcererController
	{
		public List<string> m_astrShroudTargets = new List<string>();
		public List<string> m_astrGraspTargets = new List<string>();

		protected uint m_uiGroupCastingSkillBuffAbilityID = 0;
		protected uint m_uiGroupNoxiousBuffAbilityID = 0;
		protected uint m_uiGroupProcBuffAbilityID = 0;
		protected uint m_uiGiftAbilityID = 0;
		protected uint m_uiNetherealmAbilityID = 0;
		protected uint m_uiSingleDamageShieldBuffAbilityID = 0;
		protected uint m_uiSingleMeleeProcBuffAbilityID = 0;
		protected uint m_uiNullmailAbilityID = 0;

		protected uint m_uiSingleSTRINTDebuffAbilityID = 0;
		protected uint m_uiAuraOfVoidAbilityID = 0;
		protected uint m_uiDissolveAbilityID = 0;
		protected uint m_uiDistortionAbilityID = 0;
		protected uint m_uiAcidAbilityID = 0;
		protected uint m_uiDarkPyreAbilityID = 0;
		protected uint m_uiEncaseAbilityID = 0;
		protected uint m_uiPlaguebringerAbilityID = 0;
		protected uint m_uiGreenNoxiousDebuffAbilityID = 0;
		protected uint m_uiDarkNebulaAbilityID = 0;
		protected uint m_uiApocalypseAbilityID = 0;
		protected uint m_uiAbsolutionAbilityID = 0;
		protected uint m_uiGreenDeaggroAbilityID = 0;
		protected uint m_uiCataclysmAbilityID = 0;
		protected uint m_uiRiftAbilityID = 0;
		protected uint m_uiDarkInfestationAbilityID = 0;
		protected uint m_uiNetherlordPetAbilityID = 0;
		protected uint m_uiAcidStormPetAbilityID = 0;

		/************************************************************************************/
		public WarlockController()
		{
			/// Add an extra default frame to skip because of all the AE spells to check.
			m_iFrameSkip++;
			return;
		}

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferStringList("Warlock.ShroudTargets", m_astrShroudTargets);
			ThisFile.TransferStringList("Warlock.GraspTargets", m_astrGraspTargets);
			return;
		}

		/************************************************************************************/
		protected override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			/// Buffs.
			m_uiGroupCastingSkillBuffAbilityID = SelectHighestTieredAbilityID("Dark Pact");
			m_uiGroupNoxiousBuffAbilityID = SelectHighestTieredAbilityID("Aspect of Darkness");
			m_uiGroupProcBuffAbilityID = SelectHighestAbilityID("Propagation");
			m_uiGiftAbilityID = SelectHighestTieredAbilityID("Gift of Bertoxxulous");
			m_uiNetherealmAbilityID = SelectHighestTieredAbilityID("Netherealm");
			m_uiSingleDamageShieldBuffAbilityID = SelectHighestTieredAbilityID("Shroud of Bertoxxulous");
			m_uiSingleMeleeProcBuffAbilityID = SelectHighestTieredAbilityID("Grasp of Bertoxxulous");
			m_uiNullmailAbilityID = SelectHighestAbilityID("Nullmail");
			m_uiHateTransferAbilityID = SelectHighestTieredAbilityID("Boon of the Damned");

			m_uiSingleSTRINTDebuffAbilityID = SelectHighestTieredAbilityID("Curse of Void");
			m_uiAuraOfVoidAbilityID = SelectHighestTieredAbilityID("Aura of Void");
			m_uiSinglePowerFeedAbilityID = SelectHighestTieredAbilityID("Mana Trickle");
			m_uiDissolveAbilityID = SelectHighestTieredAbilityID("Dissolve");
			m_uiDistortionAbilityID = SelectHighestTieredAbilityID("Distortion");
			m_uiAcidAbilityID = SelectHighestTieredAbilityID("Acid");
			m_uiDarkPyreAbilityID = SelectHighestTieredAbilityID("Dark Pyre");
			m_uiEncaseAbilityID = SelectHighestTieredAbilityID("Encase");
			m_uiPlaguebringerAbilityID = SelectHighestAbilityID("Plaguebringer");
			m_uiGreenNoxiousDebuffAbilityID = SelectHighestTieredAbilityID("Vacuum Field");
			m_uiDarkNebulaAbilityID = SelectHighestTieredAbilityID("Dark Nebula");
			m_uiApocalypseAbilityID = SelectHighestTieredAbilityID("Apocalypse");
			m_uiAbsolutionAbilityID = SelectHighestTieredAbilityID("Absolution");
			m_uiGreenDeaggroAbilityID = SelectHighestTieredAbilityID("Nullify");
			m_uiCataclysmAbilityID = SelectHighestTieredAbilityID("Cataclysm");
			m_uiRiftAbilityID = SelectHighestTieredAbilityID("Rift");
			m_uiDarkInfestationAbilityID = SelectHighestTieredAbilityID("Dark Infestation");
			m_uiNetherlordPetAbilityID = SelectHighestTieredAbilityID("Netherlord");
			m_uiAcidStormPetAbilityID = SelectHighestTieredAbilityID("Acid Storm");

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

			if (MeActor.IsInvis)
			{
				/// This breaks invis.
				if (CancelMaintained(m_uiNetherealmAbilityID, true))
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
				if (CheckToggleBuff(m_uiNullmailAbilityID, true))
					return true;
				if (CheckToggleBuff(m_uiGroupCastingSkillBuffAbilityID, true))
					return true;
				if (CheckToggleBuff(m_uiGroupNoxiousBuffAbilityID, true))
					return true;
				if (CheckToggleBuff(m_uiGroupProcBuffAbilityID, true))
					return true;
				if (CheckSingleTargetBuff(m_uiHateTransferAbilityID, m_astrHateTransferTargets))
					return true;
				if (CheckSingleTargetBuffs(m_uiSingleDamageShieldBuffAbilityID, m_astrShroudTargets))
					return true;
				if (CheckSingleTargetBuffs(m_uiSingleMeleeProcBuffAbilityID, m_astrGraspTargets))
					return true;
				if (CheckRacialBuffs())
					return true;
				if (CheckKingdomOfSkyPet())
					return true;
				StopCheckingBuffs();
			}

			if (bOffensiveTargetEngaged)
			{
				bool bTempBuffsAdvised = AreTempOffensiveBuffsAdvised();
				bool bDumbfiresAdvised = AreDumbfiresAdvised();

				if (CastHOStarter())
					return true;

				/// Not all spells here need IsIdle, but a large enough amount do that I'm not gonna clutter the code for their sake.
				if (IsIdle)
				{
					/// Deaggros.
					if (m_bIHaveAggro)
					{
						if (CastAbility(m_uiGreenDeaggroAbilityID))
							return true;
						if (CastAbility(m_uiGeneralGreenDeaggroAbilityID))
							return true;
						if (UseDeaggroItems())
							return true;
					}

					/// Unfortunately, even these two spells can be counted and added to the DPS chart.
					/// But it's too complicated to figure out at this time. Stay tuned!
					if (bTempBuffsAdvised)
					{
						if (CastAbilityOnSelf(m_uiGiftAbilityID))
							return true;
						if (GetBlueOffensiveAbilityCompatibleTargetCount(m_uiNetherealmAbilityID, 25.0) > 0 && CastAbilityOnSelf(m_uiNetherealmAbilityID))
							return true;
					}

					/// Resistance debuff is ALWAYS first.
					if (m_bUseGreenAEs && !IsAbilityMaintained(m_uiGreenNoxiousDebuffAbilityID) && CastGreenOffensiveAbility(m_uiGreenNoxiousDebuffAbilityID, 1))
						return true;

					/// They really need to get the fuck rid of this level restriction.
					/// If we cast this every time regardless of mob type, then we really
					/// diminish the value of bringing along the warlock for burning AE trash.
					if (!IsAbilityMaintained(m_uiSingleSTRINTDebuffAbilityID, m_iOffensiveTargetID) &&
						(m_OffensiveTargetActor.Level >= 20) &&
						(m_OffensiveTargetActor.IsEpic || m_OffensiveTargetActor.IsNamed) &&
						!m_OffensiveTargetActor.IsAPet &&
						CastAbility(m_uiSingleSTRINTDebuffAbilityID))
					{
						return true;
					}

					/// This pet is PBAE and good in any context.
					if (bDumbfiresAdvised && m_bUseBlueAEs && CastAbility(m_uiAcidStormPetAbilityID))
						return true;

					/// TODO: Find out EXACTLY where Acid needs to go in the cast order after getting 5 Shadows AAs.

					/// Single-target mythical stance.
					/// This table is more contained than the normal green AE stance because
					/// all green damage AE's (including unlimited target ones) are limited to 1 target.
					if (IsAbilityMaintained("Negative Void"))
					{
						if (CastBlueOffensiveAbility(m_uiCataclysmAbilityID, 3))
							return true;
						if (CastBlueOffensiveAbility(m_uiRiftAbilityID, 3))
							return true;
						if (CastAbility(m_uiApocalypseAbilityID))
							return true;
						if (CastAbility(m_uiPlaguebringerAbilityID))
							return true;
						if (CastAbility(m_uiAuraOfVoidAbilityID))
							return true;
						if (CastBlueOffensiveAbility(m_uiCataclysmAbilityID, 2))
							return true;
						if (CastBlueOffensiveAbility(m_uiRiftAbilityID, 2))
							return true;
						if (CastAbility(m_uiBewildermentAbilityID))
							return true;
						if (CastAbility(m_uiThunderclapAbilityID))
							return true;
						if (CastAbility(m_uiDarkInfestationAbilityID))
							return true;
						if (!IsAbilityMaintained(m_uiAcidAbilityID, m_iOffensiveTargetID) && CastAbility(m_uiAcidAbilityID))
							return true;
						if (CastAbility(m_uiLoreAndLegendAbilityID))
							return true;
						if (CastAbility(m_uiAbsolutionAbilityID))
							return true;
						if (CastAbility(m_uiDistortionAbilityID))
							return true;
						if (CastAbility(m_uiFlamesOfVeliousAbilityID))
							return true;
						if (CastAbility(m_uiEncaseAbilityID))
							return true;
						if (CastAbility(m_uiDarkPyreAbilityID))
							return true;
						if (CastBlueOffensiveAbility(m_uiCataclysmAbilityID, 1))
							return true;
						if (CastBlueOffensiveAbility(m_uiRiftAbilityID, 1))
							return true;
						if (CastAbility(m_uiDissolveAbilityID))
							return true;
						if (CastAbility(m_uiDarkNebulaAbilityID))
							return true;
					}

					/// Encounter-target (normal) stance.
					else
					{
						/// The lack of a target limit on Absolution and Dark Nebula means that
						/// at some encounter size they have runaway dps potential.
						/// Fortunately I don't have to extend the cast order infinitely,
						/// just to the point where the runaway transition occurs.
						/// The highest Absolution hit will be placed above the highest Dark Nebula
						/// hit because it is a higher dps spell.

						if (CastGreenOffensiveAbility(m_uiAbsolutionAbilityID, 14))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 26))
							return true;
						if (CastBlueOffensiveAbility(m_uiRiftAbilityID, 12))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 25))
							return true;
						if (CastGreenOffensiveAbility(m_uiAbsolutionAbilityID, 13))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 23))
							return true;
						if (CastBlueOffensiveAbility(m_uiRiftAbilityID, 11))
							return true;
						if (CastGreenOffensiveAbility(m_uiAbsolutionAbilityID, 12))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 22))
							return true;
						if (CastGreenOffensiveAbility(m_uiApocalypseAbilityID, 5))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 21))
							return true;
						if (CastBlueOffensiveAbility(m_uiRiftAbilityID, 10))
							return true;
						if (CastGreenOffensiveAbility(m_uiAbsolutionAbilityID, 11))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 19))
							return true;
						if (CastGreenOffensiveAbility(m_uiAbsolutionAbilityID, 10))
							return true;
						if (CastBlueOffensiveAbility(m_uiRiftAbilityID, 9))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 18))
							return true;
						if (CastBlueOffensiveAbility(m_uiCataclysmAbilityID, 8))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 17))
							return true;
						if (CastGreenOffensiveAbility(m_uiApocalypseAbilityID, 4))
							return true;
						if (CastGreenOffensiveAbility(m_uiAbsolutionAbilityID, 9))
							return true;
						if (CastBlueOffensiveAbility(m_uiRiftAbilityID, 8))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 16))
							return true;
						if (CastGreenOffensiveAbility(m_uiAbsolutionAbilityID, 8))
							return true;
						if (CastBlueOffensiveAbility(m_uiCataclysmAbilityID, 7))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 15))
							return true;
						if (CastBlueOffensiveAbility(m_uiRiftAbilityID, 7))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 14))
							return true;
						if (CastGreenOffensiveAbility(m_uiAbsolutionAbilityID, 7))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 13))
							return true;
						if (CastBlueOffensiveAbility(m_uiCataclysmAbilityID, 6))
							return true;
						if (CastGreenOffensiveAbility(m_uiApocalypseAbilityID, 3))
							return true;
						if (CastBlueOffensiveAbility(m_uiRiftAbilityID, 6))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 12))
							return true;
						if (CastGreenOffensiveAbility(m_uiAbsolutionAbilityID, 6))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 11))
							return true;
						if (CastBlueOffensiveAbility(m_uiCataclysmAbilityID, 5))
							return true;
						if (CastBlueOffensiveAbility(m_uiRiftAbilityID, 5))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 10))
							return true;
						if (CastGreenOffensiveAbility(m_uiAbsolutionAbilityID, 5))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 9))
							return true;
						if (CastBlueOffensiveAbility(m_uiCataclysmAbilityID, 4))
							return true;
						if (CastGreenOffensiveAbility(m_uiApocalypseAbilityID, 2))
							return true;
						if (CastBlueOffensiveAbility(m_uiRiftAbilityID, 4))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 8))
							return true;
						if (CastGreenOffensiveAbility(m_uiAbsolutionAbilityID, 4))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 7))
							return true;
						if (CastBlueOffensiveAbility(m_uiCataclysmAbilityID, 3))
							return true;
						if (CastBlueOffensiveAbility(m_uiRiftAbilityID, 3))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 6))
							return true;
						if (CastGreenOffensiveAbility(m_uiAbsolutionAbilityID, 3))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 5))
							return true;
						if (CastAbility(m_uiPlaguebringerAbilityID))
							return true;
						if (CastAbility(m_uiAuraOfVoidAbilityID))
							return true;
						if (CastBlueOffensiveAbility(m_uiCataclysmAbilityID, 2))
							return true;
						if (CastGreenOffensiveAbility(m_uiApocalypseAbilityID, 1))
							return true;
						if (CastBlueOffensiveAbility(m_uiRiftAbilityID, 2))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 4))
							return true;
						if (CastAbility(m_uiBewildermentAbilityID))
							return true;
						if (CastGreenOffensiveAbility(m_uiAbsolutionAbilityID, 2))
							return true;
						if (CastAbility(m_uiThunderclapAbilityID))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 3))
							return true;
						if (m_bUseBlueAEs && CastAbility(m_uiDarkInfestationAbilityID)) /// The broodlings case PBAE's.
							return true;
						if (!IsAbilityMaintained(m_uiAcidAbilityID, m_iOffensiveTargetID) && CastAbility(m_uiAcidAbilityID))
							return true;
						if (CastAbility(m_uiLoreAndLegendAbilityID))
							return true;
						if (CastAbility(m_uiDistortionAbilityID))
							return true;
						if (CastAbility(m_uiFlamesOfVeliousAbilityID))
							return true;
						if (CastAbility(m_uiEncaseAbilityID))
							return true;
						if (CastAbility(m_uiDarkPyreAbilityID))
							return true;
						if (CastBlueOffensiveAbility(m_uiCataclysmAbilityID, 1))
							return true;
						if (CastBlueOffensiveAbility(m_uiRiftAbilityID, 1))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 2))
							return true;
						if (CastGreenOffensiveAbility(m_uiAbsolutionAbilityID, 1))
							return true;
						if (CastAbility(m_uiDissolveAbilityID))
							return true;
						if (CastGreenOffensiveAbility(m_uiDarkNebulaAbilityID, 1))
							return true;
					}

					/// TODO: Who knows where this fits in yet...(and who cares?)
					if (bDumbfiresAdvised && CastAbility(m_uiNetherlordPetAbilityID))
						return true;
					/// Desperation, lol.
					if (UseOffensiveItems())
						return true;
				}
			}

			return false;
		}
	}
}
