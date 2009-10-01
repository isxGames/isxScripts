using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace EQ2GlassCannon
{
	public class SetCollection<TYPE> : ICollection, IEnumerable, ICloneable
	{
		private SortedList<TYPE, object> m_SortedList = new SortedList<TYPE, object>();

		public bool Contains(TYPE ThisValue)
		{
			if (ThisValue == null)
				return false;

			return m_SortedList.ContainsKey(ThisValue);
		}

		public void Add(TYPE NewValue)
		{
			if (NewValue == null)
				return;

			/// We remove the threat of an exception for duplicate items.
			/// There is no need for an exception, nor will there ever be duplicate items.
			if (!m_SortedList.ContainsKey(NewValue))
			{
				m_SortedList.Add(NewValue, null);
			}
			return;
		}

		public void Add(IEnumerable<TYPE> NewValueCollection)
		{
			foreach (TYPE ThisType in NewValueCollection)
				Add(ThisType);
			return;
		}

		public void Remove(TYPE OldValue)
		{
			/// We remove the threat of an exception for nonexistent items.
			if (m_SortedList.ContainsKey(OldValue))
			{
				m_SortedList.Remove(OldValue);
			}
			return;
		}

		public void Clear()
		{
			m_SortedList.Clear();
			return;
		}

		/// <summary>
		/// </summary>
		public TYPE this[int iIndex]
		{
			get
			{
				return m_SortedList.Keys[iIndex];
			}
		}

		void ICollection.CopyTo(Array DestinationArray, int iIndex)
		{
			m_SortedList.Keys.CopyTo((TYPE[])DestinationArray, iIndex);
			return;
		}

		public int Count
		{
			get
			{
				return m_SortedList.Keys.Count;
			}
		}

		public bool IsEmpty
		{
			get
			{
				return (m_SortedList.Keys.Count == 0);
			}
		}

		public bool IsSynchronized
		{
			get
			{
				/// Not sure how to handle this one!
				return false;
				//return m_Dictionary.IsSyn  
			}
		}
		public object SyncRoot
		{
			get
			{
				/// Not sure how to handle this one!
				return null;
			}
		}

		public IEnumerator GetEnumerator()
		{
			return m_SortedList.Keys.GetEnumerator();
		}

		public object Clone()
		{
			return Copy();
		}

		public SetCollection<TYPE> Copy()
		{
			throw new NotImplementedException("TekSetCollection<>.Copy() not yet implemented");
		}
	}
}
