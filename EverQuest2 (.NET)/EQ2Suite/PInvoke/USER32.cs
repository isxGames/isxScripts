using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;

namespace PInvoke
{
	public static class USER32
	{
		[Flags]
		public enum SetWindowPosFlags : uint
		{
			NoSize = 0x1,
			NoMove = 0x2,
			NoZOrder = 0x4,
			FrameChanged = 0x20,
		}

		[DllImport("user32.dll")]
		public static extern bool SetWindowPos(IntPtr hwnd, IntPtr hwndInsertAfter, int x, int y, int width, int height, SetWindowPosFlags flags);

		public const int WM_SETICON = 0x0080;
		public const int WM_DWMCOMPOSITIONCHANGED = 0x031E;
		public const int WM_USER = 0x0400;

		[DllImport("user32.dll")]
		public static extern IntPtr SendMessage(IntPtr hwnd, uint msg, IntPtr wParam, IntPtr lParam);

		[Flags]
		public enum WindowStyles : uint
		{
			MaximizeBox = 0x10000,
			MinimizeBox = 0x20000,
			SystemMenu = 0x80000,
		}

		[Flags]
		public enum WindowStylesEx
		{
			DialogModalFrame = 0x1, //WS_EX_DLGMODALFRAME
		}

		public const int GWL_STYLE = -16;
		public const int GWL_EXSTYLE = -20;

		[DllImport("user32.dll")]
		public static extern int GetWindowLong(IntPtr hwnd, int index);

		[DllImport("user32.dll")]
		public static extern int SetWindowLong(IntPtr hwnd, int index, int newStyle);
	}
}
