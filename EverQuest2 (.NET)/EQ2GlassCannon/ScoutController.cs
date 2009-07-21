using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2.ISXEQ2;

namespace EQ2GlassCannon
{
	public class ScoutController : PlayerController
	{
		public bool m_bDisarmChests = true;

		public int m_iShroudAbilityID = -1;
		public int m_iSingleDeaggroAbilityID = -1;
		public int m_iEvasiveManeuversAbilityID = -1;

		/// <summary>
		/// The int is the actor ID and the bool is whether or not we made fair attempt to disarm it.
		/// There is no actor test to whether or not a chest can be disarmed, so we have to cache our attempts.
		/// </summary>
		public Dictionary<int, bool> m_NearbyChestDictionary = new Dictionary<int, bool>();

		public int m_iLastChestDisarmAttempted = -1;
		public DateTime m_LastChestDisarmAttemptTime = DateTime.FromBinary(0);

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_iLoreAndLegendAbilityID = SelectHighestAbilityID("Sinister Strike");
			m_iHOStarterAbiltyID = SelectHighestAbilityID("Lucky Break");
			m_iShroudAbilityID = SelectHighestAbilityID("Shroud");
			m_iSingleDeaggroAbilityID = SelectHighestTieredAbilityID("Evade");
			m_iEvasiveManeuversAbilityID = SelectHighestAbilityID("Evasive Maneuvers");

			return;
		}

		/************************************************************************************/
		protected override void TransferINISettings(PlayerController.TransferType eTransferType)
		{
			base.TransferINISettings(eTransferType);

			TransferINIBool(eTransferType, "Scout.DisarmChests", ref m_bDisarmChests);

			return;
		}

		/************************************************************************************/
		public override bool OnIncomingText(string strFrom, string strChatText)
		{
			if (base.OnIncomingText(strFrom, strChatText))
				return true;

			if (m_iLastChestDisarmAttempted != -1)
			{
				if (strChatText.StartsWith("You disarm the trap on") ||
					strChatText.StartsWith("You failed to disarm the trap on") ||
					strChatText.StartsWith("You trigger the trap on"))
				{
					if (m_NearbyChestDictionary.ContainsKey(m_iLastChestDisarmAttempted))
						m_NearbyChestDictionary[m_iLastChestDisarmAttempted] = true;
					m_iLastChestDisarmAttempted = -1;
					Program.Log("Chest disarmed or triggered. Checking for others.");
					return true;
				}
			}

			return false;
		}

		/************************************************************************************/
		public override void OnZoning()
		{
			base.OnZoning();

			m_NearbyChestDictionary.Clear();
			return;
		}

		/************************************************************************************/
		public bool DisarmChests()
		{
			/// No need to be doing this during combat.
			if (!m_bDisarmChests || MeActor.InCombatMode)
				return false;

			/// A disarm attempt is still in progress.
			if (m_iLastChestDisarmAttempted != -1)
			{
				/// We need to wait a little longer.
				if ((DateTime.Now - m_LastChestDisarmAttemptTime) < TimeSpan.FromSeconds(5))
				{
					Program.Log("Waiting for the server to respond to last chest disarm attempt before attempting more.");
					return false;
				}

				/// Timeout, write this one off.
				/// Most likely it was already opened or disarmed.
				else
				{
					m_iLastChestDisarmAttempted = -1;
					if (m_NearbyChestDictionary.ContainsKey(m_iLastChestDisarmAttempted))
						m_NearbyChestDictionary[m_iLastChestDisarmAttempted] = true;
					Program.Log("Timeout on chest disarm. Won't repeat the attempt.");
				}
			}

			/// Scan for chests in disarm range.
			/// It's a pretty small radius, you almost have to run the scout right over the chest.
			foreach (Actor ThisActor in EnumCustomActors("byDist", "3.5"))
			{
				if (!m_NearbyChestDictionary.ContainsKey(ThisActor.ID))
					m_NearbyChestDictionary.Add(ThisActor.ID, false);

				if (ThisActor.IsChest && !m_NearbyChestDictionary[ThisActor.ID])
				{
					Program.Log("Attempting to disarm \"{0}\" (ID:{1})...", ThisActor.Name, ThisActor.ID);
					Program.ApplyVerb(ThisActor, "disarm");
					m_LastChestDisarmAttemptTime = DateTime.Now;
					m_iLastChestDisarmAttempted = ThisActor.ID;
					return true;
				}
			}

			return false;
		}

	}
}
