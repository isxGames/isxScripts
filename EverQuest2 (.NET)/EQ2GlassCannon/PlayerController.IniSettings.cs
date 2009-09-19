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
		protected enum StanceType
		{
			Neither = 0,
			Defensive = 1,
			Offensive = 2,
		}

		public bool m_bWriteBackINI = true;
		public int m_iFrameSkip = 2;
		public bool m_bKillBotWhenCamping = false;
		protected string m_strCustomTellTriggerFile = string.Empty;
		protected string m_strReloadINISubphrase = "rebuff me pls";
		protected List<string> m_astrMainTanks = new List<string>();
		protected List<string> m_astrAutoFollowTargets = new List<string>();
		protected List<string> m_astrCommandingPlayers = new List<string>();
		protected string m_strAssistSubphrase = "assist me";
		protected string m_strBotKillswitchSubphrase = "stop dps";
		protected string m_strProcessKillswitchSubphrase = "beddy-bye!!";
		protected string m_strDoNothingSubphrase = "afk";
		protected string m_strNeutralPositionSubphrase = "neutral";
		protected string m_strAutoFollowSubphrase = "come";
		protected string m_strCustomAutoFollowSubphrase = "stay close";
		protected string m_strStayInPlaceSubphrase = "stay here";
		protected string m_strShadowMeSubphrase = "shadow me";
		protected string m_strForwardDashSubphrase = "charge";
		protected string m_strClearGroupMaintainedSubphrase = "redo group buffs";
		protected string m_strMentorSubphrase = "mentor";
		protected string m_strRepairSubphrase = "repair";
		protected string m_strArbitraryVerbCommandPrefix = "try this: \"";
		protected string m_strArbitraryVerbCommandSeparator = "\", \"";
		protected string m_strArbitraryVerbCommandSuffix = "\"";
		protected double m_fStayInPlaceTolerance = 1.5;
		protected double m_fCustomAutoFollowMaximumRange = 10.0;
		protected int m_iCheckBuffsInterval = 500;
		protected double m_fAggroPanicPercentage = 90.0;
		protected bool m_bUseRanged = false;
		protected bool m_bUseGreenAEs = true;
		protected bool m_bUseBlueAEs = true;
		protected bool m_bAutoAttack = true;
		protected bool m_bSyncAbilitiesWithAutoAttack = false; /// Not implemented yet.
		protected bool m_bCastCures = true;
		protected bool m_bPrioritizeCures = true;
		protected bool m_bCancelCastForCures = true;
		protected bool m_bCureUngroupedMainTank = true;
		protected bool m_bHealUngroupedMainTank = true;
		protected bool m_bCastFurySalveIfGranted = true;
		protected bool m_bSpamHeroicOpportunity = true;
		protected bool m_bMezAdds = true;
		protected bool m_bMezMembersOfTargetEncounter = false;
		protected string m_strMezCallout = "MEZZING << {0} >> YOU BREAK IT YOU TANK IT!";
		protected bool m_bUseRacialBuffs = true;
		protected bool m_bUsePet = true;
		protected bool m_bSummonPetDuringCombat = false;
		protected bool m_bHarvestAutomatically = false;

		protected string m_strForwardKey = "W";
		protected string m_strBackwardKey = "S";
		protected string m_strTurnLeftKey = "A";
		protected string m_strTurnRightKey = "D";
		protected string m_strStrafeLeftKey = "Q";
		protected string m_strStrafeRightKey = "E";
		protected string m_strJumpKey = "Space";
		protected string m_strCancelKey = "Esc";

		protected EmailQueueThread.SMTPProfile m_EmailProfile = new EmailQueueThread.SMTPProfile();

		public bool m_bUseVoiceSynthesizer = true;
		protected string m_strVoiceSynthesizerProfile = "Microsoft Anna";
		protected int m_iVoiceSynthesizerVolume = 100;
		protected string m_strPhoneticCharacterName = "";

		protected string m_strChatWatchSubphrase = "listen for";
		protected List<string> m_astrChatWatchToAddressList = new List<string>();
		protected double m_fChatWatchAlertCooldownMinutes = 5.0;

		protected string m_strSpawnWatchSubphrase = "watch for";
		protected List<string> m_astrSpawnWatchToAddressList = new List<string>();
		protected string m_strSpawnWatchAlertCommand = string.Empty;
		protected string m_strSpawnWatchAlertSpeech = "{0} has just appeared";
		protected string m_strSpawnWatchDespawnSubphrase = "wait for despawn";
		protected double m_fSpawnWatchDespawnTimeoutMinutes = 6.0;

		/************************************************************************************/
		protected virtual void TransferINISettings(IniFile ThisFile)
		{
			ThisFile.TransferBool("General.WriteBackINI", ref m_bWriteBackINI);
			ThisFile.TransferInteger("General.FrameSkip", ref m_iFrameSkip);
			ThisFile.TransferBool("General.KillBotWhenCamping", ref m_bKillBotWhenCamping);
			ThisFile.TransferString("General.CustomTellTriggerFile", ref m_strCustomTellTriggerFile);
			ThisFile.TransferString("General.ReloadINISubphrase", ref m_strReloadINISubphrase);
			ThisFile.TransferStringList("General.MainTanks", m_astrMainTanks);
			ThisFile.TransferStringList("General.AutoFollowTargets", m_astrAutoFollowTargets);
			ThisFile.TransferStringList("General.CommandingPlayers", m_astrCommandingPlayers);
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
			ThisFile.TransferDouble("General.StayInPlaceTolerance", ref m_fStayInPlaceTolerance);
			ThisFile.TransferDouble("General.CustomAutoFollowMaximumRange", ref m_fCustomAutoFollowMaximumRange);
			ThisFile.TransferInteger("General.CheckBuffsInterval", ref m_iCheckBuffsInterval);
			ThisFile.TransferDouble("General.AggroPanicPercentage", ref m_fAggroPanicPercentage);
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
			ThisFile.TransferBool("General.MezMembersOfTargetEncounter", ref m_bMezMembersOfTargetEncounter);
			ThisFile.TransferBool("General.UseRacialBuffs", ref m_bUseRacialBuffs);
			ThisFile.TransferBool("General.UsePet", ref m_bUsePet);
			ThisFile.TransferBool("General.RecastPetDuringCombat", ref m_bSummonPetDuringCombat);
			ThisFile.TransferBool("General.HarvestAutomatically", ref m_bHarvestAutomatically);

			ThisFile.TransferString("Controls.ForwardKey", ref m_strForwardKey);
			ThisFile.TransferString("Controls.BackwardKey", ref m_strBackwardKey);
			ThisFile.TransferString("Controls.TurnLeftKey", ref m_strTurnLeftKey);
			ThisFile.TransferString("Controls.TurnRightKey", ref m_strTurnRightKey);
			ThisFile.TransferString("Controls.StrafeLeftKey", ref m_strStrafeLeftKey);
			ThisFile.TransferString("Controls.StrafeRightKey", ref m_strStrafeRightKey);
			ThisFile.TransferString("Controls.JumpKey", ref m_strJumpKey);
			ThisFile.TransferString("Controls.CancelKey", ref m_strCancelKey);

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

			/// Load the custom tell trigger list.
			try
			{
				m_aCustomChatTriggerList.Clear();
				string strInputFile = Path.Combine(Program.s_strINIFolderPath, m_strCustomTellTriggerFile);

				if (File.Exists(strInputFile))
				{
					using (CsvFileReader ThisReader = new CsvFileReader(strInputFile))
					{
						while (ThisReader.ReadLine())
						{
							CustomChatTrigger NewTrigger = new CustomChatTrigger();

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
								m_aCustomChatTriggerList.Add(NewTrigger);
						}
					}
				}

				Program.s_EmailQueueThread.PostNewProfileMessage(m_EmailProfile);
			}
			catch
			{
				Program.Log("Generic exception while parsing custom tell trigger file. List will be cleared and unused.");
				m_aCustomChatTriggerList.Clear();
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
		protected void ApplySettings()
		{
			/// Fallback option to prevent an unresponsive bot.
			if (m_astrCommandingPlayers.Count == 0)
				m_astrCommandingPlayers.Add(Me.Name);

			if (string.IsNullOrEmpty(m_strPhoneticCharacterName))
				m_strPhoneticCharacterName = Me.Name;

			Program.ToggleSpeechSynthesizer(m_bUseVoiceSynthesizer, m_iVoiceSynthesizerVolume, m_strVoiceSynthesizerProfile);

			if (m_ePositioningStance == PositioningStance.CustomAutoFollow)
				m_fCurrentMovementTargetCoordinateTolerance = m_fCustomAutoFollowMaximumRange;

			return;
		}
	}
}
