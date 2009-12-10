using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace EQ2SuiteLib
{
	public class PollingTextFileUpdateMonitor
	{
		protected FileSystemWatcher m_Watcher = new FileSystemWatcher();
		protected long m_lLastFileEnd = 0;

		protected string m_strFolderPath = string.Empty;
		protected string m_strFileName = string.Empty;
		protected string m_strFilePath = string.Empty;

		public string FilePath
		{
			get
			{
				return m_strFilePath;
			}
			set
			{
				m_Watcher.EnableRaisingEvents = false;
				if (File.Exists(value))
				{
					m_strFilePath = value;
					m_strFolderPath = Path.GetDirectoryName(m_strFilePath);
					m_strFileName = Path.GetFileName(m_strFilePath);

					FileInfo NewInfo = new FileInfo(m_strFilePath);
					m_lLastFileEnd = NewInfo.Length;

					m_Watcher.Path = m_strFolderPath;
					m_Watcher.Filter = m_strFileName;
					m_Watcher.EnableRaisingEvents = true;
				}
				return;
			}
		}

		public PollingTextFileUpdateMonitor()
		{
			m_Watcher.Changed += new FileSystemEventHandler(OnFileChanged);
			m_Watcher.Deleted += new FileSystemEventHandler(OnFileDeleted);
			m_Watcher.NotifyFilter = NotifyFilters.LastWrite | NotifyFilters.Size | NotifyFilters.LastAccess;

			return;
		}

		protected void OnFileDeleted(object sender, FileSystemEventArgs e)
		{
			/// TODO: Just reset buffers.
			m_lLastFileEnd = 0;
			return;
		}

		protected void OnFileChanged(object sender, FileSystemEventArgs e)
		{
			if (m_strFilePath != e.FullPath)
				FilePath = e.FullPath;

			if (!File.Exists(m_strFilePath))
				return;

			FileInfo NewInfo = new FileInfo(m_strFilePath);

			using (FileStream LogFile = new FileStream(m_strFilePath, FileMode.Open))
			{
				long lReadSize = NewInfo.Length - m_lLastFileEnd;
				byte[] abyBuffer = new byte[lReadSize];

				LogFile.Read(abyBuffer, (int)m_lLastFileEnd, (int)lReadSize);

				m_lLastFileEnd = NewInfo.Length;
			}

			return;
		}


	}
}
