using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;

namespace EQ2SuiteLib
{
	/// <summary>
	/// There's no sense implementing INotifyPropertyChanged the same exact way every single time.
	/// </summary>
	public abstract class NotifyPropertyChangedBase : INotifyPropertyChanged
	{
		/***************************************************************************/
		public event PropertyChangedEventHandler PropertyChanged;

		/***************************************************************************/
		protected void NotifyPropertyChanged(string strPropertyName)
		{
			if (PropertyChanged != null)
				PropertyChanged(this, new PropertyChangedEventArgs(strPropertyName));
			return;
		}
	}
}
