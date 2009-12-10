using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2SuiteLib
{
	public class ThreadSafeQueue<T>
	{
		protected class Node
		{
			public T m_Value = default(T);
			public Node m_Next = null;
		}

		protected object m_objLock = new object();
		protected Node m_RemovalNode = null;
		protected Node m_InsertionNode = null;
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
			NewNode.m_Next = null;

			lock (m_objLock)
			{
				if (m_InsertionNode != null)
					m_InsertionNode.m_Next = NewNode;
				m_InsertionNode = NewNode;
				if (m_RemovalNode == null)
					m_RemovalNode = NewNode;
				m_iCount++;
			}
			return;
		}

		public bool Dequeue(ref T ThisValue)
		{
			lock (m_objLock)
			{
				if (m_RemovalNode == null)
					return false;
				else
				{
					ThisValue = m_RemovalNode.m_Value;
					m_RemovalNode = m_RemovalNode.m_Next;
					if (m_RemovalNode == null)
						m_InsertionNode = null;
					m_iCount--;
					return true;
				}
			}
		}
	}
}
