using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using System.ComponentModel;

namespace EQ2SuiteLib
{
	/// <summary>
	/// This class should really be internal but XAML won't let me do that. Fuck XAML.
	/// </summary>
	public partial class PersistentDetailedListView_ColumnSelectionWindow : CustomBaseWindow
	{
		public class SimpleColumnDesc : NotifyPropertyChangedBase
		{
			public SimpleColumnDesc(string strTag, object objContent)
			{
				m_strTag = strTag;
				m_objContent = objContent;
				return;
			}

			protected string m_strTag = string.Empty;
			public string Tag
			{
				get
				{
					return m_strTag;
				}
				set
				{
					if (m_strTag != value)
					{
						m_strTag = value;
						NotifyPropertyChanged("Label");
					}
					return;
				}
			}

			protected object m_objContent = null;
			public object Content
			{
				get
				{
					return m_objContent;
				}
				set
				{
					if (m_objContent != value)
					{
						m_objContent = value;
						NotifyPropertyChanged("Content");
					}
					return;
				}
			}
		}

		public class SortedColumnDesc : SimpleColumnDesc
		{
			public SortedColumnDesc(string strTag, object objContent, bool bSortAscending)
				: base(strTag, objContent)
			{
				m_bSortAscending = bSortAscending;
				return;
			}

			protected bool m_bSortAscending = false;
			public bool SortAscending
			{
				get
				{
					return m_bSortAscending;
				}
				set
				{
					if (m_bSortAscending != value)
					{
						m_bSortAscending = value;
						NotifyPropertyChanged("SortAscending");
					}
					return;
				}
			}
		}

		protected PersistentDetailedListView.ColumnLayout m_SavedLayout = null;
		protected Dictionary<string, TaggedGridViewColumn> m_ColumnDictionary = null;

		protected BindingList<SimpleColumnDesc> m_aShowColumnSourceList = new BindingList<SimpleColumnDesc>();
		protected BindingList<SimpleColumnDesc> m_aShowColumnDestinationList = new BindingList<SimpleColumnDesc>();
		protected BindingList<SimpleColumnDesc> m_aSortColumnSourceList = new BindingList<SimpleColumnDesc>();
		protected BindingList<SortedColumnDesc> m_aSortColumnDestinationList = new BindingList<SortedColumnDesc>();

		/***************************************************************************/
		public PersistentDetailedListView_ColumnSelectionWindow(
			SavedWindowLocation ThisSavedLocation,
			PersistentDetailedListView.ColumnLayout ThisSavedLayout,
			Dictionary<string, TaggedGridViewColumn> ColumnDictionary)
			: base(ThisSavedLocation)
		{
			InitializeComponent();

			m_SavedLayout = ThisSavedLayout;
			m_ColumnDictionary = ColumnDictionary;

			/// Tally the visible columns.
			foreach (string strThisTag in m_SavedLayout.m_astrColumnDisplayOrderList)
			{
				object objContent = (m_ColumnDictionary[strThisTag].Header as GridViewColumnHeader).Content;
				objContent = UIHelper.DeepCopyXamlObject(objContent);
				m_aShowColumnDestinationList.Add(new SimpleColumnDesc(strThisTag, objContent));
			}

			/// Tally the hidden columns.
			foreach (KeyValuePair<string, TaggedGridViewColumn> ThisPair in m_ColumnDictionary)
			{
				bool bIsDisplayed = m_SavedLayout.m_astrColumnDisplayOrderList.Contains(ThisPair.Key);
				if (!bIsDisplayed)
				{
					object objContent = (ThisPair.Value.Header as GridViewColumnHeader).Content;
					objContent = UIHelper.DeepCopyXamlObject(objContent);
					m_aShowColumnSourceList.Add(new SimpleColumnDesc(ThisPair.Key, objContent));
				}
			}

			/// Tally all columns.
			foreach (KeyValuePair<string, TaggedGridViewColumn> ThisPair in m_ColumnDictionary)
			{
				PersistentDetailedListView.ColumnLayout.SortDesc ThisDesc = null;
				
				foreach (PersistentDetailedListView.ColumnLayout.SortDesc ThisDesc2 in m_SavedLayout.m_aColumnSortOrderList)
				{
					if (ThisDesc2.m_strTag == ThisPair.Key)
					{
						ThisDesc = ThisDesc2;
						break;
					}
				}

				object objContent = (ThisPair.Value.Header as GridViewColumnHeader).Content;
				objContent = UIHelper.DeepCopyXamlObject(objContent);

				if (ThisDesc == null)
					m_aSortColumnSourceList.Add(new SimpleColumnDesc(ThisPair.Key, objContent));
				else
					m_aSortColumnDestinationList.Add(new SortedColumnDesc(ThisDesc.m_strTag, objContent, ThisDesc.m_bSortAscending));
			}

			/// Finalize the bindings.
			m_wndViewOrderSourceList.ItemsSource = m_aShowColumnSourceList;
			m_wndViewOrderDestinationList.ItemsSource = m_aShowColumnDestinationList;
			m_wndSortSourceList.ItemsSource = m_aSortColumnSourceList;
			m_wndSortDestinationList.ItemsSource = m_aSortColumnDestinationList;
			return;
		}

		/***************************************************************************/
		private void OnOkButtonClick(object sender, RoutedEventArgs e)
		{
			m_SavedLayout.m_astrColumnDisplayOrderList.Clear();
/*
			/// Remove columns that shouldn't be there.
			foreach (ShowColumnDesc ThisDesc in m_aShowColumnDescList)
				if (ThisDesc.IsChecked)
					m_SavedLayout.m_astrColumnDisplayOrderList.Add(ThisDesc.Tag);
*/
			ModelessDialogResult = true;
			return;
		}

		/***************************************************************************/
		private void OnCancelButtonClick(object sender, RoutedEventArgs e)
		{
			ModelessDialogResult = false;
			return;
		}

		/***************************************************************************/
		protected override void OnClosed(EventArgs e)
		{
			try
			{
				m_SavedLayout.m_astrColumnDisplayOrderList.Clear();
				foreach (SimpleColumnDesc ThisDesc in m_aShowColumnDestinationList)
				{
					m_SavedLayout.m_astrColumnDisplayOrderList.Add(ThisDesc.Tag);
				}


				//m_SavedLayout.m_aColumnSortOrderList.Add();

				base.OnClosed(e);
			}
			catch (Exception ex)
			{
			}

			return;
		}

		/***************************************************************************/
		protected override void EnableDisableControls()
		{
			base.EnableDisableControls();

			/// Shorthand aliases.
			int iSelectedIndex = -1;
			int iItemCount = -1;

			iSelectedIndex = m_wndViewOrderSourceList.SelectedIndex;
			m_wndViewOrderAddButton.IsEnabled = (iSelectedIndex != -1);

			iSelectedIndex = m_wndViewOrderDestinationList.SelectedIndex;
			iItemCount = m_wndViewOrderDestinationList.Items.Count;
			m_wndViewOrderRemoveButton.IsEnabled = (iSelectedIndex != -1) && (iItemCount > 1);
			m_wndViewOrderMoveUpButton.IsEnabled = (iSelectedIndex > 0);
			m_wndViewOrderMoveDownButton.IsEnabled = (0 <= iSelectedIndex) && (iSelectedIndex < (iItemCount - 1));

			return;
		}

		private void m_wndViewOrderSourceList_SelectionChanged(object sender, SelectionChangedEventArgs e)
		{
			EnableDisableControls();
			return;
		}

		private void m_wndViewOrderDestinationList_SelectionChanged(object sender, SelectionChangedEventArgs e)
		{
			EnableDisableControls();
			return;
		}

		private void m_wndSortSourceList_SelectionChanged(object sender, SelectionChangedEventArgs e)
		{
			EnableDisableControls();
			return;
		}

		private void m_wndSortDestinationList_SelectionChanged(object sender, SelectionChangedEventArgs e)
		{
			EnableDisableControls();
			return;
		}

		private void m_wndViewOrderAddButton_Click(object sender, RoutedEventArgs e)
		{
			SimpleColumnDesc ThisListItem = m_aShowColumnSourceList[m_wndViewOrderSourceList.SelectedIndex];
			m_aShowColumnSourceList.RemoveAt(m_wndViewOrderSourceList.SelectedIndex);
			m_aShowColumnDestinationList.Add(ThisListItem);
			return;
		}

		private void m_wndViewOrderRemoveButton_Click(object sender, RoutedEventArgs e)
		{
			SimpleColumnDesc ThisListItem = m_aShowColumnDestinationList[m_wndViewOrderDestinationList.SelectedIndex];
			m_aShowColumnDestinationList.RemoveAt(m_wndViewOrderDestinationList.SelectedIndex);
			m_aShowColumnSourceList.Add(ThisListItem);
			return;
		}

		private void m_wndViewOrderMoveUpButton_Click(object sender, RoutedEventArgs e)
		{
			int iSelectedIndex = m_wndViewOrderDestinationList.SelectedIndex;
			SimpleColumnDesc ThisListItem = m_aShowColumnDestinationList[iSelectedIndex];
			m_aShowColumnDestinationList.RemoveAt(iSelectedIndex);
			m_aShowColumnDestinationList.Insert(iSelectedIndex - 1, ThisListItem);
			m_wndViewOrderDestinationList.SelectedIndex = iSelectedIndex - 1;
			m_wndViewOrderDestinationList.Focus(); /// Doesn't focus the item the way a mouse click does, though.
			return;
		}

		private void m_wndViewOrderMoveDownButton_Click(object sender, RoutedEventArgs e)
		{
			int iSelectedIndex = m_wndViewOrderDestinationList.SelectedIndex;
			SimpleColumnDesc ThisListItem = m_aShowColumnDestinationList[iSelectedIndex];
			m_aShowColumnDestinationList.RemoveAt(iSelectedIndex);
			m_aShowColumnDestinationList.Insert(iSelectedIndex + 1, ThisListItem);
			m_wndViewOrderDestinationList.SelectedIndex = iSelectedIndex + 1;
			m_wndViewOrderDestinationList.Focus(); /// Doesn't focus the item the way a mouse click does, though.
		}
	}
}
