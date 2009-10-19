using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2SuiteLib;

namespace EQ2ParseEngine
{
	public class ZoneStatistics
	{
		protected SetCollection<ItemLinkFoundEventArgs> m_ItemLinkCollection = new SetCollection<ItemLinkFoundEventArgs>();
		protected List<EncounterStatistics> m_EncounterStatisticsList = new List<EncounterStatistics>();
		protected EncounterStatistics m_MergedEncounter = null;
		protected EncounterStatistics m_CurrentEncounter = null;
		protected EQ2LogTokenizer m_SourceTokenizer = null;
		protected EQ2LogTokenizer.ItemLinkFoundHandler m_ItemLinkFoundHandler = null;
		protected EQ2LogTokenizer.ChatEventHandler m_ChatEventHandler = null;
		protected EQ2LogTokenizer.ActionEventHandler m_ActionEventHandler = null;

		public ZoneStatistics()
		{
		}

		/// <summary>
		/// If you want to be lazy, you can link the tokenizer directly to this object rather than feeding them manually.
		/// </summary>
		public EQ2LogTokenizer SourceTokenizer
		{
			get
			{
				return m_SourceTokenizer;
			}
			set
			{
				if (object.ReferenceEquals(m_SourceTokenizer, value))
					return;

				/// Kill the old one.
				if (m_SourceTokenizer != null)
				{
					m_SourceTokenizer.ItemLinkFound -= m_ItemLinkFoundHandler;
					m_SourceTokenizer.ChatSent -= m_ChatEventHandler;
					m_SourceTokenizer.ActionOccurred -= m_ActionEventHandler;
					m_SourceTokenizer = null;
				}

				/// Install the new one.
				if (value != null)
				{
					if (m_ItemLinkFoundHandler == null)
						m_ItemLinkFoundHandler = new EQ2LogTokenizer.ItemLinkFoundHandler(SourceTokenizer_ItemLinkFound);
					if (m_ChatEventHandler == null)
						m_ChatEventHandler = new EQ2LogTokenizer.ChatEventHandler(SourceTokenizer_ChatEvent);
					if (m_ActionEventHandler == null)
						m_ActionEventHandler = new EQ2LogTokenizer.ActionEventHandler(SourceTokenizer_ActionEvent);

					m_SourceTokenizer = value;
					m_SourceTokenizer.ItemLinkFound += m_ItemLinkFoundHandler;
					m_SourceTokenizer.ChatSent += m_ChatEventHandler;
					m_SourceTokenizer.ActionOccurred += m_ActionEventHandler;
				}
				return;
			}
		}

		protected void SourceTokenizer_ItemLinkFound(object objSender, ItemLinkFoundEventArgs args)
		{
			AddItemLinkFoundEvent(args);
			return;
		}

		protected void SourceTokenizer_ChatEvent(object objSender, ChatEventArgs args)
		{
			AddChatEvent(args);
			return;
		}

		protected void SourceTokenizer_ActionEvent(object objSender, ActionEventArgs args)
		{
			AddActionEvent(args);
			return;
		}

		protected void CreateEncounterIfNonExistant(DateTime EncounterStartTime)
		{
			if (m_CurrentEncounter == null)
			{
				m_CurrentEncounter = new EncounterStatistics(EncounterStartTime);
				m_EncounterStatisticsList.Add(m_CurrentEncounter);
			}

			return;
		}

		public void EndEncounter(DateTime EncounterEndTime)
		{
			if (m_CurrentEncounter != null)
			{
				m_CurrentEncounter.EndEncounter(EncounterEndTime);
				m_CurrentEncounter = null;
			}

			/// We do not delete the merged encounter.
			if (m_MergedEncounter != null)
			{
				m_MergedEncounter.EndEncounter(EncounterEndTime);
			}
			return;
		}

		public void AddItemLinkFoundEvent(ItemLinkFoundEventArgs NewEvent)
		{
			m_ItemLinkCollection.Add(NewEvent);
			return;
		}

		public void AddChatEvent(ChatEventArgs NewEvent)
		{
			if (m_CurrentEncounter != null)
				m_CurrentEncounter.AddChatEvent(NewEvent);

			if (m_MergedEncounter != null)
				m_MergedEncounter.AddChatEvent(NewEvent);
			return;
		}

		public void AddActionEvent(ActionEventArgs NewEvent)
		{
			CreateEncounterIfNonExistant(NewEvent.Timestamp);
			m_CurrentEncounter.AddActionEvent(NewEvent);
			m_MergedEncounter.AddActionEvent(NewEvent);
			return;
		}
	}
}
