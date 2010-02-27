using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EQ2SuiteLib;
using System.Windows.Controls;

namespace EQ2ParseBrowser
{
	public interface IMdiBaseChild : IMdiChild
	{
		/*
		string IMdiChild.ID { get { return string.Empty; } }
		UserControl IMdiChild.Control { get { return null; } }
		bool IMdiChild.TryClose() { return false; }
		 */

		bool CanClearAll { get; }
	}

	/// <summary>
	/// This is only for XAML. Such a puny definition that it doesn't need its own file.
	/// </summary>
	public class SharedMdiTabControl : MdiTabControl<IMdiBaseChild>
	{
	}

}
