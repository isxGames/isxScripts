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
using System.Speech.Synthesis;
using System.Collections;

namespace EQ2GlassCannon
{
	public static class Program
	{
		private static Extension s_Extension = null;
		private static EQ2.ISXEQ2.ISXEQ2 s_ISXEQ2 = null;
		private static EQ2.ISXEQ2.EQ2 s_EQ2 = null;
		private static EQ2Event s_eq2event = null;
		public static string ServerName { get { return s_EQ2.ServerName; } }

		private static SpeechSynthesizer s_SpeechSynthesizer = null;

		private static Character s_Me = null;
		public static Character Me { get { return s_Me; } }

		private static Actor s_MeActor = null;
		public static Actor MeActor { get { return s_MeActor; } }

		private static bool s_bIsZoning = false;
		public static bool IsZoning { get { return s_bIsZoning; } }

		private static bool s_bIsFlythroughVideoPlaying = false;
		public static bool IsFlythroughVideoPlaying { get { return s_bIsFlythroughVideoPlaying; } }

		private static PlayerController s_Controller = null;
		public static EmailQueueThread s_EmailQueueThread = new EmailQueueThread();
		public static bool s_bContinueBot = true;
		public static bool s_bRefreshKnowledgeBook = false;
		private static long s_lFrameCount = 0;
		public static string s_strINIFolderPath = string.Empty;
		public static string s_strCurrentINIFilePath = string.Empty;
		public static string s_strSharedOverridesINIFilePath = string.Empty;
		private static string s_strNewWindowTitle = null;
		private static SetCollection<string> s_PressedKeys = new SetCollection<string>();
		private static Dictionary<string, DateTime> m_RecentThrottledCommandIndex = new Dictionary<string, DateTime>();

		/************************************************************************************/
		/// <summary>
		/// Make sure to call this every time you grab a frame lock.
		/// I've had to compensate in far too many ways for exception bullshit that gets thrown on property access.
		/// The wrapper is behaving pretty fucking sloppy and it vexes me.
		/// </summary>
		public static bool UpdateGlobals()
		{
			/// These become invalid from frame to frame.
			try
			{
				if (s_ISXEQ2 == null)
					s_ISXEQ2 = s_Extension.ISXEQ2();
				if (s_EQ2 == null)
					s_EQ2 = s_Extension.EQ2();
				if (s_Me == null)
					s_Me = s_Extension.Me();
			}
			catch
			{
				Log("Exception thrown when updating global variable aliases for the frame lock.");
				return false;
			}

			try
			{
				s_bIsZoning = s_EQ2.Zoning;
			}
			catch
			{
				/// This is an annoying quirk. It throws an exception only during zoning.
				Log("Exception thrown when accessing EQ2.Zoning. Assuming the value to be \"true\".");
				s_bIsZoning = true;
			}

			if (!s_bIsZoning)
			{
				try
				{
					s_MeActor = s_Me.ToActor();
				}
				catch
				{
					Log("Exception thrown when accessing self actor.");
					return false;
				}

				try
				{
					/// A little thing I discovered while watching console spam.
					/// EQ2 will prefix your character name if you are watching that video.
					s_bIsFlythroughVideoPlaying = Me.Group(0).Name.StartsWith("Flythrough_");
				}
				catch
				{
					s_bIsFlythroughVideoPlaying = false;
				}
			}

			return true;
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
				Frame.Wait(false);
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
			Log("Applying preferential account settings (music volume, personal torch, welcome screen).");
			RunCommand("/music_volume 0");
			RunCommand("/r_personal_torch off");
			RunCommand("/cl_show_welcome_screen_on_startup 0");
			return;
		}

		/************************************************************************************/
		private static void Main()
		{
			try
			{
				Program.Log("Starting EQ2GlassCannon spellcaster bot...");
				s_EmailQueueThread.Start();

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
						if (!UpdateGlobals())
						{
							Log("UpdateGlobals() failed right away. Aborting.");
							return;
						}

						if (s_ISXEQ2.IsReady)
							break;
					}
				}

				using (new FrameLock(true))
				{
					if (UpdateGlobals())
						s_ISXEQ2.SetActorEventsRange(50.0f);

					s_eq2event = new EQ2Event();
					s_eq2event.ChoiceWindowAppeared += new EventHandler<LSEventArgs>(OnChoiceWindowAppeared_EventHandler);
					s_eq2event.RewardWindowAppeared += new EventHandler<LSEventArgs>(OnRewardWindowAppeared_EventHandler);
					s_eq2event.IncomingChatText += new EventHandler<LSEventArgs>(OnIncomingChatText_EventHandler);
					s_eq2event.IncomingText += new EventHandler<LSEventArgs>(OnIncomingText_EventHandler);

					Program.AddCommand(
						"gc_changesetting",
						"gc_exit",
						"gc_findactor",
						"gc_openini",
						"gc_openoverridesini",
						"gc_reloadsettings",
						"gc_stance",
						"gc_spawnwatch");
				}

#if !DEBUG
				double fTestTime = 2.0;

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

				s_strSharedOverridesINIFilePath = Path.Combine(s_strINIFolderPath, "SharedOverrides.ini");
				if (!File.Exists(s_strSharedOverridesINIFilePath))
					File.Create(s_strSharedOverridesINIFilePath).Close();

				string strLastClass = string.Empty;
				bool bFirstZoningFrame = true;

				do
				{
					Frame.Wait(true);
					try
					{
						if (!UpdateGlobals())
							continue;

						/// Call the controller if we zone.
						if (IsZoning)
						{
							if (bFirstZoningFrame)
							{
								Program.Log("Zoning...");
								bFirstZoningFrame = false;

								ReleaseAllKeys();
								if (s_Controller != null)
									s_Controller.OnZoning();

								/// Tell the garbage collector to do a full collect. Now's as good a time as any!
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
							}
						}

						/// Pressing Escape kills it.
						if (IsFlythroughVideoPlaying)
						{
							Program.Log("Zone flythrough sequence detected, attempting to cancel with the Esc key...");
							LavishScriptAPI.LavishScript.ExecuteCommand("press esc");
							continue;
						}

						/// Yay for lazy!
						if (!string.IsNullOrEmpty(s_EQ2.PendingQuestName) && s_EQ2.PendingQuestName != "None")
						{
							Log("Quest offered: \"{0}\".", s_EQ2.PendingQuestName);

							/// Stolen from "EQ2Quest.iss". The question I have: isn't AcceptPendingQuest() redundant then?
							EQ2UIPage QuestPage = s_Extension.EQ2UIPage("Popup", "RewardPack");
							if (QuestPage.IsValid)
							{
								EQ2UIElement QuestAcceptButton = QuestPage.Child("button", "RewardPack.Accept");
								if (QuestAcceptButton.IsValid)
								{
									Log("Automatically accepting quest \"{0}\"...", s_EQ2.PendingQuestName);
									s_EQ2.AcceptPendingQuest();
									QuestAcceptButton.LeftClick();
								}
							}
						}

						unchecked { s_lFrameCount++; }

						/// If the subclass changes (startup, betrayal, etc), resync.
						/// The null check on SubClass is because it comes up as null when reviving.
						/// s_Controller is guaranteed to be non-null after this block (otherwise the program would have exited).
						if (!string.IsNullOrEmpty(Me.SubClass) && Me.SubClass != strLastClass)
						{
							Program.Log("New class found: \"{0}\"", Me.SubClass);
							strLastClass = Me.SubClass;
							s_bRefreshKnowledgeBook = true;

							switch (strLastClass.ToLower())
							{
								case "illusionist": s_Controller = new IllusionistController(); break;
								case "mystic": s_Controller = new MysticController(); break;
								case "templar": s_Controller = new TemplarController(); break;
								case "troubador": s_Controller = new TroubadorController(); break;
								case "warden": s_Controller = new WardenController(); break;
								case "warlock": s_Controller = new WarlockController(); break;
								case "wizard": s_Controller = new WizardController(); break;
								default:
								{
									Program.Log("Unrecognized or unsupported subclass type: {0}.", Me.SubClass);
									Program.Log("Will use generic controller without support for spells or combat arts.");
									s_Controller = new PlayerController();
									break;
								}
							}

							/// Build the name of the INI file.
							string strFileName = string.Format("{0}.{1}.ini", ServerName, Me.Name);
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
						if (s_Controller.m_bKillBotWhenCamping && (s_lFrameCount % 5) == 0 && (Me.IsCamping))
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
						Frame.Wait(false);
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
				OnUnhandledException(e);

				/// Nothing will appear on the screen anyway because the whole thing is locked up.
				if (LavishVMAPI.Frame.IsLocked)
					Process.GetCurrentProcess().Kill();

				if (s_Controller != null)
					Program.RunCommand("/t " + s_Controller.m_strCommandingPlayer + " oh shit lol");
			}

			finally
			{
				Program.Log("EQ2GlassCannon has terminated!");
			}

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
		private static void OnRewardWindowAppeared_EventHandler(object sender, LSEventArgs e)
		{
			try
			{
				if (s_Controller != null)
				{
					using (new FrameLock(true))
					{
						UpdateGlobals();
						s_Controller.OnRewardWindowAppeared(s_Extension.RewardWindow());
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
		private static int OnLavishScriptCommand(string[] astrArgs)
		{
			try
			{

				if (s_Controller != null)
				{
					List<string> astrArgList = new List<string>(astrArgs);
					astrArgList.RemoveAt(0);
					using (new FrameLock(true))
						s_Controller.OnCustomSlashCommand(astrArgs[0].ToLower(), astrArgList.ToArray());
				}
			}
			catch (Exception e)
			{
				OnUnhandledException(e);
			}

			return 0;
		}

		/************************************************************************************/
		public static void SetWindowText(string strText)
		{
			s_strNewWindowTitle = strText;
			return;
		}

		/************************************************************************************/
		/// <summary>
		/// I hate trying to remember the syntax, so I hid it behind this function.
		/// </summary>
		/// <param name="bThrottled">Whether or not to prevent immediate duplicates of the same command until a certain time has passed.</param>
		/// <param name="strCommand"></param>
		public static void RunCommand(double fBlockageSeconds, string strCommand, params object[] aobjParams)
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
				if (fBlockageSeconds > 0.0 && m_RecentThrottledCommandIndex.ContainsKey(strFinalCommand))
				{
					if (DateTime.Now > m_RecentThrottledCommandIndex[strFinalCommand])
						m_RecentThrottledCommandIndex.Remove(strFinalCommand);
					else
					{
						Log("Throttled command blocked: {0}", strFinalCommand);
						return;
					}
				}

				using (new FrameLock(true))
				{
					if (UpdateGlobals())
					{
						Log("Executing: {0}", strFinalCommand);
						s_Extension.EQ2Execute(strFinalCommand);
					}
				}

				m_RecentThrottledCommandIndex.Add(strFinalCommand, DateTime.Now + TimeSpan.FromSeconds(fBlockageSeconds));
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
			RunCommand(0, strCommand, aobjParams);
			return;
		}

		/************************************************************************************/
		public static void ApplyVerb(int iActorID, string strVerb)
		{
			RunCommand(5, "/apply_verb {0} {1}", iActorID, strVerb);
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
		public static IEnumerable<Actor> EnumActors(params string[] astrParams)
		{
			s_EQ2.CreateCustomActorArray(astrParams);

			for (int iIndex = 1; iIndex <= s_EQ2.CustomActorArraySize; iIndex++)
				yield return s_Extension.CustomActor(iIndex);
		}

		/************************************************************************************/
		/// <summary>
		/// Frame lock is assumed to be held before this function is called.
		/// </summary>
		public static Actor GetNonPetActor(string strName)
		{
			Actor PlayerActor = s_Extension.Actor(strName);

			/// Try again if it's invalid or it's a pet.
			if (!PlayerActor.IsValid || PlayerActor.IsAPet)
			{
				PlayerActor = s_Extension.Actor(strName, "notid", PlayerActor.ID.ToString());
			}

			if (!PlayerActor.IsValid || PlayerActor.IsAPet)
				PlayerActor = null;

			return PlayerActor;
		}

		/************************************************************************************/
		public static Actor GetActor(int iActorID)
		{
			try
			{
				return s_Extension.Actor(iActorID);
			}
			catch
			{
				Log("Exception thrown when looking up actor {0}.", iActorID);
				return null;
			}
		}

		/************************************************************************************/
		public static Actor GetActor(string strActorID)
		{
			try
			{
				return s_Extension.Actor(strActorID);
			}
			catch
			{
				Log("Exception thrown when looking up actor {0}.", strActorID);
				return null;
			}
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
				Frame.Wait(false);

			return;
		}

		/************************************************************************************/
		public static void PressAndHoldKey(string strKey)
		{
			string strIndexedKey = strKey.ToLower().Trim();
			if (!s_PressedKeys.Contains(strIndexedKey))
			{
				Log("Pressing and holding keyboard key: {0}", strKey);
				LavishScriptAPI.LavishScript.ExecuteCommand("press -hold " + strKey);
				s_PressedKeys.Add(strIndexedKey);
			}
			return;
		}

		/************************************************************************************/
		/// <summary>
		/// Releases a key but only if we remember pressing it in the first place.
		/// This prevents interference with user action.
		/// </summary>
		public static void ReleaseKey(string strKey)
		{
			string strIndexedKey = strKey.ToLower().Trim();
			if (s_PressedKeys.Contains(strIndexedKey))
			{
				Log("Releasing keyboard key: {0}", strKey);
				LavishScriptAPI.LavishScript.ExecuteCommand("press -release " + strKey);
				s_PressedKeys.Remove(strIndexedKey);
			}
			return;
		}

		/************************************************************************************/
		public static void ReleaseAllKeys()
		{
			foreach (string strThisKey in s_PressedKeys)
			{
				LavishScriptAPI.LavishScript.ExecuteCommand("press -release " + strThisKey);
			}
			s_PressedKeys.Clear();
			return;
		}

		/************************************************************************************/
		public static void AddCommand(params string[] astrCommandNames)
		{
			foreach (string strCommand in astrCommandNames)
			{
				LavishScriptAPI.LavishScript.Commands.AddCommand(strCommand, OnLavishScriptCommand);
			}
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
						OnUnhandledException(e);
					}
				}
			);
			return;
		}

		/************************************************************************************/
		public static void OnUnhandledException(Exception e)
		{
			StringBuilder ExceptionText = new StringBuilder();
			ExceptionText.AppendLine("Unhandled .NET exception: " + e.Message);
			ExceptionText.AppendLine(e.TargetSite.ToString());
			ExceptionText.AppendLine(e.StackTrace.ToString());
			string strExceptionText = ExceptionText.ToString();

			using (StreamWriter OutputFile = new StreamWriter(Path.Combine(s_strINIFolderPath, "ExceptionLog.txt"), true))
			{
				OutputFile.WriteLine("-----------------------------");
				OutputFile.WriteLine(strExceptionText);
			}

			Program.Log(strExceptionText); /// TODO: Extract and display the LINE that threw the exception!!!
			return;
		}

		/************************************************************************************/
		public static void ToggleSpeechSynthesizer(bool bActivate, int iVolume, string strVoiceProfile)
		{
			if (bActivate)
			{
				if (s_SpeechSynthesizer == null)
					s_SpeechSynthesizer = new SpeechSynthesizer();
				s_SpeechSynthesizer.Volume = iVolume;

				try
				{
					s_SpeechSynthesizer.SelectVoice(strVoiceProfile);
				}
				catch
				{
					/// If no voice is found, use the first installed one we find.
					foreach (InstalledVoice ThisVoice in s_SpeechSynthesizer.GetInstalledVoices())
					{
						s_SpeechSynthesizer.SelectVoice(ThisVoice.VoiceInfo.Name);
						break;
					}
				}
			}
			else
			{
				if (s_SpeechSynthesizer != null)
				{
					s_SpeechSynthesizer.Dispose();
					s_SpeechSynthesizer = null;
				}
			}
		}

		/************************************************************************************/
		public static void SayText(string strFormat, params object[] aobjParams)
		{
			string strOutput = string.Format(strFormat, aobjParams);
			if (string.IsNullOrEmpty(strOutput))
				return;

			if (s_Controller != null && s_Controller.m_bUseVoiceSynthesizer && s_SpeechSynthesizer != null)
				s_SpeechSynthesizer.SpeakAsync(string.Format(strFormat, aobjParams));

			return;
		}
	}
}
