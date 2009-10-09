using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2GlassCannon
{
	public class ThreadSafeQueue<T>
	{
		protected class Node
		{
			public T m_Value = default(T);
			public Node m_Next = null;
		}

		protected object m_objLock = new object();
		protected Node m_Head = null;
		protected int m_iCount = 0;

		public int Count
		{
			get
			{
				lock (m_objLock)
					return m_iCount;
			}
		}

		public void Enqueue(T NewValue)
		{
			Node NewNode = new Node();
			NewNode.m_Value = NewValue;

			lock (m_objLock)
			{
				NewNode.m_Next = m_Head;
				m_Head = NewNode;
				m_iCount++;
			}
			return;
		}

		public bool Dequeue(ref T ThisValue)
		{
			lock (m_objLock)
			{
				if (m_iCount == 0)
					return false;

				ThisValue = m_Head.m_Value;
				m_Head = m_Head.m_Next;
				m_iCount--;
			}
			return true;
		}
	}
}
