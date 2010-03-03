using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Controls;
using System.Diagnostics;
using System.Windows;
using System.Windows.Input;
using System.Windows.Media;

namespace EQ2SuiteLib
{
	/// <summary>
	/// ListView that saves column state and offers sorting and item activation eventing.
	/// Written with help from:
	/// http://kentb.blogspot.com/2006/12/listviewitemactivated-event-in-wpf.html
	/// </summary>
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

		/***************************************************************************/
		public class ItemActivatedEventArgs : RoutedEventArgs
		{
			public ItemActivatedEventArgs(RoutedEvent ThisEvent, object sender) : base(ThisEvent, sender)
			{
				return;
			}
		}

		/***************************************************************************/
		/// <summary>
		/// Identifies the <see cref="Command"/> property.
		/// </summary>
		protected static readonly DependencyProperty CommandProperty = DependencyProperty.Register(
			"Command",
			typeof(ICommand),
			typeof(ListView));

		/// <summary>
		/// Identifies the <see cref="CommandParameter"/> property.
		/// </summary>
		protected static readonly DependencyProperty CommandParameterProperty = DependencyProperty.Register(
			"CommandParameter",
			typeof(object),
			typeof(ListView),
			new FrameworkPropertyMetadata(null));

		/// <summary>
		/// Identifies the <see cref="CommandTarget"/> property.
		/// </summary>
		protected static readonly DependencyProperty CommandTargetProperty = DependencyProperty.Register("CommandTarget",
				typeof(IInputElement),
				typeof(ListView),
				new FrameworkPropertyMetadata(null));

		/// <summary>
		/// Identifies the <see cref="ItemActivated"/> event.
		/// </summary>
		protected static readonly RoutedEvent ItemActivatedEvent = EventManager.RegisterRoutedEvent("ItemActivated",
				RoutingStrategy.Bubble,
				typeof(EventHandler<ItemActivatedEventArgs>),
				typeof(ListView));

		/***************************************************************************/
		static PersistentDetailedListView()
		{
			//register a handler for any double-clicks on ListViewItems
			EventManager.RegisterClassHandler(typeof(ListViewItem), ListViewItem.MouseDoubleClickEvent, new MouseButtonEventHandler(MouseDoubleClickHandler));
			return;
		}

		/***************************************************************************/
		/// <summary>
		/// Gets or sets the <see cref="ICommand"/> to execute whenever an item is activated.
		/// </summary>
		public ICommand Command
		{
			get { return GetValue(CommandProperty) as ICommand; }
			set { SetValue(CommandProperty, value); }
		}

		/***************************************************************************/
		/// <summary>
		/// Gets or sets the parameter to be passed to the executed <see cref="Command"/>.
		/// </summary>
		public object CommandParameter
		{
			get { return GetValue(CommandParameterProperty); }
			set { SetValue(CommandParameterProperty, value); }
		}

		/***************************************************************************/
		/// <summary>
		/// Gets or sets the element on which to raise the specified <see cref="Command"/>.
		/// </summary>
		public IInputElement CommandTarget
		{
			get { return GetValue(CommandTargetProperty) as IInputElement; }
			set { SetValue(CommandTargetProperty, value); }
		}

		/***************************************************************************/
		/// <summary>
		/// Occurs whenever an item in this <c>ListView</c> is activated.
		/// </summary>
		public event EventHandler<ItemActivatedEventArgs> ItemActivated
		{
			add { AddHandler(ItemActivatedEvent, value); }
			remove { RemoveHandler(ItemActivatedEvent, value); }
		}

		/***************************************************************************/
		protected GridView m_wndGridView = null;
		protected Dictionary<string, NamedGridViewColumn> m_ColumnDictionary = new Dictionary<string, NamedGridViewColumn>();
		protected ColumnLayout m_SavedLayout = null;

		/***************************************************************************/
		public PersistentDetailedListView()
		{
			return;
		}

		/***************************************************************************/
		private static void MouseDoubleClickHandler(object sender, MouseEventArgs e)
		{
			ListViewItem listViewItem = sender as ListViewItem;
			Debug.Assert(listViewItem != null);
			PersistentDetailedListView wndListView = FindListViewForItem(listViewItem);

			if (wndListView != null)
				wndListView.OnItemActivated(listViewItem.Content);

			return;
		}

		/***************************************************************************/
		/// <summary>
		/// Walks the visual tree up from the item until we find the ListView.
		/// </summary>
		/// <param name="listViewItem"></param>
		/// <returns></returns>
		private static PersistentDetailedListView FindListViewForItem(ListViewItem listViewItem)
		{
			DependencyObject parent = VisualTreeHelper.GetParent(listViewItem);

			while (parent != null)
			{
				if (parent is PersistentDetailedListView)
					return (parent as PersistentDetailedListView);

				parent = VisualTreeHelper.GetParent(parent);
			}

			return null;
		}

		/***************************************************************************/
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
		public void SaveLayout()
		{
			if (m_SavedLayout == null)
				throw new Exception("A layout object must be linked to this PersistentDetailedListView.");

			m_SavedLayout.m_astrColumnOrderList.Clear();
			//m_ColumnDescDictionary.Clear();

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
			return;
		}

		/***************************************************************************/
		protected void OnListViewUnloaded(object sender, System.Windows.RoutedEventArgs e)
		{
			try
			{
				SaveLayout();
			}
			catch //(Exception ex)
			{
				//throw new Exception("PersistentDetailedListView.OnListViewUnloaded() failed.", ex);
			}
			finally
			{
				m_ColumnDictionary.Clear();
				m_SavedLayout = null;
			}

			return;
		}

		/***************************************************************************/
		protected override void OnKeyDown(KeyEventArgs e)
		{
			base.OnKeyDown(e);

			//hitting enter activates an item too
			if ((e.Key == Key.Enter) && (SelectedItem != null))
			{
				OnItemActivated(SelectedItem);
			}

			return;
		}

		/***************************************************************************/
		protected virtual void OnItemActivated(object item)
		{
			RaiseEvent(new ItemActivatedEventArgs(ItemActivatedEvent, item));

			//execute the command if there is one
			if (Command != null)
			{
				RoutedCommand routedCommand = Command as RoutedCommand;

				if (routedCommand != null)
					routedCommand.Execute(CommandParameter, CommandTarget);
				else
					Command.Execute(CommandParameter);
			}

			return;
		}
	}
}
