using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2SuiteLib
{
	public static class CustomFormatter
	{
		public static string FormatByteCount(ulong ulByteCount, string strNumericFormat)
		{
			const ulong KB = 1024;
			const ulong MB = KB * KB;
			const ulong GB = MB * KB;
			const ulong TB = GB * KB;
			const ulong PB = TB * KB;
			const ulong EB = PB * KB;

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
