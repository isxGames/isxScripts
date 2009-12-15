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
using EQ2SuiteLib;

namespace EQ2GlassCannon
{
	public partial class PlayerController
	{
		/************************************************************************************/
		protected class Point3D
		{
			public double X = 0.0f;
			public double Y = 0.0f;
			public double Z = 0.0f;

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

		/************************************************************************************/
		protected class ActorDistanceComparer : IComparer<Actor>
		{
			public int Compare(Actor x, Actor y)
			{
				/// I don't know if the property recalculates these per access, so I cache just in case.
				float fDistanceX = x.Distance;
				float fDistanceY = y.Distance;

				if (fDistanceX > fDistanceY)
					return 1;
				else if (fDistanceX < fDistanceY)
					return -1;
				else
					return 0;
			}
		}

		/************************************************************************************/
		protected string GetFirstExistingPartyMember(List<string> astrCandidates, bool bMustBeInGroup)
		{
			foreach (string strThisCandidate in astrCandidates)
			{
				if (bMustBeInGroup)
				{
					if (m_GroupMemberDictionary.ContainsKey(strThisCandidate))
						return strThisCandidate;
				}
				else
				{
					if (m_FriendDictionary.ContainsKey(strThisCandidate))
						return strThisCandidate;
				}
			}

			return string.Empty;
		}

		/************************************************************************************/
		/// <summary>
		/// This finds planar distance without regard to altitude.
		/// In EQ2, the Y coordinate is altitude/elevation.
		/// </summary>
		protected static double GetActorDistance2D(Actor Actor1, Actor Actor2)
		{
			/// http://en.wikipedia.org/wiki/Euclidean_distance
			double A = Actor1.X - Actor2.X;
			A *= A;

			double B = Actor1.Z - Actor2.Z;
			B *= B;

			return Math.Sqrt(A + B); //- Actor1.TargetRingRadius - Actor2.TargetRingRadius;
		}

		/************************************************************************************/
		/// <summary>
		/// This finds planar distance without regard to altitude.
		/// In EQ2, the Y coordinate is altitude/elevation.
		/// </summary>
		protected static double GetActorDistance2D(Actor Actor1, Point3D ptReference)
		{
			/// http://en.wikipedia.org/wiki/Euclidean_distance
			double A = Actor1.X - ptReference.X;
			A *= A;

			double B = Actor1.Z - ptReference.Z;
			B *= B;

			return Math.Sqrt(A + B); //- Actor1.TargetRingRadius - Actor2.TargetRingRadius;
		}

		/************************************************************************************/
		protected static double GetActorDistance3D(Actor Actor1, Actor Actor2)
		{
			/// http://en.wikipedia.org/wiki/Euclidean_distance
			double A = Actor1.X - Actor2.X;
			A *= A;

			double B = Actor1.Y - Actor2.Y;
			B *= B;

			double C = Actor1.Z - Actor2.Z;
			C *= C;

			return Math.Sqrt(A + B + C); //- Actor1.TargetRingRadius - Actor2.TargetRingRadius;
		}

		/************************************************************************************/
		protected static double GetActorDistance3D(Actor Actor1, Point3D ptReference)
		{
			/// http://en.wikipedia.org/wiki/Euclidean_distance
			double A = Actor1.X - ptReference.X;
			A *= A;

			double B = Actor1.Y - ptReference.Y;
			B *= B;

			double C = Actor1.Z - ptReference.Z;
			C *= C;

			return Math.Sqrt(A + B + C); //- Actor1.TargetRingRadius - Actor2.TargetRingRadius;
		}

		/************************************************************************************/
		/// <summary>
		/// This function inverts the heading perspective,
		/// from your heading to an actor to that actor's heading to you.
		/// </summary>
		/// <param name="FromActor"></param>
		/// <returns></returns>
		protected static double GetHeadingFrom(Actor FromActor)
		{
			//Reference table (TO,FROM)
			//0,180
			//45,225
			//90,270
			//180,0
			//270,90

			double fHeadingFrom = (double)FromActor.HeadingTo + 180.0;
			if (fHeadingFrom >= 360.0)
				fHeadingFrom -= 360.0;

			return fHeadingFrom;
		}

		/************************************************************************************/
		/// <summary>
		/// This function gives you the relative heading of your character from the given actor's
		/// perspective, using 0 degrees as the reference angle being dead in front of it.
		/// </summary>
		/// <param name="FromActor"></param>
		/// <returns></returns>
		protected static double GetRelativeHeadingFrom(Actor FromActor)
		{
			double fHeadingFrom = GetHeadingFrom(FromActor);
			double fRelativeHeading = 360.0 - (double)FromActor.Heading + fHeadingFrom;
			if (fRelativeHeading >= 360.0)
				fRelativeHeading -= 360.0;

			return fRelativeHeading;
		}

		/************************************************************************************/
		protected static void SpamSafeGroupSay(string strFormat, params object[] aobjParams)
		{
			if (!IsInGroup)
				return;

			RunCommand(5, "/g " + strFormat, aobjParams);
			return;
		}

		/************************************************************************************/
		protected static void SpamSafeRaidSay(string strFormat, params object[] aobjParams)
		{
			if (!IsInRaid)
			{
				if (IsInGroup)
					SpamSafeGroupSay(strFormat, aobjParams);
				return;
			}

			RunCommand(5, "/r " + strFormat, aobjParams);
			return;
		}

		/************************************************************************************/
		protected static void SpamSafeTell(string strPlayerName, string strFormat, params object[] aobjParams)
		{
			RunCommand(5, "/t " + strPlayerName + " " + strFormat, aobjParams);
			return;
		}

		/************************************************************************************/
		protected static void AppendActorInfo(FlexStringBuilder ThisBuilder, int iBulletNumber, Actor ThisActor)
		{
			ThisBuilder.AppendedLinePrefix = "   ";
			if (!ThisActor.IsValid)
			{
				ThisBuilder.AppendLine("{0}. Actor not valid.", iBulletNumber);
				return;
			}

			ThisBuilder.AppendLine("{0}. \"{1}\" ({2}) found {3:0.00} meters away at ({4:0.00}, {5:0.00}, {6:0.00})",
				iBulletNumber,
				ThisActor.Name,
				ThisActor.ID,
				ThisActor.Distance,
				ThisActor.X,
				ThisActor.Y,
				ThisActor.Z);
			ThisBuilder.AppendedLinePrefix = "      ";

			string strFullName = ThisActor.Name;
			if (!string.IsNullOrEmpty(ThisActor.LastName))
				strFullName += " " + ThisActor.LastName;
			if (!string.IsNullOrEmpty(ThisActor.SuffixTitle))
				strFullName += " " + ThisActor.SuffixTitle;
			if (!string.IsNullOrEmpty(ThisActor.Guild))
				strFullName += " <" + ThisActor.Guild + ">";

			ThisBuilder.AppendLine("Full Name: {0}", strFullName);

			ThisBuilder.AppendLine("Type: {0}", ThisActor.Type);
			ThisBuilder.AppendLine("Class: {0}", ThisActor.Class);
			ThisBuilder.AppendLine("Race: {0}", ThisActor.Race);
			ThisBuilder.AppendLine("Level(Effective): {0}({1})", ThisActor.Level, ThisActor.EffectiveLevel);
			ThisBuilder.AppendLine("Encounter Size: {0}", ThisActor.EncounterSize);
			ThisBuilder.AppendLine("Collision Radius: {0}", ThisActor.CollisionRadius);
			ThisBuilder.AppendLine("Speed: {0}%", ThisActor.Speed);

			List<string> astrFlags = new List<string>();
			if (ThisActor.IsLinkdead)
				astrFlags.Add("IsLinkdead");

			if (ThisActor.IsSolo)
				astrFlags.Add("IsSolo");
			else if (ThisActor.IsHeroic)
				astrFlags.Add("IsHeroic");
			else if (ThisActor.IsEpic)
				astrFlags.Add("IsEpic");

			if (ThisActor.IsMerchant)
				astrFlags.Add("IsMerchant");
			if (ThisActor.IsBanker)
				astrFlags.Add("IsBanker");
			if (ThisActor.IsInvis)
				astrFlags.Add("IsInvis");
			if (ThisActor.IsStealthed)
				astrFlags.Add("IsStealthed");
			if (ThisActor.IsDead)
				astrFlags.Add("IsDead");
			if (ThisActor.IsFD)
				astrFlags.Add("IsFD");
			if (ThisActor.IsAggro)
				astrFlags.Add("IsAggro");
			if (ThisActor.IsLocked)
				astrFlags.Add("IsLocked");
			if (ThisActor.IsEncounterBroken)
				astrFlags.Add("IsEncounterBroken");
			if (ThisActor.IsNamed)
				astrFlags.Add("IsNamed");
			if (ThisActor.IsAPet)
				astrFlags.Add("IsAPet");
			if (ThisActor.IsMyPet)
				astrFlags.Add("IsMyPet");
			if (ThisActor.IsChest)
				astrFlags.Add("IsChest");

			if (ThisActor.IsIdle)
				astrFlags.Add("IsIdle");
			else if (ThisActor.IsBackingUp)
				astrFlags.Add("IsBackingUp");
			else if (ThisActor.IsStrafingLeft)
				astrFlags.Add("IsStrafingLeft");
			else if (ThisActor.IsStrafingRight)
				astrFlags.Add("IsStrafingRight");

			if (ThisActor.InCombatMode)
				astrFlags.Add("InCombatMode");
			else if (ThisActor.IsCrouching)
				astrFlags.Add("IsCrouching");
			else if (ThisActor.IsSitting)
				astrFlags.Add("IsSitting");

			if (ThisActor.IsSprinting)
				astrFlags.Add("IsSprinting");
			else if (ThisActor.IsWalking)
				astrFlags.Add("IsWalking");
			else if (ThisActor.IsRunning)
				astrFlags.Add("IsRunning");

			if (ThisActor.OnCarpet)
				astrFlags.Add("OnCarpet");
			else if (ThisActor.OnHorse)
				astrFlags.Add("OnHorse");
			else if (ThisActor.OnGriffin)
				astrFlags.Add("OnGriffin");
			else if (ThisActor.OnGriffon)
				astrFlags.Add("OnGriffon");

			string strFlags = string.Join(", ", astrFlags.ToArray());
			ThisBuilder.AppendLine("Flags: {0}", strFlags);
			return;
		}

		/************************************************************************************/
		protected static void AppendItemInfo(FlexStringBuilder ThisBuilder, int iBulletNumber, Item ThisItem)
		{
			ThisBuilder.AppendedLinePrefix = "   ";
			if (!ThisItem.IsValid)
			{
				ThisBuilder.AppendLine("{0}. Item not valid.", iBulletNumber);
				return;
			}

			ThisBuilder.AppendLine("{0}. \"{1}\"",
				iBulletNumber,
				ThisItem.Name);
			ThisBuilder.AppendedLinePrefix = "      ";

			ThisBuilder.AppendLine("Tier: {0}", ThisItem.Tier);
			ThisBuilder.AppendLine("Description: {0}", ThisItem.Description);
			ThisBuilder.AppendLine("Level: {0}", ThisItem.Level);
			//ThisBuilder.AppendLine("Link ID: {0}", ThisItem.LinkID);

			List<string> astrFlags = new List<string>();

			if (ThisItem.Lore)
				astrFlags.Add("Lore");
			if (ThisItem.LoreOnEquip)
				astrFlags.Add("LoreOnEquip");
			if (ThisItem.NoTrade)
				astrFlags.Add("NoTrade");
			if (ThisItem.Heirloom)
				astrFlags.Add("Heirloom");
			if (ThisItem.NoValue)
				astrFlags.Add("NoValue");
			if (ThisItem.NoZone)
				astrFlags.Add("NoZone");
			if (ThisItem.Attuneable)
				astrFlags.Add("Attunable");
			if (ThisItem.Attuned)
				astrFlags.Add("Attuned");

			string strFlags = string.Join(", ", astrFlags.ToArray());
			ThisBuilder.AppendLine("Flags: {0}", strFlags);

			return;
		}
	}
}
