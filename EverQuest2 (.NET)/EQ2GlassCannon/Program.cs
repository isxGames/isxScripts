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
using System.Net.Mail;

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
		public static bool s_bContinueBot = true;
		public static bool s_bRefreshKnowledgeBook = false;
		private static long s_lFrameCount = 0;
		public static string s_strINIFolderPath = string.Empty;
		public static string s_strCurrentINIFilePath = string.Empty;
		private static string s_strNewWindowTitle = null;

		public static Dictionary<string, string> s_INISettings = new Dictionary<string, string>();

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
			const int iPeHeaderOffset = 60;
			const int iLinkerTimestampOffset = 8;

			byte[] b = new byte[2048];

			Stream s = null;
			try
			{
				s = new FileStream(strFilePath, FileMode.Open, FileAccess.Read);
				s.Read(b, 0, 2048);
			}
			finally
			{
				if (s != null)
					s.Close();
			}

			int i = BitConverter.ToInt32(b, iPeHeaderOffset);
			int iSecondsSince1970 = BitConverter.ToInt32(b, i + iLinkerTimestampOffset);

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
		public static void LoadINIFile()
		{
			if (!File.Exists(s_strCurrentINIFilePath))
				return;

			Log("Loading INI file...");

			using (StreamReader InputFile = new StreamReader(s_strCurrentINIFilePath))
			{
				s_INISettings.Clear();

				while (!InputFile.EndOfStream)
				{
					string strInput = InputFile.ReadLine();
					strInput = strInput.Trim();

#if DEBUG
					//Program.Log(strInput);
#endif

					if (strInput.StartsWith(";"))
						continue;

					int iEqualsPosition = strInput.IndexOf("=");
					if (iEqualsPosition == -1)
						continue;

					string strKey = strInput.Substring(0, iEqualsPosition).TrimEnd();
					string strValue = strInput.Substring(iEqualsPosition + 1).TrimStart();

					if (s_INISettings.ContainsKey(strKey))
						s_INISettings[strKey] = strValue;
					else
						s_INISettings.Add(strKey, strValue);
				}
			}

			return;
		}

		/************************************************************************************/
		public static void SaveINIFile()
		{
			using (StreamWriter OutputFile = new StreamWriter(s_strCurrentINIFilePath))
			{
				foreach (KeyValuePair<string, string> ThisItem in s_INISettings)
				{
					string strOutput = string.Format("{0}={1}", ThisItem.Key, ThisItem.Value);
					OutputFile.WriteLine(strOutput);
#if DEBUG
					//Program.Log(strOutput);
#endif
				}
			}

			return;
		}

		/************************************************************************************/
		private static void Main()
		{
			try
			{
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
					LavishVMAPI.Frame.Wait(true);
					try
					{
						if (s_Extension.ISXEQ2().IsReady)
							break;
					}
					finally
					{
						LavishVMAPI.Frame.Unlock();
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
					LavishVMAPI.Frame.Wait(true);
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
							}
							continue;
						}
						else
						{
							if (!bFirstZoningFrame)
							{
								Program.Log("Done zoning.");
								bFirstZoningFrame = true;

								/// We used to not have to do this, but something changed and fucked everything up.
								s_bRefreshKnowledgeBook = true;
							}
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
							{
								LoadINIFile();
								s_Controller.ReadINISettings();
							}
							else
							{
								/// First-time save.
								s_Controller.WriteINISettings();
								SaveINIFile();
							}

							SetWindowText(string.Format("{0} ({1})", Me.Name, Me.SubClass));
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
						LavishVMAPI.Frame.Unlock();
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
					if (!string.IsNullOrEmpty(s_strCurrentINIFilePath))
						SaveINIFile();
				}
			}

			/// I have only one try-catch frame because I don't want hidden logic bugs.
			/// Things should work perfectly or not at all.
			catch (Exception e)
			{
				if (s_Controller != null)
					Program.RunCommand("/t " + s_Controller.m_strCommandingPlayer + " oh shit lol");

				Program.Log("Unhandled .NET exception: " + e.Message);
				Program.Log(e.TargetSite.ToString()); /// TODO: Extract and display the LINE that threw the exception!!!
				Program.Log(e.StackTrace.ToString());
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

			string strPlayerSource = string.Empty;
			string strBody = string.Empty;

			try
			{
				if (s_Controller != null)
				{
					using (new FrameLock(true))
					{
						UpdateGlobals();

						/// TODO: Parse this out.
						if (strChatText.StartsWith("You tell"))
						{
							strPlayerSource = Me.Name;
						}
						else if (strChatText.StartsWith("\\aPC -1 "))
						{
							/// Fill with junk till we parse it out, lol.
							strPlayerSource = Guid.NewGuid().ToString();
						}
						else
						{
							strBody = strChatText;
						}

						s_Controller.OnIncomingText(strPlayerSource, strBody);
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
		/// <summary>
		/// I hate trying to remember the syntax, so I hid it behind this function.
		/// </summary>
		/// <param name="strCommand"></param>
		public static void RunCommand(string strCommand, params object[] aobjParams)
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

				using (new FrameLock(true))
				{
					s_Extension.EQ2Execute(strFinalCommand);
				}
			}
			catch
			{
			}

			return;
		}

		/************************************************************************************/
		public static void ApplyVerb(int iActorID, string strVerb)
		{
			RunCommand("/apply_verb {0} {1}", iActorID, strVerb);
			return;
		}

		/************************************************************************************/
		public static void ApplyVerb(Actor ThisActor, string strVerb)
		{
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

		/************************************************************************************/
		public static bool SendEMail(
			string strServer,
			int iPort,
			bool bUseSSLForPassword,
			string strAccount,
			string strPassword,
			string strFromAddress,
			List<string> astrToAddressList,
			string strSubject,
			string strMessage)
		{
			try
			{
				SmtpClient ThisClient = new SmtpClient(strServer, iPort);

				bool bUsePassword = !string.IsNullOrEmpty(strAccount) || !string.IsNullOrEmpty(strPassword);
				if (bUsePassword)
				{
					ThisClient.Credentials = new System.Net.NetworkCredential(strAccount, strPassword);
					ThisClient.EnableSsl = bUseSSLForPassword;
				}

				foreach (string strThisToAddress in astrToAddressList)
				{
					ThisClient.Send(strFromAddress, strThisToAddress, strSubject, strMessage);
				}
			}
			catch
			{
				return false;
			}

			return true;
		}
	}
}
