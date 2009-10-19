using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2ParseEngine
{
	/************************************************************************************/
	/// <summary>
	/// This event depicts any communication text, like tells or says.
	/// </summary>
	public class ChatEventArgs : ConsoleLogEventArgs, ICloneable
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

		public enum ChannelType : int
		{
			NonChat = 0,
			PlayerSay,
			NonPlayerSay,
			PlayerTell,
			NonPlayerTell,
			SelfNonPlayerTell, /// A specialized form of NonPlayerTell used in the T8 coercer epic questline.
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
			string strMessage)
			: base(Timestamp, strOriginalLine)
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
}
