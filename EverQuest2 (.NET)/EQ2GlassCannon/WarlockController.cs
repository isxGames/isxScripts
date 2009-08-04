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
		public int m_iGroupCastingSkillBuffAbilityID = -1;
		public int m_iGroupNoxiousBuffAbilityID = -1;
		public int m_iSingleSTRINTDebuffAbilityID = -1;
		public int m_iSingleBasicNukeAbilityID = -1;
		public int m_iSinglePrimaryPoisonNukeAbilityID = -1;
		public int m_iSingleUnresistableDOTAbilityID = -1;
		public int m_iSingleMediumNukeDOTAbilityID = -1;
		public int m_iSingleColdStunNukeAbilityID = -1;
		public int m_iGreenNoxiousDebuffAbilityID = -1;
		public int m_iGreenPoisonStunNukeAbilityID = -1;
		public int m_iGreenPoisonDOTAbilityID = -1;
		public int m_iGreenDiseaseNukeAbilityID = -1;
		public int m_iGreenDeaggroAbilityID = -1;
		public int m_iBluePoisonAEAbilityID = -1;
		public int m_iBlueMagicKnockbackAEAbilityID = -1;

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);
			return;
		}

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_iGroupCastingSkillBuffAbilityID = SelectHighestTieredAbilityID("Dark Pact");
			m_iGroupNoxiousBuffAbilityID = SelectHighestTieredAbilityID("Aspect of Darkness");
			m_iSingleBasicNukeAbilityID = SelectHighestTieredAbilityID("Dissolve");
			m_iSinglePrimaryPoisonNukeAbilityID = SelectHighestTieredAbilityID("Distortion");
			m_iSingleUnresistableDOTAbilityID = SelectHighestTieredAbilityID("Poison");
			m_iSingleMediumNukeDOTAbilityID = SelectHighestTieredAbilityID("Dark Pyre");
			m_iSingleColdStunNukeAbilityID = SelectHighestTieredAbilityID("Encase");
			m_iSingleSTRINTDebuffAbilityID = SelectHighestTieredAbilityID("Curse of Void");
			m_iGreenNoxiousDebuffAbilityID = SelectHighestTieredAbilityID("Vacuum Field");
			m_iGreenPoisonStunNukeAbilityID = SelectHighestTieredAbilityID("Dark Nebula");
			m_iGreenPoisonDOTAbilityID = SelectHighestTieredAbilityID("Apocalypse");
			m_iGreenDiseaseNukeAbilityID = SelectHighestTieredAbilityID("Absolution");
			m_iGreenDeaggroAbilityID = SelectHighestTieredAbilityID("Nullify");
			m_iBluePoisonAEAbilityID = SelectHighestTieredAbilityID("Cataclysm");
			m_iBlueMagicKnockbackAEAbilityID = SelectHighestTieredAbilityID("Rift");

			return;
		}

		/************************************************************************************/
		public override bool DoNextAction()
		{
			if (base.DoNextAction())
				return true;

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

				if (CheckToggleBuff(m_iGroupCastingSkillBuffAbilityID, true))
					return true;

				if (CheckToggleBuff(m_iGroupNoxiousBuffAbilityID, true))
					return true;

				if (CheckSingleTargetBuffs(m_iHateTransferAbilityID, m_strHateTransferTarget, true, true))
					return true;

				if (CheckRacialBuffs())
					return true;

				StopCheckingBuffs();
			}

			GetOffensiveTargetActor();
			if (!EngagePrimaryEnemy())
				return false;

			if (m_OffensiveTargetActor != null)
			{
				if (MeActor.IsIdle)
				{
					/// Deaggros.
					if (m_bIHaveAggro)
					{
						if (CastAbility(m_iGreenDeaggroAbilityID))
							return true;

						if (CastAbility(m_iGeneralGreenDeaggroAbilityID))
							return true;
					}

					if (m_OffensiveTargetActor.IsNamed && !IsAbilityMaintained(m_iSingleSTRINTDebuffAbilityID) && CastAbility(m_iSingleSTRINTDebuffAbilityID))
						return true;

					/// Resistance debuff is ALWAYS first.
					if (m_bUseGreenAEs && !IsAbilityMaintained(m_iGreenNoxiousDebuffAbilityID) && CastGreenOffensiveAbility(m_iGreenNoxiousDebuffAbilityID, 1))
						return true;

					if (CastBlueOffensiveAbility(m_iBlueMagicKnockbackAEAbilityID, 5))
						return true;
					if (CastBlueOffensiveAbility(m_iBluePoisonAEAbilityID, 7))
						return true;

					if (CastGreenOffensiveAbility(m_iGreenPoisonDOTAbilityID, 4))
						return true;
					if (CastGreenOffensiveAbility(m_iGreenDiseaseNukeAbilityID, 5))
						return true;
					if (CastGreenOffensiveAbility(m_iGreenPoisonStunNukeAbilityID, 6))
						return true;

					if (CastBlueOffensiveAbility(m_iBlueMagicKnockbackAEAbilityID, 4))
						return true;
					if (CastBlueOffensiveAbility(m_iBluePoisonAEAbilityID, 6))
						return true;

					if (CastGreenOffensiveAbility(m_iGreenPoisonDOTAbilityID, 2))
						return true;
					if (CastGreenOffensiveAbility(m_iGreenDiseaseNukeAbilityID, 3))
						return true;
					if (CastGreenOffensiveAbility(m_iGreenPoisonStunNukeAbilityID, 4))
						return true;

					if (CastBlueOffensiveAbility(m_iBluePoisonAEAbilityID, 3))
						return true;

					/// We don't get concerned with single debuffs until AE potential is used up.
					if (!m_OffensiveTargetActor.IsSolo && !IsAbilityMaintained(m_iSingleSTRINTDebuffAbilityID) && CastAbility(m_iSingleSTRINTDebuffAbilityID))
						return true;

					if (CastAbility(m_iSinglePrimaryPoisonNukeAbilityID))
						return true;

					if (CastAbility(m_iSingleMediumNukeDOTAbilityID))
						return true;

					if (CastAbility(m_iSingleColdStunNukeAbilityID))
						return true;

					if (CastAbility(m_iIceFlameAbilityID))
						return true;

					if (CastAbility(m_iSingleBasicNukeAbilityID))
						return true;

					if (CastAbility(m_iSingleUnresistableDOTAbilityID))
						return true;

					if (CastGreenOffensiveAbility(m_iGreenPoisonDOTAbilityID, 1))
						return true;
					if (CastGreenOffensiveAbility(m_iGreenDiseaseNukeAbilityID, 1))
						return true;
					if (CastGreenOffensiveAbility(m_iGreenPoisonStunNukeAbilityID, 1))
						return true;
					if (CastBlueOffensiveAbility(m_iBluePoisonAEAbilityID, 1))
						return true;
				}
			}

			Program.Log("Nothing left to cast.");
			return false;
		}
	}
}
