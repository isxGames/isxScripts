﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Diagnostics;
using System.Drawing;
using EQ2.ISXEQ2;
using InnerSpaceAPI;
using LavishVMAPI;

namespace EQ2GlassCannon
{
	public partial class PlayerController
	{
		/************************************************************************************/
		protected class Point3D
		{
			public float X = 0.0f;
			public float Y = 0.0f;
			public float Z = 0.0f;

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
	}
}
