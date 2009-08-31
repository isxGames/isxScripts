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
		public enum StanceType
		{
			Neither = 0,
			Defensive = 1,
			Offensive = 2,
		}

		public bool m_bWriteBackINI = true;
		public string m_strCustomTellTriggerFile = string.Empty;
		public string m_strReloadINISubphrase = "rebuff me pls";
		public List<string> m_astrMainTanks = new List<string>();
		public List<string> m_astrAutoFollowTargets = new List<string>();
		public List<string> m_astrCommandingPlayers = new List<string>();
		public string m_strCommandChannel = string.Empty;
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
		public bool m_bKillBotWhenCamping = false;
		public bool m_bUseRanged = false;
		public bool m_bUseGreenAEs = true;
		public bool m_bUseBlueAEs = true;
		public bool m_bAutoAttack = true;
		public bool m_bSyncAbilitiesWithAutoAttack = false; /// Not implemented yet.
		public bool m_bCastCures = true;
		public bool m_bPrioritizeCures = true;
		public bool m_bCancelCastForCures = true;
		public bool m_bCureUngroupedMainTank = true;
		public bool m_bHealUngroupedMainTank = true;
		public bool m_bCastFurySalveIfGranted = true;
		public bool m_bSpamHeroicOpportunity = true;
		public bool m_bMezAdds = false;
		public bool m_bUseRacialBuffs = true;
		public bool m_bUsePet = true;
		public bool m_bSummonPetDuringCombat = false;
		public bool m_bHarvestAutomatically = false;
		public int m_iFrameSkip = 2;
		public EmailQueueThread.SMTPProfile m_EmailProfile = new EmailQueueThread.SMTPProfile();
		public bool m_bUseVoiceSynthesizer = true;
		public string m_strVoiceSynthesizerProfile = "Microsoft Anna";
		public int m_iVoiceSynthesizerVolume = 100;
		public string m_strPhoneticCharacterName = "";
		public string m_strChatWatchSubphrase = "listen for";
		public List<string> m_astrChatWatchToAddressList = new List<string>();
		public double m_fChatWatchAlertCooldownMinutes = 5.0;
		public string m_strSpawnWatchSubphrase = "watch for";
		public List<string> m_astrSpawnWatchToAddressList = new List<string>();
		public string m_strSpawnWatchAlertCommand = string.Empty;
		public string m_strSpawnWatchAlertSpeech = "{0} has just appeared";
		public string m_strSpawnWatchDespawnSubphrase = "wait for despawn";
		public double m_fSpawnWatchDespawnTimeoutMinutes = 6.0;

		/************************************************************************************/
		protected virtual void TransferINISettings(IniFile ThisFile)
		{
			ThisFile.TransferBool("General.WriteBackINI", ref m_bWriteBackINI);
			ThisFile.TransferString("General.CustomTellTriggerFile", ref m_strCustomTellTriggerFile);
			ThisFile.TransferString("General.ReloadINISubphrase", ref m_strReloadINISubphrase);
			ThisFile.TransferStringList("General.MainTanks", m_astrMainTanks);
			ThisFile.TransferStringList("General.AutoFollowTargets", m_astrAutoFollowTargets);
			ThisFile.TransferStringList("General.CommandingPlayers", m_astrCommandingPlayers);
			ThisFile.TransferString("General.CommandChannel", ref m_strCommandChannel);
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
			ThisFile.TransferBool("General.KillBotWhenCamping", ref m_bKillBotWhenCamping);
			ThisFile.TransferBool("General.UseRanged", ref m_bUseRanged);
			ThisFile.TransferBool("General.UseGreenAEs", ref m_bUseGreenAEs);
			ThisFile.TransferBool("General.UseBlueAEs", ref m_bUseBlueAEs);
			ThisFile.TransferBool("General.AutoAttack", ref m_bAutoAttack);
			ThisFile.TransferBool("General.SyncAbilitiesWithAutoAttack", ref m_bSyncAbilitiesWithAutoAttack);
			ThisFile.TransferBool("General.CastCures", ref m_bCastCures);
			ThisFile.TransferBool("General.PrioritizeCures", ref m_bPrioritizeCures);
			ThisFile.TransferBool("General.CancelCastForCures", ref m_bCancelCastForCures);
			ThisFile.TransferBool("General.CureUngroupedMainTank", ref m_bCureUngroupedMainTank);
			ThisFile.TransferBool("General.HealUngroupedMainTank", ref m_bHealUngroupedMainTank);
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

			ThisFile.TransferBool("Voice.UseSynthesizer", ref m_bUseVoiceSynthesizer);
			ThisFile.TransferString("Voice.SynthesizerProfile", ref m_strVoiceSynthesizerProfile);
			ThisFile.TransferInteger("Voice.SynthesizerVolume", ref m_iVoiceSynthesizerVolume);
			ThisFile.TransferString("Voice.PhoneticCharacterName", ref m_strPhoneticCharacterName);

			/// Chat Watch values.
			ThisFile.TransferCaselessString("ChatWatch.Subphrase", ref m_strChatWatchSubphrase);
			ThisFile.TransferStringList("ChatWatch.ToAddresses", m_astrChatWatchToAddressList);
			ThisFile.TransferDouble("ChatWatch.AlertCooldownMinutes", ref m_fChatWatchAlertCooldownMinutes);

			/// Spawn Watch values.
			ThisFile.TransferCaselessString("SpawnWatch.Subphrase", ref m_strSpawnWatchSubphrase);
			ThisFile.TransferStringList("SpawnWatch.ToAddresses", m_astrSpawnWatchToAddressList);
			ThisFile.TransferString("SpawnWatch.AlertCommand", ref m_strSpawnWatchAlertCommand);
			ThisFile.TransferString("SpawnWatch.AlertSpeech", ref m_strSpawnWatchAlertSpeech);
			ThisFile.TransferCaselessString("SpawnWatch.DespawnSubphrase", ref m_strSpawnWatchDespawnSubphrase);
			ThisFile.TransferDouble("SpawnWatch.DespawnTimeoutMinutes", ref m_fSpawnWatchDespawnTimeoutMinutes);

			return;
		}

		/************************************************************************************/
		public void ReadINISettings()
		{
			IniFile NewFile = new IniFile(Program.s_strCurrentINIFilePath);
			TransferINISettings(NewFile);

			if (File.Exists(Program.s_strSharedOverridesINIFilePath))
			{
				IniFile OverridesFile = new IniFile(Program.s_strSharedOverridesINIFilePath);
				TransferINISettings(OverridesFile);
			}

			ApplySettings();

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

		/************************************************************************************/
		public void ApplySettings()
		{
			/// Fallback option to prevent an unresponsive bot.
			if (m_astrCommandingPlayers.Count == 0)
				m_astrCommandingPlayers.Add(Me.Name);

			if (string.IsNullOrEmpty(m_strPhoneticCharacterName))
				m_strPhoneticCharacterName = Me.Name;

			Program.ToggleSpeechSynthesizer(m_bUseVoiceSynthesizer, m_iVoiceSynthesizerVolume, m_strVoiceSynthesizerProfile);

			if (m_ePositioningStance == PositioningStance.CustomAutoFollow)
				m_fCurrentMovementTargetCoordinateTolerance = m_fCustomAutoFollowMinimumRange;

			return;
		}
	}
}
