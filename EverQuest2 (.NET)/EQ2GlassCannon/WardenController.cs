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
		protected int m_iSingleElementalDebuffSpellAbilityID = -1;
		protected int m_iSingleElementalDebuffMeleeAbilityID = -1;
		protected int m_iSingleHeatNukeAbilityID = -1;
		protected int m_iSingleColdNukeAbilityID = -1;
		protected int m_iBlueMeleeColdAEAbilityID = -1;

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_iSingleElementalDebuffSpellAbilityID = SelectHighestTieredAbilityID("Frostbite");
			m_iSingleElementalDebuffMeleeAbilityID = SelectHighestAbilityID("Frostbite Slice");
			m_iSingleHeatNukeAbilityID = SelectHighestTieredAbilityID("Dawnstrike");
			m_iSingleColdNukeAbilityID = SelectHighestTieredAbilityID("Icefall");
			m_iBlueMeleeColdAEAbilityID = SelectHighestAbilityID("Whirl of Permafrost");
			return;
		}

		/************************************************************************************/
		public bool AttemptCures()
		{
			return AttemptCures(true, false, false, true);
		}

		/************************************************************************************/
		public override bool DoNextAction()
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
				if (CastBlueOffensiveAbility(m_iBlueMeleeColdAEAbilityID, 4))
					return true;

				if (MeActor.IsIdle)
				{
					if (CastAbility(m_iSingleElementalDebuffMeleeAbilityID) || CastAbility(m_iSingleElementalDebuffSpellAbilityID))
						return true;
					if (CastAbility(m_iSingleColdNukeAbilityID))
						return true;
					if (CastAbility(m_iSingleHeatNukeAbilityID))
						return true;
				}
			}

			return false;
		}
	}
}
