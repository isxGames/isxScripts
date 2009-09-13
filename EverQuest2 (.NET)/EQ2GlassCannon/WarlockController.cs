/* NOTE: The warlock implementation is nowhere near complete.
 */

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2GlassCannon
{
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
		protected uint m_uiSingleDiseaseReactiveAbilityID = 0;
		protected uint m_uiSingleBasicNukeAbilityID = 0;
		protected uint m_uiSinglePrimaryPoisonNukeAbilityID = 0;
		protected uint m_uiSingleUnresistableDOTAbilityID = 0;
		protected uint m_uiSingleMediumNukeDOTAbilityID = 0;
		protected uint m_uiSingleColdStunNukeAbilityID = 0;
		protected uint m_uiGreenNoxiousDebuffAbilityID = 0;
		protected uint m_uiGreenPoisonStunNukeAbilityID = 0;
		protected uint m_uiGreenPoisonDOTAbilityID = 0;
		protected uint m_uiGreenDiseaseNukeAbilityID = 0;
		protected uint m_uiGreenDeaggroAbilityID = 0;
		protected uint m_uiBluePoisonAEAbilityID = 0;
		protected uint m_uiBlueMagicKnockbackAEAbilityID = 0;
		protected uint m_uiDarkInfestationAbilityID = 0;
		protected uint m_uiNetherlordPetAbilityID = 0;
		protected uint m_uiAcidStormPetAbilityID = 0;

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferStringList("Warlock.ShroudTargets", m_astrShroudTargets);
			ThisFile.TransferStringList("Warlock.GraspTargets", m_astrGraspTargets);
			return;
		}

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
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
			m_uiSingleDiseaseReactiveAbilityID = SelectHighestTieredAbilityID("Aura of Void");
			m_uiSinglePowerFeedAbilityID = SelectHighestTieredAbilityID("Mana Trickle");
			m_uiSingleBasicNukeAbilityID = SelectHighestTieredAbilityID("Dissolve");
			m_uiSinglePrimaryPoisonNukeAbilityID = SelectHighestTieredAbilityID("Distortion");
			m_uiSingleUnresistableDOTAbilityID = SelectHighestTieredAbilityID("Poison");
			m_uiSingleMediumNukeDOTAbilityID = SelectHighestTieredAbilityID("Dark Pyre");
			m_uiSingleColdStunNukeAbilityID = SelectHighestTieredAbilityID("Encase");
			m_uiGreenNoxiousDebuffAbilityID = SelectHighestTieredAbilityID("Vacuum Field");
			m_uiGreenPoisonStunNukeAbilityID = SelectHighestTieredAbilityID("Dark Nebula");
			m_uiGreenPoisonDOTAbilityID = SelectHighestTieredAbilityID("Apocalypse");
			m_uiGreenDiseaseNukeAbilityID = SelectHighestTieredAbilityID("Absolution");
			m_uiGreenDeaggroAbilityID = SelectHighestTieredAbilityID("Nullify");
			m_uiBluePoisonAEAbilityID = SelectHighestTieredAbilityID("Cataclysm");
			m_uiBlueMagicKnockbackAEAbilityID = SelectHighestTieredAbilityID("Rift");
			m_uiDarkInfestationAbilityID = SelectHighestTieredAbilityID("Dark Infestation");
			m_uiNetherlordPetAbilityID = SelectHighestTieredAbilityID("Netherlord");
			m_uiAcidStormPetAbilityID = SelectHighestTieredAbilityID("Acid Storm");

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

			if (MeActor.IsInvis)
			{
				/// This breaks invis.
				if (CancelMaintained(m_uiNetherealmAbilityID, true))
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

				StopCheckingBuffs();
			}

/* Berrbe says this is his cast order for 1 target:
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

			if (bOffensiveTargetEngaged)
			{
				bool bTempBuffsAdvised = AreTempOffensiveBuffsAdvised();
				bool bDumbfiresAdvised = AreDumbfiresAdvised();

				if (CastHOStarter())
					return true;

				if (MeActor.IsIdle)
				{
					/// Deaggros.
					if (m_bIHaveAggro)
					{
						if (CastAbility(m_uiGreenDeaggroAbilityID))
							return true;

						if (CastAbility(m_uiGeneralGreenDeaggroAbilityID))
							return true;
					}

					if (bTempBuffsAdvised)
					{
						if (CastAbilityOnSelf(m_uiGiftAbilityID))
							return true;

						if (CastAbilityOnSelf(m_uiNetherealmAbilityID))
							return true;
					}

					/// Resistance debuff is ALWAYS first.
					if (m_bUseGreenAEs && !IsAbilityMaintained(m_uiGreenNoxiousDebuffAbilityID) && CastGreenOffensiveAbility(m_uiGreenNoxiousDebuffAbilityID, 1))
						return true;

					/// They really need to get the fuck rid of this level restriction.
					/// If we cast this every time regardless of mob type, then we really
					/// diminish the value of bringing along the warlock for burning AE trash.
					if (!IsAbilityMaintained(m_uiSingleSTRINTDebuffAbilityID) &&
						(m_OffensiveTargetActor.Level >= 20) &&
						(m_OffensiveTargetActor.IsEpic || m_OffensiveTargetActor.IsNamed) &&
						!m_OffensiveTargetActor.IsAPet &&
						CastAbility(m_uiSingleSTRINTDebuffAbilityID))
					{
						return true;
					}

					/// This pet is PBAE and good in any context.
					if (bDumbfiresAdvised && CastAbility(m_uiAcidStormPetAbilityID))
						return true;

					if (CastBlueOffensiveAbility(m_uiBlueMagicKnockbackAEAbilityID, 3))
						return true;
					if (CastBlueOffensiveAbility(m_uiBluePoisonAEAbilityID, 7))
						return true;
					if (CastGreenOffensiveAbility(m_uiGreenPoisonDOTAbilityID, 4))
						return true;
					if (CastGreenOffensiveAbility(m_uiGreenDiseaseNukeAbilityID, 5))
						return true;
					if (CastGreenOffensiveAbility(m_uiGreenPoisonStunNukeAbilityID, 6))
						return true;

					if (CastBlueOffensiveAbility(m_uiBlueMagicKnockbackAEAbilityID, 2))
						return true;
					if (CastBlueOffensiveAbility(m_uiBluePoisonAEAbilityID, 6))
						return true;
					if (CastGreenOffensiveAbility(m_uiGreenPoisonDOTAbilityID, 2))
						return true;
					if (CastGreenOffensiveAbility(m_uiGreenDiseaseNukeAbilityID, 3))
						return true;
					if (CastGreenOffensiveAbility(m_uiGreenPoisonStunNukeAbilityID, 4))
						return true;

					if (CastGreenOffensiveAbility(m_uiGreenDiseaseNukeAbilityID, 2))
						return true;

					if (CastAbility(m_uiSingleDiseaseReactiveAbilityID))
						return true;

					if (bDumbfiresAdvised && CastAbility(m_uiNetherlordPetAbilityID))
						return true;

					if (CastAbility(m_uiBewildermentAbilityID))
						return true;

					if (CastAbility(m_uiDarkInfestationAbilityID))
						return true;

					if (CastAbility(m_uiSinglePrimaryPoisonNukeAbilityID))
						return true;

					if (CastGreenOffensiveAbility(m_uiGreenPoisonStunNukeAbilityID, 2))
						return true;

					if (CastAbility(m_uiSingleColdStunNukeAbilityID))
						return true;

					if (CastAbility(m_uiIceFlameAbilityID))
						return true;

					if (CastAbility(m_uiSingleMediumNukeDOTAbilityID))
						return true;

					if (CastAbility(m_uiSingleBasicNukeAbilityID))
						return true;

					if (CastAbility(m_uiSingleUnresistableDOTAbilityID))
						return true;

					if (CastBlueOffensiveAbility(m_uiBluePoisonAEAbilityID, 3))
						return true;
					if (CastGreenOffensiveAbility(m_uiGreenPoisonDOTAbilityID, 1))
						return true;
					if (CastGreenOffensiveAbility(m_uiGreenDiseaseNukeAbilityID, 1))
						return true;
					if (CastGreenOffensiveAbility(m_uiGreenPoisonStunNukeAbilityID, 1))
						return true;
					if (CastBlueOffensiveAbility(m_uiBluePoisonAEAbilityID, 1))
						return true;

					if (UseOffensiveItems())
						return true;
				}
			}

			return false;
		}
	}
}
