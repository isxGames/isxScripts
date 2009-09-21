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
		public uint m_uiBewildermentAbilityID = 0;
		public uint m_uiCureArcaneAbilityID = 0;
		public uint m_uiMagisShieldingAbilityID = 0;

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_uiLoreAndLegendAbilityID = SelectHighestAbilityID("Master's Strike");
			m_uiHOStarterAbiltyID = SelectHighestAbilityID("Arcane Augur");

			/// Bewilderment shares the same name as the level 16 illusionist stun, so we can't do a name lookup.
			//m_iBewildermentAbilityID = SelectHighestAbilityID("Bewilderment");
			m_uiBewildermentAbilityID = SelectAbilityID(3903537279);

			m_uiCureArcaneAbilityID = SelectHighestAbilityID("Cure Arcane");
			m_uiMagisShieldingAbilityID = SelectHighestAbilityID("Magi's Shielding");

			return;
		}

		/************************************************************************************/
		public bool AttemptCureArcane()
		{
			if (!m_bCastCures || Me.IsMoving)
				return false;

			/// Do myself first, or this will be harder to coordinate for raiding.
			if (Me.Arcane > 0)
				return CastAbilityOnSelf(m_uiCureArcaneAbilityID);

			foreach (VitalStatus ThisStatus in EnumVitalStatuses(m_bCureUngroupedMainTank))
			{
				if (ThisStatus.m_iArcane > 0)
				{
					return CastAbility(m_uiCureArcaneAbilityID, ThisStatus.m_strName, true);
				}
			}

			return false;
		}


	}
}
