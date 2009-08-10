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
		protected int m_iSingleElementalDebuffAbilityID = -1;
		protected int m_iSingleHeatNukeAbilityID = -1;
		protected int m_iSingleColdNukeAbilityID = -1;
		protected int m_iBlueMeleeColdAEAbilityID = -1;

		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_iSingleElementalDebuffAbilityID = SelectHighestTieredAbilityID("Frostbite");
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
			if (base.DoNextAction())
				return true;

			if (Me.CastingSpell || MeActor.IsDead)
				return true;

			if (m_bPrioritizeCures && AttemptCures())
				return true;

			/// Start this early just to get pet and autoattack rolling (illusionist mythical regen depends on it).
			/// We don't attempt offensive action until after cures/heals are dealt with.
			GetOffensiveTargetActor();

			bool bOffensiveTargetEngaged = EngagePrimaryEnemy();

			if (m_OffensiveTargetActor != null)
			{
				if (CastBlueOffensiveAbility(m_iBlueMeleeColdAEAbilityID, 4))
					return true;

				if (MeActor.IsIdle)
				{
					if (CastAbility(m_iSingleElementalDebuffAbilityID))
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
