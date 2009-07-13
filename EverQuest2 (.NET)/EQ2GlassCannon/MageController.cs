using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using InnerSpaceAPI;
using System.Threading;
using EQ2.ISXEQ2;

namespace EQ2GlassCannon
{
	public class MageController : PlayerController
	{
		public int m_iBewildermentAbilityID = -1;
		public int m_iCureArcaneAbilityID = -1;
		public int m_iMagisShieldingAbilityID = -1;

		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_iLoreAndLegendAbilityID = SelectHighestAbilityID("Master's Strike");
			m_iHOStarterAbiltyID = SelectHighestAbilityID("Arcane Augur");
			m_iBewildermentAbilityID = SelectHighestAbilityID("Bewilderment");
			m_iCureArcaneAbilityID = SelectHighestAbilityID("Cure Arcane");
			m_iMagisShieldingAbilityID = SelectHighestAbilityID("Magi's Shielding");

			return;
		}

		/************************************************************************************/
		public bool AttemptCureArcane()
		{
			if (!m_bCastCures || Me.IsMoving)
				return false;

			/// Do myself first, or this will be harder to coordinate for raiding.
			if (Me.Arcane > 0)
				return CastAbility(m_iCureArcaneAbilityID, Me.Name, true);

			foreach (VitalStatus ThisStatus in EnumVitalStatuses(m_bCureMainTank))
			{
				if (ThisStatus.m_iArcane > 0)
				{
					return CastAbility(m_iCureArcaneAbilityID, ThisStatus.m_strName, true);
				}
			}

			return false;
		}


	}
}
