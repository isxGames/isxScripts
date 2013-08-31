using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2.ISXEQ2;
using EQ2ParseEngine;
using EQ2SuiteLib;

namespace EQ2GlassCannon
{
	/************************************************************************************/
	public class ScoutController : PlayerController
	{
		protected bool m_bDisarmChests = true;

		protected uint m_uiShroudAbilityID = 0;
		protected uint m_uiSingleDeaggroAbilityID = 0;
		protected uint m_uiEvasiveManeuversAbilityID = 0;

		/// <summary>
		/// The int is the actor ID and the bool is whether or not we made fair attempt to disarm it.
		/// There is no actor test to whether or not a chest can be disarmed, so we have to cache our attempts.
		/// </summary>
		protected Dictionary<int, bool> m_NearbyChestDictionary = new Dictionary<int, bool>();

		protected int m_iLastChestDisarmAttempted = -1;
		protected DateTime m_LastChestDisarmAttemptTime = DateTime.FromBinary(0);

		/************************************************************************************/
		protected override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			m_uiLoreAndLegendAbilityID = SelectHighestAbilityID("Sinister Strike");
			m_uiHOStarterAbiltyID = SelectHighestAbilityID("Lucky Break");
			m_uiShroudAbilityID = SelectHighestAbilityID("Shroud");
			m_uiSingleDeaggroAbilityID = SelectHighestTieredAbilityID("Evade");
			m_uiEvasiveManeuversAbilityID = SelectHighestAbilityID("Evasive Maneuvers");

			return;
		}

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferBool("Scout.DisarmChests", ref m_bDisarmChests);

			return;
		}

		/************************************************************************************/
		protected override bool OnLogNarrative(ConsoleLogEventArgs NewArgs)
		{
			if (base.OnLogNarrative(NewArgs))
				return true;

			if (m_iLastChestDisarmAttempted != -1)
			{
				if (NewArgs.OriginalLine.StartsWith("You disarm the trap on") ||
					NewArgs.OriginalLine.StartsWith("You failed to disarm the trap on") ||
					NewArgs.OriginalLine.StartsWith("You trigger the trap on"))
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
		protected override void OnZoningBegin()
		{
			base.OnZoningBegin();

			m_NearbyChestDictionary.Clear();
			return;
		}

		/************************************************************************************/
		protected bool CastLoreAndLegendAbility()
		{
			return CastAbilityFromFlankingOrBehind(m_uiLoreAndLegendAbilityID);
		}

		/************************************************************************************/
		protected bool DisarmChests()
		{
			/// No need to be doing this during combat.
			if (!m_bDisarmChests || MeActor.InCombatMode)
				return false;

			/// A disarm attempt is still in progress.
			if (m_iLastChestDisarmAttempted != -1)
			{
				/// We need to wait a little longer.
				if ((CurrentCycleTimestamp - m_LastChestDisarmAttemptTime) < TimeSpan.FromSeconds(3))
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
			foreach (Actor ThisActor in EnumActorsInRadius(3.5))
			{
				if (!m_NearbyChestDictionary.ContainsKey(ThisActor.ID))
					m_NearbyChestDictionary.Add(ThisActor.ID, false);

				if (ThisActor.IsChest && !m_NearbyChestDictionary[ThisActor.ID])
				{
					Program.Log("Attempting to disarm \"{0}\" (ID:{1})...", ThisActor.Name, ThisActor.ID);
					//ApplyVerb(ThisActor, "disarm");
					ThisActor.DoubleClick();
					m_LastChestDisarmAttemptTime = CurrentCycleTimestamp;
					m_iLastChestDisarmAttempted = ThisActor.ID;
					return true;
				}
			}

			return false;
		}

	}
}
