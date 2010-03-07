using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2.ISXEQ2;
using LavishVMAPI;
using LavishScriptAPI;
using System.Threading;
using System.IO;
using System.Speech.Synthesis;
using EQ2ParseEngine;
using EQ2SuiteLib;
using System.Diagnostics;

namespace EQ2GlassCannon
{
	/// Basically the entire bot is run out of here, so that only a static PlayerController can access the values
	/// in the dynamically allocated PlayerControllers, and vice versa.
	/// Outside classes are not allowed to peek inside.
	public partial class PlayerController
	{
		private static Extension s_Extension = null;
		private static EQ2.ISXEQ2.ISXEQ2 s_ISXEQ2 = null;
		private static EQ2.ISXEQ2.EQ2 s_EQ2 = null;
		private static EQ2Event s_eq2event = null;
		private static SpeechSynthesizer s_SpeechSynthesizer = null;

		private static Character s_Me = null;
		protected static Character Me { get { return s_Me; } }

		private static Actor s_MeActor = null;
		protected static Actor MeActor { get { return s_MeActor; } }

		private static string s_strName = string.Empty;
		/// <summary>
		/// The current player's own name. Cached during UpdateStaticGlobals().
		/// </summary>
		protected static string Name { get { return s_strName; } }

		private static int s_iAbilityCount = 0;
		protected static int AbilityCount { get { return s_iAbilityCount; } }

		private static bool s_bIsIdle = false;
		protected static bool IsIdle { get { return s_bIsIdle; } }

		private static bool s_bIsCastingAbility = false;

		private static bool s_bIsInCombat = false;
		protected static bool IsInCombat { get { return s_bIsInCombat; } }

		private static bool s_bIsInRaid = false;
		protected static bool IsInRaid { get { return s_bIsInRaid; } }

		private static bool s_bIsInGroup = false;
		protected static bool IsInGroup { get { return s_bIsInGroup; } }

		protected static string ServerName { get { return s_EQ2.ServerName; } }

		private static long s_lFrameCount = 0;
		protected static long FrameCount { get { return s_lFrameCount; } }

		private static DateTime s_CurrentCycleTimestamp = DateTime.Now;
		/// <summary>
		/// I want every time calculation inside a game cycle to use the same reference point for the current time.
		/// Plus it is more efficient to only call "DateTime.Now" once per frame.
		/// </summary>
		protected static DateTime CurrentCycleTimestamp { get { return s_CurrentCycleTimestamp; } }

		private static ParseThread s_ParseThread = new ParseThread();
		private static ThreadSafeQueue<ConsoleLogEventArgs> s_ChatEventQueue = new ThreadSafeQueue<ConsoleLogEventArgs>();
		private static PlayerController s_Controller = null;
		private static bool s_bContinueBot = true;
		private static bool s_bRefreshKnowledgeBook = false;
		private static string s_strKnowledgeBookDumpPath = null;
		private static string s_strCurrentINIFilePath = string.Empty;
		private static string s_strSharedOverridesINIFilePath = string.Empty;
		private static string s_strNewWindowTitle = null;
		private static SetCollection<string> s_PressedKeys = new SetCollection<string>();
		private static Dictionary<string, DateTime> s_RecentThrottledCommandCache = new Dictionary<string, DateTime>();
		private static SetCollection<string> s_RegisteredCustomSlashCommands = new SetCollection<string>();
		private readonly static LavishScriptAPI.Delegates.CommandTarget s_CustomSlashCommandDelegate = OnLavishScriptCommand;
		private static string s_strLastLootWindowID = string.Empty;

		/************************************************************************************/
		protected static bool UpdateStaticGlobals()
		{
			/// These become invalid from frame to frame.
			/// I find that a LOT of Character members throw exceptions.
			/// I may need to cache them here the same way I cache abilities.
			try
			{
				s_MeActor = s_Me.ToActor();
				s_strName = Me.Name;
				s_iAbilityCount = Me.NumAbilities;
				s_bIsIdle = MeActor.IsIdle;
				s_bIsCastingAbility = Me.CastingSpell;
				s_bIsInCombat = (Me.IsHated || MeActor.InCombatMode);
				s_bIsInRaid = Me.InRaid;
				s_bIsInGroup = Me.Grouped;
			}
			catch
			{
				Program.Log("Exception thrown when updating global variable aliases for the frame lock.");
				return false;
			}

			return true;
		}

		/************************************************************************************/
		public static bool Initialize()
		{
			Program.Log("Waiting for ISXEQ2 to initialize...");

			using (new FrameLock(true))
			{
				/// Just use this for debugging; otherwise it crashes the client when the bot terminates.
				//LavishScript.RequireExplicitFrameLock = true;

				s_Extension = new Extension();

				/// Patch notes say these are now persistant.
				s_ISXEQ2 = s_Extension.ISXEQ2();
				s_EQ2 = s_Extension.EQ2();
				s_Me = s_Extension.Me();

				LavishScript.Events.AttachEventTarget(LavishScript.Events.RegisterEvent("OnFrame"), OnFrame_EventHandler);
			}

			while (true)
			{
				using (new FrameLock(true))
				{
					if (s_ISXEQ2.IsReady)
						break;
				}
			}

			using (new FrameLock(true))
			{
				s_ISXEQ2.SetActorEventsRange(50.0f);

				s_eq2event = new EQ2Event();
				s_eq2event.ChoiceWindowAppeared += new EventHandler<LSEventArgs>(OnChoiceWindowAppeared_EventHandler);
				s_eq2event.RewardWindowAppeared += new EventHandler<LSEventArgs>(OnRewardWindowAppeared_EventHandler);
				s_eq2event.LootWindowAppeared += new EventHandler<LSEventArgs>(OnLootWindowAppeared_EventHandler);
				s_eq2event.IncomingText += new EventHandler<LSEventArgs>(OnIncomingText_EventHandler);

				RegisterCustomSlashCommands(
					"gc_assist",
					"gc_attack",
					"gc_attackassist",
					"gc_cancelgroupbuffs",
					"gc_changesetting",
					"gc_debug",
					"gc_defaultverb",
					"gc_distance",
					"gc_dumpabilities",
					"gc_exit",
					"gc_exitprocess",
					"gc_findactor",
					"gc_openini",
					"gc_openoverridesini",
					"gc_reloadsettings",
					"gc_stance",
					"gc_spawnwatch",
					"gc_target",
					"gc_trackactor",
					"gc_tts",
					"gc_version",
					"gc_withdraw");
			}

			return true;
		}

		/************************************************************************************/
		public static bool TestSpeed()
		{
			double fTestTime = 2.0;

			/// This giant code chunk was a huge necessity due to the completely random lag that happens
			/// inside the UpdateGlobals() function. A laggy launch will never free up and a free launch
			/// will never get laggy.  Thus we veto laggy launches and tell the user to re-launch.
			Program.Log("Testing the speed of root object lookup. Please wait {0:0.0} seconds...", fTestTime);
			int iFramesElapsed = 0;
			int iBadFrames = 0;
			double fTotalTimes = 0.0;
			DateTime SlowFrameTestStartTime = DateTime.Now;
			while (DateTime.Now - SlowFrameTestStartTime < TimeSpan.FromSeconds(fTestTime))
			{
				iFramesElapsed++;
				Frame.Wait(true);
				try
				{
					DateTime BeforeTime = DateTime.Now;
					PlayerController.UpdateStaticGlobals(); /// This is the line we're testing.
					DateTime AfterTime = DateTime.Now;

					double fElapsedTime = (AfterTime - BeforeTime).TotalMilliseconds;
					fTotalTimes += fElapsedTime;
					//Program.Log("{0} : {1:0.0}", iFramesElapsed, fElapsedTime);

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
			double fFramesPerSecond = (double)iFramesElapsed / (DateTime.Now - SlowFrameTestStartTime).TotalSeconds;
			double fAverageTime = fTotalTimes / (double)iFramesElapsed;
			double fBadFramePercentage = (double)iBadFrames / (double)iFramesElapsed * 100;
			Program.Log("Average time per object lookup was {0:0} ms, with {1:0.0}% of frames ({2} / {3}) lagging out ({4:0.0} FPS).", fAverageTime, fBadFramePercentage, iBadFrames, iFramesElapsed, fFramesPerSecond);
#if DEBUG
			if (fFramesPerSecond < 10)
#else
			if (fAverageTime > 2 || fBadFramePercentage > 10)
#endif
			{
				Program.Log("Aborting due to substantial ISXEQ2 lag. Please restart EQ2GlassCannon.");
				return false;
			}

			return true;
		}

		/************************************************************************************/
		public static void Run()
		{
			s_ParseThread.Start();

			s_strSharedOverridesINIFilePath = Path.Combine(Program.ConfigurationFolderPath, "SharedOverrides.ini");
			if (!File.Exists(s_strSharedOverridesINIFilePath))
				File.Create(s_strSharedOverridesINIFilePath).Close();

			string strPreviousSubClass = string.Empty;
			string strPreviousName = string.Empty;
			bool bFirstZoningFrame = true;
			bool bRunGarbageCollector = false;

			do
			{
				s_CurrentCycleTimestamp = DateTime.Now;

				/// Run this outside of the frame lock.
				if (bRunGarbageCollector)
				{
					Program.RunGarbageCollector();
					bRunGarbageCollector = false;
				}

				Frame.Wait(true);
				try
				{
					/// Call the controller if we zone. During zoning, no game variables are assumed to be worth a damn.
					/// We go straight to a string check for now instead of the property (which uses <int> conversion)
					/// because the property has had a troubled past and returned buggy/invalid values.
					if (s_EQ2.GetMember<string>("Zoning") != "0")
					{
						if (bFirstZoningFrame)
						{
							Program.Log("Zoning...");
							bFirstZoningFrame = false;

							ReleaseAllKeys();
							s_RecentThrottledCommandCache.Clear();
							if (s_Controller != null)
								s_Controller.OnZoningBegin();

							bRunGarbageCollector = true;
						}
						continue;
					}
					else
					{
						if (!UpdateStaticGlobals())
							continue;

						if (!bFirstZoningFrame)
						{
							Program.Log("Done zoning.");
							bFirstZoningFrame = true;

							if (s_Controller != null)
								s_Controller.OnZoningComplete();

							ApplyGameSettings();
						}
					}

					try
					{
						/// An amazing little thing I discovered while watching console spam.
						/// EQ2 will prefix your character name if you are watching a flythrough zone intro video.
						/// Pressing Escape kills it.
						if (Me.Group(0).Name.StartsWith("Flythrough_"))
						{
							Program.Log("Zone flythrough sequence detected, attempting to cancel with the Esc key...");
							LavishScript.ExecuteCommand("press esc");
							continue;
						}
					}
					catch
					{
					}


					/// Automatically accept a quest.
					if (s_Controller != null && !string.IsNullOrEmpty(s_EQ2.PendingQuestName) && s_EQ2.PendingQuestName != "None")
					{
						Program.Log("Quest offered: \"{0}\".", s_EQ2.PendingQuestName);

						if (s_Controller.m_ePositioningStance == PlayerController.PositioningStance.DoNothing)
							Program.Log("Character is in do-nothing stance; ignoring offered quest.");
						else
						{
							/// Stolen from "EQ2Quest.iss". The question I have: isn't AcceptPendingQuest() redundant then?
							/// eq2ui_popup_rewardpack.xml
							EQ2UIPage QuestPage = s_Extension.EQ2UIPage("Popup", "RewardPack");
							if (QuestPage.IsValid)
							{
								EQ2UIElement QuestAcceptButton = QuestPage.Child("button", "RewardPack.Accept");
								if (QuestAcceptButton.IsValid)
								{
									Program.Log("Automatically accepting quest \"{0}\"...", s_EQ2.PendingQuestName);
									s_EQ2.AcceptPendingQuest();
									QuestAcceptButton.LeftClick();
								}
							}
						}
					}

					unchecked { s_lFrameCount++; }

					/// Make sure the parse engine always knows the current character name.
					/// Unfortunately, there's no way to know the current language at this time.
					if (Name != strPreviousName)
					{
						s_ParseThread.PostNewNameLanguageMessage(Name, ChatEventArgs.GameLanguageType.Unknown);
						strPreviousName = Name;
					}

					/// If the subclass changes (startup, betrayal, etc), resync.
					/// The null check on SubClass is because it comes up as null when reviving.
					/// s_Controller is guaranteed to be non-null after this block (otherwise the program would have exited).
					/// TODO: State variables contained in the prior controller will be lost. Maybe make them static?
					if (!string.IsNullOrEmpty(Me.SubClass) && Me.SubClass != strPreviousSubClass)
					{
						Program.Log("New class found: \"{0}\"", Me.SubClass);
						strPreviousSubClass = Me.SubClass;
						s_bRefreshKnowledgeBook = true;

						switch (strPreviousSubClass.ToLower())
						{
							case "coercer": s_Controller = new CoercerController(); break;
							case "defiler": s_Controller = new DefilerController(); break;
							case "dirge": s_Controller = new DirgeController(); break;
							case "fury": s_Controller = new FuryController(); break;
							case "illusionist": s_Controller = new IllusionistController(); break;
							case "inquisitor": s_Controller = new InquisitorController(); break;
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
						string strFileName = string.Format("{0}.{1}.ini", ServerName, Name);
						s_strCurrentINIFilePath = Path.Combine(Program.ConfigurationFolderPath, strFileName);

						if (File.Exists(s_strCurrentINIFilePath))
							s_Controller.ReadINISettings();

						s_Controller.WriteINISettings();

						SetWindowText(string.Format("{0} ({1})", Name, Me.SubClass));

						ApplyGameSettings();
					}

					/// If the size of the knowledge book changes, defer a resync.
					/// NOTE: If the user equips or unequips an ability-changing item,
					/// the ability table will be hosed but we'll have no way of knowing to force a refresh.
					if (s_Controller.AbilityCountChanged)
						s_bRefreshKnowledgeBook = true;

					/// Only if the knowledge book is intact can we safely assume that regular actions are OK.
					/// DoNextAction() might set s_bRefreshKnowledgeBook to true.  This is fine.
					if (!s_bRefreshKnowledgeBook)
					{
						/// Handle all the log events that were generated by the parse thread so far.
						ConsoleLogEventArgs NewArgs = null;
						while (s_ChatEventQueue.Dequeue(ref NewArgs))
						{
							if (NewArgs is ChatEventArgs)
								s_Controller.OnLogChat(NewArgs as ChatEventArgs);
							else
								s_Controller.OnLogNarrative(NewArgs);
						}

						s_Controller.DoNextAction();
						s_Controller.UpdateEndOfRoundStatistics();
					}

					/// Do certain checks only every 5th frame.
					if ((s_lFrameCount % 5) == 0)
					{
						/// Supposedly Process.VirtualMemorySize64 can return negative values because of casting bugs.
						Process CurrentProcess = Process.GetCurrentProcess();
						long lActualVirtualAllocation = CurrentProcess.VirtualMemorySize64;
						if (lActualVirtualAllocation > (long)s_Controller.m_ulVirtualAllocationProcessTerminationThreshold &&
							lActualVirtualAllocation < (long)(4 * CustomFormatter.GB)) /// This check	is to prevent impossible values from causing crashes.
						{
							/// GAME OVER.
							using (StreamWriter OutputFile = Program.OpenCrashLog())
								OutputFile.WriteLine("Process terminating immediately: current virtual allocation is {0}.", CustomFormatter.FormatByteCount(CurrentProcess.VirtualMemorySize64, "0.00"));
							CurrentProcess.Kill();
						}

						if (s_Controller.m_bKillBotWhenCamping && Me.IsCamping)
						{
							Program.Log("Camping detected; aborting bot!");
							s_bContinueBot = false;
						}
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

			Program.Log("Shutting down parser thread...");
			s_ParseThread.PostQuitMessageAndShutdownQueue(true);
			if (s_ParseThread.WaitForTermination(TimeSpan.FromSeconds(30.0)))
				Program.Log("Parser thread terminated.");
			else
				Program.Log("Parser thread timed out.");
			return;
		}

		/************************************************************************************/
		/// <summary>
		/// This is meant to get called by the parse thread.
		/// </summary>
		/// <param name="NewEvent"></param>
		public static void EnqueueLogEvent(ConsoleLogEventArgs NewEvent)
		{
			s_ChatEventQueue.Enqueue(NewEvent);
			return;
		}

		/************************************************************************************/
		protected static void ApplyGameSettings()
		{
			/// We could do this once at the beginning, but I've seen it not take.
			Program.Log("Applying preferential configuration settings.");
			RunCommand("/music_volume 0");
			RunCommand("/r_personal_torch off");
			RunCommand("/cl_show_welcome_screen_on_startup off");
			return;
		}

		/************************************************************************************/
		protected static void SetWindowText(string strText)
		{
			s_strNewWindowTitle = strText;
			return;
		}

		/************************************************************************************/
		/// <summary>
		/// </summary>
		/// <param name="fBlockageSeconds">The number of seconds to wait before allowing any other copy of the same command to run. If 0, then there will be no throttling.</param>
		/// <param name="strCommand"></param>
		protected static bool RunCommand(double fBlockageSeconds, string strCommandLineFormat, params object[] aobjParams)
		{
			if (string.IsNullOrEmpty(strCommandLineFormat))
				return false;

			try
			{
				string strFinalCommandLine = string.Empty;

				if (aobjParams.Length == 0)
					strFinalCommandLine += string.Format("{0}", strCommandLineFormat);
				else
					strFinalCommandLine += string.Format(strCommandLineFormat, aobjParams);

				/// Throttle it only if the parameter says so.
				/// The only time a command gets removed from the cache is during zoning.
				if (fBlockageSeconds > 0.0)
				{
					DateTime ExpirationTime = DateTime.FromBinary(0);
					if (s_RecentThrottledCommandCache.TryGetValue(strFinalCommandLine, out ExpirationTime))
					{
						/// Overwrite an old entry.
						if (CurrentCycleTimestamp > ExpirationTime)
							s_RecentThrottledCommandCache[strFinalCommandLine] = CurrentCycleTimestamp + TimeSpan.FromSeconds(fBlockageSeconds);
						else
						{
							Program.Log("Throttled command blocked: {0}", strFinalCommandLine);
							return false;
						}
					}
					else
						s_RecentThrottledCommandCache.Add(strFinalCommandLine, CurrentCycleTimestamp + TimeSpan.FromSeconds(fBlockageSeconds));
				}

				using (new FrameLock(true))
				{
					Program.Log("Executing: {0}", strFinalCommandLine);

					/// Break the command up as if it were a custom one.
					List<string> astrParameters = new List<string>(strFinalCommandLine.Split(new string[] { " " }, StringSplitOptions.RemoveEmptyEntries));
					string strCommand = astrParameters[0];
					if (strCommand[0] == '/')
						strCommand = strCommand.Substring(1);
					astrParameters.RemoveAt(0);

					/// We have to manually process custom commands, EQ2Execute does not handle them.
					if (s_RegisteredCustomSlashCommands.Contains(strCommand))
					{
						if (s_Controller != null && UpdateStaticGlobals())
							return s_Controller.OnCustomSlashCommand(strCommand, astrParameters.ToArray());
					}
					else
					{
						s_Extension.EQ2Execute(strFinalCommandLine);
						return true;
					}
				}
			}
			catch
			{
			}

			return true;
		}

		/************************************************************************************/
		/// <summary>
		/// This version of RunCommand DEFAULTS TO NON-THROTTLED.
		/// </summary>
		/// <param name="strCommand"></param>
		/// <param name="aobjParams"></param>
		protected static bool RunCommand(string strCommand, params object[] aobjParams)
		{
			return RunCommand(0, strCommand, aobjParams);
		}

		/************************************************************************************/
		protected static bool ApplyVerb(int iActorID, string strVerb)
		{
			return RunCommand(5, "/apply_verb {0} {1}", iActorID, strVerb);
		}

		/************************************************************************************/
		protected static bool ApplyVerb(Actor ThisActor, string strVerb)
		{
			Program.Log("Applying verb \"{0}\" on actor \"{1}\" (ID: \"{2}\").", strVerb, ThisActor.Name, ThisActor.ID);
			return ApplyVerb(ThisActor.ID, strVerb);
		}

		/************************************************************************************/
		protected static IEnumerable<Maintained> EnumMaintained()
		{
			for (int iIndex = 1; iIndex <= Me.CountMaintained; iIndex++)
				yield return Me.Maintained(iIndex);
		}

		/************************************************************************************/
		protected static IEnumerable<GroupMember> EnumGroupMembers()
		{
			/// Referring to group member #0 is shady but it's useful enough for us to continue doing it.
			if (IsInGroup || IsInRaid)
			{
				for (int iIndex = 0; iIndex <= 5; iIndex++)
				{
					GroupMember ThisMember = Me.Group(iIndex);
					if (ThisMember != null && !string.IsNullOrEmpty(ThisMember.Name))
						yield return ThisMember;
				}
			}
			else
				yield return Me.Group(0);
		}

		/************************************************************************************/
		protected static IEnumerable<GroupMember> EnumRaidMembers()
		{
			if (IsInRaid)
			{
				/// Documentation says to iterate through all 24 even if we have less than 24.
				for (int iIndex = 1; iIndex <= 24; iIndex++)
				{
					GroupMember ThisMember = Me.Raid(iIndex, false);
					if (ThisMember != null && !string.IsNullOrEmpty(ThisMember.Name))
						yield return ThisMember;
				}
			}
			else
			{
				foreach (GroupMember ThisMember in EnumGroupMembers())
					yield return ThisMember;
			}
		}

		/************************************************************************************/
		protected static IEnumerable<Ability> EnumAbilities()
		{
			for (int iIndex = 1; iIndex <= AbilityCount; iIndex++)
				yield return Me.Ability(iIndex);
		}

		/************************************************************************************/
		protected static IEnumerable<Actor> EnumActors(params string[] astrParams)
		{
			s_EQ2.CreateCustomActorArray(astrParams);

			for (int iIndex = 1; iIndex <= s_EQ2.CustomActorArraySize; iIndex++)
			{
				Actor ThisActor = s_Extension.CustomActor(iIndex);
				if (ThisActor.IsValid)
					yield return ThisActor;
			}
		}

		/************************************************************************************/
		protected static IEnumerable<Actor> EnumActorsInRadius(double fRadius)
		{
			return EnumActors("byDist", fRadius.ToString());
		}

		/************************************************************************************/
		protected static IEnumerable<Actor> EnumValidActorsFromIDCollection(ICollection<int> ThisCollection)
		{
			foreach (int iActorID in ThisCollection)
			{
				Actor ThisActor = GetActor(iActorID);
				if (ThisActor != null)
					yield return ThisActor;
			}
		}

		/************************************************************************************/
		/// <summary>
		/// Frame lock is assumed to be held before this function is called.
		/// </summary>
		protected static Actor GetNonPetActor(string strName)
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
		protected static Actor GetPlayerActor(string strName)
		{
			if (strName == Name)
				return MeActor;

			string strLowerCaseName = strName.ToLower();
			foreach (Actor ThisActor in EnumActors())
				if (ThisActor.Name.ToLower() == strLowerCaseName && ThisActor.Type == "PC")
					return ThisActor;

			return null;
		}

		/************************************************************************************/
		protected static Actor GetActor(int iActorID)
		{
			try
			{
				Actor ThisActor = s_Extension.Actor(iActorID);
				if (ThisActor.IsValid)
					return ThisActor;
			}
			catch
			{
				Program.Log("Exception thrown when looking up actor {0}.", iActorID);
			}
			return null;
		}

		/************************************************************************************/
		protected static Actor GetActor(string strActorID)
		{
			try
			{
				Actor ThisActor = s_Extension.Actor(strActorID);
				if (ThisActor.IsValid)
					return ThisActor;
			}
			catch
			{
				Program.Log("Exception thrown when looking up actor {0}.", strActorID);
			}
			return null;
		}

		/************************************************************************************/
		/// <summary>
		/// Using Thread.Sleep() during a frame lock, locks up the client.
		/// </summary>
		/// <param name="ThisTimeSpan"></param>
		protected static void DeadWait(TimeSpan ThisTimeSpan)
		{
			Thread.Sleep((int)ThisTimeSpan.TotalMilliseconds);
			return;
		}

		/************************************************************************************/
		protected static void FrameWait(TimeSpan ThisTimeSpan)
		{
			DateTime WaitEndTime = DateTime.Now + ThisTimeSpan;

			while (DateTime.Now < WaitEndTime)
				Frame.Wait(false);

			return;
		}

		/************************************************************************************/
		protected static void PressAndHoldKey(string strKey)
		{
			string strIndexedKey = strKey.ToLower().Trim();
			if (!s_PressedKeys.Contains(strIndexedKey))
			{
				Program.Log("Pressing and holding keyboard key: {0}", strKey);
				s_PressedKeys.Add(strIndexedKey);
			}

			/// Reapply the key even if it was applied before.
			/// Sometimes with window focus changes, the press gets lost.
			LavishScriptAPI.LavishScript.ExecuteCommand("press -hold " + strKey);
			return;
		}

		/************************************************************************************/
		/// <summary>
		/// Releases a key but only if we were the one who pressed it in the first place.
		/// This prevents interference with user action.
		/// </summary>
		protected static void ReleaseKey(string strKey)
		{
			string strIndexedKey = strKey.ToLower().Trim();
			if (s_PressedKeys.Contains(strIndexedKey))
			{
				Program.Log("Releasing keyboard key: {0}", strKey);
				LavishScriptAPI.LavishScript.ExecuteCommand("press -release " + strKey);
				s_PressedKeys.Remove(strIndexedKey);
			}
			return;
		}

		/************************************************************************************/
		protected static void ReleaseAllKeys()
		{
			foreach (string strThisKey in s_PressedKeys)
			{
				Program.Log("Releasing keyboard key: {0}", strThisKey);
				LavishScriptAPI.LavishScript.ExecuteCommand("press -release " + strThisKey);
			}
			s_PressedKeys.Clear();
			return;
		}

		/************************************************************************************/
		protected static void RegisterCustomSlashCommands(params string[] astrCommandNames)
		{
			foreach (string strCommand in astrCommandNames)
			{
				string strActualCommand = strCommand.Trim().ToLower();
				if (!s_RegisteredCustomSlashCommands.Contains(strActualCommand))
				{
					s_RegisteredCustomSlashCommands.Add(strActualCommand);
					LavishScript.Commands.AddCommand(strActualCommand, s_CustomSlashCommandDelegate);
				}
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
						UpdateStaticGlobals();
						s_Controller.OnChoiceWindowAppeared(s_Extension.ChoiceWindow());
					}
				}
			}
			catch (Exception ex)
			{
				/// Do nothing. But at least the bot doesn't crash!
				Program.OnUnhandledException(ex);
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
						UpdateStaticGlobals();
						s_Controller.OnRewardWindowAppeared(s_Extension.RewardWindow());
					}
				}
			}
			catch (Exception ex)
			{
				/// Do nothing. But at least the bot doesn't crash!
				Program.OnUnhandledException(ex);
			}

			return;
		}

		/************************************************************************************/
		private static void OnLootWindowAppeared_EventHandler(object sender, LSEventArgs e)
		{
			try
			{
				if (s_Controller != null)
				{
					using (new FrameLock(true))
					{
						UpdateStaticGlobals();

						LootWindow ThisWindow = s_Extension.LootWindow();
						if (s_strLastLootWindowID == e.Args[0])
							Program.Log("Blocking duplicate event for this loot window ({0}).", s_strLastLootWindowID);
						else
						{
							s_strLastLootWindowID = e.Args[0];
							s_Controller.OnLootWindowAppeared(s_strLastLootWindowID, ThisWindow);
						}
					}
				}
			}
			catch (Exception ex)
			{
				/// Do nothing. But at least the bot doesn't crash!
				Program.OnUnhandledException(ex);
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
			try
			{
				s_ParseThread.PostNewLogLineMessage(e.Args[0]);
			}
			catch (Exception ex)
			{
				/// Do nothing. But at least the bot doesn't crash!
				Program.OnUnhandledException(ex);
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
					{
						if (UpdateStaticGlobals())
							s_Controller.OnCustomSlashCommand(astrArgs[0].ToLower(), astrArgList.ToArray());
					}
				}
			}
			catch (Exception e)
			{
				Program.OnUnhandledException(e);
			}

			return 0;
		}

		/************************************************************************************/
		protected static void ToggleSpeechSynthesizer(bool bActivate, int iVolume, string strVoiceProfile)
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
		protected static void SayText(string strFormat, params object[] aobjParams)
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
