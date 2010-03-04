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
	/// ListView that saves column state, and offers sorting and item activation eventing.
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
		/// <summary>
		/// Identifies the <see cref="Command"/> property.
		/// </summary>
		protected static readonly DependencyProperty s_CommandProperty = DependencyProperty.Register(
			"Command",
			typeof(ICommand),
			typeof(PersistentDetailedListView));

		/// <summary>
		/// Identifies the <see cref="CommandParameter"/> property.
		/// </summary>
		protected static readonly DependencyProperty s_CommandParameterProperty = DependencyProperty.Register(
			"CommandParameter",
			typeof(object),
			typeof(PersistentDetailedListView),
			new FrameworkPropertyMetadata(null));

		/// <summary>
		/// Identifies the <see cref="CommandTarget"/> property.
		/// </summary>
		protected static readonly DependencyProperty s_CommandTargetProperty = DependencyProperty.Register("CommandTarget",
				typeof(IInputElement),
				typeof(PersistentDetailedListView),
				new FrameworkPropertyMetadata(null));

		/// <summary>
		/// Identifies the <see cref="ItemActivated"/> event.
		/// </summary>
		protected static readonly RoutedEvent s_ItemActivatedEvent = EventManager.RegisterRoutedEvent("ItemActivated",
				RoutingStrategy.Bubble,
				typeof(RoutedEventHandler),
				typeof(PersistentDetailedListView));

		/***************************************************************************/
		static PersistentDetailedListView()
		{
			//register a handler for any double-clicks on ListViewItems
			EventManager.RegisterClassHandler(typeof(ListViewItem), ListViewItem.MouseDoubleClickEvent, new MouseButtonEventHandler(MouseDoubleClickHandler));
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
		public static PersistentDetailedListView FindListViewForItem(ListViewItem listViewItem)
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
		/// <summary>
		/// Gets or sets the <see cref="ICommand"/> to execute whenever an item is activated.
		/// </summary>
		public ICommand Command
		{
			get { return GetValue(s_CommandProperty) as ICommand; }
			set { SetValue(s_CommandProperty, value); }
		}

		/***************************************************************************/
		/// <summary>
		/// Gets or sets the parameter to be passed to the executed <see cref="Command"/>.
		/// </summary>
		public object CommandParameter
		{
			get { return GetValue(s_CommandParameterProperty); }
			set { SetValue(s_CommandParameterProperty, value); }
		}

		/***************************************************************************/
		/// <summary>
		/// Gets or sets the element on which to raise the specified <see cref="Command"/>.
		/// </summary>
		public IInputElement CommandTarget
		{
			get { return GetValue(s_CommandTargetProperty) as IInputElement; }
			set { SetValue(s_CommandTargetProperty, value); }
		}

		/***************************************************************************/
		/// <summary>
		/// Occurs whenever an item in this <c>ListView</c> is activated. <>
		/// </summary>
		public event RoutedEventHandler ItemActivated
		{
			add { AddHandler(s_ItemActivatedEvent, value); }
			remove { RemoveHandler(s_ItemActivatedEvent, value); }
		}

		/***************************************************************************/
		protected PersistentDetailedListView_ColumnSelectionWindow m_wndColumnSelectionWindow = null;
		protected GridView m_wndGridView = null;
		protected Dictionary<string, TaggedGridViewColumn> m_ColumnDictionary = new Dictionary<string, TaggedGridViewColumn>();
		protected ColumnLayout m_SavedLayout = null;

		/***************************************************************************/
		public PersistentDetailedListView()
		{
			return;
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

				/// Get to work, wire the ListView/GridView control up for use!
				try
				{
					m_ColumnDictionary.Clear();

					m_wndGridView.ColumnHeaderToolTip = "Right-click for more options";

					/// Build our custom context menu.
					ContextMenu NewContextMenu = new ContextMenu();
					NewContextMenu.Placement = System.Windows.Controls.Primitives.PlacementMode.MousePoint;
					MenuItem NewItem = new MenuItem();
					NewItem.Header = "Configure Columns...";
					NewItem.Click += new RoutedEventHandler(OnHeaderContextMenuConfigureColumnsMenuItemClick);
					NewContextMenu.Items.Add(NewItem);

					/// TODO: Assert that every child is a NamedGridViewColumn.
					foreach (TaggedGridViewColumn ThisColumn in m_wndGridView.Columns)
					{
						/// Catalog the column.
						m_ColumnDictionary.Add(ThisColumn.Tag, ThisColumn);

						/// Prepare our desired header.
						GridViewColumnHeader ThisHeader = null;
						if (ThisColumn.Header is GridViewColumnHeader)
						{
							/// If the XAML provided a header already, then just reuse that.
							ThisHeader = (ThisColumn.Header as GridViewColumnHeader);
							ThisHeader.Click -= OnHeaderClick;
							ThisHeader.Click += OnHeaderClick;
						}
						else
						{
							ThisHeader = new GridViewColumnHeader();
							ThisHeader.Click += OnHeaderClick;

							ThisHeader.Content = ThisColumn.Header;
							ThisColumn.Header = ThisHeader;
						}
						ThisHeader.ContextMenu = NewContextMenu;
						ThisHeader.ContextMenuOpening += new ContextMenuEventHandler(OnHeaderContextMenuOpening);

						/// Apply existing descriptors to the columns.
						if (m_SavedLayout.m_ColumnDescDictionary.ContainsKey(ThisColumn.Tag))
						{
							ThisColumn.Width = m_SavedLayout.m_ColumnDescDictionary[ThisColumn.Tag].m_fWidth;
						}

						/// Or add any descriptors that are missing.
						else
						{
							ColumnLayout.ColumnDesc NewDesc = new ColumnLayout.ColumnDesc();
							NewDesc.m_fWidth = ThisColumn.Width;
							m_SavedLayout.m_ColumnDescDictionary.Add(ThisColumn.Tag, NewDesc);
						}
					}

					/// An empty list means this is the first time this saved layout is ever attached on this view.
					if (m_SavedLayout.m_astrColumnOrderList.Count == 0)
					{
						/// TODO: Remove any columns with default invisibility/non-presence.
						for (int iIndex = m_wndGridView.Columns.Count - 1; iIndex >= 0; iIndex--)
						{
							TaggedGridViewColumn ThisColumn = (m_wndGridView.Columns[iIndex] as TaggedGridViewColumn);
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

					/// Provide default sort parameters.
					if (string.IsNullOrEmpty(m_SavedLayout.m_strSortedColumnID))
					{
						foreach (TaggedGridViewColumn ThisColumn in m_ColumnDictionary.Values)
						{
							m_SavedLayout.m_strSortedColumnID = ThisColumn.Tag;
							break;
						}
					}
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
				TaggedGridViewColumn ThisColumn = (m_wndGridView.Columns[iIndex] as TaggedGridViewColumn);
				m_SavedLayout.m_astrColumnOrderList.Add(ThisColumn.Tag);

				/// Save the details without erasing the dictionary (all of it will be saved to disk somehow).
				ColumnLayout.ColumnDesc ThisDesc = null;
				if (m_SavedLayout.m_ColumnDescDictionary.TryGetValue(ThisColumn.Tag, out ThisDesc))
				{
					ThisDesc.m_fWidth = ThisColumn.Width;
				}
			}
			return;
		}

		/***************************************************************************/
		protected void OnHeaderClick(object sender, RoutedEventArgs e)
		{
			TaggedGridViewColumn ThisColumn = ((sender as GridViewColumnHeader).Column as TaggedGridViewColumn);

			/// Define the sort parameters.
			if (m_SavedLayout.m_strSortedColumnID != ThisColumn.Tag)
				m_SavedLayout.m_strSortedColumnID = ThisColumn.Tag;
			else
				m_SavedLayout.m_bSortAscending = !m_SavedLayout.m_bSortAscending;

			/// TODO: Do sort here.

			return;
		}

		/***************************************************************************/
		protected void OnHeaderContextMenuOpening(object sender, ContextMenuEventArgs e)
		{
			GridViewColumnHeader ThisHeader = (sender as GridViewColumnHeader);

			/// This is TACKY AS HELL.
			/// I thought LayoutTransform was supposed to be a dependency object,
			/// so that it would carry down from the parent if not otherwise interrupted.
			/// But between the transforms there's all these mysterious Transform.Identity objects filling the gap, which I did not set.
			for (DependencyObject objThis = this; objThis != null; objThis = VisualTreeHelper.GetParent(objThis))
			{
				if (objThis is FrameworkElement)
				{
					FrameworkElement ThisControl = (objThis as FrameworkElement);

					if (ThisControl.LayoutTransform is ScaleTransform)
					{
						ThisHeader.ContextMenu.LayoutTransform = ThisControl.LayoutTransform;
						break;
					}

					/// Game over, we lose.
					else if (ThisControl.LayoutTransform != Transform.Identity)
						break;
				}
			}

			return;
		}

		/***************************************************************************/
		protected void OnHeaderContextMenuConfigureColumnsMenuItemClick(object sender, RoutedEventArgs e)
		{
			if (m_wndColumnSelectionWindow == null)
			{
				m_wndColumnSelectionWindow = new PersistentDetailedListView_ColumnSelectionWindow();

				/// Find the parent window.
				for (DependencyObject objThis = this; objThis != null; objThis = LogicalTreeHelper.GetParent(objThis))
				{
					if (objThis is Window)
					{
						m_wndColumnSelectionWindow.Owner = (objThis as Window);
						break;
					}
				}

				m_wndColumnSelectionWindow.Closed +=
					delegate(object sender2, EventArgs e2)
					{
						m_wndColumnSelectionWindow = null;
						return;
					};

				m_wndColumnSelectionWindow.Show();
			}
			else
			{
				if (m_wndColumnSelectionWindow.WindowState == WindowState.Minimized)
					m_wndColumnSelectionWindow.WindowState = WindowState.Normal;
				m_wndColumnSelectionWindow.Activate();
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
			RaiseEvent(new RoutedEventArgs(s_ItemActivatedEvent, item));

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
