using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2SuiteLib;

namespace EQ2GlassCannon
{
	public class TemplarController : ClericController
	{
		#region INI settings
		public bool m_bBuffArcaneResistance = true;
		public bool m_bBuffYaulp = false;
		public List<string> m_astrManaCureTargets = new List<string>();
		public List<string> m_astrStoneskinTargets = new List<string>();
		public List<string> m_astrSTRWISTargets = new List<string>();
		public List<string> m_astrMeleeSkillTargets = new List<string>();
		public List<string> m_astrMeleeHealProcTargets = new List<string>();
		#endregion

		#region Ability ID's
		protected uint m_uiGroupArcaneBuffAbilityID = 0;
		protected uint m_uiBlessingsAbilityID = 0;
		protected uint m_uiManaCureAbilityID = 0;
		protected uint m_uiSingleSTRWISBuffAbilityID = 0;
		protected uint m_uiSingleStoneskinBuffAbilityID = 0;
		protected uint m_uiMeleeSkillBuffAbilityID = 0;
		protected uint m_uiMeleeHealProcBuffAbilityID = 0;
		protected uint m_uiSanctuaryAbilityID = 0;

		protected uint m_uiSingleReactiveHealAbilityID = 0;
		protected uint m_uiHealingAbilityID = 0;
		protected uint m_uiArchHealingAbilityID = 0;
		protected uint m_uiSinglePowerToHealthAbilityID = 0;
		protected uint m_uiSingleOneHitWardAbilityID = 0;
		protected uint m_uiGroupReactiveHealAbilityID = 0;
		protected uint m_uiGroupHealingAbilityID = 0;
		protected uint m_uiGroupCombatRezAbilityID = 0;
		protected uint m_uiSingleFullHealthCombatRezAbilityID = 0;
		protected uint m_uiSingleNormalCombatRezAbilityID = 0;

		protected uint m_uiSingleMitigationDebuffAbilityID = 0;
		protected uint m_uiSingleDivineDebuffAbilityID = 0;
		protected uint m_uiSingleWISDebuffAbilityID = 0;
		protected uint m_uiSingleReactiveTraumaCureAbilityID = 0;
		protected uint m_uiSingleReactiveDeathHealAbilityID = 0;
		protected uint m_uiSingleSmiteAbilityID = 0;
		protected uint m_uiSingleStunAbilityID = 0;
		protected uint m_uiSingleDazeAbilityID = 0;
		protected uint m_uiHammerDumbfirePetAbilityID = 0;
		#endregion

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferBool("Templar.BuffPhysicalMitigation", ref m_bBuffPhysicalMitigation);
			ThisFile.TransferBool("Templar.BuffArcaneResistance", ref m_bBuffArcaneResistance);
			ThisFile.TransferBool("Templar.BuffYaulp", ref m_bBuffYaulp);
			ThisFile.TransferStringList("Templar.ManaCureTargets", m_astrManaCureTargets);
			ThisFile.TransferStringList("Templar.StoneskinTargets", m_astrStoneskinTargets);
			ThisFile.TransferStringList("Templar.STRWISTargets", m_astrSTRWISTargets);
			ThisFile.TransferStringList("Templar.MeleeSkillTargets", m_astrMeleeSkillTargets);
			ThisFile.TransferStringList("Templar.MeleeHealProcTargets", m_astrMeleeHealProcTargets);
			return;
		}

		/************************************************************************************/
		protected override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			/// PriestController abilities.
			m_uiShadowsDefensiveHealStance = SelectHighestAbilityID("Focused Prayers");
			m_uiShadowsOffensiveHealStance = SelectHighestAbilityID("Peaceful Aggression");
			m_uiGroupMitigationBuffAbilityID = SelectHighestTieredAbilityID("Holy Armor");
			m_uiGroupWaterBreathingAbilityID = SelectHighestAbilityID("Watery Respite");

			m_uiBlessingsAbilityID = SelectHighestAbilityID("Blessings");
			m_uiManaCureAbilityID = SelectHighestAbilityID("Mana Cure");
			m_uiSingleSTRWISBuffAbilityID = SelectHighestTieredAbilityID("Virtue");
			m_uiSingleStoneskinBuffAbilityID = SelectHighestTieredAbilityID("Unyielding Benediction");
			m_uiMeleeSkillBuffAbilityID = SelectHighestTieredAbilityID("Aegolism");
			m_uiMeleeHealProcBuffAbilityID = SelectHighestTieredAbilityID("Glory");
			m_uiSanctuaryAbilityID = SelectHighestAbilityID("Sanctuary");

			m_uiSingleReactiveHealAbilityID = SelectHighestTieredAbilityID("Vital Intercession");
			m_uiHealingAbilityID = SelectHighestTieredAbilityID("Meliorate");
			m_uiArchHealingAbilityID = SelectHighestTieredAbilityID("Restoration");
			m_uiSinglePowerToHealthAbilityID = SelectHighestAbilityID("Reverence");
			m_uiSingleOneHitWardAbilityID = SelectHighestTieredAbilityID("Repent");
			m_uiGroupReactiveHealAbilityID = SelectHighestTieredAbilityID("Holy Intercession");
			m_uiGroupHealingAbilityID = SelectHighestTieredAbilityID("Word of Redemption");
			m_uiGroupCombatRezAbilityID = SelectHighestAbilityID("Blazon Life");
			m_uiSingleFullHealthCombatRezAbilityID = SelectHighestAbilityID("Resurrect");
			m_uiSingleNormalCombatRezAbilityID = SelectHighestAbilityID("Battle's Reprieve");
			m_uiGeneralGroupCureAbilityID = SelectHighestTieredAbilityID("Devoted Resolve");
			m_uiGeneralSingleDeathSaveAbilityID = SelectHighestTieredAbilityID("Holy Salvation");
			m_uiSingleMitigationDebuffAbilityID = SelectHighestTieredAbilityID("Rebuke");
			m_uiSingleDivineDebuffAbilityID = SelectHighestTieredAbilityID("Mark of Divinity");
			m_uiSingleWISDebuffAbilityID = SelectHighestTieredAbilityID("Smite Corruption");
			m_uiSingleReactiveTraumaCureAbilityID = SelectHighestTieredAbilityID("Involuntary Gift");
			m_uiSingleReactiveDeathHealAbilityID = SelectHighestTieredAbilityID("Healing Fate");
			m_uiSingleSmiteAbilityID = SelectHighestTieredAbilityID("Divine Smite");
			m_uiSingleStunAbilityID = SelectHighestTieredAbilityID("Awestruck");
			m_uiSingleDazeAbilityID = SelectHighestTieredAbilityID("Sign of Pacification");
			m_uiHammerDumbfirePetAbilityID = SelectHighestTieredAbilityID("Unswerving Hammer");

			return;
		}

		/************************************************************************************/
		protected bool AttemptCures()
		{
			return AttemptCures(true, true, false, false);
		}

		/************************************************************************************/
		protected override bool DoNextAction()
		{
			if (base.DoNextAction() || MeActor.IsDead)
				return true;

			if (IsCasting)
			{
				return true;
			}

			if (m_bPrioritizeCures && AttemptCures())
				return true;

			/// Start this early just to get pet and autoattack rolling (illusionist mythical regen depends on it).
			/// We don't attempt offensive action until after cures/heals are dealt with.
			GetOffensiveTargetActor();

			if (CheckPositioningStance())
				return true;

			VitalStatus MyStatus = null;
			if (!GetVitalStatus(Name, ref MyStatus))
				return true;
			double fMyPowerRatio = MyStatus.PowerRatio;

			/// We'll refer to this multiple times so we might as well alias the value.
			bool bGroupRezAvailable = IsAbilityReady(m_uiGroupCombatRezAbilityID);

			string strLowestHealthName = string.Empty;
			int iLowestHealthAmount = int.MaxValue;
			double fLowestHealthRatio = double.MaxValue;
			int iTotalDeficientMembers = 0;
			int iTotalDeficientMembersBelowGroupHealTolerance = 0;
			int iTotalDeadMembers = 0;
			string strNearestDeadName = string.Empty;
			double fNearestDeadDistance = double.MaxValue;
			double fNetHealthGap = 0.0f; /// The sum of everyone's gap percentages.

			/// First things first, we evaluate the heal situation.
			foreach (VitalStatus ThisStatus in EnumVitalStatuses(m_bHealUngroupedMainTank))
			{
				double fHealthRatio = ThisStatus.HealthRatio;
				if (ThisStatus.m_bIsDead)
				{
					iTotalDeadMembers++;

					/// Establish the nearest (and least risky) dead player.
					double fDistance = GetActorDistance3D(MeActor, ThisStatus.m_Actor);
					if (fDistance < fNearestDeadDistance)
					{
						strNearestDeadName = ThisStatus.m_strName;
						fNearestDeadDistance = fDistance;
					}
				}
				else if (fHealthRatio < m_fHealThresholdRatio)
				{
					iTotalDeficientMembers++;

					if (fHealthRatio < fLowestHealthRatio)
					{
						strLowestHealthName = ThisStatus.m_strName;
						fLowestHealthRatio = fHealthRatio;
					}
					if (ThisStatus.m_iCurrentHealth < iLowestHealthAmount)
						iLowestHealthAmount = ThisStatus.m_iCurrentHealth;

					if (fHealthRatio < 0.80)
						iTotalDeficientMembersBelowGroupHealTolerance++;

					fNetHealthGap += (1.0f - fHealthRatio) * 100.0f;
				}
			}

			/// Do buffs only if the vital situation isn't grim.
			if (m_bCheckBuffsNow && (fLowestHealthRatio > 0.80f))
			{
				if (CheckWaterBreathingBuffs())
					return true;
				if (CheckShadowsHealStanceBuffs())
					return true;
				if (CheckToggleBuff(m_uiGroupMitigationBuffAbilityID, m_bBuffPhysicalMitigation))
					return true;
				if (CheckSingleTargetBuff(m_uiShieldAllyAbilityID, m_strShieldAllyTargets))
					return true;
				if (CheckToggleBuff(m_uiGroupArcaneBuffAbilityID, m_bBuffArcaneResistance))
					return true;
				if (CheckToggleBuff(m_uiBlessingsAbilityID, true))
					return true;
				if (CheckToggleBuff(m_uiGroupWaterBreathingAbilityID, m_bBuffGroupWaterBreathing))
					return true;
				if (CheckSingleTargetBuff(m_uiManaCureAbilityID, m_astrManaCureTargets))
					return true;
				if (CheckSingleTargetBuff(m_uiSingleSTRWISBuffAbilityID, m_astrSTRWISTargets))
					return true;
				if (CheckSingleTargetBuff(m_uiSingleStoneskinBuffAbilityID, m_astrStoneskinTargets))
					return true;
				if (CheckSingleTargetBuffs(m_uiMeleeSkillBuffAbilityID, m_astrMeleeSkillTargets))
					return true;
				if (CheckSingleTargetBuffs(m_uiMeleeHealProcBuffAbilityID, m_astrMeleeHealProcTargets))
					return true;
				if (CheckToggleBuff(m_uiYaulpAbilityID, m_bBuffYaulp))
					return true;
				if (CheckRacialBuffs())
					return true;
				if (CheckSpiritOfTheWolf())
					return true;
				StopCheckingBuffs();
			}

			bool bOffensiveTargetEngaged = EngageOffensiveTarget();

			if (IsIdle)
			{
				if (m_OffensiveTargetActor != null)
				{
					/// If Illusionist epic regen is up, do our fastest nuke to try and reap the benefit.
					/// Ideally it would be a lowest-tier spell because we know this nuke doesn't do shit for dps considering the power it uses,
					/// but we're not set up for that.
					if ((fMyPowerRatio < 0.20) && IsIllusionistSoothingMindActive() && CastAbility(m_uiSingleSmiteAbilityID))
						return true;
				}

				if (MeActor.InCombatMode)
				{
					/// Death save.
					if (fLowestHealthRatio < 0.10)
					{
						if (CastAbility(m_uiGeneralSingleDeathSaveAbilityID, strLowestHealthName, true))
							return true;
					}
				}

				/// Attempt to rez.
				if (iTotalDeadMembers > 0)
				{
					/// NOTE: Group rez risky if MT is getting rezzed and is outside of group.
					if (iTotalDeadMembers > 1 && bGroupRezAvailable)
					{
						if (CastAbility(m_uiGroupCombatRezAbilityID, strNearestDeadName, false))
						{
							SpamSafeRaidSay(m_strGroupRezCallout, strNearestDeadName);
							return true;
						}
					}
					else
					{
						/// Single rez. It's all we can do.
						if (CastAbility(m_uiSingleFullHealthCombatRezAbilityID, strNearestDeadName, false) ||
							CastAbility(m_uiSingleNormalCombatRezAbilityID, strNearestDeadName, false) ||
							(!Me.IsHated && CastAbility(m_uiGeneralNonCombatRezAbilityID, strNearestDeadName, false)))
						{
							SpamSafeRaidSay(m_strSingleRezCallout, strNearestDeadName);
							return true;
						}
					}
				}

				bool bTempBuffsOrDumbfiresAdvised = AreTempOffensiveBuffsAdvised();

				/// If vitals look acceptable for now, then we try debuffs and/or damage.
				/// Do debuffs only if the vital situation isn't grim.
				if (bOffensiveTargetEngaged && (fLowestHealthRatio > 0.90))
				{
					if (bTempBuffsOrDumbfiresAdvised && CastAbilityOnSelf(m_uiDivineRecoveryAbilityID))
						return true;

					if (!IsAbilityMaintained(m_uiSingleMitigationDebuffAbilityID) && CastAbility(m_uiSingleMitigationDebuffAbilityID))
						return true;

					if (CastAbility(m_uiSkullCrackAbilityID))
						return true;

					if (CastAbility(m_uiLoreAndLegendAbilityID))
						return true;

					if (!IsAbilityMaintained(m_uiSingleDivineDebuffAbilityID) && CastAbility(m_uiSingleDivineDebuffAbilityID))
						return true;

					if (!IsAbilityMaintained(m_uiSingleWISDebuffAbilityID) && CastAbility(m_uiSingleWISDebuffAbilityID))
						return true;

					if (!IsAbilityMaintained(m_uiSingleReactiveTraumaCureAbilityID) && CastAbility(m_uiSingleReactiveTraumaCureAbilityID))
						return true;

					if (bTempBuffsOrDumbfiresAdvised && !IsAbilityMaintained(m_uiHammerDumbfirePetAbilityID) && CastAbility(m_uiHammerDumbfirePetAbilityID))
						return true;

					if (!m_OffensiveTargetActor.IsEpic)
					{
						if (CastAbility(m_uiSingleStunAbilityID))
							return true;

						/// Don't waste this while the stun is active.
						if (!IsAbilityMaintained(m_uiSingleStunAbilityID) && CastAbility(m_uiSingleDazeAbilityID))
							return true;

						if (!IsAbilityMaintained(m_uiSingleReactiveDeathHealAbilityID) && CastAbility(m_uiSingleReactiveDeathHealAbilityID))
							return true;
					}
				}

				if (iTotalDeficientMembersBelowGroupHealTolerance > 1 && CastAbilityOnSelf(m_uiGroupHealingAbilityID))
					return true;

				if (MeActor.InCombatMode && CastAbility(m_uiSingleOneHitWardAbilityID, m_astrMainTanks, true))
					return true;

				if (!string.IsNullOrEmpty(strLowestHealthName))
				{
					if (CastAbility(m_uiHealingAbilityID, strLowestHealthName, true))
						return true;

					if (CastAbility(m_uiArchHealingAbilityID, strLowestHealthName, true))
						return true;
				}

				/// This needs to be kept up on the MT.
				if (MeActor.InCombatMode && CastAbility(m_uiSingleReactiveHealAbilityID, m_astrMainTanks, true))
					return true;

				if (MeActor.InCombatMode && !IsAbilityMaintained(m_uiGroupReactiveHealAbilityID) && CastAbilityOnSelf(m_uiGroupReactiveHealAbilityID))
					return true;

				if (!string.IsNullOrEmpty(strLowestHealthName))
				{
					if (MeActor.InCombatMode && CastAbility(m_uiSinglePowerToHealthAbilityID, strLowestHealthName, true))
						return true;
				}

				if (iTotalDeficientMembers > 1 && (fNetHealthGap > 30.0) && CastAbilityOnSelf(m_uiGroupHealingAbilityID))
					return true;

				/// (fill this spot with any other spells)

				/// If anyone at all is missing health, do a group heal, because this is all that's left.
				if (!string.IsNullOrEmpty(strLowestHealthName))
				{
					if (CastAbilityOnSelf(m_uiGroupHealingAbilityID))
						return true;
				}

				if (!m_bPrioritizeCures && AttemptCures())
					return true;
			}

			if (bOffensiveTargetEngaged)
			{
				Program.Log("DEBUG: NEED MORE TO DO");
			}

			return false;
		}
	}
}
