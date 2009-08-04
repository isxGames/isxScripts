using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Diagnostics;
using System.Drawing;
using EQ2.ISXEQ2;
using InnerSpaceAPI;
using LavishVMAPI;
using System.IO;

namespace EQ2GlassCannon
{
	public partial class PlayerController
	{
		public bool m_bWriteBackINI = true;
		public string m_strCustomTellTriggerFile = string.Empty;
		public string m_strReloadINISubphrase = "rebuff me pls";
		public string m_strMainTank = string.Empty;
		public string m_strAutoFollowTarget = string.Empty;
		public string m_strCommandingPlayer = string.Empty;
		public string m_strAssistSubphrase = "assist me";
		public string m_strBotKillswitchSubphrase = "stop dps";
		public string m_strProcessKillswitchSubphrase = "beddy-bye!!";
		public string m_strDoNothingSubphrase = "afk";
		public string m_strNeutralPositionSubphrase = "neutral";
		public string m_strAutoFollowSubphrase = "come";
		public string m_strCustomAutoFollowSubphrase = "stay close";
		public string m_strStayInPlaceSubphrase = "stay here";
		public string m_strShadowMeSubphrase = "shadow me";
		public string m_strForwardDashSubphrase = "charge";
		public string m_strClearGroupMaintainedSubphrase = "redo group buffs";
		public string m_strMentorSubphrase = "mentor";
		public string m_strRepairSubphrase = "repair";
		public string m_strArbitraryVerbCommandPrefix = "try this: \"";
		public string m_strArbitraryVerbCommandSeparator = "\", \"";
		public string m_strArbitraryVerbCommandSuffix = "\"";
		public double m_fStayInPlaceTolerance = 1.5;
		public double m_fCustomAutoFollowMinimumRange = 10.0;
		public int m_iCheckBuffsInterval = 500;
		public bool m_bUseRanged = false;
		public bool m_bUseGreenAEs = true;
		public bool m_bUseBlueAEs = true;
		public bool m_bAutoAttack = true;
		public bool m_bSyncAbilitiesWithAutoAttack = false; /// Not implemented yet.
		public bool m_bCastCures = true;
		public bool m_bPrioritizeCures = true;
		public bool m_bCureMainTank = true;
		public bool m_bHealMainTank = true;
		public bool m_bCastFurySalveIfGranted = true;
		public bool m_bSpamHeroicOpportunity = true;
		public bool m_bMezAdds = false;
		public bool m_bUseRacialBuffs = true;
		public bool m_bUsePet = true;
		public bool m_bSummonPetDuringCombat = false;
		public bool m_bHarvestAutomatically = false;
		public int m_iFrameSkip = 2;
		public EmailQueueThread.SMTPProfile m_EmailProfile = new EmailQueueThread.SMTPProfile();
		public string m_strChatWatchSubphrase = "listen for";
		public List<string> m_astrChatWatchToAddressList = new List<string>();
		public double m_fChatWatchAlertCooldownMinutes = 5.0;
		public string m_strSpawnWatchSubphrase = "watch for";
		public List<string> m_astrSpawnWatchToAddressList = new List<string>();
		public string m_strSpawnWatchAlertCommand = string.Empty;
		public string m_strSpawnWatchDespawnSubphrase = "wait for despawn";
		public double m_fSpawnWatchDespawnTimeoutMinutes = 6.0;

		/************************************************************************************/
		protected virtual void TransferINISettings(IniFile ThisFile)
		{
			ThisFile.TransferBool("General.WriteBackINI", ref m_bWriteBackINI);
			ThisFile.TransferString("General.CustomTellTriggerFile", ref m_strCustomTellTriggerFile);
			ThisFile.TransferString("General.ReloadINISubphrase", ref m_strReloadINISubphrase);
			ThisFile.TransferString("General.MainTank", ref m_strMainTank);
			ThisFile.TransferString("General.AutoFollowTarget", ref m_strAutoFollowTarget);
			ThisFile.TransferString("General.CommandingPlayer", ref m_strCommandingPlayer);
			ThisFile.TransferCaselessString("General.AssistSubphrase", ref m_strAssistSubphrase);
			ThisFile.TransferCaselessString("General.BotKillswitchSubphrase", ref m_strBotKillswitchSubphrase);
			ThisFile.TransferCaselessString("General.ProcessKillswitchSubphrase", ref m_strProcessKillswitchSubphrase);
			ThisFile.TransferCaselessString("General.DoNothingSubphrase", ref m_strDoNothingSubphrase);
			ThisFile.TransferCaselessString("General.NeutralPositionSubphrase", ref m_strNeutralPositionSubphrase);
			ThisFile.TransferCaselessString("General.AutoFollowSubphrase", ref m_strAutoFollowSubphrase);
			ThisFile.TransferCaselessString("General.CustomAutoFollowSubphrase", ref m_strCustomAutoFollowSubphrase);
			ThisFile.TransferCaselessString("General.StayInPlaceSubphrase", ref m_strStayInPlaceSubphrase);
			ThisFile.TransferCaselessString("General.ShadowMeSubphrase", ref m_strShadowMeSubphrase);
			ThisFile.TransferCaselessString("General.ForwardDashSubphrase", ref m_strForwardDashSubphrase);
			ThisFile.TransferCaselessString("General.ClearGroupMaintainedSubphrase", ref m_strClearGroupMaintainedSubphrase);
			ThisFile.TransferCaselessString("General.MentorSubphrase", ref m_strMentorSubphrase);
			ThisFile.TransferCaselessString("General.RepairSubphrase", ref m_strRepairSubphrase);
			ThisFile.TransferString("General.ArbitraryVerbCommandPrefix", ref m_strArbitraryVerbCommandPrefix);
			ThisFile.TransferString("General.ArbitraryVerbCommandSeparator", ref m_strArbitraryVerbCommandSeparator);
			ThisFile.TransferString("General.ArbitraryVerbCommandSuffix", ref m_strArbitraryVerbCommandSuffix);
			ThisFile.TransferInteger("General.CheckBuffsInterval", ref m_iCheckBuffsInterval);
			ThisFile.TransferBool("General.UseRanged", ref m_bUseRanged);
			ThisFile.TransferBool("General.UseGreenAEs", ref m_bUseGreenAEs);
			ThisFile.TransferBool("General.UseBlueAEs", ref m_bUseBlueAEs);
			ThisFile.TransferBool("General.AutoAttack", ref m_bAutoAttack);
			ThisFile.TransferBool("General.SyncAbilitiesWithAutoAttack", ref m_bSyncAbilitiesWithAutoAttack);
			ThisFile.TransferBool("General.CastCures", ref m_bCastCures);
			ThisFile.TransferBool("General.PrioritizeCures", ref m_bPrioritizeCures);
			ThisFile.TransferBool("General.CureMainTank", ref m_bCureMainTank);
			ThisFile.TransferBool("General.HealMainTank", ref m_bHealMainTank);
			ThisFile.TransferBool("General.CastFurySalveIfGranted", ref m_bCastFurySalveIfGranted);
			ThisFile.TransferBool("General.SpamHeroicOpportunity", ref m_bSpamHeroicOpportunity);
			ThisFile.TransferBool("General.MezAdds", ref m_bMezAdds);
			ThisFile.TransferBool("General.UseRacialBuffs", ref m_bUseRacialBuffs);
			ThisFile.TransferBool("General.UsePet", ref m_bUsePet);
			ThisFile.TransferBool("General.RecastPetDuringCombat", ref m_bSummonPetDuringCombat);
			ThisFile.TransferBool("General.HarvestAutomatically", ref m_bHarvestAutomatically);
			ThisFile.TransferInteger("General.FrameSkip", ref m_iFrameSkip);
			ThisFile.TransferDouble("General.StayInPlaceTolerance", ref m_fStayInPlaceTolerance);
			ThisFile.TransferDouble("General.CustomAutoFollowMinimumRange", ref m_fCustomAutoFollowMinimumRange);

			/// E-mail account values.
			ThisFile.TransferString("E-Mail.SMTPServer", ref m_EmailProfile.m_strServer);
			ThisFile.TransferInteger("E-Mail.SMTPPort", ref m_EmailProfile.m_iPort);
			ThisFile.TransferBool("E-Mail.SMTPUseSSL", ref m_EmailProfile.m_bUseSSL);
			ThisFile.TransferString("E-Mail.SMTPAccount", ref m_EmailProfile.m_strAccount);
			ThisFile.TransferString("E-Mail.SMTPPassword", ref m_EmailProfile.m_strPassword);
			ThisFile.TransferCaselessString("E-Mail.FromAddress", ref m_EmailProfile.m_strFromAddress);

			/// Chat Watch values.
			ThisFile.TransferCaselessString("ChatWatch.Subphrase", ref m_strChatWatchSubphrase);
			ThisFile.TransferStringList("ChatWatch.ToAddresses", m_astrChatWatchToAddressList);
			ThisFile.TransferDouble("ChatWatch.AlertCooldownMinutes", ref m_fChatWatchAlertCooldownMinutes);

			/// Spawn Watch values.
			ThisFile.TransferCaselessString("SpawnWatch.Subphrase", ref m_strSpawnWatchSubphrase);
			ThisFile.TransferStringList("SpawnWatch.ToAddresses", m_astrSpawnWatchToAddressList);
			ThisFile.TransferString("SpawnWatch.AlertCommand", ref m_strSpawnWatchAlertCommand);
			ThisFile.TransferCaselessString("SpawnWatch.DespawnSubphrase", ref m_strSpawnWatchDespawnSubphrase);
			ThisFile.TransferDouble("SpawnWatch.DespawnTimeoutMinutes", ref m_fSpawnWatchDespawnTimeoutMinutes);

			if (ThisFile.Mode == IniFile.TransferMode.Read)
			{
				/// Fallback option to prevent an unresponsive bot.
				if (string.IsNullOrEmpty(m_strCommandingPlayer))
					m_strCommandingPlayer = Me.Name;
			}

			return;
		}

		/************************************************************************************/
		public void ReadINISettings()
		{
			IniFile NewFile = new IniFile(Program.s_strCurrentINIFilePath);
			TransferINISettings(NewFile);

			m_aCustomTellTriggerList.Clear();

			/// Load the custom tell trigger list.
			try
			{
				string strInputFile = Path.Combine(Program.s_strINIFolderPath, m_strCustomTellTriggerFile);

				if (File.Exists(strInputFile))
				{
					using (CsvFileReader ThisReader = new CsvFileReader(strInputFile))
					{
						while (ThisReader.ReadLine())
						{
							CustomTellTrigger NewTrigger = new CustomTellTrigger();

							NewTrigger.m_astrSourcePlayers.AddRange(ThisReader.ReadNextValue().ToLower().Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries));
							NewTrigger.m_strSubstring = ThisReader.ReadNextValue().Trim().ToLower();

							/// Keep reading commands until there are no more.
							try
							{
								while (true)
									NewTrigger.m_astrCommands.Add(ThisReader.ReadNextValue());
							}
							catch (IndexOutOfRangeException)
							{
								/// This exception is harmless and expected.
							}

							if (!string.IsNullOrEmpty(NewTrigger.m_strSubstring) && (NewTrigger.m_astrCommands.Count > 0))
								m_aCustomTellTriggerList.Add(NewTrigger);
						}
					}
				}

				Program.s_EmailQueueThread.PostNewProfileMessage(m_EmailProfile);
			}
			catch
			{
				Program.Log("Generic exception while parsing custom tell trigger file. List will be cleared and unused.");
				m_aCustomTellTriggerList.Clear();
			}

			return;
		}

		/************************************************************************************/
		public void WriteINISettings()
		{
			IniFile NewFile = new IniFile();
			TransferINISettings(NewFile);
			if (m_bWriteBackINI)
				NewFile.Save(Program.s_strCurrentINIFilePath);
			return;
		}
	}
}
