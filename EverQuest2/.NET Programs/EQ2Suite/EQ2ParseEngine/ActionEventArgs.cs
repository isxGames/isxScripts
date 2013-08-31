using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2ParseEngine
{
	/************************************************************************************/
	public class ActionEventArgs : ConsoleLogEventArgs, ICloneable
	{
		public enum ActionType : int
		{
			Unknown = 0,
			Cure,
			Dispel,
			Threat,
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

		internal const AttributeFlags FAILED_ATTRIBUTES =
			AttributeFlags.Blocked |
			AttributeFlags.Deflected |
			AttributeFlags.Dodged |
			AttributeFlags.Missed |
			AttributeFlags.Resisted |
			AttributeFlags.Riposted |
			AttributeFlags.Reflected;

		public bool FailedAttempt
		{
			get
			{
				return ((m_eAttributes & FAILED_ATTRIBUTES) != 0);
			}
		}

		public ActionEventArgs(DateTime Timestamp, string strParseLine)
			: base(Timestamp, strParseLine)
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
}
