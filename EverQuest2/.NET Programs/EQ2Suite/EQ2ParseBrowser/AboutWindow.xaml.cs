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
	/// Interaction logic for AboutWindow.xaml
	/// </summary>
	public partial class AboutWindow : CustomBaseWindow
	{
		public AboutWindow() : base(App.s_AboutWindowLocation)
		{
			InitializeComponent();

			ShowSystemMenu = false;
			return;
		}

		private void m_wndOkButton_Click(object sender, RoutedEventArgs e)
		{
			Close();
			return;
		}
	}
}
