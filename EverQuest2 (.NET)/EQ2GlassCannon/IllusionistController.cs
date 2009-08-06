using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2.ISXEQ2;

namespace EQ2GlassCannon
{
	public class IllusionistController : EnchanterController
	{
		#region INI settings
		public List<string> m_astrHasteTargets = new List<string>();
		public List<string> m_astrDynamismTargets = new List<string>();
		public string m_strPrismaticTarget = string.Empty;
		public string m_strTimeCompressionTarget = string.Empty;
		public string m_strIllusoryArmTarget = string.Empty;
		public string m_strSpellshieldTarget = string.Empty;
		public bool m_bBuffArcaneResistance = false;
		public bool m_bBuffINTWIS = false;
		public string m_strPeaceOfMindCallout = "Peace of Mind INC (20 sec, damage proc on any offensive action)";
		public string m_strDestructiveRampageCallout = "Destructive Rampage INC (20 sec, 10% base damage boost to spells and CA's)";
		public string m_strIlluminateCallout = "Illuminate INC (20 sec, 50% less resistability to all spells)";
		public string m_strCastingSkillBoostCallout = "Flash INC (+int and +all casting skills)";
		public string m_strSavanteCallout = "Savante INC (reduced power consumption)";
		#endregion


		#region Ability ID's
		public int m_iINTWISBuffAbilityID = -1;
		public int m_iArcaneBuffAbilityID = -1;
		public int m_iHasteBuffAbilityID = -1;
		public int m_iDynamismAbilityID = -1;
		public int m_iTimeCompressionAbilityID = -1;
		public int m_iIllusoryArmAbilityID = -1;

		public int m_iSpellshieldAbilityID = -1;
		public int m_iPersonaePetAbilityID = -1;
		public int m_iDestructiveRampageAbilityID = -1;
		public int m_iIlluminateAbilityID = -1;
		public int m_iSavanteAbilityID = -1;
		public int m_iCastingSkillBoostAbilityID = -1;
		public int m_iConstructAbilityID = -1;
		public int m_iBeamAbilityID = -1;
		public int m_iPrismaticAbilityID = -1;
		public int m_iDazeNukeAbilityID = -1;
		public int m_iStifleNukeAbilityID = -1;
		public int m_iStunNukeAbilityID = -1;
		public int m_iArcaneDebuffNukeAbilityID = -1;
		public int m_iUnresistableNukeAbilityID = -1;
		public int m_iMeleeDebuffAbilityID = -1;
		public int m_iGreenShowerAbilityID = -1;
		public int m_iStormAbilityID = -1;
		public int m_iGreenStunAbilityID = -1;

		public int m_iSingleNormalMezAbilityID = -1;
		public int m_iSingleFastMezAbilityID = -1;
		public int m_iGreenMezAbilityID = -1;
		#endregion

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferStringList("Illusionist.HasteTargets", m_astrHasteTargets);
			ThisFile.TransferStringList("Illusionist.DynamismTargets", m_astrDynamismTargets);
			ThisFile.TransferString("Illusionist.PrismaticTarget", ref m_strPrismaticTarget);
			ThisFile.TransferString("Illusionist.TimeCompressionTarget", ref m_strTimeCompressionTarget);
			ThisFile.TransferString("Illusionist.IllusoryArmTarget", ref m_strIllusoryArmTarget);
			ThisFile.TransferString("Illusionist.SpellshieldTarget", ref m_strSpellshieldTarget);
			ThisFile.TransferBool("Illusionist.BuffArcaneResistance", ref m_bBuffArcaneResistance);
			ThisFile.TransferBool("Illusionist.BuffIntWis", ref m_bBuffINTWIS);
			ThisFile.TransferString("Illusionist.PeaceOfMindCallout", ref m_strPeaceOfMindCallout);
			ThisFile.TransferString("Illusionist.DestructiveRampageCallout", ref m_strDestructiveRampageCallout);
			ThisFile.TransferString("Illusionist.IlluminateCallout", ref m_strIlluminateCallout);
			ThisFile.TransferString("Illusionist.CastingSkillBoostCallout", ref m_strCastingSkillBoostCallout);
			ThisFile.TransferString("Illusionist.SavanteCallout", ref m_strSavanteCallout);
			return;
		}

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_iINTWISBuffAbilityID = SelectHighestTieredAbilityID("Rune of Thought");
			m_iArcaneBuffAbilityID = SelectHighestTieredAbilityID("Aspect of Genius");
			m_iMainRegenBuffAbilityID = SelectHighestTieredAbilityID("Epiphany");
			m_iHasteBuffAbilityID = SelectHighestTieredAbilityID("Rapidity");
			m_iDynamismAbilityID = SelectHighestTieredAbilityID("Synergism");
			m_iTimeCompressionAbilityID = SelectHighestAbilityID("Time Compression");
			m_iIllusoryArmAbilityID = SelectHighestAbilityID("Illusory Arm");
			m_iSpellshieldAbilityID = SelectHighestAbilityID("Spellshield");
			m_iPersonaePetAbilityID = SelectHighestTieredAbilityID("Personae Reflection");
			m_iDestructiveRampageAbilityID = SelectHighestAbilityID("Destructive Rampage");
			m_iIlluminateAbilityID = SelectHighestAbilityID("Illuminate");
			m_iSavanteAbilityID = SelectHighestAbilityID("Savante");
			m_iCastingSkillBoostAbilityID = SelectHighestTieredAbilityID("Flash of Brilliance");
			m_iConstructAbilityID = SelectHighestTieredAbilityID("Construct of Order");
			m_iBeamAbilityID = SelectHighestTieredAbilityID("Ultraviolet Beam");
			m_iPrismaticAbilityID = SelectHighestTieredAbilityID("Prismatic Chaos");
			m_iDazeNukeAbilityID = SelectHighestTieredAbilityID("Aneurysm");
			m_iStifleNukeAbilityID = SelectHighestTieredAbilityID("Speechless");
			m_iStunNukeAbilityID = SelectHighestTieredAbilityID("Paranoia");
			m_iArcaneDebuffNukeAbilityID = SelectHighestTieredAbilityID("Nightmare");
			m_iUnresistableNukeAbilityID = SelectHighestTieredAbilityID("Brainburst");
			m_iMeleeDebuffAbilityID = SelectHighestTieredAbilityID("Dismay");
			m_iGreenShowerAbilityID = SelectHighestTieredAbilityID("Chromatic Shower");
			m_iStormAbilityID = SelectHighestTieredAbilityID("Chromatic Storm");
			m_iGreenStunAbilityID = SelectHighestTieredAbilityID("Bewilderment");
			m_iSingleNormalMezAbilityID = SelectHighestTieredAbilityID("Entrance");
			m_iSingleFastMezAbilityID = SelectHighestTieredAbilityID("Regalia");
			m_iGreenMezAbilityID = SelectHighestTieredAbilityID("Phantasmal Awe");
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
				if (MeActor.IsIdle && (!Me.IsHated || m_bSummonPetDuringCombat) && CheckToggleBuff(m_iPersonaePetAbilityID, m_bUsePet))
					return true;

				if (CheckToggleBuff(m_iINTWISBuffAbilityID, m_bBuffINTWIS))
					return true;

				if (CheckToggleBuff(m_iArcaneBuffAbilityID, m_bBuffArcaneResistance))
					return true;

				if (CheckToggleBuff(m_iMainRegenBuffAbilityID, m_bBuffRegen))
					return true;

				if (CheckToggleBuff(m_iMagisShieldingAbilityID, true))
					return true;

				if (CheckSingleTargetBuffs(m_iDynamismAbilityID, m_astrDynamismTargets))
					return true;

				if (CheckSingleTargetBuffs(m_iHasteBuffAbilityID, m_astrHasteTargets))
					return true;

				if (CheckSingleTargetBuffs(m_iTimeCompressionAbilityID, m_strTimeCompressionTarget))
					return true;

				if (CheckSingleTargetBuffs(m_iIllusoryArmAbilityID, m_strIllusoryArmTarget))
					return true;

				if (MeActor.InCombatMode && CheckSingleTargetBuffs(m_iSpellshieldAbilityID, m_strSpellshieldTarget))
					return true;

				if (CheckRacialBuffs())
					return true;

				StopCheckingBuffs();
			}

			if (CheckManaFlow())
				return true;

			GetOffensiveTargetActor();

			/// Red illusionist mezzes can be cast while in motion.
			if (m_bUseGreenAEs && MeActor.IsIdle) /// Should also have encounter size check (2 or greater) but that'll have to wait for now (based on mez range).
			{
				if (CastNextMez(m_iGreenMezAbilityID, m_iSingleFastMezAbilityID, m_iSingleNormalMezAbilityID))
					return true;
			}
			else
			{
				if (CastNextMez(m_iSingleFastMezAbilityID, m_iSingleNormalMezAbilityID))
					return true;
			}

			if (!EngagePrimaryEnemy())
				return false;

			/// Decide if the offensive target is still legitimate. If so, attempt to target it.
			if (m_OffensiveTargetActor != null && MeActor.IsIdle)
			{
				double fDistance = GetActorDistance2D(MeActor, m_OffensiveTargetActor);
				bool bDumbfiresAdvised = (m_OffensiveTargetActor.IsEpic && m_OffensiveTargetActor.Health > 25) || (m_OffensiveTargetActor.IsHeroic && m_OffensiveTargetActor.Health > 90);
				bool bTempBuffsAdvised = AreTempOffensiveBuffsAdvised();
				int iEncounterSize = m_OffensiveTargetActor.EncounterSize;

				if (CastHOStarter())
					return true;

				if (MeActor.IsIdle)
				{
					/// This buffs PC cast speed and debuffs NPC cast speed. So it gets rare priority.
					if (CastAbility(m_iChronosiphoningAbilityID))
						return true;

					if (bTempBuffsAdvised)
					{
						if (!IsBeneficialEffectPresent(m_iPeaceOfMindAbilityID) && CastAbilityOnSelf(m_iPeaceOfMindAbilityID))
						{
							SpamSafeGroupSay(m_strPeaceOfMindCallout);
							return true;
						}

						if (!IsBeneficialEffectPresent(m_iDestructiveRampageAbilityID) && CastAbilityOnSelf(m_iDestructiveRampageAbilityID))
						{
							SpamSafeGroupSay(m_strDestructiveRampageCallout);
							return true;
						}

						/// Illuminate and Flash of Brilliance are used by this bot to lower spell resist rates;
						/// it's counterproductive almost all of the time to have them both up at once.
						if (!IsBeneficialEffectPresent(m_iCastingSkillBoostAbilityID) && !IsBeneficialEffectPresent(m_iIlluminateAbilityID) && CastAbilityOnSelf(m_iIlluminateAbilityID))
						{
							SpamSafeGroupSay(m_strIlluminateCallout);
							return true;
						}
						if (!IsBeneficialEffectPresent(m_iCastingSkillBoostAbilityID) && !IsBeneficialEffectPresent(m_iIlluminateAbilityID) && CastAbilityOnSelf(m_iCastingSkillBoostAbilityID))
						{
							SpamSafeGroupSay(m_strCastingSkillBoostCallout);
							return true;
						}

						if (!IsBeneficialEffectPresent(m_iSavanteAbilityID) && CastAbilityOnSelf(m_iSavanteAbilityID))
						{
							SpamSafeGroupSay(m_strSavanteCallout);
							return true;
						}
					}

					/// Extreme AE opportunities should receive top priority, and never subordinate to boilerplate cast orders.
					if (CastGreenOffensiveAbility(m_iGreenShowerAbilityID, 3))
						return true;
					if (CastGreenOffensiveAbility(m_iStormAbilityID, 4))
						return true;

					if (!IsAbilityMaintained(m_iPrismaticAbilityID) && CastAbility(m_iPrismaticAbilityID, m_strPrismaticTarget, true))
						return true;

					if (CastAbility(m_iBeamAbilityID))
						return true;

					if (CastAbility(m_iLoreAndLegendAbilityID))
						return true;

					/// We attempt this in two places:
					/// - Here at the beginning for the debuff, and
					/// - Down the list for the proc DPS.
					if (!IsAbilityMaintained(m_iArcaneDebuffNukeAbilityID) && CastAbility(m_iArcaneDebuffNukeAbilityID))
						return true;
					if (!IsAbilityMaintained(m_iMeleeDebuffAbilityID) && CastAbility(m_iMeleeDebuffAbilityID))
						return true;
					if (!IsAbilityMaintained(m_iNullifyingStaffAbilityID) && CastAbility(m_iNullifyingStaffAbilityID))
						return true;

					if (bDumbfiresAdvised && !IsAbilityMaintained(m_iConstructAbilityID) && CastAbility(m_iConstructAbilityID))
						return true;

					/// We let this expire for the termination nuke, Pinski supposedly thinks it does more dps that way. :/
					if (!IsAbilityMaintained(m_iUnresistableNukeAbilityID) && CastAbility(m_iUnresistableNukeAbilityID))
						return true;

					if (CastGreenOffensiveAbility(m_iGreenShowerAbilityID, 1))
						return true;

					if (CastAbility(m_iBewildermentAbilityID))
						return true;

					if (CastAbility(m_iDazeNukeAbilityID))
						return true;

					if (CastAbility(m_iStifleNukeAbilityID))
						return true;

					if (CastAbility(m_iArcaneDebuffNukeAbilityID))
						return true;

					if (CastAbility(m_iStunNukeAbilityID))
						return true;

					if (CastAbility(m_iMeleeDebuffAbilityID))
						return true;

					if (CastGreenOffensiveAbility(m_iStormAbilityID, 1))
						return true;
				}

			}

			Program.Log("Nothing left to cast!");
			return false;
		}
	}
}
