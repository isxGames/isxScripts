using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2GlassCannon
{
	public class ClericController : PriestController
	{
		public List<string> m_strShieldAllyTargets = new List<string>();

		public uint m_uiDivineRecoveryAbilityID = 0;
		public uint m_uiSkullCrackAbilityID = 0; /// KoS AA, melee attack that debuffs offensive skills.
		public uint m_uiShieldAllyAbilityID = 0;
		public uint m_uiYaulpAbilityID = 0;

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_uiDivineRecoveryAbilityID = SelectHighestAbilityID("Divine Recovery");
			m_uiSkullCrackAbilityID = SelectHighestAbilityID("Skull Crack");
			m_uiShieldAllyAbilityID = SelectHighestAbilityID("Shield Ally");
			m_uiYaulpAbilityID = SelectHighestAbilityID("Yaulp");

			return;
		}

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferStringList("Cleric.ShieldAllyTargets", m_strShieldAllyTargets);
			return;
		}
	}
}
