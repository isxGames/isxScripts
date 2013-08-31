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
using EQ2ParseEngine;
using EQ2SuiteLib;

namespace EQ2GlassCannon
{
	public partial class PlayerController
	{
		protected const string STR_NO_KILL_NPC = "NoKill NPC";
		protected const string STR_NAMED_NPC = "NamedNPC";
		protected const string STR_FREE_FOR_ALL = "Free For All";
		protected const string STR_NEED_BEFORE_GREED = "Need Before Greed";

		protected uint m_uiLoreAndLegendAbilityID = 0;
		protected uint m_uiHOStarterAbiltyID = 0;
		protected uint m_uiFeatherfallAbilityID = 0;
		protected uint m_uiHalfElfMitigationDebuffAbilityID = 0;
		protected uint m_uiFurySalveHealAbilityID = 0;

		protected uint m_uiCollectingAbilityID = 0;
		protected uint m_uiGatheringAbilityID = 0;
		protected uint m_uiMiningAbilityID = 0;
		protected uint m_uiForestingAbilityID = 0;
		protected uint m_uiTrappingAbilityID = 0;
		protected uint m_uiFishingAbilityID = 0;

		/************************************************************************************/
		protected enum PositioningStance
		{
			DoNothing = 0,
			NeutralPosition,
			AutoFollow,
			CustomAutoFollow,
			StayInPlace,
			ForwardDash,
			ChatWatch,
			SpawnWatch,
			DespawnWatch,
		}

		/************************************************************************************/
		protected class CustomChatTrigger
		{
			public SetCollection<string> m_SourcePlayerSet = new SetCollection<string>();
			public string m_strSubstring = string.Empty;
			public List<string> m_astrCommands = new List<string>();
			public bool Match(string strPlayerName, string strText)
			{
				if (!strText.ToLower().Contains(m_strSubstring))
					return false;

				/// This means anyone can do the trigger.
				if (m_SourcePlayerSet.Count == 0)
					return true;

				return m_SourcePlayerSet.Contains(strPlayerName);
			}
		}

		/************************************************************************************/
		protected class CustomRegenItem
		{
			public string m_strName = string.Empty;
			public bool m_bMustBeEquipped = false;
			public bool m_bMustNotBeEquipped = false;
			public bool m_bMustTargetEnemy = false;
			public bool m_bMustTargetFriend = false;
			public double m_fMinimumHealthRatioRequired = 0;
			public double m_fMaximumHealthRatioRequired = 1;
			public double m_fMinimumPowerRatioRequired = 0;
			public double m_fMaximumPowerRatioRequired = 1;

			public bool IsValid()
			{
				if (string.IsNullOrEmpty(m_strName))
					return false;

				if (m_bMustBeEquipped && m_bMustNotBeEquipped)
					return false;

				if (m_bMustTargetEnemy && m_bMustTargetFriend)
					return false;

				if (m_fMinimumHealthRatioRequired > m_fMaximumHealthRatioRequired)
					return false;

				if (m_fMinimumPowerRatioRequired > m_fMaximumPowerRatioRequired)
					return false;

				return true;
			}

			public bool ShouldUse(VitalStatus ThisStatus)
			{
				double fHealthRatio = ThisStatus.HealthRatio;
				if (fHealthRatio < m_fMinimumHealthRatioRequired || m_fMaximumHealthRatioRequired < fHealthRatio)
					return false;

				double fPowerRatio = ThisStatus.PowerRatio;
				if (fPowerRatio < m_fMinimumPowerRatioRequired || m_fMaximumPowerRatioRequired < fPowerRatio)
					return false;

				return true;
			}
		}

		/************************************************************************************/
		public class PlayerRequest
		{
			public DateTime m_Timestamp = PlayerController.CurrentCycleTimestamp;

			public TimeSpan Age
			{
				get
				{
					return (PlayerController.CurrentCycleTimestamp - m_Timestamp);
				}
			}

			public string m_strName = string.Empty;
			public PlayerRequest(string strName)
			{
				m_strName = strName;
				return;
			}
		}

		/************************************************************************************/
		protected bool m_bContinueBot = true;
		protected int m_iLastAbilityCount = 0;
		protected Point3D m_ptMyLastLocation = new Point3D();
		protected bool m_bCheckBuffsNow = true;
		protected bool m_bIHaveAggro = false;
		protected bool m_bIHaveBadPing = false;
		protected bool m_bClearGroupMaintained = false;
		protected bool m_bLastShadowTargetSamplingWasNearby = false;
		protected DateTime m_LastCheckBuffsTime = DateTime.Now;
		protected int m_iOffensiveTargetID = -1;
		protected int m_iLastOffensiveTargetID = -1;
		protected Actor m_OffensiveTargetActor = null;
		protected Dictionary<int, Actor> m_OffensiveTargetEncounterActorDictionary = new Dictionary<int, Actor>();
		protected Point3D m_ptStayLocation = new Point3D();
		protected double m_fCurrentMovementTargetCoordinateTolerance = 0.0f;
		protected string m_strPositionalCommandingPlayer = string.Empty;
		protected string m_strCurrentMainTank = string.Empty;
		protected string m_strChatWatchTargetText = string.Empty;
		protected DateTime m_ChatWatchNextValidAlertTime = DateTime.Now;
		protected bool m_bSpawnWatchTargetAnnounced = false;
		protected string m_strSpawnWatchTarget = string.Empty;
		protected DateTime m_SpawnWatchDespawnStartTime = DateTime.Now;
		protected List<CustomChatTrigger> m_aCustomChatTriggerList = new List<CustomChatTrigger>();
		protected List<CustomRegenItem> m_aCustomRegenItemList = new List<CustomRegenItem>();

		protected PositioningStance m_ePositioningStance = PositioningStance.AutoFollow;

		private Dictionary<string, uint> m_KnowledgeBookNameToIDMap = new Dictionary<string, uint>();
		private Dictionary<uint, string> m_KnowledgeBookIDToNameMap = new Dictionary<uint, string>();
		protected Dictionary<string, GroupMember> m_GroupMemberDictionary = new Dictionary<string, GroupMember>();
		protected Dictionary<string, GroupMember> m_FriendDictionary = new Dictionary<string, GroupMember>();

		/// <summary>
		/// This associates all identical spells of a shared recast timer with the index of the highest level version of them.
		/// </summary>
		protected Dictionary<string, uint> m_KnowledgeBookAbilityLineDictionary = new Dictionary<string, uint>();

		/// <summary>
		/// Generally only used for combat. Prevents us from having to enumerate multiple times.
		/// </summary>
		protected Dictionary<int, Actor> m_KillableActorDictionary = new Dictionary<int, Actor>();

		/************************************************************************************/
		protected virtual void RefreshKnowledgeBook()
		{
			Program.Log("Referencing Knowledge Book...");

			while (s_bContinueBot)
			{
				m_KnowledgeBookNameToIDMap.Clear();
				m_KnowledgeBookIDToNameMap.Clear();

				Frame.Wait(true);
				try
				{
					UpdateStaticGlobals();

					if (AbilityCount == 0)
						Program.Log("NO abilities found!");
					else
					{
						m_iLastAbilityCount = 0;

						foreach (Ability ThisAbility in EnumAbilities())
						{
							/// An ability string of null means it isn't loaded from the server yet.
							if (ThisAbility.IsValid && !string.IsNullOrEmpty(ThisAbility.Name))
							{
								m_iLastAbilityCount++;

								if (m_KnowledgeBookNameToIDMap.ContainsKey(ThisAbility.Name))
								{
									Program.Log(
										"WARNING: Duplicate ability \"{0}\" found (ID {1} & {2}). This could be problematic with maintained spells.",
										ThisAbility.Name,
										ThisAbility.ID,
										m_KnowledgeBookNameToIDMap[ThisAbility.Name]);
								}
								else
									m_KnowledgeBookNameToIDMap.Add(ThisAbility.Name, ThisAbility.ID);

								m_KnowledgeBookIDToNameMap.Add(ThisAbility.ID, ThisAbility.Name);
							}
						}

						if (m_iLastAbilityCount < AbilityCount)
							Program.Log("Found {0} names of {1} abilities so far.", m_iLastAbilityCount, AbilityCount);
						else
						{
							Program.Log("All abilities found.");
							break;
						}
					}
				}
				catch
				{
					Program.Log("Exception thrown while looking up ability data.");
				}
				finally
				{
					Frame.Unlock();
				}

				/// This is black magic to force the client to reload the knowledge book.
				RunCommand("/showcombatartbook");
				Program.Log("Waiting for abilities to load from the server...");
				FrameWait(TimeSpan.FromSeconds(3.0f));
				RunCommand("/toggleknowledge");
			} /// while(s_bContinueBot)

			/// Now dump it all to a file, if so requested.
			if (s_strKnowledgeBookDumpPath != null)
			{
				try
				{
					using (CsvFileWriter OutputFile = new CsvFileWriter(s_strKnowledgeBookDumpPath, false))
					{
						for (int iIndex = 1; iIndex <= AbilityCount; iIndex++)
						{
							Ability ThisAbility = Me.Ability(iIndex);
							OutputFile.WriteNextValue(iIndex);
							OutputFile.WriteNextValue(ThisAbility.ID);
							OutputFile.WriteNextValue(ThisAbility.Tier);
							OutputFile.WriteNextValue(ThisAbility.Name);
							OutputFile.WriteLine();
						}
					}
				}
				catch
				{
					/// Not our problem. Move along!
				}
				finally
				{
					s_strKnowledgeBookDumpPath = null;
				}
			}

			/// This must be done before any call to SelectHighestAbilityID().
			m_KnowledgeBookAbilityLineDictionary.Clear();

			/// Racials.
			m_uiFeatherfallAbilityID = SelectHighestAbilityID(
				//"Mind over Matter", /// High Elves. Commented out until the devs reconcile this with the tradeskill ability of the same name.
				"Glide", /// Fae.
				"Falling Grace" /// Erudites.
				);
			m_uiHalfElfMitigationDebuffAbilityID = SelectHighestAbilityID("Piercing Stab");
			m_uiFurySalveHealAbilityID = SelectHighestAbilityID("Salve");

			/// Harvesting.
			m_uiCollectingAbilityID = SelectHighestAbilityID("Collecting");
			m_uiGatheringAbilityID = SelectHighestAbilityID("Gathering");
			m_uiMiningAbilityID = SelectHighestAbilityID("Mining");
			m_uiForestingAbilityID = SelectHighestAbilityID("Foresting");
			m_uiTrappingAbilityID = SelectHighestAbilityID("Trapping");
			m_uiFishingAbilityID = SelectHighestAbilityID("Fishing");

			return;
		}

		/************************************************************************************/
		/// <summary>
		/// Each ordered element in the passed array is the next higher level (or next higher preferred) ability.
		/// </summary>
		/// <param name="astrAbilityNames">List of every spell that shares the behavior and recast timer,
		/// presorted by the caller from lowest level to highest.</param>
		protected uint SelectHighestAbilityID(params string[] astrAbilityNames)
		{
			uint uiBestSpellID = 0;

			/// Grab the highest level ability from this group.
			for (int iIndex = astrAbilityNames.Length - 1; iIndex >= 0; iIndex--)
			{
				string strThisAbility = astrAbilityNames[iIndex];
				if (m_KnowledgeBookNameToIDMap.ContainsKey(strThisAbility))
				{
					uiBestSpellID = m_KnowledgeBookNameToIDMap[strThisAbility];
					break;
				}
			}

			/// Now associate every ability in the list (that actually exists) with the ID of the highest-level version of it.
			/// This is important so that older versions of maintained buffs can be efficiently cancelled in favor of the highest versions of them.
			for (int iIndex = 0; iIndex < astrAbilityNames.Length; iIndex++)
			{
				string strThisAbility = astrAbilityNames[iIndex];
				if (m_KnowledgeBookNameToIDMap.ContainsKey(strThisAbility) && !m_KnowledgeBookAbilityLineDictionary.ContainsKey(strThisAbility))
					m_KnowledgeBookAbilityLineDictionary.Add(strThisAbility, uiBestSpellID);
			}

			return uiBestSpellID;
		}

		/************************************************************************************/
		private static readonly string[] s_astrRomanNumeralSuffixes = new string[]
		{
			"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII"
		};

		/************************************************************************************/
		protected uint SelectHighestTieredAbilityID(string strBaseAbilityName)
		{
			List<string> astrAbilityNames = new List<string>(s_astrRomanNumeralSuffixes.Length);
			for (int iIndex = 0; iIndex < s_astrRomanNumeralSuffixes.Length; iIndex++)
			{
				string strRomanNumeral = s_astrRomanNumeralSuffixes[iIndex];

				/// There is no roman numeral I for the first spell in the series.
				string strFinalAbilityName = (iIndex > 0) ? string.Format("{0} {1}", strBaseAbilityName, strRomanNumeral) : strBaseAbilityName;
				astrAbilityNames.Add(strFinalAbilityName);
			}

			/// Now check for overrides.
			for (int iIndex = 0; iIndex < astrAbilityNames.Count; iIndex++)
			{
				int iOverrideLocation = m_astrTieredAbilityOverrides.IndexOf(astrAbilityNames[iIndex]);
				if (iOverrideLocation != -1)
				{
					/// Bump this ability to the top of the priority list.
					astrAbilityNames.RemoveAt(iIndex);
					astrAbilityNames.Add(m_astrTieredAbilityOverrides[iOverrideLocation]);
					break;
				}
			}

			return SelectHighestAbilityID(astrAbilityNames.ToArray());
		}

		/************************************************************************************/
		protected uint SelectAbilityID(uint uiAbilityID)
		{
			if (m_KnowledgeBookIDToNameMap.ContainsKey(uiAbilityID))
				return uiAbilityID;
			else
				return 0;
		}

		/************************************************************************************/
		protected bool AbilityCountChanged
		{
			get
			{
				return (AbilityCount != m_iLastAbilityCount);
			}
		}

		/************************************************************************************/
		/// <summary>
		/// The base function caches certain lookup data.
		/// </summary>
		/// <returns>true if an action was taken and no further processing should occur</returns>
		protected virtual bool DoNextAction()
		{
			/// Single-target radar but without the radar screen.
			if (m_bTrackActor && CurrentCycleTimestamp >= m_NextTrackActorAttemptTime)
			{
				TrackNearestActors(1, false, m_strTrackActorSubstring);
				m_NextTrackActorAttemptTime = CurrentCycleTimestamp + m_TrackActorInterval;
			}

			if (m_ePositioningStance == PositioningStance.DoNothing)
				return true;

			/// We freshly reacquire these for every frame.
			m_OffensiveTargetActor = null;
			m_bIHaveAggro = false;

			/// Decide if our ping is too high to function properly.
			/// If ping is given as an invalid value, then we consider that a bad ping as well.
			/// eq2ui_mainhud_connectionstats.xml
			EQ2UIElement PingGameData = Me.GetGameData("General.Ping");
			if (PingGameData.IsValid)
			{
				try
				{
					string strPing = PingGameData.ShortLabel.Replace(",", string.Empty);

					int iThisPing = -1;
					m_bIHaveBadPing = (!int.TryParse(strPing, out iThisPing) || (iThisPing >= m_iBadPingThreshold));
					if (m_bIHaveBadPing)
						Program.Log("Bad ping detected ({0}ms).", iThisPing);
				}
				catch
				{
					Program.Log("EXCEPTION THROWN.");
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

				Program.Log("All maintained group effects cancelled.");
				m_bClearGroupMaintained = false;
			}

			m_GroupMemberDictionary.Clear();
			foreach (GroupMember ThisMember in EnumGroupMembers())
				m_GroupMemberDictionary.Add(ThisMember.Name, ThisMember);

			m_FriendDictionary.Clear();
			foreach (GroupMember ThisMember in EnumRaidMembers())
				m_FriendDictionary.Add(ThisMember.Name, ThisMember);

			/// Build the maintained spell dictionaries.
			m_MaintainedNameToIndexMap.Clear();
			m_MaintainedTargetNameDictionary.Clear();
			for (int iIndex = 1; iIndex <= Me.CountMaintained; iIndex++)
			{
				Maintained ThisMaintained = Me.Maintained(iIndex);

				MaintainedTargetIDKey NewKey = new MaintainedTargetIDKey(ThisMaintained.Name, ThisMaintained.Target().ID);
				if (m_MaintainedTargetNameDictionary.ContainsKey(NewKey))
					Program.Log("Duplicate {0} on target {1}.", ThisMaintained.Name, ThisMaintained.Target().Name);
				else
					m_MaintainedTargetNameDictionary.Add(NewKey, ThisMaintained);

				string strName = ThisMaintained.Name;
				if (strName != null)
				{
					if (!m_MaintainedNameToIndexMap.ContainsKey(strName))
						m_MaintainedNameToIndexMap.Add(strName, iIndex);
				}
			}

			/// Build the beneficial effect dictionary.
			/// NOTE: Can't do it in current implementation. Me.Effect() does server lookup and major bandwidth saturation.
			/*if (!Me.InitializingEffects)
			{
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
				Me.InitializeEffects();
			}*/

			m_AbilityCache.Clear();
			m_AbilityCompatibleTargetCountCache.Clear();
			m_VitalStatusCache.Clear();

			m_strCurrentMainTank = GetFirstExistingPartyMember(m_astrMainTanks, false);

			/// NOTE: Bookkeeping is done at this point. Anything after is open game.

			ClearOffensiveTargetIfWipe();

			if (CheckPositioningStance())
				return true;

			/// Decide whether now is a good time to check buffs.
			if (!m_bCheckBuffsNow)
			{
				if (CurrentCycleTimestamp > (m_LastCheckBuffsTime + TimeSpan.FromMilliseconds(m_iCheckBuffsInterval)))
				{
					Program.Log("Checking buffs now.");

					/// Only derived classes set the flag back to false.
					m_bCheckBuffsNow = true;
				}
			}

			if (AutoHarvestNearestNode() || AutoLootNearestCorpseOrChest())
				return true;

			/// Calculate how much time remains on the cast timer.
			DateTime CurrentDateTime = CurrentCycleTimestamp;
			if (CurrentDateTime > m_LastCastEndTime)
				m_CastTimeRemaining = TimeSpan.FromTicks(0);
			else
				m_CastTimeRemaining = m_LastCastEndTime - CurrentDateTime;

			if (MeActor.OnGriffin || MeActor.OnGriffon)
				return true;

			return false;
		}

		/************************************************************************************/
		protected virtual void UpdateEndOfRoundStatistics()
		{
			m_ptMyLastLocation = new Point3D(MeActor);
			m_iLastOffensiveTargetID = m_iOffensiveTargetID;
			return;
		}

		/************************************************************************************/
		protected virtual bool OnChoiceWindowAppeared(ChoiceWindow ThisWindow)
		{
			if (m_ePositioningStance == PositioningStance.DoNothing)
			{
				Program.Log("Character is in do-nothing stance; ignoring choice window.");
				return false;
			}

			Program.Log("Choice window appeared: \"{0}\".", ThisWindow.Text);

			/// Group invite window.
			if (ThisWindow.Text.Contains("has invited you to join a group"))
			{
				/// Only accept group invites from a commanding player.
				bool bIssuedByCommandingPlayer = false;
				foreach (string strThisPlayer in m_astrCommandingPlayers)
					if (!string.IsNullOrEmpty(strThisPlayer) && ThisWindow.Text.StartsWith(strThisPlayer))
					{
						bIssuedByCommandingPlayer = true;
						break;
					}

				if (bIssuedByCommandingPlayer)
				{
					Program.Log("Accepting invite from commanding player.");
					//ThisWindow.DoChoice1();
					RunCommand("/acceptinvite");
				}
				else
				{
					Program.Log("Declining invite from unauthorized player.");
					//ThisWindow.DoChoice2();
					RunCommand("/declineinvite");
				}

				return true;
			}

			/// Zone timer reset window.
			else if (ThisWindow.Text.Contains("Are you sure you want to reset your zone timer for "))
			{
				ThisWindow.DoChoice1();
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
		/// <summary>
		/// This function is not yet complete.
		/// </summary>
		protected virtual bool OnRewardWindowAppeared(RewardWindow ThisWindow)
		{
			if (m_ePositioningStance == PositioningStance.DoNothing)
			{
				Program.Log("Character is in do-nothing stance; ignoring reward window.");
				return false;
			}

			//Program.Log("Reward window appeared: \"{0}\".", ThisWindow.);

			Program.Log("Accepting reward...");
			ThisWindow.Receive();
			return true;
		}

		/************************************************************************************/
		protected virtual bool OnLootWindowAppeared(string strID, LootWindow ThisWindow)
		{
			if (m_ePositioningStance == PositioningStance.DoNothing)
			{
				Program.Log("Character is in do-nothing stance; ignoring loot window.");
				return false;
			}

			FlexStringBuilder NewBuilder = new FlexStringBuilder();
			NewBuilder.AppendLine("Loot window appeared (\"{0}\").", ThisWindow.Type);
			for (int iIndex = 1; iIndex <= ThisWindow.NumItems; iIndex++)
			{
				Item ThisItem = ThisWindow.Item(iIndex);
				AppendItemInfo(NewBuilder, iIndex, ThisItem);
			}
			Program.Log(NewBuilder.ToString());

			if (ThisWindow.Type == STR_FREE_FOR_ALL)
			{
				SetCollection<int> LootedItemSet = new SetCollection<int>();

				/// Items that we know we are intended to loot.
				/// Maybe consider making this an external file list.
				/// Ideally we'd use the item link ID but that seems to be, yep, throwing fucking exceptions.
				for (int iIndex = 1; iIndex <= ThisWindow.NumItems; iIndex++)
				{
					Item ThisItem = ThisWindow.Item(iIndex);
					if (ThisItem.Heirloom && ThisItem.Name == "Void Shard")
						LootedItemSet.Add(iIndex);
				}

				if (m_bLootFFATradeablesAutomatically)
				{
					for (int iIndex = 1; iIndex <= ThisWindow.NumItems; iIndex++)
					{
						Item ThisItem = ThisWindow.Item(iIndex);

						if (!ThisItem.Heirloom && !ThisItem.NoTrade)
							LootedItemSet.Add(iIndex);
					}
				}

				Program.Log("Looting items: ({0})...", LootedItemSet);
				foreach (int iIndex in LootedItemSet)
					ThisWindow.LootItem(iIndex, true);
			}

			else if (ThisWindow.Type == STR_NEED_BEFORE_GREED)
			{
				//ThisWindow.Items(3);
			}

			/*switch (ThisWindow.Type)
			{
				case "Lottery":
					break;
				case "Free For All":
					break;
				case "Need Before Greed":
					break;
				case "Unknown":
				default:
					break;
			}*/

			return true;
		}

		/************************************************************************************/
		/// <summary>
		/// Anything unhandled by the parse engine is assumed to be a narrative.
		/// </summary>
		/// <param name="NewArgs"></param>
		/// <returns></returns>
		protected virtual bool OnLogNarrative(ConsoleLogEventArgs NewArgs)
		{
			/// NOTE: Place all exact-match checks in this table. C# will hash sort it for quickness.
			switch (NewArgs.OriginalLine)
			{
				/// Look for cast abort strings.
				case "Already casting...": /// This one is in question because it isn't necessarily an abort if the same spell is being cast.
				case "Can't see target":
				case "Interrupted!":
				case "No eligible target":
				case "No targets in range":
				case "Not an enemy":
				case "Not enough skill":
				case "Target is immune":
				case "Target is not alive":
				case "Target too weak":
				case "Too far away":
				{
					Program.Log("Cast or harvesting attempt aborted.");
					m_LastCastEndTime = CurrentCycleTimestamp;
					m_bAutoHarvestInProgress = false;
					return true;
				}
			}

			if (m_bAutoHarvestInProgress)
			{
				if (NewArgs.OriginalLine.StartsWith("You gather") ||
					NewArgs.OriginalLine.StartsWith("You failed to gather anything from") ||
					NewArgs.OriginalLine.StartsWith("You forest") ||
					NewArgs.OriginalLine.StartsWith("You failed to forest anything from") ||
					NewArgs.OriginalLine.StartsWith("You acquire") ||
					NewArgs.OriginalLine.StartsWith("You failed to trap anything from") ||
					NewArgs.OriginalLine.StartsWith("You fish") ||
					NewArgs.OriginalLine.StartsWith("You failed to fish anything from") ||
					NewArgs.OriginalLine.StartsWith("You mine") ||
					NewArgs.OriginalLine.StartsWith("You failed to mine anything from") ||
					NewArgs.OriginalLine.StartsWith("You do not have enough skill"))
				{
					Program.Log("Harvesting attempt complete.");
					m_bAutoHarvestInProgress = false;
					return true;
				}
			}

			return false;
		}

		/************************************************************************************/
		protected virtual bool OnLogChat(ChatEventArgs NewArgs)
		{
			string strTrimmedMessage = NewArgs.Message.Trim();
			string strLowerCaseMessage = strTrimmedMessage.ToLower();

			/// Chat Watch text is top priority.
			if (m_ePositioningStance == PositioningStance.ChatWatch &&
				strLowerCaseMessage.Contains(m_strChatWatchTargetText) &&
				m_ChatWatchNextValidAlertTime < CurrentCycleTimestamp)
			{
				Program.Log("Chat Watch text \"{0}\" found!", m_strChatWatchTargetText);
				Program.s_EmailQueueThread.PostEmailMessage(m_astrChatWatchToAddressList, "Chat text spotted!", NewArgs.OriginalLine);
				m_ChatWatchNextValidAlertTime = CurrentCycleTimestamp + TimeSpan.FromMinutes(m_fChatWatchAlertCooldownMinutes);
				/// Don't return a value; allow processing to continue because there's no need to cockblock in this case.
			}

			if (NewArgs.Channel == ChatEventArgs.ChannelType.NonPlayerTell ||
				NewArgs.Channel == ChatEventArgs.ChannelType.NonPlayerSay ||
				NewArgs.Channel == ChatEventArgs.ChannelType.SelfNonPlayerTell)
			{
				return false;
			}

			bool bIsCommand = m_astrCommandingPlayers.Contains(NewArgs.SourceActorName);

			/// Check for a match against custom tell triggers.
			/// These can be authorized from any source.
			foreach (CustomChatTrigger ThisTrigger in m_aCustomChatTriggerList)
			{
				if (ThisTrigger.Match(NewArgs.SourceActorName, strLowerCaseMessage))
				{
					Program.Log("Custom trigger command received (\"{0}\").", ThisTrigger.m_strSubstring);
					foreach (string strThisCommand in ThisTrigger.m_astrCommands)
					{
						RunCommand(strThisCommand, NewArgs.SourceActorName);
					}
					return true;
				}
			}

			/// This override only deals with commands after this point.
			string strThisCommandingPlayer = string.Empty;
			if (string.IsNullOrEmpty(NewArgs.SourceActorName) || !m_astrCommandingPlayers.Contains(NewArgs.SourceActorName))
				return false;

			/// Mentor the specified group member.
			if (strLowerCaseMessage.Contains(m_strMentorSubphrase))
			{
				/// This is a very sloppy way of finding out who to mentor.
				foreach (GroupMember ThisMember in EnumGroupMembers())
				{
					if (strLowerCaseMessage.Contains(ThisMember.Name.ToLower()) && ThisMember.ToActor().IsValid)
					{
						ApplyVerb(ThisMember.ToActor(), "mentor");
						return true;
					}
				}
			}

			else if (strLowerCaseMessage.Contains(m_strRepairSubphrase))
			{
				Actor CommandingPlayerActor = GetPlayerActor(NewArgs.SourceActorName);
				if (CommandingPlayerActor != null)
				{
					Actor MenderTargetActor = CommandingPlayerActor.Target();
					if (MenderTargetActor.IsValid && (MenderTargetActor.Type == "NoKill NPC" || MenderTargetActor.Type == "NPC")) /// Some menders can be killed.
					{
						ApplyVerb(MenderTargetActor, "repair");
						RunCommand("/mender_repair_all");
						return true;
					}
				}
			}

			/// This is a very shady command to use; it's only for the daring individual.
			/// It allows you to specify a verb upon an actor by name, choosing the actor closest to the commanding player.
			/// It is most useful when you want all of your bots to perform a verb at the exact same time.
			/// The command is formatted in five concatenated chunks:
			/// Prefix ActorName Separator Verb Suffix
			/// The INI file allows you to customize the Prefix, Separator, and Suffix to differentiate somewhat.
			/// Using default INI settings a command string will look something like this next line:
			/// try this: "Treasure Chest", "disarm"
			else if (strTrimmedMessage.StartsWith(m_strArbitraryVerbCommandPrefix) && strTrimmedMessage.EndsWith(m_strArbitraryVerbCommandSuffix))
			{
				string strMiddleChunk = strTrimmedMessage.Substring(
					m_strArbitraryVerbCommandPrefix.Length,
					strTrimmedMessage.Length - m_strArbitraryVerbCommandPrefix.Length - m_strArbitraryVerbCommandSuffix.Length);

				string[] astrParameters = strMiddleChunk.Split(new string[] { m_strArbitraryVerbCommandSeparator }, StringSplitOptions.None);
				if (astrParameters.Length != 2)
					return false;

				string strActorName = astrParameters[0];
				string strVerb = astrParameters[1];
				Program.Log("Attempting to apply verb \"{0}\" on actor \"{1}\".", strVerb, strActorName);

				/// Grab the so-named actor nearest to the commander.
				double fNearestDistance = 50.0;
				Actor NearestActor = null;
				foreach (Actor ThisActor in EnumActors(strActorName))
				{
					if (ThisActor.Name != strActorName)
						continue;

					Actor CommandingPlayerActor = GetPlayerActor(NewArgs.SourceActorName);
					double fThisDistance = GetActorDistance2D(CommandingPlayerActor, ThisActor);
					if (fThisDistance < fNearestDistance)
					{
						fNearestDistance = fThisDistance;
						NearestActor = ThisActor;
					}
				}

				/// No such actor found.
				if (NearestActor == null)
				{
					Program.Log("No actor found for the specified arbitrary verb.");
					return false;
				}

				ApplyVerb(NearestActor, strVerb);
				return true;
			}

			else if (strLowerCaseMessage.StartsWith(m_strChatWatchSubphrase))
			{
				Program.Log("Chat Watch command (\"{0}\") received.", m_strChatWatchSubphrase);
				m_strChatWatchTargetText = strLowerCaseMessage.Substring(m_strChatWatchSubphrase.Length).ToLower().Trim();
				Program.Log("Bot will now scan for text \"{0}\".", m_strChatWatchTargetText);

				ChangePositioningStance(PositioningStance.ChatWatch);
			}

			else if (strLowerCaseMessage.StartsWith(m_strSpawnWatchSubphrase))
			{
				Program.Log("Spawn Watch command (\"{0}\") received.", m_strSpawnWatchSubphrase);
				m_bSpawnWatchTargetAnnounced = false;
				m_strSpawnWatchTarget = strTrimmedMessage.Substring(m_strSpawnWatchSubphrase.Length).ToLower().Trim();
				Program.Log("Bot will now scan for actor \"{0}\".", m_strSpawnWatchTarget);
				ChangePositioningStance(PositioningStance.SpawnWatch);
			}

			else if (strLowerCaseMessage.StartsWith(m_strSpawnWatchDespawnSubphrase))
			{
				Program.Log("De-spawn Watch command (\"{0}\") received.", m_strSpawnWatchDespawnSubphrase);
				m_bSpawnWatchTargetAnnounced = false;

				m_strSpawnWatchTarget = strTrimmedMessage.Substring(m_strSpawnWatchDespawnSubphrase.Length).ToLower().Trim();
				Program.Log("Bot will now wait for the absence of actor \"{0}\" for {0:0.0} consecutive minute(s).", m_strSpawnWatchTarget, m_fSpawnWatchDespawnTimeoutMinutes);

				ChangePositioningStance(PositioningStance.DespawnWatch);
			}

			else
				Program.Log("A commanding player ({0}) has spoken (\"{1}\") but no commands were found in the text.", NewArgs.SourceActorName, NewArgs.Message);

			return false;
		}

		/************************************************************************************/
		protected virtual void OnZoningBegin()
		{
			return;
		}

		/************************************************************************************/
		protected virtual void OnZoningComplete()
		{
			if (m_ePositioningStance == PositioningStance.ForwardDash)
				ChangePositioningStance(PositioningStance.AutoFollow);

			WithdrawFromCombat();
			return;
		}

		/************************************************************************************/
		protected void StopCheckingBuffs()
		{
			m_bCheckBuffsNow = false;
			m_LastCheckBuffsTime = CurrentCycleTimestamp;
			Program.Log("Finished checking buffs.");
			return;
		}

		/************************************************************************************/
		protected void ChangePositioningStance(PositioningStance eNewStance)
		{
			/// Deactivate the existing stance.
			if (m_ePositioningStance == PositioningStance.CustomAutoFollow ||
				m_ePositioningStance == PositioningStance.StayInPlace ||
				m_ePositioningStance == PositioningStance.ForwardDash)
			{
				ReleaseKey(m_strForwardKey);
			}

			/// Activate the new stance.
			if (eNewStance == PositioningStance.DoNothing)
			{
				m_ePositioningStance = PositioningStance.DoNothing;

				/// If the player wants autofollow, he'll have to do it manually.
				if (!string.IsNullOrEmpty(MeActor.WhoFollowing))
					RunCommand("/stopfollow");
			}
			else if (eNewStance == PositioningStance.NeutralPosition)
			{
				m_ePositioningStance = PositioningStance.NeutralPosition;
			}
			else if (eNewStance == PositioningStance.StayInPlace)
			{
				/// If a player is specified, we grab the location from it.
				/// Otherwise we assume the location was pre-set.
				if (!string.IsNullOrEmpty(m_strPositionalCommandingPlayer))
				{
					Actor CommandingPlayerActor = GetPlayerActor(m_strPositionalCommandingPlayer);
					if (CommandingPlayerActor != null)
						m_ptStayLocation = new Point3D(CommandingPlayerActor);
				}
				m_ePositioningStance = PositioningStance.StayInPlace;
				m_fCurrentMovementTargetCoordinateTolerance = m_fStayInPlaceTolerance;
				CheckPositioningStance();
			}
			else if (eNewStance == PositioningStance.CustomAutoFollow)
			{
				m_ePositioningStance = PositioningStance.CustomAutoFollow;
				m_bLastShadowTargetSamplingWasNearby = false;
				CheckPositioningStance();
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

			else if (eNewStance == PositioningStance.ChatWatch)
			{
				m_ePositioningStance = PositioningStance.ChatWatch;
				m_ChatWatchNextValidAlertTime = CurrentCycleTimestamp;
			}

			else if (eNewStance == PositioningStance.SpawnWatch)
			{
				m_ePositioningStance = PositioningStance.SpawnWatch;
				m_bSpawnWatchTargetAnnounced = false;
			}

			else if (eNewStance == PositioningStance.DespawnWatch)
			{
				m_ePositioningStance = PositioningStance.DespawnWatch;
				m_bSpawnWatchTargetAnnounced = false;
				m_SpawnWatchDespawnStartTime = CurrentCycleTimestamp;
			}

			return;
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		/// <returns>true if an autofollow command was sent.</returns>
		protected bool CheckPositioningStance()
		{
			/// Traditional client autofollow.
			if (m_ePositioningStance == PositioningStance.AutoFollow)
			{
				if (MeActor.IsDead)
					return false;

				/// Make sure we don't lag into a mob or off a fucking cliff.
				if (m_bIHaveBadPing && m_bBreakAutoFollowOnBadPing)
				{
					if (!string.IsNullOrEmpty(MeActor.WhoFollowing))
						RunCommand(1, "/stopfollow");
					return false;
				}

				/// Make sure an autofollow target exists in our group.
				string strAutoFollowTarget = GetFirstExistingPartyMember(m_astrAutoFollowTargets, true);
				if (string.IsNullOrEmpty(strAutoFollowTarget))
				{
					//Program.Log("Can't autofollow (no configured targets found in group).");
					return false;
				}

				/// If the player isn't in zone or is dead, we don't really need to see that in the log.
				Actor AutoFollowActor = m_GroupMemberDictionary[strAutoFollowTarget].ToActor();
				if (!AutoFollowActor.IsValid)
				{
					//Program.Log("Can't autofollow on {0} (player actor is invalid).", m_strAutoFollowTarget);
					return false;
				}
				else if (AutoFollowActor.ID == MeActor.ID)
				{
					/// Can't follow yourself!
					return false;
				}
				else if (AutoFollowActor.IsDead)
				{
					//Program.Log("Can't autofollow on {0} (player is dead).", m_strAutoFollowTarget);
					return false;
				}

				/// Reapply autofollow.
				/// We won't make it an absolute requirement for Check Buffs completion.
				if (MeActor.WhoFollowing != strAutoFollowTarget)
				{
					/// If we're too far away, the client will put up an error message.
					/// Therefore we have to filter out this failure condition.
					if (GetActorDistance3D(MeActor, AutoFollowActor) < 50)
					{
						if (AutoFollowActor.DoFace())
						{
							RunCommand(1, "/follow {0}", strAutoFollowTarget);
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
			else if (m_ePositioningStance == PositioningStance.StayInPlace || m_ePositioningStance == PositioningStance.CustomAutoFollow)
			{
				if (MeActor.IsDead)
					return false;

				/// Firstly, no matter where we are, stop autofollowing.
				if (!string.IsNullOrEmpty(MeActor.WhoFollowing))
				{
					RunCommand(1, "/stopfollow");
					return true;
				}

				/// For shadowing, the coordinate is updated at every iteration.
				if (m_ePositioningStance == PositioningStance.CustomAutoFollow)
				{
					/// Make sure we don't lag into a mob or off a fucking cliff.
					if (m_bIHaveBadPing && m_bBreakAutoFollowOnBadPing)
					{
						ReleaseKey(m_strForwardKey);
						return false;
					}

					/// Make sure we have an autofollow target configured.
					string strAutoFollowTarget = GetFirstExistingPartyMember(m_astrAutoFollowTargets, false);
					if (string.IsNullOrEmpty(strAutoFollowTarget))
					{
						ReleaseKey(m_strForwardKey);
						return false;
					}

					/// Make sure the autofollow target exists in our party and isn't ourself.
					Actor FollowActor = m_FriendDictionary[strAutoFollowTarget].ToActor();
					if (!FollowActor.IsValid || FollowActor.ID == MeActor.ID)
					{
						ReleaseKey(m_strForwardKey);
						return false;
					}

					m_ptStayLocation = new Point3D(FollowActor);
				}

				if (/*!MeActor.IsClimbing &&*/ MeActor.CanTurn)
				{
					double fRange = GetActorDistance3D(MeActor, m_ptStayLocation);

					/// If target suddenly ported from near to ridiculously far away, almost errantly, then call it off.
					/// But if the target began the stance far away and is approaching near, then allow it to continue,
					/// because in that case the commander is using shadowing to draw the character closer.
					if (m_ePositioningStance == PositioningStance.CustomAutoFollow)
					{
						bool bThisSamplingIsNearby = (fRange < 200.0f);
						if (m_bLastShadowTargetSamplingWasNearby && !bThisSamplingIsNearby)
						{
							//RunCommand("/t {0} you ported too far away", m_astrCommandingPlayers); /// TODO: Make this configurable.
							Program.Log("Custom auto-follow target suddenly warped far away; reverting to auto-follow.");
							ChangePositioningStance(PositioningStance.AutoFollow);
							return true;
						}
						m_bLastShadowTargetSamplingWasNearby = bThisSamplingIsNearby;
					}

					/// Move the character.
					if (fRange > m_fCurrentMovementTargetCoordinateTolerance)
					{
						float fBearing = Me.HeadingTo((float)m_ptStayLocation.X, (float)m_ptStayLocation.Y, (float)m_ptStayLocation.Z);
						if (Me.Face(fBearing))
						{
							Program.Log("Moving to stay position ({0:0.00}, {1:0.00}, {2:0.00}), {3:0.00} meters away...", m_ptStayLocation.X, m_ptStayLocation.Y, m_ptStayLocation.Z, fRange);
							PressAndHoldKey(m_strForwardKey);
						}
					}
					else
					{
						ReleaseKey(m_strForwardKey);
					}
				}
			}

			else if (m_ePositioningStance == PositioningStance.ForwardDash)
			{
				if (MeActor.IsDead)
					return false;

				if (GetActorDistance3D(MeActor, m_ptMyLastLocation) > 200.0f)
				{
					/// We probably ran through a port.
					Program.Log("Large motion gap detected while dashing; it is assumed we got ported.");
					ChangePositioningStance(PositioningStance.NeutralPosition);
				}
				else
				{
					PressAndHoldKey(m_strForwardKey);
				}

				return false;
			}

			else if (m_ePositioningStance == PositioningStance.ChatWatch)
			{
				return true;
			}

			else if (m_ePositioningStance == PositioningStance.SpawnWatch)
			{
				/// Look for the actor.
				Actor ActualFoundActor = null;
				foreach (Actor ThisActor in EnumActors())
				{
					string strThisActorName = ThisActor.Name.Trim().ToLower();
					if (strThisActorName == m_strSpawnWatchTarget)
					{
						ActualFoundActor = ThisActor;
						break;
					}
				}

				/// Actor found!!!
				if (ActualFoundActor != null)
				{
					/// This is awesomesauce right here.
					string strCoordinates = string.Format("{0:0.00}, {1:0.00}, {2:0.00}", ActualFoundActor.X, ActualFoundActor.Y, ActualFoundActor.Z);
					RunCommand("/waypoint {0}", strCoordinates);
					Program.Log("Spawn Watch target \"{0}\" found at ({1})! See map: a waypoint command was executed.", ActualFoundActor.Name, strCoordinates);
					SayText(m_strSpawnWatchAlertSpeech, ActualFoundActor.Name);

					if (m_astrSpawnWatchToAddressList.Count > 0)
					{
						Program.s_EmailQueueThread.PostEmailMessage(
							m_astrSpawnWatchToAddressList,
							"From " + Name,
							ActualFoundActor.Name + " just spawned!");
					}

					try
					{
						RunCommand(m_strSpawnWatchAlertCommand, m_astrCommandingPlayers, m_strSpawnWatchTarget);
					}
					catch
					{
						Program.Log("Error in Spawn Watch alert command format.");
					}

					Program.Log("Now entering De-spawn Watch mode.");
					ChangePositioningStance(PositioningStance.DespawnWatch);
				}
				return true;
			}

			else if (m_ePositioningStance == PositioningStance.DespawnWatch)
			{
				foreach (Actor ThisActor in EnumActors())
				{
					string strThisActorName = ThisActor.Name.Trim().ToLower();
					if ((strThisActorName == m_strSpawnWatchTarget) && !ThisActor.IsDead)
					{
#if DEBUG
						double fDistance = GetActorDistance2D(MeActor, ThisActor);
						Program.Log("Distance to {0}: {1:0.00}", ThisActor.Name, fDistance);
#endif
						/// Reset the clock every time we see a single living actor with the search name.
						m_SpawnWatchDespawnStartTime = CurrentCycleTimestamp;
						return true;
					}
				}

				/// Actor despawned!
				if ((m_SpawnWatchDespawnStartTime + TimeSpan.FromMinutes(m_fSpawnWatchDespawnTimeoutMinutes)) < CurrentCycleTimestamp)
				{
					Program.Log("De-spawn Watch target \"{0}\" dead or no longer found after timeout!", m_strSpawnWatchTarget);

					if (m_astrSpawnWatchToAddressList.Count > 0)
					{
						Program.s_EmailQueueThread.PostEmailMessage(
							m_astrSpawnWatchToAddressList,
							"From " + Name,
							m_strSpawnWatchTarget + " just despawned!");
					}

					ChangePositioningStance(PositioningStance.DoNothing);
				}

				return true;
			}

			return false;
		}

		/************************************************************************************/
		protected bool GetOffensiveTargetActor()
		{
			/// An offensive target ID of -1 is never compatible with our decision-making;
			/// it means the bot has no intention to do combat.
			if (m_iOffensiveTargetID == -1)
			{
				WithdrawFromCombat();
				return false;
			}

			Actor CandidateActor = GetActor(m_iOffensiveTargetID);
			bool bSelectNewTarget = false;

			/// If the mob disappeared, find another one on record.
			if (CandidateActor == null)
			{
				/// Grab the first valid actor in the existing list.
				foreach (Actor ThisActor in EnumValidActorsFromIDCollection(m_OffensiveTargetEncounterActorDictionary.Keys))
				{
					CandidateActor = ThisActor;
					break;
				}

				/// If all actors in the encounter disappeared, it's over.
				if (CandidateActor == null)
				{
					Program.Log("Encounter ended; all actors disappeared.");
					WithdrawFromCombat();
					return false;
				}

				bSelectNewTarget = true;
			}
			else if (CandidateActor.IsDead)
				bSelectNewTarget = true;

			if (bSelectNewTarget)
			{
				/// There are no alternative choices; we're SOL.
				if (m_eEncounterCompletionMode == EncounterCompletionMode.None)
				{
					Program.Log("Forbidden to find new target; now waiting for next assist call from commander.");
					WithdrawFromCombat();
					return false;
				}
				else if (m_eEncounterCompletionMode == EncounterCompletionMode.AssistMainTank)
				{
					CandidateActor = GetNestedCombatAssistTarget(m_strCurrentMainTank);
				}
			}

			/// Evaluate the battlefield and refresh the encounter based on the entire actor map.
			m_KillableActorDictionary.Clear();
			m_OffensiveTargetEncounterActorDictionary.Clear();
			foreach (Actor ThisActor in EnumActors())
			{
				/// Only examine actors that we can attack.
				if (!ThisActor.IsDead &&
					(ThisActor.Type == STR_NAMED_NPC || ThisActor.Type == "NPC") &&
					!ThisActor.IsLocked)
				{
					m_KillableActorDictionary.Add(ThisActor.ID, ThisActor);

					if (ThisActor.ID == CandidateActor.ID || ThisActor.IsInSameEncounter(CandidateActor.ID))
						m_OffensiveTargetEncounterActorDictionary.Add(ThisActor.ID, ThisActor);
				}
			}

			if (m_OffensiveTargetEncounterActorDictionary.Count == 0)
			{
				Program.Log("No killable mobs remaining in the encounter.");
				WithdrawFromCombat();
				return false;
			}

			/// Now find a new actor if needed.
			if (bSelectNewTarget &&
				(m_eEncounterCompletionMode == EncounterCompletionMode.HighestHealth ||
					m_eEncounterCompletionMode == EncounterCompletionMode.LowestHealth ||
					m_eEncounterCompletionMode == EncounterCompletionMode.HighHeroicLowEpic))
			{
				Program.Log("Finding next encounter candidate...");

				/// The actual mode we use will undergo some translation.
				EncounterCompletionMode eActualCompletionMode = m_eEncounterCompletionMode;

				/// Map a pseudomode to a specific mode depending on the context of the target encounter.
				if (eActualCompletionMode == EncounterCompletionMode.HighHeroicLowEpic)
				{
					foreach (Actor ThisActor in m_OffensiveTargetEncounterActorDictionary.Values)
					{
						if (ThisActor.IsEpic)
						{
							eActualCompletionMode = EncounterCompletionMode.LowestHealth;
							break;
						}
					}
					if (eActualCompletionMode != EncounterCompletionMode.LowestHealth)
						eActualCompletionMode = EncounterCompletionMode.HighestHealth;
				}

				/// Decide who in the encounter remains with the highest or lowest health.
				CandidateActor = null;
				foreach (Actor ThisActor in m_OffensiveTargetEncounterActorDictionary.Values)
				{
					/// If health is tied, use the highest ID to make sure all bots decide on the same target.
					if (CandidateActor == null ||
						(eActualCompletionMode == EncounterCompletionMode.HighestHealth && ThisActor.Health > CandidateActor.Health) ||
						(eActualCompletionMode == EncounterCompletionMode.LowestHealth && ThisActor.Health < CandidateActor.Health) ||
						(ThisActor.Health == CandidateActor.Health && ThisActor.ID > CandidateActor.ID))
					{
						CandidateActor = ThisActor;
					}
				}

				Program.Log("New target automatically chosen: {0} ({1}).", CandidateActor.Name, CandidateActor.ID);
			}

			m_OffensiveTargetActor = CandidateActor;
			m_iOffensiveTargetID = CandidateActor.ID;
			m_bIHaveAggro = ((double)m_OffensiveTargetActor.ThreatToMe >= m_fAggroPanicPercentage);
			return true;
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		/// <returns>true if the player was able to fully target and engage the designated opponent</returns>
		protected bool EngageOffensiveTarget()
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

			/// If we're stealthed, then we can bail because targetting is all we need.
			/// Otherwise the /auto commands will break stealth which we might need for some CA's.
			if (MeActor.IsStealthed)
			{
				Program.Log("Player is stealthed; auto-attack will not be toggled.");
				return true;
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
				RunCommand(1, "/auto 2");
				m_OffensiveTargetActor.DoFace();
				return false;
			}
			else if (m_bAutoAttack && !Me.AutoAttackOn)
			{
				RunCommand(1, "/auto 1");
				m_OffensiveTargetActor.DoFace();
				return false;
			}

			/// Make sure the pet is on the right target.
			Actor PetActor = Me.Pet();
			if (PetActor.IsValid && PetActor.CanTurn)
			{
				Actor PetTargetActor = PetActor.Target();
				if (!PetTargetActor.IsValid || (PetTargetActor.ID != m_OffensiveTargetActor.ID) || !PetActor.InCombatMode)
				{
					Program.Log("Sending in pet for attack!");
					RunCommand(1, "/pet attack");
					///return false; // Don't return failure; often there is lag time with the fucking pet and it kills our dps to wait for it.
				}
			}

			/// Decide if I have aggro. In the future, use the ratio.
			Actor AggroWhoreActor = m_OffensiveTargetActor.Target();
			m_bIHaveAggro = AggroWhoreActor.IsValid && (AggroWhoreActor.ID == MeActor.ID);

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
		protected bool WithdrawCombatFromTarget(Actor TargetActor)
		{
			bool bActionTaken = false;

			Actor MyTargetActor = MeActor.Target();
			if (MyTargetActor.IsValid && MyTargetActor.ID == TargetActor.ID)
			{
				/// Turn it off just in case.
				if (Me.AutoAttackOn || Me.RangedAutoAttackOn)
				{
					RunCommand(1, "/auto 0");
					bActionTaken = true;
				}

				/// If an enemy is targetted, target nothing instead.
				//RunCommand("/target_none");
				//return true;
			}

			Actor PetActor = Me.Pet();
			if (PetActor.IsValid)
			{
				Actor PetTargetActor = PetActor.Target();
				if (PetTargetActor.IsValid && PetTargetActor.InCombatMode && PetTargetActor.ID == TargetActor.ID)
				{
					RunCommand(1, "/pet backoff");
					bActionTaken = true;
				}
			}

			return bActionTaken;
		}

		/************************************************************************************/
		protected bool WithdrawFromCombat()
		{
			bool bActionTaken = false;

			if (!MeActor.IsDead)
			{
				/// Cancel a cast only if we can reasonably assume it's done in the context of a combat assist.
				if (m_iOffensiveTargetID != -1 && IsCasting)
				{
					CancelCast();
					bActionTaken = true;
				}

				/// Turn it off. Clearing the target is a backup measure.
				if (Me.AutoAttackOn || Me.RangedAutoAttackOn)
				{
					RunCommand(1, "/auto 0");
					RunCommand(1, "/target_none");
					bActionTaken = true;
				}

				/// Pull the pet back just in case.
				Actor PetActor = Me.Pet();
				if (PetActor.IsValid && PetActor.InCombatMode)
				{
					RunCommand(1, "/pet backoff");
					bActionTaken = true;
				}

				/// If an enemy is targetted, target nothing instead.
				/*Actor TargetActor = MeActor.Target();
				if (TargetActor.IsValid && (TargetActor.Type == "NPC" || TargetActor.Type == STR_NAMED_NPC))
				{
					RunCommand(1, "/target_none");
					bActionTaken = true;
				}*/
			}

			m_iOffensiveTargetID = -1;
			m_OffensiveTargetEncounterActorDictionary.Clear();
			return bActionTaken;
		}

		/************************************************************************************/
		/// <summary>
		/// </summary>
		protected void ClearOffensiveTargetIfWipe()
		{
			if (m_iOffensiveTargetID != -1)
			{
				/// See if everyone is dead...
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
					/// FF6 reference. :)
					Program.Log("Annihilated.");
					WithdrawFromCombat();
				}
			}

			return;
		}
	}
}
