using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Interop;

namespace PInvoke
{
	public static partial class COMCTL32
	{
		public enum TaskDialogResult : int
		{
			Ok = 1,
			Cancel = 2,
			Abort = 3,
			Retry = 4,
			Ignore = 5,
			Yes = 6,
			No = 7,
			Close = 8,
		}

		[Flags]
		public enum TaskDialogButtons : int
		{
			Ok = 0x0001,
			Yes = 0x0002,
			No = 0x0004,
			Cancel = 0x0008,
			Retry = 0x0010,
			Close = 0x0020,
		}

		public enum TaskDialogIcon
		{
			Warning = 65535,
			Error = 65534,
			Information = 65533,
			Shield = 65532,
		}

		/// <summary>
		/// This is an enhanced MessageBox found only in Windows Vista or later.
		/// http://msdn.microsoft.com/en-us/library/bb760540(VS.85).aspx
		/// </summary>
		[DllImport("comctl32.dll", PreserveSig = false, CharSet = CharSet.Unicode, EntryPoint="TaskDialog")]
		public static extern HRESULT TaskDialog(
			IntPtr hParentWindow,
			IntPtr hInstance,
			string strTitle,
			string strMainInstruction,
			string strContent,
			TaskDialogButtons eButtons,
			TaskDialogIcon eIcon,
			ref int iResult);

		/// <summary>
		/// More comprehensive wrapper function.
		/// </summary>
		public static TaskDialogResult TaskDialog(
			Window ParentWindow,
			string strTitle,
			string strMainInstruction,
			string strContent,
			TaskDialogButtons eButtons,
			TaskDialogIcon eIcon)
		{
			int iDialogResult = 0;
			IntPtr hwnd = new WindowInteropHelper(ParentWindow).Handle;

			HRESULT hResult = TaskDialog(hwnd, IntPtr.Zero, strTitle, strMainInstruction, strContent, eButtons, eIcon, ref iDialogResult);
			if ((int)hResult < 0) // >= 0 means HRESULT success
				throw new COMException("TaskDialog() failed.", (int)hResult);
			return (TaskDialogResult)iDialogResult;
		}

		[Flags]
		public enum TaskDialogFlags : int
		{
			None = 0,
			EnableHyperlinks = 0x0001,
			UseHIconMain = 0x0002,
			UseHIconFooter = 0x0004,
			AllowDialogCancellation = 0x0008,
			UseCommandLinks = 0x0010,
			UseCommandLinksNoIcon = 0x0020,
			ExpandFooterArea = 0x0040,
			ExpandedByDefault = 0x0080,
			VerificationFlagChecked = 0x0100,
			ShowProgressBar = 0x0200,
			ShowMarqueeProgressBar = 0x0400,
			CallbackTimer = 0x0800,
			PositionRelativeToWindow = 0x1000,
			RightToLeftLayout = 0x2000,
			NoDefaultRadioButton = 0x4000
		}

		// NOTE: We include a "spacer" so that the struct size varies on 
		// 64-bit architectures.
		[StructLayout(LayoutKind.Explicit, CharSet = CharSet.Auto)]
		public struct TASKDIALOGCONFIG_ICON_UNION
		{
			public TASKDIALOGCONFIG_ICON_UNION(int i)
			{
				spacer = IntPtr.Zero;
				pszIcon = 0;
				hMainIcon = i;
			}

			[FieldOffset(0)]
			public int hMainIcon;
			[FieldOffset(0)]
			public int pszIcon;
			[FieldOffset(0)]
			public IntPtr spacer;
		}

		// NOTE: Packing must be set to 4 to make this work on 64-bit platforms.
		[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto, Pack = 4)]
		public struct TASKDIALOG_BUTTON
		{
			public TASKDIALOG_BUTTON(int n, string txt)
			{
				nButtonID = n;
				pszButtonText = txt;
			}

			public int nButtonID;
			[MarshalAs(UnmanagedType.LPWStr)]
			public string pszButtonText;
		}

		/// <summary>
		// Main task dialog configuration struct.
		// NOTE: Packing must be set to 4 to make this work on 64-bit platforms.
		/// ms-help://MS.VSCC.v90/MS.MSDNQTR.v90.en/shellcc/platform/commctls/taskdialogs/taskdialogreference/taskdialogstructures/taskdialogconfig.htm
		/// </summary>
		[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto, Pack = 4)]
		public class TASKDIALOGCONFIG
		{
			protected uint cbSize; /// No need to expose this constant.
			public IntPtr hwndParent = IntPtr.Zero;
			protected IntPtr hInstance = IntPtr.Zero; /// Useless in .NET.
			public TaskDialogFlags dwFlags = TaskDialogFlags.None;
			public TaskDialogButtons dwCommonButtons = 0;
			[MarshalAs(UnmanagedType.LPWStr)]
			public string pszWindowTitle;
			public TASKDIALOGCONFIG_ICON_UNION MainIcon; // NOTE: 32-bit union field, holds pszMainIcon as well
			[MarshalAs(UnmanagedType.LPWStr)]
			public string pszMainInstruction;
			[MarshalAs(UnmanagedType.LPWStr)]
			public string pszContent;
			public uint cButtons;
			public IntPtr pButtons;           // Ptr to TASKDIALOG_BUTTON structs
			public int nDefaultButton;
			public uint cRadioButtons;
			public IntPtr pRadioButtons;      // Ptr to TASKDIALOG_BUTTON structs
			public int nDefaultRadioButton;
			[MarshalAs(UnmanagedType.LPWStr)]
			public string pszVerificationText;
			[MarshalAs(UnmanagedType.LPWStr)]
			public string pszExpandedInformation;
			[MarshalAs(UnmanagedType.LPWStr)]
			public string pszExpandedControlText;
			[MarshalAs(UnmanagedType.LPWStr)]
			public string pszCollapsedControlText;
			public TASKDIALOGCONFIG_ICON_UNION FooterIcon;  // NOTE: 32-bit union field, holds pszFooterIcon as well
			[MarshalAs(UnmanagedType.LPWStr)]
			public string pszFooter;
			public TaskDialogCallbackDelegate pfCallback;
			public IntPtr lpCallbackData;
			public uint cxWidth;

			public TASKDIALOGCONFIG()
			{
				cbSize = (uint)Marshal.SizeOf(typeof(COMCTL32.TASKDIALOGCONFIG));
				return;
			}
		}

		public const int TASKDIALOG_IDEALWIDTH = 0;  // Value for TASKDIALOGCONFIG.cxWidth
		public const int TASKDIALOG_BUTTON_SHIELD_ICON = 1;

		public enum TaskDialogElements : int
		{
			Content,
			ExpandedInformation,
			Footer,
			MainInstruction,
		}

		public enum TaskDialogIconElement : int
		{
			Main,
			Footer,
		}

		public enum TaskDialogMessages : int
		{
			TDM_NAVIGATE_PAGE = USER32.WM_USER + 101,
			TDM_CLICK_BUTTON = USER32.WM_USER + 102, // wParam = Button ID
			TDM_SET_MARQUEE_PROGRESS_BAR = USER32.WM_USER + 103, // wParam = 0 (nonMarque) wParam != 0 (Marquee)
			TDM_SET_PROGRESS_BAR_STATE = USER32.WM_USER + 104, // wParam = new progress state
			TDM_SET_PROGRESS_BAR_RANGE = USER32.WM_USER + 105, // lParam = MAKELPARAM(nMinRange, nMaxRange)
			TDM_SET_PROGRESS_BAR_POS = USER32.WM_USER + 106, // wParam = new position
			TDM_SET_PROGRESS_BAR_MARQUEE = USER32.WM_USER + 107, // wParam = 0 (stop marquee), wParam != 0 (start marquee), lparam = speed (milliseconds between repaints)
			TDM_SET_ELEMENT_TEXT = USER32.WM_USER + 108, // wParam = element (TaskDialogElements), lParam = new element text (LPCWSTR)
			TDM_CLICK_RADIO_BUTTON = USER32.WM_USER + 110, // wParam = Radio Button ID
			TDM_ENABLE_BUTTON = USER32.WM_USER + 111, // lParam = 0 (disable), lParam != 0 (enable), wParam = Button ID
			TDM_ENABLE_RADIO_BUTTON = USER32.WM_USER + 112, // lParam = 0 (disable), lParam != 0 (enable), wParam = Radio Button ID
			TDM_CLICK_VERIFICATION = USER32.WM_USER + 113, // wParam = 0 (unchecked), 1 (checked), lParam = 1 (set key focus)
			TDM_UPDATE_ELEMENT_TEXT = USER32.WM_USER + 114, // wParam = element (TaskDialogElements), lParam = new element text (LPCWSTR)
			TDM_SET_BUTTON_ELEVATION_REQUIRED_STATE = USER32.WM_USER + 115, // wParam = Button ID, lParam = 0 (elevation not required), lParam != 0 (elevation required)
			TDM_UPDATE_ICON = USER32.WM_USER + 116  // wParam = icon element (TaskDialogIconElement), lParam = new icon (hIcon if TDF_USE_HICON_* was set, PCWSTR otherwise)
		}

		// Used in the various SET_DEFAULT* TaskDialog messages
		public const int NO_DEFAULT_BUTTON_SPECIFIED = 0;

		public enum TaskDialogNotifications : uint
		{
			Created = 0,
			Navigated = 1,
			ButtonClicked = 2,            // wParam = Button ID
			HyperlinkClicked = 3,         // lParam = (LPCWSTR)pszHREF
			Timer = 4,                     // wParam = Milliseconds since dialog created or timer reset
			Destroyed = 5,
			RadioButtonClicked = 6,      // wParam = Radio Button ID
			DialogConstructed = 7,
			VerificationClicked = 8,      // wParam = 1 if checkbox checked, 0 if not, lParam is unused and always 0
			Help = 9,
			ExpandoButtonClicked = 10    // wParam = 0 (dialog is now collapsed), wParam != 0 (dialog is now expanded)
		}

		// Task Dialog config and related structs (for TaskDialogIndirect())
		public delegate HRESULT TaskDialogCallbackDelegate(
			IntPtr hwnd,
			TaskDialogNotifications uNotification,
			IntPtr wParam,
			IntPtr lParam,
			IntPtr lpRefData);

		public enum PBST
		{
			PBST_NORMAL = 0x0001,
			PBST_ERROR = 0x0002,
			PBST_PAUSED = 0x0003
		}

		[DllImport("comctl32.dll", CharSet = CharSet.Auto, SetLastError = true)]
		public static extern HRESULT TaskDialogIndirect(
			 [In] TASKDIALOGCONFIG pTaskConfig,
			 [Out] out int pnButton,
			 [Out] out int pnRadioButton,
			 [MarshalAs(UnmanagedType.Bool)][Out] out bool pVerificationFlagChecked);

	}
}
