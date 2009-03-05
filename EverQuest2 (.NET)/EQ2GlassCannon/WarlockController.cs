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

		public override void TransferINISettings(PlayerController.TransferType eTransferType)
		{
			base.TransferINISettings(eTransferType);
			return;
		}

		public override void InitializeKnowledgeBook()
		{
			base.InitializeKnowledgeBook();

			m_iGroupCastingSkillBuffAbilityID = SelectHighestAbilityID(
				"Spellbinding Pact",
				"Dark Pact",
				"Seal of Dark Rumination",
				"Seal of Ebon Thought");

			m_iGroupNoxiousBuffAbilityID = SelectHighestAbilityID(
				"Boon of the Shadows",
				"Boon of the Void",
				"Bolster Energy",
				"Aspect of Darkness");

			m_iSingleBasicNukeAbilityID = SelectHighestAbilityID(
				"Corrosive Strike",
				"Corrosive Blast",
				"Corrosive Bolt",
				"Noxious Blast",
				"Noxious Bolt",
				"Soul Flay");

			m_iSinglePrimaryPoisonNukeAbilityID = SelectHighestAbilityID(
				"Dark Distortion",
				"Nil Distortion",
				"Null Distortion");

			m_iSingleUnresistableDOTAbilityID = SelectHighestAbilityID(
				"Erupt",
				"Emanate",
				"Shadowy Emanations",
				"Dark Emanations",
				"Torment of Shadows");

			m_iSingleMediumNukeDOTAbilityID = SelectHighestAbilityID(
				"Suffocation",
				"Suffocating Breath",
				"Dark Pyre",
				"Shadowed Pyre");

			m_iSingleColdStunNukeAbilityID = SelectHighestAbilityID(
				"Freeze",
				"Flashfreeze",
				"Deter");

			m_iSingleSTRINTDebuffAbilityID = SelectHighestAbilityID(
				"Curse of Null",
				"Curse of Nil");

			m_iGreenNoxiousDebuffAbilityID = SelectHighestAbilityID(
				"Stop Breath",
				"Shorten Breath",
				"Steal Breath",
				"Chaotic Maelstrom");

			m_iGreenPoisonStunNukeAbilityID = SelectHighestAbilityID(
				"Glass Cloud",
				"Putrid Cloud",
				"Grievous Blast",
				"Dark Nebula");

			m_iGreenPoisonDOTAbilityID = SelectHighestAbilityID(
				"Devastation");

			m_iGreenDiseaseNukeAbilityID = SelectHighestAbilityID(
				"Negative Absolution",
				"Null Absolution",
				"Nil Absolution");

			m_iGreenDeaggroAbilityID = SelectHighestAbilityID(
				"Interference",
				"Nullification",
				"Vulian Interference",
				"Vulian Intrusion");

			m_iBluePoisonAEAbilityID = SelectHighestAbilityID(
				"Poison Cloud",
				"Suffocate",
				"Suffocating Cloud",
				"Abysmal Fury");

			return;
		}

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
			if (!EngageOffensiveTargetActor())
				return false;

			if (m_OffensiveTargetActor != null)
			{
				if (MeActor.IsIdle)
				{
					/// Deaggros.
					if (m_bSpamCrowdControl || m_bIHaveAggro)
					{
						if (CastAbility(m_iGreenDeaggroAbilityID))
							return true;

						if (CastAbility(m_iGeneralGreenDeaggroAbilityID))
							return true;
					}

					if (m_bUseGreenAEs && !IsAbilityMaintained(m_iGreenNoxiousDebuffAbilityID) && CastAbility(m_iGreenNoxiousDebuffAbilityID))
						return true;

					if (!IsAbilityMaintained(m_iSingleSTRINTDebuffAbilityID) && CastAbility(m_iSingleSTRINTDebuffAbilityID))
						return true;

					if (CastBlueOffensiveAbility(m_iBluePoisonAEAbilityID, 6))
						return true;

					if (CastGreenOffensiveAbility(m_iGreenPoisonDOTAbilityID, 2))
						return true;

					if (CastGreenOffensiveAbility(m_iGreenDiseaseNukeAbilityID, 3))
						return true;

					if (CastGreenOffensiveAbility(m_iGreenPoisonStunNukeAbilityID, 4))
						return true;

					if (CastAbility(m_iSingleBasicNukeAbilityID))
						return true;

					if (CastAbility(m_iSinglePrimaryPoisonNukeAbilityID))
						return true;

					if (CastAbility(m_iSingleUnresistableDOTAbilityID))
						return true;

					if (CastAbility(m_iSingleMediumNukeDOTAbilityID))
						return true;

					if (CastAbility(m_iSingleColdStunNukeAbilityID))
						return true;

					if (CastAbility(m_iIceFlameAbilityID))
						return true;

				}
			}

			return false;
		}
	}
}
