using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2GlassCannon
{
	public class ScoutController : PlayerController
	{
		public int m_iShroudAbilityID = -1;
		public int m_iSingleDeaggroAbilityID = -1;
		public int m_iEvasiveManeuversAbilityID = -1;

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_iLoreAndLegendAbilityID = SelectHighestAbilityID("Sinister Strike");
			m_iHOStarterAbiltyID = SelectHighestAbilityID("Lucky Break");
			m_iShroudAbilityID = SelectHighestAbilityID("Shroud");
			m_iSingleDeaggroAbilityID = SelectHighestTieredAbilityID("Evade");
			m_iEvasiveManeuversAbilityID = SelectHighestAbilityID("Evasive Maneuvers");

			return;
		}
	}
}
