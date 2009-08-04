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
		/************************************************************************************/
		/// <summary>
		/// It's difficult for healer logic when Character and GroupMember separately hold 
		/// vital information depending if it's the bot player or not.
		/// This unites the two for clean logic.
		/// </summary>
		public class VitalStatus
		{
			[Flags]
			public enum ClassType
			{
				None = 0,

				Guardian = 0x1,
				Berserker = 0x2,
				Paladin = 0x4,
				Shadowknight = 0x8,
				Monk = 0x10,
				Bruiser = 0x20,
				Templar = 0x40,
				Inquisitor = 0x80,
				Mystic = 0x100,
				Defiler = 0x200,
				Warden = 0x400,
				Fury = 0x800,
				Ranger = 0x1000,
				Assassin = 0x2000,
				Swashbuckler = 0x4000,
				Brigand = 0x8000,
				Troubador = 0x10000,
				Dirge = 0x20000,
				Wizard = 0x40000,
				Warlock = 0x80000,
				Conjuror = 0x100000,
				Necromancer = 0x200000,
				Illusionist = 0x400000,
				Coercer = 0x800000,

				Warrior = Guardian | Berserker,
				Crusader = Paladin | Shadowknight,
				Brawler = Monk | Bruiser,
				Cleric = Templar | Inquisitor,
				Shaman = Mystic | Defiler,
				Druid = Warden | Fury,
				Predator = Ranger | Assassin,
				Rogue = Swashbuckler | Brigand,
				Bard = Troubador | Dirge,
				Sorceror = Wizard | Warlock,
				Summoner = Conjuror | Necromancer,
				Enchanter = Illusionist | Coercer,

				Fighter = Warrior | Crusader | Brawler,
				Priest = Cleric | Shaman | Druid,
				Scout = Predator | Rogue | Bard,
				Mage = Sorceror | Summoner | Enchanter,
			}

			protected static Dictionary<string, ClassType> m_ClassStringToFlagMap = new Dictionary<string, ClassType>();

			static VitalStatus()
			{
				m_ClassStringToFlagMap.Add("guardian", ClassType.Guardian);
				m_ClassStringToFlagMap.Add("berserker", ClassType.Berserker);
				m_ClassStringToFlagMap.Add("paladin", ClassType.Paladin);
				m_ClassStringToFlagMap.Add("shadowknight", ClassType.Shadowknight);
				m_ClassStringToFlagMap.Add("monk", ClassType.Monk);
				m_ClassStringToFlagMap.Add("bruiser", ClassType.Bruiser);
				m_ClassStringToFlagMap.Add("templar", ClassType.Templar);
				m_ClassStringToFlagMap.Add("inquisitor", ClassType.Inquisitor);
				m_ClassStringToFlagMap.Add("mystic", ClassType.Mystic);
				m_ClassStringToFlagMap.Add("defiler", ClassType.Defiler);
				m_ClassStringToFlagMap.Add("warden", ClassType.Warden);
				m_ClassStringToFlagMap.Add("fury", ClassType.Fury);
				m_ClassStringToFlagMap.Add("ranger", ClassType.Ranger);
				m_ClassStringToFlagMap.Add("assassin", ClassType.Assassin);
				m_ClassStringToFlagMap.Add("swashbuckler", ClassType.Swashbuckler);
				m_ClassStringToFlagMap.Add("brigand", ClassType.Brigand);
				m_ClassStringToFlagMap.Add("troubador", ClassType.Troubador);
				m_ClassStringToFlagMap.Add("dirge", ClassType.Dirge);
				m_ClassStringToFlagMap.Add("wizard", ClassType.Wizard);
				m_ClassStringToFlagMap.Add("warlock", ClassType.Warlock);
				m_ClassStringToFlagMap.Add("conjuror", ClassType.Conjuror);
				m_ClassStringToFlagMap.Add("necromancer", ClassType.Necromancer);
				m_ClassStringToFlagMap.Add("illusionist", ClassType.Illusionist);
				m_ClassStringToFlagMap.Add("coercer", ClassType.Coercer);
				return;
			}

			public readonly string m_strName = string.Empty;
			public readonly ClassType m_eClass = ClassType.None;
			public readonly bool m_bIsDead = false;
			public readonly int m_iTrauma = 0;
			public readonly int m_iArcane = 0;
			public readonly int m_iNoxious = 0;
			public readonly int m_iElemental = 0;
			public readonly int m_iCursed = 0;
			public readonly int m_iCurrentHealth = 0;
			public readonly int m_iMaximumHealth = 0;
			public readonly int m_iCurrentPower = 0;
			public readonly int m_iMaximumPower = 0;
			public readonly bool m_bInZone = true; /// Not used yet.
			public readonly Actor m_Actor = null;

			public VitalStatus(Character SourceInfo)
			{
				m_Actor = SourceInfo.ToActor();
				m_strName = SourceInfo.Name;
				m_eClass = m_ClassStringToFlagMap[m_Actor.Class];
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
				m_eClass = m_ClassStringToFlagMap[m_Actor.Class];
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

			public bool IsPriest
			{
				get
				{
					return ((m_eClass & ClassType.Priest) != 0);
				}
			}
		}

		/************************************************************************************/
		public bool GetVitalStatus(Character SourceInfo, ref VitalStatus ThisStatus)
		{
			try
			{
				ThisStatus = new VitalStatus(SourceInfo);
				if (!ThisStatus.m_Actor.IsValid)
					return false;
				return true;
			}
			catch
			{
				Program.Log("Exception thrown while attempting to look up Character vital status info.");
				return false;
			}
		}

		/************************************************************************************/
		public bool GetVitalStatus(GroupMember SourceInfo, ref VitalStatus ThisStatus)
		{
			try
			{
				ThisStatus = new VitalStatus(SourceInfo);
				if (!ThisStatus.m_Actor.IsValid)
					return false;
				return true;
			}
			catch
			{
				Program.Log("Exception thrown while attempting to look up GroupMember vital status info.");
				return false;
			}
		}

		/************************************************************************************/
		public IEnumerable<VitalStatus> EnumVitalStatuses(bool bIncludeMainTank)
		{
			VitalStatus ThisStatus = null;

			if (bIncludeMainTank && m_FriendDictionary.ContainsKey(m_strMainTank))
			{
				GroupMember ThisMember = m_FriendDictionary[m_strMainTank];
				if (GetVitalStatus(ThisMember, ref ThisStatus))
					yield return ThisStatus;
			}

			if (GetVitalStatus(Me, ref ThisStatus))
				yield return ThisStatus;

			foreach (GroupMember ThisMember in m_GroupMemberDictionary.Values)
			{
				/// Omit everyone we already cycled through.
				if ((ThisMember.Name != Me.Name) && (ThisMember.Name != m_strMainTank))
				{
					if (GetVitalStatus(ThisMember, ref ThisStatus))
						yield return ThisStatus;
				}
			}
		}
	}
}
