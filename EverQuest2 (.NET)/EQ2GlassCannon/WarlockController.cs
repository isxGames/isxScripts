using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2GlassCannon
{
	public class WarlockController : SorcererController
	{
		public int m_iNoxiousBuffAbilityID = -1;

		public int m_iSingleBasicNukeAbilityID = -1;
		public int m_iSingleUnresistableDOTAbilityID = -1;
		public int m_iSingleMediumNukeDOTAbilityID = -1;
		public int m_iSingleColdStunNukeAbilityID = -1;
		public int m_iGreenNoxiousDebuffAbilityID = -1;
		public int m_iGreenPoisonStunNukeAbilityID = -1;
		public int m_iGreenDiseaseNukeAbilityID = -1;
		public int m_iBluePoisonAEAbilityID = -1;

		public override void TransferINISettings(PlayerController.TransferType eTransferType)
		{
			base.TransferINISettings(eTransferType);
			return;
		}

		public override void InitializeKnowledgeBook()
		{
			base.InitializeKnowledgeBook();

			m_iNoxiousBuffAbilityID = SelectHighestAbilityID(
				"Boon of the Shadows",
				"Boon of the Void");

			m_iSingleBasicNukeAbilityID = SelectHighestAbilityID(
				"Corrosive Strike",
				"Corrosive Blast",
				"Corrosive Bolt",
				"Noxious Blast");

			m_iSingleUnresistableDOTAbilityID = SelectHighestAbilityID(
				"Erupt",
				"Emanate",
				"Shadowy Emanations");

			m_iSingleMediumNukeDOTAbilityID = SelectHighestAbilityID(
				"Suffocation");

			m_iSingleColdStunNukeAbilityID = SelectHighestAbilityID(
				"Freeze");

			m_iGreenNoxiousDebuffAbilityID = SelectHighestAbilityID(
				"Stop Breath",
				"Shorten Breath");

			m_iGreenPoisonStunNukeAbilityID = SelectHighestAbilityID(
				"Glass Cloud");

			m_iGreenDiseaseNukeAbilityID = SelectHighestAbilityID(
				"Negative Absolution");

			m_iBluePoisonAEAbilityID = SelectHighestAbilityID(
				"Poison Cloud",
				"Suffocate");

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

				if (CheckToggleBuff(m_iNoxiousBuffAbilityID, true))
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
				if (CastAbility(m_iSingleBasicNukeAbilityID))
					return true;

				if (CastAbility(m_iSingleUnresistableDOTAbilityID))
					return true;

				if (CastAbility(m_iSingleMediumNukeDOTAbilityID))
					return true;

				if (CastAbility(m_iSingleColdStunNukeAbilityID))
					return true;

				if (m_bUseGreenAEs && CastAbility(m_iGreenNoxiousDebuffAbilityID))
					return true;

				if (m_bUseGreenAEs && CastAbility(m_iGreenPoisonStunNukeAbilityID))
					return true;

				if (m_bUseGreenAEs && CastAbility(m_iGreenDiseaseNukeAbilityID))
					return true;

				if (m_bUseBlueAEs && CastAbility(m_iBluePoisonAEAbilityID))
					return true;
			}

			return false;
		}
	}
}
