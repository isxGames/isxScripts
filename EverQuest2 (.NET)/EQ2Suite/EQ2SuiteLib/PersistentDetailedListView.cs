using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Controls;
using System.Diagnostics;

namespace EQ2SuiteLib
{
	public class PersistentDetailedListView : ListView
	{
		/***************************************************************************/
		public class ColumnLayout
		{
			public class ColumnDesc
			{
				public double m_fWidth = 100;
			}

			public Dictionary<string, ColumnDesc> m_ColumnDescDictionary = new Dictionary<string, ColumnDesc>();
			public List<string> m_astrColumnOrderList = new List<string>();
			public string m_strSortedColumnID = string.Empty;
			public bool m_bSortAscending = true;
		}

		protected GridView m_wndGridView = null;
		protected Dictionary<string, NamedGridViewColumn> m_ColumnDictionary = new Dictionary<string, NamedGridViewColumn>();

		/***************************************************************************/
		protected ColumnLayout m_SavedLayout = null;
		public ColumnLayout SavedLayout
		{
			set
			{
				/// This isn't mandatory but it keeps the code easy for now.
				if (m_SavedLayout != null)
					throw new Exception("Layout object already linked to this PersistentDetailedListView.");

				if (m_wndGridView == null)
					throw new Exception("PersistentDetailedListView.View must be an initialized GridView before linking the layout object.");

				m_SavedLayout = value;

				try
				{
					/// First thing we do is catalog all columns.
					/// TODO: Assert that every child is a NamedGridViewColumn.
					m_ColumnDictionary.Clear();
					foreach (NamedGridViewColumn ThisColumn in m_wndGridView.Columns)
						m_ColumnDictionary.Add(ThisColumn.ID, ThisColumn);

					/// Synchronize the descriptor dictionary with the column dictionary.
					foreach (NamedGridViewColumn ThisColumn in m_ColumnDictionary.Values)
					{
						/// Apply existing descriptors to the columns.
						if (m_SavedLayout.m_ColumnDescDictionary.ContainsKey(ThisColumn.ID))
						{
							ThisColumn.Width = m_SavedLayout.m_ColumnDescDictionary[ThisColumn.ID].m_fWidth;
						}

						/// Or add any descriptors that are missing.
						else
						{
							ColumnLayout.ColumnDesc NewDesc = new ColumnLayout.ColumnDesc();
							NewDesc.m_fWidth = ThisColumn.Width;
							m_SavedLayout.m_ColumnDescDictionary.Add(ThisColumn.ID, NewDesc);
						}
					}

					/// An empty list means this is the first time this saved layout is ever attached on this view.
					if (m_SavedLayout.m_astrColumnOrderList.Count == 0)
					{
						/// TODO: Remove any columns with default invisibility/non-presence.
						for (int iIndex = m_wndGridView.Columns.Count - 1; iIndex >= 0; iIndex--)
						{
							NamedGridViewColumn ThisColumn = (m_wndGridView.Columns[iIndex] as NamedGridViewColumn);
							if (!ThisColumn.IncludeInDefaultView)
								m_wndGridView.Columns.RemoveAt(iIndex);
						}
					}
					/// If an order is specified (which must have at least one column) then impose it.
					else if (m_SavedLayout.m_astrColumnOrderList.Count > 0)
					{
						/// Clear the official grid.
						m_wndGridView.Columns.Clear();

						/// Now we add the columns back in saved order.
						for (int iIndex = 0; iIndex < m_SavedLayout.m_astrColumnOrderList.Count; iIndex++)
							m_wndGridView.Columns.Add(m_ColumnDictionary[m_SavedLayout.m_astrColumnOrderList[iIndex]]);
					}
					/// ...otherwise all columns are initially visible.

					/// We need this event to know when to save the column configuration.
					Unloaded += new System.Windows.RoutedEventHandler(this.OnListViewUnloaded);
				}
				catch //(Exception ex)
				{
					/// This function makes a ton of assumptions.
					/// Whether to leave things in a broken state or not, who really knows.
					//throw new Exception("PersistentDetailedListView.OnInitialized() failed.", ex);
				}

				return;
			}
		}

		/***************************************************************************/
		protected override void OnInitialized(EventArgs e)
		{
			base.OnInitialized(e);

			Debug.Assert(View is GridView, "PersistentDetailedListView.View must be of type GridView.");
			m_wndGridView = (View as GridView);
			return;
		}

		/***************************************************************************/
		protected void OnListViewUnloaded(object sender, System.Windows.RoutedEventArgs e)
		{
			try
			{
				m_SavedLayout.m_astrColumnOrderList.Clear();
				//m_ColumnDescDictionary.Clear();

				/// Now is when we save the layout.
				for (int iIndex = 0; iIndex < m_wndGridView.Columns.Count; iIndex++)
				{
					NamedGridViewColumn ThisColumn = (m_wndGridView.Columns[iIndex] as NamedGridViewColumn);
					m_SavedLayout.m_astrColumnOrderList.Add(ThisColumn.ID);

					/// Save the details without erasing the dictionary (all of it will be saved to disk somehow).
					ColumnLayout.ColumnDesc ThisDesc = null;
					if (m_SavedLayout.m_ColumnDescDictionary.TryGetValue(ThisColumn.ID, out ThisDesc))
					{
						ThisDesc.m_fWidth = ThisColumn.Width;
					}
				}
			}
			catch //(Exception ex)
			{
				//throw new Exception("PersistentDetailedListView.OnListViewUnloaded() failed.", ex);
			}
			finally
			{
				m_wndGridView = null;
				m_ColumnDictionary.Clear();
				m_SavedLayout = null;
			}

			return;
		}
	}
}
