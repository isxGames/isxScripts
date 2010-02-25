using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using PInvoke;
using Microsoft.Win32.SafeHandles;
using System.Runtime.InteropServices;

namespace EQ2SuiteLib
{
	public class PollingLogFileMonitor
	{
		protected long m_lLastFileEnd = 0;
		protected string m_strFilePath = string.Empty;
		protected bool m_bIgnoreThisLine = true;

		public string FilePath
		{
			get
			{
				return m_strFilePath;
			}
			set
			{
				m_strFilePath = value;
				return;
			}
		}

		public PollingLogFileMonitor()
		{
			return;
		}

		public bool CheckChanges()
		{
			IntPtr hFile = KERNEL32.INVALID_HANDLE_VALUE;

			try
			{
				long lNewLength = 0;

				/// Used CreateFile because I wanted to access the file ONLY ONCE.
				/// Not three times to get existance, size, blah blah.
				hFile = KERNEL32.CreateFile(
					m_strFilePath,
					KERNEL32.FileAccess.ReadData | KERNEL32.FileAccess.ReadAttributes,
					KERNEL32.FileShareMode.Read,
					IntPtr.Zero,
					KERNEL32.FileCreationDisposition.OpenExisting,
					KERNEL32.FileFlagsAndAttributes.FlagRandomAccess,
					IntPtr.Zero);
				if (hFile == KERNEL32.INVALID_HANDLE_VALUE)
				{
					KERNEL32.Win32Error eError = KERNEL32.GetLastError();
					return false;
				}

				if (!KERNEL32.GetFileSizeEx(hFile, out lNewLength))
					return false;

				/// File was presumably deleted or replaced.
				if (m_lLastFileEnd > lNewLength)
				{
					m_lLastFileEnd = lNewLength;
					m_bIgnoreThisLine = true;
					return false;
				}

				/// The file didn't change.
				if (m_lLastFileEnd == lNewLength)
					return false;

				string strContents = null;
				using (FileStream ThisFile = new FileStream(new SafeFileHandle(hFile, false), FileAccess.Read))
				{
					ThisFile.Seek(m_lLastFileEnd, SeekOrigin.Begin);
					byte[] abyBuffer = new byte[1000];
					ThisFile.Read(abyBuffer, 0, 1000);

					using (StreamReader ThisReader = new StreamReader(ThisFile, Encoding.ASCII))
					{
						strContents = ThisReader.ReadToEnd();
					}
				}

				Console.WriteLine("Added {0} characters.", strContents.Length);
				m_lLastFileEnd = lNewLength;
			}
			catch (Exception e)
			{
				return false;
			}
			finally
			{
				if (hFile != KERNEL32.INVALID_HANDLE_VALUE)
				{
					KERNEL32.CloseHandle(hFile);
					hFile = KERNEL32.INVALID_HANDLE_VALUE;
				}
			}

			return true;
		}

		public string GetNextLine()
		{
			return null;
		}
	}
}
