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
using PInvoke;
using System.Runtime.InteropServices;
using System.Windows.Interop;

namespace EQ2ParseBrowser
{
	/// <summary>
	/// Interaction logic for Window1.xaml
	/// </summary>
	public partial class MainWindow : CustomBaseWindow
	{
		public AboutWindow m_wndAboutWindow = null;
		public ScaleInterfaceWindow m_wndScaleInterfaceWindow = null;

		/***************************************************************************/
		public MainWindow()
			: base(App.s_MainWindowLocation)
		{
			InitializeComponent();
			ShowSystemMenu = true;

			return;
		}

		/***************************************************************************/
		protected override void OnSourceInitialized(EventArgs e)
		{
			base.OnSourceInitialized(e);

			//COMCTL32.TaskDialog(this, "asdf", "fdas", "11223344", COMCTL32.TaskDialogButtons.Cancel, COMCTL32.TaskDialogIcon.Error);
			//*
			COMCTL32.TASKDIALOGCONFIG ThisConfig = new COMCTL32.TASKDIALOGCONFIG();
			ThisConfig.hwndParent = new WindowInteropHelper(this).Handle;
			ThisConfig.pszWindowTitle = "Demonstration";
			ThisConfig.pszMainInstruction = "Click on something before you get slapped.";
			ThisConfig.pszFooter = "You can find more out by visiting <a>EQ2Flames.com</a>.";
			ThisConfig.pszContent = "If you click on something, evidence indicates that you will be less retarded than ever.";
			ThisConfig.MainIcon.hMainIcon = (int)COMCTL32.TaskDialogIcon.Information;
			ThisConfig.FooterIcon.hMainIcon = (int)COMCTL32.TaskDialogIcon.Shield;
			ThisConfig.dwCommonButtons = COMCTL32.TaskDialogButtons.Ok | COMCTL32.TaskDialogButtons.No;
			ThisConfig.dwFlags = COMCTL32.TaskDialogFlags.AllowDialogCancellation | COMCTL32.TaskDialogFlags.EnableHyperlinks;
			ThisConfig.nDefaultButton = (int)COMCTL32.TaskDialogResult.No;
			ThisConfig.pfCallback =
				delegate(IntPtr hwnd, COMCTL32.TaskDialogNotifications msg, IntPtr wParam, IntPtr lParam, IntPtr lpRefData)
				{
					Console.WriteLine(this.Title);
					Console.WriteLine("hwnd: {0}, msg: {1}, wParam: {2}, lParam: {3}, lpRefData: {4}", hwnd, msg, wParam, lParam, lpRefData);
					return HRESULT.S_OK;
				};

			int iButton = 0;
			int iRadioButton = 0;
			bool bVerificationFlagChecked = false;

			HRESULT hResult = COMCTL32.TaskDialogIndirect(ThisConfig, out iButton, out iRadioButton, out bVerificationFlagChecked);
			//*/
			return;
		}

		/***************************************************************************/
		private void FileExitMenuItem_Click(object sender, RoutedEventArgs e)
		{
			Close();
			return;
		}

		/***************************************************************************/
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

		/***************************************************************************/
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
