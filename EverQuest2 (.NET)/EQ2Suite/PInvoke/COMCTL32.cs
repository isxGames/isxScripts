using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;

namespace PInvoke
{
	public static class COMCTL32
	{
		public enum TaskDialogResult : int
		{
			Ok = 1,
			Cancel = 2,
			Retry = 4,
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
		/// <param name="hParentWindow"></param>
		/// <param name="hInstance"></param>
		/// <param name="strTitle"></param>
		/// <param name="strMainInstruction"></param>
		/// <param name="strContent"></param>
		/// <param name="eButtons"></param>
		/// <param name="eIcon"></param>
		/// <returns></returns>
		[DllImport("comctl32.dll", PreserveSig = false, CharSet = CharSet.Unicode)]
		public static extern IntPtr TaskDialog(
			IntPtr hParentWindow,
			IntPtr hInstance,
			string strTitle,
			string strMainInstruction,
			string strContent,
			TaskDialogButtons eButtons,
			TaskDialogIcon eIcon,
			ref int iResult);

		/// <summary>
		/// More convenient wrapper function.
		/// </summary>
		/// <param name="hParentWindow"></param>
		/// <param name="strTitle"></param>
		/// <param name="strMainInstruction"></param>
		/// <param name="strContent"></param>
		/// <param name="eButtons"></param>
		/// <param name="eIcon"></param>
		/// <returns></returns>
		public static TaskDialogResult TaskDialog(
			IntPtr hParentWindow,
			string strTitle,
			string strMainInstruction,
			string strContent,
			TaskDialogButtons eButtons,
			TaskDialogIcon eIcon)
		{
			int iDialogResult = 0;
			IntPtr hResult = TaskDialog(hParentWindow, IntPtr.Zero, strTitle, strMainInstruction, strContent, eButtons, eIcon, ref iDialogResult);
			return (TaskDialogResult)iDialogResult;
		}
	}
}
