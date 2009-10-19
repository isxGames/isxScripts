using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2SuiteLib
{
	/// <summary>
	/// The premise for this class is simple; in a volume parsing scenario,
	/// it should help to contain memory cost by sharing references to identical strings.
	/// You don't need hundreds of instances of the same string.
	/// TODO: A debug version that counts the references made, as proof of concept.
	/// </summary>
	public class SharedStringCache
	{
		protected long m_lReferencesShared = 0;
		protected Dictionary<string, string> m_StringDictionary = new Dictionary<string, string>();

		public void Clear()
		{
			m_lReferencesShared = 0;
			m_StringDictionary.Clear();
			return;
		}

		public string GetSharedReference(string strString)
		{
			if (m_StringDictionary.ContainsKey(strString))
			{
				m_lReferencesShared++;
				return m_StringDictionary[strString];
			}

			m_StringDictionary.Add(strString, strString);
			return strString;
		}

	}
}
