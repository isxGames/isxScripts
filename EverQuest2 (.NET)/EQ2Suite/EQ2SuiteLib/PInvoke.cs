using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;

namespace EQ2SuiteLib
{
	public static class PInvoke
	{
		[DllImport("kernel32.dll")]
		static extern bool SetProcessAffinityMask(IntPtr hProcess, UIntPtr dwProcessAffinityMask);

		[DllImport("kernel32.dll")]
		static extern UIntPtr SetThreadAffinityMask(IntPtr hThread, UIntPtr dwThreadAffinityMask);
	}
}
