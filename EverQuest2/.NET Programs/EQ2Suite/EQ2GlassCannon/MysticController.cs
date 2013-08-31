using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2SuiteLib;

namespace EQ2GlassCannon
{
	public class MysticController : ShamanController
	{
		#region INI settings
		public bool m_bBuffNoxiousResistance = true;
		public bool m_bBuffSTRSTA = true;
		public List<string> m_astrHealthPoolTargets = new List<string>();
		public List<string> m_astrAvatarTargets = new List<string>();
		public List<string> m_astrAncestryTargets = new List<string>();
		public string m_strRitualOfAlacrityTarget = string.Empty;
		public string m_strSpiritDanceCallout = "CASTING SPIRIT DANCE ON << {0} >>";
		#endregion

		#region Ability ID's
		protected uint m_uiGroupNoxiousBuffAbilityID = 0;
		protected uint m_uiGroupSTRSTABuffAbilityID = 0;
		protected uint m_uiSingleHealthPoolBuffAbilityID = 0;
		protected uint m_uiSpiritCompanionAbilityID = 0;
		protected uint m_uiUrsineAbilityID = 0;
		protected uint m_uiSingleStatBuffAbilityID = 0;
		protected uint m_uiSingleProcBuffAbilityID = 0;

		protected uint m_uiSingleWardAbilityID = 0;
		protected uint m_uiSingleHealingAbilityID = 0;
		protected uint m_uiSingleBiggerHealingAbilityID = 0;
		protected uint m_uiSingleStunnedWardAbilityID = 0;
		protected uint m_uiGroupWardAbilityID = 0;
		protected uint m_uiGroupHealingAbilityID = 0;
		protected uint m_uiGroupCombatRezAbilityID = 0;
		protected uint m_uiSpiritDanceRezAbilityID = 0;
		protected uint m_uiSingleWardedCombatRezAbilityID = 0;
		protected uint m_uiSingleNormalCombatRezAbilityID = 0;
		protected uint m_uiDumbfireHealPetAbilityID = 0;
		protected uint m_uiDumbfireWardPetAbilityID = 0;

		protected uint m_uiGreenResistDebuffAbilityID = 0;
		protected uint m_uiGreenHasteDebuffAbilityID = 0;
		protected uint m_uiGreenDPSDebuffAbilityID = 0;
		protected uint m_uiSingleHasteDebuffAbilityID = 0;
		protected uint m_uiSingleDPSDebuffAbilityID = 0;
		protected uint m_uiSingleSTRSTADebuffAbilityID = 0;
		protected uint m_uiSingleFastShadowBaneNukeAbilityID = 0;
		protected uint m_uiSingleColdSnareAbilityID = 0;
		#endregion

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferBool("Mystic.BuffNoxiousResistance", ref m_bBuffNoxiousResistance);
			ThisFile.TransferBool("Mystic.BuffSTRSTA", ref m_bBuffSTRSTA);
			ThisFile.TransferStringList("Mystic.HealthPoolTargets", m_astrHealthPoolTargets);
			ThisFile.TransferStringList("Mystic.AvatarTargets", m_astrAvatarTargets);
			ThisFile.TransferStringList("Mystic.AncestryTargets", m_astrAncestryTargets);
			ThisFile.TransferString("Mystic.RitualOfAlacrityTarget", ref m_strRitualOfAlacrityTarget);
			ThisFile.TransferString("Mystic.SpiritDanceCallout", ref m_strSpiritDanceCallout);
			return;
		}

		/************************************************************************************/
		protected override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			/// PriestController abilities.
			m_uiShadowsDefensiveHealStance = SelectHighestAbilityID("Ritual of Protection");
			m_uiShadowsOffensiveHealStance = SelectHighestAbilityID("Ravenous Protector");
			m_uiGeneralGroupCureAbilityID = SelectHighestTieredAbilityID("Ebbing Spirit");
			m_uiGeneralSingleDeathSaveAbilityID = SelectHighestTieredAbilityID("Ancestral Savior");
			m_uiGroupWaterBreathingAbilityID = SelectHighestAbilityID("Water Spirit");
			m_uiGroupMitigationBuffAbilityID = SelectHighestTieredAbilityID("Runic Armor");

			m_uiGroupNoxiousBuffAbilityID = SelectHighestTieredAbilityID("Ancestral Mettle");
			m_uiGroupSTRSTABuffAbilityID = SelectHighestTieredAbilityID("Spirit of the Mammoth");
			m_uiSingleHealthPoolBuffAbilityID = SelectHighestTieredAbilityID("Premonition");
			m_uiSpiritCompanionAbilityID = SelectHighestAbilityID("Summon Spirit Companion");
			m_uiUrsineAbilityID = SelectHighestTieredAbilityID("Ursine Avatar");
			m_uiSingleStatBuffAbilityID = SelectHighestTieredAbilityID("Ancestral Avatar");
			m_uiSingleProcBuffAbilityID = SelectHighestAbilityID("Ancestry");
			
			m_uiSingleWardAbilityID = SelectHighestTieredAbilityID("Ancestral Ward");
			m_uiSingleHealingAbilityID = SelectHighestTieredAbilityID("Rejuvenation");
			m_uiSingleBiggerHealingAbilityID = SelectHighestTieredAbilityID("Ritual Healing");
			m_uiSingleStunnedWardAbilityID = SelectHighestTieredAbilityID("Oberon");
			m_uiGroupWardAbilityID = SelectHighestTieredAbilityID("Umbral Warding");
			m_uiGroupHealingAbilityID = SelectHighestTieredAbilityID("Transcendence");
			m_uiGroupCombatRezAbilityID = SelectHighestAbilityID("Fields of the Grey");
			m_uiSpiritDanceRezAbilityID = SelectHighestAbilityID("Spirit Dance");
			m_uiSingleWardedCombatRezAbilityID = SelectHighestAbilityID("Recall of the Grey");
			m_uiSingleNormalCombatRezAbilityID = SelectHighestAbilityID("Path of the Grey");
			m_uiDumbfireHealPetAbilityID = SelectHighestTieredAbilityID("Lunar Attendant");
			m_uiDumbfireWardPetAbilityID = SelectHighestAbilityID("Ancestral Sentry");

			m_uiGreenResistDebuffAbilityID = SelectHighestTieredAbilityID("Echoes of the Ancients");
			m_uiGreenHasteDebuffAbilityID = SelectHighestTieredAbilityID("Lethargy");
			m_uiGreenDPSDebuffAbilityID = SelectHighestTieredAbilityID("Umbral Trap");
			m_uiSingleHasteDebuffAbilityID = SelectHighestTieredAbilityID("Haze");
			m_uiSingleDPSDebuffAbilityID = SelectHighestTieredAbilityID("Lamenting Soul");
			m_uiSingleSTRSTADebuffAbilityID = SelectHighestTieredAbilityID("Deteriorate");
			m_uiSingleFastShadowBaneNukeAbilityID = SelectHighestTieredAbilityID("Plague");
			m_uiSingleColdSnareAbilityID = SelectHighestTieredAbilityID("Velium Winds");

			return;
		}

		/************************************************************************************/
		protected bool AttemptCures()
		{
			return AttemptCures(false, true, true, false);
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

			VitalStatus MyStatus = null;
			if (!GetVitalStatus(Name, ref MyStatus))
				return true;
			double fMyPowerRatio = MyStatus.PowerRatio;

			string strLowestHealthName = string.Empty;
			int iLowestHealthAmount = int.MaxValue;
			double fLowestHealthRatio = double.MaxValue;
			int iTotalDeficientMembers = 0;
			int iTotalDeficientMembersBelowGroupHealTolerance = 0;
			double fNetHealthGap = 0.0f; /// The sum of everyone's gap percentages.

			/// First things first, we evaluate the heal situation.
			foreach (VitalStatus ThisStatus in EnumVitalStatuses(m_bHealUngroupedMainTank))
			{
				double fHealthRatio = ThisStatus.HealthRatio;
				if (fHealthRatio < m_fHealThresholdRatio)
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

			if (DoArbitraryRez())
				return true;

			if (m_bCheckBuffsNow)
			{
				/// These buffs are critical.
				if (fLowestHealthRatio > 0.75)
				{
					if (CheckShadowsHealStanceBuffs())
						return true;
					if (CheckToggleBuff(m_uiCoagulateAbilityID, true))
						return true;
					if (CheckToggleBuff(m_uiGroupMitigationBuffAbilityID, m_bBuffPhysicalMitigation))
						return true;
				}

				/// Do buffs only if the vital situation isn't grim.
				if (fLowestHealthRatio > 0.90)
				{
					if (CheckWaterBreathingBuffs())
						return true;
					if (CheckToggleBuff(m_uiGroupNoxiousBuffAbilityID, m_bBuffNoxiousResistance))
						return true;
					if (CheckToggleBuff(m_uiGroupSTRSTABuffAbilityID, m_bBuffSTRSTA))
						return true;
					if (CheckSingleTargetBuffs(m_uiSingleHealthPoolBuffAbilityID, m_astrHealthPoolTargets))
						return true;
					if (CheckToggleBuff(m_uiUrsineAbilityID, true))
						return true;
					if (CheckSingleTargetBuff(m_uiSingleStatBuffAbilityID, m_astrAvatarTargets))
						return true;
					if (CheckSingleTargetBuff(m_uiSingleProcBuffAbilityID, m_astrAncestryTargets))
						return true;
					if (CheckRacialBuffs())
						return true;
					if (CheckSpiritOfTheWolf())
						return true;
					if (IsIdle && (!IsInCombat || m_bSummonPetDuringCombat) && CheckToggleBuff(m_uiSpiritCompanionAbilityID, m_bUsePet))
						return true;
				}

				StopCheckingBuffs();
			}

			bool bOffensiveTargetEngaged = EngageOffensiveTarget();

			if (IsIdle)
			{
				if (bOffensiveTargetEngaged)
				{
					/// If Illusionist epic regen is up, do our fastest nuke to try and reap the benefit.
					/// Ideally it would be a lowest-tier spell because we know this nuke doesn't do shit for dps considering the power it uses,
					/// but we're not set up for that.
					if ((fMyPowerRatio < 0.05) && IsIllusionistSoothingMindActive() && CastAbility(m_uiSingleFastShadowBaneNukeAbilityID))
						return true;

					/// Emergency spells on the Main Tank.
					VitalStatus MainTankVitalStatus = null;
					if (GetVitalStatus(m_strCurrentMainTank, ref MainTankVitalStatus))
					{
						/// Death save.
						if (MainTankVitalStatus.HealthRatio < 0.20)
						{
							if (CastAbility(m_uiGeneralSingleDeathSaveAbilityID, m_strCurrentMainTank, true))
								return true;
						}

						/// Stun ward.
						if (MainTankVitalStatus.HealthRatio < 0.05)
						{
							if (CastAbility(m_uiSingleStunnedWardAbilityID, m_strCurrentMainTank, true))
								return true;
						}

						/// Keep the single ward up.
						if (!IsAbilityMaintained(m_uiSingleWardAbilityID, MainTankVitalStatus.m_Actor.ID) && CastAbility(m_uiSingleWardAbilityID, m_strCurrentMainTank, true))
							return true;
					}
				}

				if (DoArbitraryRez())
					return true;

				/// If vitals look acceptable for now, then we try debuffs and/or damage.
				/// Do debuffs only if the vital situation isn't grim.
				if (bOffensiveTargetEngaged && (fLowestHealthRatio > 0.90f))
				{
					if (CastAbility(m_uiLoreAndLegendAbilityID))
						return true;

					if (!IsAbilityMaintained(m_uiGreenResistDebuffAbilityID) && CastAbility(m_uiGreenResistDebuffAbilityID))
						return true;

					if (!IsAbilityMaintained(m_uiGreenHasteDebuffAbilityID) && CastAbility(m_uiGreenHasteDebuffAbilityID))
						return true;

					if (!IsAbilityMaintained(m_uiSingleHasteDebuffAbilityID, m_iOffensiveTargetID) && CastAbility(m_uiSingleHasteDebuffAbilityID))
						return true;

					if (!IsAbilityMaintained(m_uiGreenDPSDebuffAbilityID) && CastAbility(m_uiGreenDPSDebuffAbilityID))
						return true;

					if (!IsAbilityMaintained(m_uiSingleDPSDebuffAbilityID, m_iOffensiveTargetID) && CastAbility(m_uiSingleDPSDebuffAbilityID))
						return true;

					if (!IsAbilityMaintained(m_uiSingleSTRSTADebuffAbilityID, m_iOffensiveTargetID) && CastAbility(m_uiSingleSTRSTADebuffAbilityID))
						return true;

					bool bTempBuffsAdvised = AreTempOffensiveBuffsAdvised();

					if (bTempBuffsAdvised)
					{
						/// Ritual would be a total waste if DR were on the group.
						/// Right now we use it at any time during combat, but we may refine this later.
						if (!IsClericDivineRecoveryActive() && CastAbility(m_uiRitualOfAlacrityAbilityID, m_strRitualOfAlacrityTarget, true))
							return true;

						if (CastAbilityOnSelf(m_uiDumbfireWardPetAbilityID))
							return true;
					}
				}

				/// General dps requires 95% or higher. Sorry!
				if (bOffensiveTargetEngaged && (fLowestHealthRatio > 0.95f))
				{
					if (CastAbility(m_uiSingleColdSnareAbilityID))
						return true;
				}

				if (iTotalDeficientMembers > 1 && (fNetHealthGap > 40.0f) && CastAbilityOnSelf(m_uiGroupHealingAbilityID))
					return true;

				/// Single heals and wards on the player hurting the most.
				if (!string.IsNullOrEmpty(strLowestHealthName))
				{
					if (CastAbility(m_uiSingleWardAbilityID, strLowestHealthName, true))
						return true;

					if (CastAbility(m_uiSingleBiggerHealingAbilityID, strLowestHealthName, true))
						return true;

					if (CastAbility(m_uiSingleHealingAbilityID, strLowestHealthName, true))
						return true;
				}

				if (iTotalDeficientMembers > 1 && (fNetHealthGap > 20.0f) && CastAbilityOnSelf(m_uiGroupHealingAbilityID))
					return true;

				/// Keep the group ward up.
				if ((bOffensiveTargetEngaged || IsInCombat) && !IsAbilityMaintained(m_uiGroupWardAbilityID) && CastAbilityOnSelf(m_uiGroupWardAbilityID))
					return true;

				if (IsInCombat && CastAbilityOnSelf(m_uiDumbfireHealPetAbilityID))
					return true;

				/// If anyone at all is missing health, do a group heal, because this is all that's left.
				if (!string.IsNullOrEmpty(strLowestHealthName))
				{
					if (CastAbilityOnSelf(m_uiGroupHealingAbilityID))
						return true;
				}

				if (!m_bPrioritizeCures && AttemptCures())
					return true;
			}

			return false;
		}

		/************************************************************************************/
		public bool DoArbitraryRez()
		{
			if (!IsIdle)
				return false;

			int iTotalDeadMembers = 0;
			string strNearestDeadName = string.Empty;
			double fNearestDeadDistance = double.MaxValue;

			foreach (VitalStatus ThisStatus in EnumVitalStatuses(m_bHealUngroupedMainTank))
			{
				if (ThisStatus.m_bIsDead)
				{
					iTotalDeadMembers++;

					/// Establish the nearest dead player.
					double fDistance = ThisStatus.m_Actor.Distance;
					if (fDistance < fNearestDeadDistance)
					{
						strNearestDeadName = ThisStatus.m_strName;
						fNearestDeadDistance = fDistance;
					}
				}
			}

			/// Attempt to rez.
			if (iTotalDeadMembers > 0)
			{
				if (CastNonCombatRaidRez(strNearestDeadName))
					return true;

				/// NOTE: Group rez risky if MT is getting rezzed and is outside of group.
				if (iTotalDeadMembers > 1)
				{
					/// I don't really have a good Spirit Dance algorithm but I do know it is way more efficient than standard group rez.
					if (CastAbility(m_uiSpiritDanceRezAbilityID, strNearestDeadName, false))
					{
						SpamSafeRaidSay(m_strSpiritDanceCallout, strNearestDeadName);
						return true;
					}
					if (CastAbility(m_uiGroupCombatRezAbilityID, strNearestDeadName, false))
					{
						SpamSafeRaidSay(m_strGroupRezCallout, strNearestDeadName);
						return true;
					}
				}
				else
				{
					/// Single rez. It's all we can do.
					if (CastAbility(m_uiSingleWardedCombatRezAbilityID, strNearestDeadName, false) ||
						CastAbility(m_uiSingleNormalCombatRezAbilityID, strNearestDeadName, false) ||
						(!IsInCombat && CastAbility(m_uiGeneralNonCombatRezAbilityID, strNearestDeadName, false)))
					{
						SpamSafeRaidSay(m_strSingleRezCallout, strNearestDeadName);
						return true;
					}
				}
			}

			return false;
		}
	}
}
