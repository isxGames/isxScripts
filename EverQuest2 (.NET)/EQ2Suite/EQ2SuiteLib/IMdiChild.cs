using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Controls;

namespace EQ2SuiteLib
{
	public interface IMdiChild
	{
		string ID { get; }
		UserControl Control { get; }
		bool TryClose();
	}
}
