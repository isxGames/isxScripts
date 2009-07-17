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
		private static readonly TimeSpan s_ChatSpamThrottleTimeout = TimeSpan.FromSeconds(10);

		/// <summary>
		/// Records the most recent group chat strings,
		/// so that the bot doesn't spam repeatedly and send bad hints to the server.
		/// </summary>
		private Dictionary<string, DateTime> m_RecentGroupChatStringIndex = new Dictionary<string, DateTime>();

		/// <summary>
		/// Records the most recent raid chat strings,
		/// so that the bot doesn't spam repeatedly and send bad hints to the server.
		/// </summary>
		private Dictionary<string, DateTime> m_RecentRaidChatStringIndex = new Dictionary<string, DateTime>();

		/************************************************************************************/
		/// <summary>
		/// This finds planar distance without regard to altitude.
		/// </summary>
		public static double GetActorDistance2D(Actor Actor1, Actor Actor2)
		{
			/// http://en.wikipedia.org/wiki/Euclidean_distance
			double A = Actor1.X - Actor2.X;
			A *= A;

			double B = Actor1.Y - Actor2.Y;
			B *= B;

			return Math.Sqrt(A + B); //- Actor1.TargetRingRadius - Actor2.TargetRingRadius;
		}

		/************************************************************************************/
		/// <summary>
		/// This finds planar distance without regard to altitude.
		/// </summary>
		public static double GetActorDistance2D(Actor Actor1, Point3D ptReference)
		{
			/// http://en.wikipedia.org/wiki/Euclidean_distance
			double A = Actor1.X - ptReference.X;
			A *= A;

			double B = Actor1.Y - ptReference.Y;
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
			if (!Me.Grouped || string.IsNullOrEmpty(strFormat))
				return;

			string strMessage = string.Empty;
			try
			{
				if (aobjParams.Length == 0)
					strMessage += string.Format("{0}", strFormat);
				else
					strMessage += string.Format(strFormat, aobjParams);
			}
			catch
			{
				return;
			}

			if (m_RecentGroupChatStringIndex.ContainsKey(strMessage))
			{
				if (DateTime.Now - m_RecentGroupChatStringIndex[strMessage] > s_ChatSpamThrottleTimeout)
					m_RecentGroupChatStringIndex.Remove(strMessage);
				else
					return;
			}

			Program.RunCommand("/g {0}", strMessage);
			m_RecentGroupChatStringIndex.Add(strMessage, DateTime.Now);
			return;
		}

		/************************************************************************************/
		public void SpamSafeRaidSay(string strFormat, params object[] aobjParams)
		{
			if (string.IsNullOrEmpty(strFormat))
				return;

			if (!Me.InRaid)
			{
				if (Me.Grouped)
					SpamSafeGroupSay(strFormat, aobjParams);
				return;
			}

			string strMessage = string.Empty;
			try
			{
				if (aobjParams.Length == 0)
					strMessage += string.Format("{0}", strFormat);
				else
					strMessage += string.Format(strFormat, aobjParams);
			}
			catch
			{
				return;
			}

			if (m_RecentRaidChatStringIndex.ContainsKey(strMessage))
			{
				if (DateTime.Now - m_RecentRaidChatStringIndex[strMessage] > s_ChatSpamThrottleTimeout)
					m_RecentRaidChatStringIndex.Remove(strMessage);
				else
					return;
			}

			Program.RunCommand("/r {0}", strMessage);
			m_RecentRaidChatStringIndex.Add(strMessage, DateTime.Now);
			return;
		}
	}
}
