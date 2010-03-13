using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;

namespace PInvoke
{
	public static class ADVAPI32
	{
		public const int GENERIC_WRITE = 0x40000000;
		public const int DELETE = 0x10000;

		public const int SC_MANAGER_CREATE_SERVICE = 0x0002;
		public const int SERVICE_WIN32_OWN_PROCESS = 0x00000010;
		public const int SERVICE_AUTO_START = 0x00000002;
		public const int SERVICE_DEMAND_START = 0x00000003;
		public const int SERVICE_ERROR_NORMAL = 0x00000001;
		public const int STANDARD_RIGHTS_REQUIRED = 0xF0000;
		public const int SERVICE_QUERY_CONFIG = 0x0001;
		public const int SERVICE_CHANGE_CONFIG = 0x0002;
		public const int SERVICE_QUERY_STATUS = 0x0004;
		public const int SERVICE_ENUMERATE_DEPENDENTS = 0x0008;
		public const int SERVICE_START = 0x0010;
		public const int SERVICE_STOP = 0x0020;
		public const int SERVICE_PAUSE_CONTINUE = 0x0040;
		public const int SERVICE_INTERROGATE = 0x0080;
		public const int SERVICE_USER_DEFINED_CONTROL = 0x0100;
		public const int SERVICE_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED |
			SERVICE_QUERY_CONFIG |
			SERVICE_CHANGE_CONFIG |
			SERVICE_QUERY_STATUS |
			SERVICE_ENUMERATE_DEPENDENTS |
			SERVICE_START |
			SERVICE_STOP |
			SERVICE_PAUSE_CONTINUE |
			SERVICE_INTERROGATE |
			SERVICE_USER_DEFINED_CONTROL);

		public const int SERVICE_CONFIG_DESCRIPTION = 1;
		public const int SERVICE_CONFIG_FAILURE_ACTIONS = 2;
		public const int SERVICE_CONFIG_DELAYED_AUTO_START_INFO = 3;
		public const int SERVICE_CONFIG_FAILURE_ACTIONS_FLAG = 4;
		public const int SERVICE_CONFIG_SERVICE_SID_INFO = 5;
		public const int SERVICE_CONFIG_REQUIRED_PRIVILEGES_INFO = 6;
		public const int SERVICE_CONFIG_PRESHUTDOWN_INFO = 7;

		[Flags]
		public enum SERVICE_TYPES : int
		{
			SERVICE_KERNEL_DRIVER = 0x00000001,
			SERVICE_FILE_SYSTEM_DRIVER = 0x00000002,
			SERVICE_WIN32_OWN_PROCESS = 0x00000010,
			SERVICE_WIN32_SHARE_PROCESS = 0x00000020,
			SERVICE_INTERACTIVE_PROCESS = 0x00000100
		}

		[Flags]
		public enum SERVICE_CONTROL : uint
		{
			STOP = 0x00000001,
			PAUSE = 0x00000002,
			CONTINUE = 0x00000003,
			INTERROGATE = 0x00000004,
			SHUTDOWN = 0x00000005,
			PARAMCHANGE = 0x00000006,
			NETBINDADD = 0x00000007,
			NETBINDREMOVE = 0x00000008,
			NETBINDENABLE = 0x00000009,
			NETBINDDISABLE = 0x0000000A,
			DEVICEEVENT = 0x0000000B,
			HARDWAREPROFILECHANGE = 0x0000000C,
			POWEREVENT = 0x0000000D,
			SESSIONCHANGE = 0x0000000E
		}

		public enum SERVICE_STATE : uint
		{
			SERVICE_STOPPED = 0x00000001,
			SERVICE_START_PENDING = 0x00000002,
			SERVICE_STOP_PENDING = 0x00000003,
			SERVICE_RUNNING = 0x00000004,
			SERVICE_CONTINUE_PENDING = 0x00000005,
			SERVICE_PAUSE_PENDING = 0x00000006,
			SERVICE_PAUSED = 0x00000007
		}

		[Flags]
		public enum SERVICE_ACCEPT : uint
		{
			STOP = 0x00000001,
			PAUSE_CONTINUE = 0x00000002,
			SHUTDOWN = 0x00000004,
			PARAMCHANGE = 0x00000008,
			NETBINDCHANGE = 0x00000010,
			HARDWAREPROFILECHANGE = 0x00000020,
			POWEREVENT = 0x00000040,
			SESSIONCHANGE = 0x00000080,
		}

		public enum SC_ACTION_TYPE : int
		{
			SC_ACTION_NONE = 0,
			SC_ACTION_RESTART = 1,
			SC_ACTION_REBOOT = 2,
			SC_ACTION_RUN_COMMAND = 3,
		}

		[StructLayout(LayoutKind.Sequential, Pack = 1)]
		public struct SERVICE_STATUS
		{
			public static readonly int SizeOf = Marshal.SizeOf(typeof(SERVICE_STATUS));
			public SERVICE_TYPES dwServiceType;
			public SERVICE_STATE dwCurrentState;
			public uint dwControlsAccepted;
			public uint dwWin32ExitCode;
			public uint dwServiceSpecificExitCode;
			public uint dwCheckPoint;
			public uint dwWaitHint;
		}

		[StructLayout(LayoutKind.Sequential)]
		public struct SERVICE_DESCRIPTION
		{
			[MarshalAs(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
			public String lpDescription;
		}

		[StructLayout(LayoutKind.Sequential)]
		public struct SERVICE_FAILURE_ACTIONS
		{
			public uint dwResetPeriod;
			[MarshalAs(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
			public string lpRebootMsg;
			[MarshalAs(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
			public string lpCommand;
			public uint cActions;
			public IntPtr lpsaActions;
		}

		[StructLayout(LayoutKind.Sequential)]
		public struct SC_ACTION
		{
			public SC_ACTION_TYPE Type;
			public uint Delay;
		}

		[DllImport("advapi32.dll", SetLastError = true)]
		public static extern IntPtr OpenSCManager(string lpMachineName, string lpSCDB, int scParameter);

		[DllImport("advapi32.dll", SetLastError = true)]
		public static extern IntPtr CreateService(IntPtr SC_HANDLE, string lpSvcName, string lpDisplayName,
		int dwDesiredAccess, int dwServiceType, int dwStartType, int dwErrorControl, string lpPathName,
		string lpLoadOrderGroup, int lpdwTagId, string lpDependencies, string lpServiceStartName, string lpPassword);

		[DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Auto)]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool ChangeServiceConfig2(IntPtr hService, int dwInfoLevel, IntPtr lpInfo);

		[DllImport("advapi32.dll")]
		public static extern void CloseServiceHandle(IntPtr SC_HANDLE);

		[DllImport("advapi32.dll", SetLastError = true)]
		public static extern bool StartService(IntPtr hService, int dwNumServiceArgs, string lpServiceArgVectors);

		[DllImport("advapi32.dll", SetLastError = true)]
		public static extern IntPtr OpenService(IntPtr SC_HANDLE, string lpSvcName, int dwNumServiceArgs);

		[DllImport("advapi32.dll", SetLastError = true)]
		public static extern bool DeleteService(IntPtr SVHANDLE);

		[DllImport("advapi32.dll", SetLastError = true)]
		public static extern bool SetServiceStatus(IntPtr hServiceStatus, ref SERVICE_STATUS lpServiceStatus);

		/***************************************************************************/
		public static void DeleteService(string strServiceName)
		{
			IntPtr hServiceControlManager = IntPtr.Zero;
			IntPtr hService = IntPtr.Zero;

			try
			{
				hServiceControlManager =  OpenSCManager(null, null, GENERIC_WRITE);
				if (hServiceControlManager == IntPtr.Zero)
					throw new Exception("Unable to open the service controller.");

				hService = OpenService(hServiceControlManager, strServiceName, DELETE);
				if (hService == IntPtr.Zero)
					throw new Exception("Unable to open the service to perform deletion.");

				if (!DeleteService(hService))
					throw new Exception("Unable to delete the service.");
			}
			finally
			{
				if (hService != IntPtr.Zero)
					CloseServiceHandle(hService);

				if (hServiceControlManager != IntPtr.Zero)
					CloseServiceHandle(hServiceControlManager);
			}
			return;
		}

		/***************************************************************************/
		public static void SetServiceDescription(IntPtr hService, string strDescription)
		{
			IntPtr pNewDescriptionBuffer = IntPtr.Zero;
			try
			{
				/// Now set the description for the service.
				SERVICE_DESCRIPTION NewDescription = new SERVICE_DESCRIPTION();
				NewDescription.lpDescription = strDescription;

				pNewDescriptionBuffer = PInvokeHelper.AllocHGlobalFromStruct<SERVICE_DESCRIPTION>(NewDescription);
				if (pNewDescriptionBuffer == IntPtr.Zero)
					throw new Exception("Unable to allocate the SERVICE_DESCRIPTION buffer.");

				if (!ChangeServiceConfig2(hService, SERVICE_CONFIG_DESCRIPTION, pNewDescriptionBuffer))
					throw new Exception("Failed call to ChangeServiceConfig2(SERVICE_CONFIG_DESCRIPTION).");
			}
			finally
			{
				if (pNewDescriptionBuffer != IntPtr.Zero)
					Marshal.FreeHGlobal(pNewDescriptionBuffer);
			}
			return;
		}

	}
}
