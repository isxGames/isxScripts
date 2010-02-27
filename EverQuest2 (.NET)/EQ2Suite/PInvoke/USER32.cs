using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;

namespace PInvoke
{
	public static class USER32
	{
		[DllImport("user32.dll")]
		public static extern int GetWindowLong(IntPtr hwnd, int index);

		[DllImport("user32.dll")]
		public static extern int SetWindowLong(IntPtr hwnd, int index, int newStyle);

		[DllImport("user32.dll")]
		public static extern bool SetWindowPos(IntPtr hwnd, IntPtr hwndInsertAfter, int x, int y, int width, int height, uint flags);

		[DllImport("user32.dll")]
		public static extern IntPtr SendMessage(IntPtr hwnd, uint msg, IntPtr wParam, IntPtr lParam);

		public const int GWL_EXSTYLE = -20;
		public const int WS_EX_DLGMODALFRAME = 0x0001;

		public const int SWP_NOSIZE = 0x0001;
		public const int SWP_NOMOVE = 0x0002;
		public const int SWP_NOZORDER = 0x0004;
		public const int SWP_FRAMECHANGED = 0x0020;

		public const int WM_SETICON = 0x0080;
		public const int WM_DWMCOMPOSITIONCHANGED = 0x031E;
		public const int WM_USER = 0x0400;

	}
}
