using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2.ISXEQ2;

namespace EQ2GlassCannon
{
	public class MysticController : ShamanController
	{
		#region INI settings
		public bool m_bBuffPhysicalMitigation = true;
		public bool m_bBuffNoxiousResistance = true;
		public bool m_bBuffSTRSTA = true;
		public List<string> m_astrHealthPoolTargets = new List<string>();
		public string m_strAvatarTarget = string.Empty;
		public string m_strAncestryTarget = string.Empty;
		public string m_strRitualOfAlacrityTarget = string.Empty;
		#endregion

		#region Ability ID's
		public int m_iGroupMitigationBuffAbilityID = -1;
		public int m_iGroupNoxiousBuffAbilityID = -1;
		public int m_iGroupSTRSTABuffAbilityID = -1;
		public int m_iSingleHealthPoolBuffAbilityID = -1;
		public int m_iSpiritCompanionAbilityID = -1;
		public int m_iUrsineAbilityID = -1;
		public int m_iSingleStatBuffAbilityID = -1;
		public int m_iSingleProcBuffAbilityID = -1;

		public int m_iSingleWardAbilityID = -1;
		public int m_iHealingAbilityID = -1;
		public int m_iBiggerHealingAbilityID = -1;
		public int m_iGroupWardAbilityID = -1;
		public int m_iGroupHealingAbilityID = -1;
		public int m_iGroupCombatRezAbilityID = -1;
		public int m_iSingleWardedCombatRezAbilityID = -1;
		public int m_iSingleNormalCombatRezAbilityID = -1;
		public int m_iDumbfireHealPetAbilityID = -1;
		public int m_iDumbfireWardPetAbilityID = -1;

		public int m_iGreenResistDebuffAbilityID = -1;
		public int m_iGreenHasteDebuffAbilityID = -1;
		public int m_iGreenDPSDebuffAbilityID = -1;
		public int m_iSingleHasteDebuffAbilityID = -1;
		public int m_iSingleDPSDebuffAbilityID = -1;
		public int m_iSingleSTRSTADebuffAbilityID = -1;
		public int m_iSingleFastShadowBaneNukeAbilityID = -1;
		public int m_iSingleColdSnareAbilityID = -1;
		#endregion

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferBool("Mystic.BuffPhysicalMitigation", ref m_bBuffPhysicalMitigation);
			ThisFile.TransferBool("Mystic.BuffNoxiousResistance", ref m_bBuffNoxiousResistance);
			ThisFile.TransferBool("Mystic.BuffSTRSTA", ref m_bBuffSTRSTA);
			ThisFile.TransferStringList("Mystic.HealthPoolTargets", m_astrHealthPoolTargets);
			ThisFile.TransferString("Mystic.AvatarTarget", ref m_strAvatarTarget);
			ThisFile.TransferString("Mystic.AncestryTarget", ref m_strAncestryTarget);
			ThisFile.TransferString("Mystic.RitualOfAlacrityTarget", ref m_strRitualOfAlacrityTarget);
			return;
		}

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_iGeneralGroupCureAbilityID = SelectHighestTieredAbilityID("Ebbing Spirit");
			m_iGeneralSingleDeathSaveAbilityID = SelectHighestTieredAbilityID("Ancestral Savior");
			m_iGroupMitigationBuffAbilityID = SelectHighestTieredAbilityID("Runic Armor");
			m_iGroupNoxiousBuffAbilityID = SelectHighestTieredAbilityID("Ancestral Mettle");
			m_iGroupSTRSTABuffAbilityID = SelectHighestTieredAbilityID("Spirit of the Mammoth");
			m_iGroupWaterBreathingAbilityID = SelectHighestAbilityID("Water Spirit");
			m_iSingleHealthPoolBuffAbilityID = SelectHighestTieredAbilityID("Premonition");
			m_iSpiritCompanionAbilityID = SelectHighestAbilityID("Summon Spirit Companion");
			m_iUrsineAbilityID = SelectHighestTieredAbilityID("Ursine Avatar");
			m_iSingleStatBuffAbilityID = SelectHighestTieredAbilityID("Ancestral Avatar");
			m_iSingleProcBuffAbilityID = SelectHighestAbilityID("Ancestry");
			m_iSingleWardAbilityID = SelectHighestTieredAbilityID("Ancestral Ward");
			m_iHealingAbilityID = SelectHighestTieredAbilityID("Rejuvenation");
			m_iBiggerHealingAbilityID = SelectHighestTieredAbilityID("Ritual Healing");
			m_iGroupWardAbilityID = SelectHighestTieredAbilityID("Umbral Warding");
			m_iGroupHealingAbilityID = SelectHighestTieredAbilityID("Transcendence");
			m_iGroupCombatRezAbilityID = SelectHighestAbilityID("Fields of the Grey");
			m_iSingleWardedCombatRezAbilityID = SelectHighestAbilityID("Recall of the Grey");
			m_iSingleNormalCombatRezAbilityID = SelectHighestAbilityID("Path of the Grey");
			m_iDumbfireHealPetAbilityID = SelectHighestTieredAbilityID("Lunar Attendant");
			m_iDumbfireWardPetAbilityID = SelectHighestAbilityID("Ancestral Sentry");
			m_iGreenResistDebuffAbilityID = SelectHighestTieredAbilityID("Echoes of the Ancients");
			m_iGreenHasteDebuffAbilityID = SelectHighestTieredAbilityID("Lethargy");
			m_iGreenDPSDebuffAbilityID = SelectHighestTieredAbilityID("Umbral Trap");
			m_iSingleHasteDebuffAbilityID = SelectHighestTieredAbilityID("Haze");
			m_iSingleDPSDebuffAbilityID = SelectHighestTieredAbilityID("Lamenting Soul");
			m_iSingleSTRSTADebuffAbilityID = SelectHighestTieredAbilityID("Deteriorate");
			m_iSingleFastShadowBaneNukeAbilityID = SelectHighestTieredAbilityID("Plague");
			m_iSingleColdSnareAbilityID = SelectHighestTieredAbilityID("Velium Winds");

			return;
		}

		/************************************************************************************/
		public bool AttemptCures()
		{
			return AttemptCures(false, true, true, false);
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
				if (CheckToggleBuff(m_iCoagulateAbilityID, true))
					return true;

				if (CheckToggleBuff(m_iGroupMitigationBuffAbilityID, m_bBuffPhysicalMitigation))
					return true;

				if (CheckToggleBuff(m_iGroupNoxiousBuffAbilityID, m_bBuffNoxiousResistance))
					return true;

				if (CheckToggleBuff(m_iGroupSTRSTABuffAbilityID, m_bBuffSTRSTA))
					return true;

				if (CheckSingleTargetBuffs(m_iSingleHealthPoolBuffAbilityID, m_astrHealthPoolTargets, true, false))
					return true;

				if (CheckToggleBuff(m_iUrsineAbilityID, true))
					return true;

				if (CheckGroupWaterBreathingBuff())
					return true;

				if (CheckSingleTargetBuffs(m_iSingleStatBuffAbilityID, m_strAvatarTarget, true, false))
					return true;

				if (CheckSingleTargetBuffs(m_iSingleProcBuffAbilityID, m_strAncestryTarget, true, false))
					return true;

				if (CheckRacialBuffs())
					return true;

				if (CheckSpiritOfTheWolf())
					return true;

				if (MeActor.IsIdle && (!Me.IsHated || m_bSummonPetDuringCombat) && CheckToggleBuff(m_iSpiritCompanionAbilityID, m_bUsePet))
					return true;

				StopCheckingBuffs();
			}

			bool bOffensiveTargetEngaged = EngagePrimaryEnemy();

			if (MeActor.IsIdle)
			{
				if (bOffensiveTargetEngaged)
				{
					/// If Illusionist epic regen is up, do our fastest nuke to try and reap the benefit.
					/// Ideally it would be a lowest-tier spell because we know this nuke doesn't do shit for dps considering the power it uses,
					/// but we're not set up for that.
					if ((fMyPowerRatio < 0.10) && IsIllusionistSoothingMindActive() && CastAbility(m_iSingleFastShadowBaneNukeAbilityID))
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
						if (CastAbility(m_iSingleWardedCombatRezAbilityID, strNearestDeadName, false) ||
							CastAbility(m_iSingleNormalCombatRezAbilityID, strNearestDeadName, false) ||
							(!Me.IsHated && CastAbility(m_iGeneralNonCombatRezAbilityID, strNearestDeadName, false)))
						{
							SpamSafeGroupSay(m_strSingleRezCallout, strNearestDeadName);
							SpamSafeRaidSay(m_strSingleRezCallout, strNearestDeadName);
							return true;
						}
					}
				}

				/// If vitals look acceptable for now, then we try debuffs and/or damage.
				/// Do debuffs only if the vital situation isn't grim.
				if (bOffensiveTargetEngaged && (fLowestHealthRatio > 0.90f))
				{
					if (CastAbility(m_iLoreAndLegendAbilityID))
						return true;

					if (!IsAbilityMaintained(m_iGreenResistDebuffAbilityID) && CastAbility(m_iGreenResistDebuffAbilityID))
						return true;

					if (!IsAbilityMaintained(m_iGreenHasteDebuffAbilityID) && CastAbility(m_iGreenHasteDebuffAbilityID))
						return true;

					if (!IsAbilityMaintained(m_iSingleHasteDebuffAbilityID) && CastAbility(m_iSingleHasteDebuffAbilityID))
						return true;

					if (!IsAbilityMaintained(m_iGreenDPSDebuffAbilityID) && CastAbility(m_iGreenDPSDebuffAbilityID))
						return true;

					if (!IsAbilityMaintained(m_iSingleDPSDebuffAbilityID) && CastAbility(m_iSingleDPSDebuffAbilityID))
						return true;

					if (!IsAbilityMaintained(m_iSingleSTRSTADebuffAbilityID) && CastAbility(m_iSingleSTRSTADebuffAbilityID))
						return true;

					bool bTempBuffsAdvised = AreTempOffensiveBuffsAdvised();

					if (bTempBuffsAdvised)
					{
						/// Ritual would be a total waste if DR were on the group.
						/// Right now we use it at any time during combat, but we may refine this later.
						if (!IsClericDivineRecoveryActive() && CastAbility(m_iRitualOfAlacrityAbilityID, m_strRitualOfAlacrityTarget, true))
							return true;

						if (CastAbility(m_iDumbfireWardPetAbilityID, Me.Name, true))
							return true;
					}
				}

				/// General dps requires 95% or higher. Sorry!
				if (m_OffensiveTargetActor != null && (fLowestHealthRatio > 0.95f))
				{
					if (CastAbility(m_iSingleColdSnareAbilityID))
						return true;
				}

				if (iTotalDeficientMembers > 1 && (fNetHealthGap > 40.0f) && CastAbility(m_iGroupHealingAbilityID, Me.Name, true))
					return true;

				if (!string.IsNullOrEmpty(strLowestHealthName))
				{
					if (CastAbility(m_iSingleWardAbilityID, strLowestHealthName, true))
						return true;

					if (CastAbility(m_iBiggerHealingAbilityID, strLowestHealthName, true))
						return true;

					if (CastAbility(m_iHealingAbilityID, strLowestHealthName, true))
						return true;
				}

				/// Keep the group ward up.
				if ((Me.IsHated || MeActor.InCombatMode) && !IsAbilityMaintained(m_iGroupWardAbilityID) && CastAbility(m_iGroupWardAbilityID, Me.Name, true))
					return true;

				if (iTotalDeficientMembers > 1 && (fNetHealthGap > 20.0f) && CastAbility(m_iGroupHealingAbilityID, Me.Name, true))
					return true;

				if ((Me.IsHated || MeActor.InCombatMode) && CastAbility(m_iDumbfireHealPetAbilityID, Me.Name, true))
					return true;

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
