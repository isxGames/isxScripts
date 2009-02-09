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
		public int m_iGroupMitigationBuffAbilityID = -1;
		public int m_iGroupArcaneBuffAbilityID = -1;
		public int m_iBlessingsAbilityID = -1;
		public int m_iManaCureAbilityID = -1;
		public int m_iSingleSTRWISBuffAbilityID = -1;
		public int m_iSingleStoneskinBuffAbilityID = -1;
		public int m_iMeleeSkillBuffAbilityID = -1;
		public int m_iMeleeHealProcBuffAbilityID = -1;

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
		public override void TransferINISettings(PlayerController.TransferType eTransferType)
		{
			base.TransferINISettings(eTransferType);

			TransferINIBool(eTransferType, "Templar.BuffPhysicalMitigation", ref m_bBuffPhysicalMitigation);
			TransferINIBool(eTransferType, "Templar.BuffArcaneResistance", ref m_bBuffArcaneResistance);
			TransferINIBool(eTransferType, "Templar.BuffYaulp", ref m_bBuffYaulp);
			TransferINIString(eTransferType, "Templar.ManaCureTarget", ref m_strManaCureTarget);
			TransferINIString(eTransferType, "Templar.StoneskinTarget", ref m_strStoneskinTarget);
			TransferINIString(eTransferType, "Templar.STRWISTarget", ref m_strSTRWISTarget);
			TransferINIStringList(eTransferType, "Templar.MeleeSkillTargets", m_astrMeleeSkillTargets);
			TransferINIStringList(eTransferType, "Templar.MeleeHealProcTargets", m_astrMeleeHealProcTargets);
			return;
		}

		/************************************************************************************/
		public override void InitializeKnowledgeBook()
		{
			base.InitializeKnowledgeBook();

			m_iGroupMitigationBuffAbilityID = SelectHighestAbilityID(
				"Courage",
				"Daring",
				"Bravery",
				"Valor",
				"Gallantry",
				"Holy Armor");

			m_iGroupWaterBreathingAbilityID = SelectHighestAbilityID("Watery Respite");
			m_iBlessingsAbilityID = SelectHighestAbilityID("Blessings");
			m_iManaCureAbilityID = SelectHighestAbilityID("Mana Cure");

			m_iSingleSTRWISBuffAbilityID = SelectHighestAbilityID(
				"Protectorate",
				"Praetorate",
				"Divine Praetorate",
				"Celestial Praetorate",
				"Virtue");
			
			m_iSingleStoneskinBuffAbilityID = SelectHighestAbilityID(
				"Vigilant Benediction",
				"Unyielding Benediction");

			m_iMeleeSkillBuffAbilityID = SelectHighestAbilityID(
				"Minor Redoubt",
				"Redoubt",
				"Pious Redoubt",
				"Sacred Redoubt",
				"Holy Redoubt",
				"Aegolism");

			m_iMeleeHealProcBuffAbilityID = SelectHighestAbilityID(
				"Glory of Combat",
				"Glory of Battle",
				"Glory");

			m_iSingleReactiveHealAbilityID = SelectHighestAbilityID(
				"Bestowal of Vitae",
				"Bestowal of Vitality",
				"Supplicant's Prayer",
				"Greater Intercession",
				"Grand Intercession",
				"Glorious Intercession",
				"Vital Intercession");

			m_iHealingAbilityID = SelectHighestAbilityID(
				"Minor Healing",
				"Healing",
				"Greater Healing",
				"Ameliorate",
				"Amelioration",
				"Greater Amelioration",
				"Grand Amelioration",
				"Meliorate");

			m_iArchHealingAbilityID = SelectHighestAbilityID(
				"Minor Arch Healing",
				"Arch Healing",
				"Greater Arch Healing",
				"Restoration",
				"Greater Restoration",
				"Grand Restoration",
				"Arch Restoration");

			m_iSinglePowerToHealthAbilityID = SelectHighestAbilityID("Reverence");
			m_iSingleOneHitWardAbilityID = SelectHighestAbilityID("Repent");

			m_iGroupReactiveHealAbilityID = SelectHighestAbilityID(
				"Soothing Sermon",
				"Intercession",
				"Crucial Intercession",
				"Fateful Intercession",
				"Grand Intercession",
				"Dire Intercession",
				"Holy Intercession");

			m_iGroupHealingAbilityID = SelectHighestAbilityID(
				"Healing Word",
				"Healing Touch",
				"Word of Restoration",
				"Word of Atonement",
				"Word of Reparation");

			m_iGroupCombatRezAbilityID = SelectHighestAbilityID("Blazon Life");
			m_iSingleFullHealthCombatRezAbilityID = SelectHighestAbilityID("Resurrect");
			m_iSingleNormalCombatRezAbilityID = SelectHighestAbilityID("Battle's Reprieve");

			m_iGeneralGroupCureAbilityID = SelectHighestAbilityID(
				"Cure: Resolve",
				"Cure: Ardent Resolve",
				"Devoted Resolve");

			m_iGeneralSingleDeathSaveAbilityID = SelectHighestAbilityID(
				"Salvation",
				"Faithful Salvation",
				"Forgiving Salvation");

			m_iSingleMitigationDebuffAbilityID = SelectHighestAbilityID(
				"Rebuke",
				"Scorn",
				"Disgrace",
				"Reproach",
				"Admonishment",
				"Reproval");

			m_iSingleDivineDebuffAbilityID = SelectHighestAbilityID(
				"Mark of Pawns",
				"Mark of Princes",
				"Mark of Kings",
				"Mark of the Celestial");

			m_iSingleWISDebuffAbilityID = SelectHighestAbilityID(
				"Symbol of Corruption",
				"Punish Corruption",
				"Smite Corruption");
	
			m_iSingleReactiveTraumaCureAbilityID = SelectHighestAbilityID(
				"Involuntary Healer",
				"Involuntary Curate");

			m_iSingleReactiveDeathHealAbilityID = SelectHighestAbilityID(
				"Amending Fate",
				"Redemptive Fate",
				"Atoning Fate",
				"Supplicating Fate",
				"Healing Fate");

			m_iSingleSmiteAbilityID = SelectHighestAbilityID(
				"Smite",
				"Admonishing Smite",
				"Greater Smite",
				"Reproving Smite",
				"Condemning Smite",
				"Judging Smite",
				"Divine Smite");

			m_iSingleStunAbilityID = SelectHighestAbilityID(
				"Prostrate",
				"Force Submission",
				"Forced Humility",
				"Awestruck");

			m_iSingleDazeAbilityID = SelectHighestAbilityID(
				"Sign of Pacification",
				"Sign of Weakness",
				"Sign of Debility",
				"Sign of Infirmity",
				"Sign of Frailty",
				"Sign of Placation");

			m_iHammerDumbfirePetAbilityID = SelectHighestAbilityID(
				"Unswerving Hammer",
				"Unflinching Hammer");

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
			foreach (VitalStatus ThisStatus in EnumVitalStatuses(m_bHealMainTank))
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
				if (CheckToggleBuff(m_iGroupMitigationBuffAbilityID, m_bBuffPhysicalMitigation))
					return true;

				if (CheckSingleTargetBuffs(m_iShieldAllyAbilityID, m_strShieldAllyTarget, true, false))
					return true;

				if (CheckToggleBuff(m_iGroupArcaneBuffAbilityID, m_bBuffArcaneResistance))
					return true;

				if (CheckToggleBuff(m_iBlessingsAbilityID, true))
					return true;

				if (CheckToggleBuff(m_iGroupWaterBreathingAbilityID, m_bBuffGroupWaterBreathing))
					return true;

				if (CheckSingleTargetBuffs(m_iManaCureAbilityID, m_strManaCureTarget, true, false))
					return true;

				if (CheckSingleTargetBuffs(m_iSingleSTRWISBuffAbilityID, m_strSTRWISTarget, true, false))
					return true;

				if (CheckSingleTargetBuffs(m_iSingleStoneskinBuffAbilityID, m_strStoneskinTarget, true, false))
					return true;

				if (CheckSingleTargetBuffs(m_iMeleeSkillBuffAbilityID, m_astrMeleeSkillTargets, true, false))
					return true;

				if (CheckSingleTargetBuffs(m_iMeleeHealProcBuffAbilityID, m_astrMeleeHealProcTargets, true, false))
					return true;

				if (CheckGroupWaterBreathingBuff())
					return true;

				if (CheckRacialBuffs())
					return true;

				if (CheckSpiritOfTheWolf())
					return true;

				StopCheckingBuffs();
			}

			bool bOffensiveTargetEngaged = EngageOffensiveTargetActor();

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

					if (m_bSpamCrowdControl && !m_OffensiveTargetActor.IsEpic)
					{
						if (m_OffensiveTargetActor.CanTurn && CastAbility(m_iSingleStunAbilityID))
							return true;

						if (!IsAbilityMaintained(m_iSingleStunAbilityID) && CastAbility(m_iSingleDazeAbilityID))
							return true;
					}

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
