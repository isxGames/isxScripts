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
	/// Interaction logic for PersistentDetailedListView_ColumnSelectionWindow.xaml
	/// </summary>
	public partial class PersistentDetailedListView_ColumnSelectionWindow : CustomBaseWindow
	{
		public PersistentDetailedListView_ColumnSelectionWindow()
		{
			InitializeComponent();
			return;
		}

		private void OnCancelButtonClick(object sender, RoutedEventArgs e)
		{
			Close();
			return;
		}
	}
}
