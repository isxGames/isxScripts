using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2GlassCannon
{
	public class SorcererController : MageController
	{
		public string m_strHateTransferTarget = string.Empty;

		public int m_iWardOfSagesAbilityID = -1;

		public int m_iIceFlameAbilityID = -1;
		public int m_iThunderclapAbilityID = -1;
		public int m_iHateTransferAbilityID = -1;
		public int m_iFreehandSorceryAbilityID = -1;
		public int m_iAmbidexterousCastingAbilityID = -1;
		public int m_iGeneralGreenDeaggroAbilityID = -1;

		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_iWardOfSagesAbilityID = SelectHighestAbilityID("Ward of Sages");

			m_iIceFlameAbilityID = SelectHighestAbilityID(
				"Ice Flame",
				"Glacialflame",
				"Flames of Velious");

			m_iThunderclapAbilityID = SelectHighestAbilityID("Thunderclap");
			m_iFreehandSorceryAbilityID = SelectHighestAbilityID("Freehand Sorcery");
			m_iAmbidexterousCastingAbilityID = SelectHighestAbilityID("Ambidexterous Casting");
			m_iGeneralGreenDeaggroAbilityID = SelectHighestAbilityID("Concussive");

			return;
		}

		public override void TransferINISettings(TransferType eTransferType)
		{
			base.TransferINISettings(eTransferType);

			TransferINIString(eTransferType, "Sorceror.HateTransferTarget", ref m_strHateTransferTarget);

			return;
		}
	}
}
