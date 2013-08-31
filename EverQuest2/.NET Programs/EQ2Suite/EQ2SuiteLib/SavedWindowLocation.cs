using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;

namespace EQ2SuiteLib
{
	public class SavedWindowLocation : ICloneable
	{
		public RectangleF m_rcBounds;
		public bool m_bMaximized = false;
		public double m_fScale = 1.0;

		/************************************************************************************/
		public object Clone()
		{
			return Copy();
		}

		/************************************************************************************/
		public SavedWindowLocation Copy()
		{
			SavedWindowLocation NewCopy = new SavedWindowLocation();
			NewCopy.m_rcBounds = m_rcBounds;
			NewCopy.m_bMaximized = m_bMaximized;
			NewCopy.m_fScale = m_fScale;
			return NewCopy;
		}
	}
}
