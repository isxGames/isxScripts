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
using EQ2SuiteLib;

namespace EQ2ParseBrowser
{
	/// <summary>
	/// Interaction logic for LogSourceManagerWindow.xaml
	/// </summary>
	public partial class LogSourceManagerWindow : CustomBaseWindow
	{
		public LogSourceManagerWindow()
			: base(App.s_LogSourceManagerWindowLocation)
		{
			InitializeComponent();
			return;
		}

		private void OnCloseButtonClick(object sender, RoutedEventArgs e)
		{
			Close();
			return;
		}
	}
}
