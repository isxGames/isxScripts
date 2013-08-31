using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2SuiteLib
{
	public static class CustomFormatter
	{
		public const ulong KB = 1024;
		public const ulong MB = KB * KB;
		public const ulong GB = MB * KB;
		public const ulong TB = GB * KB;
		public const ulong PB = TB * KB;
		public const ulong EB = PB * KB;

		public static string FormatByteCount(ulong ulByteCount, string strNumericFormat)
		{
			/// If there's a more elegant algorithm, I haven't thought of it yet.
			if (ulByteCount > EB)
				return ((double)ulByteCount / (double)EB).ToString(strNumericFormat) + " EB";
			else if (ulByteCount > PB)
				return ((double)ulByteCount / (double)PB).ToString(strNumericFormat) + " PB";
			else if (ulByteCount > TB)
				return ((double)ulByteCount / (double)TB).ToString(strNumericFormat) + " TB";
			else if (ulByteCount > GB)
				return ((double)ulByteCount / (double)GB).ToString(strNumericFormat) + " GB";
			else if (ulByteCount > MB)
				return ((double)ulByteCount / (double)MB).ToString(strNumericFormat) + " MB";
			else if (ulByteCount > KB)
				return ((double)ulByteCount / (double)KB).ToString(strNumericFormat) + " KB";
			else
				return string.Format("{0} bytes", ulByteCount);
		}

		public static string FormatByteCount(long lByteCount, string strNumericFormat)
		{
			return FormatByteCount((ulong)lByteCount, strNumericFormat);
		}
	}
}
