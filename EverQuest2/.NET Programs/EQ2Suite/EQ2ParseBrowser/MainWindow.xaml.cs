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
		public readonly BoxedScalar<AboutWindow> m_wndAboutWindow = new BoxedScalar<AboutWindow>();
		public readonly BoxedScalar<LogSourceManagerWindow> m_wndLogSourceManagerWindow = new BoxedScalar<LogSourceManagerWindow>();
		public readonly BoxedScalar<ScaleInterfaceWindow> m_wndScaleInterfaceWindow = new BoxedScalar<ScaleInterfaceWindow>();

		/***************************************************************************/
		public MainWindow()
			: base(App.s_MainWindowLocation)
		{
			InitializeComponent();
			ShowSystemMenu = true;
			CloseOnEscape = false;
			return;
		}

		/***************************************************************************/
		protected override void OnSourceInitialized(EventArgs e)
		{
			base.OnSourceInitialized(e);

			//COMCTL32.TaskDialog(this, "asdf", "fdas", "11223344", COMCTL32.TaskDialogButtons.Cancel, COMCTL32.TaskDialogIcon.Error);
			/*
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
			*/
			return;
		}

		/***************************************************************************/
		protected override void OnClosing(System.ComponentModel.CancelEventArgs e)
		{
			base.OnClosing(e);

			try
			{
				/// Give every child popup window a chance to refuse.
				TryCloseSingletonModelessWindow<AboutWindow>(m_wndAboutWindow);
				TryCloseSingletonModelessWindow<LogSourceManagerWindow>(m_wndLogSourceManagerWindow);
				TryCloseSingletonModelessWindow<ScaleInterfaceWindow>(m_wndScaleInterfaceWindow);
			}
			catch
			{
				e.Cancel = true;
			}

			return;
		}

		/***************************************************************************/
		private void OnFileManageLogSourcesMenuItemClick(object sender, RoutedEventArgs e)
		{
			if (CreateSingletonModelessWindow<LogSourceManagerWindow>(m_wndLogSourceManagerWindow))
			{
				m_wndLogSourceManagerWindow.Value.Show();
			}
			return;
		}

		/***************************************************************************/
		private void OnFileCloseMenuItemClick(object sender, RoutedEventArgs e)
		{
			return;
		}

		/***************************************************************************/
		private void OnFileCloseAllMenuItemClick(object sender, RoutedEventArgs e)
		{
			return;
		}

		/***************************************************************************/
		private void OnFileExitMenuItemClick(object sender, RoutedEventArgs e)
		{
			Close();
			return;
		}

		/***************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		/// <typeparam name="T"></typeparam>
		/// <param name="ThisWindowVariable"></param>
		/// <returns>true if the window was newly created and will need to be explicly shown.</returns>
		protected bool CreateSingletonModelessWindow<T>(BoxedScalar<T> ThisWindowVariable) where T : CustomBaseWindow, new()
		{
			if (ThisWindowVariable.Value != null)
			{
				ThisWindowVariable.Value.Activate();

				/// Restore a minimized window.
				if (ThisWindowVariable.Value.WindowState == WindowState.Minimized)
					ThisWindowVariable.Value.WindowState = WindowState.Normal;

				return false;
			}
			else
			{
				ThisWindowVariable.Value = new T();

				/// This event does nothing more than set the variable to null when the window is closed.
				ThisWindowVariable.Value.Closed += (new CloseSingletonModelessWindowEventDesc<T>(ThisWindowVariable)).OnClose;
				
				ThisWindowVariable.Value.Owner = this;
				ThisWindowVariable.Value.Scale = App.s_fInterfaceScaleFactor;
				return true;
			}
		}

		/***************************************************************************/
		private class CloseSingletonModelessWindowEventDesc<T> where T : CustomBaseWindow
		{
			protected BoxedScalar<T> m_wndWindow = null;
			public CloseSingletonModelessWindowEventDesc(BoxedScalar<T> ThisWindow)
			{
				m_wndWindow = ThisWindow;
				return;
			}
			public void OnClose(object sender, EventArgs e)
			{
				m_wndWindow.Value = null;
				return;
			}
		}

		/***************************************************************************/
		/// <summary>
		/// This function throws an exception if the window in question didn't close.
		/// It assumes that the window was created with CreateSingletonModelessWindow<>().
		/// </summary>
		protected void TryCloseSingletonModelessWindow<T>(BoxedScalar<T> ThisWindowVariable) where T : CustomBaseWindow
		{
			if (ThisWindowVariable.Value != null)
			{
				ThisWindowVariable.Value.Activate();
				ThisWindowVariable.Value.Close();

				/// If the window object reference still exists, it means the OnClose event was never called, meaning it never closed.
				/// And that means the window must have refused it.
				if (ThisWindowVariable.Value != null)
					throw new Exception("Window refused to close, either on its own or because of user input.");
			}

			return;
		}

		/***************************************************************************/
		private void OnToolsScaleInterfaceMenuItemClick(object sender, RoutedEventArgs e)
		{
			if (CreateSingletonModelessWindow<ScaleInterfaceWindow>(m_wndScaleInterfaceWindow))
			{
				m_wndScaleInterfaceWindow.Value.Show();
			}
			return;
		}

		/***************************************************************************/
		private void OnHelpAboutMenuItemClick(object sender, RoutedEventArgs e)
		{
			if (CreateSingletonModelessWindow<AboutWindow>(m_wndAboutWindow))
			{
				m_wndAboutWindow.Value.Show();
			}
			return;
		}
	}
}
