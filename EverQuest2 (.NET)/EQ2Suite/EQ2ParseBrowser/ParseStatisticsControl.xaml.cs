using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.ComponentModel;

namespace EQ2ParseBrowser
{
	/// <summary>
	/// Interaction logic for ParseStatisticsControl.xaml
	/// </summary>
	public partial class ParseStatisticsControl : UserControl
	{
		public ParseStatisticsControl()
		{
			InitializeComponent();

			/// Clear the dimensional properties in a running build to allow the control to fill the parent.
			if (LicenseManager.UsageMode != LicenseUsageMode.Designtime)
			{
				this.Width = double.NaN;
				this.Height = double.NaN;
			}

			return;
		}
	}
}
