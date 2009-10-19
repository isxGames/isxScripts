using System;
using System.Collections.Generic;
using System.Text;

namespace EQ2SuiteLib
{
	/// <summary>
	/// Unlike the .NET string builder, this one doesn't keep reallocating the primary buffer.
	/// </summary>
	public class FlexStringBuilder
	{
		protected int m_iFinalLength = 0;
		protected Queue<string> m_StringQueue = new Queue<string>();
		protected string m_strAppendedLinePrefix = string.Empty;

		public string AppendedLinePrefix
		{
			set
			{
				m_strAppendedLinePrefix = value;
				return;
			}
		}

		public void Append(string strFormat, params object[] aobjArgs)
		{
			string strNew = (aobjArgs.Length > 0) ? string.Format(strFormat, aobjArgs) : strFormat;
			m_StringQueue.Enqueue(strNew);
			m_iFinalLength += strNew.Length;
			return;
		}

		public void AppendBreak()
		{
			Append("\r\n");
			return;
		}

		public void AppendLine(string strFormat, params object[] aobjArgs)
		{
			if (!string.IsNullOrEmpty(m_strAppendedLinePrefix))
				Append(m_strAppendedLinePrefix);

			Append(strFormat, aobjArgs);
			AppendBreak();
			return;
		}

		public void Clear()
		{
			m_StringQueue.Clear();
			m_iFinalLength = 0;
			return;
		}

		public override string ToString()
		{
			if (m_StringQueue.Count == 1)
				return m_StringQueue.Peek();
			else if (m_StringQueue.Count == 0)
				return string.Empty;
			else
			{
				StringBuilder FinalBuilder = new StringBuilder(m_iFinalLength);

				foreach (string strThis in m_StringQueue)
				{
					FinalBuilder.Append(strThis);
				}
				Clear();

				/// Don't reassemble it every single ToString() call.
				string strFullString = FinalBuilder.ToString();
				Append(strFullString);

				return strFullString;
			}
		}
	}
}
