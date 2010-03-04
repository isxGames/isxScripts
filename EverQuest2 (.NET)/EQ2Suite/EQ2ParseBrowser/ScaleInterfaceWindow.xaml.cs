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
using System.Windows.Shapes;
using EQ2SuiteLib;

namespace EQ2ParseBrowser
{
	/// <summary>
	/// Interaction logic for Window1.xaml
	/// </summary>
	public partial class ScaleInterfaceWindow : CustomBaseWindow
	{
		public ScaleInterfaceWindow() : base(App.s_ScaleInterfaceWindowLocation)
		{
			InitializeComponent();

			m_wndScaleSlider.Value = App.s_fInterfaceScaleFactor;

			return;
		}

		private void m_wndScaleSlider_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
		{
			if (IsInitialized)
			{
				App.s_fInterfaceScaleFactor = e.NewValue;
				CustomBaseWindow.UniversalScale = e.NewValue;
			}
			return;
		}
	}
}
