using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using EQ2.ISXEQ2;
using EQ2SuiteLib;

namespace EQ2GlassCannon
{
	public partial class PlayerController
	{
		/************************************************************************************/
		protected class CachedAbility
		{
			private Ability m_OriginalAbility = null;

			public enum TargetType : int
			{
				Unknown0 = 0,
				Unknown1 = 1,
				Group = 2,
				Unknown3 = 3,
			}

			public readonly uint m_uiID = 0;
			public readonly string m_strName = string.Empty;
			public readonly bool m_bIsValid = false;
			public readonly bool m_bIsReady = false;
			public readonly bool m_bIsQueued = false;
			public readonly float m_fTimeUntilReady = 0.0f;
			public readonly float m_fCastTimeSeconds = 0.0f;
			public readonly float m_fRecoveryTimeSeconds = 0.0f;
			public readonly int m_iHealthCost = 0;
			public readonly int m_iPowerCost = 0;
			public readonly int m_iConcentrationCost = 0;
			public readonly float m_fRange = 0.0f;
			public readonly float m_fMinRange = 0.0f;
			public readonly float m_fMaxRange = 0.0f;
			public readonly float m_fEffectRadius = 0.0f;
			public readonly int m_iMaxAOETargets = 1;
			public readonly bool m_bAllowRaid = false;
			public readonly TargetType m_eTargetType = TargetType.Unknown0;

			public CachedAbility(Ability ThisAbility)
			{
				m_bIsValid = ThisAbility.IsValid;

				if (m_bIsValid)
				{
					m_OriginalAbility = ThisAbility;
					m_uiID = ThisAbility.ID;
					m_strName = ThisAbility.Name;
					m_bIsReady = ThisAbility.IsReady;
					m_bIsQueued = ThisAbility.IsQueued;
					m_fTimeUntilReady = ThisAbility.TimeUntilReady;
					m_fCastTimeSeconds = ThisAbility.CastingTime;
					m_fRecoveryTimeSeconds = ThisAbility.RecoveryTime;
					m_iHealthCost = ThisAbility.HealthCost;
					m_iPowerCost = ThisAbility.PowerCost;
					m_iConcentrationCost = ThisAbility.ConcentrationCost;
					m_fRange = ThisAbility.Range;
					m_fMinRange = ThisAbility.MinRange;
					m_fMaxRange = ThisAbility.MaxRange;
					m_fEffectRadius = ThisAbility.EffectRadius;
					m_iMaxAOETargets = ThisAbility.MaxAOETargets;
					m_bAllowRaid = ThisAbility.AllowRaid;
					m_eTargetType = (TargetType)ThisAbility.TargetType;
				}
				return;
			}

			/// <summary>
			/// Cast time + recovery time.
			/// </summary>
			public TimeSpan TotalCastTimeSpan
			{
				get
				{
					return TimeSpan.FromSeconds(m_fCastTimeSeconds + m_fRecoveryTimeSeconds);
				}
			}

			public bool Use()
			{
				if (m_bIsQueued)
				{
					Program.Log("{0} is already queued for casting.", m_strName);
					return true;
				}

				Program.Log("Casting \"{0}\" ({1})...", m_strName, m_uiID);
				RunCommand("/useability {0}", m_uiID);
				return true;
			}

			public bool Use(string strPlayerTarget)
			{
				if (m_bIsQueued)
				{
					Program.Log("{0} is already queued for casting.", m_strName);
					return true;
				}

				Program.Log("Casting \"{0}\" ({1}) on {2}...", m_strName, m_uiID, strPlayerTarget);
				RunCommand("/useabilityonplayer {0} {1}", strPlayerTarget, m_uiID);
				return true;
			}

			public bool IsWithinRange(double fDistance)
			{
				return (m_fMinRange <= fDistance && fDistance <= m_fMaxRange);
			}
		}

		/************************************************************************************/
		protected class MaintainedTargetIDKey : IComparable<MaintainedTargetIDKey>
		{
			private readonly string m_strMaintainedName = string.Empty;
			private readonly int m_iTargetActorID = -1;

			public MaintainedTargetIDKey(string strMaintainedName, int iActorID)
			{
				m_strMaintainedName = strMaintainedName;
				m_iTargetActorID = iActorID;
				return;
			}

			public int CompareTo(MaintainedTargetIDKey OtherKey)
			{
				int iCompareValue = 0;

				iCompareValue = m_strMaintainedName.CompareTo(OtherKey.m_strMaintainedName);
				if (iCompareValue != 0)
					return iCompareValue;

				return m_iTargetActorID.CompareTo(OtherKey.m_iTargetActorID);
			}
		}

		/// <summary>
		/// This dictionary has only one entry per spell regardless of how many targets the spell is actually on,
		/// but allows immediate O(1) boolean detection of any maintained effect.
		/// This is repopulated on every new frame.
		/// </summary>
		private Dictionary<string, int> m_MaintainedNameToIndexMap = new Dictionary<string, int>();

		private SortedDictionary<MaintainedTargetIDKey, Maintained> m_MaintainedTargetNameDictionary = new SortedDictionary<MaintainedTargetIDKey, Maintained>();
		private Dictionary<string, int> m_BeneficialEffectNameToIndexMap = new Dictionary<string, int>();

		protected bool m_bAutoHarvestInProgress = false;
		protected DateTime m_LastAutoHarvestAttemptTime = DateTime.FromBinary(0);
		protected DateTime m_NextAutoLootAttemptTime = DateTime.Now;
		protected DateTime m_LastCastStartTime = DateTime.Now;
		protected DateTime m_LastCastEndTime = DateTime.Now;

		/************************************************************************************/
		private Dictionary<uint, CachedAbility> m_AbilityCache = new Dictionary<uint, CachedAbility>();

		/// <summary>
		/// Within a frame lock, encounter/PBAE attempts might be called multiple times for the same spell.
		/// This cache prevents the need for redundant range detection on all NPC's within the blast radius,
		/// which can conceivably be taxing on CPU usage.
		/// </summary>
		private Dictionary<uint, int> m_AbilityCompatibleTargetCountCache = new Dictionary<uint, int>();

		/************************************************************************************/
		/// <summary>
		/// While seeing ISXEQ2 crash lately I realized the inefficiency of the layer,
		/// which (a) has the capacity of throwing an exception on ability property access,
		/// and (b) saves everything internally as strings.
		/// To combat this, I have built a frame-local cache which saves binary values.
		/// </summary>
		/// <param name="iAbilityID"></param>
		/// <param name="bFailIfNotReady"></param>
		/// <returns></returns>
		protected CachedAbility GetAbility(uint uiAbilityID, bool bFailIfNotReady)
		{
			if (uiAbilityID < 1)
				return null;

			CachedAbility ThisCachedAbility = null;

			if (m_AbilityCache.ContainsKey(uiAbilityID))
				ThisCachedAbility = m_AbilityCache[uiAbilityID];
			else
			{
				try
				{
					Ability ThisAbility = Me.AbilityByID(uiAbilityID);
					ThisCachedAbility = new CachedAbility(ThisAbility);
					m_AbilityCache.Add(uiAbilityID, ThisCachedAbility);
				}
				catch
				{
					Program.Log("Exception thrown while attempting to look up ability info for \"{0}\" ({1}).", m_KnowledgeBookIDToNameMap[uiAbilityID], uiAbilityID);
					return null;
				}
			}

			if (!ThisCachedAbility.m_bIsValid)
			{
				Program.Log("Spell #{0} not valid.", uiAbilityID);
				return null;
			}

			if (bFailIfNotReady && !ThisCachedAbility.m_bIsReady)
			{
				return null;
			}

			return ThisCachedAbility;
		}

		/************************************************************************************/
		protected void StartCastTimers(CachedAbility ThisAbility)
		{
			DateTime StartTime = CurrentCycleTimestamp;
			m_LastCastStartTime = StartTime;
			m_LastCastEndTime = StartTime + TimeSpan.FromSeconds(ThisAbility.m_fCastTimeSeconds + ThisAbility.m_fRecoveryTimeSeconds);
			return;
		}

		/************************************************************************************/
		protected void StartCastTimers(Item ThisItem)
		{
			try
			{
				DateTime StartTime = CurrentCycleTimestamp;
				DateTime EndTime = StartTime + TimeSpan.FromSeconds(ThisItem.CastingTime + ThisItem.RecoveryTime);

				/// If no exception (Item.CastingTime or Item.RecoveryTime) has happened by this point, then continue.
				m_LastCastStartTime = StartTime;
				m_LastCastEndTime = EndTime;
			}
			catch
			{
				Program.Log("Exception thrown when referencing Item.CastingTime or Item.RecoveryTime.");
			}
			return;
		}

		/************************************************************************************/
		protected void CancelCast()
		{
			m_LastCastEndTime = CurrentCycleTimestamp;
			RunCommand("/cancel_spellcast");
			return;
		}

		/************************************************************************************/
		private TimeSpan m_CastTimeRemaining = TimeSpan.FromTicks(0);
		protected TimeSpan CastTimeRemaining
		{
			get
			{
				/// This gets reassigned at the start of DoNextAction().
				return m_CastTimeRemaining;
			}
		}

		/************************************************************************************/
		protected bool IsCasting
		{
			get
			{
				return s_bIsCastingAbility || (CurrentCycleTimestamp < m_LastCastEndTime);
			}
		}

		/************************************************************************************/
		protected bool UseInventoryItem(
			string strItemName,
			bool bMustBeEquipped,
			bool bMustNotBeEquipped,
			bool bMustTargetEnemy,
			bool bMustTargetFriend)
		{
			try
			{
				if (IsCasting)
					return false;

				Item ThisItem = null;

				if (bMustBeEquipped)
					ThisItem = Me.Equipment("ExactName", strItemName);
				else if (bMustNotBeEquipped)
					ThisItem = Me.Inventory("ExactName", strItemName);
				else
				{
					ThisItem = Me.Inventory("ExactName", strItemName);
					if (!ThisItem.IsValid)
						ThisItem = Me.Equipment("ExactName", strItemName);
				}

				if (!ThisItem.IsValid || !ThisItem.IsReady || !ThisItem.IsActivatable)
					return false;

				if (bMustTargetEnemy || bMustTargetFriend)
				{
					Actor TargetActor = MeActor.Target();
					if (!TargetActor.IsValid)
						return false;

					string strType = TargetActor.Type;
					if (bMustTargetEnemy && !(strType == "NPC" || strType == STR_NAMED_NPC))
						return false;
					if (bMustTargetFriend && !(strType == "PC" || strType == "Pet" || strType == "MyPet"))
						return false;

					/// Test range.
					double fDistance = TargetActor.Distance;
					if (fDistance < ThisItem.MinRange || ThisItem.MaxRange < fDistance)
					{
						Program.Log("Unable to use {0} because {1} is out of range ({2}-{3} needed, {4:0.00} actual)",
							ThisItem.Name, TargetActor.Name, ThisItem.MinRange, ThisItem.MaxRange, fDistance);
						return false;
					}
				}

				Program.Log("Attempting to use clicky item \"{0}\" ({1})...", ThisItem.Name, ThisItem.LinkID);
				StartCastTimers(ThisItem);
				RunCommand("/use_itemvdl {0}", ThisItem.LinkID);
				return true;
			}
			catch
			{
				Program.Log("Exception thrown when attempting to use item \"{0}\".", strItemName);
				return false;
			}
		}

		/************************************************************************************/
		protected bool UseInventoryItem(CustomRegenItem ThisItem)
		{
			return UseInventoryItem(
				ThisItem.m_strName,
				ThisItem.m_bMustBeEquipped,
				ThisItem.m_bMustNotBeEquipped,
				ThisItem.m_bMustTargetEnemy,
				ThisItem.m_bMustTargetFriend);
		}

		/************************************************************************************/
		protected bool UseInventoryItem(string strItemName)
		{
			return UseInventoryItem(strItemName, false, false, false, false);
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		/// <param name="iAbilityID"></param>
		/// <returns>true if spell exists, is usable, AND can be afforded; false otherwise.</returns>
		protected bool CanAffordAbilityCost(uint uiAbilityID)
		{
			CachedAbility ThisAbility = GetAbility(uiAbilityID, true);
			if (ThisAbility == null)
				return false;

			if (ThisAbility.m_iPowerCost > Me.Power)
			{
				Program.Log("Not enough power to cast {0}!", ThisAbility.m_strName);
				return false;
			}

			/// I first check against zero to dodge the Character class value lookup.
			/// Most abilities have no health cost and for them this check is a waste of CPU.
			if (ThisAbility.m_iHealthCost > 0)
			{
				if (ThisAbility.m_iHealthCost > Me.Health)
				{
					Program.Log("Not enough health to cast {0}!", ThisAbility.m_strName);
					return false;
				}
			}

			/// I first check against zero to dodge the Character class value lookup because most
			/// abilities have no concentration cost and for them this check is a waste of CPU.
			/// NOTE: I had to comment this out for now because Mana Flow incorrectly reports a conc cost of 1.
			/// Other spells are reporting bogus costs too.
			/*if (ThisAbility.m_iConcentrationCost > 0)
			{
				int iFreeSlots = (Me.MaxConc - Me.UsedConc);
				if (ThisAbility.m_iConcentrationCost > iFreeSlots)
				{
					Program.Log("Not enough concentration slots to cast {0}! It requires {1} free slot(s) but you have {2}.", ThisAbility.m_strName, ThisAbility.m_iConcentrationCost, iFreeSlots);
					return false;
				}
			}*/

			return true;
		}

		/************************************************************************************/
		protected string GetFirstExistingBeneficialAbilityCandidate(uint uiAbilityID, List<string> astrCandidates)
		{
			CachedAbility ThisAbility = GetAbility(uiAbilityID, false);
			if (ThisAbility == null)
				return string.Empty;

			return GetFirstExistingPartyMember(astrCandidates, !ThisAbility.m_bAllowRaid);
		}

		/************************************************************************************/
		/// <summary>
		/// Casts an action on an arbitrary player target.
		/// Preferred for all beneficial casts.
		/// </summary>
		protected bool CastAbility(uint uiAbilityID, string strPlayerTarget, bool bMustBeAlive)
		{
			if (string.IsNullOrEmpty(strPlayerTarget))
				return false;

			CachedAbility ThisAbility = GetAbility(uiAbilityID, true);
			if (ThisAbility == null)
				return false;

			Actor SpellTargetActor = null;
			GroupMember TempGroupMember = null;
			if (m_FriendDictionary.TryGetValue(strPlayerTarget, out TempGroupMember))
				SpellTargetActor = TempGroupMember.ToActor();
			else if (strPlayerTarget == Name)
				SpellTargetActor = MeActor;
			else
				SpellTargetActor = GetActor(strPlayerTarget);

			if (SpellTargetActor == null || !SpellTargetActor.IsValid)
			{
				Program.Log("Target actor {0} not valid to receive \"{1}\".", strPlayerTarget, ThisAbility.m_strName);
				return false;
			}

			if (bMustBeAlive && SpellTargetActor.IsDead)
				return false;

			double fDistance = SpellTargetActor.Distance;
			if (fDistance > ThisAbility.m_fRange)
			{
				Program.Log("Unable to cast \"{0}\" because {1} is out of range ({2} needed, {3:0.00} actual)",
					ThisAbility.m_strName, SpellTargetActor.Name, ThisAbility.m_fRange, fDistance);
				return false;
			}

			if (!CanAffordAbilityCost(uiAbilityID))
				return false;

			StartCastTimers(ThisAbility);
			return ThisAbility.Use(strPlayerTarget);
		}

		/************************************************************************************/
		/// <summary>
		/// Casts the ability on the first player it finds from the list who exists in the group or raid party.
		/// Preferred for beneficial casts.
		/// </summary>
		protected bool CastAbility(uint uiAbilityID, List<string> astrCandidates, bool bMustBeAlive)
		{
			string strPlayer = GetFirstExistingBeneficialAbilityCandidate(uiAbilityID, astrCandidates);
			if (string.IsNullOrEmpty(strPlayer))
				return false;

			return CastAbility(uiAbilityID, strPlayer, bMustBeAlive);
		}

		/************************************************************************************/
		protected bool CastAbilityOnSelf(uint uiAbilityID)
		{
			return CastAbility(uiAbilityID, Name, true);
		}

		/************************************************************************************/
		/// <summary>
		/// Casts a general ability, on the player's current target if applicable.
		/// The caller passes the start/end arc points in clockwise order.
		/// </summary>
		protected bool CastAbility(
			uint uiAbilityID,
			double fVulnerableRelativeHeadingRangeStart,
			double fVulnerableRelativeHeadingRangeEnd,
			bool bOverwriteExistingCastTimer)
		{
			CachedAbility ThisAbility = GetAbility(uiAbilityID, true);
			if (ThisAbility == null)
				return false;

			Actor MyTargetActor = MeActor.Target();
			if (MyTargetActor.IsValid)
			{
				/// Test range.
				double fDistance = GetActorDistance3D(MeActor, MyTargetActor);
				if (!ThisAbility.IsWithinRange(fDistance))
				{
					Program.Log("Unable to cast \"{0}\" because {1} is out of range ({2}-{3} needed, {4:0.00} actual)",
						ThisAbility.m_strName, MyTargetActor.Name, ThisAbility.m_fMinRange, ThisAbility.m_fMaxRange, fDistance);
					return false;
				}

				/// Test directional attack.
				/// An unlimited attack vector is from 0 to 360 thus nullifying a need for a check.
				if (fVulnerableRelativeHeadingRangeStart > 0.0 || fVulnerableRelativeHeadingRangeEnd < 360.0)
				{
					double fRelativeHeadingFrom = GetRelativeHeadingFrom(MyTargetActor);

					bool bSuccess = true;
					if (fVulnerableRelativeHeadingRangeStart < fVulnerableRelativeHeadingRangeEnd)
					{
						/// NOTE: This is the normal condition.
						bSuccess = (fVulnerableRelativeHeadingRangeStart <= fRelativeHeadingFrom && fRelativeHeadingFrom <= fVulnerableRelativeHeadingRangeEnd);
					}
					else
					{
						/// NOTE: For frontal-only attacks (non-existant yet), a range of 270 start to 90 end is valid.
						bSuccess = (fVulnerableRelativeHeadingRangeEnd > fRelativeHeadingFrom || fRelativeHeadingFrom > fVulnerableRelativeHeadingRangeStart);
					}
					if (!bSuccess)
					{
						Program.Log("Unable to cast \"{0}\" because you are on the wrong attack heading ({2:0} to {3:0} degrees needed, {4:0.00} actual).",
							ThisAbility.m_strName, MyTargetActor.Name, fVulnerableRelativeHeadingRangeStart, fVulnerableRelativeHeadingRangeEnd, fRelativeHeadingFrom);
						return false;
					}
				}
			}

			if (!CanAffordAbilityCost(uiAbilityID))
				return false;

			if (bOverwriteExistingCastTimer)
				StartCastTimers(ThisAbility);
			return ThisAbility.Use();
		}

		/************************************************************************************/
		protected bool CastAbility(uint uiAbilityID)
		{
			return CastAbility(uiAbilityID, 0.0, 360.0, true);
		}

		/************************************************************************************/
		protected bool CastSimultaneousAbility(uint uiAbilityID)
		{
			return CastAbility(uiAbilityID, 0.0, 360.0, false);
		}

		/************************************************************************************/
		protected bool CastAbilityFromBehind(uint uiAbilityID)
		{
			return CastAbility(uiAbilityID, 120.0, 240.0, true);
		}

		/************************************************************************************/
		/// <summary>
		/// "Flanking or behind" means everything but the 120-degree arc in front.
		/// </summary>
		/// <param name="iAbilityID"></param>
		/// <returns></returns>
		protected bool CastAbilityFromFlankingOrBehind(uint uiAbilityID)
		{
			return CastAbility(uiAbilityID, 60.0, 300.0, true);
		}

		/************************************************************************************/
		/// <summary>
		/// Not all PBAE-like abilities have an official radius,
		/// so allowing this function to be exposed allows derived classes to pretend that a radius does exist,
		/// also caching the value.
		/// </summary>
		protected int GetBlueOffensiveAbilityCompatibleTargetCount(uint uiAbilityID, double fRadiusOverride)
		{
			int iValidVictimCount = 0;
			if (!m_AbilityCompatibleTargetCountCache.TryGetValue(uiAbilityID, out iValidVictimCount) && m_bUseBlueAEs)
			{
				foreach (Actor ThisActor in m_KillableActorDictionary.Values)
				{
					if (ThisActor.Distance > fRadiusOverride)
						continue;

					/// Total fudging here.  I'm basically trying to clip off upstairs and downstairs.
					double fLowY = MeActor.Y - 5;
					double fHighY = MeActor.Y + (fRadiusOverride / 2);
					if (ThisActor.Y < fLowY || fHighY < ThisActor.Y)
						continue;

					iValidVictimCount++;
				}
				m_AbilityCompatibleTargetCountCache.Add(uiAbilityID, iValidVictimCount);
			}
			return iValidVictimCount;
		}

		/************************************************************************************/
		protected int GetBlueOffensiveAbilityCompatibleTargetCount(uint uiAbilityID)
		{
			CachedAbility ThisAbility = GetAbility(uiAbilityID, true);
			if (ThisAbility == null)
				return 0;

			return GetBlueOffensiveAbilityCompatibleTargetCount(uiAbilityID, ThisAbility.m_fEffectRadius);
		}

		/************************************************************************************/
		protected bool CastBlueOffensiveAbility(uint uiAbilityID, int iMinimumVictimCheckCount)
		{
			if (!m_bUseBlueAEs)
				return false;

			CachedAbility ThisAbility = GetAbility(uiAbilityID, true);
			if (ThisAbility == null)
				return false;

			/// Check that the minimum number of potential victims is within the blast radius before proceeding.
			int iValidVictimCount = GetBlueOffensiveAbilityCompatibleTargetCount(uiAbilityID);
			if (iValidVictimCount < iMinimumVictimCheckCount)
				return false;

			if (!CanAffordAbilityCost(uiAbilityID))
				return false;

			Program.Log("\"{0}\" approved against {1} possible PBAE target(s) within {2:0}m radius.", ThisAbility.m_strName, iValidVictimCount, ThisAbility.m_fEffectRadius);
			StartCastTimers(ThisAbility);
			return ThisAbility.Use();
		}

		/************************************************************************************/
		/// <summary>
		/// </summary>
		protected bool CastGreenOffensiveAbility(uint uiAbilityID, int iMinimumVictimCheckCount)
		{
			if (!m_bUseGreenAEs || m_OffensiveTargetActor == null)
				return false;

			/// I'm tempted to pre-filter based on Actor.EncounterSize but I don't trust that value.

			CachedAbility ThisAbility = GetAbility(uiAbilityID, true);
			if (ThisAbility == null)
				return false;

			int iValidVictimCount = 0;
			if (!m_AbilityCompatibleTargetCountCache.TryGetValue(uiAbilityID, out iValidVictimCount))
			{
				double fDistance = GetActorDistance3D(MeActor, m_OffensiveTargetActor);
				if (ThisAbility.IsWithinRange(fDistance))
				{
					foreach (Actor ThisActor in m_OffensiveTargetEncounterActorDictionary.Values)
					{
						double fThisDistance = GetActorDistance3D(m_OffensiveTargetActor, ThisActor);
						if (fThisDistance < ThisAbility.m_fEffectRadius)
							iValidVictimCount++;
					}
				}
				else
				{
					Program.Log("Unable to cast \"{0}\" because {1} is out of range ({2}-{3} needed, {4:0.00} actual)",
						ThisAbility.m_strName, m_OffensiveTargetActor.Name, ThisAbility.m_fMinRange, ThisAbility.m_fMaxRange, fDistance);
				}

				m_AbilityCompatibleTargetCountCache.Add(uiAbilityID, iValidVictimCount);
			}

			/// Check that the minimum number of potential victims is within the blast radius before proceeding.
			if (iValidVictimCount < iMinimumVictimCheckCount)
				return false;

			if (!CanAffordAbilityCost(uiAbilityID))
				return false;

			Program.Log("\"{0}\" approved against {1} possible encounter target(s) within {2:0}m radius.", ThisAbility.m_strName, iValidVictimCount, ThisAbility.m_fMaxRange);
			StartCastTimers(ThisAbility);
			return ThisAbility.Use();
		}

		/************************************************************************************/
		/// <summary>
		/// Casts the HO starter if the wheel isn't up.
		/// </summary>
		protected bool CastHOStarter()
		{
			try
			{
				return false;
				//return (m_bSpamHeroicOpportunity && (Me.IsHated && MeActor.InCombatMode) && !EQ2.HOWindowActive && CastAbilityOnSelf(m_iHOStarterAbiltyID));
			}
			catch
			{
				/// Referencing EQ2.HOWindowActive is known to throw exceptions.
				return false;
			}
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		/// <param name="aiMezAbilityIDs">A list of mez spells to choose from, in order of decreasing preference.</param>
		/// <returns></returns>
		protected bool CastNextMez(params uint[] auiMezAbilityIDs)
		{
			if (m_eMezMode == MezMode.Never || auiMezAbilityIDs.Length == 0)
				return false;

			else if (m_eMezMode == MezMode.OnlyWhenMainTankDead)
			{
				/// There's no main tank!
				if (string.IsNullOrEmpty(m_strCurrentMainTank))
					return false;

				VitalStatus MainTankStatus = null;
				if (GetVitalStatus(m_strCurrentMainTank, ref MainTankStatus) && !MainTankStatus.m_bIsDead)
					return false;
			}

			float fHighestRangeAlreadyScanned = 0;

			foreach (uint uiThisAbilityID in auiMezAbilityIDs)
			{
				CachedAbility ThisAbility = GetAbility(uiThisAbilityID, true);
				if (ThisAbility == null)
					continue;

				float fThisAbilityRange = ThisAbility.m_fRange;

				/// Avoid scanning subsets of a radius we already scanned in a prior iteration.
				if (fThisAbilityRange < fHighestRangeAlreadyScanned)
					continue;

				foreach (Actor ThisActor in m_KillableActorDictionary.Values)
				{
					if (!ThisActor.IsEpic && /// Mass-mezzing epics is just silly and has too many pitfalls.
						(m_OffensiveTargetActor == null || (ThisActor.ID != m_OffensiveTargetActor.ID && (!m_OffensiveTargetEncounterActorDictionary.ContainsKey(ThisActor.ID) || m_bMezMembersOfTargetEncounter))) && /// It can't be our current burn mob.
						ThisActor.CanTurn &&
						ThisActor.Target().IsValid &&
						ThisActor.Target().Type == "PC") /// It has to be targetting a player; an indicator of aggro.
					{
						/// If we found a mez target but are still in combat, withdraw for now.
						if (WithdrawCombatFromTarget(ThisActor))
						{
							Program.Log("Mez target found but first we need to withdraw from combat.");
							return true;
						}

						Program.Log("Mez target found: \"{0}\" ({1})", ThisActor.Name, ThisActor.ID);

						/// Not generally our policy to do more than one server command in a frame but we make an exception here.
						if (ThisActor.DoTarget() && CastAbility(uiThisAbilityID))
						{
							SpamSafeRaidSay(m_strMezCallout, ThisActor.Name);
							return true;
						}
					}
				}

				fHighestRangeAlreadyScanned = fThisAbilityRange;
			}

			//Program.Log("No mez targets identified.");
			return false;
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		protected bool IsAbilityMaintained(string strEffectName)
		{
			return m_MaintainedNameToIndexMap.ContainsKey(strEffectName);
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		protected bool IsAbilityMaintained(uint uiAbilityID)
		{
			if (uiAbilityID == 0)
				return false;

			string strAbilityName = m_KnowledgeBookIDToNameMap[uiAbilityID];
			if (m_MaintainedNameToIndexMap.ContainsKey(strAbilityName))
				return true;

			return false;
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		protected bool IsAbilityMaintained(uint uiAbilityID, double fMinimumRemainingDurationSeconds)
		{
			if (uiAbilityID == 0)
				return false;

			string strAbilityName = m_KnowledgeBookIDToNameMap[uiAbilityID];

			int iIndex = -1;
			if (!m_MaintainedNameToIndexMap.TryGetValue(strAbilityName, out iIndex))
				return false;

			Maintained ThisMaintained = Me.Maintained(iIndex);
			return (ThisMaintained.Duration >= fMinimumRemainingDurationSeconds);
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		protected bool IsAbilityMaintained(uint uiAbilityID, int iTargetActorID)
		{
			if (uiAbilityID == 0)
				return false;

			string strAbilityName = m_KnowledgeBookIDToNameMap[uiAbilityID];
			MaintainedTargetIDKey NewKey = new MaintainedTargetIDKey(strAbilityName, iTargetActorID);
			return m_MaintainedTargetNameDictionary.ContainsKey(NewKey);
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		protected bool IsBeneficialEffectPresent(uint uiAbilityID)
		{
			if (uiAbilityID == 0)
				return false;

			string strAbilityName = m_KnowledgeBookIDToNameMap[uiAbilityID];
			if (m_BeneficialEffectNameToIndexMap.ContainsKey(strAbilityName))
				return true;

			return false;
		}

		/************************************************************************************/
		protected bool IsBeneficialEffectPresent(string strName)
		{
			return m_BeneficialEffectNameToIndexMap.ContainsKey(strName);
		}

		/************************************************************************************/
		/// <summary>
		/// Don't use this inside other PlayerController functions, there'd be too much dummy-check redundancy.
		/// </summary>
		protected bool IsAbilityReady(uint uiAbilityID)
		{
			/// IsReady is false for available CA's that require stealth.
			//return (ThisAbility.TimeUntilReady == 0.0);
			return (GetAbility(uiAbilityID, true) != null);
		}

		/************************************************************************************/
		/// <summary>
		/// If a maintained ability is active but it's a lower-tier version of something you have a later version of,
		/// then this function will cancel it.
		/// </summary>
		/// <param name="iAbilityID"></param>
		/// <param name="bAnyVersion">true if any version of the spell should be cancelled, false if only inferior ones should be cancelled</param>
		/// <returns>true if a maintained spell was actually found and cancelled.</returns>
		protected bool CancelMaintained(uint uiAbilityID, bool bCancelAnyVersion)
		{
			if (uiAbilityID == 0)
				return false;

			/// This is the name that SHOULD appear in the maintained list.
			string strBestAbilityName = m_KnowledgeBookIDToNameMap[uiAbilityID];

			int iCancelCount = 0;

			foreach (Maintained ThisMaintained in EnumMaintained())
			{
				string strMaintainedName = ThisMaintained.Name;

				uint uiBestAbilityID = 0;
				if (m_KnowledgeBookAbilityLineDictionary.TryGetValue(strMaintainedName, out uiBestAbilityID) && uiBestAbilityID == uiAbilityID)
				{
					/// We have to distinguish via name because maintained spells don't give us the original ability ID.
					if (bCancelAnyVersion || strBestAbilityName != strMaintainedName)
					{
						Program.Log("Cancelling \"{0}\" from {1}...", strMaintainedName, ThisMaintained.Target().Name);
						ThisMaintained.Cancel();
						iCancelCount++;
					}
				}
			}

			return (iCancelCount > 0);
		}

		/************************************************************************************/
		/// <summary>
		/// </summary>
		/// <param name="iAbilityID"></param>
		/// <param name="astrRecipients"></param>
		/// <returns>true if a buff was cast or cancelled even one single time.</returns>
		protected bool CheckSingleTargetBuffs(uint uiAbilityID, List<string> astrRecipients)
		{
			CachedAbility ThisAbility = GetAbility(uiAbilityID, false);
			if (ThisAbility == null)
				return false;

#if DEBUG
			/// This is a common mistake I make, initializing string lists as null instead of an allocated instance.
			if (astrRecipients == null)
			{
				Program.Log("BUG: CheckSingleTargetBuffs() called with null list parameter!");
				return false;
			}
#endif

			bool bAnyActionTaken = false;

			/// Eliminate inferior versions.
			if (CancelMaintained(uiAbilityID, false))
				bAnyActionTaken = true;

			/// Start the list with everyone who *should* have the buff.
			SetCollection<string> NeedyTargetSet = new SetCollection<string>();
			foreach (string strThisTarget in astrRecipients)
			{
				if (!string.IsNullOrEmpty(strThisTarget))
					NeedyTargetSet.Add(strThisTarget);
			}

			/// Find out who needs the buff, and remove the buff from people who shouldn't have it.
			foreach (Maintained ThisMaintained in EnumMaintained())
			{
				if (ThisMaintained.Name == ThisAbility.m_strName)
				{
					/// Either from a mythical weapon or AA, this single-target buff might be converted to a group/raid buff,
					/// which in current experience there will only be one of in the maintained list.
					/// We can skip a lot of errant processing if we make note of this.
					if (ThisMaintained.Type == "Group" || ThisMaintained.Type == "Raid")
						return bAnyActionTaken;

					/// Because this is based off of an actor rather than just storing the target name string,
					/// we have weird side effects like buffs being dropped on anyone who is in a different zone.
					string strTargetName = ThisMaintained.Target().Name;

					/// Remove from the list everyone who *has* the buff already.
					if (NeedyTargetSet.Contains(strTargetName) && !string.IsNullOrEmpty(strTargetName))
						NeedyTargetSet.Remove(strTargetName);
					else
					{
						/// Remove the buff from every player who should not have it,
						/// and also from targets whose names are no longer known (i.e. empty string).
						Program.Log("Cancelling \"{0}\" from {1}...", ThisAbility.m_strName, string.IsNullOrEmpty(strTargetName) ? "(unknown target)" : strTargetName);
						if (ThisMaintained.Cancel())
							bAnyActionTaken = true;
					}
				}
			}

			/// Now cast the buff on the next person that needs it.
			foreach (string strThisTarget in NeedyTargetSet)
			{
				/// Check raid first; it's a superset of the group.
				if (ThisAbility.m_bAllowRaid)
				{
					if (!m_FriendDictionary.ContainsKey(strThisTarget))
					{
						Program.DebugLog("{0} wasn't cast on {1} (not found in group or raid).", ThisAbility.m_strName, strThisTarget);
						continue;
					}
				}
				else
				{
					if (!m_GroupMemberDictionary.ContainsKey(strThisTarget))
					{
						Program.DebugLog("{0} wasn't cast on {1} (not found in group).", ThisAbility.m_strName, strThisTarget);
						continue;
					}
				}

				if (CastAbility(uiAbilityID, strThisTarget, true))
				{
					bAnyActionTaken = true;
					break;
				}
			}

			return bAnyActionTaken;
		}

		/************************************************************************************/
		protected bool CheckSingleTargetBuff(uint uiAbilityID, string strRecipient)
		{
			List<string> astrSingleTargetList = new List<string>();
			astrSingleTargetList.Add(strRecipient);
			return CheckSingleTargetBuffs(uiAbilityID, astrSingleTargetList);
		}

		/************************************************************************************/
		/// <summary>
		/// This gets used for a buff that can only be on one person at a time.
		/// It prioritizes the first player it finds in the candidates list.
		/// This is extremely useful when you frequently alternate players that receive the buff.
		/// </summary>
		protected bool CheckSingleTargetBuff(uint uiAbilityID, List<string> astrCandidates)
		{
			string strPlayer = GetFirstExistingBeneficialAbilityCandidate(uiAbilityID, astrCandidates);
			if (string.IsNullOrEmpty(strPlayer))
				return false;

			return CheckSingleTargetBuff(uiAbilityID, strPlayer);
		}

		/************************************************************************************/
		protected bool CheckToggleBuff(uint uiAbilityID, bool bOn)
		{
			if (uiAbilityID == 0)
				return false;

			if (CancelMaintained(uiAbilityID, !bOn))
				return true;

			/// Cast it explicitly on myself to remove ambiguity.
			if (bOn && !IsAbilityMaintained(uiAbilityID) && CastAbilityOnSelf(uiAbilityID))
				return true;

			return false;
		}

		/************************************************************************************/
		protected bool CheckStanceBuff(uint uiOffensiveAbilityID, uint uiDefensiveAbilityID, StanceType eStance)
		{
			/// Cancel the wrong stance.
			if (eStance != StanceType.Offensive && CancelMaintained(uiOffensiveAbilityID, true))
				return true;
			if (eStance != StanceType.Defensive && CancelMaintained(uiDefensiveAbilityID, true))
				return true;

			/// Cast the right stance.
			if (eStance == StanceType.Offensive && !IsAbilityMaintained(uiOffensiveAbilityID) && CastAbilityOnSelf(uiOffensiveAbilityID))
				return true;
			if (eStance == StanceType.Defensive && !IsAbilityMaintained(uiDefensiveAbilityID) && CastAbilityOnSelf(uiDefensiveAbilityID))
				return true;

			return false;
		}

		/************************************************************************************/
		protected bool AreDumbfiresAdvised()
		{
			if (m_OffensiveTargetActor == null)
				return false;
			else if (m_OffensiveTargetActor.IsNamed)
				return true;
			else if (m_OffensiveTargetActor.IsEpic)
				return (m_OffensiveTargetActor.Health > 50);
			else
				return false;
		}

		/************************************************************************************/
		protected bool AreTempOffensiveBuffsAdvised()
		{
			/// TODO: We need a condition that checks how many mobs we have engaged.

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

		/************************************************************************************/
		protected bool CheckRacialBuffs()
		{
			if (!m_bUseRacialBuffs)
				return false;

			if (CheckToggleBuff(m_uiFeatherfallAbilityID, true))
				return true;

			return false;
		}

		/************************************************************************************/
		/// <summary>
		/// Harvests the nearest node while standing still.
		/// Because we can't use CastAbility() to perform the harvest,
		/// we fudge the range and harvest cast time.
		/// Otherwise we'd need a table of nodes and what harvest ability they require (fuck that).
		/// </summary>
		/// <returns></returns>
		protected bool AutoHarvestNearestNode()
		{
			if (!m_bHarvestAutomatically || MeActor.IsDead || Me.IsMoving || MeActor.InCombatMode || m_iOffensiveTargetID != -1)
				return false;

			/// Try to disqualify the attempt in progress if it timed out.
			/// The correct termination of an attempt is when OnIncomingText() receives a status string.
			if (m_bAutoHarvestInProgress)
			{
				if ((CurrentCycleTimestamp - m_LastAutoHarvestAttemptTime) < TimeSpan.FromSeconds(5))
					return false;
				else
				{
					Program.Log("Harvest attempt timed out.");
					m_bAutoHarvestInProgress = false;
				}
			}

			Actor NearestHarvestableNode = null;
			double fNearestHarvestableDistance = 0.0f;

			/// Find the nearest harvestable. 5 meters seems to be the right range.
			foreach (Actor ThisActor in EnumActorsInRadius(5))
			{
				/// We have to be careful, this also includes shineys that may be locked due to leader loot.
				if (ThisActor.Type != "Resource")
					continue;

				double fDistance = ThisActor.Distance;
				if (NearestHarvestableNode == null || fDistance < fNearestHarvestableDistance)
				{
					NearestHarvestableNode = ThisActor;
					fNearestHarvestableDistance = fDistance;
				}
			}

			/// No harvestable node found.
			if (NearestHarvestableNode == null)
				return false;

			NearestHarvestableNode.DoTarget();
			if (!Me.TargetLOS)
			{
				Program.Log("No line of sight to the harvest node. Please move closer to avoid command spam.");
				return false;
			}

			NearestHarvestableNode.DoubleClick();

			m_bAutoHarvestInProgress = true;
			m_LastAutoHarvestAttemptTime = CurrentCycleTimestamp;
			Program.Log("Harvesting \"{1}\" from a distance of {2:0.00} meters...", NearestHarvestableNode.Type, NearestHarvestableNode.Name, fNearestHarvestableDistance);
			return true;
		}

		/************************************************************************************/
		protected bool AutoLootNearestCorpseOrChest()
		{
			/// Don't loot another actor if a loot window is up.
			if (!m_bLootAutomatically || MeActor.IsDead || s_Extension.LootWindow().IsValid || CurrentCycleTimestamp < m_NextAutoLootAttemptTime)
				return false;

			/// Find the nearest actor. 12 meters seems to be the right range, so I'll do 10.
			bool bActionAttempted = false;
			foreach (Actor ThisActor in EnumActorsInRadius(12))
			{
				if (ThisActor.Type != "PC")
				{
					if (ThisActor.IsDead && ThisActor.Distance <= 12)
					{
						if (ApplyVerb(ThisActor, "loot"))
							bActionAttempted = true;
					}
					else if (ThisActor.IsChest && ThisActor.Distance <= 5)
					{
						if (ApplyVerb(ThisActor, "open"))
							bActionAttempted = true;
					}
				}
			}

			m_NextAutoLootAttemptTime = CurrentCycleTimestamp + TimeSpan.FromSeconds(0.5);
			return bActionAttempted;
		}

		/************************************************************************************/
		protected bool CastFurySalveAbility()
		{
			if (!m_bCastFurySalveIfGranted || !CanAffordAbilityCost(m_uiFurySalveHealAbilityID))
				return false;

			/// This is very simple actually; we'll be casting it on the PC with the lowest health percentage.
			string strLowestHealthName = null;
			double fLowestHealthRatio = 1.0;
			foreach (VitalStatus ThisStatus in EnumVitalStatuses(m_bHealUngroupedMainTank))
			{
				double fThisHealthRatio = ThisStatus.HealthRatio;
				if (fThisHealthRatio < fLowestHealthRatio)
				{
					fLowestHealthRatio = fThisHealthRatio;
					strLowestHealthName = ThisStatus.m_strName;
				}
			}

			/// TODO: Really should have a sorted list, to heal the next-lowest PC if the lowest PC is OOR.
			if (string.IsNullOrEmpty(strLowestHealthName))
				return false;

			return CastAbility(m_uiFurySalveHealAbilityID, strLowestHealthName, true);
		}

		/************************************************************************************/
		protected bool UseRegenItem()
		{
			if (!IsIdle || IsCasting)
				return false;

			VitalStatus MyStatus = null;
			if (!GetVitalStatus(Name, ref MyStatus))
				return false;

			foreach (CustomRegenItem ThisItem in m_aCustomRegenItemList)
			{
				if (ThisItem.ShouldUse(MyStatus) && UseInventoryItem(ThisItem))
					return true;
			}

			return false;
		}

		/************************************************************************************/
		protected bool UseDeaggroItems()
		{
			if (IsIdle)
			{
				if (m_OffensiveTargetActor != null)
				{
					if (UseInventoryItem("Behavioral Modificatinator Stereopticon", false, false, true, false))
						return true;
				}
			}

			return false;
		}

		/************************************************************************************/
		/// <summary>
		/// This is a dumping ground for any last bag of tricks.
		/// </summary>
		/// <returns></returns>
		protected bool UseOffensiveItems()
		{
			if (IsIdle)
			{
				if (m_OffensiveTargetActor != null)
				{
					if (UseInventoryItem("Brock's Thermal Shocker", false, false, true, false))
						return true;

					/// Shard of Fear has a 30 minute recast, you wouldn't want to waste it on dumb shit.
					if (m_OffensiveTargetActor.IsNamed && UseInventoryItem("Shard of Fear", true, false, true, false))
						return true;
				}
			}

			return false;
		}
	}
}
