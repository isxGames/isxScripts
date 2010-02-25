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
			return;
		}

		/***************************************************************************/
		public void TransferInt(string strName, ref int iValue, TransferMode eTransferMode)
		{
			if (TransferMode.Read == eTransferMode)
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
		public void TransferEnum32<T>(string strName, ref T eValue, TransferMode eTransferMode)
		{
			if (TransferMode.Read == eTransferMode)
			{
				int iValue = (int)m_Key.GetValue(strName);
				eValue = (T)Enum.ToObject(typeof(T), iValue);
			}
			else
				m_Key.SetValue(strName, Convert.ToInt32(eValue));
			return;
		}

		/***************************************************************************/
		public void TransferDateTime(string strName, ref DateTime DateTimeValue, TransferMode eTransferMode)
		{
			if (TransferMode.Read == eTransferMode)
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
		public void TransferString(string strName, ref string strValue, TransferMode eTransferMode)
		{
			if (TransferMode.Read == eTransferMode)
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
		public void TransferStringList(string strNamePrefix, ref List<string> astrValues, TransferMode eTransferMode)
		{
			int iCount = astrValues.Count;
			TransferInt(strNamePrefix + "Count", ref iCount, eTransferMode);

			if (TransferMode.Read == eTransferMode)
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
		public void TransferBool(string strName, ref bool bValue, TransferMode eTransferMode)
		{
			if (TransferMode.Read == eTransferMode)
				bValue = (0 != (int)m_Key.GetValue(strName));
			else
				m_Key.SetValue(strName, (bValue ? (int)1 : (int)0));
			return;
		}

		/***************************************************************************/
		/// <summary>
		/// </summary>
		/// <remarks>
		/// This function turned out way more complicated than it needed to be.
		/// There's no reason the members of Rectangle had to be properties instead of straight variables.
		/// </remarks>
		public void TransferRectangle(
			string strNamePrefix,
			ref Rectangle rcValue,
			TransferMode eTransferMode)
		{
			string strTemp = string.Empty;

			if (eTransferMode == TransferMode.Write)
			{
				strTemp = string.Format("{0} {1} {2} {3}", rcValue.X, rcValue.Y, rcValue.Width, rcValue.Height);
			}

			TransferString(strNamePrefix + "Dimensions", ref strTemp, eTransferMode);

			if (eTransferMode == TransferMode.Read)
			{
				string[] astrComponents = strTemp.Split(' ');
				rcValue.X = int.Parse(astrComponents[0]);
				rcValue.Y = int.Parse(astrComponents[1]);
				rcValue.Width = int.Parse(astrComponents[2]);
				rcValue.Height = int.Parse(astrComponents[3]);
			}

			return;
		}

		/***************************************************************************/
		public void TransferFormLocation(
			RegistryKey m_Key,
			string strNamePrefix,
			SavedWindowLocation ThisLocation,
			TransferMode eTransferMode)
		{
			TransferRectangle(strNamePrefix, ref ThisLocation.m_rcBounds, eTransferMode);
			TransferBool(strNamePrefix + "Maximized", ref ThisLocation.m_bMaximized, eTransferMode);
			return;
		}
	}
}
