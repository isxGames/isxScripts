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

namespace EQ2GlassCannon
{
	public partial class PlayerController
	{
		/************************************************************************************/
		/// <summary>
		/// This finds planar distance without regard to altitude.
		/// In EQ2, the Y coordinate is altitude/elevation.
		/// </summary>
		public static double GetActorDistance2D(Actor Actor1, Actor Actor2)
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
		public static double GetActorDistance2D(Actor Actor1, Point3D ptReference)
		{
			/// http://en.wikipedia.org/wiki/Euclidean_distance
			double A = Actor1.X - ptReference.X;
			A *= A;

			double B = Actor1.Z - ptReference.Z;
			B *= B;

			return Math.Sqrt(A + B); //- Actor1.TargetRingRadius - Actor2.TargetRingRadius;
		}

		/************************************************************************************/
		public static double GetActorDistance3D(Actor Actor1, Actor Actor2)
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
		public static double GetActorDistance3D(Actor Actor1, Point3D ptReference)
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
		public static double GetHeadingFrom(Actor FromActor)
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
		public double GetRelativeHeadingFrom(Actor FromActor)
		{
			double fHeadingFrom = GetHeadingFrom(FromActor);
			double fRelativeHeading = 360.0 - (double)FromActor.Heading + fHeadingFrom;
			if (fRelativeHeading >= 360.0)
				fRelativeHeading -= 360.0;

			return fRelativeHeading;
		}

		/************************************************************************************/
		public IEnumerable<Maintained> EnumMaintained()
		{
			for (int iIndex = 1; iIndex <= Me.CountMaintained; iIndex++)
				yield return Me.Maintained(iIndex);
		}

		/************************************************************************************/
		public IEnumerable<GroupMember> EnumGroupMembers()
		{
			/// Referring to group member #0 is shady but it's useful enough for us to continue doing it.
			if (Me.Grouped)
			{
				for (int iIndex = 0; iIndex <= 5; iIndex++)
				{
					GroupMember ThisMember = Me.Group(iIndex);
					if (ThisMember != null && !string.IsNullOrEmpty(ThisMember.Name))
						yield return ThisMember;
				}
			}
			else
				yield return Me.Group(0);
		}

		/************************************************************************************/
		public IEnumerable<GroupMember> EnumRaidMembers()
		{
			if (Me.InRaid)
			{
				/// Documentation says to iterate through all 24 even if we have less than 24.
				for (int iIndex = 1; iIndex <= 24; iIndex++)
				{
					GroupMember ThisMember = Me.Raid(iIndex, false);
					if (ThisMember != null && ThisMember.Name != null)
						yield return ThisMember;
				}
			}
		}

		/************************************************************************************/
		public IEnumerable<Actor> EnumCustomActors(params string[] astrParams)
		{
			Program.EQ2.CreateCustomActorArray(astrParams);

			for (int iIndex = 1; iIndex <= Program.EQ2.CustomActorArraySize; iIndex++)
				yield return Program.s_Extension.CustomActor(iIndex);
		}

		/************************************************************************************/
		/// <summary>
		/// Frame lock is assumed to be held before this function is called.
		/// </summary>
		public static Actor GetNonPetActor(string strName)
		{
			Actor PlayerActor = Program.s_Extension.Actor(strName);

			/// Try again if it's invalid or it's a pet.
			if (!PlayerActor.IsValid || PlayerActor.IsAPet)
			{
				PlayerActor = Program.s_Extension.Actor(strName, "notid", PlayerActor.ID.ToString());
			}

			if (!PlayerActor.IsValid || PlayerActor.IsAPet)
				PlayerActor = null;

			return PlayerActor;
		}


		/************************************************************************************/
		public void SpamSafeGroupSay(string strFormat, params object[] aobjParams)
		{
			if (!Me.Grouped)
				return;

			Program.RunCommand(true, "/g " + strFormat, aobjParams);
			return;
		}

		/************************************************************************************/
		public void SpamSafeRaidSay(string strFormat, params object[] aobjParams)
		{
			if (!Me.InRaid)
			{
				if (Me.Grouped)
					SpamSafeGroupSay(strFormat, aobjParams);
				return;
			}

			Program.RunCommand(true, "/r " + strFormat, aobjParams);
			return;
		}

		/************************************************************************************/
		public void SpamSafeTell(string strPlayerName, string strFormat, params object[] aobjParams)
		{
			Program.RunCommand(true, "/t " + strPlayerName + " " + strFormat, aobjParams);
			return;
		}
	}
}
