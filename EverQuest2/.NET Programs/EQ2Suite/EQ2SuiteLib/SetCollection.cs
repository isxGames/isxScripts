using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace EQ2SuiteLib
{
	/************************************************************************************/
	public class SetCollection<TYPE> : ICollection, IEnumerable, ICloneable
	{
		private SortedList<TYPE, object> m_SortedList = new SortedList<TYPE, object>();

		/************************************************************************************/
		public string ToString(string strSeparator)
		{
			List<string> astrList = new List<string>(Count);

			foreach (TYPE ThisItem in this)
			{
				astrList.Add(ThisItem.ToString());
			}

			return string.Join(strSeparator, astrList.ToArray());
		}

		/************************************************************************************/
		public override string ToString()
		{
			return ToString(", ");
		}

		/************************************************************************************/
		public bool Contains(TYPE ThisValue)
		{
			if (ThisValue == null)
				return false;

			return m_SortedList.ContainsKey(ThisValue);
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		/// <param name="NewValue"></param>
		/// <returns>true if the item was new in the collection</returns>
		public bool Add(TYPE NewValue)
		{
			if (NewValue == null)
				return false;

			/// We remove the threat of an exception for duplicate items.
			/// There is no need for an exception, nor will there ever be duplicate items.
			if (!m_SortedList.ContainsKey(NewValue))
			{
				m_SortedList.Add(NewValue, null);
				return true;
			}
			
			return true;
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		/// <param name="NewValueCollection"></param>
		/// <returns>true if the item was new in the collection</returns>
		public bool Add(IEnumerable<TYPE> NewValueCollection)
		{
			bool bNewLinkAdded = false;
			foreach (TYPE ThisType in NewValueCollection)
				if (Add(ThisType))
					bNewLinkAdded = true;
			return bNewLinkAdded;
		}

		/************************************************************************************/
		public void Remove(TYPE OldValue)
		{
			/// We remove the threat of an exception for nonexistent items.
			if (m_SortedList.ContainsKey(OldValue))
			{
				m_SortedList.Remove(OldValue);
			}
			return;
		}

		/************************************************************************************/
		public void Clear()
		{
			m_SortedList.Clear();
			return;
		}

		/************************************************************************************/
		/// <summary>
		/// </summary>
		public TYPE this[int iIndex]
		{
			get
			{
				return m_SortedList.Keys[iIndex];
			}
		}

		/************************************************************************************/
		void ICollection.CopyTo(Array DestinationArray, int iIndex)
		{
			m_SortedList.Keys.CopyTo((TYPE[])DestinationArray, iIndex);
			return;
		}

		/************************************************************************************/
		public TYPE[] ToArray()
		{
			TYPE[] NewArray = new TYPE[Count];
			int iIndex = 0;
			foreach (TYPE ThisItem in this)
				NewArray[iIndex++] = ThisItem;
			return NewArray;
		}

		/************************************************************************************/
		public int Count
		{
			get
			{
				return m_SortedList.Keys.Count;
			}
		}

		/************************************************************************************/
		public bool IsEmpty
		{
			get
			{
				return (m_SortedList.Keys.Count == 0);
			}
		}

		/************************************************************************************/
		public bool IsSynchronized
		{
			get
			{
				/// Not sure how to handle this one!
				return false;
				//return m_Dictionary.IsSyn  
			}
		}

		/************************************************************************************/
		public object SyncRoot
		{
			get
			{
				/// Not sure how to handle this one!
				return null;
			}
		}

		/************************************************************************************/
		public IEnumerator GetEnumerator()
		{
			return m_SortedList.Keys.GetEnumerator();
		}

		/************************************************************************************/
		public object Clone()
		{
			return Copy();
		}

		/************************************************************************************/
		public SetCollection<TYPE> Copy()
		{
			throw new NotImplementedException("TekSetCollection<>.Copy() not yet implemented");
		}
	}
}
