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
	public class PollingLogFileMonitor
	{
		protected long m_lLastFileEnd = 0;
		protected string m_strFilePath = string.Empty;
		protected bool m_bFirstCheck = true;
		protected Queue<string> m_NewLineQueue = new Queue<string>();
		protected string m_strCurrentLine = string.Empty;

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

		public bool ReadChanges()
		{
			IntPtr hFile = KERNEL32.INVALID_HANDLE_VALUE;

			try
			{
				long lNewLength = 0;

				/// Used CreateFile because I wanted to open a file handle ONLY ONCE.
				/// Not three times to get existance, size, blah blah.
				hFile = KERNEL32.CreateFile(
					m_strFilePath,
					KERNEL32.FileAccess.ReadData | KERNEL32.FileAccess.ReadAttributes,
					KERNEL32.FileShareMode.Read | KERNEL32.FileShareMode.Write | KERNEL32.FileShareMode.Delete,
					IntPtr.Zero,
					KERNEL32.FileCreationDisposition.OpenExisting,
					KERNEL32.FileFlagsAndAttributes.FlagRandomAccess,
					IntPtr.Zero);
				if (hFile == KERNEL32.INVALID_HANDLE_VALUE)
				{
					KERNEL32.Win32Error eError = KERNEL32.GetLastError();
					if (eError == KERNEL32.Win32Error.ERROR_FILE_NOT_FOUND)
						lNewLength = 0;

					return false;
				}

				if (!KERNEL32.GetFileSizeEx(hFile, out lNewLength))
					return false;

				/// File was presumably deleted or replaced.
				if (m_lLastFileEnd > lNewLength)
				{
					m_lLastFileEnd = lNewLength;
					return false;
				}

				/// The file didn't change.
				if (m_lLastFileEnd == lNewLength)
					return false;

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
						{
							strContents = ThisReader.ReadToEnd();
						}
					}
					UnpackNewText(strContents);
				}

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

		protected void UnpackNewText(string strContents)
		{
			int iNewLineStart = -1;
			int iLastStart = 0;
			string strRemainder = m_strCurrentLine + strContents;
			while ((iLastStart < strRemainder.Length) && (iNewLineStart = strRemainder.IndexOf("\r\n", iLastStart)) != -1)
			{
				string strNewLine = strRemainder.Substring(iLastStart, iNewLineStart - iLastStart);
				m_NewLineQueue.Enqueue(strNewLine);
				//Console.WriteLine("Added line: {0}", strNewLine);

				iLastStart = iNewLineStart + 2;
			}

			m_strCurrentLine = strRemainder.Substring(iLastStart);

			/// Something is wrong and the line is abnormally long; proper newlines aren't being found. Start over.
			if (m_strCurrentLine.Length > 5000)
				m_strCurrentLine = string.Empty;

			return;
		}

		public string GetNextLine()
		{
			if (m_NewLineQueue.Count == 0)
				return null;
			
			return m_NewLineQueue.Dequeue();
		}
	}
}
