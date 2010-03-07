using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
using EQ2.ISXEQ2;
using EQ2SuiteLib;
using PInvoke;

namespace EQ2GlassCannon
{
	public partial class PlayerController
	{
		protected bool m_bTrackActor = false;
		protected TimeSpan m_TrackActorInterval = TimeSpan.FromTicks(0);
		protected DateTime m_NextTrackActorAttemptTime = DateTime.FromBinary(0);
		protected string m_strTrackActorSubstring = string.Empty;

		/************************************************************************************/
		protected Actor GetNestedCombatAssistTarget(string strPlayerName)
		{
			Actor AssistedPlayerActor = GetPlayerActor(strPlayerName);
			if (AssistedPlayerActor == null)
			{
				Program.Log("No player actor was found with the name {0}.", strPlayerName);
				return null;
			}

			string strAssistDescription = string.Empty;
			Actor FinalTargetActor = null;

			SetCollection<int> TraversedActorIDSet = new SetCollection<int>();

			/// Nested assist targetting. Go through assist targets until either a recursive loop or a killable NPC is found.
			/// This is more advanced than even the normal UI allows.
			for (Actor ThisActor = AssistedPlayerActor; ThisActor.IsValid; ThisActor = ThisActor.Target())
			{
				if (TraversedActorIDSet.Count > 0)
					strAssistDescription += " --> ";
				strAssistDescription += string.Format("{0} ({1})", ThisActor.Name, ThisActor.ID);

				if (ThisActor.Type == "NPC" || ThisActor.Type == STR_NAMED_NPC)
				{
					FinalTargetActor = ThisActor;
					break;
				}

				/// Infinite recursion = FAIL
				if (TraversedActorIDSet.Contains(ThisActor.ID))
				{
					Program.Log("Circular player assist chain detected! No enemy was found.");
					break;
				}

				TraversedActorIDSet.Add(ThisActor.ID);
			}

			Program.Log("Assist chain: {0}", strAssistDescription);
			return FinalTargetActor;
		}

		/************************************************************************************/
		private enum TrackType
		{
			None = 0,
			Normal,
			Named,
			EmptyName,
			Resource,
		}

		/************************************************************************************/
		protected void TrackNearestActors(int iActorCount, bool bDumpActorInfo, string strSearchSubstring)
		{
			TrackType eTrackType = TrackType.None;
			if (strSearchSubstring == "named")
				eTrackType = TrackType.Named;
			else if (strSearchSubstring == "resource")
				eTrackType = TrackType.Resource;
			else if (string.IsNullOrEmpty(strSearchSubstring.Trim()))
				eTrackType = TrackType.EmptyName;

			List<Actor> ActorList = new List<Actor>();
			int iValidActorCount = 0;
			int iInvalidActorCount = 0;

			foreach (Actor ThisActor in EnumActors())
			{
				bool bAddThisActor = false;

				switch (eTrackType)
				{
					case TrackType.Named:
					{
						if (ThisActor.IsNamed && !ThisActor.IsAPet)
							bAddThisActor = true;
						break;
					}
					case TrackType.EmptyName:
					{
						if (string.IsNullOrEmpty(ThisActor.Name.Trim()))
							bAddThisActor = true;
						break;
					}
					case TrackType.Resource:
					{
						if (ThisActor.Type == "Resource")
							bAddThisActor = true;
						break;
					}
					default:
					{
						string strActorName = ThisActor.Name.ToLower();
						if (strActorName.Contains(strSearchSubstring))
							bAddThisActor = true;
						break;
					}
				}

				if (bAddThisActor)
				{
					ActorList.Add(ThisActor);
					iValidActorCount++;
				}
				else
					iInvalidActorCount++;
			}

			if (ActorList.Count == 0)
			{
				Program.Log("Unable to find actor \"{0}\".", strSearchSubstring);
				RunCommand("/waypoint_cancel");
				return;
			}

			ActorList.Sort(new ActorDistanceComparer());

			/// Run the waypoint on the nearest actor.
			RunCommand("/waypoint {0}, {1}, {2}", ActorList[0].X, ActorList[0].Y, ActorList[0].Z);

			if (bDumpActorInfo)
			{
				FlexStringBuilder SummaryBuilder = new FlexStringBuilder();
				SummaryBuilder.AppendLine("{0} actor(s) found ({1} invalid) using \"{2}\".", iValidActorCount, iInvalidActorCount, strSearchSubstring);

				/// Now display the individual results.
				for (int iIndex = 0; iIndex < ActorList.Count && iIndex < 5; iIndex++)
				{
					Actor ThisActor = ActorList[iIndex];
					AppendActorInfo(SummaryBuilder, iIndex + 1, ThisActor);
				}

				Program.Log(SummaryBuilder.ToString());
			}
			return;
		}

		/************************************************************************************/
		protected virtual bool OnCustomSlashCommand(string strCommand, string[] astrParameters)
		{
			string strCondensedParameters = string.Join(" ", astrParameters).Trim();

			switch (strCommand)
			{
				case "gc_assist":
				{
					Actor OffensiveTargetActor = GetNestedCombatAssistTarget(astrParameters[0]);
					if (OffensiveTargetActor != null)
						OffensiveTargetActor.DoTarget();
					return true;
				}

				/// Directly acquire an offensive target.
				case "gc_attack":
				{
					Actor MyTargetActor = MeActor.Target();
					if (MyTargetActor.IsValid)
					{
						/// Don't bother filtering. Just grab the ID, let the other code determine if it's a legit target.
						m_iOffensiveTargetID = MyTargetActor.ID;
						Program.Log("Offensive target set to \"{0}\" ({1}).", MyTargetActor.Name, m_iOffensiveTargetID);
					}
					else
					{
						Program.Log("Invalid target selected.");
					}
					return true;
				}

				/// This is the assist call; direct the bot to begin combat.
				/// Essentially combines gc_assist and gc_attack.
				case "gc_attackassist":
				{
					if (astrParameters.Length != 1)
					{
						Program.Log("gc_attackassist: Missing name of player to assist!");
						return true;
					}

					/// Force a recalculation.
					m_OffensiveTargetEncounterActorDictionary.Clear();

					Actor OffensiveTargetActor = GetNestedCombatAssistTarget(astrParameters[0]);
					if (OffensiveTargetActor == null)
					{
						/// Combat is now cancelled.
						/// Maybe the commanding player misclicked or clicked off intentionally, but it doesn't matter.
						WithdrawFromCombat();
					}
					else
					{
						/// Successful target acquisition.
						m_iOffensiveTargetID = OffensiveTargetActor.ID;
						Program.Log("New offensive target: {0}", OffensiveTargetActor.Name);

						/// An assist command promotes AFK into neutral positioning.
						if (m_ePositioningStance == PositioningStance.DoNothing)
							ChangePositioningStance(PositioningStance.NeutralPosition);
					}

					return true;
				}

				/// Begin dropping all group buffs.
				case "gc_cancelgroupbuffs":
				{
					Program.Log("Cancelling all maintained group effects...");
					m_bClearGroupMaintained = true;
					return true;
				}

				/// Arbitrarily change an INI setting on the fly.
				case "gc_changesetting":
				{
					string strKey = string.Empty;
					string strValue = string.Empty;

					int iEqualsPosition = strCondensedParameters.IndexOf(" ");
					if (iEqualsPosition == -1)
						strKey = strCondensedParameters;
					else
					{
						strKey = strCondensedParameters.Substring(0, iEqualsPosition).TrimEnd();
						strValue = strCondensedParameters.Substring(iEqualsPosition + 1).TrimStart();
					}

					if (!string.IsNullOrEmpty(strKey))
					{
						Program.Log("Changing setting \"{0}\" to new value \"{1}\"...", strKey, strValue);

						IniFile FakeIniFile = new IniFile();
						FakeIniFile.WriteString(strKey, strValue);
						FakeIniFile.Mode = IniFile.TransferMode.Read;
						TransferINISettings(FakeIniFile);
						ApplySettings();
					}
					return true;
				}

				case "gc_debug":
				{
					if (astrParameters.Length == 0)
					{
						Program.Log("gc_debug: No option specified!");
						return true;
					}

					switch (astrParameters[0])
					{
						case "whopet":
							Program.Log("gc_debug whopet: Listing player's primary pet...");
							FlexStringBuilder ThisBuilder = new FlexStringBuilder();
							AppendActorInfo(ThisBuilder, 1, Me.Pet());
							Program.Log("{0}", ThisBuilder.ToString());
							return true;
						case "fullaffinities":
							Program.Log("Attempting to remove all affinity constraints on the process and its threads...");
							uint uiCurrentProcessID = KERNEL32.GetCurrentProcessId();
							IntPtr hProcess = KERNEL32.OpenProcess(KERNEL32.ProcessAccess.SetInformation | KERNEL32.ProcessAccess.QueryInformation, false, uiCurrentProcessID);
							if (hProcess == KERNEL32.INVALID_HANDLE_VALUE)
							{
								Program.Log("Unable to open process {0}.", uiCurrentProcessID);
								return true;
							}

							UIntPtr uiProcessAffinityMask;
							UIntPtr uiSystemProcessorMask;
							KERNEL32.GetProcessAffinityMask(hProcess, out uiProcessAffinityMask, out uiSystemProcessorMask);
							Program.Log("Process {0} previous affinity mask: 0x{1:X8}", uiCurrentProcessID, uiProcessAffinityMask);

							KERNEL32.SetProcessAffinityMask(hProcess, uiSystemProcessorMask);
							KERNEL32.CloseHandle(hProcess);

							Program.Log("Attempting to remove all affinity constraints on the process threads...");
							foreach (KERNEL32.THREADENTRY32 ThisThread in KERNEL32.EnumProcessThreads(uiCurrentProcessID))
							{
								IntPtr hThread = KERNEL32.OpenThread(KERNEL32.ThreadAccess.SetInformation | KERNEL32.ThreadAccess.QueryInformation, false, ThisThread.th32ThreadID);
								if (hThread != IntPtr.Zero)
								{
									UIntPtr uiOldThreadAffinityMask = KERNEL32.SetThreadAffinityMask(hThread, uiSystemProcessorMask);
									Program.Log("Thread {0} previous affinity mask: 0x{1:X8}", ThisThread.th32ThreadID, uiOldThreadAffinityMask);
									KERNEL32.CloseHandle(hThread);
								}
								else
									Program.Log("Can't open thread {0}.", ThisThread.th32ThreadID);
							}
							return true;
						case "memstat":
							Process CurrentProcess = Process.GetCurrentProcess();
							Program.Log("Virtual Allocation: {0}", CustomFormatter.FormatByteCount(CurrentProcess.VirtualMemorySize64, "0.00"));
							Program.Log("Working Set: {0}", CustomFormatter.FormatByteCount(CurrentProcess.WorkingSet64, "0.00"));
							Program.Log(".NET Heap Allocation: {0}", CustomFormatter.FormatByteCount(GC.GetTotalMemory(false), "0.00"));
							Program.Log("Threads: {0}", CurrentProcess.Threads.Count);
							return true;
					}

					Program.Log("Usage: gc_debug (whopet|fullaffinities|memstat)");
					return true;
				}

				case "gc_defaultverb":
				{
					string strActorName = strCondensedParameters;
					Actor IntendedTargetActor = null;

					/// Grab the targetted actor.
					if (string.IsNullOrEmpty(strActorName))
					{
						Actor CurrentTargetActor = MeActor.Target();
						if (CurrentTargetActor.IsValid)
							IntendedTargetActor = CurrentTargetActor;
					}

					/// Grab the so-named actor nearest to the commander.
					else
					{
						double fNearestDistance = 50.0;
						foreach (Actor ThisActor in EnumActors(strActorName))
						{
							if (ThisActor.Name != strActorName)
								continue;

							double fThisDistance = ThisActor.Distance;
							if (fThisDistance < fNearestDistance)
							{
								fNearestDistance = fThisDistance;
								IntendedTargetActor = ThisActor;
							}
						}
					}

					/// No such actor found.
					if (IntendedTargetActor == null)
					{
						Program.Log("gc_defaultverb: actor not found.");
					}
					else
					{
						Program.Log("gc_defaultverb: Attempting to apply default verb on actor \"{0}\" ({1}).", strActorName, IntendedTargetActor.ID);
						IntendedTargetActor.DoubleClick();
					}

					return true;
				}

				case "gc_distance":
				{
					Actor MyTargetActor = MeActor.Target();
					if (MyTargetActor.IsValid)
					{
						string strOutput = string.Format("Distance to target \"{0}\" ({1}): {2} meter(s).", MyTargetActor.Name, MyTargetActor.ID, MyTargetActor.Distance);
						RunCommand("/announce {0}", strOutput);
						Program.Log(strOutput);
					}
					return true;
				}

				case "gc_dumpabilities":
				{
					/// Dump all abilities to a .CSV file specified as a parameter, on the next knowledge book refresh.
					s_strKnowledgeBookDumpPath = strCondensedParameters;
					s_bRefreshKnowledgeBook = true;
					return true;
				}

				case "gc_exit":
				{
					Program.Log("Exit command received!");
					s_bContinueBot = false;
					return true;
				}

				case "gc_exitprocess":
				{
					Process.GetCurrentProcess().Kill();
					return true;
				}

				case "gc_findactor":
				{
					string strSearchString = strCondensedParameters.ToLower();

					TrackNearestActors(5, true, strSearchString);
					return true;
				}

				case "gc_openini":
				{
					Program.SafeShellExecute(s_strCurrentINIFilePath);
					return true;
				}

				case "gc_openoverridesini":
				{
					Program.SafeShellExecute(s_strSharedOverridesINIFilePath);
					return true;
				}

				case "gc_reloadsettings":
				{
					ReadINISettings();
					ReleaseAllKeys(); /// If there's a bug, this will cure it. If not, no loss.
					s_bRefreshKnowledgeBook = true;
					return true;
				}

				case "gc_stance":
				{
					if (astrParameters.Length < 1)
					{
						Program.Log("gc_stance failed: Missing stance parameter.");
						return true;
					}

					string strStance = astrParameters[0].ToLower();
					switch (strStance)
					{
						case "afk":
							Program.Log("Now ignoring all non-stance commands.");
							ChangePositioningStance(PositioningStance.DoNothing);
							break;
						case "customfollow":
							m_fCurrentMovementTargetCoordinateTolerance = m_fCustomAutoFollowMaximumRange;
							m_strPositionalCommandingPlayer = GetFirstExistingPartyMember(m_astrAutoFollowTargets, false);
							ChangePositioningStance(PositioningStance.CustomAutoFollow);
							break;
						case "shadow":
							m_fCurrentMovementTargetCoordinateTolerance = m_fStayInPlaceTolerance;
							m_strPositionalCommandingPlayer = GetFirstExistingPartyMember(m_astrAutoFollowTargets, false);
							ChangePositioningStance(PositioningStance.CustomAutoFollow);
							break;
						case "normal":
						case "follow":
							Program.Log("Positioning is now regular auto-follow.");
							ChangePositioningStance(PositioningStance.AutoFollow);
							break;
						case "neutral":
							Program.Log("Positioning is now neutral.");
							ChangePositioningStance(PositioningStance.NeutralPosition);
							break;
						case "dash":
							Program.Log("Dashing forward.");
							ChangePositioningStance(PositioningStance.ForwardDash);
							break;
						case "stay":
							Program.Log("Locking position to where the commanding player is now standing.");
							m_strPositionalCommandingPlayer = GetFirstExistingPartyMember(m_astrAutoFollowTargets, false);
							ChangePositioningStance(PositioningStance.StayInPlace);
							break;
						case "stayat":
							if (astrParameters.Length >= 4)
							{
								Point3D NewSpot = new Point3D();
								if (double.TryParse(astrParameters[1], out NewSpot.X) &&
									double.TryParse(astrParameters[2], out NewSpot.Y) &&
									double.TryParse(astrParameters[3], out NewSpot.Z))
								{
									m_strPositionalCommandingPlayer = string.Empty;
									m_ptStayLocation = NewSpot;
									ChangePositioningStance(PositioningStance.StayInPlace);
								}
								else
									Program.Log("Bad coordinate input format.");
							}
							else
								Program.Log("You need 3 values to form a 3-D coordinate, but you specified {0}.", astrParameters.Length - 1);
							break;
						case "stayself":
							Program.Log("Locking position to where you are now standing.");
							m_strPositionalCommandingPlayer = Name;
							ChangePositioningStance(PositioningStance.StayInPlace);
							break;
						default:
							Program.Log("Stance not recognized.");
							break;
					}

					return true;
				}

				case "gc_spawnwatch":
				{
					m_bSpawnWatchTargetAnnounced = false;
					m_strSpawnWatchTarget = strCondensedParameters.ToLower().Trim();
					Program.Log("Bot will now scan for actor \"{0}\".", m_strSpawnWatchTarget);
					ChangePositioningStance(PositioningStance.SpawnWatch);
					return true;
				}

				/// A super-powerful direct targetter.
				case "gc_target":
				{
					Actor TargetActor = null;
					string strSearchString = strCondensedParameters.ToLower();

					/// If they give an actual actor ID, then that's awesome.
					int iActorID = -1;
					if (int.TryParse(strSearchString, out iActorID))
						TargetActor = GetActor(iActorID);
					else
					{
						foreach (Actor ThisActor in EnumActors())
							if (ThisActor.Name.ToLower().Contains(strSearchString))
							{
								TargetActor = ThisActor;
								break;
							}
					}

					if (TargetActor != null)
						TargetActor.DoTarget();
					return true;
				}

				/// Update the waypoint at a regular interval with the nearest location of an actor search string.
				case "gc_trackactor":
				{
					if (astrParameters.Length < 1)
					{
						Program.Log("gc_trackactor failed: Missing parameter.");
						return true;
					}

					string strInterval = astrParameters[0].Trim().ToLower();
					if (strInterval == "off")
					{
						RunCommand("/waypoint_cancel");
						Program.Log("Actor tracking mode disabled.");
						m_bTrackActor = false;
						return true;
					}

					double fIntervalSeconds = 0;
					if (!double.TryParse(strInterval, out fIntervalSeconds) || fIntervalSeconds < 0.0)
					{
						Program.Log("gc_trackactor failed: Invalid interval parameter.");
						return false;
					}

					List<string> astrRemainingParameters = new List<string>(astrParameters);
					if (astrRemainingParameters.Count > 0)
						astrRemainingParameters.RemoveAt(0);

					string strRemainingCondensedParameters = string.Join(" ", astrRemainingParameters.ToArray()).Trim().ToLower();

					/// Now we turn the mode on.
					m_TrackActorInterval = TimeSpan.FromSeconds(fIntervalSeconds);
					m_NextTrackActorAttemptTime = CurrentCycleTimestamp;
					m_strTrackActorSubstring = strRemainingCondensedParameters;
					m_bTrackActor = true;
					return true;
				}

				/// Test the text-to-speech synthesizer using the current settings.
				case "gc_tts":
				{
					SayText(strCondensedParameters);
					return true;
				}

				case "gc_version":
				{
					Program.DisplayVersion();
					Program.Log("ISXEQ2 Version: " + s_ISXEQ2.Version);
					return true;
				}

				/// Clear the offensive target.
				case "gc_withdraw":
				{
					Program.Log("Offensive target withdrawn.");
					WithdrawFromCombat();
					return true;
				}
			}

			return false;
		}
	}
}
