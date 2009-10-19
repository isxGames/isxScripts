using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace EQ2SuiteLib
{
	public class CompiledRegexCache
	{
		private Dictionary<string, Regex> m_Dictionary = new Dictionary<string, Regex>();

		protected Regex GetRegex(string strPattern)
		{
			if (m_Dictionary.ContainsKey(strPattern))
				return m_Dictionary[strPattern];

			Regex NewRegex = new Regex(strPattern, RegexOptions.Compiled);
			m_Dictionary.Add(strPattern, NewRegex);
			return NewRegex;
		}

		public Match Match(string strInput, string strPattern)
		{
			return GetRegex(strPattern).Match(strInput);
		}

		public MatchCollection Matches(string strInput, string strPattern)
		{
			return GetRegex(strPattern).Matches(strInput);
		}
	}
}
