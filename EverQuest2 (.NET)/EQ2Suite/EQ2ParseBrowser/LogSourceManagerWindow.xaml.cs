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
	/***************************************************************************/
	/// <summary>
	/// This converts the enum to a string.
	/// </summary>
	[ValueConversion(typeof(LogSourceConfiguration.SourceType), typeof(string))]
	public class LogSourceConfiguration_SourceType_FormatConverter : IValueConverter
	{
		object IValueConverter.Convert(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture)
		{
			LogSourceConfiguration.SourceType eType = (LogSourceConfiguration.SourceType)value;
			return eType.ToString() + "!!";
		}
		object IValueConverter.ConvertBack(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture)
		{
			return null;
		}
	}

	/***************************************************************************/
	public class LogSourceConfiguration
	{
		private string m_DUMMYNAME = Guid.NewGuid().ToString("N");
		public string Name
		{
			get { return m_DUMMYNAME; }
		}

		public enum SourceType : int
		{
			Unknown = 0,
			File = 1,
			Socket = 2,
		}

		public SourceType Source
		{
			get
			{
				if (m_DUMMYNAME[0] == '2')
					return SourceType.File;
				else
					return SourceType.Socket;
			}
		}

		public string SourceContextString
		{
			get
			{
				return "asdflakwenw;elktnawe wlaektnawel;ktn weakltnwelkatn awekl;tn ";
			}
		}
	}

	/***************************************************************************/
	/// <summary>
	/// Interaction logic for LogSourceManagerWindow.xaml
	/// </summary>
	public partial class LogSourceManagerWindow : CustomBaseWindow
	{
		/***************************************************************************/
		public LogSourceManagerWindow()
			: base(App.s_LogSourceManagerWindowLocation)
		{
			InitializeComponent();
			m_wndSourceList.SavedLayout = App.s_LogSourceManagerListLayout;

			for (int iIndex = 0; iIndex < 100; iIndex++)
				m_wndSourceList.Items.Add(new LogSourceConfiguration());

			//ItemsSource is ObservableCollection of EmployeeInfo objects
			//m_wndSourceList.ItemsSource = new myEmployees();

			return;
		}

		/***************************************************************************/
		protected override void OnClosing(System.ComponentModel.CancelEventArgs e)
		{
			base.OnClosing(e);
			return;
		}

		/***************************************************************************/
		protected override void OnClosed(EventArgs e)
		{
			base.OnClosed(e);
			m_wndSourceList.SaveLayout();
			return;
		}

		/***************************************************************************/
		private void OnCloseButtonClick(object sender, RoutedEventArgs e)
		{
			Close();
			return;
		}

		/***************************************************************************/
		protected void OnSourceListItemActivated(object sender, RoutedEventArgs e)
		{
			return;
		}

	}
}
