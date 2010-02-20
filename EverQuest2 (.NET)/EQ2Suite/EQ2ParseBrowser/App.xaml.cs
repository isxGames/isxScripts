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

			int iExtendedStyle = User32.GetWindowLong(hwnd, User32.GWL_EXSTYLE);
			User32.SetWindowLong(hwnd, User32.GWL_EXSTYLE, iExtendedStyle | User32.WS_EX_DLGMODALFRAME);

			// Update the window's non-client area to reflect the changes
			User32.SetWindowPos(hwnd, IntPtr.Zero, 0, 0, 0, 0, User32.SWP_NOMOVE | User32.SWP_NOSIZE | User32.SWP_NOZORDER | User32.SWP_FRAMECHANGED);
			return;
		}
	}
}
