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

		/************************************************************************************/
		/// <summary>
		/// Casts an action on an arbitrary PC target using the chat command.
		/// Preferred for all beneficial casts.
		/// </summary>
		public bool CastAbility(int iAbilityID, string strPlayerTarget, bool bMustBeAlive)
		{
			if (iAbilityID < 1)
				return false;

			/// We won't muck around with spell queuing and add needless complexity;
			/// the latency between frames is usually smaller than the smallest recovery times (0.25 sec) anyway.
			Ability ThisAbility = Me.Ability(iAbilityID);
			if (!ThisAbility.IsValid || !ThisAbility.IsReady)
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
			Program.RunCommand("/useabilityonplayer {0} {1}", strPlayerTarget, ThisAbility.Name);
			return true;
		}

		/************************************************************************************/
		/// <summary>
		/// Casts an action on the player's current target.
		/// </summary>
		/// <param name="iAbilityID"></param>
		/// <returns></returns>
		public bool CastAbility(int iAbilityID)
		{
			if (iAbilityID < 1)
				return false;

			/// We won't muck around with spell queuing and add needless complexity;
			/// the latency between frames is usually smaller than the smallest recovery times (0.25 sec) anyway.
			Ability ThisAbility = Me.Ability(iAbilityID);
			if (!ThisAbility.IsValid || !ThisAbility.IsReady || ThisAbility.IsQueued)
				return false;

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

			/// Disqualify by power cost.
			/// Although it would be cheaper CPU to disqualify power first,
			/// the log spam would think we were trying to cast even if we were eventually going to disqualify it anyway.
			if (Me.Power < ThisAbility.PowerCost)
			{
				Program.Log("Not enough power to cast {0}!", ThisAbility.Name);
				return false;
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

			/// We won't muck around with spell queuing and add needless complexity;
			/// the latency between frames is usually smaller than the smallest recovery times (0.25 sec) anyway.
			Ability ThisAbility = Me.Ability(iAbilityID);
			if (!ThisAbility.IsValid || !ThisAbility.IsReady)
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

			/// We won't muck around with spell queuing and add needless complexity;
			/// the latency between frames is usually smaller than the smallest recovery times (0.25 sec) anyway.
			Ability ThisAbility = Me.Ability(iAbilityID);
			if (!ThisAbility.IsValid || !ThisAbility.IsReady)
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

					/// Save time. The only reason we enumerated is because EncounterSize also includes dead members.
					if (iValidVictimCount >= m_OffensiveTargetActor.EncounterSize)
						break;
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
				Ability ThisAbility = Me.Ability(iThisAbilityID);
				if (!ThisAbility.IsValid || !ThisAbility.IsReady)
					continue;

				float fThisAbilityRange = ThisAbility.Range;

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
			if (iAbilityID < 1)
				return false;

			Ability ThisAbility = Me.Ability(iAbilityID);

			/// IsReady is false for available CA's that require stealth.
			//return (ThisAbility.TimeUntilReady == 0.0);
			return ThisAbility.IsValid && ThisAbility.IsReady;
		}

		/************************************************************************************/
		/// <summary>
		/// If a maintained ability is active but it's a lower-tier version of something you have a later version of,
		/// then this function will cancel it.
		/// </summary>
		/// <param name="iAbilityID"></param>
		/// <param name="bAnyVersion">true if any version of the spell should be cancelled, false if only inferior ones should be cancelled</param>
		/// <returns>true if a maintained spell was actually found and cancelled.</returns>
		public bool CancelAbility(int iAbilityID, bool bCancelAnyVersion)
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
			if (iAbilityID < -1)
				return false;

			if (CancelAbility(iAbilityID, !bOn))
				return true;

			/// Target myself to remove ambiguity.
			if (bOn && !IsAbilityMaintained(iAbilityID) && CastAbility(iAbilityID, Me.Name, true))
				return true;

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
		public bool AutoHarvestNearestNode()
		{
			if (!m_bHarvestAutomatically || Me.IsMoving || MeActor.InCombatMode || m_iOffensiveTargetID != -1)
				return false;

			/// Try to disqualify the attempt in progress if it timed out.
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
			double fNearestHarvestableDistance = 50.0f;

			/// Find the nearest harvestable. 6 meters seems to be the right range.
			foreach (Actor ThisActor in EnumCustomActors("byDist", "6"))
			{
				if (ThisActor.Type != "Resource")
					continue;

				double fDistance = GetActorDistance3D(MeActor, ThisActor);
				if (fDistance < fNearestHarvestableDistance)
				{
					NearestHarvestableNode = ThisActor;
					fNearestHarvestableDistance = fDistance;
				}
			}

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
	}
}
