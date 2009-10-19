using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2ParseEngine
{
	/************************************************************************************/
	public class ConsoleLogEventArgs : EventArgs
	{
		protected readonly DateTime m_Timestamp = DateTime.FromBinary(0);
		public DateTime Timestamp { get { return m_Timestamp; } }

		protected readonly string m_strOriginalLine = string.Empty;
		public string OriginalLine { get { return m_strOriginalLine; } }

		public ConsoleLogEventArgs(
			DateTime ThisTimestamp,
			string strOriginalLine)
		{
			m_Timestamp = ThisTimestamp;
			m_strOriginalLine = strOriginalLine;
			return;
		}
	}

}
