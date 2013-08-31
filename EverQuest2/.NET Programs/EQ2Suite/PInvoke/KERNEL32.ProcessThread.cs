using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;

namespace PInvoke
{
	public static partial class KERNEL32
	{
		//inner enum used only internally
		[Flags]
		public enum SnapshotFlags : uint
		{
			HeapList = 0x00000001,
			Process = 0x00000002,
			Thread = 0x00000004,
			Module = 0x00000008,
			Module32 = 0x00000010,
			Inherit = 0x80000000,
			All = 0x0000001F
		}

		[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
		public class PROCESSENTRY32
		{
			public UInt32 dwSize;
			public UInt32 cntUsage;
			public UInt32 th32ProcessID;
			public IntPtr th32DefaultHeapID;
			public UInt32 th32ModuleID;
			public UInt32 cntThreads;
			public UInt32 th32ParentProcessID;
			public Int32 pcPriClassBase;
			public UInt32 dwFlags;
			[MarshalAs(UnmanagedType.ByValTStr, SizeConst = MAX_PATH)]
			public string szExeFile;
		}

		[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
		public struct THREADENTRY32
		{
			public UInt32 dwSize;
			public UInt32 cntUsage;
			public UInt32 th32ThreadID;
			public UInt32 th32OwnerProcessID;
			public Int32 tpBasePri;
			public Int32 tpDeltaPri;
			public UInt32 dwFlags;
		}

		[Flags]
		public enum ThreadAccess : int
		{
			Terminate = (0x0001),
			SuspendResume = (0x0002),
			GetContext = (0x0008),
			SetContext = (0x0010),
			SetInformation = (0x0020),
			QueryInformation = (0x0040),
			SetThreadToken = (0x0080),
			Impersonate = (0x0100),
			DirectImpersonation = (0x0200)
		}

		[Flags]
		public enum ProcessAccess : int
		{
			/// <summary>Specifies all possible access flags for the process object.</summary>
			AllAccess = CreateThread | DuplicateHandle | QueryInformation | SetInformation | Terminate | VMOperation | VMRead | VMWrite | Synchronize,
			/// <summary>Enables usage of the process handle in the CreateRemoteThread function to create a thread in the process.</summary>
			CreateThread = 0x2,
			/// <summary>Enables usage of the process handle as either the source or target process in the DuplicateHandle function to duplicate a handle.</summary>
			DuplicateHandle = 0x40,
			/// <summary>Enables usage of the process handle in the GetExitCodeProcess and GetPriorityClass functions to read information from the process object.</summary>
			QueryInformation = 0x400,
			/// <summary>Enables usage of the process handle in the SetPriorityClass function to set the priority class of the process.</summary>
			SetInformation = 0x200,
			/// <summary>Enables usage of the process handle in the TerminateProcess function to terminate the process.</summary>
			Terminate = 0x1,
			/// <summary>Enables usage of the process handle in the VirtualProtectEx and WriteProcessMemory functions to modify the virtual memory of the process.</summary>
			VMOperation = 0x8,
			/// <summary>Enables usage of the process handle in the ReadProcessMemory function to' read from the virtual memory of the process.</summary>
			VMRead = 0x10,
			/// <summary>Enables usage of the process handle in the WriteProcessMemory function to write to the virtual memory of the process.</summary>
			VMWrite = 0x20,
			/// <summary>Enables usage of the process handle in any of the wait functions to wait for the process to terminate.</summary>
			Synchronize = 0x100000
		}

		[DllImport("kernel32", SetLastError = true, CharSet = CharSet.Auto)]
		public static extern IntPtr OpenThread(ThreadAccess dwDesiredAccess, bool bInheritHandle, uint dwThreadId);

		[DllImport("kernel32", SetLastError = true, CharSet = CharSet.Auto)]
		public static extern IntPtr OpenProcess(ProcessAccess dwDesiredAccess, bool bInheritHandle, uint dwProcessId);

		[DllImport("kernel32", SetLastError = true, CharSet = CharSet.Auto)]
		public static extern IntPtr CreateToolhelp32Snapshot([In]SnapshotFlags dwFlags, [In]UInt32 th32ProcessID);

		[DllImport("kernel32", SetLastError = true, CharSet = CharSet.Auto)]
		public static extern bool Process32First([In]IntPtr hSnapshot, ref PROCESSENTRY32 lppe);

		[DllImport("kernel32", SetLastError = true, CharSet = CharSet.Auto)]
		public static extern bool Process32Next([In]IntPtr hSnapshot, ref PROCESSENTRY32 lppe);

		[DllImport("kernel32", SetLastError = true, CharSet = CharSet.Auto)]
		public static extern bool Thread32First([In]IntPtr hSnapshot, ref THREADENTRY32 lpte);

		[DllImport("kernel32", SetLastError = true, CharSet = CharSet.Auto)]
		public static extern bool Thread32Next([In]IntPtr hSnapshot, ref THREADENTRY32 lpte);

		[DllImport("kernel32", SetLastError = true)]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool CloseHandle([In] IntPtr hObject);

		[DllImport("kernel32", SetLastError = true, CharSet = CharSet.Auto)]
		public static extern bool SetProcessAffinityMask(IntPtr hProcess, UIntPtr dwProcessAffinityMask);

		[DllImport("kernel32.dll", SetLastError = true)]
		public static extern bool GetProcessAffinityMask(IntPtr hProcess, out UIntPtr lpProcessAffinityMask, out UIntPtr lpSystemAffinityMask);

		[DllImport("kernel32", SetLastError = true, CharSet = CharSet.Auto)]
		public static extern UIntPtr SetThreadAffinityMask(IntPtr hThread, UIntPtr dwThreadAffinityMask);

		[DllImport("kernel32", SetLastError = true, CharSet = CharSet.Auto)]
		public static extern uint GetCurrentProcessId();

		/************************************************************************************/
		public static IEnumerable<THREADENTRY32> EnumProcessThreads(UInt32 uiProcessID)
		{
			IntPtr hSnapshot = IntPtr.Zero;

			try
			{
				hSnapshot = CreateToolhelp32Snapshot(SnapshotFlags.Thread, uiProcessID);
				if (hSnapshot == INVALID_HANDLE_VALUE)
					yield break;

				THREADENTRY32 ThreadInfo = new THREADENTRY32();
				ThreadInfo.dwSize = (uint)Marshal.SizeOf(typeof(THREADENTRY32));
				if (!Thread32First(hSnapshot, ref ThreadInfo))
					yield break;

				do
				{
					if (ThreadInfo.th32OwnerProcessID == uiProcessID)
						yield return ThreadInfo;

					ThreadInfo = new THREADENTRY32();
					ThreadInfo.dwSize = (uint)Marshal.SizeOf(typeof(THREADENTRY32));
				}
				while (Thread32Next(hSnapshot, ref ThreadInfo));
			}
			finally
			{
				if (hSnapshot != IntPtr.Zero)
					CloseHandle(hSnapshot);
			}
		}
	}
}
