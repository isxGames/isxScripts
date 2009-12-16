using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2SuiteLib;

namespace EQ2GlassCannon
{
	public class IllusionistController : EnchanterController
	{
		#region INI settings
		protected List<string> m_astrHasteTargets = new List<string>();
		protected List<string> m_astrDynamismTargets = new List<string>();
		protected List<string> m_astrPrismaticTargets = new List<string>();
		protected List<string> m_astrTimeCompressionTargets = new List<string>();
		protected List<string> m_astrIllusoryArmTargets = new List<string>();
		protected List<string> m_astrSpellshieldTargets = new List<string>();
		protected bool m_bBuffINTWIS = false;
		protected string m_strDestructiveRampageCallout = "Destructive Rampage INC (20 sec, 10% base damage boost to spells and CA's)";
		protected string m_strIlluminateCallout = "Illuminate INC (20 sec, 50% less resistability to all spells)";
		protected string m_strCastingSkillBoostCallout = "Flash INC (+int and +all casting skills)";
		protected string m_strSavanteCallout = "Savante INC (reduced power consumption)";
		#endregion

		#region Ability ID's
		protected uint m_uiINTWISBuffAbilityID = 0;
		protected uint m_uiHasteBuffAbilityID = 0;
		protected uint m_uiDynamismAbilityID = 0;
		protected uint m_uiTimeCompressionAbilityID = 0;
		protected uint m_uiIllusoryArmAbilityID = 0;

		protected uint m_uiSpellshieldAbilityID = 0;
		protected uint m_uiPersonaePetAbilityID = 0;
		protected uint m_uiDestructiveRampageAbilityID = 0;
		protected uint m_uiIlluminateAbilityID = 0;
		protected uint m_uiSavanteAbilityID = 0;
		protected uint m_uiCastingSkillBoostAbilityID = 0;
		protected uint m_uiConstructAbilityID = 0;
		protected uint m_uiBeamAbilityID = 0;
		protected uint m_uiPrismaticAbilityID = 0;
		protected uint m_uiDazeNukeAbilityID = 0;
		protected uint m_uiStifleNukeAbilityID = 0;
		protected uint m_uiStunNukeAbilityID = 0;
		protected uint m_uiArcaneDebuffNukeAbilityID = 0;
		protected uint m_uiUnresistableNukeAbilityID = 0;
		protected uint m_uiMeleeDebuffAbilityID = 0;
		protected uint m_uiGreenShowerAbilityID = 0;
		protected uint m_uiStormAbilityID = 0;
		protected uint m_uiGreenStunAbilityID = 0;

		protected uint m_uiSingleNormalMezAbilityID = 0;
		protected uint m_uiSingleFastMezAbilityID = 0;
		protected uint m_uiGreenMezAbilityID = 0;
		#endregion

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferStringList("Illusionist.HasteTargets", m_astrHasteTargets);
			ThisFile.TransferStringList("Illusionist.DynamismTargets", m_astrDynamismTargets);
			ThisFile.TransferStringList("Illusionist.PrismaticTargets", m_astrPrismaticTargets);
			ThisFile.TransferStringList("Illusionist.TimeCompressionTargets", m_astrTimeCompressionTargets);
			ThisFile.TransferStringList("Illusionist.IllusoryArmTargets", m_astrIllusoryArmTargets);
			ThisFile.TransferStringList("Illusionist.SpellshieldTargets", m_astrSpellshieldTargets);
			ThisFile.TransferBool("Illusionist.BuffIntWis", ref m_bBuffINTWIS);
			ThisFile.TransferString("Illusionist.DestructiveRampageCallout", ref m_strDestructiveRampageCallout);
			ThisFile.TransferString("Illusionist.IlluminateCallout", ref m_strIlluminateCallout);
			ThisFile.TransferString("Illusionist.CastingSkillBoostCallout", ref m_strCastingSkillBoostCallout);
			ThisFile.TransferString("Illusionist.SavanteCallout", ref m_strSavanteCallout);
			return;
		}

		/************************************************************************************/
		protected override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_uiINTWISBuffAbilityID = SelectHighestTieredAbilityID("Rune of Thought");
			m_uiArcaneBuffAbilityID = SelectHighestTieredAbilityID("Aspect of Genius");
			m_uiMainRegenBuffAbilityID = SelectHighestTieredAbilityID("Epiphany");
			m_uiHasteBuffAbilityID = SelectHighestTieredAbilityID("Rapidity");
			m_uiDynamismAbilityID = SelectHighestTieredAbilityID("Synergism");
			m_uiTimeCompressionAbilityID = SelectHighestAbilityID("Time Compression");
			m_uiIllusoryArmAbilityID = SelectHighestAbilityID("Illusory Arm");
			m_uiSpellshieldAbilityID = SelectHighestAbilityID("Spellshield");
			m_uiPersonaePetAbilityID = SelectHighestTieredAbilityID("Personae Reflection");
			m_uiDestructiveRampageAbilityID = SelectHighestAbilityID("Destructive Rampage");
			m_uiIlluminateAbilityID = SelectHighestAbilityID("Illuminate");
			m_uiSavanteAbilityID = SelectHighestAbilityID("Savante");
			m_uiCastingSkillBoostAbilityID = SelectHighestTieredAbilityID("Flash of Brilliance");
			m_uiConstructAbilityID = SelectHighestTieredAbilityID("Construct of Order");
			m_uiBeamAbilityID = SelectHighestTieredAbilityID("Ultraviolet Beam");
			m_uiPrismaticAbilityID = SelectHighestTieredAbilityID("Prismatic Chaos");
			m_uiDazeNukeAbilityID = SelectHighestTieredAbilityID("Aneurysm");
			m_uiStifleNukeAbilityID = SelectHighestTieredAbilityID("Speechless");
			m_uiStunNukeAbilityID = SelectHighestTieredAbilityID("Paranoia");
			m_uiArcaneDebuffNukeAbilityID = SelectHighestTieredAbilityID("Nightmare");
			m_uiUnresistableNukeAbilityID = SelectHighestTieredAbilityID("Brainburst");
			m_uiMeleeDebuffAbilityID = SelectHighestTieredAbilityID("Dismay");
			m_uiGreenShowerAbilityID = SelectHighestTieredAbilityID("Chromatic Shower");
			m_uiStormAbilityID = SelectHighestTieredAbilityID("Chromatic Storm");
			m_uiGreenStunAbilityID = SelectHighestTieredAbilityID("Bewilderment");
			m_uiSingleNormalMezAbilityID = SelectHighestTieredAbilityID("Entrance");
			m_uiSingleFastMezAbilityID = SelectHighestTieredAbilityID("Regalia");
			m_uiGreenMezAbilityID = SelectHighestTieredAbilityID("Phantasmal Awe");
			return;
		}

		/************************************************************************************/
		protected override bool DoNextAction()
		{
			if (base.DoNextAction() || MeActor.IsDead)
				return true;

			if (IsCasting)
				return true;

			GetOffensiveTargetActor();

			/// Red illusionist mezzes can be cast while in motion.
			if (m_bUseGreenAEs && IsIdle) /// Should also have encounter size check (2 or greater) but that'll have to wait for now (based on mez range).
			{
				if (CastNextMez(m_uiGreenMezAbilityID, m_uiSingleFastMezAbilityID, m_uiSingleNormalMezAbilityID))
					return true;
			}
			else
			{
				if (CastNextMez(m_uiSingleFastMezAbilityID, m_uiSingleNormalMezAbilityID))
					return true;
			}

			if (AttemptCureArcane())
				return true;
			if (UseRegenItem())
				return true;

			if (m_bCheckBuffsNow)
			{
				if (IsIdle && (!Me.IsHated || m_bSummonPetDuringCombat) && CheckToggleBuff(m_uiPersonaePetAbilityID, m_bUsePet))
					return true;
				if (CheckToggleBuff(m_uiINTWISBuffAbilityID, m_bBuffINTWIS))
					return true;
				if (CheckToggleBuff(m_uiArcaneBuffAbilityID, m_bBuffArcaneResistance))
					return true;
				if (CheckToggleBuff(m_uiMainRegenBuffAbilityID, m_bBuffRegen))
					return true;
				if (CheckToggleBuff(m_uiMagisShieldingAbilityID, true))
					return true;
				if (CheckSingleTargetBuffs(m_uiDynamismAbilityID, m_astrDynamismTargets))
					return true;
				if (CheckSingleTargetBuffs(m_uiHasteBuffAbilityID, m_astrHasteTargets))
					return true;
				if (CheckSingleTargetBuff(m_uiTimeCompressionAbilityID, m_astrTimeCompressionTargets))
					return true;
				if (CheckSingleTargetBuff(m_uiIllusoryArmAbilityID, m_astrIllusoryArmTargets))
					return true;
				if (MeActor.InCombatMode && CheckSingleTargetBuff(m_uiSpellshieldAbilityID, m_astrSpellshieldTargets))
					return true;
				if (CheckRacialBuffs())
					return true;
				StopCheckingBuffs();
			}

			if (CheckManaFlow())
				return true;

			if (!EngageOffensiveTarget())
				return false;

			/// Decide if the offensive target is still legitimate. If so, attempt to target it.
			if (m_OffensiveTargetActor != null && IsIdle)
			{
				bool bDumbfiresAdvised = AreDumbfiresAdvised();
				bool bTempBuffsAdvised = AreTempOffensiveBuffsAdvised();

				if (CastHOStarter())
					return true;

				if (IsIdle)
				{
					/// This buffs PC cast speed and debuffs NPC cast speed. So it gets unique priority.
					if (CastAbility(m_uiChronosiphoningAbilityID))
						return true;

					if (bTempBuffsAdvised)
					{
						if (!IsBeneficialEffectPresent(m_uiPeaceOfMindAbilityID) && CastAbilityOnSelf(m_uiPeaceOfMindAbilityID))
						{
							SpamSafeGroupSay(m_strPeaceOfMindCallout);
							return true;
						}

						if (!IsBeneficialEffectPresent(m_uiDestructiveRampageAbilityID) && CastAbilityOnSelf(m_uiDestructiveRampageAbilityID))
						{
							SpamSafeGroupSay(m_strDestructiveRampageCallout);
							return true;
						}

						/// Illuminate and Flash of Brilliance are used by this bot to lower spell resist rates;
						/// it's counterproductive almost all of the time to have them both up at once.
						if (!IsBeneficialEffectPresent(m_uiCastingSkillBoostAbilityID) && !IsBeneficialEffectPresent(m_uiIlluminateAbilityID) && CastAbilityOnSelf(m_uiIlluminateAbilityID))
						{
							SpamSafeGroupSay(m_strIlluminateCallout);
							return true;
						}
						if (!IsBeneficialEffectPresent(m_uiCastingSkillBoostAbilityID) && !IsBeneficialEffectPresent(m_uiIlluminateAbilityID) && CastAbilityOnSelf(m_uiCastingSkillBoostAbilityID))
						{
							SpamSafeGroupSay(m_strCastingSkillBoostCallout);
							return true;
						}

						if (!IsBeneficialEffectPresent(m_uiSavanteAbilityID) && CastAbilityOnSelf(m_uiSavanteAbilityID))
						{
							SpamSafeGroupSay(m_strSavanteCallout);
							return true;
						}
					}

					if (m_bIHaveAggro)
					{
						if (UseDeaggroItems())
							return true;
					}

					if (CastGreenOffensiveAbility(m_uiGreenShowerAbilityID, 2))
						return true;

					/// Extreme AE opportunities should receive top priority, and never subordinate to boilerplate cast orders.
					if (CastGreenOffensiveAbility(m_uiStormAbilityID, 4))
						return true;

					/// We attempt this in two places:
					/// - Here at the beginning for the debuff, and
					/// - Down the list for the proc DPS.
					if (!IsAbilityMaintained(m_uiArcaneDebuffNukeAbilityID, m_iOffensiveTargetID) && CastAbility(m_uiArcaneDebuffNukeAbilityID))
						return true;
					if (!IsAbilityMaintained(m_uiMeleeDebuffAbilityID, m_iOffensiveTargetID) && CastAbility(m_uiMeleeDebuffAbilityID))
						return true;
					if (!IsAbilityMaintained(m_uiNullifyingStaffAbilityID, m_iOffensiveTargetID) && CastAbility(m_uiNullifyingStaffAbilityID))
						return true;

					if (CastGreenOffensiveAbility(m_uiGreenShowerAbilityID, 1))
						return true;

					if (bDumbfiresAdvised && !IsAbilityMaintained(m_uiConstructAbilityID) && CastAbility(m_uiConstructAbilityID))
						return true;

					/// TODO: This should be changed to behave more like a buff, to allow multiple recipients.
					if (!IsAbilityMaintained(m_uiPrismaticAbilityID) && CastAbility(m_uiPrismaticAbilityID, m_astrPrismaticTargets, true))
					//if (!CheckSingleTargetBuffs(m_uiPrismaticAbilityID, m_astrPrismaticTargets))
						return true;

					if (CastAbility(m_uiBewildermentAbilityID))
						return true;

					if (CastAbility(m_uiBeamAbilityID))
						return true;

					if (CastAbility(m_uiLoreAndLegendAbilityID))
						return true;

					/// We let this expire for the termination nuke, Pinski supposedly thinks it does more dps that way. :/
					if (!IsAbilityMaintained(m_uiUnresistableNukeAbilityID, m_iOffensiveTargetID) && CastAbility(m_uiUnresistableNukeAbilityID))
						return true;

					if (CastAbility(m_uiDazeNukeAbilityID))
						return true;

					if (CastAbility(m_uiStifleNukeAbilityID))
						return true;

					if (CastAbility(m_uiArcaneDebuffNukeAbilityID))
						return true;

					if (CastAbility(m_uiStunNukeAbilityID))
						return true;

					if (CastAbility(m_uiMeleeDebuffAbilityID))
						return true;

					if (UseOffensiveItems())
						return true;

					if (CastGreenOffensiveAbility(m_uiStormAbilityID, 1))
						return true;
				}
			}

			return false;
		}
	}
}
