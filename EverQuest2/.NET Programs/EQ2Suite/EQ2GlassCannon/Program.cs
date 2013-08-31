using System;
using System.IO;
using System.Reflection;
using System.Threading;
using System.Diagnostics;
using System.Text;
using InnerSpaceAPI;

namespace EQ2GlassCannon
{
	public static class Program
	{
		public static EmailQueueThread s_EmailQueueThread = new EmailQueueThread();

		private static string s_strConfigurationFolderPath = string.Empty;
		public static string ConfigurationFolderPath { get { return s_strConfigurationFolderPath; } }

		private static string s_strCrashLogPath = string.Empty;

		/************************************************************************************/
		private static void Main()
		{
			try
			{
				DisplayVersion();

				s_EmailQueueThread.Start();

				/// Ensure that the configuration path exists firstly.
				string strAppDataFolderPath = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
				strAppDataFolderPath = Path.Combine(strAppDataFolderPath, "EQ2GlassCannon");
				DirectoryInfo DataFolderInfo = Directory.CreateDirectory(strAppDataFolderPath);
				if (DataFolderInfo != null)
					s_strConfigurationFolderPath = DataFolderInfo.FullName;
				else
					s_strConfigurationFolderPath = Directory.GetCurrentDirectory(); // ehhhh not the best option but w/e...

				s_strCrashLogPath = Path.Combine(s_strConfigurationFolderPath, "CrashLog.txt");

				/// Run the bot!
				if (PlayerController.Initialize() && PlayerController.TestSpeed())
					PlayerController.Run();

				Program.Log("Shutting down e-mail thread...");
				s_EmailQueueThread.PostQuitMessageAndShutdownQueue(true);
				if (s_EmailQueueThread.WaitForTermination(TimeSpan.FromSeconds(30.0)))
					Program.Log("E-mail thread terminated.");
				else
					Program.Log("E-mail thread timed out.");
			}

			/// I have only one try-catch frame because I don't want hidden logic bugs.
			/// Things should work perfectly or not at all.
			catch (Exception e)
			{
				Program.OnUnhandledException(e);

				/// Nothing will appear on the screen anyway because the whole thing is locked up.
				/// TODO: Verify that this is needed.
				/*if (LavishVMAPI.Frame.IsLocked)
					Process.GetCurrentProcess().Kill();*/
			}

			finally
			{
				Program.Log("EQ2GlassCannon has terminated!");
			}

			return;
		}

		/************************************************************************************/
		/// <summary>
		/// Converted from VB written by Dustin Aleksiuk.
		/// http://www.codinghorror.com/blog/archives/000264.html
		/// </summary>
		public static DateTime RetrieveLinkerTimestamp(string strFilePath)
		{
			byte[] abyBuffer = new byte[2048];
			using (Stream s = new FileStream(strFilePath, FileMode.Open, FileAccess.Read))
				s.Read(abyBuffer, 0, 2048);

			const int PE_HEADER_OFFSET = 60;
			const int LINKER_TIMESTAMP_OFFSET = 8;

			int i = BitConverter.ToInt32(abyBuffer, PE_HEADER_OFFSET);
			int iSecondsSince1970 = BitConverter.ToInt32(abyBuffer, i + LINKER_TIMESTAMP_OFFSET);

			DateTime LinkerTimestamp = new DateTime(1970, 1, 1, 0, 0, 0);
			LinkerTimestamp = LinkerTimestamp.AddSeconds(iSecondsSince1970);
			LinkerTimestamp = LinkerTimestamp.AddHours(TimeZone.CurrentTimeZone.GetUtcOffset(LinkerTimestamp).Hours);
			return LinkerTimestamp;
		}

		/************************************************************************************/
		public static void Log(string strFormat, params object[] aobjParams)
		{
			string strOutput = DateTime.Now.ToLongTimeString() + " - ";

			if (aobjParams.Length == 0)
				strOutput += string.Format("{0}", strFormat);
			else
				strOutput += string.Format(strFormat, aobjParams);

			InnerSpace.Echo(strOutput);

			/// TODO: Optionally push this out to a file or separate text console.
			return;
		}

		/************************************************************************************/
		[Conditional("DEBUG")]
		public static void DebugLog(string strFormat, params object[] aobjParams)
		{
			Log(strFormat, aobjParams);
			return;
		}

		/************************************************************************************/
		public static void Log(object objParam)
		{
			Program.Log("{0}", objParam);
			return;
		}

		/************************************************************************************/
		private static string s_strLinkerTimestamp = null;
		public static void DisplayVersion()
		{
			Program.Log("EQ2GlassCannon Spellcaster Bot (Written 2008-2010 by Eccentric)");

			if (string.IsNullOrEmpty(s_strLinkerTimestamp))
			{
				Assembly ThisAssembly = Assembly.GetExecutingAssembly();
				if (ThisAssembly != null)
				{
					DateTime LinkerTimestamp = RetrieveLinkerTimestamp(ThisAssembly.Location);
					s_strLinkerTimestamp = string.Format("\"{0}\" built on {1} at {2}.", Path.GetFileName(ThisAssembly.Location), LinkerTimestamp.ToLongDateString(), LinkerTimestamp.ToLongTimeString());
				}
			}

			Program.Log(s_strLinkerTimestamp);
			return;
		}

		/************************************************************************************/
		public static void SafeShellExecute(string strFileName)
		{
			ThreadPool.QueueUserWorkItem(
				delegate(object objContext)
				{
					try
					{
						if (File.Exists(strFileName))
						{
							Program.Log("Shell executing \"{0}\"...", strFileName);

							Process p = new System.Diagnostics.Process();
							p.StartInfo.FileName = strFileName;
							p.StartInfo.UseShellExecute = true;
							p.StartInfo.ErrorDialog = false;

							/// This call crashes the process when run inside the main thread.
							/// That's why we dump this act to the worker queue.
							p.Start();
						}
						else
						{
							Program.Log("Shell execute error: Cannot find file \"{0}\".", strFileName);
						}
					}
					catch (Exception e)
					{
						Program.OnUnhandledException(e);
					}
				}
			);
			return;
		}

		/************************************************************************************/
		public static StreamWriter OpenCrashLog()
		{
			StreamWriter OutputFile = new StreamWriter(s_strCrashLogPath, true);
			OutputFile.WriteLine("-----------------------------");
			DateTime NowTime = DateTime.Now;
			OutputFile.WriteLine(NowTime.ToLongDateString() + " " + NowTime.ToLongTimeString());
			return OutputFile;
		}

		/************************************************************************************/
		public static void OnUnhandledException(Exception e)
		{
			try
			{
				StringBuilder ExceptionText = new StringBuilder();
				ExceptionText.AppendLine("Unhandled .NET exception: " + e.Message);
				ExceptionText.AppendLine(e.TargetSite.ToString());
				ExceptionText.AppendLine(e.StackTrace.ToString());
				string strExceptionText = ExceptionText.ToString();

				using (StreamWriter OutputFile = OpenCrashLog())
					OutputFile.WriteLine(strExceptionText);

				Program.Log(strExceptionText); /// TODO: Extract and display the LINE that threw the exception!!!
			}
			catch
			{
				Program.Log("Exception occured while handling the unhandled exception!");
			}
			return;
		}

		/************************************************************************************/
		public static void RunGarbageCollector()
		{
			Program.Log("Performing .NET garbage collection...");
			long lMemoryBeforeGarbageCollection = GC.GetTotalMemory(false);
			GC.Collect();
			long lMemoryAfterGarbageCollection = GC.GetTotalMemory(true);
			long lMemoryFreed = lMemoryBeforeGarbageCollection - lMemoryAfterGarbageCollection;
			Program.Log("{0} bytes freed.", lMemoryFreed);
			return;
		}
	}
}
