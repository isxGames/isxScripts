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
		protected class VitalStatus
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

			protected readonly static Dictionary<string, ClassType> s_ClassStringToFlagMap = new Dictionary<string, ClassType>();

			static VitalStatus()
			{
				s_ClassStringToFlagMap.Add("guardian", ClassType.Guardian);
				s_ClassStringToFlagMap.Add("berserker", ClassType.Berserker);
				s_ClassStringToFlagMap.Add("paladin", ClassType.Paladin);
				s_ClassStringToFlagMap.Add("shadowknight", ClassType.Shadowknight);
				s_ClassStringToFlagMap.Add("monk", ClassType.Monk);
				s_ClassStringToFlagMap.Add("bruiser", ClassType.Bruiser);
				s_ClassStringToFlagMap.Add("templar", ClassType.Templar);
				s_ClassStringToFlagMap.Add("inquisitor", ClassType.Inquisitor);
				s_ClassStringToFlagMap.Add("mystic", ClassType.Mystic);
				s_ClassStringToFlagMap.Add("defiler", ClassType.Defiler);
				s_ClassStringToFlagMap.Add("warden", ClassType.Warden);
				s_ClassStringToFlagMap.Add("fury", ClassType.Fury);
				s_ClassStringToFlagMap.Add("ranger", ClassType.Ranger);
				s_ClassStringToFlagMap.Add("assassin", ClassType.Assassin);
				s_ClassStringToFlagMap.Add("swashbuckler", ClassType.Swashbuckler);
				s_ClassStringToFlagMap.Add("brigand", ClassType.Brigand);
				s_ClassStringToFlagMap.Add("troubador", ClassType.Troubador);
				s_ClassStringToFlagMap.Add("dirge", ClassType.Dirge);
				s_ClassStringToFlagMap.Add("wizard", ClassType.Wizard);
				s_ClassStringToFlagMap.Add("warlock", ClassType.Warlock);
				s_ClassStringToFlagMap.Add("conjuror", ClassType.Conjuror);
				s_ClassStringToFlagMap.Add("necromancer", ClassType.Necromancer);
				s_ClassStringToFlagMap.Add("illusionist", ClassType.Illusionist);
				s_ClassStringToFlagMap.Add("coercer", ClassType.Coercer);
				return;
			}

			public readonly bool m_bIsValid = false;
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
				m_bIsValid = SourceInfo.IsValid;
				if (m_bIsValid)
				{
					m_Actor = SourceInfo.ToActor();
					m_bIsValid = (m_bIsValid && m_Actor.IsValid);
				}
				if (m_bIsValid)
				{
					m_strName = SourceInfo.Name;
					m_eClass = s_ClassStringToFlagMap[m_Actor.Class];
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
				}
				return;
			}

			public VitalStatus(GroupMember SourceInfo)
			{
				m_bIsValid = SourceInfo.IsValid;
				if (m_bIsValid)
				{
					m_Actor = SourceInfo.ToActor();
					m_bIsValid = (m_bIsValid && m_Actor.IsValid);
				}
				if (m_bIsValid)
				{
					m_strName = SourceInfo.Name;
					m_eClass = s_ClassStringToFlagMap[m_Actor.Class];
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
				}
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

			public double HealthRatio
			{
				get
				{
					return (double)m_iCurrentHealth / (double)m_iMaximumHealth;
				}
			}

			public double PowerRatio
			{
				get
				{
					return (double)m_iCurrentPower / (double)m_iMaximumPower;
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
		private Dictionary<string, VitalStatus> m_VitalStatusCache = new Dictionary<string, VitalStatus>();

		/************************************************************************************/
		protected bool GetVitalStatus(string strFriendName, ref VitalStatus ThisStatus)
		{
			try
			{
				if (!m_VitalStatusCache.TryGetValue(strFriendName, out ThisStatus))
				{
					GroupMember TempGroupMember = null;
					if (strFriendName == Me.Name)
					{
						ThisStatus = new VitalStatus(Me);
						m_VitalStatusCache.Add(strFriendName, ThisStatus);
					}
					else if (m_FriendDictionary.TryGetValue(strFriendName, out TempGroupMember))
					{
						ThisStatus = new VitalStatus(TempGroupMember);
						m_VitalStatusCache.Add(strFriendName, ThisStatus);
					}
					else
						return false;
				}

				if (ThisStatus.m_bIsValid)
					return true;
			}
			catch
			{
				Program.Log("Exception thrown while attempting to look up vital status info for {0}.", strFriendName);
			}
			return false;
		}

		/************************************************************************************/
		protected IEnumerable<VitalStatus> EnumVitalStatuses(bool bIncludeMainTank)
		{
			VitalStatus ThisStatus = null;

			if (bIncludeMainTank && GetVitalStatus(m_strCurrentMainTank, ref ThisStatus))
				yield return ThisStatus;

			foreach (string strThisMemberName in m_GroupMemberDictionary.Keys)
			{
				/// Omit everyone we already cycled through.
				if (strThisMemberName != m_strCurrentMainTank)
				{
					if (GetVitalStatus(strThisMemberName, ref ThisStatus))
						yield return ThisStatus;
				}
			}
		}
	}
}
