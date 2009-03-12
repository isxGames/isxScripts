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

namespace EQ2GlassCannon
{
	public partial class PlayerController
	{
		public const int ABILITY_TARGET_TYPE_GROUP = 2;

		#region INI settings
		public bool m_bWriteBackINI = true;
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
		public string m_strSpawnWatchSubphrase = "watch for";
		public string m_strSpawnWatchSMTPServer = string.Empty;
		public int m_iSpawnWatchSMTPPort = 25;
		public string m_strSpawnWatchSMTPAccount = string.Empty;
		public string m_strSpawnWatchSMTPPassword = string.Empty;
		public List<string> m_astrSpawnWatchToAddressList = new List<string>();
		public string m_strSpawnWatchFromAddress = string.Empty;
		public string m_strSpawnWatchAlertCommand = string.Empty;
		public float m_fStayInPlaceTolerance = 1.5f;
		public int m_iCheckBuffsInterval = 500;
		public bool m_bUseRanged = false;
		public bool m_bUseGreenAEs = true;
		public bool m_bUseBlueAEs = true;
		public bool m_bAutoAttack = true;
		public bool m_bCastCures = true;
		public bool m_bPrioritizeCures = true;
		public bool m_bCureMainTank = true;
		public bool m_bHealMainTank = true;
		public bool m_bSpamHeroicOpportunity = true;
		public bool m_bSpamCrowdControl = false;
		public bool m_bMezAdds = false;
		public bool m_bUseRacialBuffs = true;
		public bool m_bUsePet = true;
		public bool m_bSummonPetDuringCombat = false;
		public int m_iFrameSkip = 2;
		#endregion

		public int m_iLoreAndLegendAbilityID = -1;
		public int m_iHOStarterAbiltyID = -1;
		public int m_iFeatherfallAbilityID = -1;
		public int m_iHalfElfMitigationDebuffAbilityID = -1;

		public enum PositioningStance
		{
			DoNothing,
			NeutralPosition,
			AutoFollow,
			StayInPlace,
			ShadowMe,
			ForwardDash,
			SpawnWatch,
		}

		public class Point3D
		{
			public float X = 0.0f;
			public float Y = 0.0f;
			public float Z = 0.0f;

			public Point3D()
			{
				return;
			}

			public Point3D(Actor SourceActor)
			{
				X = SourceActor.X;
				Y = SourceActor.Y;
				Z = SourceActor.Z;
				return;
			}
		}

		public bool m_bContinueBot = true;
		public bool m_bCheckBuffsNow = true;
		public bool m_bIHaveAggro = false;
		public bool m_bClearGroupMaintained = false;
		public DateTime m_LastCheckBuffsTime = DateTime.Now;
		public int m_iOffensiveTargetID = -1;
		public Actor m_OffensiveTargetActor = null;
		public Actor m_CommandingPlayerActor = null;
		public int m_iAbilitiesFound = 0;
		public PositioningStance m_ePositioningStance = PositioningStance.AutoFollow;
		public Point3D m_ptStayLocation = new Point3D();
		public bool m_bSpawnWatchTargetAnnounced = false;
		public string m_strSpawnWatchTarget = string.Empty;

		public Dictionary<string, int> m_KnowledgeBookNameToIndexMap = new Dictionary<string, int>();
		public Dictionary<int, string> m_KnowledgeBookIndexToNameMap = new Dictionary<int, string>();
		public Dictionary<string, GroupMember> m_GroupMemberDictionary = new Dictionary<string, GroupMember>();
		public Dictionary<string, GroupMember> m_FriendDictionary = new Dictionary<string, GroupMember>();

		/// <summary>
		/// Within a frame lock, CastPBAEAbility() might be called multiple times for the same spell.
		/// This cache prevents the need for redundant range detection on all NPC's within the blast radius,
		/// which can conceivably be taxing on CPU usage.
		/// </summary>
		public Dictionary<int, int> m_DetectedAbilityTargetCountCache = new Dictionary<int, int>();

		/// <summary>
		/// This associates all identical spells of a shared recast timer with the index of the highest level version of them.
		/// </summary>
		public Dictionary<string, int> m_KnowledgeBookCategoryDictionary = new Dictionary<string, int>();

		/// <summary>
		/// This dictionary has only one entry per spell regardless of how many targets the spell is actually on,
		/// but allows immediate O(1) boolean detection of any maintained effect.
		/// This is repopulated on every new frame.
		/// </summary>
		private Dictionary<string, int> m_MaintainedNameToIndexMap = new Dictionary<string, int>();

		private Dictionary<string, int> m_BeneficialEffectNameToIndexMap = new Dictionary<string, int>();

		/************************************************************************************/
		public Character Me
		{
			get
			{
				return Program.Me;
			}
		}

		/************************************************************************************/
		public Actor MeActor
		{
			get
			{
				return Program.MeActor;
			}
		}

		#region INI file settings.

		/************************************************************************************/
		public enum TransferType
		{
			Read,
			Write
		}

		/************************************************************************************/
		public virtual void TransferINISettings(TransferType eTransferType)
		{
			TransferINIBool(eTransferType, "General.WriteBackINI", ref m_bWriteBackINI);
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
			TransferINICaselessString(eTransferType, "General.SpawnWatchSubphrase", ref m_strSpawnWatchSubphrase);
			TransferINIString(eTransferType, "General.SpawnWatchSMTPServer", ref m_strSpawnWatchSMTPServer);
			TransferINIInteger(eTransferType, "General.SpawnWatchSMTPPort", ref m_iSpawnWatchSMTPPort);
			TransferINIString(eTransferType, "General.SpawnWatchSMTPAccount", ref m_strSpawnWatchSMTPAccount);
			TransferINIString(eTransferType, "General.SpawnWatchSMTPPassword", ref m_strSpawnWatchSMTPPassword);
			TransferINIString(eTransferType, "General.SpawnWatchGuildChatAlert", ref m_strSpawnWatchSMTPPassword);
			TransferINIStringList(eTransferType, "General.SpawnWatchToAddresses", m_astrSpawnWatchToAddressList);
			TransferINICaselessString(eTransferType, "General.SpawnWatchFromAddress", ref m_strSpawnWatchFromAddress);
			TransferINIString(eTransferType, "General.SpawnWatchAlertCommand", ref m_strSpawnWatchAlertCommand);
			TransferINIInteger(eTransferType, "General.CheckBuffsInterval", ref m_iCheckBuffsInterval);
			TransferINIBool(eTransferType, "General.UseRanged", ref m_bUseRanged);
			TransferINIBool(eTransferType, "General.UseGreenAEs", ref m_bUseGreenAEs);
			TransferINIBool(eTransferType, "General.UseBlueAEs", ref m_bUseBlueAEs);
			TransferINIBool(eTransferType, "General.AutoAttack", ref m_bAutoAttack);
			TransferINIBool(eTransferType, "General.CastCures", ref m_bCastCures);
			TransferINIBool(eTransferType, "General.PrioritizeCures", ref m_bPrioritizeCures);
			TransferINIBool(eTransferType, "General.CureMainTank", ref m_bCureMainTank);
			TransferINIBool(eTransferType, "General.HealMainTank", ref m_bHealMainTank);
			TransferINIBool(eTransferType, "General.SpamHeroicOpportunity", ref m_bSpamHeroicOpportunity);
			TransferINIBool(eTransferType, "General.SpamCrowdControl", ref m_bSpamCrowdControl);
			TransferINIBool(eTransferType, "General.MezAdds", ref m_bMezAdds);
			TransferINIBool(eTransferType, "General.UseRacialBuffs", ref m_bUseRacialBuffs);
			TransferINIBool(eTransferType, "General.UsePet", ref m_bUsePet);
			TransferINIBool(eTransferType, "General.RecastPetDuringCombat", ref m_bSummonPetDuringCombat);
			TransferINIInteger(eTransferType, "General.FrameSkip", ref m_iFrameSkip);
			TransferINIFloat(eTransferType, "General.StayInPlaceTolerance", ref m_fStayInPlaceTolerance);

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

		#endregion

		/************************************************************************************/
		public virtual void InitializeKnowledgeBook()
		{
			Program.Log("Referencing Knowledge Book...");

			while (Program.s_bContinueBot)
			{
				m_KnowledgeBookNameToIndexMap.Clear();
				m_KnowledgeBookIndexToNameMap.Clear();

				using (new FrameLock(true))
				{
					Program.UpdateGlobals();

					if (Me.NumAbilities == 0)
						Program.Log("NO abilities found!");
					else
					{
						m_iAbilitiesFound = 0;

						for (int iIndex = 1; iIndex <= Me.NumAbilities; iIndex++)
						{
							Ability ThisAbility = Me.Ability(iIndex);
							if (ThisAbility.Name != null)
							{
								if (m_KnowledgeBookNameToIndexMap.ContainsKey(ThisAbility.Name))
									Program.Log("WARNING: Duplicate ability found ({0}). This could be problematic with maintained spells.", ThisAbility.Name);
								else
									m_KnowledgeBookNameToIndexMap.Add(ThisAbility.Name, iIndex);
								m_KnowledgeBookIndexToNameMap.Add(iIndex, ThisAbility.Name);

								m_iAbilitiesFound++;
							}
						}

						if (m_iAbilitiesFound < Me.NumAbilities)
							Program.Log(string.Format("Found {0} names of {1} abilities so far.", m_iAbilitiesFound, Me.NumAbilities));
						else
						{
							Program.Log("All abilities found.");
							break;
						}

					}
				}

				/// This is black magic to force the client to reload the knowledge book.
				Program.RunCommand("/showcombatartbook");
				Program.FrameWait(TimeSpan.FromSeconds(3.0f));
				Program.RunCommand("/toggleknowledge");
			}

			/// This must be done before any call to SelectHighestAbilityID().
			m_KnowledgeBookCategoryDictionary.Clear();

			/// Racials.
			m_iFeatherfallAbilityID = SelectHighestAbilityID(
				//"Mind over Matter", /// High Elves. Commented out until the devs reconcile this with the tradeskill ability of the same name.
				"Glide", /// Fae.
				"Falling Grace" /// Erudites.
				);
			m_iHalfElfMitigationDebuffAbilityID = SelectHighestAbilityID("Piercing Stab");

			return;
		}

		/************************************************************************************/
		/// <summary>
		/// The base function caches certain lookup data.
		/// </summary>
		/// <returns>true if an action was taken and no further processing should occur</returns>
		public virtual bool DoNextAction()
		{
			/// We freshly reacquire this for every frame.
			m_OffensiveTargetActor = null;

			if (m_ePositioningStance == PositioningStance.DoNothing)
				return true;
			else if (m_ePositioningStance == PositioningStance.SpawnWatch)
			{
				foreach (Actor ThisActor in EnumCustomActors())
				{
					string strThisActorName = ThisActor.Name.Trim().ToLower();
					if (strThisActorName == m_strSpawnWatchTarget)
					{
						Program.Log("Spawn Watch target \"{0}\" found!", ThisActor.Name);

						if (!string.IsNullOrEmpty(m_strSpawnWatchSMTPServer) && (m_astrSpawnWatchToAddressList.Count > 0))
						{
							Program.Log("Attempting to send Spawn Watch e-mails...");

							if (Program.SendEMail(
								m_strSpawnWatchSMTPServer, m_iSpawnWatchSMTPPort,
								m_strSpawnWatchSMTPAccount, m_strSpawnWatchSMTPPassword,
								m_strSpawnWatchFromAddress, m_astrSpawnWatchToAddressList,
								"From " + Me.Name,
								ThisActor.Name + " just spawned!"))
							{
								Program.Log("Spawn Watch e-mails successfully sent.");
							}
							else
							{
								Program.Log("Not all Spawn Watch e-mails could be sent!");
							}
						}

						try
						{
							Program.RunCommand(m_strSpawnWatchAlertCommand, m_strSpawnWatchTarget);
						}
						catch
						{
							Program.Log("Error in Spawn Watch alert command format.");
						}

						Program.Log("Reverting back to AFK mode. You will need to send another command to resume Spawn Watch.");
						m_ePositioningStance = PositioningStance.DoNothing;
						return true;
					}
				}
				return true;
			}

			m_GroupMemberDictionary.Clear();
			foreach (GroupMember ThisMember in EnumGroupMembers())
				m_GroupMemberDictionary.Add(ThisMember.Name, ThisMember);

			m_FriendDictionary.Clear();
			foreach (GroupMember ThisMember in EnumRaidMembers())
				m_FriendDictionary.Add(ThisMember.Name, ThisMember);

			/// If we're not in a raid, or for some weird reason the raid enum turned up blanks,
			/// then just copy from the group list (cheating!).
			if (m_FriendDictionary.Count == 0)
			{
				foreach (KeyValuePair<string, GroupMember> ThisPair in m_GroupMemberDictionary)
					m_FriendDictionary.Add(ThisPair.Key, ThisPair.Value);
			}

			/// Define the commanding player actor object.
			if (m_GroupMemberDictionary.ContainsKey(m_strCommandingPlayer))
			{
				m_CommandingPlayerActor = m_GroupMemberDictionary[m_strCommandingPlayer].ToActor();
				if (m_CommandingPlayerActor.IsValid)
				{
					/// If commanding player is AFK, then DON'T DO SHIT.
					/// NOTE: I can't get this to work yet.
					if (m_CommandingPlayerActor.IsAFK)
						return true;
				}
				else
					m_CommandingPlayerActor = null;
			}
			else
				m_CommandingPlayerActor = null;

			m_MaintainedNameToIndexMap.Clear();
			for (int iIndex = 1; iIndex <= Me.CountMaintained; iIndex++)
			{
				string strName = Me.Maintained(iIndex).Name;
				if (strName != null)
				{
					if (!m_MaintainedNameToIndexMap.ContainsKey(strName))
						m_MaintainedNameToIndexMap.Add(strName, iIndex);
				}
			}

			/// If we have been commanded to redo group buffs, then cancel one per frame.
			if (m_bClearGroupMaintained)
			{
				foreach (Maintained ThisMaintained in EnumMaintained())
				{
					if (ThisMaintained.Type == "Group")
						return ThisMaintained.Cancel();
				}
				m_bClearGroupMaintained = false;
			}

			m_BeneficialEffectNameToIndexMap.Clear();
			for (int iIndex = 1; iIndex <= Me.CountEffects; iIndex++)
			{
				string strName = Me.Effect(iIndex).Name;
				if (strName != null)
				{
					if (!m_BeneficialEffectNameToIndexMap.ContainsKey(strName))
						m_BeneficialEffectNameToIndexMap.Add(strName, iIndex);
				}
			}

			/// Decide whether now is a good time to check buffs.
			if (!m_bCheckBuffsNow)
			{
				if (DateTime.Now > (m_LastCheckBuffsTime + TimeSpan.FromMilliseconds(m_iCheckBuffsInterval)))
				{
					Program.Log("Checking buffs now.");

					/// Only derived classes set the flag back to false.
					m_bCheckBuffsNow = true;
				}
			}

			m_DetectedAbilityTargetCountCache.Clear();

			if (CheckPositioningStance())
				return true;

			return false;
		}

		/************************************************************************************/
		public virtual bool OnChoiceWindowAppeared(ChoiceWindow ThisWindow)
		{
			Program.Log("Choice window appeared: {0}", ThisWindow.Text);

			/// Group invite window.
			/// BUG: This doesn't work for some reason if the inviter is in a different zone!
			if (ThisWindow.Text.Contains("has invited you to join a group."))
			{
				/// Only accept group invites from the commanding player.
				if (!string.IsNullOrEmpty(m_strCommandingPlayer) && ThisWindow.Text.StartsWith(m_strCommandingPlayer))
					Program.RunCommand("/acceptinvite");
				else
					Program.RunCommand("/declineinvite");

				return true;
			}

			/// Rez window (could be port too, gotta be careful).
			/// "* would like to cast '*' on you. Do you accept?"
			/// TODO: Only accept if person is in group/raid.
			else if (ThisWindow.Text.Contains("would like to cast"))
			{
				/// Always accept; no known reason not to yet.
				ThisWindow.DoChoice1(); /// Accept
				return true;
			}

			return false;
		}

		/************************************************************************************/
		public virtual bool OnIncomingText(string strFrom, string strChatText)
		{
			if (string.IsNullOrEmpty(strFrom))
			{
			}

			return false;
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		/// <param name="iChannel"></param>
		/// <param name="strFrom"></param>
		/// <param name="strMessage"></param>
		/// <returns>true if handled by a base implementation, and if no further processing should be permitted.</returns>
		public virtual bool OnIncomingChatText(int iChannel, string strFrom, string strMessage)
		{
			string strTrimmedMessage = strMessage.Trim();
			string strLowerCaseMessage = strTrimmedMessage.ToLower();

			if (string.Compare(strFrom, m_strCommandingPlayer, true) == 0)
			{
				Actor CommandingPlayerActor = GetNonPetActor(m_strCommandingPlayer);

				/// This is the assist call; direct the bot to begin combat.
				if (strLowerCaseMessage.Contains(m_strAssistSubphrase))
				{
					if (CommandingPlayerActor == null)
						Program.Log("Commanding player not a valid combat assist!");
					else
					{
						Actor OffensiveTargetActor = CommandingPlayerActor.Target();

						/// Successful target acquisition.
						if (OffensiveTargetActor != null && OffensiveTargetActor.IsValid && (OffensiveTargetActor.Type == "NPC" || OffensiveTargetActor.Type == "NamedNPC"))
						{
							m_iOffensiveTargetID = OffensiveTargetActor.ID;
							Program.Log("New offensive target: {0}", OffensiveTargetActor.Name);
						}
						else
						{
							if (OffensiveTargetActor != null)
								Program.Log("{0} provided an invalid offensive target ({1}, {2}, {3}).", CommandingPlayerActor.Name, OffensiveTargetActor.Name, OffensiveTargetActor.ID, OffensiveTargetActor.Type);

							/// Combat is now cancelled.
							/// Maybe the commanding player misclicked or clicked off intentionally, but it doesn't matter.
							WithdrawFromCombat();
						}
					}

					return true;
				}

				/// Reload the INI file; the rest of the code will adjust on its own.
				else if (strLowerCaseMessage.Contains(m_strReloadINISubphrase))
				{
					Program.Log("Reload INI command (\"{0}\") received.", m_strReloadINISubphrase);
					Program.LoadINIFile();
					TransferINISettings(TransferType.Read);
				}

				else if (strLowerCaseMessage.Contains(m_strDoNothingSubphrase))
				{
					Program.Log("Do Nothing command (\"{0}\") received.", m_strDoNothingSubphrase);
					ChangePositioningStance(PositioningStance.DoNothing);
				}

				else if (strLowerCaseMessage.Contains(m_strNeutralPositionSubphrase))
				{
					Program.Log("Neutral Position command (\"{0}\") received.", m_strNeutralPositionSubphrase);
					ChangePositioningStance(PositioningStance.NeutralPosition);
				}

				else if (strLowerCaseMessage.Contains(m_strStayInPlaceSubphrase))
				{
					Program.Log("Stay In Place command (\"{0}\") received.", m_strStayInPlaceSubphrase);
					ChangePositioningStance(PositioningStance.StayInPlace);
				}

				else if (strLowerCaseMessage.Contains(m_strShadowMeSubphrase))
				{
					Program.Log("Shadow Me command (\"{0}\") received.", m_strShadowMeSubphrase);
					ChangePositioningStance(PositioningStance.ShadowMe);
				}

				else if (strLowerCaseMessage.Contains(m_strForwardDashSubphrase))
				{
					Program.Log("Forward Dash command (\"{0}\") received.", m_strForwardDashSubphrase);
					ChangePositioningStance(PositioningStance.ForwardDash);
				}

				else if (strLowerCaseMessage.Contains(m_strAutoFollowSubphrase))
				{
					Program.Log("Autofollow command (\"{0}\") received.", m_strAutoFollowSubphrase);
					ChangePositioningStance(PositioningStance.AutoFollow);
				}

				/// Bot killswitch.
				else if (strLowerCaseMessage.Contains(m_strBotKillswitchSubphrase))
				{
					Program.Log("Bot killswitch command (\"{0}\") received.", m_strBotKillswitchSubphrase);
					Program.s_bContinueBot = false;
					return true;
				}

				/// Process killswitch.
				else if (strLowerCaseMessage.Contains(m_strProcessKillswitchSubphrase))
				{
					Program.Log("Process killswitch command (\"{0}\") received.", m_strProcessKillswitchSubphrase);
					Process.GetCurrentProcess().Kill();
				}

				/// Begin dropping all group buffs.
				else if (strLowerCaseMessage.Contains(m_strClearGroupMaintainedSubphrase))
				{
					m_bClearGroupMaintained = true;
				}

				/// Mentor the specified group member.
				else if (strLowerCaseMessage.Contains(m_strMentorSubphrase))
				{
					foreach (GroupMember ThisMember in EnumGroupMembers())
					{
						if (strLowerCaseMessage.Contains(ThisMember.Name.ToLower()) && ThisMember.ToActor().IsValid)
						{
							Program.RunCommand("/apply_verb {0} mentor", ThisMember.ID);
							return true;
						}
					}
				}

				else if (strLowerCaseMessage.Contains(m_strRepairSubphrase))
				{
					if (CommandingPlayerActor != null)
					{
						Actor MenderTargetActor = CommandingPlayerActor.Target();
						if (MenderTargetActor.IsValid && MenderTargetActor.Type == "NoKill NPC")
						{
							Program.RunCommand("/apply_verb {0} repair", MenderTargetActor.ID);
							Program.RunCommand("/mender_repair_all");
							return true;
						}
					}
				}

				else if (strLowerCaseMessage.StartsWith(m_strSpawnWatchSubphrase))
				{
					Program.Log("Spawn Watch command (\"{0}\") received.", m_strSpawnWatchSubphrase);
					m_bSpawnWatchTargetAnnounced = false;

					m_strSpawnWatchTarget = strTrimmedMessage.Substring(m_strSpawnWatchSubphrase.Length).ToLower().Trim();
					Program.Log("Bot will now scan for actor \"{0}\".", m_strSpawnWatchTarget);

					ChangePositioningStance(PositioningStance.SpawnWatch);
				}

				else
				{
					Program.Log("No command detected in commanding player chat.");
				}
			}

			return false;
		}

		/************************************************************************************/
		public virtual void OnZoning()
		{
			if (m_ePositioningStance == PositioningStance.ForwardDash)
				ChangePositioningStance(PositioningStance.AutoFollow);

			return;
		}

		/************************************************************************************/
		public void StopCheckingBuffs()
		{
			m_bCheckBuffsNow = false;
			m_LastCheckBuffsTime = DateTime.Now;
			Program.Log("Finished checking buffs.");
			return;
		}

		/************************************************************************************/
		/// <summary>
		/// Each ordered element in the passed array is the next higher level ability.
		/// </summary>
		/// <param name="astrAbilityNames">List of every spell that shares the behavior and recast timer,
		/// presorted from lowest level to highest.</param>
		public int SelectHighestAbilityID(params string[] astrAbilityNames)
		{
			int iBestSpellIndex = -1;

			/// Grab the highest level ability from this group.
			/// Technically you don't even need a loop for this, just pick the last item in the array.
			for (int iIndex = 0; iIndex < astrAbilityNames.Length; iIndex++)
			{
				string strThisAbility = astrAbilityNames[iIndex];
				if (m_KnowledgeBookNameToIndexMap.ContainsKey(strThisAbility))
					iBestSpellIndex = m_KnowledgeBookNameToIndexMap[strThisAbility];
			}

			/// Now associate every ability in the list with the ID of the highest-level version of it.
			for (int iIndex = 0; iIndex < astrAbilityNames.Length; iIndex++)
			{
				string strThisAbility = astrAbilityNames[iIndex];
				if (!m_KnowledgeBookCategoryDictionary.ContainsKey(strThisAbility))
					m_KnowledgeBookCategoryDictionary.Add(strThisAbility, iBestSpellIndex);
			}

			return iBestSpellIndex;
		}

		/************************************************************************************/
		/// <summary>
		/// Casts a hostile action.
		/// </summary>
		/// <param name="iAbilityID"></param>
		/// <returns></returns>
		public bool CastAbility(int iAbilityID)
		{
			if (iAbilityID < 1)
				return false;

			Ability ThisAbility = Me.Ability(iAbilityID);

			/// We won't muck around with spell queuing and add needless complexity;
			/// the latency between frames is usually smaller than the smallest recovery times (0.25 sec) anyway.
			if (!ThisAbility.IsReady)
				return false;

			if (ThisAbility.IsQueued)
				return true;

			/// Disqualify by power cost.
			if (Me.Power < ThisAbility.PowerCost)
			{
				Program.Log("Not enough power to cast {0}!", ThisAbility.Name);
				return false;
			}

			/// Disqualify by range.
			Actor MyTargetActor = MeActor.Target();
			if (MyTargetActor.IsValid)
			{
				double fDistance = GetActorDistance3D(MeActor, MyTargetActor);
				if (fDistance < ThisAbility.MinRange || ThisAbility.MaxRange < fDistance)
				{
					Program.Log("Unable to cast {0} because {1} is out of range ({2}-{3} needed, {4:0.000} actual)",
						ThisAbility.Name, MyTargetActor.Name, ThisAbility.MinRange, ThisAbility.MaxRange, fDistance);
					return false;
				}
			}

			Program.Log("Casting {0}...", ThisAbility.Name);
			if (ThisAbility.Use())
				return true;

			return false;
		}

		/************************************************************************************/
		public bool CastBlueOffensiveAbility(int iAbilityID, int iMinimumVictimCheckCount)
		{
			if (!m_bUseBlueAEs || iAbilityID < 1)
				return false;

			Ability ThisAbility = Me.Ability(iAbilityID);

			/// We won't muck around with spell queuing and add needless complexity;
			/// the latency between frames is usually smaller than the smallest recovery times (0.25 sec) anyway.
			if (!ThisAbility.IsReady)
				return false;

			if (ThisAbility.IsQueued)
				return true;

			int iValidVictimCount = 0;
			if (m_DetectedAbilityTargetCountCache.ContainsKey(iAbilityID))
				iValidVictimCount = m_DetectedAbilityTargetCountCache[iAbilityID];
			else
			{
				foreach (Actor ThisActor in EnumCustomActors("byDist", ThisAbility.EffectRadius.ToString(), "npc"))
				{
					if (ThisActor.Type != "NoKill NPC" && !ThisActor.IsDead)
						iValidVictimCount++;
				}

				m_DetectedAbilityTargetCountCache.Add(iAbilityID, iValidVictimCount);
			}

			/// Check that the minimum number of potential victims is within the blast radius before proceeding.
			if (iValidVictimCount < iMinimumVictimCheckCount)
				return false;

			if (Me.Power < ThisAbility.PowerCost)
			{
				Program.Log("Not enough power to cast {0}!", ThisAbility.Name);
				return false;
			}

			Program.Log("Casting {0} (as PBAE against {1} possible targets within {2:0}m radius)...", ThisAbility.Name, iValidVictimCount, ThisAbility.EffectRadius);
			if (ThisAbility.Use())
				return true;

			return false;
		}

		/************************************************************************************/
		/// <summary>
		/// I don't know the exact range mechanics behind green AE's, so this is some fudge work.
		/// </summary>
		public bool CastGreenOffensiveAbility(int iAbilityID, int iMinimumVictimCheckCount)
		{
			if (!m_bUseGreenAEs || iAbilityID < 1 || m_OffensiveTargetActor == null)
				return false;

			Ability ThisAbility = Me.Ability(iAbilityID);

			/// We won't muck around with spell queuing and add needless complexity;
			/// the latency between frames is usually smaller than the smallest recovery times (0.25 sec) anyway.
			if (!ThisAbility.IsReady)
				return false;

			if (ThisAbility.IsQueued)
				return true;

			int iValidVictimCount = 0;
			if (m_DetectedAbilityTargetCountCache.ContainsKey(iAbilityID))
				iValidVictimCount = m_DetectedAbilityTargetCountCache[iAbilityID];
			else
			{
				foreach (Actor ThisActor in EnumCustomActors("byDist", ThisAbility.MaxRange.ToString(), "npc"))
				{
					if (ThisActor.Type != "NoKill NPC" && !ThisActor.IsDead && m_OffensiveTargetActor.IsInSameEncounter(ThisActor.ID))
						iValidVictimCount++;
				}

				m_DetectedAbilityTargetCountCache.Add(iAbilityID, iValidVictimCount);
			}

			/// Check that the minimum number of potential victims is within the blast radius before proceeding.
			if (iValidVictimCount < iMinimumVictimCheckCount)
				return false;

			if (Me.Power < ThisAbility.PowerCost)
			{
				Program.Log("Not enough power to cast {0}!", ThisAbility.Name);
				return false;
			}

			Program.Log("Casting {0} (as encounter AE against {1} possible targets within {2:0}m radius)...", ThisAbility.Name, iValidVictimCount, ThisAbility.MaxRange);
			if (ThisAbility.Use())
				return true;

			return false;
		}

		/************************************************************************************/
		/// <summary>
		/// Riskier (possibly slower?) version that uses the command to do the cast.
		/// Preferred for all beneficial casts.
		/// </summary>
		public bool CastAbility(int iAbilityID, string strPlayerTarget, bool bMustBeAlive)
		{
			if (iAbilityID < 1)
				return false;

			Ability ThisAbility = Me.Ability(iAbilityID);

			/// We won't muck around with spell queuing and add needless complexity;
			/// the latency between frames is usually smaller than the smallest recovery times (0.25 sec) anyway.
			if (!ThisAbility.IsReady)
				return false;

			if (ThisAbility.IsQueued)
				return true;

			Actor SpellTargetActor = null;
			if (m_FriendDictionary.ContainsKey(strPlayerTarget))
				SpellTargetActor = m_FriendDictionary[strPlayerTarget].ToActor();
			else if (strPlayerTarget == Me.Name)
				SpellTargetActor = MeActor;
			else
				SpellTargetActor = Program.s_Extension.Actor(strPlayerTarget);

			if (!SpellTargetActor.IsValid)
			{
				Program.Log("Target actor {0} not valid for CastAbility().", strPlayerTarget);
				return false;
			}

			if (bMustBeAlive && SpellTargetActor.IsDead)
				return false;

			double fDistance = GetActorDistance3D(MeActor, SpellTargetActor);
			if (fDistance > ThisAbility.Range)
			{
				Program.Log("Unable to cast {0} because {1} is out of range ({2} needed, {3:0.000} actual)",
					ThisAbility.Name, SpellTargetActor.Name, ThisAbility.Range, fDistance);
				return false;
			}

			if (Me.Power < ThisAbility.PowerCost)
			{
				Program.Log("Not enough power to cast {0} on {1}!", ThisAbility.Name, SpellTargetActor.Name);
				return false;
			}

			//Program.Log("TARGET TYPE: " + ThisAbility.TargetType.ToString());

			Program.Log("Casting {0} on {1}...", ThisAbility.Name, strPlayerTarget);
			Program.RunCommand("/useabilityonplayer " + strPlayerTarget + " " + ThisAbility.Name);
			return true;
		}

		/************************************************************************************/
		/// <summary>
		/// Casts the HO starter if the wheel isn't up.
		/// </summary>
		public bool CastHOStarter()
		{
			return (m_bSpamHeroicOpportunity && (Me.IsHated && MeActor.InCombatMode) && !Program.EQ2.HOWindowActive && CastAbility(m_iHOStarterAbiltyID, Me.Name, true));
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		/// <param name="aiMezAbilityIDs">A list of mez spells to choose from, in order of decreasing preference.</param>
		/// <returns></returns>
		public bool CastNextMez(params int[] aiMezAbilityIDs)
		{
			/// This action is only intended for combat, where a primary target has been already selected.
			if (!m_bMezAdds || m_OffensiveTargetActor == null)
				return false;

			float fHighestRangeAlreadyScanned = 0;

			foreach (int iThisAbilityID in aiMezAbilityIDs)
			{
				if (!IsAbilityReady(iThisAbilityID))
					continue;

				float fThisAbilityRange = Me.Ability(iThisAbilityID).Range;

				/// Avoid scanning subsets of a radius we already scanned in a prior iteration.
				if (fThisAbilityRange < fHighestRangeAlreadyScanned)
					continue;

				foreach (Actor ThisActor in EnumCustomActors("byDist", fThisAbilityRange.ToString(), "npc"))
				{
					if (!ThisActor.IsDead &&
						!ThisActor.IsEpic && /// Mass-mezzing epics is just silly.
						ThisActor.CanTurn &&
						ThisActor.ID != m_OffensiveTargetActor.ID && /// It can't be our current burn mob.
						ThisActor.Type != "NoKill NPC" &&
						ThisActor.Target().IsValid &&
						ThisActor.Target().Type == "PC") /// It has to be targetting a player; an indicator of aggro.
					{
						/// If we found a mez target but are still in combat, withdraw for now.
						if (WithdrawCombatFromTarget(ThisActor))
						{
							Program.Log("Mez target found but first we need to withdraw from combat.");
							return true;
						}

						Program.Log("Mez target found: \"{0}\"", ThisActor.Name);

						/// Not generally our policy to do more than one server command in a frame but we make an exception here.
						if (ThisActor.DoTarget() && CastAbility(iThisAbilityID))
							return true;
					}
				}

				fHighestRangeAlreadyScanned = fThisAbilityRange;
			}

			return false;
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		public bool IsAbilityMaintained(int iAbilityID)
		{
			if (iAbilityID < 1)
				return false;

			string strAbilityName = m_KnowledgeBookIndexToNameMap[iAbilityID];
			if (m_MaintainedNameToIndexMap.ContainsKey(strAbilityName))
				return true;

			return false;
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		public bool IsBeneficialEffectPresent(int iAbilityID)
		{
			if (iAbilityID < 1)
				return false;

			string strAbilityName = m_KnowledgeBookIndexToNameMap[iAbilityID];
			if (m_BeneficialEffectNameToIndexMap.ContainsKey(strAbilityName))
				return true;

			return false;
		}

		/************************************************************************************/
		public bool IsBeneficialEffectPresent(string strName)
		{
			return m_BeneficialEffectNameToIndexMap.ContainsKey(strName);
		}

		/************************************************************************************/
		/// <summary>
		/// Don't use this inside other PlayerController functions, there'd be too much dummy-check redundancy.
		/// </summary>
		public bool IsAbilityReady(int iAbilityID)
		{
			if (iAbilityID < 1)
				return false;

			Ability ThisAbility = Me.Ability(iAbilityID);

			/// IsReady is false for available CA's that require stealth.
			//return (ThisAbility.TimeUntilReady == 0.0);
			return ThisAbility.IsReady;
		}

		/************************************************************************************/
		/// <summary>
		/// If a maintained ability is active but it's a lower-tier version of something you have a later version of,
		/// then this function will cancel it.
		/// </summary>
		/// <param name="iAbilityID"></param>
		/// <param name="bAnyVersion">true if any version of the spell should be cancelled, false if only inferior ones should be cancelled</param>
		/// <returns>true if a maintained spell was actually found and cancelled.</returns>
		public bool CancelAbility(int iAbilityID, bool bAnyVersion)
		{
			if (iAbilityID < 1)
				return false;

			string strAbilityName = m_KnowledgeBookIndexToNameMap[iAbilityID];

			int iCancelCount = 0;

			foreach (Maintained ThisMaintained in EnumMaintained())
			{
				string strMaintainedName = ThisMaintained.Name;

				if (m_KnowledgeBookCategoryDictionary.ContainsKey(strMaintainedName) && m_KnowledgeBookCategoryDictionary[strMaintainedName] == iAbilityID)
				{
					if (bAnyVersion || strAbilityName != strMaintainedName)
					{
						Program.Log("Cancelling {0} from {1}...", strMaintainedName, ThisMaintained.Target().Name);
						ThisMaintained.Cancel();
						iCancelCount++;
					}
				}
			}

			return (iCancelCount > 0);
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		/// <param name="iAbilityID"></param>
		/// <param name="astrRecipients"></param>
		/// <returns>true if a buff was cast or cancelled even one single time.</returns>
		public bool CheckSingleTargetBuffs(int iAbilityID, List<string> astrRecipients, bool bGroupTargetable, bool bRaidTargetable)
		{
			if (iAbilityID < 0)
				return false;

			/// This is a common mistake I make, initializing string lists as null instead of an allocated instance.
			if (astrRecipients == null)
			{
				Program.Log("BUG: CheckSingleTargetBuffs() called with null list parameter!");
				return false;
			}

			bool bAnyActionTaken = false;

			/// Eliminate inferior versions.
			if (CancelAbility(iAbilityID, false))
				bAnyActionTaken = true;

			string strAbilityName = m_KnowledgeBookIndexToNameMap[iAbilityID];

			/// Start the list with everyone who *should* have the buff.
			SetCollection<string> NeedyTargetSet = new SetCollection<string>();
			foreach (string strThisTarget in astrRecipients)
			{
				if (!string.IsNullOrEmpty(strThisTarget))
					NeedyTargetSet.Add(strThisTarget);
			}

			foreach (Maintained ThisMaintained in EnumMaintained())
			{
				if (ThisMaintained.Name == strAbilityName)
				{
					/// Either from a mythical weapon or AA, this single-target buff might be converted to a group/raid buff,
					/// which in current experience there will only be one of in the maintained list.
					/// We can skip a lot of errant processing if we make note of this.
					if (ThisMaintained.Type == "Group" || ThisMaintained.Type == "Raid")
						return bAnyActionTaken;

					string strTargetName = ThisMaintained.Target().Name;

					/// Remove from the list everyone who *has* the buff already.
					if (NeedyTargetSet.Contains(strTargetName))
						NeedyTargetSet.Remove(strTargetName);
					else
					{
						/// Also remove the buff from every player who should not have it.
						if (ThisMaintained.Cancel())
							bAnyActionTaken = true;
					}
				}
			}

			/// TODO: Skip each player who is dead!
			/// Otherwise we'd never get out of this unless at least one person got dropped or buffed.
			foreach (string strThisTarget in NeedyTargetSet)
			{
				/// Check raid first; it's a superset of the group.
				if (bRaidTargetable)
				{
					if (!m_FriendDictionary.ContainsKey(strThisTarget))
					{
						Program.Log("{0} wasn't cast on {1} (not found in raid).", strAbilityName, strThisTarget);
						continue;
					}
				}

				else if (bGroupTargetable)
				{
					if (!m_GroupMemberDictionary.ContainsKey(strThisTarget))
					{
						Program.Log("{0} wasn't cast on {1} (not found in group).", strAbilityName, strThisTarget);
						continue;
					}
				}

				if (CastAbility(iAbilityID, strThisTarget, true))
					bAnyActionTaken = true;
			}

			return bAnyActionTaken;
		}

		/************************************************************************************/
		public bool CheckSingleTargetBuffs(int iAbilityID, string strRecipient, bool bGroupBuff, bool bRaidBuff)
		{
			List<string> astrSingleTargetList = new List<string>();
			astrSingleTargetList.Add(strRecipient);
			return CheckSingleTargetBuffs(iAbilityID, astrSingleTargetList, bGroupBuff, bRaidBuff);
		}

		/************************************************************************************/
		public bool CheckToggleBuff(int iAbilityID, bool bOn)
		{
			CancelAbility(iAbilityID, !bOn);

			/// Target myself to remove ambiguity.
			if (bOn && !IsAbilityMaintained(iAbilityID) && CastAbility(iAbilityID, Me.Name, true))
				return true;

			return false;
		}

		/************************************************************************************/
		public void ChangePositioningStance(PositioningStance eNewStance)
		{
			Actor CommandingPlayerActor = GetNonPetActor(m_strCommandingPlayer);

			/// Deactivate the existing stance.
			if (m_ePositioningStance == PositioningStance.ShadowMe || m_ePositioningStance == PositioningStance.StayInPlace || m_ePositioningStance == PositioningStance.ForwardDash)
			{
				LavishScriptAPI.LavishScript.ExecuteCommand("press -release W");
			}

			if (eNewStance == PositioningStance.DoNothing)
			{
				m_ePositioningStance = PositioningStance.DoNothing;
			}
			else if (eNewStance == PositioningStance.NeutralPosition)
			{
				m_ePositioningStance = PositioningStance.NeutralPosition;
			}
			else if (eNewStance == PositioningStance.StayInPlace)
			{
				if (CommandingPlayerActor != null)
				{
					m_ePositioningStance = PositioningStance.StayInPlace;
					m_ptStayLocation = new Point3D(CommandingPlayerActor);
					CheckPositioningStance();
				}
			}
			else if (eNewStance == PositioningStance.ShadowMe)
			{
				if (CommandingPlayerActor != null)
				{
					m_ePositioningStance = PositioningStance.ShadowMe;
					CheckPositioningStance();
				}
			}
			else if (eNewStance == PositioningStance.ForwardDash)
			{
				m_ePositioningStance = PositioningStance.ForwardDash;
				CheckPositioningStance();
			}
			else if (eNewStance == PositioningStance.AutoFollow)
			{
				m_ePositioningStance = PositioningStance.AutoFollow;
				CheckPositioningStance();
			}
			else if (eNewStance == PositioningStance.SpawnWatch)
			{
				m_ePositioningStance = PositioningStance.SpawnWatch;
			}


			return;
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		/// <returns>true if an autofollow command was sent.</returns>
		public bool CheckPositioningStance()
		{
			if (MeActor.IsDead)
				return false;

			/// Traditional client autofollow.
			if (m_ePositioningStance == PositioningStance.AutoFollow)
			{
				/// We'll deal with this after LU51.
				if (MeActor.IsClimbing || string.IsNullOrEmpty(m_strAutoFollowTarget))
					return false;

				/// Make sure the autofollow target is in our group.
				if (!m_GroupMemberDictionary.ContainsKey(m_strAutoFollowTarget))
				{
					Program.Log("Can't autofollow on {0} (not found in group).", m_strAutoFollowTarget);
					return false;
				}

				Actor AutoFollowActor = m_GroupMemberDictionary[m_strAutoFollowTarget].ToActor();
				if (!AutoFollowActor.IsValid || AutoFollowActor.IsDead)
				{
					Program.Log("Can't autofollow on {0} (player is dead or invalid).", m_strAutoFollowTarget);
					return false;
				}

				/// Reapply autofollow.
				/// We won't make it an absolute requirement for Check Buffs completion.
				if (MeActor.WhoFollowing != m_strAutoFollowTarget)
				{
					/// If we're too far away, the client will put up an error message.
					/// Therefore we have to filter out this failure condition.
					if (GetActorDistance3D(MeActor, AutoFollowActor) < 30)
					{
						if (AutoFollowActor.DoFace())
						{
							Program.RunCommand("/follow {0}", m_strAutoFollowTarget);
							return true;
						}
					}
				}

				/// The most annoying shit about autofollow is when we're in combat but not on a target.
				/// They run their own fucking directions.
				else if ((MeActor.InCombatMode || Me.IsHated) && m_iOffensiveTargetID == -1)
				{
					if (AutoFollowActor.DoFace())
					{
						Program.Log("In combat without an offensive target; forcing direction toward autofollow target.");
						return false;
					}
				}
			}

			/// These stances are grouped together because both of them involve direct autofollow.
			else if (m_ePositioningStance == PositioningStance.StayInPlace || m_ePositioningStance == PositioningStance.ShadowMe)
			{
				/// Firstly, no matter where we are, stop autofollowing.
				if (!string.IsNullOrEmpty(MeActor.WhoFollowing))
				{
					Program.RunCommand("/stopfollow");
					return true;
				}

				/// For shadowing, the coordinate is updated at every iteration.
				if (m_ePositioningStance == PositioningStance.ShadowMe)
				{
					if (!m_FriendDictionary.ContainsKey(m_strCommandingPlayer))
					{
						LavishScriptAPI.LavishScript.ExecuteCommand("press -release W");
						return false;
					}

					m_ptStayLocation = new Point3D(m_FriendDictionary[m_strCommandingPlayer].ToActor());
				}

				if (!MeActor.IsClimbing && MeActor.CanTurn)
				{
					double fRange = GetActorDistance3D(MeActor, m_ptStayLocation);
					if (fRange > m_fStayInPlaceTolerance)
					{
						float fBearing = Me.HeadingTo(m_ptStayLocation.X, m_ptStayLocation.Y, m_ptStayLocation.Z);
						if (Me.Face(fBearing))
						{
							Program.Log("Moving to stay position ({0:0.000}, {1:0.000}, {2:0.000}), {3:0.000} distance away...", m_ptStayLocation.X, m_ptStayLocation.Y, m_ptStayLocation.Z, fRange);
							LavishScriptAPI.LavishScript.ExecuteCommand("press -hold W");
						}
					}
					else
					{
						//Program.Log("Settled at stay position, {0:0.000} distance away.", fRange);
						LavishScriptAPI.LavishScript.ExecuteCommand("press -release W");
					}
				}
			}

			else if (m_ePositioningStance == PositioningStance.ForwardDash)
			{
				LavishScriptAPI.LavishScript.ExecuteCommand("press -hold W");
				return false;
			}

			return false;
		}

		/************************************************************************************/
		public bool CheckRacialBuffs()
		{
			if (!m_bUseRacialBuffs)
				return false;

			if (CheckToggleBuff(m_iFeatherfallAbilityID, true))
				return true;

			return false;
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		/// <returns>true if the player was able to fully target and engage the designated opponent</returns>
		public bool EngageOffensiveTargetActor()
		{
			if (m_OffensiveTargetActor == null)
				return false;

			/// Make sure the mob is targetted before we return success.
			Actor MyTargetActor = MeActor.Target();
			if (!MyTargetActor.IsValid || MyTargetActor.ID != m_OffensiveTargetActor.ID)
			{
				/// If we can't even target it, we either got a crazy mob (which we're not prepared for in this script) or we're SOL.
				if (!m_OffensiveTargetActor.DoTarget())
					Program.Log("Unable to target mob: ({0}, {1})", m_OffensiveTargetActor.Name, m_OffensiveTargetActor.ID);

				return false;
			}

			/// Turn on auto-attack if required.
			/// End-of-combat will turn it back off automatically.
			/// I picked a larger minimum range for ranged autoattack because any closer
			/// and then it's likely the commander is just trying to position for melee.
			/// Remember too that there is an update delay with readback stats.
			double fDistance = GetActorDistance3D(MeActor, m_OffensiveTargetActor);
			if (m_bUseRanged && (fDistance > 10.0) && !Me.RangedAutoAttackOn)
			{
				/// Turn on ranged auto-attack instead if there is too much distance to the target.
				Program.RunCommand("/auto 2");
				m_OffensiveTargetActor.DoFace();
				return false;
			}
			else if (m_bAutoAttack && !Me.AutoAttackOn)
			{
				Program.RunCommand("/auto 1");
				m_OffensiveTargetActor.DoFace();
				return false;
			}

			/// Make sure the pet is on the right target before we return success.
			Actor PetActor = Me.Pet();
			if (Me.IsHated && PetActor.IsValid && PetActor.CanTurn)
			{
				Actor PetTargetActor = PetActor.Target();
				if (!PetTargetActor.IsValid || (PetTargetActor.ID != m_OffensiveTargetActor.ID) || !PetActor.InCombatMode)
				{
					Program.Log("Sending in pet for attack!");
					Program.RunCommand("/pet attack");
					return false;
				}
			}

			return true;
		}

		/************************************************************************************/
		/// <summary>
		/// Ceases any offensive activity against the given target actor without completely
		/// disengaging from the current encounter altogether, and in a way to prevent accidental
		/// engagement of a different target. This is vital for mezzing, and returns true
		/// if any server contact was made (implying that we'll need to call this again on the
		/// same actor later).
		/// </summary>
		/// <returns></returns>
		public bool WithdrawCombatFromTarget(Actor TargetActor)
		{
			Actor MyTargetActor = MeActor.Target();
			if (MyTargetActor.IsValid && MyTargetActor.ID == TargetActor.ID)
			{
				/// Turn it off just in case.
				if (Me.AutoAttackOn || Me.RangedAutoAttackOn)
				{
					Program.RunCommand("/auto 0");
					return true;
				}

				/// If an enemy is targetted, target nothing instead.
				//Program.RunCommand("/target_none");
				return true;
			}

			Actor PetActor = Me.Pet();
			if (PetActor.IsValid)
			{
				Actor PetTargetActor = PetActor.Target();
				if (PetTargetActor.IsValid && PetTargetActor.InCombatMode && PetTargetActor.ID == TargetActor.ID)
				{
					Program.RunCommand("/pet backoff");
					return true;
				}
			}

			return false;
		}

		/************************************************************************************/
		public bool WithdrawFromCombat()
		{
			m_iOffensiveTargetID = -1;

			if (!MeActor.IsDead)
			{
				/// Turn it off just in case.
				if (Me.AutoAttackOn || Me.RangedAutoAttackOn)
				{
					Program.RunCommand("/auto 0");
					return true;
				}

				/// Pull the pet back just in case.
				Actor PetActor = Me.Pet();
				if (PetActor.IsValid && PetActor.InCombatMode)
				{
					Program.RunCommand("/pet backoff");
					return true;
				}

				/// If an enemy is targetted, target nothing instead.
				Actor TargetActor = MeActor.Target();
				if (TargetActor.IsValid && TargetActor.Type == "NPC")
				{
					Program.RunCommand("/target_none");
					return true;
				}
			}

			return false;
		}

		/************************************************************************************/
		public bool GetOffensiveTargetActor()
		{
			if (m_iOffensiveTargetID == -1)
				return false;

			bool bEveryoneDead = true;
			foreach (GroupMember ThisMember in m_FriendDictionary.Values)
			{
				Actor ThisActor = ThisMember.ToActor();
				if (ThisActor.IsValid && !ThisActor.IsDead)
				{
					bEveryoneDead = false;
					break;
				}
			}

			/// If everyone in the party is dead, the fight is completely over.
			if (bEveryoneDead)
			{
				m_iOffensiveTargetID = -1;
				return false;
			}

			Actor OffensiveTargetActor = Program.s_Extension.Actor(m_iOffensiveTargetID);

			if (OffensiveTargetActor == null ||
				!OffensiveTargetActor.IsValid ||
				OffensiveTargetActor.IsDead ||
				OffensiveTargetActor.IsLocked ||
				OffensiveTargetActor.Type == "NoKill NPC")
			{
				if (OffensiveTargetActor == null)
					Program.Log("Offensive target is null.");
				else
					Program.Log("Offensive target ({0}, {1}) is dead, locked, or invalid.", OffensiveTargetActor.Name, OffensiveTargetActor.ID);

				WithdrawFromCombat();
				return false;
			}

			m_OffensiveTargetActor = OffensiveTargetActor;

			/// Decide if I have aggro. In the future, use the ratio.
			Actor AggroWhoreActor = m_OffensiveTargetActor.Target();
			m_bIHaveAggro = AggroWhoreActor.IsValid && (AggroWhoreActor.ID == MeActor.ID);

			return true;
		}

		/************************************************************************************/
		/// <summary>
		/// It's difficult for healer logic when Character and GroupMember separately hold 
		/// vital information depending if it's the bot player or not.
		/// This unites the two for clean logic.
		/// </summary>
		public class VitalStatus
		{
			public string m_strName = string.Empty;
			public bool m_bIsDead = false;
			public int m_iTrauma = 0;
			public int m_iArcane = 0;
			public int m_iNoxious = 0;
			public int m_iElemental = 0;
			public int m_iCursed = 0;
			public int m_iCurrentHealth = 0;
			public int m_iMaximumHealth = 0;
			public int m_iCurrentPower = 0;
			public int m_iMaximumPower = 0;
			public Actor m_Actor = null;

			public VitalStatus(Character SourceInfo)
			{
				m_Actor = SourceInfo.ToActor();
				m_strName = SourceInfo.Name;
				m_bIsDead = m_Actor.IsDead;
				m_iTrauma = SourceInfo.Trauma;
				m_iArcane = SourceInfo.Arcane;
				m_iNoxious = SourceInfo.Noxious;
				m_iElemental = SourceInfo.Elemental;
				m_iCursed = SourceInfo.Cursed ? 1 : 0; /// Totally fudged and possibly inaccurate in some situations.
				m_iCurrentHealth = SourceInfo.Health;
				m_iMaximumHealth = SourceInfo.MaxHealth;
				m_iCurrentPower = SourceInfo.Power;
				m_iMaximumPower = SourceInfo.MaxPower;
				return;
			}

			public VitalStatus(GroupMember SourceInfo)
			{
				m_Actor = SourceInfo.ToActor();
				m_strName = SourceInfo.Name;
				m_bIsDead = m_Actor.IsDead;
				m_iTrauma = SourceInfo.Trauma;
				m_iArcane = SourceInfo.Arcane;
				m_iNoxious = SourceInfo.Noxious;
				m_iElemental = SourceInfo.Elemental;
				m_iCursed = SourceInfo.Cursed;
				m_iCurrentHealth = SourceInfo.HitPoints;
				m_iMaximumHealth = SourceInfo.MaxHitPoints;
				m_iCurrentPower = SourceInfo.Power;
				m_iMaximumPower = SourceInfo.MaxPower;
				return;
			}

			public bool HasAnyCurableAffliction
			{
				get
				{
					/// Don't rely on IsAfflicted, it doesn't always work.
					return (m_iTrauma > 0 || m_iArcane > 0 || m_iNoxious > 0 || m_iElemental > 0);
				}
			}

			public int HealthDeficit
			{
				get
				{
					return (m_iMaximumHealth - m_iCurrentHealth);
				}
			}
		}

		/************************************************************************************/
		public IEnumerable<VitalStatus> EnumVitalStatuses(bool bIncludeMainTank)
		{
			if (bIncludeMainTank && m_FriendDictionary.ContainsKey(m_strMainTank))
			{
				GroupMember ThisMember = m_FriendDictionary[m_strMainTank];
				if (ThisMember.ToActor().IsValid)
					yield return new VitalStatus(ThisMember);
			}

			yield return new VitalStatus(Me);

			foreach (GroupMember ThisMember in m_GroupMemberDictionary.Values)
			{
				/// The presence of our character in the group member dictionary 
				/// is a convenience for some areas of this program,
				/// but is superfluous and incorrect in this loop.
				if ((ThisMember.Name != Me.Name) && (ThisMember.Name != m_strMainTank) && ThisMember.ToActor().IsValid)
					yield return new VitalStatus(ThisMember);
			}
		}

		/************************************************************************************/
		public bool AreTempOffensiveBuffsAdvised()
		{
			if (m_OffensiveTargetActor == null)
				return false;
			else if (m_OffensiveTargetActor.IsNamed)
				return true;
			else if (m_OffensiveTargetActor.IsHeroic)
				return (m_OffensiveTargetActor.Health > 90);
			else if (m_OffensiveTargetActor.IsEpic)
				return (m_OffensiveTargetActor.Health > 70);
			else
				return false;
		}
	}
}
