using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2ParseEngine
{
	/************************************************************************************/
	public class ItemLinkFoundEventArgs : EventArgs, IComparable<ItemLinkFoundEventArgs>
	{
		protected readonly string m_strFullLink = string.Empty;
		public string FullLink { get { return m_strFullLink; } }

		protected readonly int m_iParameter1 = 0;
		public int Parameter1 { get { return m_iParameter1; } }

		protected readonly int m_iParameter2 = 0;
		public int Parameter2 { get { return m_iParameter2; } }

		protected readonly int m_iParameter3 = 0;
		public int Parameter3 { get { return m_iParameter3; } }

		protected readonly string m_strItemName = string.Empty;
		public string ItemName { get { return m_strItemName; } }

		public ItemLinkFoundEventArgs(
			string strFullLink,
			int iParameter1,
			int iParameter2,
			int iParameter3,
			string strItemName)
		{
			m_strFullLink = strFullLink;
			m_iParameter1 = iParameter1;
			m_iParameter2 = iParameter2;
			m_iParameter3 = iParameter3;
			m_strItemName = strItemName;
			return;
		}

		/// <summary>
		/// This is useful in case you want to keep a SortedDictionary of unique item links.
		/// </summary>
		public int CompareTo(ItemLinkFoundEventArgs OtherItem)
		{
			int iComparison = 0;

			/// Parameter 1 is a quicker sort method but for human readability, the name is better.
			iComparison = m_strItemName.CompareTo(OtherItem.m_strItemName);
			if (iComparison != 0)
				return iComparison;

			iComparison = m_iParameter1.CompareTo(OtherItem.m_iParameter1);
			if (iComparison != 0)
				return iComparison;

			iComparison = m_iParameter2.CompareTo(OtherItem.m_iParameter2);
			if (iComparison != 0)
				return iComparison;

			iComparison = m_iParameter3.CompareTo(OtherItem.m_iParameter3);
			if (iComparison != 0)
				return iComparison;

			return 0;
		}
	}
}
