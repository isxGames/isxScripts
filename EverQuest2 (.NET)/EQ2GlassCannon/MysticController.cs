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
		public int m_iAvatarAbilityID = -1;
		public int m_iAncestryAbilityID = -1;

		public int m_iSingleWardAbilityID = -1;
		public int m_iHealingAbilityID = -1;
		public int m_iEnlightenedHealingAbilityID = -1;
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
		public override void TransferINISettings(TransferType eTransferType)
		{
			base.TransferINISettings(eTransferType);

			TransferINIBool(eTransferType, "Mystic.BuffPhysicalMitigation", ref m_bBuffPhysicalMitigation);
			TransferINIBool(eTransferType, "Mystic.BuffNoxiousResistance", ref m_bBuffNoxiousResistance);
			TransferINIBool(eTransferType, "Mystic.BuffSTRSTA", ref m_bBuffSTRSTA);
			TransferINIStringList(eTransferType, "Mystic.HealthPoolTargets", m_astrHealthPoolTargets);
			TransferINIString(eTransferType, "Mystic.AvatarTarget", ref m_strAvatarTarget);
			TransferINIString(eTransferType, "Mystic.AncestryTarget", ref m_strAncestryTarget);
			TransferINIString(eTransferType, "Mystic.RitualOfAlacrityTarget", ref m_strRitualOfAlacrityTarget);
			return;
		}

		/************************************************************************************/
		public override void InitializeKnowledgeBook()
		{
			base.InitializeKnowledgeBook();

			m_iGeneralGroupCureAbilityID = SelectHighestAbilityID(
				"Cure: Fading Spirit",
				"Cure: Gasping Spirit",
				"Ebbing Spirit");

			m_iGeneralSingleDeathSaveAbilityID = SelectHighestAbilityID(
				"Eidolic Savior",
				"Umbral Savior",
				"Ghastly Savior",
				"Ancestral Savior");

			m_iGroupMitigationBuffAbilityID = SelectHighestAbilityID(
				"Runic Mark",
				"Runic Symbol",
				"Runic Shield",
				"Runic Talisman",
				"Runic Aegis",
				"Runic Armor");

			m_iGroupNoxiousBuffAbilityID = SelectHighestAbilityID(
				"Spiritual Seal",
				"Umbral Fortitude",
				"Eidolic Mettle",
				"Umbral Mettle",
				"Ancestral Mettle");

			m_iGroupSTRSTABuffAbilityID = SelectHighestAbilityID(
				"Spirit of the Bull",
				"Spirit of the Rhino",
				"Spirit of the Elephant",
				"Spirit of the Mammoth",
				"Spirit of the Mastodon");

			m_iGroupWaterBreathingAbilityID = SelectHighestAbilityID("Water Spirit");

			m_iSingleHealthPoolBuffAbilityID = SelectHighestAbilityID(
				"Minor Auspice",
				"Auspice",
				"Omen",
				"Prophecy",
				"Foretelling",
				"Premonition");

			m_iSpiritCompanionAbilityID = SelectHighestAbilityID("Summon Spirit Companion");

			m_iUrsineAbilityID = SelectHighestAbilityID(
				"Ursine Elder",
				"Ursine Oracle",
				"Ursine Prophet",
				"Ursine Augur",
				"Ursine Avatar");

			m_iAvatarAbilityID = SelectHighestAbilityID(
				"Avatar",
				"Ancient Avatar",
				"Ancestral Avatar");

			m_iAncestryAbilityID = SelectHighestAbilityID("Ancestry");

			m_iSingleWardAbilityID = SelectHighestAbilityID(
				"Spectral Ward",
				"Ghostly Ward",
				"Ancestral Ward",
				"Ancestral Aegis",
				"Sacred Aegis",
				"Ethereal Aegis",
				"Ancient Aegis");

			m_iHealingAbilityID = SelectHighestAbilityID(
				"Minor Aid",
				"Aid",
				"Totemic Aid",
				"Replenishment",
				"Spiritual Replenishment",
				"Rejuvenating Chant",
				"Rejuvenating Rite",
				"Rejuvenation");

			m_iEnlightenedHealingAbilityID = SelectHighestAbilityID(
				"Minor Ritual",
				"Ritual",
				"Healing Ritual",
				"Spiritual Healing",
				"Enlightened Healing",
				"Learned Healing",
				"Ritual Healing");

			m_iGroupWardAbilityID = SelectHighestAbilityID(
				"Wards of Spirit",
				"Wards of Shadow",
				"Umbral Ritual",
				"Umbral Sacrament",
				"Umbral Liturgy",
				"Umbral Warding");

			m_iGroupHealingAbilityID = SelectHighestAbilityID(
				"Breath of Spirits",
				"Spiritist's Salve",
				"Transcendent Blessing",
				"Transcendent Grace",
				"Transcendence",
				"Transcendant Aid");

			m_iGroupCombatRezAbilityID = SelectHighestAbilityID("Fields of the Grey");
			m_iSingleWardedCombatRezAbilityID = SelectHighestAbilityID("Recall of the Grey");
			m_iSingleNormalCombatRezAbilityID = SelectHighestAbilityID("Path of the Grey");

			m_iDumbfireHealPetAbilityID = SelectHighestAbilityID(
				"Shadowy Attendant",
				"Umbral Attendant",
				"Lunar Attendant");

			m_iDumbfireWardPetAbilityID = SelectHighestAbilityID("Ancestral Sentry");

			m_iGreenResistDebuffAbilityID = SelectHighestAbilityID(
				"Anger of the Ancients",
				"Fury of the Ancients",
				"Wrath of the Ancients",
				"Wail of the Ancients",
				"Echoes of the Ancients");

			m_iGreenHasteDebuffAbilityID = SelectHighestAbilityID(
				"Grim Lethargy",
				"Dreadful Lethargy",
				"Lethargy");

			m_iGreenDPSDebuffAbilityID = SelectHighestAbilityID(
				"Umbral Trap");

			m_iSingleHasteDebuffAbilityID = SelectHighestAbilityID(
				"Haze",
				"Wailing Haze",
				"Keening Haze",
				"Howling Haze",
				"Weeping Haze",
				"Shrieking Haze");

			m_iSingleDPSDebuffAbilityID = SelectHighestAbilityID(
				"Mourning Soul",
				"Grieving Soul",
				"Lamenting Soul");

			m_iSingleSTRSTADebuffAbilityID = SelectHighestAbilityID(
				"Enfeeble",
				"Delusion",
				"Fallacy",
				"Chimerik",
				"Eidolon",
				"Deteriorate");

			m_iSingleFastShadowBaneNukeAbilityID = SelectHighestAbilityID(
				"Fever",
				"Sickness",
				"Miasma",
				"Pox",
				"Fevered Pox",
				"Plague",
				"Epidemic");

			m_iSingleColdSnareAbilityID = SelectHighestAbilityID(
				"Chilling Winds",
				"Cold Wind",
				"Grey Wind",
				"Touch of the Grey",
				"Ire of the Grey",
				"Wrath of the Grey",
				"Velium Winds");

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

				if (CheckSingleTargetBuffs(m_iAvatarAbilityID, m_strAvatarTarget, true, false))
					return true;

				if (CheckSingleTargetBuffs(m_iAncestryAbilityID, m_strAncestryTarget, true, false))
					return true;

				if (CheckRacialBuffs())
					return true;

				if (CheckSpiritOfTheWolf())
					return true;

				if (MeActor.IsIdle && (!Me.IsHated || m_bSummonPetDuringCombat) && CheckToggleBuff(m_iSpiritCompanionAbilityID, m_bUsePet))
					return true;

				StopCheckingBuffs();
			}

			bool bOffensiveTargetEngaged = EngageOffensiveTargetActor();

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

					if (CastAbility(m_iEnlightenedHealingAbilityID, strLowestHealthName, true))
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
