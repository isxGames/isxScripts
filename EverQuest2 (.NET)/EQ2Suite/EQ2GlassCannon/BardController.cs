using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2SuiteLib;

namespace EQ2GlassCannon
{
	public class BardController : ScoutController
	{
		#region Ability ID's
		protected uint m_uiAllegroAbilityID = 0;
		protected uint m_uiDontKillTheMessengerAbilityID = 0;
		protected uint m_uiDexterousSonataAbilityID = 0;
		protected uint m_uiFortissimoAbilityID = 0;
		protected uint m_uiGroupRunSpeedBuffAbilityID = 0;

		protected uint m_uiGreenSTRAGIDebuffAbilityID = 0;

		protected uint m_uiBumpAbilityID = 0;
		protected uint m_uiRhythmBladeAbilityID = 0;
		protected uint m_uiTurnstrikeAbilityID = 0;
		#endregion

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);
			return;
		}

		/************************************************************************************/
		protected override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_uiAllegroAbilityID = SelectHighestAbilityID("Allegro");
			m_uiDontKillTheMessengerAbilityID = SelectHighestAbilityID("Don't Kill the Messenger");
			m_uiDexterousSonataAbilityID = SelectHighestAbilityID("Dexterous Sonata");
			m_uiFortissimoAbilityID = SelectHighestAbilityID("Fortissimo");
			m_uiGroupRunSpeedBuffAbilityID = SelectHighestTieredAbilityID("Selo's Accelerando");
			m_uiGreenSTRAGIDebuffAbilityID = SelectHighestTieredAbilityID("Disheartening Descant");
			m_uiBumpAbilityID = SelectHighestAbilityID("Bump");
			m_uiRhythmBladeAbilityID = SelectHighestAbilityID("Rhythm Blade");
			m_uiTurnstrikeAbilityID = SelectHighestAbilityID("Turnstrike");

			return;
		}
	}
}
