using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2GlassCannon
{
	public class ClericController : PriestController
	{
		public string m_strShieldAllyTarget = string.Empty;

		public int m_iDivineRecoveryAbilityID = -1;
		public int m_iSkullCrackAbilityID = -1; /// KoS AA, melee attack that debuffs offensive skills.
		public int m_iShieldAllyAbilityID = -1;
		public int m_iYaulpAbilityID = -1;

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_iDivineRecoveryAbilityID = SelectHighestAbilityID("Divine Recovery");
			m_iSkullCrackAbilityID = SelectHighestAbilityID("Skull Crack");
			m_iShieldAllyAbilityID = SelectHighestAbilityID("Shield Ally");
			m_iYaulpAbilityID = SelectHighestAbilityID("Yaulp");

			return;
		}

		/************************************************************************************/
		public override void TransferINISettings(TransferType eTransferType)
		{
			base.TransferINISettings(eTransferType);

			TransferINIString(eTransferType, "Cleric.ShieldAllyTarget", ref m_strShieldAllyTarget);
			return;
		}
	}
}
