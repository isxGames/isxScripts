using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2ParseEngine
{
	public class EncounterStatistics
	{
		protected DateTime? m_EncounterStartTime = null;
		protected TimeSpan m_TotalEncounterTime = TimeSpan.FromTicks(0);

		public EncounterStatistics(DateTime EncounterStartTime)
		{
			StartEncounter(EncounterStartTime);
			return;
		}

		public void StartEncounter(DateTime EncounterStartTime)
		{
			if (m_EncounterStartTime == null)
				m_EncounterStartTime = EncounterStartTime;
			return;
		}

		public void EndEncounter(DateTime EncounterEndTime)
		{
			if (m_EncounterStartTime != null)
			{
				m_TotalEncounterTime += (EncounterEndTime - m_EncounterStartTime.Value);
				m_EncounterStartTime = null;
			}
			return;
		}

		public void AddChatEvent(ChatEventArgs NewEvent)
		{
			return;
		}

		public void AddActionEvent(ActionEventArgs NewEvent)
		{
			return;
		}
	}
}
