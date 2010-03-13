using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using System.Diagnostics;
using Microsoft.Win32.SafeHandles;
using System.Threading;

namespace PInvoke
{
	public static partial class KERNEL32
	{
		public const int MAX_PATH = 260;
		public static readonly IntPtr INVALID_HANDLE_VALUE = (IntPtr)(-1);
		public const uint INFINITE = 0;

		/// <summary>
		/// Gets the Win32 error code from the last marshaled PInvoke call.
		/// Does not actually call KERNEL32.GetLastError().
		/// </summary>
		public static Win32ErrorCode GetLastError()
		{
			/// Sneaky!
			return (Win32ErrorCode)Marshal.GetLastWin32Error();
		}

		[Flags]
		public enum FileAccess : uint
		{
			Delete = 0x00010000,
			ReadControl = 0x00020000,
			WriteDAC = 0x00040000,
			WriteOwner = 0x00080000,
			Synchronize = 0x00100000,
			StandardRightsRequired = 0x000F0000,
			StandardRightsRead = ReadControl,
			StandardRightsWrite = ReadControl,
			StandardRightsExecute = ReadControl,
			StandardRightsAll = 0x001F0000,
			SpecificRightsAll = 0x0000FFFF,

			ReadData = 0x1,
			ListDirectory = 0x1,
			WriteData = 0x2,
			AddFile = 0x2,
			AppendData = 0x4,
			AddSubDirectory = 0x4,
			CreatePipeInstance = 0x4,
			ReadExtendedAttributes = 0x8,
			WriteExtendedAttributes = 0x10,
			Execute = 0x20,
			Traverse = 0x20,
			DeleteChild = 0x40,
			ReadAttributes = 0x80,
			WriteAttributes = 0x100,
			AllAccess = StandardRightsRequired | Synchronize | 0x1FF,
			GenericRead = StandardRightsRead | ReadData | ReadAttributes | ReadExtendedAttributes | Synchronize,
			GenericWrite = StandardRightsWrite | WriteData | WriteAttributes | WriteExtendedAttributes | AppendData | Synchronize,
			GenericExecute = StandardRightsExecute | ReadAttributes | Execute | Synchronize,
		}

		[Flags]
		public enum FileShareMode : uint
		{
			Read = 0x00000001,
			Write = 0x00000002,
			Delete = 0x00000004,
		}

		/// <summary>
		/// Winbase.h
		/// </summary>
		public enum FileCreationDisposition : uint
		{
			CreateNew = 1,
			CreateAlways = 2,
			OpenExisting = 3,
			OpenAlways = 4,
			TruncateExisting = 5,
			OpenForLoader = 6,
		}

		[Flags]
		public enum FileFlagsAndAttributes : uint
		{
			ReadOnly = 0x1,
			Hidden = 0x2,
			System = 0x4,
			Directory = 0x10,
			Archive = 0x20,
			Device = 0x40,
			Normal = 0x80,
			Temporary = 0x100,
			SparseFile = 0x200,
			ReparsePoint = 0x400,
			Compressed = 0x800,
			Offline = 0x1000,
			NotContentIndexed = 0x2000,
			Encrypted = 0x4000,
			Virtual = 0x10000,
			FlagFirstPipeInstance = 0x00080000,
			FlagOpenNoRecall = 0x00100000,
			FlagOpenReparsePoint = 0x00200000,
			FlagPosixSemantics = 0x01000000,
			FlagBackupSemantics = 0x02000000,
			FlagDeleteOnClose = 0x04000000,
			FlagSequentialScan = 0x08000000,
			FlagRandomAccess = 0x10000000,
			FlagNoBuffering = 0x20000000,
			FlagOverlapped = 0x40000000,
			FlagWriteThrough = 0x80000000,
			Failure = 0xFFFFFFFF,
		}

		[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
		public static extern /*SafeFileHandle*/ IntPtr CreateFile(
			string lpFileName,
			FileAccess dwDesiredAccess,
			FileShareMode dwShareMode,
			IntPtr lpSecurityAttributes,
			FileCreationDisposition dwCreationDisposition,
			FileFlagsAndAttributes dwFlagsAndAttributes,
			IntPtr hTemplateFile);

		[DllImport("kernel32.dll", SetLastError = true)]
		public static extern bool GetFileSizeEx(IntPtr hFile, ref long lpFileSize);

		[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
		public static extern FileFlagsAndAttributes GetFileAttributes(string lpFileName);

		[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
		public static extern bool SetFileAttributes(string lpFileName, FileFlagsAndAttributes dwFileAttributes);

		public enum FilePointerMoveMethod : uint
		{
			Beginning = 0,
			Current = 1,
			End = 2,
		}

		[DllImport("kernel32.dll", SetLastError = true)]
		public static extern bool SetFilePointerEx(IntPtr hFile, long liDistanceToMove, ref long lpNewFilePointer, FilePointerMoveMethod dwMoveMethod);

		[DllImport("kernel32.dll", SetLastError = true)]
		public static extern bool SetEndOfFile(IntPtr hFile);

		public delegate CopyProgressResult CopyProgressRoutine(
			long TotalFileSize,
			long TotalBytesTransferred,
			long StreamSize,
			long StreamBytesTransferred,
			uint dwStreamNumber,
			CopyProgressCallbackReason dwCallbackReason,
			IntPtr hSourceFile,
			IntPtr hDestinationFile,
			IntPtr lpData);

		public enum CopyProgressResult : uint
		{
			Continue = 0,
			Cancel = 1,
			Stop = 2,
			Quiet = 3
		}

		public enum CopyProgressCallbackReason : uint
		{
			ChunkFinished = 0x00000000,
			StreamFinished = 0x00000001
		}

		[Flags]
		public enum CopyFileFlags : uint
		{
			FailIfExists = 0x00000001,
			Restartable = 0x00000002,
			OpenSourceForWrite = 0x00000004,
			AllowDecryptedDestination = 0x00000008,
		}

		[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
		public static extern bool CopyFile(
			string lpExistingFileName,
			string lpNewFileName,
			bool bFailIfExists);

		[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool CopyFileEx(
			string lpExistingFileName,
			string lpNewFileName,
			CopyProgressRoutine lpProgressRoutine,
			IntPtr lpData,
			ref Int32 pbCancel,
			CopyFileFlags dwCopyFlags);

		[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool DeleteFile(string lpFileName);

		[StructLayout(LayoutKind.Sequential)]
		public class SECURITY_ATTRIBUTES
		{
			public int nLength;
			public IntPtr lpSecurityDescriptor;
			public int bInheritHandle;
		}

		[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool CreateDirectory(string lpPathName, SECURITY_ATTRIBUTES lpSecurityAttributes);

		[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool RemoveDirectory(string lpPathName);

		[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
		public static extern IntPtr CreateIoCompletionPort(
			IntPtr FileHandle,
			IntPtr ExistingCompletionPort,
			UIntPtr CompletionKey,
			uint NumberOfConcurrentThreads);

		/// <summary>
		/// From "Advanced Windows" by Jeffrey Richter, page 747.
		/// </summary>
		/// <param name="NumberOfConcurrentThreads"></param>
		/// <returns></returns>
		public static IntPtr CreateNewCompletionPort(uint NumberOfConcurrentThreads)
		{
			return CreateIoCompletionPort(INVALID_HANDLE_VALUE, IntPtr.Zero, UIntPtr.Zero, NumberOfConcurrentThreads);
		}

		/// <summary>
		/// From "Advanced Windows" by Jeffrey Richter, page 750.
		/// </summary>
		/// <param name="hCompletionPort"></param>
		/// <param name="hDevice"></param>
		/// <param name="dwCompKey"></param>
		/// <returns></returns>
		public static bool AssociateDeviceWithCompletionPort(IntPtr hCompletionPort, IntPtr hDevice, UIntPtr dwCompKey)
		{
			IntPtr h = CreateIoCompletionPort(hDevice, hCompletionPort, dwCompKey, 0);
			return (h == hCompletionPort);
		}

		/// <summary>
		/// "Warning! GetOverlappedResult writes to the address of the buffer specified in the ORIGINAL OPERATION
		/// (ie/ ReadFile  or WriteFile). .NET may move the address of the buffer before GetOverlappedResult 
		/// returns, resulting in a buffer overflow.
		/// Use AllocHGlobal and FreeHGlobal or otherwise ensure the buffer is pinned between the two calls.
		/// </summary>
		/// <param name="hFile"></param>
		/// <param name="lpOverlapped"></param>
		/// <param name="lpNumberOfBytesTransferred"></param>
		/// <param name="bWait"></param>
		/// <returns></returns>
		[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool GetOverlappedResult(
			IntPtr hFile,
			[In] ref NativeOverlapped lpOverlapped,
			out uint lpNumberOfBytesTransferred,
			bool bWait);

		[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool GetQueuedCompletionStatus(
			IntPtr CompletionPort,
			out uint lpNumberOfBytes,
			out UIntPtr lpCompletionKey,
			[Out] out NativeOverlapped lpOverlapped,
			uint dwMilliseconds);

		[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
		public struct OVERLAPPED_ENTRY
		{
			UIntPtr lpCompletionKey;
			NativeOverlapped lpOverlapped; /// This is supposed to be an address; may need to be an IntPtr.
			UIntPtr Internal;
			uint dwNumberOfBytesTransferred;
		}

		/// <summary>
		/// Windows Vista or later: retrieves mulitple completion statuses at one time.
		/// </summary>
		/// <param name="CompletionPort"></param>
		/// <param name="lpCompletionPortEntries"></param>
		/// <param name="ulCount"></param>
		/// <param name="ulNumEntriesRemoved"></param>
		/// <param name="dwMilliseconds"></param>
		/// <param name="fAlertable"></param>
		/// <returns></returns>
		[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool GetQueuedCompletionStatusEx(
			[In] IntPtr CompletionPort,
			[Out] OVERLAPPED_ENTRY[] lpCompletionPortEntries,
			[In] uint ulCount,
			[Out] out uint ulNumEntriesRemoved,
			[In] uint dwMilliseconds,
			[In] bool fAlertable);
	}
}
