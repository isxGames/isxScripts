using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using InnerSpaceAPI;
using System.Threading;

namespace EQ2GlassCannon
{
	public class TemplarController : ClericController
	{
		#region INI settings
		public bool m_bBuffPhysicalMitigation = true;
		public bool m_bBuffArcaneResistance = true;
		public bool m_bBuffYaulp = false;
		public string m_strManaCureTarget = null;
		public string m_strStoneskinTarget = null;
		public string m_strSTRWISTarget = null;
		public List<string> m_astrMeleeSkillTargets = new List<string>();
		public List<string> m_astrMeleeHealProcTargets = new List<string>();
		#endregion

		#region Ability ID's
		public int m_iGroupArcaneBuffAbilityID = -1;
		public int m_iBlessingsAbilityID = -1;
		public int m_iManaCureAbilityID = -1;
		public int m_iSingleSTRWISBuffAbilityID = -1;
		public int m_iSingleStoneskinBuffAbilityID = -1;
		public int m_iMeleeSkillBuffAbilityID = -1;
		public int m_iMeleeHealProcBuffAbilityID = -1;
		public int m_iSanctuaryAbilityID = -1;

		public int m_iSingleReactiveHealAbilityID = -1;
		public int m_iHealingAbilityID = -1;
		public int m_iArchHealingAbilityID = -1;
		public int m_iSinglePowerToHealthAbilityID = -1;
		public int m_iSingleOneHitWardAbilityID = -1;
		public int m_iGroupReactiveHealAbilityID = -1;
		public int m_iGroupHealingAbilityID = -1;
		public int m_iGroupCombatRezAbilityID = -1;
		public int m_iSingleFullHealthCombatRezAbilityID = -1;
		public int m_iSingleNormalCombatRezAbilityID = -1;

		public int m_iSingleMitigationDebuffAbilityID = -1;
		public int m_iSingleDivineDebuffAbilityID = -1;
		public int m_iSingleWISDebuffAbilityID = -1;
		public int m_iSingleReactiveTraumaCureAbilityID = -1;
		public int m_iSingleReactiveDeathHealAbilityID = -1;
		public int m_iSingleSmiteAbilityID = -1;
		public int m_iSingleStunAbilityID = -1;
		public int m_iSingleDazeAbilityID = -1;
		public int m_iHammerDumbfirePetAbilityID = -1;
		#endregion

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferBool("Templar.BuffPhysicalMitigation", ref m_bBuffPhysicalMitigation);
			ThisFile.TransferBool("Templar.BuffArcaneResistance", ref m_bBuffArcaneResistance);
			ThisFile.TransferBool("Templar.BuffYaulp", ref m_bBuffYaulp);
			ThisFile.TransferString("Templar.ManaCureTarget", ref m_strManaCureTarget);
			ThisFile.TransferString("Templar.StoneskinTarget", ref m_strStoneskinTarget);
			ThisFile.TransferString("Templar.STRWISTarget", ref m_strSTRWISTarget);
			ThisFile.TransferStringList("Templar.MeleeSkillTargets", m_astrMeleeSkillTargets);
			ThisFile.TransferStringList("Templar.MeleeHealProcTargets", m_astrMeleeHealProcTargets);
			return;
		}

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			/// PriestController abilities.
			m_iShadowsDefensiveHealStance = SelectHighestAbilityID("Focused Prayers");
			m_iShadowsOffensiveHealStance = SelectHighestAbilityID("Peaceful Aggression");
			m_iGroupMitigationBuffAbilityID = SelectHighestTieredAbilityID("Holy Armor");
			m_iGroupWaterBreathingAbilityID = SelectHighestAbilityID("Watery Respite");

			m_iBlessingsAbilityID = SelectHighestAbilityID("Blessings");
			m_iManaCureAbilityID = SelectHighestAbilityID("Mana Cure");
			m_iSingleSTRWISBuffAbilityID = SelectHighestTieredAbilityID("Virtue");
			m_iSingleStoneskinBuffAbilityID = SelectHighestTieredAbilityID("Unyielding Benediction");
			m_iMeleeSkillBuffAbilityID = SelectHighestTieredAbilityID("Aegolism");
			m_iMeleeHealProcBuffAbilityID = SelectHighestTieredAbilityID("Glory");
			m_iSanctuaryAbilityID = SelectHighestAbilityID("Sanctuary");

			m_iSingleReactiveHealAbilityID = SelectHighestTieredAbilityID("Vital Intercession");
			m_iHealingAbilityID = SelectHighestTieredAbilityID("Meliorate");
			m_iArchHealingAbilityID = SelectHighestTieredAbilityID("Restoration");
			m_iSinglePowerToHealthAbilityID = SelectHighestAbilityID("Reverence");
			m_iSingleOneHitWardAbilityID = SelectHighestTieredAbilityID("Repent");
			m_iGroupReactiveHealAbilityID = SelectHighestTieredAbilityID("Holy Intercession");
			m_iGroupHealingAbilityID = SelectHighestTieredAbilityID("Word of Redemption");
			m_iGroupCombatRezAbilityID = SelectHighestAbilityID("Blazon Life");
			m_iSingleFullHealthCombatRezAbilityID = SelectHighestAbilityID("Resurrect");
			m_iSingleNormalCombatRezAbilityID = SelectHighestAbilityID("Battle's Reprieve");
			m_iGeneralGroupCureAbilityID = SelectHighestTieredAbilityID("Devoted Resolve");
			m_iGeneralSingleDeathSaveAbilityID = SelectHighestTieredAbilityID("Holy Salvation");
			m_iSingleMitigationDebuffAbilityID = SelectHighestTieredAbilityID("Rebuke");
			m_iSingleDivineDebuffAbilityID = SelectHighestTieredAbilityID("Mark of Divinity");
			m_iSingleWISDebuffAbilityID = SelectHighestTieredAbilityID("Smite Corruption");
			m_iSingleReactiveTraumaCureAbilityID = SelectHighestTieredAbilityID("Involuntary Gift");
			m_iSingleReactiveDeathHealAbilityID = SelectHighestTieredAbilityID("Healing Fate");
			m_iSingleSmiteAbilityID = SelectHighestTieredAbilityID("Divine Smite");
			m_iSingleStunAbilityID = SelectHighestTieredAbilityID("Awestruck");
			m_iSingleDazeAbilityID = SelectHighestTieredAbilityID("Sign of Pacification");
			m_iHammerDumbfirePetAbilityID = SelectHighestTieredAbilityID("Unswerving Hammer");

			return;
		}

		/************************************************************************************/
		public bool AttemptCures()
		{
			return AttemptCures(true, true, false, false);
		}

		/************************************************************************************/
		public override bool DoNextAction()
		{
			if (base.DoNextAction())
				return true;

			if (Me.CastingSpell || MeActor.IsDead)
				return true;

			if (m_bPrioritizeCures && AttemptCures())
				return true;

			/// Start this early just to get pet and autoattack rolling (illusionist mythical regen depends on it).
			/// We don't attempt offensive action until after cures/heals are dealt with.
			GetOffensiveTargetActor();

			if (CheckPositioningStance())
				return true;

			double fMyPowerRatio = (double)Me.Power / (double)Me.MaxPower;

			/// We'll refer to this multiple times so we might as well alias the value.
			bool bGroupRezAvailable = IsAbilityReady(m_iGroupCombatRezAbilityID);

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
				else if (ThisStatus.m_iCurrentHealth < ThisStatus.m_iMaximumHealth)
				{
					iTotalDeficientMembers++;

					double fHealthRatio = (double)ThisStatus.m_iCurrentHealth / (double)ThisStatus.m_iMaximumHealth;
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
				if (CheckShadowsHealStanceBuffs())
					return true;

				if (CheckToggleBuff(m_iGroupMitigationBuffAbilityID, m_bBuffPhysicalMitigation))
					return true;

				if (CheckSingleTargetBuffs(m_iShieldAllyAbilityID, m_strShieldAllyTarget))
					return true;

				if (CheckToggleBuff(m_iGroupArcaneBuffAbilityID, m_bBuffArcaneResistance))
					return true;

				if (CheckToggleBuff(m_iBlessingsAbilityID, true))
					return true;

				if (CheckToggleBuff(m_iGroupWaterBreathingAbilityID, m_bBuffGroupWaterBreathing))
					return true;

				if (CheckSingleTargetBuffs(m_iManaCureAbilityID, m_strManaCureTarget))
					return true;

				if (CheckSingleTargetBuffs(m_iSingleSTRWISBuffAbilityID, m_strSTRWISTarget))
					return true;

				if (CheckSingleTargetBuffs(m_iSingleStoneskinBuffAbilityID, m_strStoneskinTarget))
					return true;

				if (CheckSingleTargetBuffs(m_iMeleeSkillBuffAbilityID, m_astrMeleeSkillTargets))
					return true;

				if (CheckSingleTargetBuffs(m_iMeleeHealProcBuffAbilityID, m_astrMeleeHealProcTargets))
					return true;

				if (CheckToggleBuff(m_iYaulpAbilityID, m_bBuffYaulp))
					return true;

				if (CheckGroupWaterBreathingBuff())
					return true;

				if (CheckRacialBuffs())
					return true;

				if (CheckSpiritOfTheWolf())
					return true;

				StopCheckingBuffs();
			}

			bool bOffensiveTargetEngaged = EngagePrimaryEnemy();

			if (MeActor.IsIdle)
			{
				if (m_OffensiveTargetActor != null)
				{
					/// If Illusionist epic regen is up, do our fastest nuke to try and reap the benefit.
					/// Ideally it would be a lowest-tier spell because we know this nuke doesn't do shit for dps considering the power it uses,
					/// but we're not set up for that.
					if ((fMyPowerRatio < 0.20) && IsIllusionistSoothingMindActive() && CastAbility(m_iSingleSmiteAbilityID))
						return true;
				}

				if (MeActor.InCombatMode)
				{
					/// Death save.
					if (fLowestHealthRatio < 0.10)
					{
						if (CastAbility(m_iGeneralSingleDeathSaveAbilityID, strLowestHealthName, true))
							return true;
					}
				}

				/// Attempt to rez.
				if (iTotalDeadMembers > 0)
				{
					/// NOTE: Group rez risky if MT is getting rezzed and is outside of group.
					if (iTotalDeadMembers > 1 && bGroupRezAvailable)
					{
						if (CastAbility(m_iGroupCombatRezAbilityID, strNearestDeadName, false))
						{
							SpamSafeGroupSay(m_strGroupRezCallout, strNearestDeadName);
							SpamSafeRaidSay(m_strGroupRezCallout, strNearestDeadName);
							return true;
						}
					}
					else
					{
						/// Single rez. It's all we can do.
						if (CastAbility(m_iSingleFullHealthCombatRezAbilityID, strNearestDeadName, false) ||
							CastAbility(m_iSingleNormalCombatRezAbilityID, strNearestDeadName, false) ||
							(!Me.IsHated && CastAbility(m_iGeneralNonCombatRezAbilityID, strNearestDeadName, false)))
						{
							SpamSafeGroupSay(m_strSingleRezCallout, strNearestDeadName);
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
					if (bTempBuffsOrDumbfiresAdvised && CastAbility(m_iDivineRecoveryAbilityID, Me.Name, true))
						return true;

					if (!IsAbilityMaintained(m_iSingleMitigationDebuffAbilityID) && CastAbility(m_iSingleMitigationDebuffAbilityID))
						return true;

					if (CastAbility(m_iSkullCrackAbilityID))
						return true;

					if (CastAbility(m_iLoreAndLegendAbilityID))
						return true;

					if (!IsAbilityMaintained(m_iSingleDivineDebuffAbilityID) && CastAbility(m_iSingleDivineDebuffAbilityID))
						return true;

					if (!IsAbilityMaintained(m_iSingleWISDebuffAbilityID) && CastAbility(m_iSingleWISDebuffAbilityID))
						return true;

					if (!IsAbilityMaintained(m_iSingleReactiveTraumaCureAbilityID) && CastAbility(m_iSingleReactiveTraumaCureAbilityID))
						return true;

					if (bTempBuffsOrDumbfiresAdvised && !IsAbilityMaintained(m_iHammerDumbfirePetAbilityID) && CastAbility(m_iHammerDumbfirePetAbilityID))
						return true;

					if (!m_OffensiveTargetActor.IsEpic && !IsAbilityMaintained(m_iSingleReactiveDeathHealAbilityID) && CastAbility(m_iSingleReactiveDeathHealAbilityID))
						return true;
				}

				if (iTotalDeficientMembersBelowGroupHealTolerance > 1 && CastAbility(m_iGroupHealingAbilityID, Me.Name, true))
					return true;

				if (MeActor.InCombatMode && CastAbility(m_iSingleOneHitWardAbilityID, m_strMainTank, true))
					return true;

				if (!string.IsNullOrEmpty(strLowestHealthName))
				{
					if (CastAbility(m_iHealingAbilityID, strLowestHealthName, true))
						return true;

					if (CastAbility(m_iArchHealingAbilityID, strLowestHealthName, true))
						return true;
				}

				/// This needs to be kept up on the MT.
				if (MeActor.InCombatMode && CastAbility(m_iSingleReactiveHealAbilityID, m_strMainTank, true))
					return true;

				if (MeActor.InCombatMode && !IsAbilityMaintained(m_iGroupReactiveHealAbilityID) && CastAbility(m_iGroupReactiveHealAbilityID, Me.Name, true))
					return true;

				if (!string.IsNullOrEmpty(strLowestHealthName))
				{
					if (MeActor.InCombatMode && CastAbility(m_iSinglePowerToHealthAbilityID, strLowestHealthName, true))
						return true;
				}

				if (iTotalDeficientMembers > 1 && (fNetHealthGap > 30.0) && CastAbility(m_iGroupHealingAbilityID, Me.Name, true))
					return true;

				/// (fill this spot with any other spells)

				/// If anyone at all is missing health, do a group heal, because this is all that's left.
				if (!string.IsNullOrEmpty(strLowestHealthName))
				{
					if (CastAbility(m_iGroupHealingAbilityID, Me.Name, true))
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
