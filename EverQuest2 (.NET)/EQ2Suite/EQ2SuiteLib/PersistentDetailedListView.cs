using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Controls;
using System.Diagnostics;
using System.Windows;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Documents;
using System.ComponentModel;
using System.Windows.Data;
using System.Globalization;

namespace EQ2SuiteLib
{
	/// <summary>
	/// ListView that saves column state, and offers sorting and item activation eventing.
	/// Written with help from:
	/// http://kentb.blogspot.com/2006/12/listviewitemactivated-event-in-wpf.html
	/// http://www.switchonthecode.com/tutorials/wpf-tutorial-using-the-listview-part-2-sorting
	/// </summary>
	public class PersistentDetailedListView : ListView, CustomBaseWindow.IWindowEventSpy
	{
		/***************************************************************************/
		/// <summary>
		/// </summary>
		protected class SortDirectionAdorner : Adorner
		{
			private readonly static Geometry s_DescGeometry = Geometry.Parse("M 0,0 L 10,0 L 5,5 Z");
			private readonly static Geometry s_AscGeometry = Geometry.Parse("M 0,5 L 10,5 L 5,0 Z");
			public int m_iRank = 0;
			public bool m_bSortAscending = false;

			public SortDirectionAdorner(UIElement ThisElement, int iRank, bool bSortAscending)
				: base(ThisElement)
			{
				m_iRank = iRank;
				m_bSortAscending = bSortAscending;
				return;
			}

			protected override void OnRender(DrawingContext ThisContext)
			{
				base.OnRender(ThisContext);

				if (AdornedElement.RenderSize.Width < 20)
					return;

				/// Primary sort criteria.
				if (m_iRank == 0)
				{
					ThisContext.PushTransform(new TranslateTransform(AdornedElement.RenderSize.Width - 15, (AdornedElement.RenderSize.Height - 5) / 2));
					ThisContext.DrawGeometry(Brushes.Black, null, m_bSortAscending ? s_AscGeometry : s_DescGeometry);
					ThisContext.Pop();
				}

				/// Lesser sort criteria.
				else
				{
					ThisContext.PushTransform(new TranslateTransform(AdornedElement.RenderSize.Width - 20, (AdornedElement.RenderSize.Height - 5) / 2));
					ThisContext.DrawGeometry(Brushes.Gray, null, m_bSortAscending ? s_AscGeometry : s_DescGeometry);

					ThisContext.DrawText(
						new FormattedText(
							(m_iRank + 1).ToString(),
							CultureInfo.CurrentCulture,
							FlowDirection.LeftToRight,
							new Typeface("Arial"),
							10,
							Brushes.Gray),
						new Point(10, -5));

					ThisContext.Pop();
				}

				Console.WriteLine("SortDirectionAdorner.OnRender(): m_iRank {0} m_bSortAscending {1}", m_iRank, m_bSortAscending);
				return;
			}
		}

		/***************************************************************************/
		public class ColumnLayout
		{
			public class ColumnDesc
			{
				public double m_fWidth = 100;
			}

			public class SortDesc
			{
				public string m_strTag = string.Empty;
				public bool m_bSortAscending = true;
				public SortDesc()
				{
					return;
				}
				public SortDesc(string strTag, bool bSortAscending)
				{
					m_strTag = strTag;
					m_bSortAscending = bSortAscending;
					return;
				}
			}

			public Dictionary<string, ColumnDesc> m_ColumnDescDictionary = new Dictionary<string, ColumnDesc>();
			public List<string> m_astrColumnDisplayOrderList = new List<string>();
			public List<SortDesc> m_aColumnSortOrderList = new List<SortDesc>();
			public SavedWindowLocation m_ConfigWindowLocation = new SavedWindowLocation();
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
		protected static ScaleTransform FindParentScaleTransform(DependencyObject objStart)
		{
			/// This is TACKY AS HELL.
			/// I thought LayoutTransform was supposed to be a dependency object,
			/// so that it would carry down from the parent if not otherwise interrupted.
			/// But between the transforms there's all these mysterious Transform.Identity objects filling the gap, which I did not set.
			for (DependencyObject objThis = objStart; objThis != null; objThis = LogicalTreeHelper.GetParent(objThis))
			{
				if (objThis is FrameworkElement)
				{
					FrameworkElement ThisControl = (objThis as FrameworkElement);

					if (ThisControl.LayoutTransform is ScaleTransform)
						return (ThisControl.LayoutTransform as ScaleTransform);

					/// Game over, we lose.
					else if (ThisControl.LayoutTransform != Transform.Identity)
						return null;
				}
			}

			return null;
		}

		/***************************************************************************/
		/// <summary>
		/// Walks the tree up from the item until we find the ListView.
		/// </summary>
		/// <param name="listViewItem"></param>
		/// <returns></returns>
		public static PersistentDetailedListView FindListViewForItem(ListViewItem listViewItem)
		{
			for (DependencyObject parent = LogicalTreeHelper.GetParent(listViewItem); parent != null; parent = LogicalTreeHelper.GetParent(parent))
			{
				if (parent is PersistentDetailedListView)
					return (parent as PersistentDetailedListView);
			}

			return null;
		}

		/***************************************************************************/
		protected PersistentDetailedListView_ColumnSelectionWindow m_wndColumnSelectionWindow = null;
		protected GridView m_wndGridView = null;
		protected Dictionary<string, TaggedGridViewColumn> m_ColumnDictionary = new Dictionary<string, TaggedGridViewColumn>();
		protected Dictionary<string, SortDirectionAdorner> m_LastHeaderAdornerDictionary = new Dictionary<string, SortDirectionAdorner>();
		protected ColumnLayout m_SavedLayout = null;

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

					ToolTip HeaderToolTip = new ToolTip();
					HeaderToolTip.Content = "Right-click for more options";
					m_wndGridView.ColumnHeaderToolTip = HeaderToolTip;

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
						ThisHeader.ToolTipOpening += new ToolTipEventHandler(OnHeaderToolTipOpening);

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
					if (m_SavedLayout.m_astrColumnDisplayOrderList.Count == 0)
					{
						/// Remove any columns with default invisibility/non-presence.
						for (int iIndex = m_wndGridView.Columns.Count - 1; iIndex >= 0; iIndex--)
						{
							TaggedGridViewColumn ThisColumn = (m_wndGridView.Columns[iIndex] as TaggedGridViewColumn);
							if (!ThisColumn.IncludeInDefaultView)
								m_wndGridView.Columns.RemoveAt(iIndex);
						}
					}
					/// If an order is specified (which must have at least one column) then impose it.
					else if (m_SavedLayout.m_astrColumnDisplayOrderList.Count > 0)
					{
						HideAndShowColumns();
					}
					/// ...otherwise all columns are initially visible.

					/// We need this event to know when to save the column configuration.
					Unloaded += new System.Windows.RoutedEventHandler(this.OnListViewUnloaded);

					/// Provide default sort parameters.
					if (m_SavedLayout.m_aColumnSortOrderList.Count == 0)
					{
						foreach (TaggedGridViewColumn ThisColumn in m_ColumnDictionary.Values)
						{
							m_SavedLayout.m_aColumnSortOrderList.Add(new ColumnLayout.SortDesc(ThisColumn.Tag, true));
							break; // We just need the first one.
						}
					}

					//ActivateSorting();
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
		protected void OnHeaderClick(object sender, RoutedEventArgs e)
		{
			GridViewColumnHeader ThisHeader = (sender as GridViewColumnHeader);
			TaggedGridViewColumn ThisColumn = (ThisHeader.Column as TaggedGridViewColumn);

			/// Simply invert the toggle if it is the same column as the main.
			if (ThisColumn.Tag == m_SavedLayout.m_aColumnSortOrderList[0].m_strTag)
				m_SavedLayout.m_aColumnSortOrderList[0].m_bSortAscending = !m_SavedLayout.m_aColumnSortOrderList[0].m_bSortAscending;

			/// Otherwise copy it and overwrite everything.
			else
			{
				bool bSortAscending = m_SavedLayout.m_aColumnSortOrderList[0].m_bSortAscending;

				m_SavedLayout.m_aColumnSortOrderList.Clear();
				m_SavedLayout.m_aColumnSortOrderList.Add(new ColumnLayout.SortDesc(ThisColumn.Tag, bSortAscending));
			}

			SortOnce();
			return;
		}

		/***************************************************************************/
		protected void OnHeaderToolTipOpening(object sender, ToolTipEventArgs e)
		{
			ToolTip HeaderToolTip = ((sender as GridViewColumnHeader).ToolTip as ToolTip);
			ScaleTransform ThisTransform = FindParentScaleTransform(this);
			if (ThisTransform != null)
				HeaderToolTip.LayoutTransform = ThisTransform;
			return;
		}

		/***************************************************************************/
		void CustomBaseWindow.IWindowEventSpy.OnClosed(EventArgs e)
		{
			SaveLayout();
			return;
		}

		/***************************************************************************/
		void CustomBaseWindow.IWindowEventSpy.OnContentRendered(EventArgs e)
		{
			SortOnce();
			return;
		}

		/***************************************************************************/
		public void HideAndShowColumns()
		{
			/// Clear the official grid.
			m_wndGridView.Columns.Clear();

			/// Now we add the columns back in saved order.
			for (int iIndex = 0; iIndex < m_SavedLayout.m_astrColumnDisplayOrderList.Count; iIndex++)
				m_wndGridView.Columns.Add(m_ColumnDictionary[m_SavedLayout.m_astrColumnDisplayOrderList[iIndex]]);

			return;
		}

		/***************************************************************************/
		/// <summary>
		/// This can't be called until Window.OnContentRendered() is called,
		/// otherwise the adorner layer for the header items won't exist.
		/// "Although the logical tree can be traversed within the Window's constructor,
		/// the visual tree is empty until the Window undergoes layout at least once."
		/// </summary>
		public void SortOnce()
		{
			Items.SortDescriptions.Clear();

			/// Clear all adorners.
			foreach (KeyValuePair<string, SortDirectionAdorner> ThisPair in m_LastHeaderAdornerDictionary)
			{
				TaggedGridViewColumn ThisColumn = m_ColumnDictionary[ThisPair.Key];
				GridViewColumnHeader ThisHeader = (ThisColumn.Header as GridViewColumnHeader);
				AdornerLayer.GetAdornerLayer(ThisHeader).Remove(ThisPair.Value);
			}

			m_LastHeaderAdornerDictionary.Clear();

			foreach (ColumnLayout.SortDesc ThisDesc in m_SavedLayout.m_aColumnSortOrderList)
			{
				TaggedGridViewColumn ThisColumn = m_ColumnDictionary[ThisDesc.m_strTag];
				GridViewColumnHeader ThisHeader = (ThisColumn.Header as GridViewColumnHeader);

				SortDirectionAdorner NewAdorner = new SortDirectionAdorner(ThisHeader, Items.SortDescriptions.Count, ThisDesc.m_bSortAscending);
				AdornerLayer.GetAdornerLayer(ThisHeader).Add(NewAdorner);
				m_LastHeaderAdornerDictionary.Add(ThisColumn.Tag, NewAdorner);

				string strSortProperty = (ThisColumn.DisplayMemberBinding as Binding).Path.Path;
				Items.SortDescriptions.Add(new SortDescription(strSortProperty, ThisDesc.m_bSortAscending ? ListSortDirection.Ascending : ListSortDirection.Descending));
			}
			return;
		}

		/***************************************************************************/
		public void SaveLayout()
		{
			if (m_SavedLayout == null)
				throw new Exception("A layout object must be linked to this PersistentDetailedListView.");

			m_SavedLayout.m_astrColumnDisplayOrderList.Clear();
			//m_ColumnDescDictionary.Clear();

			for (int iIndex = 0; iIndex < m_wndGridView.Columns.Count; iIndex++)
			{
				TaggedGridViewColumn ThisColumn = (m_wndGridView.Columns[iIndex] as TaggedGridViewColumn);
				m_SavedLayout.m_astrColumnDisplayOrderList.Add(ThisColumn.Tag);

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
		protected void OnHeaderContextMenuOpening(object sender, ContextMenuEventArgs e)
		{
			GridViewColumnHeader ThisHeader = (sender as GridViewColumnHeader);
			ScaleTransform ThisTransform = FindParentScaleTransform(this);
			if (ThisTransform != null)
				ThisHeader.ContextMenu.LayoutTransform = ThisTransform;
			return;
		}

		/***************************************************************************/
		protected void OnHeaderContextMenuConfigureColumnsMenuItemClick(object sender, RoutedEventArgs e)
		{
			if (m_wndColumnSelectionWindow == null)
			{
				SaveLayout();

				m_wndColumnSelectionWindow = new PersistentDetailedListView_ColumnSelectionWindow(m_SavedLayout.m_ConfigWindowLocation, m_SavedLayout, m_ColumnDictionary);

				/// The parent window of the list will be our parent window.
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
						if (m_wndColumnSelectionWindow.ModelessDialogResult.Value)
						{
							HideAndShowColumns();
							SortOnce();
						}

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
		protected virtual void OnItemActivated(object item)
		{
			RaiseEvent(new RoutedEventArgs(s_ItemActivatedEvent, item));

			//execute the command if there is one
			if (Command != null)
			{
				RoutedCommand routedCommand = (Command as RoutedCommand);

				if (routedCommand != null)
					routedCommand.Execute(CommandParameter, CommandTarget);
				else
					Command.Execute(CommandParameter);
			}

			return;
		}
	}
}
