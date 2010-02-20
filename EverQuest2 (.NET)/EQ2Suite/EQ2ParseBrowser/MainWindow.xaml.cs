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
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace EQ2ParseBrowser
{
	/// <summary>
	/// Interaction logic for Window1.xaml
	/// </summary>
	public partial class MainWindow : Window
	{
		public AboutWindow m_wndAboutWindow = null;

		public MainWindow()
		{
			InitializeComponent();
			return;
		}

		private void HelpAboutMenuItem_Click(object sender, RoutedEventArgs e)
		{
			if (m_wndAboutWindow != null)
				m_wndAboutWindow.Activate();
			else
			{
				m_wndAboutWindow = new AboutWindow();
				m_wndAboutWindow.Closed +=
					delegate(object sender2, EventArgs e2)
					{
						m_wndAboutWindow = null;
						return;
					};
				m_wndAboutWindow.Owner = this;
				m_wndAboutWindow.Show();
			}

			return;
		}

	}
}
