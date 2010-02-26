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
using EQ2SuiteLib;

namespace EQ2ParseBrowser
{
	/// <summary>
	/// Interaction logic for Window1.xaml
	/// </summary>
	public partial class MainWindow : CustomBaseWindow
	{
		public AboutWindow m_wndAboutWindow = null;
		public ScaleInterfaceWindow m_wndScaleInterfaceWindow = null;

		public MainWindow() : base(App.s_MainWindowLocation)
		{
			InitializeComponent();
			ShowSystemMenu = true;
			return;
		}

		protected override void OnInitialized(EventArgs e)
		{
			base.OnInitialized(e);
			return;
		}

		private void FileExitMenuItem_Click(object sender, RoutedEventArgs e)
		{
			Close();
			return;
		}

		private void ToolsScaleContentsMenuItem_Click(object sender, RoutedEventArgs e)
		{
			if (m_wndScaleInterfaceWindow != null)
				m_wndScaleInterfaceWindow.Activate();
			else
			{
				m_wndScaleInterfaceWindow = new ScaleInterfaceWindow();
				m_wndScaleInterfaceWindow.Closed +=
					delegate(object sender2, EventArgs e2)
					{
						m_wndScaleInterfaceWindow = null;
						return;
					};
				m_wndScaleInterfaceWindow.Owner = this;
				m_wndScaleInterfaceWindow.Scale = App.s_fInterfaceScaleFactor;
				m_wndScaleInterfaceWindow.Show();
			}

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
				m_wndAboutWindow.Scale = App.s_fInterfaceScaleFactor;
				m_wndAboutWindow.Show();
			}

			return;
		}

	}
}
