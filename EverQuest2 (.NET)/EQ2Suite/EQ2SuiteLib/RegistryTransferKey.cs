using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Win32;
using System.Drawing;

namespace EQ2SuiteLib
{
	public class RegistryTransferKey : IDisposable
	{
		public enum TransferMode
		{
			Read,
			Write
		}

		private RegistryKey m_Key = null;
		private TransferMode m_eTransferMode = TransferMode.Read;

		/***************************************************************************/
		public static implicit operator RegistryKey(RegistryTransferKey m_Key)
		{
			return m_Key.m_Key;
		}

		/***************************************************************************/
		public void Dispose()
		{
			if (m_Key != null)
			{
				m_Key.Close();
				m_Key = null;
			}
			return;
		}

		/***************************************************************************/
		public RegistryTransferKey(RegistryKey RootKey, string strKey, TransferMode eTransferMode)
		{
			Open(RootKey, strKey, eTransferMode);
			return;
		}

		/***************************************************************************/
		public void Open(RegistryKey RootKey, string strKey, TransferMode eTransferMode)
		{
			m_Key = RootKey.CreateSubKey(strKey);
			m_eTransferMode = eTransferMode;
			return;
		}

		/***************************************************************************/
		/// <summary>
		/// Transfer the double as a string for user editability.
		/// </summary>
		/// <param name="strName"></param>
		/// <param name="fValue"></param>
		public void TransferDouble(string strName, ref double fValue)
		{
			string strValue = string.Empty;
			
			if (m_eTransferMode == TransferMode.Write)
				strValue = fValue.ToString();

			TransferString(strName, ref strValue);

			if (m_eTransferMode == TransferMode.Read)
			{
				double fTemp = 0.0;

				if (double.TryParse(strValue, out fTemp))
					fValue = fTemp;
			}

			return;
		}

		/***************************************************************************/
		public void TransferInt(string strName, ref int iValue)
		{
			if (TransferMode.Read == m_eTransferMode)
			{
				object objPriorValue = m_Key.GetValue(strName);
				if (objPriorValue == null)
					m_Key.SetValue(strName, iValue);
				else
					iValue = (int)objPriorValue;
			}
			else
				m_Key.SetValue(strName, iValue);
			return;
		}

		/***************************************************************************/
		public void TransferEnum32<T>(string strName, ref T eValue)
		{
			if (TransferMode.Read == m_eTransferMode)
			{
				int iValue = (int)m_Key.GetValue(strName);
				eValue = (T)Enum.ToObject(typeof(T), iValue);
			}
			else
				m_Key.SetValue(strName, Convert.ToInt32(eValue));
			return;
		}

		/***************************************************************************/
		public void TransferDateTime(string strName, ref DateTime DateTimeValue)
		{
			if (TransferMode.Read == m_eTransferMode)
			{
				byte[] abyValue = (byte[])m_Key.GetValue(strName);
				long iRawValue = BitConverter.ToInt64(abyValue, 0);
				DateTimeValue = DateTime.FromBinary(iRawValue);
			}
			else
			{
				byte[] abyValue = BitConverter.GetBytes(DateTimeValue.ToBinary());
				m_Key.SetValue(strName, abyValue);
			}
			return;
		}

		/***************************************************************************/
		public void TransferString(string strName, ref string strValue)
		{
			if (TransferMode.Read == m_eTransferMode)
			{
				object objPriorValue = m_Key.GetValue(strName);
				if (objPriorValue == null)
					m_Key.SetValue(strName, strValue);
				else
					strValue = (string)objPriorValue;
			}
			else
				m_Key.SetValue(strName, strValue);
			return;
		}

		/***************************************************************************/
		public void TransferStringList(string strNamePrefix, ref List<string> astrValues)
		{
			int iCount = astrValues.Count;
			TransferInt(strNamePrefix + "Count", ref iCount);

			if (TransferMode.Read == m_eTransferMode)
			{
				astrValues.Clear();

				for (int iIndex = 0; iIndex < iCount; iIndex++)
				{
					string strValueName = strNamePrefix + iIndex.ToString("00");
					astrValues.Add((string)m_Key.GetValue(strValueName));
				}
			}
			else
			{
				for (int iIndex = 0; iIndex < iCount; iIndex++)
				{
					string strValueName = strNamePrefix + iIndex.ToString("00");
					m_Key.SetValue(strValueName, astrValues[iIndex]);
				}
			}
			return;
		}

		/***************************************************************************/
		public void TransferStringListAsSingleString(string strName, string strSeparator, ref List<string> astrValues)
		{
			string strColumnOrder = string.Empty;
			if (m_eTransferMode == TransferMode.Write)
			{
				strColumnOrder = string.Join(strSeparator, astrValues.ToArray());
			}
			TransferString(strName, ref strColumnOrder);
			if (m_eTransferMode == TransferMode.Read)
			{
				astrValues.Clear();
				string[] astrColumns = strColumnOrder.Split(new string[] { strSeparator }, StringSplitOptions.RemoveEmptyEntries);
				astrValues.AddRange(astrColumns);
			}
			return;
		}

		/***************************************************************************/
		public void TransferBool(string strName, ref bool bValue)
		{
			if (TransferMode.Read == m_eTransferMode)
				bValue = (0 != (int)m_Key.GetValue(strName));
			else
				m_Key.SetValue(strName, (bValue ? (int)1 : (int)0));
			return;
		}

		/***************************************************************************/
		public void TransferWindowLocation(string strNamePrefix, SavedWindowLocation ThisLocation)
		{
			string strTemp = string.Empty;

			if (m_eTransferMode == TransferMode.Write)
			{
				strTemp = string.Format("{0} {1} {2} {3} {4}",
					ThisLocation.m_rcBounds.X,
					ThisLocation.m_rcBounds.Y,
					ThisLocation.m_rcBounds.Width,
					ThisLocation.m_rcBounds.Height,
					ThisLocation.m_fScale);
			}

			TransferString(strNamePrefix + "Dimensions", ref strTemp);

			if (m_eTransferMode == TransferMode.Read)
			{
				string[] astrComponents = strTemp.Split(' ');
				ThisLocation.m_rcBounds.X = float.Parse(astrComponents[0]);
				ThisLocation.m_rcBounds.Y = float.Parse(astrComponents[1]);
				ThisLocation.m_rcBounds.Width = float.Parse(astrComponents[2]);
				ThisLocation.m_rcBounds.Height = float.Parse(astrComponents[3]);
				ThisLocation.m_fScale = double.Parse(astrComponents[4]);
			}

			/// Separate values.
			TransferBool(strNamePrefix + "Maximized", ref ThisLocation.m_bMaximized);
			return;
		}

		/***************************************************************************/
		public void TransferPersistentDetailedListViewColumnLayout(string strNamePrefix, PersistentDetailedListView.ColumnLayout ThisLayout)
		{
			/// Transfer the descriptor dictionary.
			List<string> astrColumnAttributeSets = new List<string>();
			if (m_eTransferMode == TransferMode.Write)
			{
				foreach (KeyValuePair<string, PersistentDetailedListView.ColumnLayout.ColumnDesc> ThisPair in ThisLayout.m_ColumnDescDictionary)
				{
					string strSet = string.Format("{0} {1}", ThisPair.Key, ThisPair.Value.m_fWidth);
					astrColumnAttributeSets.Add(strSet);
				}
			}
			TransferStringList(strNamePrefix + "ColumnDescriptor", ref astrColumnAttributeSets);
			if (m_eTransferMode == TransferMode.Read)
			{
				ThisLayout.m_ColumnDescDictionary.Clear();
				foreach (string strThisSet in astrColumnAttributeSets)
				{
					string[] astrAttributes = strThisSet.Split(new string[] {" "}, StringSplitOptions.None);

					PersistentDetailedListView.ColumnLayout.ColumnDesc NewDesc = new PersistentDetailedListView.ColumnLayout.ColumnDesc();
					if (double.TryParse(astrAttributes[1], out NewDesc.m_fWidth))
						ThisLayout.m_ColumnDescDictionary.Add(astrAttributes[0], NewDesc);
				}
			}

			/// Transfer the sort order list.
			List<string> astrColumnSortTokenList = new List<string>();
			if (m_eTransferMode == TransferMode.Write)
			{
				foreach (PersistentDetailedListView.ColumnLayout.SortDesc ThisDesc in ThisLayout.m_aColumnSortOrderList)
				{
					astrColumnSortTokenList.Add(ThisDesc.m_strTag);
					astrColumnSortTokenList.Add(ThisDesc.m_bSortAscending ? "asc" : "desc");
				}
			}
			TransferStringListAsSingleString(strNamePrefix + "ColumnSortOrder", " ", ref astrColumnSortTokenList);
			if (m_eTransferMode == TransferMode.Read)
			{
				ThisLayout.m_aColumnSortOrderList.Clear();
				for (int iIndex = 0; iIndex < astrColumnSortTokenList.Count; iIndex += 2)
				{
					PersistentDetailedListView.ColumnLayout.SortDesc NewDesc = new PersistentDetailedListView.ColumnLayout.SortDesc();
					NewDesc.m_strTag = astrColumnSortTokenList[iIndex];
					NewDesc.m_bSortAscending = (astrColumnSortTokenList[iIndex + 1] == "asc");
					ThisLayout.m_aColumnSortOrderList.Add(NewDesc);
				}
			}
	
			TransferStringListAsSingleString(strNamePrefix + "ColumnDisplayOrder", " ", ref ThisLayout.m_astrColumnDisplayOrderList);
			TransferWindowLocation(strNamePrefix + "ColumnConfigWindow", ThisLayout.m_ConfigWindowLocation);

			return;
		}
	}
}
