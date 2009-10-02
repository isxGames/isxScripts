using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Diagnostics;

namespace EQ2ParseEngine
{
	public class EQ2LogTokenizer
	{
		public enum GameLanguageType : int
		{
			Unknown = 0,
			AyrDal,
			ChaosTongue,
			Common,
			DeathsWhisper,
			DiZokian,
			Draconic,
			Druzaic,
			Dwarven,
			Erudian,
			Faerlie,
			Fayefolk,
			FeirDal,
			Gnollish,
			Gnomish,
			Goblish,
			Gorwish,
			Guktan,
			Halasian,
			Kerran,
			KoadaDal,
			Krombral,
			Oggish,
			Orcish,
			Ratongan,
			Sathirian,
			Screechsong,
			Sebilisian,
			Serilian,
			Stout,
			Thexian,
			Thullian,
			TikTok,
			Uruvanian,
			Volant,
			WordsOfShade,
			Ykeshan,
		}

		protected SharedStringCache m_SharedStringCache = new SharedStringCache();
		protected CompiledRegexCache m_CompiledRegexCache = new CompiledRegexCache();

		/************************************************************************************/
		public EQ2LogTokenizer()
		{
		}

		/************************************************************************************/
		private string m_strMyCharacterName = string.Empty;
		public string MyCharacterName
		{
			get { return m_strMyCharacterName; }
			set { m_strMyCharacterName = value; }
		}

		/************************************************************************************/
		private GameLanguageType m_eGameLanguage = GameLanguageType.Common;
		public GameLanguageType MyGameLanguage
		{
			get { return m_eGameLanguage; }
			set { m_eGameLanguage = value; }
		}

		/************************************************************************************/
		public interface ICustomRegexTrigger
		{
			string Regex { get; }
			void OnFound(DateTime Timestamp, string strFullLine);
		}

		private List<ICustomRegexTrigger> m_aCustomNarrativeRegexTriggers = new List<ICustomRegexTrigger>();
		public List<ICustomRegexTrigger> CustomNarrativeRegexTriggers
		{
			get
			{
				return m_aCustomNarrativeRegexTriggers;
			}
		}

		/************************************************************************************/
		public class ItemLinkFoundEventArgs : EventArgs, IComparable<ItemLinkFoundEventArgs>
		{
			protected readonly string m_strFullLink = string.Empty;
			public string FullLink { get { return m_strFullLink; } }

			protected readonly int m_iParameter1 = 0;
			public int Parameter1 { get { return m_iParameter1; } }

			protected readonly int m_iParameter2 = 0;
			public int Parameter2 { get { return m_iParameter2; } }

			protected readonly int m_iParameter3 = 0;
			public int Parameter3 { get { return m_iParameter3; } }

			protected readonly string m_strItemName = string.Empty;
			public string ItemName { get { return m_strItemName; } }

			public ItemLinkFoundEventArgs(
				string strFullLink,
				int iParameter1,
				int iParameter2,
				int iParameter3,
				string strItemName)
			{
				m_strFullLink = strFullLink;
				m_iParameter1 = iParameter1;
				m_iParameter2 = iParameter2;
				m_iParameter3 = iParameter3;
				m_strItemName = strItemName;
				return;
			}

			/// <summary>
			/// This is useful in case you want to keep a SortedDictionary of unique item links.
			/// </summary>
			public int CompareTo(ItemLinkFoundEventArgs OtherItem)
			{
				int iComparison = 0;

				/// Parameter 1 is a quicker sort method but for human readability, the name is better.
				iComparison = m_strItemName.CompareTo(OtherItem.m_strItemName);
				if (iComparison != 0)
					return iComparison;

				iComparison = m_iParameter1.CompareTo(OtherItem.m_iParameter1);
				if (iComparison != 0)
					return iComparison;

				iComparison = m_iParameter2.CompareTo(OtherItem.m_iParameter2);
				if (iComparison != 0)
					return iComparison;

				iComparison = m_iParameter3.CompareTo(OtherItem.m_iParameter3);
				if (iComparison != 0)
					return iComparison;

				return 0;
			}
		}

		public delegate void ItemLinkFoundDelegate(object objSender, ItemLinkFoundEventArgs args);
		public event ItemLinkFoundDelegate ItemLinkFound;

		/************************************************************************************/
		public class ConsoleLogEventArgs : EventArgs
		{
			protected readonly DateTime m_Timestamp = DateTime.FromBinary(0);
			public DateTime Timestamp { get { return m_Timestamp; } }

			protected readonly string m_strOriginalLine = string.Empty;
			public string OriginalLine { get { return m_strOriginalLine; } }

			public ConsoleLogEventArgs(
				DateTime ThisTimestamp,
				string strOriginalLine)
			{
				m_Timestamp = ThisTimestamp;
				m_strOriginalLine = strOriginalLine;
				return;
			}
		}

		public delegate void LineNotRecognizedDelegate(object objSender, ConsoleLogEventArgs args);
		public event LineNotRecognizedDelegate LineNotRecognized;

		/************************************************************************************/
		/// <summary>
		/// This event depicts any communication text, like tells or says.
		/// </summary>
		public class ChatEventArgs : ConsoleLogEventArgs, ICloneable
		{
			public enum ChannelType : int
			{
				NonChat = 0,
				PlayerSay,
				NonPlayerSay,
				PlayerTell,
				NonPlayerTell,
				NamedChannel,
				OutOfCharacter,
				Shout,
				Raid,
				Group,
				Guild,
				Officer,
			}

			internal ChannelType m_eChannelType = ChannelType.NonChat;
			public ChannelType Channel { get { return m_eChannelType; } }

			internal GameLanguageType m_eGameLanguage = GameLanguageType.Unknown;
			public GameLanguageType GameLanguage { get { return m_eGameLanguage; } }

			internal int m_iSourceActorID = -1;
			public int SourceActorID { get { return m_iSourceActorID; } }

			internal string m_strSourceActorName = string.Empty;
			public string SourceActorName { get { return m_strSourceActorName; } }

			internal string m_strDestinationName = string.Empty;
			/// <summary>
			/// This can be either a player name or a channel name depending on the context.
			/// </summary>
			public string DestinationName { get { return m_strDestinationName; } }

			internal string m_strMessage = string.Empty;
			public string Message { get { return m_strMessage; } }

			public ChatEventArgs(
				DateTime Timestamp,
				string strOriginalLine)
				: base(Timestamp, strOriginalLine)
			{
				return;
			}

			public ChatEventArgs(
				DateTime Timestamp,
				string strOriginalLine,
				ChannelType eChannelType,
				int iSourceActorID,
				string strSourceActorName,
				string strDestinationName,
				string strMessage):base(Timestamp, strOriginalLine)
			{
				m_eChannelType = eChannelType;
				m_iSourceActorID = iSourceActorID;
				m_strSourceActorName = strSourceActorName;
				m_strDestinationName = strDestinationName;
				m_strMessage = strMessage;
				return;
			}

			public ChatEventArgs Copy()
			{
				ChatEventArgs NewArgs = new ChatEventArgs(m_Timestamp, m_strOriginalLine);
				NewArgs.m_eChannelType = m_eChannelType;
				NewArgs.m_eGameLanguage = m_eGameLanguage;
				NewArgs.m_iSourceActorID = m_iSourceActorID;
				NewArgs.m_strDestinationName = m_strDestinationName;
				NewArgs.m_strMessage = m_strMessage;
				NewArgs.m_strSourceActorName = m_strSourceActorName;
				return NewArgs;
			}

			public object Clone()
			{
				return Copy();
			}
		}

		public delegate void ChatEventDelegate(object objSender, ChatEventArgs args);
		public event ChatEventDelegate ChatSent;

		/************************************************************************************/
		public class ActionEventArgs : ConsoleLogEventArgs, ICloneable
		{
			public enum ActionType : int
			{
				Unknown = 0,
				Cure,
				Stoneskin,
				Ward,
				Heal,
				PowerHeal,
				PowerDrain,
				FocusDamage,
				FallingDamage,
				CrushingDamage,
				SlashingDamage,
				PiercingDamage,
				HeatDamage,
				ColdDamage,
				MagicDamage,
				MentalDamage,
				DivineDamage,
				PoisonDamage,
				DiseaseDamage,
			}

			[Flags]
			public enum AttributeFlags : uint
			{
				Critical = 0x1,
				Double = 0x2,
				Flurry = 0x4,
				AOEAutoAttack = 0x8,
				Missed = 0x10,
				Resisted = 0x20,
				Dodged = 0x40,
				Parried = 0x80,
				Deflected = 0x100,
				Riposted = 0x200,
				Reflected = 0x400,
				Blocked = 0x800,
			}

			internal int m_iQuantity = 0;
			public int Quantity { get { return m_iQuantity; } }

			internal string m_strSource = string.Empty;
			public string Source { get { return m_strSource; } }

			internal string m_strDestination = string.Empty;
			public string Destination { get { return m_strDestination; } }

			internal string m_strAbilityName = string.Empty;
			public string AbilityName { get { return m_strAbilityName; } }

			internal string m_strSecondaryParameter = string.Empty;
			public string SecondaryParameter { get { return m_strSecondaryParameter; } }

			internal ActionType m_eActionType = ActionType.Unknown;
			public ActionType Action { get { return m_eActionType; } }

			internal AttributeFlags m_eAttributes = 0;
			public AttributeFlags Attributes { get { return m_eAttributes; } }

			public ActionEventArgs(DateTime Timestamp, string strParseLine):base(Timestamp, strParseLine)
			{
			}

			public ActionEventArgs Copy()
			{
				ActionEventArgs NewArgs = new ActionEventArgs(m_Timestamp, m_strOriginalLine);
				NewArgs.m_eActionType = m_eActionType;
				NewArgs.m_eAttributes = m_eAttributes;
				NewArgs.m_iQuantity = m_iQuantity;
				NewArgs.m_strAbilityName = m_strAbilityName;
				NewArgs.m_strDestination = m_strDestination;
				NewArgs.m_strSource = m_strSource;
				return NewArgs;
			}

			public object Clone()
			{
				return Copy();
			}
		}

		public delegate void ActionEventDelegate(object objSender, ActionEventArgs args);
		public event ActionEventDelegate ActionOccurred;

		/************************************************************************************/
		public static DateTime UnixTimeToDateTime(long time_t)
		{
			long win32FileTime = 10000000 * (long)time_t + 116444736000000000;
			return DateTime.FromFileTimeUtc(win32FileTime);
		}

		/************************************************************************************/
		protected void SplitActorAbilityPair(string strPair, ref string strActor, ref string strAbility)
		{
			Match ThisMatch = null;

			if (strPair == "YOU")
			{
				strActor = m_strMyCharacterName;
				strAbility = string.Empty;
				return;
			}

			ThisMatch = m_CompiledRegexCache.Match(strPair, @"YOUR (?<ability>.+)");
			if (ThisMatch.Success)
			{
				strActor = m_strMyCharacterName;
				strAbility = ThisMatch.Groups["ability"].Value;
				return;
			}

			ThisMatch = m_CompiledRegexCache.Match(strPair, @"(?<actor>.+?)'s? (?<ability>.+)");
			if (!ThisMatch.Success)
				ThisMatch = m_CompiledRegexCache.Match(strPair, @"(?<actor>YOUR) (?<ability>.+)");
			if (ThisMatch.Success)
			{
				strActor = ThisMatch.Groups["actor"].Value;
				if (strActor == "YOUR")
					strActor = m_strMyCharacterName;

				strAbility = ThisMatch.Groups["ability"].Value;
				return;
			}

			/// Probably a single name, in which case there is no ability but instead basic autoattack use.
			strActor = strPair;
			strAbility = string.Empty;
			return;
		}

		/************************************************************************************/
		/// <summary>
		/// Assigns the variable, but first conveniently translating "YOU" and "YOURSELF" to my character name if needed.
		/// </summary>
		/// <param name="strLogName"></param>
		/// <param name="strFinalName"></param>
		protected void AssignActorName(string strLogName, ref string strFinalName)
		{
			if (strLogName == "YOU" || strLogName == "YOURSELF")
				strFinalName = m_strMyCharacterName;
			else
				strFinalName = strLogName;
		}

		/************************************************************************************/
		protected void AssignDamageType(string strLogName, ref ActionEventArgs.ActionType eActionType)
		{
			switch (strLogName)
			{// case "struck":
				case "focus": eActionType = ActionEventArgs.ActionType.FocusDamage; break;
				case "falling": eActionType = ActionEventArgs.ActionType.FallingDamage; break;
				case "crush":
				case "crushes":
				case "crushing": eActionType = ActionEventArgs.ActionType.CrushingDamage; break;
				case "slash":
				case "slashes":
				case "slashing": eActionType = ActionEventArgs.ActionType.SlashingDamage; break;
				case "pierce":
				case "pierces":
				case "piercing": eActionType = ActionEventArgs.ActionType.PiercingDamage; break;
				case "burn":
				case "heat": eActionType = ActionEventArgs.ActionType.HeatDamage; break;
				case "freeze":
				case "cold": eActionType = ActionEventArgs.ActionType.ColdDamage; break;
				case "zap":
				case "magic": eActionType = ActionEventArgs.ActionType.MagicDamage; break;
				case "confound":
				case "confounds":
				case "mental": eActionType = ActionEventArgs.ActionType.MentalDamage; break;
				case "smite":
				case "smites":
				case "divine": eActionType = ActionEventArgs.ActionType.DivineDamage; break;
				case "diseases":
				case "disease": eActionType = ActionEventArgs.ActionType.DiseaseDamage; break;
				case "poisons":
				case "poison": eActionType = ActionEventArgs.ActionType.PoisonDamage; break;
				default: eActionType = ActionEventArgs.ActionType.Unknown; break;
			}
		}

		/************************************************************************************/
		protected void AssignAttributeType(string strLogName, ref ActionEventArgs.AttributeFlags eAttributes)
		{
			if (strLogName.StartsWith("critically"))
			{
				eAttributes |= ActionEventArgs.AttributeFlags.Critical;
				return;
			}

			switch (strLogName)
			{
				case "hit":
				case "hits": break;
				case "double attack":
				case "double attacks": eAttributes |= ActionEventArgs.AttributeFlags.Double; break;
				case "flurries":
				case "flurry": eAttributes |= ActionEventArgs.AttributeFlags.Flurry; break;
				case "aoe attack":
				case "aoe attacks": eAttributes |= ActionEventArgs.AttributeFlags.AOEAutoAttack; break;
				case "blocks":
				case "block": eAttributes |= ActionEventArgs.AttributeFlags.Blocked; break;
				case "misses":
				case "miss": eAttributes |= ActionEventArgs.AttributeFlags.Missed; break;
				case "parry":
				case "parries": eAttributes |= ActionEventArgs.AttributeFlags.Parried; break;
				case "dodges":
				case "dodge": eAttributes |= ActionEventArgs.AttributeFlags.Dodged; break;
				case "resists":
				case "resist": eAttributes |= ActionEventArgs.AttributeFlags.Resisted; break;
				case "ripostes":
				case "riposte": eAttributes |= ActionEventArgs.AttributeFlags.Riposted; break;
				case "deflects":
				case "deflect": eAttributes |= ActionEventArgs.AttributeFlags.Deflected; break;
				case "reflects":
				case "reflect": eAttributes |= ActionEventArgs.AttributeFlags.Reflected; break;
				default: break;
			}
			return;
		}

		/************************************************************************************/
		protected void AssignGameLanguageType(string strLogName, ref GameLanguageType eLanguageType)
		{
			switch (strLogName)
			{
				case "Ayr'Dal": eLanguageType = GameLanguageType.AyrDal; break;
				case "Chaos Tongue": eLanguageType = GameLanguageType.ChaosTongue; break;
				case "Common": eLanguageType = GameLanguageType.Common; break;
				case "Death's Whisper": eLanguageType = GameLanguageType.DeathsWhisper; break;
				case "Di'Zokian": eLanguageType = GameLanguageType.DiZokian; break;
				case "Draconic": eLanguageType = GameLanguageType.Draconic; break;
				case "Druzaic": eLanguageType = GameLanguageType.Druzaic; break;
				case "Dwarven": eLanguageType = GameLanguageType.Dwarven; break;
				case "Erudian": eLanguageType = GameLanguageType.Erudian; break;
				case "Faerlie": eLanguageType = GameLanguageType.Faerlie; break;
				case "Fayefolk": eLanguageType = GameLanguageType.Fayefolk; break;
				case "Feir'Dal": eLanguageType = GameLanguageType.FeirDal; break;
				case "Gnollish": eLanguageType = GameLanguageType.Gnollish; break;
				case "Gnomish": eLanguageType = GameLanguageType.Gnomish; break;
				case "Goblish": eLanguageType = GameLanguageType.Goblish; break;
				case "Gorwish": eLanguageType = GameLanguageType.Gorwish; break;
				case "Guktan": eLanguageType = GameLanguageType.Guktan; break;
				case "Halasian": eLanguageType = GameLanguageType.Halasian; break;
				case "Kerran": eLanguageType = GameLanguageType.Kerran; break;
				case "Koada'Dal": eLanguageType = GameLanguageType.KoadaDal; break;
				case "Krombral": eLanguageType = GameLanguageType.Krombral; break;
				case "Oggish": eLanguageType = GameLanguageType.Oggish; break;
				case "Orcish": eLanguageType = GameLanguageType.Orcish; break;
				case "Ratongan": eLanguageType = GameLanguageType.Ratongan; break;
				case "Sathirian": eLanguageType = GameLanguageType.Sathirian; break;
				case "Screechsong": eLanguageType = GameLanguageType.Screechsong; break;
				case "Sebilisian": eLanguageType = GameLanguageType.Sebilisian; break;
				case "Serilian": eLanguageType = GameLanguageType.Serilian; break;
				case "Stout": eLanguageType = GameLanguageType.Stout; break;
				case "Thexian": eLanguageType = GameLanguageType.Thexian; break;
				case "Thullian": eLanguageType = GameLanguageType.Thullian; break;
				case "Tik Tok": eLanguageType = GameLanguageType.TikTok; break;
				case "Uruvanian": eLanguageType = GameLanguageType.Uruvanian; break;
				case "Volant": eLanguageType = GameLanguageType.Volant; break;
				case "Words of Shade": eLanguageType = GameLanguageType.WordsOfShade; break;
				case "Ykeshan": eLanguageType = GameLanguageType.Ykeshan; break;
				default: eLanguageType = m_eGameLanguage; break;
			}
			return;
		}

		/************************************************************************************/
		protected void DispatchChatEvent(ChatEventArgs NewEvent)
		{
			if (ChatSent == null)
				return;

			NewEvent.m_strSourceActorName = m_SharedStringCache.GetSharedReference(NewEvent.m_strSourceActorName);
			NewEvent.m_strDestinationName = m_SharedStringCache.GetSharedReference(NewEvent.m_strDestinationName);

			/// Done only because it's anticipated there are a lot of repetitive macros that get used.
			/// But this code and premise can change at any time.
			if (NewEvent.m_eChannelType == ChatEventArgs.ChannelType.Group || NewEvent.m_eChannelType == ChatEventArgs.ChannelType.Raid)
				NewEvent.m_strMessage = m_SharedStringCache.GetSharedReference(NewEvent.m_strMessage);

			ChatSent(this, NewEvent);
			return;
		}

		/************************************************************************************/
		protected void DispatchActionEvent(ActionEventArgs NewEvent)
		{
			if (ActionOccurred == null)
				return;

			NewEvent.m_strAbilityName = m_SharedStringCache.GetSharedReference(NewEvent.m_strAbilityName);
			NewEvent.m_strSource = m_SharedStringCache.GetSharedReference(NewEvent.m_strSource);
			NewEvent.m_strDestination = m_SharedStringCache.GetSharedReference(NewEvent.m_strDestination);

			ActionOccurred(this, NewEvent);
			return;
		}

		/************************************************************************************/
		public bool FeedLine(DateTime Timestamp, string strParseLine)
		{
			Match ThisMatch = null;
			MatchCollection ThisMatchSet = null;

			/// Handle all custom triggers with top priority.
			/// TODO: Arguably with the right locking, this loop could even be farmed out to a queued work item.
			/// That might not be a bad idea when the list gets long enough.
			foreach (ICustomRegexTrigger ThisCustomRegex in m_aCustomNarrativeRegexTriggers)
			{
				ThisMatch = m_CompiledRegexCache.Match(strParseLine, ThisCustomRegex.Regex);
				if (ThisMatch.Success)
					ThisCustomRegex.OnFound(Timestamp, strParseLine);
			}

			/// Fish out any item links if a callback is registered.
			if (ItemLinkFound != null)
			{
				/// \aPC 813717 Testplayer:Testplayer\/a says to the group, "\aITEM -1556439464 1176896923 -1268519431:Dragon's Marrow\/a"
				/// \aPC 813717 Testplayer:Testplayer\/a says to the group, "\aITEM 1311278388 1184237822:Channeled Robe of Ethereal Energy\/a"
				ThisMatchSet = m_CompiledRegexCache.Matches(strParseLine, @"\\aITEM (-?\d+) (-?\d+) ?(-?\d+)?:([^\\]*)\\/a");
				foreach (Match ThisItemMatch in ThisMatchSet)
				{
					string strLink = ThisItemMatch.Value;
					string strParameter1 = ThisItemMatch.Groups[1].Value;
					string strParameter2 = ThisItemMatch.Groups[2].Value;
					string strParameter3 = ThisItemMatch.Groups[3].Value;
					string strName = ThisItemMatch.Groups[4].Value;

					int iParameter1 = -1;
					int iParameter2 = -1;
					int iParameter3 = -1;

					if (!int.TryParse(strParameter1, out iParameter1))
						iParameter1 = 0;
					if (!int.TryParse(strParameter2, out iParameter2))
						iParameter2 = 0;
					if (!int.TryParse(strParameter3, out iParameter3))
						iParameter3 = 0;

					ItemLinkFoundEventArgs NewEvent = new ItemLinkFoundEventArgs(strLink, iParameter1, iParameter2, iParameter3, strName);
					ItemLinkFound(this, NewEvent);
				}
			}

			/// Action events are not even worth calling if no event callback is registered.
			if (ActionOccurred != null)
			{
				/// Anonymous damage from ability.
				/// This absolutely needs to be parsed BEFORE the next RegEx because the victim and ability are reversed.
				/// a void savage is hit by Flameshield for 181 heat damage.
				ThisMatch = m_CompiledRegexCache.Match(strParseLine, @"(?<victim>.+?) (?:is|are) (?<critically>critically |)hit by (?<ability>.*) for (?<quantity>\d+) (?<damagetype>focus|falling|crushing|slashing|piercing|heat|cold|magic|mental|divine|disease|poison) damage.$");
				if (ThisMatch.Success)
				{
					ActionEventArgs NewEvent = new ActionEventArgs(Timestamp, strParseLine);

					AssignActorName(ThisMatch.Groups["victim"].Value, ref NewEvent.m_strDestination);
					AssignDamageType(ThisMatch.Groups["damagetype"].Value, ref NewEvent.m_eActionType);
					AssignAttributeType(ThisMatch.Groups["critically"].Value, ref NewEvent.m_eAttributes);
					NewEvent.m_iQuantity = int.Parse(ThisMatch.Groups["quantity"].Value);
					NewEvent.m_strAbilityName = ThisMatch.Groups["ability"].Value;

					DispatchActionEvent(NewEvent);
					return true;
				}

				/// General offensive damage.
				/// YOU hit a deathless gazer for 340 crushing damage.
				/// YOU critically hit The Carnovingian for 506 crushing damage.
				/// YOU critically double attack a deathless gazer for 680 crushing damage.
				/// Testplayer critically hits roekillik excavation chief for 555 crushing damage.
				/// Testplayer critically hits a fetidthorn wraith for 1559 slashing damage.
				/// Testplayer critically double attacks The Carnovingian for 1559 slashing damage.
				/// Testplayer's protoflame hits a deathless gazer for 326 heat damage.
				/// Testplayer critically aoe attacks a cinder wasp for 2900 piercing damage.
				/// YOUR Bewilderment hits a roekillik watcher for 2541 magic damage.
				/// YOUR Dynamism critically hits a roekillik watcher for 1238 mental damage.
				/// Testplayer's Malefic Fury hits roekillik excavation chief for 148 mental damage.
				/// Testplayer's Flametongue critically hits roekillik excavation chief for 157 heat damage.
				/// a Galebreaker maiden critically hits Testplayer for 4 slashing and 3 cold damage.
				/// a Galebreaker maiden hits Testplayer for 3 cold and 0 slashing damage.
				/// a Skyshield maiden's Holy Circle hits Testplayer for 3 cold and 0 divine damage.
				ThisMatch = m_CompiledRegexCache.Match(strParseLine, @"(?<actorability>.+?) (?<critically>critically |)(?<attacktype>hits?|double attacks?|aoe attacks?|flurries|flurry) (?<victim>.+) for (?<damagelist>.*) damage.$");
				if (ThisMatch.Success)
				{
					ActionEventArgs NewEvent = new ActionEventArgs(Timestamp, strParseLine);

					SplitActorAbilityPair(ThisMatch.Groups["actorability"].Value, ref NewEvent.m_strSource, ref NewEvent.m_strAbilityName);
					AssignActorName(ThisMatch.Groups["victim"].Value, ref NewEvent.m_strDestination);
					AssignAttributeType(ThisMatch.Groups["critically"].Value, ref NewEvent.m_eAttributes);
					AssignAttributeType(ThisMatch.Groups["attacktype"].Value, ref NewEvent.m_eAttributes);

					/// Parse the damage list (which may include multiple hits of varying damage types).
					string strDamageList = ThisMatch.Groups["damagelist"].Value;
					ThisMatchSet = m_CompiledRegexCache.Matches(strDamageList, @"(?<quantity>\d+) (?<damagetype>focus|crushing|slashing|piercing|heat|cold|magic|mental|divine|disease|poison)");
					if (ThisMatchSet.Count > 0)
					{
						/// This for-loop is set up a little funky.
						/// For the first match (index 0), the original event object is used.
						/// For every match after the first one, an event object is duplicated.
						/// Even though the event args are read-only, I don't want to event the first one out until I'm done with it.
						/// Unlike ACT, we don't have composite damage actions because those are confusing.
						for (int iIndex = ThisMatchSet.Count - 1; iIndex >= 0; iIndex--)
						{
							ActionEventArgs ThisEvent = null;
							if (iIndex == 0)
								ThisEvent = NewEvent;
							else
								ThisEvent = NewEvent.Copy();

							Match ThisItemMatch = ThisMatchSet[iIndex];
							AssignDamageType(ThisItemMatch.Groups["damagetype"].Value, ref ThisEvent.m_eActionType);
							ThisEvent.m_iQuantity = int.Parse(ThisItemMatch.Groups["quantity"].Value);
							DispatchActionEvent(ThisEvent);
						}
					}
					return true;
				}

				/// Anonymous damage from autoattack.
				/// The dev formatting for this line type is exceptionally poorly done. Very lazy.
				/// a summoned spiderling is aoe attack for 166 crushing damage.
				/// a summoned spiderling is critically double attack for 179 crushing damage.
				ThisMatch = m_CompiledRegexCache.Match(strParseLine, @"(?<victim>.+?) (?:is|are) (?<critically>critically |)(?<attacktype>hit|aoe attack|double attack) for (?<quantity>\d+) (?<damagetype>focus|falling|crushing|slashing|piercing|heat|cold|magic|mental|divine|disease|poison) damage.$");
				if (ThisMatch.Success)
				{
					ActionEventArgs NewEvent = new ActionEventArgs(Timestamp, strParseLine);

					AssignActorName(ThisMatch.Groups["victim"].Value, ref NewEvent.m_strDestination);
					AssignDamageType(ThisMatch.Groups["damagetype"].Value, ref NewEvent.m_eActionType);
					NewEvent.m_iQuantity = int.Parse(ThisMatch.Groups["quantity"].Value);
					AssignAttributeType(ThisMatch.Groups["critically"].Value, ref NewEvent.m_eAttributes);
					AssignAttributeType(ThisMatch.Groups["attacktype"].Value, ref NewEvent.m_eAttributes);

					DispatchActionEvent(NewEvent);
					return true;
				}

				/// Wards from the attacker's perspective.
				/// a mechnamagica hunter-seeker double attacks Testplayer but fails to inflict any damage.
				/// an ashengaze basilisk hits Testplayer but fails to inflict any damage.
				/// The Carnovingian hits Testplayer but fails to inflict any damage.
				/// YOUR Vampiric Requiem hits YOURSELF but fails to inflict any damage.
				/// Testwithendingess' Vampiric Requiem hits Testwithendingess but fails to inflict any damage.
				/// an undying warrior's Rupture hits Testplayer but fails to inflict any damage.
				/// a deathless gazer's Eye of Fire hits Testplayer but fails to inflict any damage.
				/// a deathless gazer hits Testplayer but fails to inflict any damage.
				ThisMatch = m_CompiledRegexCache.Match(strParseLine, @"(?<actorability>.+?) (?<critically>critically |)(?<attacktype>hit|double attack)s (?<victim>.+) but fails to inflict any damage.$");
				if (ThisMatch.Success)
				{
					ActionEventArgs NewEvent = new ActionEventArgs(Timestamp, strParseLine);

					SplitActorAbilityPair(ThisMatch.Groups["actorability"].Value, ref NewEvent.m_strSource, ref NewEvent.m_strAbilityName);
					AssignActorName(ThisMatch.Groups["victim"].Value, ref NewEvent.m_strDestination);
					AssignAttributeType(ThisMatch.Groups["attacktype"].Value, ref NewEvent.m_eAttributes);
					AssignAttributeType(ThisMatch.Groups["critically"].Value, ref NewEvent.m_eAttributes);

					DispatchActionEvent(NewEvent);
					return true;
				}

				/// Invulnerability, though the source text doesn't give an accurate damage type.
				/// Testplayer's Sandra's Deafening Strike slashes Nax Sorast, but Nax Sorast is invulnerable.
				/// Testplayer's Seed of Fire slashes Avatar of Justice, but Avatar of Justice is invulnerable.
				/// YOUR Ice Spears slash Avatar of Justice, but Avatar of Justice is invulnerable.
				/// YOUR Ball of Fire slash Avatar of Justice, but Avatar of Justice is invulnerable.
				ThisMatch = m_CompiledRegexCache.Match(strParseLine, @"(?<actorability>.+?) (?<damagetype>slash|slashes) (?<victim>.+), but \3 is invulnerable.$");
				if (ThisMatch.Success)
				{
					ActionEventArgs NewEvent = new ActionEventArgs(Timestamp, strParseLine);

					SplitActorAbilityPair(ThisMatch.Groups["actorability"].Value, ref NewEvent.m_strSource, ref NewEvent.m_strAbilityName);
					AssignActorName(ThisMatch.Groups["victim"].Value, ref NewEvent.m_strDestination);
					AssignDamageType(ThisMatch.Groups["damagetype"].Value, ref NewEvent.m_eActionType);

					DispatchActionEvent(NewEvent);
					return true;
				}

				/// Cures.
				/// YOUR Cure Arcane relieves YOU of Chronosiphoning.
				/// YOUR Cure relieves Spawn from Testplayer.
				/// Testplayer's Purifying Persistence relieves Nether Mists from Testplayer2.
				/// Testplayer's Ebbing Spirit relieves Nether Tide from YOU.
				ThisMatch = m_CompiledRegexCache.Match(strParseLine, @"(?<actorability>.+?) relieves (?<badeffect>.+) from (?<victim>.+).$");
				if (!ThisMatch.Success)
					ThisMatch = m_CompiledRegexCache.Match(strParseLine, @"(?<actorability>.+?) relieves (?<victim>YOU) of (?<badeffect>.+).$");
				if (ThisMatch.Success)
				{
					ActionEventArgs NewEvent = new ActionEventArgs(Timestamp, strParseLine);
					NewEvent.m_eActionType = ActionEventArgs.ActionType.Cure;

					SplitActorAbilityPair(ThisMatch.Groups["actorability"].Value, ref NewEvent.m_strSource, ref NewEvent.m_strAbilityName);
					AssignActorName(ThisMatch.Groups["victim"].Value, ref NewEvent.m_strDestination);
					NewEvent.m_strSecondaryParameter = ThisMatch.Groups["badeffect"].Value;

					DispatchActionEvent(NewEvent);
					return true;
				}

				/// Wards from the healer's perspective.
				/// Testplayer's Arcane Symphony absorbs 98 points of damage from being done to YOU.
				/// Testplayer's Runic Armor absorbs 362 points of damage from being done to Testplayer.
				/// Testplayer's Arcane Symphony absorbs 264 points of damage from being done to Testplayer.
				/// Testplayer's Ward of Sages absorbs 1 point of damage from being done to Testplayer.
				ThisMatch = m_CompiledRegexCache.Match(strParseLine, @"(?<actorability>.+?) absorbs (?<quantity>\d+) points? of damage from being done to (?<victim>.+).$");
				if (ThisMatch.Success)
				{
					ActionEventArgs NewEvent = new ActionEventArgs(Timestamp, strParseLine);
					NewEvent.m_eActionType = ActionEventArgs.ActionType.Ward;

					SplitActorAbilityPair(ThisMatch.Groups["actorability"].Value, ref NewEvent.m_strSource, ref NewEvent.m_strAbilityName);
					NewEvent.m_iQuantity = int.Parse(ThisMatch.Groups["quantity"].Value);
					AssignActorName(ThisMatch.Groups["victim"].Value, ref NewEvent.m_strDestination);

					DispatchActionEvent(NewEvent);
					return true;
				}

				/// Heals from the healer's perspective.
				/// Testplayer's Divine Prayer critically heals Testplayer for 306 hit points.
				/// Testplayer's Greater Reflexive Restoration heals Testplayer for 449 hit points.
				/// Testplayer's Mortal Lifetap heals Testplayer for 802 hit points.
				/// a void glider's Inquisition critically heals Bydekm for 1287 hit points.
				ThisMatch = m_CompiledRegexCache.Match(strParseLine, @"(?<actorability>.+?) (?<critically>critically |)heals? (?<victim>.+) for (?<quantity>\d+) hit points?.$");
				if (ThisMatch.Success)
				{
					ActionEventArgs NewEvent = new ActionEventArgs(Timestamp, strParseLine);
					NewEvent.m_eActionType = ActionEventArgs.ActionType.Heal;

					SplitActorAbilityPair(ThisMatch.Groups["actorability"].Value, ref NewEvent.m_strSource, ref NewEvent.m_strAbilityName);
					AssignActorName(ThisMatch.Groups["victim"].Value, ref NewEvent.m_strDestination);
					NewEvent.m_iQuantity = int.Parse(ThisMatch.Groups["quantity"].Value);
					AssignAttributeType(ThisMatch.Groups["critically"].Value, ref NewEvent.m_eAttributes);

					DispatchActionEvent(NewEvent);
					return true;
				}

				/// Mana heal.
				/// YOUR Soulsiphon refreshes YOU for 93 mana points.
				/// Testplayer's Power from Flesh critically refreshes Testplayer for 99 mana points.
				/// Testplayer's Power from Flesh refreshes Testplayer for 1 mana point.
				ThisMatch = m_CompiledRegexCache.Match(strParseLine, @"(?<actorability>.+?) (?<critically>critically |)refreshes (?<victim>.+) for (?<quantity>\d+) mana points?.$");
				if (ThisMatch.Success)
				{
					ActionEventArgs NewEvent = new ActionEventArgs(Timestamp, strParseLine);
					NewEvent.m_eActionType = ActionEventArgs.ActionType.PowerHeal;

					SplitActorAbilityPair(ThisMatch.Groups["actorability"].Value, ref NewEvent.m_strSource, ref NewEvent.m_strAbilityName);
					AssignActorName(ThisMatch.Groups["victim"].Value, ref NewEvent.m_strDestination);
					NewEvent.m_iQuantity = int.Parse(ThisMatch.Groups["quantity"].Value);
					AssignAttributeType(ThisMatch.Groups["critically"].Value, ref NewEvent.m_eAttributes);

					DispatchActionEvent(NewEvent);
					return true;
				}

				/// Mana drain. Type of attack used to do the drain is meaningless.
				/// YOUR Soulsiphon zaps Vin Moltor draining 331 points of power.
				/// Gale Monarch E'yildir slashes Testplayer draining 0 points of power.
				/// Testplayer's Vexing Verses confounds a deathless gazer draining 42 points of power.
				/// Testplayer is drained by Caustic Burns of 0 points of power.
				/// Testplayer is drained by Revived Sickness of 8966 points of power.
				/// Testplayer is drained by Revived Sickness of 9379 points of power.
				/// Testplayer is drained by Void Flames of 1777 points of power.
				ThisMatch = m_CompiledRegexCache.Match(strParseLine, @"(?<actorability>.+?) (crushes|pierces|slashes|burns|freezes|smites|zaps|confounds|diseases|poisons) (?<victim>.+) draining (?<quantity>\d+) points? of power.$");
				if (ThisMatch.Success)
				{
					ActionEventArgs NewEvent = new ActionEventArgs(Timestamp, strParseLine);
					NewEvent.m_eActionType = ActionEventArgs.ActionType.PowerDrain;

					SplitActorAbilityPair(ThisMatch.Groups["actorability"].Value, ref NewEvent.m_strSource, ref NewEvent.m_strAbilityName);
					AssignActorName(ThisMatch.Groups["victim"].Value, ref NewEvent.m_strDestination);
					NewEvent.m_iQuantity = int.Parse(ThisMatch.Groups["quantity"].Value);

					DispatchActionEvent(NewEvent);
					return true;
				}

				/// Your target's stoneskin absorbed 1,172 points of damage!
				/// Your stoneskin absorbed 986 points of damage!
				ThisMatch = m_CompiledRegexCache.Match(strParseLine, @"Your stoneskin absorbed (?<quantity>[\d,]+) points? of damage!$");
				if (ThisMatch.Success)
				{
					ActionEventArgs NewEvent = new ActionEventArgs(Timestamp, strParseLine);
					NewEvent.m_eActionType = ActionEventArgs.ActionType.Stoneskin;

					NewEvent.m_strDestination = m_strMyCharacterName;

					/// Remove the stupid commas. Dunno if I can have the regex do it for me.
					string strQuantity = ThisMatch.Groups["quantity"].Value.Replace(",", "");
					NewEvent.m_iQuantity = int.Parse(strQuantity);

					/// TODO: Not sure how I want to handle this yet.
					return true;
				}

				/// Failed abilities.
				/// Testplayer tries to slash Yitzik the Hurler with Swift Attack, but Yitzik the Hurler deflects.
				/// YOU try to crush a Fleshstripped bowman with Ambidexterous Casting, but miss.
				/// Death Pulse tries to freeze Testplayer with Corpse Explosion, but Testplayer resists.
				/// Death Pulse tries to freeze YOU with Corpse Explosion, but YOU resist.
				/// Anashti Sul tries to crush Testplayer, but Testplayer blocks the double attack.
				/// Anashti Sul tries to crush Testplayer, but Testplayer blocks.
				/// Anashti Sul tries to crush Testplayer, but Testplayer parries.
				/// Anashti Sul tries to crush Testplayer, but Testplayer ripostes.
				/// Anashti Sul tries to crush Testplayer, but Testplayer dodges.
				/// YOU try to crush a deathless gazer, but miss.
				/// YOU try to crush a deathless gazer, but YOUR double attack misses.
				/// YOU try to crush a deathless gazer, but a deathless gazer parries.
				/// YOU try to crush a deathless gazer, but a deathless gazer parries the double attack.
				/// YOU try to crush a cruor spirit, but a cruor spirit ripostes.
				/// YOU try to crush Yitzik the Hurler, but Yitzik the Hurler deflects.
				/// YOU try to crush Yitzik the Hurler, but Yitzik the Hurler deflects the double attack.
				/// Testplayer tries to slash a deathless gazer, but their double attack misses.
				/// Testplayer's unswerving hammer tries to crush a ykeshan patrol, but misses.
				ThisMatch = m_CompiledRegexCache.Match(strParseLine, @"(?<actor>.+?) (?:try|tries) to (?<damagetype>crush|pierce|slash|burn|freeze|smite|zap|confound|disease|poison) (?<victimability>.+?), but (?<response>.*).$");
				if (ThisMatch.Success)
				{
					ActionEventArgs NewEvent = new ActionEventArgs(Timestamp, strParseLine);

					/// Looking for the apostrophe is important for fucking weird cases like dumbfire pets missing swings.
					string strAbility = string.Empty;
					SplitActorAbilityPair(ThisMatch.Groups["actor"].Value, ref NewEvent.m_strSource, ref strAbility);

					AssignDamageType(ThisMatch.Groups["damagetype"].Value, ref NewEvent.m_eActionType);

					/// A mammoth Regex check would delay everything after it.
					/// So we broke off pieces to process only if the first half matched.
					string strVictimAbility = ThisMatch.Groups["victimability"].Value;
					string strResponse = ThisMatch.Groups["response"].Value;

					/// This is similar to what SplitActorAbilityPair does.
					if (strVictimAbility == "YOU")
						NewEvent.m_strDestination = m_strMyCharacterName;
					else if ((ThisMatch = m_CompiledRegexCache.Match(strVictimAbility, @"(?<victim>.+?) with (?<ability>.*|)")).Success)
					{
						AssignActorName(ThisMatch.Groups["victim"].Value, ref NewEvent.m_strDestination);
						NewEvent.m_strAbilityName = ThisMatch.Groups["ability"].Value;
					}
					else
					{
						NewEvent.m_strAbilityName = strAbility;
						NewEvent.m_strDestination = strVictimAbility;
					}

					ThisMatch = m_CompiledRegexCache.Match(strResponse, @"(.*?)(?<attacktype1>|aoe attack|double attack|) ?(?<counteraction>blocks|block|misses|miss|parry|parries|dodges|dodge|resists|resist|ripostes|riposte|deflects|deflect|reflects|reflect)(?: the )?(?<attacktype2>double attack|aoe attack|)$");
					if (ThisMatch.Success)
					{
						AssignAttributeType(ThisMatch.Groups["counteraction"].Value, ref NewEvent.m_eAttributes);

						switch (ThisMatch.Groups["attacktype1"].Value)
						{
							case "aoe attack": NewEvent.m_eAttributes |= ActionEventArgs.AttributeFlags.AOEAutoAttack; break;
							case "double attack": NewEvent.m_eAttributes |= ActionEventArgs.AttributeFlags.Double; break;
						}
						switch (ThisMatch.Groups["attacktype2"].Value)
						{
							case "aoe attack": NewEvent.m_eAttributes |= ActionEventArgs.AttributeFlags.AOEAutoAttack; break;
							case "double attack": NewEvent.m_eAttributes |= ActionEventArgs.AttributeFlags.Double; break;
						}

						DispatchActionEvent(NewEvent);
					}

					return true;
				}
			}

			/// Chat events are not even worth calling if no event callback is registered.
			if (ChatSent != null)
			{
				/// Someone else says something in a general predefined chat channel.
				/// \aNPC 30134 a roekillik watcher:a roekillik watcher\/a says, "Intruders!  Intruders!"
				/// \aNPC 6943344 Port to Raid Area:Port to Raid Area\/a says to you, "I am ready to serve the guild.  How may I be of assistance?"
				/// \aPC -1 Testplayer:Testplayer\/a says to the raid party, "how the hell did that happen"
				/// \aPC 46147 Testplayer:Testplayer\/a says to the group, "assist me on << roekillik excavation chief >>"
				/// \aPC 46147 Testplayer:Testplayer\/a says to the officers, "assist me on << roekillik excavation chief >>"
				/// \aPC 46147 Testplayer:Testplayer\/a says out of character, "assist me on << roekillik excavation chief >>"
				/// \aPC -1 Testplayer:Testplayer\/a tells you, "This had better work!!"
				/// \aPC 813717 Testplayer:Testplayer\/a shouts, "testing"
				ThisMatch = m_CompiledRegexCache.Match(strParseLine, @"\\a(?<actortype>NPC|PC) (?<actorid>-?\d+) (?<actor>.*):\3\\/a (?<channel>says to the guild|says to you|tells you|says to the raid party|says to the group|says to the officers|says out of character|says|shouts)(?: in |)(?<language>.*?|), ""(?<message>.*)""$");
				if (ThisMatch.Success)
				{
					ChatEventArgs NewEvent = new ChatEventArgs(Timestamp, strParseLine);

					string strActorType = ThisMatch.Groups["actortype"].Value;
					NewEvent.m_iSourceActorID = int.Parse(ThisMatch.Groups["actorid"].Value);
					NewEvent.m_strSourceActorName = ThisMatch.Groups["actor"].Value;
					AssignGameLanguageType(ThisMatch.Groups["language"].Value, ref NewEvent.m_eGameLanguage);

					string strChannelType = ThisMatch.Groups["channel"].Value;
					switch (strChannelType)
					{
						case "says to the guild": NewEvent.m_eChannelType = ChatEventArgs.ChannelType.Guild; break;
						case "says to you": NewEvent.m_eChannelType = ChatEventArgs.ChannelType.NonPlayerTell; break;
						case "tells you": NewEvent.m_eChannelType = ChatEventArgs.ChannelType.PlayerTell; break;
						case "says to the raid party": NewEvent.m_eChannelType = ChatEventArgs.ChannelType.Raid; break;
						case "says to the group": NewEvent.m_eChannelType = ChatEventArgs.ChannelType.Group; break;
						case "says to the officers": NewEvent.m_eChannelType = ChatEventArgs.ChannelType.Officer; break;
						case "says out of character": NewEvent.m_eChannelType = ChatEventArgs.ChannelType.OutOfCharacter; break;
						case "says":
						{
							if (strActorType == "NPC")
								NewEvent.m_eChannelType = ChatEventArgs.ChannelType.NonPlayerSay;
							else if (strActorType == "PC")
								NewEvent.m_eChannelType = ChatEventArgs.ChannelType.PlayerSay;
							break;
						}
						case "shouts": NewEvent.m_eChannelType = ChatEventArgs.ChannelType.Shout; break;
					}

					NewEvent.m_strMessage = ThisMatch.Groups["message"].Value;

					DispatchChatEvent(NewEvent);
					return true;
				}

				/// A player tell to a public channel.
				/// \aPC -1 Testplayer:Testplayer\/a tells Level_70-79 (8), "80 inq lf Kums"
				ThisMatch = m_CompiledRegexCache.Match(strParseLine, @"\\aPC (?<actorid>-?\d+) (?<actor>.+):\2\\/a tells (?<destination>\S*) ?\(\d+\), ""(?<message>.*)""$");
				if (ThisMatch.Success)
				{
					ChatEventArgs NewEvent = new ChatEventArgs(Timestamp, strParseLine);

					NewEvent.m_iSourceActorID = int.Parse(ThisMatch.Groups["actorid"].Value);
					NewEvent.m_strSourceActorName = ThisMatch.Groups["actor"].Value;
					NewEvent.m_strDestinationName = ThisMatch.Groups["destination"].Value;
					NewEvent.m_strMessage = ThisMatch.Groups["message"].Value;
					NewEvent.m_eGameLanguage = m_eGameLanguage;

					if (NewEvent.m_strDestinationName == "you")
					{
						NewEvent.m_eChannelType = ChatEventArgs.ChannelType.PlayerTell;
						NewEvent.m_strDestinationName = m_strMyCharacterName;
					}
					else
						NewEvent.m_eChannelType = ChatEventArgs.ChannelType.NamedChannel;

					ChatSent(this, NewEvent);
					return true;
				}

				/// You speak to a general predefined chat channel.
				ThisMatch = m_CompiledRegexCache.Match(strParseLine, @"You (?<type>say to the guild|say to the raid party|say to the group|say to the officers|say out of character|say|shout)(?: in |)(?<language>.*?|), ""(?<message>.*)""$");
				if (ThisMatch.Success)
				{
					ChatEventArgs NewEvent = new ChatEventArgs(Timestamp, strParseLine);
					NewEvent.m_strSourceActorName = m_strMyCharacterName;
					NewEvent.m_strMessage = ThisMatch.Groups["message"].Value;
					AssignGameLanguageType(ThisMatch.Groups["language"].Value, ref NewEvent.m_eGameLanguage);

					string strChannelType = ThisMatch.Groups["type"].Value;
					switch (strChannelType)
					{
						case "say to the guild": NewEvent.m_eChannelType = ChatEventArgs.ChannelType.Guild; break;
						case "say to the raid party": NewEvent.m_eChannelType = ChatEventArgs.ChannelType.Raid; break;
						case "say to the group": NewEvent.m_eChannelType = ChatEventArgs.ChannelType.Group; break;
						case "say to the officers": NewEvent.m_eChannelType = ChatEventArgs.ChannelType.Officer; break;
						case "say out of character": NewEvent.m_eChannelType = ChatEventArgs.ChannelType.OutOfCharacter; break;
						case "say": NewEvent.m_eChannelType = ChatEventArgs.ChannelType.PlayerSay; break;
						case "shout": NewEvent.m_eChannelType = ChatEventArgs.ChannelType.Shout; break;
					}

					DispatchChatEvent(NewEvent);
					return true;
				}

				/// You send a tell to a player or speak in a public channel.
				/// You tell Level_70-79 (8), "I wanna do an all-mage heroic group (1 healer) before this x-pack ends"
				/// You tell Yosho, "it's all good"
				ThisMatch = m_CompiledRegexCache.Match(strParseLine, @"You (?<type>tell|say to) (?<destination>\S*(?= \(\d+\))|\w*) ?(?<channelnumber>\((\d+)\))?, ""(?<message>.*)""$");
				if (ThisMatch.Success)
				{
					ChatEventArgs NewEvent = new ChatEventArgs(Timestamp, strParseLine);
					NewEvent.m_strSourceActorName = m_strMyCharacterName;

					string strTellType = ThisMatch.Groups["type"].Value;
					NewEvent.m_strDestinationName = ThisMatch.Groups["destination"].Value;
					string strChannelNumber = ThisMatch.Groups["channelnumber"].Value;
					NewEvent.m_strMessage = ThisMatch.Groups["message"].Value;

					if (strTellType == "tell")
					{
						/// If the channel number is present, then it's to a public channel.
						int iChannelNumber = -1;
						if (int.TryParse(strChannelNumber, out iChannelNumber))
							NewEvent.m_eChannelType = ChatEventArgs.ChannelType.NamedChannel;
						else
							NewEvent.m_eChannelType = ChatEventArgs.ChannelType.PlayerTell;
					}
					else
						NewEvent.m_eChannelType = ChatEventArgs.ChannelType.NonPlayerTell;

					DispatchChatEvent(NewEvent);
					return true;
				}
			}

			if (LineNotRecognized != null)
			{
				ConsoleLogEventArgs UnknownLogLineEvent = new ConsoleLogEventArgs(Timestamp, strParseLine);
				LineNotRecognized(this, UnknownLogLineEvent);
			}

			return false;
		}

		/************************************************************************************/
		public bool FeedLogFileLine(string strParseLine)
		{
			/// Grab the timestamp time_t value and the rest of the line, omitting the formatted date/time in brackets.
			/// Example line:
			/// (1253269431)[Fri Sep 18 05:23:51 2009] You have joined 'Level_10-19' (2)
			/// Gives you:
			/// 1253269431
			/// You have joined 'Level_10-19' (2)
			Match ThisMatch = m_CompiledRegexCache.Match(strParseLine, @"\((?<unixtime>\d+)\)\[.*?\] (?<line>.*)$");
			if (!ThisMatch.Success || ThisMatch.Groups.Count < 3)
				return false;

			long lUnixTime = -1;
			if (!long.TryParse(ThisMatch.Groups["unixtime"].Value, out lUnixTime))
				return false;

			DateTime TimeStamp = UnixTimeToDateTime(lUnixTime);

			return FeedLine(TimeStamp, ThisMatch.Groups["line"].Value);
		}

	}
}
