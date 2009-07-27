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
		public string m_strStayInPlaceSubphrase = "stay here";
		public string m_strShadowMeSubphrase = "shadow me";
		public string m_strForwardDashSubphrase = "charge";
		public string m_strClearGroupMaintainedSubphrase = "redo group buffs";
		public string m_strMentorSubphrase = "mentor";
		public string m_strRepairSubphrase = "repair";
		public string m_strArbitraryVerbCommandPrefix = "try this: \"";
		public string m_strArbitraryVerbCommandSeparator = "\", \"";
		public string m_strArbitraryVerbCommandSuffix = "\"";
		public float m_fStayInPlaceTolerance = 1.5f;
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
		public bool m_bSpamHeroicOpportunity = true;
		public bool m_bMezAdds = false;
		public bool m_bUseRacialBuffs = true;
		public bool m_bUsePet = true;
		public bool m_bSummonPetDuringCombat = false;
		public bool m_bHarvestAutomatically = false;
		public int m_iFrameSkip = 2;
		public EmailQueueThread.SMTPProfile m_EmailProfile = new EmailQueueThread.SMTPProfile();
		public string m_strSpawnWatchSubphrase = "watch for";
		public List<string> m_astrSpawnWatchToAddressList = new List<string>();
		public string m_strSpawnWatchAlertCommand = string.Empty;
		public string m_strSpawnWatchDespawnSubphrase = "wait for despawn";
		public float m_fSpawnWatchDespawnTimeoutMinutes = 5.0f;

		/************************************************************************************/
		public enum TransferType
		{
			Read,
			Write
		}

		/************************************************************************************/
		protected virtual void TransferINISettings(TransferType eTransferType)
		{
			TransferINIBool(eTransferType, "General.WriteBackINI", ref m_bWriteBackINI);
			TransferINIString(eTransferType, "General.CustomTellTriggerFile", ref m_strCustomTellTriggerFile);
			TransferINIString(eTransferType, "General.ReloadINISubphrase", ref m_strReloadINISubphrase);
			TransferINIString(eTransferType, "General.MainTank", ref m_strMainTank);
			TransferINIString(eTransferType, "General.AutoFollowTarget", ref m_strAutoFollowTarget);
			TransferINIString(eTransferType, "General.CommandingPlayer", ref m_strCommandingPlayer);
			TransferINICaselessString(eTransferType, "General.AssistSubphrase", ref m_strAssistSubphrase);
			TransferINICaselessString(eTransferType, "General.BotKillswitchSubphrase", ref m_strBotKillswitchSubphrase);
			TransferINICaselessString(eTransferType, "General.ProcessKillswitchSubphrase", ref m_strProcessKillswitchSubphrase);
			TransferINICaselessString(eTransferType, "General.DoNothingSubphrase", ref m_strDoNothingSubphrase);
			TransferINICaselessString(eTransferType, "General.NeutralPositionSubphrase", ref m_strNeutralPositionSubphrase);
			TransferINICaselessString(eTransferType, "General.AutoFollowSubphrase", ref m_strAutoFollowSubphrase);
			TransferINICaselessString(eTransferType, "General.StayInPlaceSubphrase", ref m_strStayInPlaceSubphrase);
			TransferINICaselessString(eTransferType, "General.ShadowMeSubphrase", ref m_strShadowMeSubphrase);
			TransferINICaselessString(eTransferType, "General.ForwardDashSubphrase", ref m_strForwardDashSubphrase);
			TransferINICaselessString(eTransferType, "General.ClearGroupMaintainedSubphrase", ref m_strClearGroupMaintainedSubphrase);
			TransferINICaselessString(eTransferType, "General.MentorSubphrase", ref m_strMentorSubphrase);
			TransferINICaselessString(eTransferType, "General.RepairSubphrase", ref m_strRepairSubphrase);
			TransferINIString(eTransferType, "General.ArbitraryVerbCommandPrefix", ref m_strArbitraryVerbCommandPrefix);
			TransferINIString(eTransferType, "General.ArbitraryVerbCommandSeparator", ref m_strArbitraryVerbCommandSeparator);
			TransferINIString(eTransferType, "General.ArbitraryVerbCommandSuffix", ref m_strArbitraryVerbCommandSuffix);
			TransferINIInteger(eTransferType, "General.CheckBuffsInterval", ref m_iCheckBuffsInterval);
			TransferINIBool(eTransferType, "General.UseRanged", ref m_bUseRanged);
			TransferINIBool(eTransferType, "General.UseGreenAEs", ref m_bUseGreenAEs);
			TransferINIBool(eTransferType, "General.UseBlueAEs", ref m_bUseBlueAEs);
			TransferINIBool(eTransferType, "General.AutoAttack", ref m_bAutoAttack);
			TransferINIBool(eTransferType, "General.SyncAbilitiesWithAutoAttack", ref m_bSyncAbilitiesWithAutoAttack);
			TransferINIBool(eTransferType, "General.CastCures", ref m_bCastCures);
			TransferINIBool(eTransferType, "General.PrioritizeCures", ref m_bPrioritizeCures);
			TransferINIBool(eTransferType, "General.CureMainTank", ref m_bCureMainTank);
			TransferINIBool(eTransferType, "General.HealMainTank", ref m_bHealMainTank);
			TransferINIBool(eTransferType, "General.SpamHeroicOpportunity", ref m_bSpamHeroicOpportunity);
			TransferINIBool(eTransferType, "General.MezAdds", ref m_bMezAdds);
			TransferINIBool(eTransferType, "General.UseRacialBuffs", ref m_bUseRacialBuffs);
			TransferINIBool(eTransferType, "General.UsePet", ref m_bUsePet);
			TransferINIBool(eTransferType, "General.RecastPetDuringCombat", ref m_bSummonPetDuringCombat);
			TransferINIBool(eTransferType, "General.HarvestAutomatically", ref m_bHarvestAutomatically);
			TransferINIInteger(eTransferType, "General.FrameSkip", ref m_iFrameSkip);
			TransferINIFloat(eTransferType, "General.StayInPlaceTolerance", ref m_fStayInPlaceTolerance);

			/// E-mail account values.
			TransferINIString(eTransferType, "E-Mail.SMTPServer", ref m_EmailProfile.m_strServer);
			TransferINIInteger(eTransferType, "E-Mail.SMTPPort", ref m_EmailProfile.m_iPort);
			TransferINIBool(eTransferType, "E-Mail.SMTPUseSSL", ref m_EmailProfile.m_bUseSSL);
			TransferINIString(eTransferType, "E-Mail.SMTPAccount", ref m_EmailProfile.m_strAccount);
			TransferINIString(eTransferType, "E-Mail.SMTPPassword", ref m_EmailProfile.m_strPassword);
			TransferINICaselessString(eTransferType, "E-Mail.FromAddress", ref m_EmailProfile.m_strFromAddress);

			/// Spawn Watch values.
			TransferINICaselessString(eTransferType, "SpawnWatch.Subphrase", ref m_strSpawnWatchSubphrase);
			TransferINIStringList(eTransferType, "SpawnWatch.ToAddresses", m_astrSpawnWatchToAddressList);
			TransferINIString(eTransferType, "SpawnWatch.AlertCommand", ref m_strSpawnWatchAlertCommand);
			TransferINICaselessString(eTransferType, "SpawnWatch.DespawnSubphrase", ref m_strSpawnWatchDespawnSubphrase);
			TransferINIFloat(eTransferType, "SpawnWatch.DespawnTimeoutMinutes", ref m_fSpawnWatchDespawnTimeoutMinutes);

			if (eTransferType == TransferType.Read)
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
			TransferINISettings(PlayerController.TransferType.Read);

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
			TransferINISettings(PlayerController.TransferType.Write);
			return;
		}

		/************************************************************************************/
		protected bool ReadINIString(string strKey, ref string strValue)
		{
			string strPreviousValue = strValue;
			if (!Program.s_INISettings.TryGetValue(strKey, out strValue))
			{
				/// TryGetValue turns the string to null, but null strings are bad.
				strValue = strPreviousValue;
				return false;
			}
			else
				return true;
		}

		/************************************************************************************/
		protected void WriteINIString(string strKey, string strValue)
		{
			if (Program.s_INISettings.ContainsKey(strKey))
				Program.s_INISettings[strKey] = strValue;
			else
				Program.s_INISettings.Add(strKey, strValue);
			return;
		}

		/************************************************************************************/
		public void TransferINIString(TransferType eTransferType, string strKey, ref string strValue)
		{
			if (eTransferType == TransferType.Read)
				ReadINIString(strKey, ref strValue);
			else
				WriteINIString(strKey, strValue);
			return;
		}

		/************************************************************************************/
		public void TransferINICaselessString(TransferType eTransferType, string strKey, ref string strValue)
		{
			if (eTransferType == TransferType.Read)
			{
				if (ReadINIString(strKey, ref strValue))
					strValue = strValue.ToLower();
			}
			else
				WriteINIString(strKey, strValue);
			return;
		}

		/************************************************************************************/
		public void TransferINIStringList(TransferType eTransferType, string strKey, List<string> astrValues)
		{
			if (astrValues == null)
				return;

			if (eTransferType == TransferType.Read)
			{
				string strCombinedValue = string.Empty;
				if (ReadINIString(strKey, ref strCombinedValue))
				{
					string[] astrRawValues = strCombinedValue.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
					astrValues.Clear();
					astrValues.AddRange(astrRawValues);
					for (int iIndex = 0; iIndex < astrValues.Count; iIndex++)
						astrValues[iIndex] = astrValues[iIndex].Trim();
				}
			}
			else
			{
				string strCombinedValue = string.Empty;
				foreach (string strValue in astrValues)
				{
					if (!string.IsNullOrEmpty(strCombinedValue))
						strCombinedValue += ",";
					strCombinedValue += strValue;
				}

				WriteINIString(strKey, strCombinedValue);
			}
			return;
		}

		/************************************************************************************/
		public void TransferINIBool(TransferType eTransferType, string strKey, ref bool bValue)
		{
			if (eTransferType == TransferType.Read)
			{
				string strValue = string.Empty;
				if (ReadINIString(strKey, ref strValue))
				{
					strValue = strValue.ToLower();
					bValue = (strValue == "1") || (strValue == "true") || (strValue == "yes");
				}
			}
			else
				WriteINIString(strKey, bValue ? "yes" : "no");
			return;
		}

		/************************************************************************************/
		public void TransferINIInteger(TransferType eTransferType, string strKey, ref int iValue)
		{
			if (eTransferType == TransferType.Read)
			{
				string strValue = string.Empty;
				if (ReadINIString(strKey, ref strValue))
				{
					int iTemp;
					if (int.TryParse(strValue, out iTemp))
						iValue = iTemp;
				}
			}
			else
				WriteINIString(strKey, iValue.ToString());
			return;
		}

		/************************************************************************************/
		public void TransferINIFloat(TransferType eTransferType, string strKey, ref float fValue)
		{
			if (eTransferType == TransferType.Read)
			{
				string strValue = string.Empty;
				if (ReadINIString(strKey, ref strValue))
				{
					float fTemp;
					if (float.TryParse(strValue, out fTemp))
						fValue = fTemp;
				}
			}
			else
				WriteINIString(strKey, fValue.ToString());
			return;
		}

		/************************************************************************************/
		public void TransferINIDouble(TransferType eTransferType, string strKey, ref double fValue)
		{
			if (eTransferType == TransferType.Read)
			{
				string strValue = string.Empty;
				if (ReadINIString(strKey, ref strValue))
				{
					double fTemp;
					if (double.TryParse(strValue, out fTemp))
						fValue = fTemp;
				}
			}
			else
				WriteINIString(strKey, fValue.ToString());
			return;
		}
	}
}
