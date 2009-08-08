using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using EQ2.ISXEQ2;
using InnerSpaceAPI;
using LavishScriptAPI;
using LavishVMAPI;

namespace EQ2GlassCannon
{
	public static class Program
	{
		public static Extension s_Extension = null;
		private static EQ2.ISXEQ2.ISXEQ2 s_ISXEQ2 = null;
		private static EQ2.ISXEQ2.EQ2 s_EQ2 = null;
		private static Character s_Me = null;
		private static Actor s_MeActor = null;
		private static EQ2Event s_eq2event = null;
		public static PlayerController s_Controller = null;
		public static EmailQueueThread s_EmailQueueThread = new EmailQueueThread();

		public static bool s_bContinueBot = true;
		public static bool s_bRefreshKnowledgeBook = false;
		private static long s_lFrameCount = 0;
		public static string s_strINIFolderPath = string.Empty;
		public static string s_strCurrentINIFilePath = string.Empty;
		private static string s_strNewWindowTitle = null;

		public static EQ2.ISXEQ2.ISXEQ2 ISXEQ2 { get { return s_ISXEQ2; } }
		public static EQ2.ISXEQ2.EQ2 EQ2 { get { return s_EQ2; } }
		public static Character Me { get { return s_Me; } }
		public static Actor MeActor { get { return s_MeActor; } }

		/************************************************************************************/
		/// <summary>
		/// Make sure to call this every time you grab a frame lock.
		/// </summary>
		public static void UpdateGlobals()
		{
			/// These become invalid from frame to frame.
			s_ISXEQ2 = s_Extension.ISXEQ2();
			s_EQ2 = s_Extension.EQ2();
			s_Me = s_Extension.Me();
			s_MeActor = s_Me.ToActor();

			return;
		}

		/************************************************************************************/
		public static long FrameCount
		{
			get
			{
				return s_lFrameCount;
			}
		}

		/************************************************************************************/
		/// <summary>
		/// Static constructor. Don't do anything of consequence in here, or shit gets messy.
		/// </summary>
		static Program()
		{
			return;
		}

		/************************************************************************************/
		/// <summary>
		/// Converted from VB written by Dustin Aleksiuk.
		/// http://www.codinghorror.com/blog/archives/000264.html
		/// </summary>
		public static DateTime RetrieveLinkerTimestamp(string strFilePath)
		{
			const int PE_HEADER_OFFSET = 60;
			const int LINKER_TIMESTAMP_OFFSET = 8;

			byte[] b = new byte[2048];

			try
			{
				using (Stream s = new FileStream(strFilePath, FileMode.Open, FileAccess.Read))
					s.Read(b, 0, 2048);
			}
			finally
			{
			}

			int i = BitConverter.ToInt32(b, PE_HEADER_OFFSET);
			int iSecondsSince1970 = BitConverter.ToInt32(b, i + LINKER_TIMESTAMP_OFFSET);

			DateTime dt = new DateTime(1970, 1, 1, 0, 0, 0);
			dt = dt.AddSeconds(iSecondsSince1970);
			dt = dt.AddHours(TimeZone.CurrentTimeZone.GetUtcOffset(dt).Hours);
			return dt;
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
		public static void Log(object objParam)
		{
			Log("{0}", objParam);
			return;
		}

		/************************************************************************************/
		public static void TestFrameRate(double fSeconds)
		{
			Program.Log("Sampling frame rate...");
			DateTime ThrottleWaitStart = DateTime.Now;
			int iFramesElapsed = 0;
			while (DateTime.Now - ThrottleWaitStart < TimeSpan.FromSeconds(fSeconds))
			{
				LavishVMAPI.Frame.Wait(false);
				//using (new FrameLock(true)) ;
				iFramesElapsed++;
			}
			double fFramesPerSecond = (double)iFramesElapsed / (DateTime.Now - ThrottleWaitStart).TotalSeconds;
			Program.Log("Measurement complete ({0:0.0} FPS).", fFramesPerSecond);
			return;
		}

		/************************************************************************************/
		public static void ApplyGameSettings()
		{
			/// We could do this once at the beginning, but I've seen it not take.
			Log("Setting music volume to zero and deactivating personal torch.");
			RunCommand("/music_volume 0");
			RunCommand("/r_personal_torch off");
			return;
		}

		/************************************************************************************/
		private static void Main()
		{
			try
			{
				s_EmailQueueThread.Start();

				Program.Log("Starting EQ2GlassCannon spellcaster bot...");

				Assembly ThisAssembly = Assembly.GetExecutingAssembly();
				if (ThisAssembly != null)
				{
					DateTime LinkerTimestamp = RetrieveLinkerTimestamp(ThisAssembly.Location);
					Program.Log("\"{0}\" built on {1} at {2}.", Path.GetFileName(ThisAssembly.Location), LinkerTimestamp.ToLongDateString(), LinkerTimestamp.ToLongTimeString());
				}

				using (new FrameLock(true))
				{
					/// Just use this for debugging; otherwise it crashes the client when the bot terminates.
					//LavishScript.RequireExplicitFrameLock = true;

					LavishScript.Events.AttachEventTarget(LavishScript.Events.RegisterEvent("OnFrame"), OnFrame_EventHandler); 
					s_Extension = new Extension();
				}

				Program.Log("Waiting for ISXEQ2 to initialize...");
				while (true)
				{
					using (new FrameLock(true))
					{
						UpdateGlobals();
						if (ISXEQ2.IsReady)
							break;
					}
				}

				using (new FrameLock(true))
				{
					UpdateGlobals();
					s_eq2event = new EQ2Event();
					s_eq2event.CastingEnded += new EventHandler<LSEventArgs>(OnCastingEnded_EventHandler);
					s_eq2event.ChoiceWindowAppeared += new EventHandler<LSEventArgs>(OnChoiceWindowAppeared_EventHandler);
					s_eq2event.IncomingChatText += new EventHandler<LSEventArgs>(OnIncomingChatText_EventHandler);
					s_eq2event.IncomingText += new EventHandler<LSEventArgs>(OnIncomingText_EventHandler);
					s_eq2event.QuestOffered += new EventHandler<LSEventArgs>(OnQuestOffered_EventHandler);

					s_ISXEQ2.SetActorEventsRange(50.0f);
				}

#if !DEBUG
				double fTestTime = 5.0;

				/// This giant code chunk was a huge necessity due to the completely random lag that happens
				/// inside the UpdateGlobals() function. A laggy launch will never free up and a free launch
				/// will never get laggy.  Thus we veto laggy launches and tell the user to re-launch.
				Log("Testing the speed of root object lookup. Please wait {0:0.0} seconds...", fTestTime);
				DateTime SlowFrameTestStartTime = DateTime.Now;
				int iFramesElapsed = 0;
				int iBadFrames = 0;
				double fTotalTimes = 0.0;
				while (DateTime.Now - SlowFrameTestStartTime < TimeSpan.FromSeconds(fTestTime))
				{
					iFramesElapsed++;
					Frame.Wait(true);
					try
					{
						DateTime BeforeTime = DateTime.Now;
						UpdateGlobals(); /// This is the line we're testing.
						DateTime AfterTime = DateTime.Now;

						double fElapsedTime = (AfterTime - BeforeTime).TotalMilliseconds;
						fTotalTimes += fElapsedTime;
						//Log("{0} : {1:0.0}", iFramesElapsed, fElapsedTime);

						/// A correctly functioning access to the root ISXEQ2 globals should take 0-1 milliseconds.
						/// Anything higher is unacceptable and demonstrably wrong.
						if (fElapsedTime > 4.0)
							iBadFrames++;
					}
					finally
					{
						Frame.Unlock();
					}
				}
				double fAverageTime = fTotalTimes / (double)iFramesElapsed;
				double fBadFramePercentage = (double)iBadFrames / (double)iFramesElapsed * 100;
				Log("Average time per object lookup was {0:0} ms, with {1:0.0}% of frames ({2} / {3}) lagging out.", fAverageTime, fBadFramePercentage, iBadFrames, iFramesElapsed);
				if (fAverageTime > 2 || fBadFramePercentage > 10)
				{
					Log("Aborting due to substantial ISXEQ2 lag. Please restart EQ2GlassCannon.");
					return;
				}
#endif

				/// Ensure that the INI path exists firstly.
				string strAppDataFolderPath = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
				strAppDataFolderPath = Path.Combine(strAppDataFolderPath, "EQ2GlassCannon");
				DirectoryInfo DataFolderInfo = Directory.CreateDirectory(strAppDataFolderPath);
				if (DataFolderInfo != null)
					s_strINIFolderPath = DataFolderInfo.FullName;
				else
					s_strINIFolderPath = Directory.GetCurrentDirectory(); // ehhhh not the best option but w/e...

				string strLastClass = string.Empty;
				bool bFirstZoningFrame = true;

				do
				{
					Frame.Wait(true);
					try
					{
						UpdateGlobals();

						/// Call the controller if we zone.
						if (EQ2.Zoning)
						{
							if (bFirstZoningFrame)
							{
								Program.Log("Zoning...");
								bFirstZoningFrame = false;

								if (s_Controller != null)
									s_Controller.OnZoning();

								/// Now's as good a time as any!
								Program.Log("Performing .NET garbage collection...");
								long lMemoryBeforeGarbageCollection = GC.GetTotalMemory(false);
								GC.Collect();
								long lMemoryAfterGarbageCollection = GC.GetTotalMemory(true);
								long lMemoryFreed = lMemoryBeforeGarbageCollection - lMemoryAfterGarbageCollection;
								Program.Log("{0} bytes freed.", lMemoryFreed);
							}
							continue;
						}
						else
						{
							if (!bFirstZoningFrame)
							{
								Program.Log("Done zoning.");
								bFirstZoningFrame = true;

								if (s_Controller != null)
									s_Controller.OnZoningComplete();

								ApplyGameSettings();

								/// We used to not have to do this, but something changed and fucked everything up.
								/// NOTE: We now catch exceptions during the ability caching.  This should be ok again.
								//s_bRefreshKnowledgeBook = true;
							}
						}

						/// A little thing I discovered while watching console spam.
						/// EQ2 will prefix your character name if you are watching that video.
						/// Pressing Escape kills it.
						if (Me.Group(0).Name.StartsWith("Flythrough_"))
						{
							Program.Log("Zone flythrough sequence detected, attempting to cancel with the Esc key...");
							LavishScriptAPI.LavishScript.ExecuteCommand("press esc");
							continue;
						}

						/// Yay for lazy!
						if (EQ2.PendingQuestName != "None")
						{
							EQ2.AcceptPendingQuest();

							/// TODO: Even though the quest gets accepted, the window doesn't disappear. We gotta make it disappear.
						}

						unchecked { s_lFrameCount++; }

						/// If the subclass changes (startup, betrayal, etc), resync.
						/// The null check on SubClass is because it comes up as null when reviving.
						/// s_Controller is guaranteed to be non-null after this block (otherwise the program would have exited).
						if (strLastClass != Me.SubClass && Me.SubClass != null)
						{
							Program.Log("New class found: " + Me.SubClass);
							strLastClass = Me.SubClass;
							s_bRefreshKnowledgeBook = true;

							switch (strLastClass.ToLower())
							{
								case "illusionist": s_Controller = new IllusionistController(); break;
								case "mystic": s_Controller = new MysticController(); break;
								case "templar": s_Controller = new TemplarController(); break;
								case "troubador": s_Controller = new TroubadorController(); break;
								case "warlock": s_Controller = new WarlockController(); break;
								case "wizard": s_Controller = new WizardController(); break;
								default:
								{
									Program.Log("Unrecognized or unsupported subclass type: {0}. Will use generic controller.", Me.SubClass);
									s_Controller = new PlayerController();
									break;
								}
							}

							/// Build the name of the INI file.
							string strFileName = string.Format("{0}.{1}.ini", EQ2.ServerName, Me.Name);
							s_strCurrentINIFilePath = Path.Combine(s_strINIFolderPath, strFileName);

							if (File.Exists(s_strCurrentINIFilePath))
								s_Controller.ReadINISettings();

							s_Controller.WriteINISettings();

							SetWindowText(string.Format("{0} ({1})", Me.Name, Me.SubClass));

							ApplyGameSettings();
						}

						/// If the size of the knowledge book changes, defer a resync.
						/// NOTE: If the user equips or unequips an ability-changing item,
						/// the ability table will be hosed but we'll have no way of knowing to force a refresh.
						if (Me.NumAbilities != s_Controller.m_iAbilitiesFound)
							s_bRefreshKnowledgeBook = true;

						/// Only if the knowledge book is intact can we safely assume that regular actions are OK.
						/// DoNextAction() might set s_bRefreshKnowledgeBook to true.  This is fine.
						if (!s_bRefreshKnowledgeBook)
							s_Controller.DoNextAction();

						/// Only check for camping or AFK every 5th frame.
						if ((s_lFrameCount % 5) == 0 && (Me.IsCamping))
						{
							Program.Log("Camping detected; aborting bot!");
							s_bContinueBot = false;
						}
					}
					finally
					{
						Frame.Unlock();
					}

					/// If we have to refresh the knowledge book, then do it outside of the main lock.
					/// This is because we'll use frame waits and can't risk breaking cached data.
					if (s_bRefreshKnowledgeBook)
					{
						s_Controller.RefreshKnowledgeBook();
						s_bRefreshKnowledgeBook = false;
					}

					/// Skip frames as configured.
					for (int iIndex = 0; iIndex < s_Controller.m_iFrameSkip; iIndex++)
					{
						LavishVMAPI.Frame.Wait(false);
						unchecked { s_lFrameCount++; }
					}
				}
				while (s_bContinueBot);

				/// Don't overwrite files that already exist unless told to; people might have special comments in place.
				if (!File.Exists(s_strCurrentINIFilePath) || s_Controller.m_bWriteBackINI)
				{
					s_Controller.WriteINISettings();
				}

				Log("Shutting down e-mail thread...");
				s_EmailQueueThread.PostQuitMessageAndShutdownQueue(false);
				if (s_EmailQueueThread.WaitForTermination(TimeSpan.FromSeconds(30.0)))
					Log("E-mail thread terminated.");
				else
					Log("E-mail thread timed out.");
			}

			/// I have only one try-catch frame because I don't want hidden logic bugs.
			/// Things should work perfectly or not at all.
			catch (Exception e)
			{
				StringBuilder ExceptionText = new StringBuilder();
				ExceptionText.AppendLine("Unhandled .NET exception: " + e.Message);
				ExceptionText.AppendLine(e.TargetSite.ToString());
				ExceptionText.AppendLine(e.StackTrace.ToString());
				string strExceptionText = ExceptionText.ToString();

				using (StreamWriter OutputFile = new StreamWriter(Path.Combine(s_strINIFolderPath, "ExceptionLog.txt")))
				{
					OutputFile.WriteLine("-----------------------------");
					OutputFile.WriteLine(strExceptionText);
				}

				/// Nothing will appear on the screen anyway because the whole thing is locked up.
				if (LavishVMAPI.Frame.IsLocked)
					Process.GetCurrentProcess().Kill();

				if (s_Controller != null)
					Program.RunCommand("/t " + s_Controller.m_strCommandingPlayer + " oh shit lol");

				Program.Log(strExceptionText); /// TODO: Extract and display the LINE that threw the exception!!!
			}

			finally
			{
				Program.Log("EQ2GlassCannon has terminated!");
			}

			return;
		}

		/************************************************************************************/
		private static void OnCastingEnded_EventHandler(object sender, LSEventArgs e)
		{
			return;
		}

		/************************************************************************************/
		private static void OnChoiceWindowAppeared_EventHandler(object sender, LSEventArgs e)
		{
			try
			{
				if (s_Controller != null)
				{
					using (new FrameLock(true))
					{
						UpdateGlobals();
						s_Controller.OnChoiceWindowAppeared(s_Extension.ChoiceWindow());
					}
				}
			}
			catch
			{
				/// Do nothing. But at least the bot doesn't crash!
			}

			return;
		}

		/************************************************************************************/
		private static void OnIncomingChatText_EventHandler(object sender, LSEventArgs e)
		{
			try
			{
				int iChannel = int.Parse(e.Args[0]);
				string strMessage = e.Args[1];
				string strFrom = e.Args[2];

				if (s_Controller != null)
				{
					using (new FrameLock(true))
					{
						UpdateGlobals();
						s_Controller.OnIncomingChatText(iChannel, strFrom, strMessage);
					}
				}
			}
			catch
			{
				/// Do nothing. But at least the bot doesn't crash!
			}

			return;
		}

		/************************************************************************************/
		/// <summary>
		/// Handles every string that can possibly appear in a chat window.
		/// Might be useful for in-process parsing down the road!
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private static void OnIncomingText_EventHandler(object sender, LSEventArgs e)
		{
			string strChatText = e.Args[0];

			try
			{
				if (s_Controller != null)
				{
					using (new FrameLock(true))
					{
						UpdateGlobals();
						s_Controller.OnIncomingText(string.Empty, strChatText);
					}
				}
			}
			catch
			{
				/// Do nothing. But at least the bot doesn't crash!
			}

			return;
		}

		/************************************************************************************/
		private static void OnQuestOffered_EventHandler(object sender, LSEventArgs e)
		{
			/// Without exception. Yes we accept all quests (if the ISXEQ2 functionality existed...does it?).
			return;
		}

		/************************************************************************************/
		private static void OnFrame_EventHandler(object sender, LSEventArgs e)
		{
			if (!string.IsNullOrEmpty(s_strNewWindowTitle))
			{
				string strCommand = string.Format("windowtext {0}", s_strNewWindowTitle);

				using (new FrameLock(true))
					LavishScript.ExecuteCommand(strCommand);
				
				s_strNewWindowTitle = null;
			}
			return;
		}

		/************************************************************************************/
		public static void SetWindowText(string strText)
		{
			s_strNewWindowTitle = strText;
			return;
		}

		/************************************************************************************/
		private static Dictionary<string, DateTime> m_RecentThrottledCommandIndex = new Dictionary<string, DateTime>();
		private static readonly TimeSpan s_CommandThrottleTimeout = TimeSpan.FromSeconds(10);

		/************************************************************************************/
		/// <summary>
		/// I hate trying to remember the syntax, so I hid it behind this function.
		/// </summary>
		/// <param name="bThrottled">Whether or not to prevent immediate duplicates of the same command until a certain time has passed.</param>
		/// <param name="strCommand"></param>
		public static void RunCommand(bool bThrottled, string strCommand, params object[] aobjParams)
		{
			if (string.IsNullOrEmpty(strCommand))
				return;

			try
			{
				string strFinalCommand = string.Empty;

				if (aobjParams.Length == 0)
					strFinalCommand += string.Format("{0}", strCommand);
				else
					strFinalCommand += string.Format(strCommand, aobjParams);

				/// Throttle it only if the parameter says so.
				if (bThrottled && m_RecentThrottledCommandIndex.ContainsKey(strFinalCommand))
				{
					if (DateTime.Now - m_RecentThrottledCommandIndex[strFinalCommand] > s_CommandThrottleTimeout)
						m_RecentThrottledCommandIndex.Remove(strFinalCommand);
					else
						return;
				}

				using (new FrameLock(true))
				{
					s_Extension.EQ2Execute(strFinalCommand);
				}

				m_RecentThrottledCommandIndex.Add(strFinalCommand, DateTime.Now);
			}
			catch
			{
			}

			return;
		}

		/************************************************************************************/
		/// <summary>
		/// This version of RunCommand DEFAULTS TO NON-THROTTLED.
		/// </summary>
		/// <param name="strCommand"></param>
		/// <param name="aobjParams"></param>
		public static void RunCommand(string strCommand, params object[] aobjParams)
		{
			RunCommand(false, strCommand, aobjParams);
			return;
		}

		/************************************************************************************/
		public static void ApplyVerb(int iActorID, string strVerb)
		{
			RunCommand(true, "/apply_verb {0} {1}", iActorID, strVerb);
			return;
		}

		/************************************************************************************/
		public static void ApplyVerb(Actor ThisActor, string strVerb)
		{
			Log("Applying verb \"{0}\" on actor \"{1}\" (ID: \"{2}\").", strVerb, ThisActor.Name, ThisActor.ID);
			ApplyVerb(ThisActor.ID, strVerb);
			return;
		}

		/************************************************************************************/
		/// <summary>
		/// Using Thread.Sleep() during a frame lock, locks up the client.
		/// </summary>
		/// <param name="ThisTimeSpan"></param>
		public static void DeadWait(TimeSpan ThisTimeSpan)
		{
			Thread.Sleep((int)ThisTimeSpan.TotalMilliseconds);
			return;
		}

		/************************************************************************************/
		public static void FrameWait(TimeSpan ThisTimeSpan)
		{
			DateTime WaitEndTime = DateTime.Now + ThisTimeSpan;

			while (DateTime.Now < WaitEndTime)
				LavishVMAPI.Frame.Wait(false);

			return;
		}
	}
}
