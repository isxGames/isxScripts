using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Windows;
using PInvoke;
using System.Windows.Interop;

namespace EQ2ParseBrowser
{
	/// <summary>
	/// Interaction logic for App.xaml
	/// </summary>
	public partial class App : Application
	{
		public static void RemoveSystemMenu(Window wndWindow)
		{
			// Get this window's handle
			IntPtr hwnd = new WindowInteropHelper(wndWindow).Handle;

			int iExtendedStyle = USER32.GetWindowLong(hwnd, USER32.GWL_EXSTYLE);
			USER32.SetWindowLong(hwnd, USER32.GWL_EXSTYLE, iExtendedStyle | USER32.WS_EX_DLGMODALFRAME);

			// Update the window's non-client area to reflect the changes
			USER32.SetWindowPos(hwnd, IntPtr.Zero, 0, 0, 0, 0, USER32.SWP_NOMOVE | USER32.SWP_NOSIZE | USER32.SWP_NOZORDER | USER32.SWP_FRAMECHANGED);
			return;
		}
	}
}
