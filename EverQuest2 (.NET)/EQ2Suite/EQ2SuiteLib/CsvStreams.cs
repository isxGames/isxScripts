using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace EQ2SuiteLib
{
	/**********************************************************************************/
	public class CsvFileWriter : StreamWriter
	{
		protected bool m_bEmptyLine = true;

		/**********************************************************************************/
		public CsvFileWriter(string strFilePath, bool bAppend)
			: base(strFilePath, bAppend, Encoding.ASCII)
		{
			return;
		}

		/**********************************************************************************/
		public void WriteNextValue(string strValue)
		{
			if (null == strValue)
			{
				strValue = string.Empty;
			}

			if (!m_bEmptyLine)
			{
				Write(",");
			}
			else
			{
				m_bEmptyLine = false;
			}

			/// We have to do this sloppy because unlike the MFC CString::Replace() that
			/// returns the replace count, this is fucking Fisher Price Land where we coddle
			/// the fucking Visual Basic users.
			string strNeutralizedQuotesValue = strValue.Replace("\"", "\"\"");

			// If there were any quotes or commas in the string, enclose it with quotes.
			if (strValue != strNeutralizedQuotesValue || -1 != strValue.IndexOf(","))
			{
				strValue = "\"" + strNeutralizedQuotesValue + "\"";
			}

			strValue = strValue.Replace("\r\n", "\\n");
			Write(strValue);
			return;
		}

		/**********************************************************************************/
		public void WriteNextValue(int iValue)
		{
			// n.b. General.GetRegion() added to format spec to force InvariantCulture for 
			//   double conversion, required since XML will choke if default region is used 
			WriteNextValue(iValue.ToString());
			return;
		}

		/**********************************************************************************/
		public void WriteNextValue(double fValue)
		{
			// n.b. General.GetRegion() added to format spec to force InvariantCulture for 
			//   double conversion, required since XML will choke if default region is used 
			WriteNextValue(fValue.ToString());
			return;
		}

		/**********************************************************************************/
		public void WriteNextValue(object objValue)
		{
			WriteNextValue(objValue.ToString());
			return;
		}

		/**********************************************************************************/
		/// <summary>
		/// Use this function instead of the base WriteLine() function.
		/// </summary>
		public new void WriteLine()
		{
			base.WriteLine();
			m_bEmptyLine = true;
			return;
		}
	}

	/**********************************************************************************/
	/// <summary>
	/// 
	/// </summary>
	public class CsvFileReader : StreamReader
	{
		protected string m_strCurrentLine = string.Empty;
		protected int m_iReadIndex = 0;

		/**********************************************************************************/
		public CsvFileReader(string strFilePath)
			: base(strFilePath, Encoding.UTF8, true, 1000)
		{
			return;
		}

		/**********************************************************************************/
		public new bool ReadLine()
		{
			try
			{
				m_strCurrentLine = base.ReadLine();
				m_iReadIndex = 0;
			}
			catch
			{
				return false;
			}

			return !string.IsNullOrEmpty(m_strCurrentLine);
		}

		/**********************************************************************************/
		public string ReadNextValue()
		{
			if (m_iReadIndex >= m_strCurrentLine.Length)
				throw new IndexOutOfRangeException("No more CSV values to read from this line.");

			StringBuilder sb = new StringBuilder();

			/// Skip past leading whitespace.
			while (m_strCurrentLine[m_iReadIndex] == ' ')
				m_iReadIndex++;

			bool bInsideQuotes = (m_strCurrentLine[m_iReadIndex] == '\"');
			if (bInsideQuotes)
				m_iReadIndex++;

			bool bInQuotePair = false;

			while (m_iReadIndex < m_strCurrentLine.Length)
			{
				char chThis = m_strCurrentLine[m_iReadIndex];

				/// Simulate the null terminator (this code was ported from C++).
				char chNext = (m_iReadIndex < m_strCurrentLine.Length - 1) ? m_strCurrentLine[m_iReadIndex + 1] : (char)0;

				switch (chThis)
				{
					case '\"':
					{
						/// Two consecutive input quotes form one output quote.
						if (bInQuotePair)
						{
							sb.Append('\"');
							bInQuotePair = false;
						}
						else if (chNext != '\"')
							bInsideQuotes = false;
						else
							bInQuotePair = true;

						break;
					}

					case ',':
					{
						/// End of item.
						if (!bInsideQuotes)
						{
							m_iReadIndex++;
							goto FINISHED;
						}
						else
							sb.Append(chThis);
						break;
					}

					default:
					{
						sb.Append(chThis);
						break;
					}
				}

				m_iReadIndex++;
			}

		FINISHED:
			string strFinalString = sb.ToString();
			strFinalString = strFinalString.Replace("\\n", "\r\n");
			return strFinalString;
		}

	}
}
