/* NOTE: The warden implementation is nowhere near complete.
 */

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2GlassCannon
{
	public class WardenController : DruidController
	{
		protected uint m_uiSingleElementalDebuffSpellAbilityID = 0;
		protected uint m_uiSingleElementalDebuffMeleeAbilityID = 0;
		protected uint m_uiSingleHeatNukeAbilityID = 0;
		protected uint m_uiSingleColdNukeAbilityID = 0;
		protected uint m_uiBlueMeleeColdAEAbilityID = 0;

		/************************************************************************************/
		protected override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_uiSingleElementalDebuffSpellAbilityID = SelectHighestTieredAbilityID("Frostbite");
			m_uiSingleElementalDebuffMeleeAbilityID = SelectHighestAbilityID("Frostbite Slice");
			m_uiSingleHeatNukeAbilityID = SelectHighestTieredAbilityID("Dawnstrike");
			m_uiSingleColdNukeAbilityID = SelectHighestTieredAbilityID("Icefall");
			m_uiBlueMeleeColdAEAbilityID = SelectHighestAbilityID("Whirl of Permafrost");
			return;
		}

		/************************************************************************************/
		protected bool AttemptCures()
		{
			return AttemptCures(true, false, false, true);
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
			bool bOffensiveTargetEngaged = EngageOffensiveTarget();

			if (bOffensiveTargetEngaged)
			{
				if (CastBlueOffensiveAbility(m_uiBlueMeleeColdAEAbilityID, 4))
					return true;

				if (IsIdle)
				{
					if (CastAbility(m_uiSingleElementalDebuffMeleeAbilityID) || CastAbility(m_uiSingleElementalDebuffSpellAbilityID))
						return true;
					if (CastAbility(m_uiSingleColdNukeAbilityID))
						return true;
					if (CastAbility(m_uiSingleHeatNukeAbilityID))
						return true;
				}
			}

			return false;
		}
	}
}
