using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using PInvoke;
using Microsoft.Win32.SafeHandles;
using System.Runtime.InteropServices;
using System.Collections;

namespace EQ2SuiteLib
{
	public class PollingLogFileMonitor : IDisposable
	{
		protected string m_strFilePath = string.Empty;
		protected long? m_lMaxFileSize = null;
		protected long m_lLastFileEnd = 0;
		protected bool m_bFirstCheck = true;
		protected Queue<string> m_NewLineQueue = new Queue<string>();
		protected string m_strCurrentLineFragment = string.Empty;

		/************************************************************************************/
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

		/************************************************************************************/
		public long? MaxFileSize
		{
			get
			{
				return m_lMaxFileSize;
			}
			set
			{
				m_lMaxFileSize = value;
				return;
			}
		}

		/************************************************************************************/
		public void Dispose()
		{
			ResetCounters();
			return;
		}

		/************************************************************************************/
		public PollingLogFileMonitor()
		{
			return;
		}

		/************************************************************************************/
		protected void ResetCounters()
		{
			m_lLastFileEnd = 0;
			m_bFirstCheck = true;
			m_NewLineQueue.Clear();
			m_strCurrentLineFragment = string.Empty;
			return;
		}

		/************************************************************************************/
		protected IntPtr OpenFile()
		{
			/// Used CreateFile because I wanted to open a file handle ONLY ONCE.
			/// Not three times to get existance, size, blah blah.
			return KERNEL32.CreateFile(
				m_strFilePath,
				KERNEL32.FileAccess.ReadData | KERNEL32.FileAccess.ReadAttributes | KERNEL32.FileAccess.WriteData,
				KERNEL32.FileShareMode.Read | KERNEL32.FileShareMode.Write | KERNEL32.FileShareMode.Delete,
				IntPtr.Zero,
				KERNEL32.FileCreationDisposition.OpenExisting,
				KERNEL32.FileFlagsAndAttributes.FlagRandomAccess,
				IntPtr.Zero);
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		/// <returns></returns>
		public bool ReadChanges()
		{
			bool bSplitFile = false;
			IntPtr hFile = KERNEL32.INVALID_HANDLE_VALUE;
			try
			{
				/// It may seem inefficient to close and reopen the handle every poll but that's the only way to get an accurate file size.
				if ((hFile = OpenFile()) == KERNEL32.INVALID_HANDLE_VALUE)
				{
					Win32ErrorCode eError = KERNEL32.GetLastError();
					return false;
				}

				long lNewLength = 0;
				if (!KERNEL32.GetFileSizeEx(hFile, ref lNewLength))
					return false;

				/// File was presumably deleted or replaced.
				if (m_lLastFileEnd > lNewLength)
				{
					m_lLastFileEnd = lNewLength;
					return false;
				}

				/// The file didn't change.
				if (m_lLastFileEnd == lNewLength)
				{
					/// ...but now is a good time to split the file if needed.
					if (m_lMaxFileSize != null && m_lLastFileEnd > m_lMaxFileSize.Value)
						bSplitFile = true;

					return false;
				}

				/// We don't load the existing file when we first connect.
				if (m_bFirstCheck)
					m_bFirstCheck = false;
				else
				{
					string strContents = null;
					using (FileStream ThisFile = new FileStream(new SafeFileHandle(hFile, false), FileAccess.Read))
					{
						ThisFile.Seek(m_lLastFileEnd, SeekOrigin.Begin);

						/// We're safe; the log isn't UTF-16 so there's no risk of starting the read mid-character.
						using (StreamReader ThisReader = new StreamReader(ThisFile, Encoding.ASCII))
							strContents = ThisReader.ReadToEnd();
					}
					UnpackNewText(strContents);
				}

				m_lLastFileEnd = lNewLength;
			}
			catch //(Exception e)
			{
				return false;
			}
			finally
			{
				if (hFile == KERNEL32.INVALID_HANDLE_VALUE)
				{
					KERNEL32.CloseHandle(hFile);
					hFile = KERNEL32.INVALID_HANDLE_VALUE;
				}

				if (bSplitFile)
					SplitLogFile();
			}

			return true;
		}

		/************************************************************************************/
		protected void UnpackNewText(string strContents)
		{
			int iNewLineStart = -1;
			int iLastStart = 0;
			string strRemainder = m_strCurrentLineFragment + strContents;

			while ((iLastStart < strRemainder.Length) && (iNewLineStart = strRemainder.IndexOf("\r\n", iLastStart)) != -1)
			{
				string strNewLine = strRemainder.Substring(iLastStart, iNewLineStart - iLastStart);
				m_NewLineQueue.Enqueue(strNewLine);
				iLastStart = iNewLineStart + 2;
			}

			/// Save leftovers for later.
			m_strCurrentLineFragment = strRemainder.Substring(iLastStart);

			/// Something is wrong and the line is abnormally long; proper newlines aren't being found. Start over.
			if (m_strCurrentLineFragment.Length > 2000)
				m_strCurrentLineFragment = string.Empty;

			return;
		}

		/************************************************************************************/
		public string GetNextLine()
		{
			if (m_NewLineQueue.Count == 0)
				return null;

			return m_NewLineQueue.Dequeue();
		}

		/************************************************************************************/
		/// <summary>
		/// This is proven to work even while the file is locked.
		/// </summary>
		public void ClearLogFile()
		{
			IntPtr hFile = OpenFile();
			if (hFile != KERNEL32.INVALID_HANDLE_VALUE)
			{
				long lNewPointer = 0;
				KERNEL32.SetFilePointerEx(hFile, 0, ref lNewPointer, KERNEL32.FilePointerMoveMethod.Beginning);
				KERNEL32.SetEndOfFile(hFile);
				KERNEL32.CloseHandle(hFile);

				ResetCounters();
			}
			return;
		}

		/************************************************************************************/
		/// <summary>
		/// Unlike ACT, this should work at any time while EQ2 has the file locked.
		/// It isn't perfect and might have some overlap but it's good enough.
		/// NOTE: The log file can't be renamed while in use.
		/// </summary>
		public void SplitLogFile()
		{
			try
			{
				string strNewFileName = string.Format("{0} {1:yyyy-MM-dd HHmmssfffffff}", Path.GetFileNameWithoutExtension(m_strFilePath), DateTime.UtcNow);
				strNewFileName += Path.GetExtension(m_strFilePath);
				string strNewFilePath = Path.Combine(Path.GetDirectoryName(m_strFilePath), strNewFileName);

				if (!KERNEL32.CopyFile(m_strFilePath, strNewFilePath, false))
					return;

				/// This is the tricky moment. Right here it's possible that more lines are added to the log file.

				ClearLogFile();
			}
			catch //(Exception ex)
			{
				/// Not sure yet what to do here, if anything.
			}
			return;
		}
	}
}
