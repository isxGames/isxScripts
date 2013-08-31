using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using System.IO;

namespace PInvoke
{
	public static class PInvokeHelper
	{
		/***************************************************************************/
		public static IntPtr AllocHGlobalFromStruct<T>(T ThisStruct)
		{
			IntPtr pBuffer = Marshal.AllocHGlobal(Marshal.SizeOf(ThisStruct));
			if (pBuffer != IntPtr.Zero)
				Marshal.StructureToPtr(ThisStruct, pBuffer, false);
			return pBuffer;
		}

		/***************************************************************************/
		/// <summary>
		/// Converted from VB written by Dustin Aleksiuk.
		/// http://www.codinghorror.com/blog/archives/000264.html
		/// </summary>
		public static DateTime RetrieveLinkerTimestamp(string strFilePath)
		{
			const int iPeHeaderOffset = 60;
			const int iLinkerTimestampOffset = 8;

			byte[] b = new byte[2048];

			using (Stream s = new FileStream(strFilePath, FileMode.Open, FileAccess.Read))
			{
				s.Read(b, 0, 2048);
			}

			int i = BitConverter.ToInt32(b, iPeHeaderOffset);
			int iSecondsSince1970 = BitConverter.ToInt32(b, i + iLinkerTimestampOffset);

			DateTime dt = new DateTime(1970, 1, 1, 0, 0, 0);
			dt = dt.AddSeconds(iSecondsSince1970);
			//dt = dt.AddHours(TimeZone.CurrentTimeZone.GetUtcOffset(dt).Hours);
			return dt;
		}
	}
}
