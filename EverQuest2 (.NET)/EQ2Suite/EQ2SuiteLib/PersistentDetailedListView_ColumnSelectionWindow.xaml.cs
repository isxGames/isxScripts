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
		public class ShowColumnDesc : NotifyPropertyChangedBase
		{
			public ShowColumnDesc(bool bIsChecked, string strLabel)
			{
				m_bIsChecked = bIsChecked;
				m_strLabel = strLabel;
				return;
			}

			protected bool m_bIsChecked = false;
			public bool IsChecked
			{
				get
				{
					return m_bIsChecked;
				}
				set
				{
					if (m_bIsChecked != value)
					{
						m_bIsChecked = value;
						NotifyPropertyChanged("IsChecked");
					}
					return;
				}
			}

			protected string m_strLabel = string.Empty;
			public string Label
			{
				get
				{
					return m_strLabel;
				}
				set
				{
					if (m_strLabel != value)
					{
						m_strLabel = value;
						NotifyPropertyChanged("Label");
					}
					return;
				}
			}

		}

		protected PersistentDetailedListView.ColumnLayout m_SavedLayout = null;
		protected List<ShowColumnDesc> m_aShowColumnDescList = new List<ShowColumnDesc>();

		/***************************************************************************/
		public PersistentDetailedListView_ColumnSelectionWindow(
			SavedWindowLocation ThisSavedLocation,
			PersistentDetailedListView.ColumnLayout ThisSavedLayout)
			: base(ThisSavedLocation)
		{
			InitializeComponent();

			m_SavedLayout = ThisSavedLayout;

			m_wndShowColumnsListBox.ItemsSource = m_aShowColumnDescList;
			for (int iIndex = 0; iIndex < 1000; iIndex++)
				m_aShowColumnDescList.Add(new ShowColumnDesc(true, Guid.NewGuid().ToString()));
			return;
		}

		/***************************************************************************/
		private void OnCancelButtonClick(object sender, RoutedEventArgs e)
		{
			Close();
			return;
		}
	}
}
