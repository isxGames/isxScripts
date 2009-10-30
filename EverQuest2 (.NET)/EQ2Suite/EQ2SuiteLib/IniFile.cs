using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace EQ2SuiteLib
{
	public class IniFile : IDisposable
	{
		protected Dictionary<string, string> m_Settings = new Dictionary<string, string>();

		/************************************************************************************/
		public enum TransferMode
		{
			Read,
			Write
		}

		/************************************************************************************/
		protected string m_strFilePath = string.Empty;
		public string Path
		{
			get
			{
				return m_strFilePath;
			}
		}

		/************************************************************************************/
		protected TransferMode m_eTransferMode = TransferMode.Read;
		public TransferMode Mode
		{
			get
			{
				return m_eTransferMode;
			}
			set
			{
				m_eTransferMode = value;
				return;
			}
		}

		/************************************************************************************/
		public void Dispose()
		{
		}

		/************************************************************************************/
		/// <summary>
		/// Create an empty file in Write mode.
		/// </summary>
		public IniFile()
		{
			m_eTransferMode = TransferMode.Write;
			return;
		}

		/************************************************************************************/
		/// <summary>
		/// Create a file in Read mode and loads the file.
		/// </summary>
		public IniFile(string strFilePath)
		{
			Load(strFilePath);
			return;
		}

		/************************************************************************************/
		public void Clear()
		{
			m_Settings.Clear();
			return;
		}

		/************************************************************************************/
		public bool Load(string strFilePath)
		{
			if (!File.Exists(strFilePath))
				return false;

			using (StreamReader InputFile = new StreamReader(strFilePath, true))
			{
				m_strFilePath = strFilePath;
				m_eTransferMode = TransferMode.Read;
				m_Settings.Clear();

				while (!InputFile.EndOfStream)
				{
					string strInput = InputFile.ReadLine();
					strInput = strInput.Trim();

					if (strInput.StartsWith(";"))
						continue;

					int iEqualsPosition = strInput.IndexOf("=");
					if (iEqualsPosition == -1)
						continue;

					string strKey = strInput.Substring(0, iEqualsPosition).TrimEnd();
					string strValue = strInput.Substring(iEqualsPosition + 1).TrimStart();

					if (m_Settings.ContainsKey(strKey))
						m_Settings[strKey] = strValue;
					else
						m_Settings.Add(strKey, strValue);
				}
			}

			return true;
		}

		/************************************************************************************/
		public bool Load()
		{
			return Load(m_strFilePath);
		}

		/************************************************************************************/
		public void Save(string strFilePath)
		{
			m_strFilePath = strFilePath;

			using (StreamWriter OutputFile = new StreamWriter(strFilePath, false, Encoding.UTF8))
			{
				foreach (KeyValuePair<string, string> ThisItem in m_Settings)
				{
					string strOutput = string.Format("{0}={1}", ThisItem.Key, ThisItem.Value);
					OutputFile.WriteLine(strOutput);
				}
			}

			return;
		}

		/************************************************************************************/
		public void Save()
		{
			Save(m_strFilePath);
			return;
		}

		/************************************************************************************/
		public bool ReadString(string strKey, ref string strValue)
		{
			string strPreviousValue = strValue;
			if (!m_Settings.TryGetValue(strKey, out strValue))
			{
				/// TryGetValue turns the string to null, but null strings are bad.
				strValue = strPreviousValue;
				return false;
			}
			else
				return true;
		}

		/************************************************************************************/
		public void WriteString(string strKey, string strValue)
		{
			if (m_Settings.ContainsKey(strKey))
				m_Settings[strKey] = strValue;
			else
				m_Settings.Add(strKey, strValue);
			return;
		}

		/************************************************************************************/
		public void TransferString(string strKey, ref string strValue)
		{
			if (m_eTransferMode == TransferMode.Read)
				ReadString(strKey, ref strValue);
			else
				WriteString(strKey, strValue);
			return;
		}

		/************************************************************************************/
		public void TransferCaselessString(string strKey, ref string strValue)
		{
			if (m_eTransferMode == TransferMode.Read)
			{
				if (ReadString(strKey, ref strValue))
					strValue = strValue.ToLower();
			}
			else
				WriteString(strKey, strValue);
			return;
		}

		/************************************************************************************/
		public void TransferStringList(string strKey, List<string> astrValues)
		{
			if (astrValues == null)
				return;

			if (m_eTransferMode == TransferMode.Read)
			{
				string strCombinedValue = string.Empty;
				if (ReadString(strKey, ref strCombinedValue))
				{
					string[] astrRawValues = strCombinedValue.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
					astrValues.Clear();
					astrValues.AddRange(astrRawValues);
					for (int iIndex = 0; iIndex < astrValues.Count; iIndex++)
						astrValues[iIndex] = astrValues[iIndex].Trim();
				}
			}
			else
			{
				string strCombinedValue = string.Empty;
				foreach (string strValue in astrValues)
				{
					if (!string.IsNullOrEmpty(strCombinedValue))
						strCombinedValue += ",";
					strCombinedValue += strValue;
				}

				WriteString(strKey, strCombinedValue);
			}
			return;
		}

		/************************************************************************************/
		public void TransferBool(string strKey, ref bool bValue)
		{
			if (m_eTransferMode == TransferMode.Read)
			{
				string strValue = string.Empty;
				if (ReadString(strKey, ref strValue))
				{
					strValue = strValue.ToLower();
					bValue = (strValue == "1") || (strValue == "true") || (strValue == "yes");
				}
			}
			else
				WriteString(strKey, bValue ? "yes" : "no");
			return;
		}

		/************************************************************************************/
		public void TransferEnum<T>(string strKey, ref T eValue)
		{
			if (m_eTransferMode == TransferMode.Read)
			{
				string strValue = string.Empty;
				if (ReadString(strKey, ref strValue))
				{
					strValue = strValue.Trim();
					try
					{
						eValue = (T)Enum.Parse(typeof(T), strValue, true);
					}
					catch
					{
					}
				}
			}
			else
				WriteString(strKey, eValue.ToString());
			return;
		}

		/************************************************************************************/
		public void TransferInteger(string strKey, ref int iValue)
		{
			if (m_eTransferMode == TransferMode.Read)
			{
				string strValue = string.Empty;
				if (ReadString(strKey, ref strValue))
				{
					int iTemp;
					if (int.TryParse(strValue, out iTemp))
						iValue = iTemp;
				}
			}
			else
				WriteString(strKey, iValue.ToString());
			return;
		}

		/************************************************************************************/
		public void TransferULong(string strKey, ref ulong ulValue)
		{
			if (m_eTransferMode == TransferMode.Read)
			{
				string strValue = string.Empty;
				if (ReadString(strKey, ref strValue))
				{
					ulong ulTemp;
					if (ulong.TryParse(strValue, out ulTemp))
						ulValue = ulTemp;
				}
			}
			else
				WriteString(strKey, ulValue.ToString());
			return;
		}

		/************************************************************************************/
		public void TransferFloat(string strKey, ref float fValue)
		{
			if (m_eTransferMode == TransferMode.Read)
			{
				string strValue = string.Empty;
				if (ReadString(strKey, ref strValue))
				{
					float fTemp;
					if (float.TryParse(strValue, out fTemp))
						fValue = fTemp;
				}
			}
			else
				WriteString(strKey, fValue.ToString());
			return;
		}

		/************************************************************************************/
		public void TransferDouble(string strKey, ref double fValue)
		{
			if (m_eTransferMode == TransferMode.Read)
			{
				string strValue = string.Empty;
				if (ReadString(strKey, ref strValue))
				{
					double fTemp;
					if (double.TryParse(strValue, out fTemp))
						fValue = fTemp;
				}
			}
			else
				WriteString(strKey, fValue.ToString());
			return;
		}
	}
}
