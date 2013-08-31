using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Controls;
using System.Windows.Markup;
using System.ComponentModel;
using System.Collections;

namespace EQ2SuiteLib
{
	[ContentProperty()] /// I need to know how to say that there is no content property.
	public class MdiTabControl<T> : UserControl, IEnumerable where T : IMdiChild
	{
		/************************************************************************************/
		protected class TabDesc
		{
			public T m_MdiChild = default(T);
			public CloseableTabItem m_Tab = null;

			public override int GetHashCode()
			{
				return m_MdiChild.ID.GetHashCode();
			}
			public override bool Equals(object obj)
			{
				return base.Equals(obj);
			}

			public void OnCloseTab(object sender, System.Windows.RoutedEventArgs e)
			{
				m_MdiChild.TryClose();
				return;
			}
		}

		/************************************************************************************/
		public event EventHandler ChildActivated;
		protected Dictionary<string, TabDesc> m_TabDictionary = new Dictionary<string, TabDesc>();
		protected TabControl m_wndTabs = new TabControl();

		/************************************************************************************/
		public MdiTabControl()
		{
			this.Content = m_wndTabs;
			m_wndTabs.SelectionChanged += new SelectionChangedEventHandler(OnTabSelectionChanged);

			CloseableTabItem NewItem = new CloseableTabItem();
			NewItem.Header = "WIN!";
			m_wndTabs.Items.Add(NewItem);

			NewItem = new CloseableTabItem();
			NewItem.Header = "WINNER!";
			m_wndTabs.Items.Add(NewItem);
			return;
		}

		/************************************************************************************/
		protected void OnTabSelectionChanged(object sender, SelectionChangedEventArgs e)
		{
			if (ChildActivated != null)
				ChildActivated(this, new EventArgs());
			return;
		}

		/************************************************************************************/
		public IEnumerator GetEnumerator()
		{
			/// TODO: We unfortunately have to do a copy so that pages can be removed during enumeration.
			T[] aChildren = new T[m_TabDictionary.Count];

			int iIndex = 0;
			foreach (TabDesc ThisDesc in m_TabDictionary.Values)
				aChildren[iIndex++] = ThisDesc.m_MdiChild;

			return aChildren.GetEnumerator();
		}

		/************************************************************************************/
		public void Add(T NewChild)
		{
			if (m_TabDictionary.ContainsKey(NewChild.ID))
				return;

			TabDesc NewDesc = new TabDesc();
			NewDesc.m_MdiChild = NewChild;
			NewDesc.m_Tab = new CloseableTabItem();
			NewDesc.m_Tab.CloseTab += new System.Windows.RoutedEventHandler(NewDesc.OnCloseTab);
			NewDesc.m_Tab.Content = NewChild.Control;
			NewDesc.m_Tab.Tag = NewDesc;

			m_TabDictionary.Add(NewChild.ID, NewDesc);
			m_wndTabs.Items.Add(NewDesc.m_Tab);
			return;
		}

		/************************************************************************************/
		public T GetActiveChild()
		{
			CloseableTabItem ThisItem = (m_wndTabs.SelectedItem as CloseableTabItem);
			if (ThisItem == null)
				return default(T);

			return (ThisItem.Tag as TabDesc).m_MdiChild;
		}

		/************************************************************************************/
		public T GetChild(string strID)
		{
			TabDesc ThisDesc = null;
			if (m_TabDictionary.TryGetValue(strID, out ThisDesc))
				return ThisDesc.m_MdiChild;

			return default(T);
		}

		/************************************************************************************/
		public bool TryClose(string strID)
		{
			TabDesc ThisDesc = null;
			if (!m_TabDictionary.TryGetValue(strID, out ThisDesc))
				return false;

			return ThisDesc.m_MdiChild.TryClose();
		}
	}
}
