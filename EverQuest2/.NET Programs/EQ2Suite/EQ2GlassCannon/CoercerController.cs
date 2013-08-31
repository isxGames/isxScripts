using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2SuiteLib;

namespace EQ2GlassCannon
{
	/// <summary>
	/// This class is not finished yet.
	/// </summary>
	public class CoercerController : EnchanterController
	{
		#region INI settings
		protected List<string> m_astrDPSTargets = new List<string>();
		protected List<string> m_astrDeaggroTargets = new List<string>();
		protected List<string> m_astrHateTransferTargets = new List<string>();
		protected List<string> m_astrCoerciveHealingTargets = new List<string>();
		protected List<string> m_astrDestructiveMindTargets = new List<string>();
		protected bool m_bBuffINTAGI = false;
		protected string m_strIntellectualRemedyCallout = "Intellectual Remedy INC (20 sec, 15% base boost to wards and heals)";
		#endregion

		#region Ability ID's
		protected uint m_uiSingleDPSBuffAbilityID = 0;
		protected uint m_uiSingleDeaggroBuffAbilityID = 0;
		protected uint m_uiSingleHateTransferAbilityID = 0;
		protected uint m_uiCoerciveHealingAbilityID = 0;
		protected uint m_uiGroupINTAGIBuffAbilityID = 0;
		protected uint m_uiGroupSecondaryManaRegenBuffAbilityID = 0;
		protected uint m_uiIntellectualRemedyAbilityID = 0;

		protected uint m_uiTashianaAbilityID = 0;
		protected uint m_uiSingleMagicalDebuffAbilityID = 0;
		protected uint m_uiSingleArcaneDebuffAbilityID = 0;
		protected uint m_uiSingleINTDebuffAbilityID = 0;
		protected uint m_uiPossessEssenceAbilityID = 0;
		protected uint m_uiPuppetmasterAbilityID = 0;
		protected uint m_uiHemorrhageAbilityID = 0;
		protected uint m_uiBrainshockAbilityID = 0;
		protected uint m_uiHostageAbilityID = 0;
		protected uint m_uiDestructiveMindAbilityID = 0;
		protected uint m_uiSingleStifleNukeAbilityID = 0;
		protected uint m_uiSingleStunNukeAbilityID = 0;
		protected uint m_uiGreenDOTAbilityID = 0;
		protected uint m_uiGreenDazeNukeAbilityID = 0;
		protected uint m_uiGreenSpellReactiveAbilityID = 0;
		protected uint m_uiBlueStunNukeAbilityID = 0;

		protected uint m_uiSingleReactiveStunAbilityID = 0;
		protected uint m_uiSingleMezAbilityID = 0;
		protected uint m_uiGreenMezAbilityID = 0;
		protected uint m_uiGreenStunAbilityID = 0;
		#endregion

		/// <summary>
		/// As soon as we get text that says we can't possess it, we set this to false until a new target is selected.
		/// </summary>
		protected bool m_bCanPossessCurrentTarget = true;

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferStringList("Coercer.DPSTargets", m_astrDPSTargets);
			ThisFile.TransferStringList("Coercer.DeaggroTargets", m_astrDeaggroTargets);
			ThisFile.TransferStringList("Coercer.HateTransferTargets", m_astrHateTransferTargets);
			ThisFile.TransferStringList("Coercer.CoerciveHealingTargets", m_astrCoerciveHealingTargets);
			ThisFile.TransferStringList("Coercer.DestructiveMindTargets", m_astrDestructiveMindTargets);
			ThisFile.TransferBool("Coercer.BuffIntAgi", ref m_bBuffINTAGI);
			ThisFile.TransferString("Coercer.IntellectualRemedyCallout", ref m_strIntellectualRemedyCallout);
			return;
		}

		/************************************************************************************/
		protected override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_uiSingleDPSBuffAbilityID = SelectHighestTieredAbilityID("Velocity");
			m_uiSingleDeaggroBuffAbilityID = SelectHighestTieredAbilityID("Peaceful Link");
			m_uiSingleHateTransferAbilityID = SelectHighestTieredAbilityID("Enraging Demeanor");
			m_uiCoerciveHealingAbilityID = SelectHighestAbilityID("Coercive Healing");
			m_uiMainRegenBuffAbilityID = SelectHighestTieredAbilityID("Breeze");
			m_uiGroupINTAGIBuffAbilityID = SelectHighestTieredAbilityID("Signet of Intellect");
			m_uiGroupSecondaryManaRegenBuffAbilityID = SelectHighestTieredAbilityID("Mind's Eye");
			m_uiIntellectualRemedyAbilityID = SelectHighestAbilityID("Intellectual Remedy");

			m_uiTashianaAbilityID = SelectHighestAbilityID("Tashiana");
			m_uiSingleMagicalDebuffAbilityID = SelectHighestTieredAbilityID("Obliterated Psyche");
			m_uiSingleArcaneDebuffAbilityID = SelectHighestTieredAbilityID("Asylum");
			m_uiSingleINTDebuffAbilityID = SelectHighestTieredAbilityID("Cannibalize Thoughts");
			m_uiPossessEssenceAbilityID = SelectHighestTieredAbilityID("Possess Essence");
			m_uiPuppetmasterAbilityID = SelectHighestTieredAbilityID("Puppetmaster");
			m_uiHemorrhageAbilityID = SelectHighestTieredAbilityID("Hemorrhage");
			m_uiBrainshockAbilityID = SelectHighestTieredAbilityID("Brainshock");
			m_uiHostageAbilityID = SelectHighestTieredAbilityID("Hostage");
			m_uiDestructiveMindAbilityID = SelectHighestTieredAbilityID("Destructive Mind");
			m_uiSingleStifleNukeAbilityID = SelectHighestTieredAbilityID("Silence");
			m_uiSingleStunNukeAbilityID = SelectHighestTieredAbilityID("Medusa Gaze");
			m_uiGreenDOTAbilityID = SelectHighestTieredAbilityID("Simple Minds");
			m_uiGreenDazeNukeAbilityID = SelectHighestTieredAbilityID("Ego Shock");
			m_uiGreenSpellReactiveAbilityID = SelectHighestTieredAbilityID("Spell Curse");
			m_uiBlueStunNukeAbilityID = SelectHighestTieredAbilityID("Shock Wave");

			m_uiSingleReactiveStunAbilityID = SelectHighestAbilityID("Mindbend");
			m_uiSingleMezAbilityID = SelectHighestTieredAbilityID("Mesmerize");
			m_uiGreenMezAbilityID = SelectHighestTieredAbilityID("Pure Awe");
			m_uiGreenStunAbilityID = SelectHighestTieredAbilityID("Stupefy");
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

			/// Mez time! But as a bonus we use stuns in the lineup too now.
			if (IsIdle)
			{
				if (m_bUseGreenAEs)
				{
					/// Should also have encounter size check (2 or greater) but that'll have to wait for now (based on mez range).
					if (CastNextMez(m_uiGreenMezAbilityID, m_uiGreenStunAbilityID, m_uiSingleMezAbilityID, m_uiSingleStunNukeAbilityID, m_uiSingleReactiveStunAbilityID))
						return true;
				}
				else if (CastNextMez(m_uiSingleMezAbilityID, m_uiSingleStunNukeAbilityID, m_uiSingleReactiveStunAbilityID))
					return true;
			}

			if (AttemptCureArcane())
				return true;
			if (UseRegenItem())
				return true;

			if (m_bCheckBuffsNow)
			{
				if (CheckToggleBuff(m_uiGroupINTAGIBuffAbilityID, m_bBuffINTAGI))
					return true;
				if (CheckToggleBuff(m_uiArcaneBuffAbilityID, m_bBuffArcaneResistance))
					return true;
				if (CheckToggleBuff(m_uiMainRegenBuffAbilityID, m_bBuffRegen))
					return true;
				if (IsIdle && CheckToggleBuff(m_uiGroupSecondaryManaRegenBuffAbilityID, m_bBuffRegen))
					return true;
				if (CheckToggleBuff(m_uiMagisShieldingAbilityID, true))
					return true;
				if (CheckSingleTargetBuff(m_uiCoerciveHealingAbilityID, m_astrCoerciveHealingTargets))
					return true;
				if (CheckSingleTargetBuff(m_uiSingleHateTransferAbilityID, m_astrHateTransferTargets))
					return true;
				if (CheckSingleTargetBuffs(m_uiSingleDeaggroBuffAbilityID, m_astrDeaggroTargets))
					return true;
				if (CheckSingleTargetBuffs(m_uiSingleDPSBuffAbilityID, m_astrDPSTargets))
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

					/// We're not picky about the mob we get. It would be too complicated otherwise.
					if ((m_bSummonPetDuringCombat && m_bCanPossessCurrentTarget) && !IsAbilityMaintained(m_uiPossessEssenceAbilityID) && CastAbility(m_uiPossessEssenceAbilityID))
						return true;

					if (bTempBuffsAdvised)
					{
						if (!IsBeneficialEffectPresent(m_uiPeaceOfMindAbilityID) && CastAbilityOnSelf(m_uiPeaceOfMindAbilityID))
						{
							SpamSafeGroupSay(m_strPeaceOfMindCallout);
							return true;
						}

						/// TODO: Save this boost for when the group is in dire straits.
						if (!IsBeneficialEffectPresent(m_uiIntellectualRemedyAbilityID) && CastAbilityOnSelf(m_uiIntellectualRemedyAbilityID))
						{
							SpamSafeGroupSay(m_strIntellectualRemedyCallout);
							return true;
						}
					}

					if (m_bIHaveAggro)
					{
						if (UseDeaggroItems())
							return true;
					}

					/// Resist debuffs ALWAYS come first, I don't CARE what AE opportunities there are.
					if (!IsAbilityMaintained(m_uiTashianaAbilityID, m_iOffensiveTargetID) &&
						(m_OffensiveTargetActor.IsEpic || m_OffensiveTargetActor.IsNamed) &&
						!m_OffensiveTargetActor.IsAPet &&
						CastAbility(m_uiTashianaAbilityID))
					{
						return true;
					}
					if (!IsAbilityMaintained(m_uiSingleMagicalDebuffAbilityID, m_iOffensiveTargetID) && CastAbility(m_uiSingleMagicalDebuffAbilityID))
						return true;

					/// TODO: This should be changed to behave more like a buff, to allow multiple recipients.
					if (!IsAbilityMaintained(m_uiDestructiveMindAbilityID) && CastAbility(m_uiDestructiveMindAbilityID, m_astrDestructiveMindTargets, true))
						return true;

					/// This is guesswork for now.
					if (!m_OffensiveTargetActor.IsEpic && CastGreenOffensiveAbility(m_uiGreenStunAbilityID, 3))
						return true;

					if (CastBlueOffensiveAbility(m_uiBlueStunNukeAbilityID, 3))
						return true;

					/// We attempt this in two places:
					/// - Here at the beginning for the debuff, and
					/// - Down the list for the proc DPS.
					if (!IsAbilityMaintained(m_uiSingleArcaneDebuffAbilityID, m_iOffensiveTargetID) && CastAbility(m_uiSingleArcaneDebuffAbilityID))
						return true;
					if (!IsAbilityMaintained(m_uiNullifyingStaffAbilityID, m_iOffensiveTargetID) && CastAbility(m_uiNullifyingStaffAbilityID))
						return true;

					if (CastGreenOffensiveAbility(m_uiGreenSpellReactiveAbilityID, 3))
						return true;
					if (CastGreenOffensiveAbility(m_uiGreenDOTAbilityID, 3))
						return true;
					if (CastGreenOffensiveAbility(m_uiGreenDazeNukeAbilityID, 3))
						return true;

					if (!IsAbilityMaintained(m_uiSingleINTDebuffAbilityID, m_iOffensiveTargetID) &&
						(m_OffensiveTargetActor.IsEpic || m_OffensiveTargetActor.IsNamed) &&
						!m_OffensiveTargetActor.IsAPet &&
						CastAbility(m_uiSingleINTDebuffAbilityID))
					{
						return true;
					}

					/// The reactives are even useful off of a single mob, thus no special processing.
					if (CastAbility(m_uiGreenSpellReactiveAbilityID))
						return true;

					if (bDumbfiresAdvised && !IsAbilityMaintained(m_uiPuppetmasterAbilityID) && CastAbility(m_uiPuppetmasterAbilityID))
						return true;

					if (CastAbility(m_uiBewildermentAbilityID))
						return true;
					if (CastAbility(m_uiHostageAbilityID))
						return true;
					if (CastAbility(m_uiHemorrhageAbilityID))
						return true;
					if (CastAbility(m_uiLoreAndLegendAbilityID))
						return true;
					if (CastAbility(m_uiSingleStifleNukeAbilityID))
						return true;
					if (CastAbility(m_uiSingleStunNukeAbilityID))
						return true;
					if (CastAbility(m_uiBrainshockAbilityID))
						return true;
					if (CastBlueOffensiveAbility(m_uiBlueStunNukeAbilityID, 1))
						return true;
					if (CastGreenOffensiveAbility(m_uiGreenDOTAbilityID, 1))
						return true;
					if (CastGreenOffensiveAbility(m_uiGreenDazeNukeAbilityID, 1))
						return true;

					if (UseOffensiveItems())
						return true;
				}
			}

			return false;
		}
	}
}
