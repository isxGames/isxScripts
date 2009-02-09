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
		public override void InitializeKnowledgeBook()
		{
			base.InitializeKnowledgeBook();

			m_iLoreAndLegendAbilityID = SelectHighestAbilityID("Sinister Strike");
			m_iHOStarterAbiltyID = SelectHighestAbilityID("Lucky Break");
			m_iShroudAbilityID = SelectHighestAbilityID("Shroud");

			m_iSingleDeaggroAbilityID = SelectHighestAbilityID(
				"Evade",
				"Divert",
				"Slip",
				"Evasion",
				"Elude",
				"Baffle");

			m_iEvasiveManeuversAbilityID = SelectHighestAbilityID("Evasive Maneuvers");

			return;
		}
	}
}
