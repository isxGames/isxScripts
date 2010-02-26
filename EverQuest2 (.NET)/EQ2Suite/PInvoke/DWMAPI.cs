using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Interop;
using System.Windows.Media;

namespace PInvoke
{
	public static class DWMAPI
	{
		[StructLayout(LayoutKind.Sequential)]
		public struct MARGINS
		{
			public int Left;
			public int Right;
			public int Top;
			public int Bottom;

			public MARGINS(Thickness t)
			{
				Left = (int)t.Left;
				Right = (int)t.Right;
				Top = (int)t.Top;
				Bottom = (int)t.Bottom;
				return;
			}
		}

		[DllImport("dwmapi.dll", PreserveSig = false)]
		public static extern void DwmExtendFrameIntoClientArea(IntPtr hWindow, ref MARGINS pMarInset);

		/// <summary>
		/// Actually returns HRESULT and accepts pointer to bool in parameter.
		/// </summary>
		/// <returns></returns>
		[DllImport("dwmapi.dll", PreserveSig = false)]
		public static extern bool DwmIsCompositionEnabled();

		/// <summary>
		/// From the book "Windows Presentation Foundation Unleashed".
		/// </summary>
		/// <param name="window"></param>
		/// <param name="margin"></param>
		/// <returns></returns>
		public static bool ExtendGlassFrame(Window ThisWindow, Thickness ThisMargin)
		{
			if (!DwmIsCompositionEnabled())
				return false;

			IntPtr hwnd = new WindowInteropHelper(ThisWindow).Handle;
			if (hwnd == IntPtr.Zero)
				throw new InvalidOperationException("The Window must be shown before extending glass.");

			/// Set the background to transparent from both the WPF and Win32 perspectives.
			ThisWindow.Background = Brushes.Transparent;
			HwndSource.FromHwnd(hwnd).CompositionTarget.BackgroundColor = Colors.Transparent;

			MARGINS margins = new MARGINS(ThisMargin);
			DwmExtendFrameIntoClientArea(hwnd, ref margins);
			return true;
		}
	}
}
