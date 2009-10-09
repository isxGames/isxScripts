using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2ParseEngine;

namespace EQ2GlassCannon
{
	public class ParseThread : MessageThread
	{
		EQ2LogTokenizer m_ParseEngine = new EQ2LogTokenizer();

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

		public void PostNewLogLineMessage(string strLogLine)
		{
			PostMessage(new NewLogLineMessage(strLogLine));
			return;
		}

		protected override int Run()
		{
			m_ParseEngine.ChatSent += new EQ2LogTokenizer.ChatEventDelegate(ParseEngine_ChatSent);
			m_ParseEngine.LineNotRecognized += new EQ2LogTokenizer.LineNotRecognizedDelegate(ParseEngine_LineNotRecognized);

			return base.Run();
		}

		protected override void OnMessage(MessageThread.ThreadMessage NewMessage)
		{
			base.OnMessage(NewMessage);

			if (NewMessage is NewLogLineMessage)
			{
				NewLogLineMessage ThisMessage = (NewMessage as NewLogLineMessage);
				m_ParseEngine.FeedLine(ThisMessage.m_Timestamp, ThisMessage.m_strLogLine);
			}

			return;
		}

		protected void ParseEngine_LineNotRecognized(object objSender, EQ2LogTokenizer.ConsoleLogEventArgs args)
		{
			PlayerController.EnqueueLogEvent(args);
			return;
		}

		protected void ParseEngine_ChatSent(object objSender, EQ2LogTokenizer.ChatEventArgs args)
		{
			PlayerController.EnqueueLogEvent(args);
			return;
		}
	}
}
