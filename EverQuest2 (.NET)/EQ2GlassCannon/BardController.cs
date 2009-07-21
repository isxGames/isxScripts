using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2GlassCannon
{
	public class BardController : ScoutController
	{
		#region Ability ID's
		public int m_iAllegroAbilityID = -1;
		public int m_iDontKillTheMessengerAbilityID = -1;
		public int m_iDexterousSonataAbilityID = -1;
		public int m_iFortissimoAbilityID = -1;
		public int m_iGroupRunSpeedBuffAbilityID = -1;

		public int m_iGreenSTRAGIDebuffAbilityID = -1;

		public int m_iBumpAbilityID = -1;
		public int m_iRhythmBladeAbilityID = -1;
		public int m_iTurnstrikeAbilityID = -1;
		#endregion

		/************************************************************************************/
		protected override void TransferINISettings(TransferType eTransferType)
		{
			base.TransferINISettings(eTransferType);
			return;
		}

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_iAllegroAbilityID = SelectHighestAbilityID("Allegro");
			m_iDontKillTheMessengerAbilityID = SelectHighestAbilityID("Don't Kill the Messenger");
			m_iDexterousSonataAbilityID = SelectHighestAbilityID("Dexterous Sonata");
			m_iFortissimoAbilityID = SelectHighestAbilityID("Fortissimo");
			m_iGroupRunSpeedBuffAbilityID = SelectHighestTieredAbilityID("Selo's Accelerando");
			m_iGreenSTRAGIDebuffAbilityID = SelectHighestTieredAbilityID("Disheartening Descant");
			m_iBumpAbilityID = SelectHighestAbilityID("Bump");
			m_iRhythmBladeAbilityID = SelectHighestAbilityID("Rhythm Blade");
			m_iTurnstrikeAbilityID = SelectHighestAbilityID("Turnstrike");

			return;
		}
	}
}
