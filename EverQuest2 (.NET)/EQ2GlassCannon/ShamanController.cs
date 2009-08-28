using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2GlassCannon
{
	public class ShamanController : PriestController
	{
		public uint m_uiCoagulateAbilityID = 0;
		public uint m_uiRitualOfAlacrityAbilityID = 0;

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_uiCoagulateAbilityID = SelectHighestAbilityID("Coagulate");
			m_uiRitualOfAlacrityAbilityID = SelectHighestAbilityID("Ritual");
			
			return;
		}
	}
}
