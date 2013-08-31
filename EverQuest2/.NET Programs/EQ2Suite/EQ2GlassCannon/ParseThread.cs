using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2ParseEngine;
using EQ2SuiteLib;

namespace EQ2GlassCannon
{
	public class ParseThread : MessageThread
	{
		EQ2LogTokenizer m_ParseEngine = new EQ2LogTokenizer();

		/************************************************************************************/
		protected class NewLogLineMessage : ThreadMessage
		{
			public DateTime m_Timestamp = DateTime.Now;
			public string m_strLogLine = string.Empty;
			public NewLogLineMessage(string strLogLine)
			{
				m_strLogLine = strLogLine;
				return;
			}
		}

		/************************************************************************************/
		public void PostNewLogLineMessage(string strLogLine)
		{
			PostMessage(new NewLogLineMessage(strLogLine));
			return;
		}

		/************************************************************************************/
		protected class NewNameLanguageMessage : ThreadMessage
		{
			public string m_strCharacterName = string.Empty;
			public ChatEventArgs.GameLanguageType m_eLanguage = ChatEventArgs.GameLanguageType.Unknown;
			public NewNameLanguageMessage(string strCharacterName, ChatEventArgs.GameLanguageType eNewLanguage)
			{
				m_strCharacterName = strCharacterName;
				m_eLanguage = eNewLanguage;
				return;
			}
		}

		/************************************************************************************/
		public void PostNewNameLanguageMessage(string strCharacterName, ChatEventArgs.GameLanguageType eNewLanguage)
		{
			PostMessage(new NewNameLanguageMessage(strCharacterName, eNewLanguage));
			return;
		}

		/************************************************************************************/
		protected override int Run()
		{
			m_ParseEngine.ActionOccurred += new EQ2LogTokenizer.ActionEventHandler(ParseEngine_ActionOccurred);
			m_ParseEngine.ChatSent += new EQ2LogTokenizer.ChatEventHandler(ParseEngine_ChatSent);
			m_ParseEngine.LineNotRecognized += new EQ2LogTokenizer.LineNotRecognizedHandler(ParseEngine_LineNotRecognized);

			return base.Run();
		}

		/************************************************************************************/
		protected override void OnMessage(MessageThread.ThreadMessage NewMessage)
		{
			base.OnMessage(NewMessage);

			if (NewMessage is NewLogLineMessage)
			{
				NewLogLineMessage ThisMessage = (NewMessage as NewLogLineMessage);
				m_ParseEngine.FeedLine(ThisMessage.m_Timestamp, ThisMessage.m_strLogLine);
			}

			else if (NewMessage is NewNameLanguageMessage)
			{
				NewNameLanguageMessage ThisMessage = (NewMessage as NewNameLanguageMessage);
				m_ParseEngine.MyCharacterName = ThisMessage.m_strCharacterName;
				m_ParseEngine.MyGameLanguage = ThisMessage.m_eLanguage;
			}

			return;
		}

		/************************************************************************************/
		protected void ParseEngine_ActionOccurred(object objSender, ActionEventArgs args)
		{
			return;
		}

		/************************************************************************************/
		protected void ParseEngine_ChatSent(object objSender, ChatEventArgs args)
		{
			PlayerController.EnqueueLogEvent(args);
			return;
		}

		/************************************************************************************/
		protected void ParseEngine_LineNotRecognized(object objSender, ConsoleLogEventArgs args)
		{
			PlayerController.EnqueueLogEvent(args);
			return;
		}
	}
}
