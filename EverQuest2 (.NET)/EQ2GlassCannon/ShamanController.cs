using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2GlassCannon
{
	public class ShamanController : PriestController
	{
		public int m_iCoagulateAbilityID = -1;
		public int m_iRitualOfAlacrityAbilityID = -1;

		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_iCoagulateAbilityID = SelectHighestAbilityID("Coagulate");
			m_iRitualOfAlacrityAbilityID = SelectHighestAbilityID("Ritual");
			
			return;
		}
	}
}
