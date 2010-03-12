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

		public class ColumnSortDesc : SimpleColumnDesc
		{
			public ColumnSortDesc(string strTag, object objContent, bool bSortAscending)
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

		protected List<SimpleColumnDesc> m_aShowColumnSourceList = new List<SimpleColumnDesc>();
		protected List<SimpleColumnDesc> m_aShowColumnDestinationList = new List<SimpleColumnDesc>();
		protected List<SimpleColumnDesc> m_aSortColumnSourceList = new List<SimpleColumnDesc>();
		protected List<ColumnSortDesc> m_aSortColumnDestinationList = new List<ColumnSortDesc>();

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
					m_aSortColumnDestinationList.Add(new ColumnSortDesc(ThisDesc.m_strTag, objContent, ThisDesc.m_bSortAscending));
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
			Close();
			return;
		}

		/***************************************************************************/
		private void OnCancelButtonClick(object sender, RoutedEventArgs e)
		{
			ModelessDialogResult = false;
			Close();
			return;
		}

		/***************************************************************************/
		protected override void OnClosed(EventArgs e)
		{
			try
			{
				base.OnClosed(e);
			}
			catch
			{
			}

			return;
		}
	}
}
