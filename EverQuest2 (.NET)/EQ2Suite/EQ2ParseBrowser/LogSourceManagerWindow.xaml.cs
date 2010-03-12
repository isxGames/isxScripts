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
using System.ComponentModel;

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
	public class LogSourceConfiguration : NotifyPropertyChangedBase
	{
		protected string m_strName = string.Empty;
		public string Name
		{
			get
			{
				return m_strName;
			}
			set
			{
				if (m_strName != value)
				{
					m_strName = value;
					NotifyPropertyChanged("Name");
				}
				return;
			}
		}

		public enum SourceType : int
		{
			Unknown = 0,
			File = 1,
			Socket = 2,
		}

		protected SourceType m_eSourceType = SourceType.Unknown;
		public SourceType Source
		{
			get
			{
				return m_eSourceType;
			}
			set
			{
				if (m_eSourceType != value)
				{
					m_eSourceType = value;
					NotifyPropertyChanged("Source");
				}
				return;
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
		public List<LogSourceConfiguration> DUMMYLIST = new List<LogSourceConfiguration>();

		/***************************************************************************/
		public LogSourceManagerWindow()
			: base(App.s_LogSourceManagerWindowLocation)
		{
			InitializeComponent();
			m_wndSourceList.SavedLayout = App.s_LogSourceManagerListLayout;

			m_wndSourceList.ItemsSource = DUMMYLIST;

			for (int iIndex = 0; iIndex < 100; iIndex++)
			{
				LogSourceConfiguration NewConfig = new LogSourceConfiguration();
				NewConfig.Name = Guid.NewGuid().ToString("N");
				DUMMYLIST.Add(NewConfig);
			}

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
			/// DEBUG
			
			/*List<LogSourceConfiguration> TEMPLIST = new List<LogSourceConfiguration>();
			Random THISRANDOM = new Random();
			for (int iIndex = 0; iIndex < 1000; iIndex++)
			{
				LogSourceConfiguration NEWITEM = new LogSourceConfiguration();
				NEWITEM.m_DUMMYNAME = "!!!!" + THISRANDOM.NextDouble().ToString();
				TEMPLIST.Add(NEWITEM);
			}
			DUMMYLIST.AddRange(TEMPLIST);*/

			foreach (LogSourceConfiguration ThisConfig in DUMMYLIST)
				ThisConfig.Source = LogSourceConfiguration.SourceType.Unknown;
			m_wndSourceList.SortOnce();
			return;
		}

	}
}
