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
		protected bool m_bAutoHarvestInProgress = false;
		protected DateTime m_LastAutoHarvestAttemptTime = DateTime.FromBinary(0);
		protected DateTime m_LastCastTime = DateTime.Now;
		protected DateTime m_NextPermissibleCastTime = DateTime.Now;

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

			public bool Use()
			{
				if (m_bIsQueued)
				{
					Program.Log("{0} is already queued for casting.", m_strName);
					return true;
				}

				/// The "/useability" command often doesn't work for shit because it toggles queuing on and off way too fucking rapidly.
				Program.Log("Casting {0}...", m_strName);
				Program.RunCommand("/useability {0}", m_strName);
				//Program.RunCommand("/clearabilityqueue");
				return true;
				//return m_OriginalAbility.Use();
			}

			public bool Use(string strPlayerTarget)
			{
				if (m_bIsQueued)
				{
					Program.Log("{0} is already queued for casting.", m_strName);
					return true;
				}

				Program.Log("Casting {0} on {1}...", m_strName, strPlayerTarget);
				Program.RunCommand("/useabilityonplayer {0} {1}", strPlayerTarget, m_strName);
				//Program.RunCommand("/clearabilityqueue");
				return true;
			}
		}

		/************************************************************************************/
		private Dictionary<int, CachedAbility> m_AbilityCache = new Dictionary<int, CachedAbility>();

		/// <summary>
		/// Within a frame lock, encounter/PBAE attempts might be called multiple times for the same spell.
		/// This cache prevents the need for redundant range detection on all NPC's within the blast radius,
		/// which can conceivably be taxing on CPU usage.
		/// </summary>
		private Dictionary<int, int> m_AbilityCompatibleTargetCountCache = new Dictionary<int, int>();

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
		protected CachedAbility GetAbility(int iAbilityID, bool bFailIfNotReady)
		{
			if (iAbilityID < 1)
				return null;

			CachedAbility ThisCachedAbility = null;

			if (m_AbilityCache.ContainsKey(iAbilityID))
				ThisCachedAbility = m_AbilityCache[iAbilityID];
			else
			{
				try
				{
					Ability ThisAbility = Me.Ability(iAbilityID);
					ThisCachedAbility = new CachedAbility(ThisAbility);
					m_AbilityCache.Add(iAbilityID, ThisCachedAbility);
				}
				catch
				{
					Program.Log("Exception thrown while attempting to look up ability info for \"{0}\" ({1}).", m_KnowledgeBookIndexToNameMap[iAbilityID], iAbilityID);
					return null;
				}
			}

#if DEBUG
			/// Dummy check.
			if (ThisCachedAbility.m_strName != m_KnowledgeBookIndexToNameMap[iAbilityID])
			{
				Program.Log("BUG: SPELL MISMATCH ({0} and {1}). The contents of the knowledge book must have changed.", ThisCachedAbility.m_strName, m_KnowledgeBookIndexToNameMap[iAbilityID]);
				return null;
			}
#endif

			if (!ThisCachedAbility.m_bIsValid)
			{
				Program.Log("Spell #{0} not valid.", iAbilityID);
				return null;
			}

			if (bFailIfNotReady && !ThisCachedAbility.m_bIsReady)
			{
#if DEBUG
				Program.Log("{0} not ready.", ThisCachedAbility.m_strName);
#endif
				return null;
			}

			return ThisCachedAbility;
		}

		/************************************************************************************/
		protected void StartCastTimers(CachedAbility ThisAbility)
		{
			m_LastCastTime = DateTime.Now;
			m_NextPermissibleCastTime = DateTime.Now + TimeSpan.FromSeconds(ThisAbility.m_fCastTimeSeconds + ThisAbility.m_fRecoveryTimeSeconds);
			return;
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		/// <param name="iAbilityID"></param>
		/// <returns>true if spell exists, is usable, AND can be afforded; false otherwise.</returns>
		public bool CanAffordAbilityCost(int iAbilityID)
		{
			CachedAbility ThisAbility = GetAbility(iAbilityID, true);
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

			/// I first check against zero to dodge the Character class value lookup.
			/// Most abilities have no concentration cost and for them this check is a waste of CPU.
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
		/// <summary>
		/// Casts an action on an arbitrary PC target using the chat command.
		/// Preferred for all beneficial casts.
		/// </summary>
		public bool CastAbility(int iAbilityID, string strPlayerTarget, bool bMustBeAlive)
		{
			if (string.IsNullOrEmpty(strPlayerTarget))
				return false;

			CachedAbility ThisAbility = GetAbility(iAbilityID, true);
			if (ThisAbility == null)
				return false;

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
			if (fDistance > ThisAbility.m_fRange)
			{
				Program.Log("Unable to cast {0} because {1} is out of range ({2} needed, {3:0.00} actual)",
					ThisAbility.m_strName, SpellTargetActor.Name, ThisAbility.m_fRange, fDistance);
				return false;
			}

			if (!CanAffordAbilityCost(iAbilityID))
				return false;

			StartCastTimers(ThisAbility);
			return ThisAbility.Use(strPlayerTarget);
		}

		/************************************************************************************/
		public bool CastAbilityOnSelf(int iAbilityID)
		{
			return CastAbility(iAbilityID, Me.Name, true);
		}

		/************************************************************************************/
		/// <summary>
		/// Casts a general ability, on the player's current target if applicable.
		/// </summary>
		/// <param name="iAbilityID"></param>
		/// <returns></returns>
		public bool CastAbility(
			int iAbilityID,
			double fVulnerableRelativeHeadingRangeStart,
			double fVulnerableRelativeHeadingRangeEnd)
		{
			CachedAbility ThisAbility = GetAbility(iAbilityID, true);
			if (ThisAbility == null)
				return false;

			Actor MyTargetActor = MeActor.Target();
			if (MyTargetActor.IsValid)
			{
				double fDistance = GetActorDistance3D(MeActor, MyTargetActor);
				if (fDistance < ThisAbility.m_fMinRange || ThisAbility.m_fMaxRange < fDistance)
				{
					Program.Log("Unable to cast {0} because {1} is out of range ({2}-{3} needed, {4:0.00} actual)",
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
						Program.Log("Unable to cast {0} because you on the wrong attack heading ({2:0} to {3:0} degrees needed, {4:0.00} actual).",
							ThisAbility.m_strName, MyTargetActor.Name, fVulnerableRelativeHeadingRangeStart, fVulnerableRelativeHeadingRangeEnd, fRelativeHeadingFrom);
						return false;
					}
				}
			}

			if (!CanAffordAbilityCost(iAbilityID))
				return false;

			StartCastTimers(ThisAbility);
			return ThisAbility.Use();
		}

		/************************************************************************************/
		public bool CastAbility(int iAbilityID)
		{
			return CastAbility(iAbilityID, 0.0, 360.0);
		}

		/************************************************************************************/
		public bool CastAbilityFromBehind(int iAbilityID)
		{
			return CastAbility(iAbilityID, 120.0, 240.0);
		}

		/************************************************************************************/
		public bool CastAbilityFromFlankingOrBehind(int iAbilityID)
		{
			return CastAbility(iAbilityID, 60.0, 300.0);
		}

		/************************************************************************************/
		public bool CastBlueOffensiveAbility(int iAbilityID, int iMinimumVictimCheckCount)
		{
			if (!m_bUseBlueAEs)
				return false;

			CachedAbility ThisAbility = GetAbility(iAbilityID, true);
			if (ThisAbility == null)
				return false;

			int iValidVictimCount = 0;
			if (m_AbilityCompatibleTargetCountCache.ContainsKey(iAbilityID))
				iValidVictimCount = m_AbilityCompatibleTargetCountCache[iAbilityID];
			else
			{
				foreach (Actor ThisActor in EnumCustomActors("byDist", ThisAbility.m_fEffectRadius.ToString(), "npc"))
				{
					if (ThisActor.Type != "NoKill NPC" && !ThisActor.IsDead)
						iValidVictimCount++;
				}

				m_AbilityCompatibleTargetCountCache.Add(iAbilityID, iValidVictimCount);
			}

			/// Check that the minimum number of potential victims is within the blast radius before proceeding.
			if (iValidVictimCount < iMinimumVictimCheckCount)
				return false;

			if (!CanAffordAbilityCost(iAbilityID))
				return false;

			Program.Log("{0} approved against {1} possible PBAE target(s) within {2:0}m radius.", ThisAbility.m_strName, iValidVictimCount, ThisAbility.m_fEffectRadius);
			StartCastTimers(ThisAbility);
			return ThisAbility.Use();
		}

		/************************************************************************************/
		/// <summary>
		/// I don't know the exact range mechanics behind green AE's, so this is some fudge work.
		/// </summary>
		public bool CastGreenOffensiveAbility(int iAbilityID, int iMinimumVictimCheckCount)
		{
			if (!m_bUseGreenAEs || m_OffensiveTargetActor == null)
				return false;

			CachedAbility ThisAbility = GetAbility(iAbilityID, true);
			if (ThisAbility == null)
				return false;

			int iValidVictimCount = 0;
			if (m_AbilityCompatibleTargetCountCache.ContainsKey(iAbilityID))
				iValidVictimCount = m_AbilityCompatibleTargetCountCache[iAbilityID];
			else
			{
				foreach (Actor ThisActor in EnumCustomActors("byDist", ThisAbility.m_fMaxRange.ToString(), "npc"))
				{
					if (ThisActor.Type != "NoKill NPC" && !ThisActor.IsDead && m_OffensiveTargetActor.IsInSameEncounter(ThisActor.ID))
						iValidVictimCount++;

					/// Save time. The only reason we enumerated is because EncounterSize also includes dead members.
					if (iValidVictimCount >= m_OffensiveTargetActor.EncounterSize)
						break;
				}

				m_AbilityCompatibleTargetCountCache.Add(iAbilityID, iValidVictimCount);
			}

			/// Check that the minimum number of potential victims is within the blast radius before proceeding.
			if (iValidVictimCount < iMinimumVictimCheckCount)
				return false;

			if (!CanAffordAbilityCost(iAbilityID))
				return false;

			Program.Log("{0} approved against {1} possible encounter target(s) within {2:0}m radius.", ThisAbility.m_strName, iValidVictimCount, ThisAbility.m_fMaxRange);
			StartCastTimers(ThisAbility);
			return ThisAbility.Use();
		}

		/************************************************************************************/
		/// <summary>
		/// Casts the HO starter if the wheel isn't up.
		/// </summary>
		public bool CastHOStarter()
		{
			try
			{
				return (m_bSpamHeroicOpportunity && (Me.IsHated && MeActor.InCombatMode) && !Program.EQ2.HOWindowActive && CastAbility(m_iHOStarterAbiltyID, Me.Name, true));
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
		public bool CastNextMez(params int[] aiMezAbilityIDs)
		{
			/// This action is only intended for combat, where a primary target has been already selected.
			if (!m_bMezAdds || m_OffensiveTargetActor == null)
				return false;

			float fHighestRangeAlreadyScanned = 0;

			foreach (int iThisAbilityID in aiMezAbilityIDs)
			{
				CachedAbility ThisAbility = GetAbility(iThisAbilityID, true);
				if (ThisAbility == null)
					continue;

				float fThisAbilityRange = ThisAbility.m_fRange;

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

			Program.Log("No mez targets identified.");
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
			/// IsReady is false for available CA's that require stealth.
			//return (ThisAbility.TimeUntilReady == 0.0);
			return (GetAbility(iAbilityID, true) != null);
		}

		/************************************************************************************/
		/// <summary>
		/// If a maintained ability is active but it's a lower-tier version of something you have a later version of,
		/// then this function will cancel it.
		/// </summary>
		/// <param name="iAbilityID"></param>
		/// <param name="bAnyVersion">true if any version of the spell should be cancelled, false if only inferior ones should be cancelled</param>
		/// <returns>true if a maintained spell was actually found and cancelled.</returns>
		public bool CancelMaintained(int iAbilityID, bool bCancelAnyVersion)
		{
			if (iAbilityID < 1)
				return false;

			/// This is the name that SHOULD appear in the maintained list.
			string strAbilityName = m_KnowledgeBookIndexToNameMap[iAbilityID];

			int iCancelCount = 0;

			foreach (Maintained ThisMaintained in EnumMaintained())
			{
				string strMaintainedName = ThisMaintained.Name;

				if (m_KnowledgeBookAbilityLineDictionary.ContainsKey(strMaintainedName) && m_KnowledgeBookAbilityLineDictionary[strMaintainedName] == iAbilityID)
				{
					if (bCancelAnyVersion || strAbilityName != strMaintainedName)
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
		/// </summary>
		/// <param name="iAbilityID"></param>
		/// <param name="astrRecipients"></param>
		/// <returns>true if a buff was cast or cancelled even one single time.</returns>
		public bool CheckSingleTargetBuffs(int iAbilityID, List<string> astrRecipients)
		{
			CachedAbility ThisAbility = GetAbility(iAbilityID, true);
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
			if (CancelMaintained(iAbilityID, false))
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
				if (ThisAbility.m_bAllowRaid)
				{
					if (!m_FriendDictionary.ContainsKey(strThisTarget))
					{
						Program.Log("{0} wasn't cast on {1} (not found in group or raid).", strAbilityName, strThisTarget);
						continue;
					}
				}
				else
				{
					if (!m_GroupMemberDictionary.ContainsKey(strThisTarget))
					{
						Program.Log("{0} wasn't cast on {1} (not found in group).", strAbilityName, strThisTarget);
						continue;
					}
				}

				if (CastAbility(iAbilityID, strThisTarget, true))
				{
					bAnyActionTaken = true;
					break;
				}
			}

			return bAnyActionTaken;
		}

		/************************************************************************************/
		public bool CheckSingleTargetBuffs(int iAbilityID, string strRecipient)
		{
			List<string> astrSingleTargetList = new List<string>();
			astrSingleTargetList.Add(strRecipient);
			return CheckSingleTargetBuffs(iAbilityID, astrSingleTargetList);
		}

		/************************************************************************************/
		public bool CheckToggleBuff(int iAbilityID, bool bOn)
		{
			if (iAbilityID < -1)
				return false;

			if (CancelMaintained(iAbilityID, !bOn))
				return true;

			/// Target myself to remove ambiguity.
			if (bOn && !IsAbilityMaintained(iAbilityID) && CastAbility(iAbilityID, Me.Name, true))
				return true;

			return false;
		}

		/************************************************************************************/
		public bool CheckStanceBuff(int iOffensiveAbilityID, int iDefensiveAbilityID, StanceType eStance)
		{
			if (eStance != StanceType.Offensive && CancelMaintained(iOffensiveAbilityID, true))
				return true;

			if (eStance != StanceType.Defensive && CancelMaintained(iDefensiveAbilityID, true))
				return true;

			if (eStance == StanceType.Offensive && !IsAbilityMaintained(iOffensiveAbilityID) && CastAbility(iOffensiveAbilityID, Me.Name, true))
				return true;

			if (eStance == StanceType.Defensive && !IsAbilityMaintained(iDefensiveAbilityID) && CastAbility(iDefensiveAbilityID, Me.Name, true))
				return true;

			return false;
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
		/// Harvests the nearest node while standing still.
		/// Because we can't use CastAbility() to perform the harvest,
		/// we fudge the range and harvest cast time.
		/// Otherwise we'd need a table of nodes and what harvest ability they require (fuck that).
		/// </summary>
		/// <returns></returns>
		public bool AutoHarvestNearestNode()
		{
			if (!m_bHarvestAutomatically || Me.IsMoving || MeActor.InCombatMode || m_iOffensiveTargetID != -1)
				return false;

			/// Try to disqualify the attempt in progress if it timed out.
			/// The correct termination of an attempt is when OnIncomingText() receives a status string.
			if (m_bAutoHarvestInProgress)
			{
				if ((DateTime.Now - m_LastAutoHarvestAttemptTime) < TimeSpan.FromSeconds(5))
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
			foreach (Actor ThisActor in EnumCustomActors("byDist", "5"))
			{
				/// We have to be careful, this also includes shineys that may be locked due to leader loot.
				if (ThisActor.Type != "Resource")
					continue;

				double fDistance = GetActorDistance3D(MeActor, ThisActor);
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
			m_LastAutoHarvestAttemptTime = DateTime.Now;
			Program.Log("Harvesting \"{1}\" from a distance of {2:0.00} meters...", NearestHarvestableNode.Type, NearestHarvestableNode.Name, fNearestHarvestableDistance);
			return false;
		}

		/************************************************************************************/
		public bool CastFurySalveAbility()
		{
			if (!m_bCastFurySalveIfGranted || !CanAffordAbilityCost(m_iFurySalveHealAbilityID))
				return false;

			/// This is very simple actually; we'll be casting it on the PC with the lowest health percentage.
			string strLowestHealthName = null;
			double fLowestHealthRatio = 1.0;
			foreach (VitalStatus ThisStatus in EnumVitalStatuses(m_bHealMainTank))
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

			return CastAbility(m_iFurySalveHealAbilityID, strLowestHealthName, true);
		}
	}
}
