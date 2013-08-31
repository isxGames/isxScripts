using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Windows;
using System.Windows.Interop;
using EQ2SuiteLib;
using Microsoft.Win32;

namespace EQ2ParseBrowser
{
	/// <summary>
	/// Interaction logic for App.xaml
	/// </summary>
	public partial class App : Application
	{
		public static double s_fInterfaceScaleFactor = 1.0;
		public static SavedWindowLocation s_AboutWindowLocation = new SavedWindowLocation();
		public static SavedWindowLocation s_LogSourceManagerWindowLocation = new SavedWindowLocation();
		public static SavedWindowLocation s_MainWindowLocation = new SavedWindowLocation();
		public static SavedWindowLocation s_ScaleInterfaceWindowLocation = new SavedWindowLocation();
		public static PersistentDetailedListView.ColumnLayout s_LogSourceManagerListLayout = new PersistentDetailedListView.ColumnLayout();

		/***************************************************************************/
		protected override void OnStartup(StartupEventArgs e)
		{
			base.OnStartup(e);
			ReadRegistrySettings();

			if (s_fInterfaceScaleFactor < 0.5)
				s_fInterfaceScaleFactor = 0.5;

			CustomBaseWindow.UniversalScale = s_fInterfaceScaleFactor;
			return;
		}

		/***************************************************************************/
		protected override void OnExit(ExitEventArgs e)
		{
			base.OnExit(e);
			WriteRegistrySettings();
			return;
		}

		/***************************************************************************/
		protected static void TransferRegistrySettings(RegistryTransferKey.TransferMode eTransferMode)
		{
			try
			{
				using (RegistryTransferKey RootKey = new RegistryTransferKey(Registry.CurrentUser, @"Software\EQ2Suite\EQ2ParseBrowser", eTransferMode))
				{
					RootKey.TransferDouble("InterfaceScaleFactor", ref s_fInterfaceScaleFactor);
					RootKey.TransferWindowLocation("AboutWindow", s_AboutWindowLocation);
					RootKey.TransferWindowLocation("MainWindow", s_MainWindowLocation);
					RootKey.TransferWindowLocation("ScaleInterfaceWindow", s_ScaleInterfaceWindowLocation);

					using (RegistryTransferKey LogSourceManagerKey = new RegistryTransferKey(RootKey, "LogSourceManager", eTransferMode))
					{
						LogSourceManagerKey.TransferWindowLocation("Window", s_LogSourceManagerWindowLocation);
						LogSourceManagerKey.TransferPersistentDetailedListViewColumnLayout("List", s_LogSourceManagerListLayout);
					}
				}
			}
			catch
			{
				/// Oh well. Sing the blues. But one monkey don't stop the show.
			}
			return;
		}

		/***************************************************************************/
		public static void ReadRegistrySettings()
		{
			TransferRegistrySettings(RegistryTransferKey.TransferMode.Read);
			return;
		}

		/***************************************************************************/
		public static void WriteRegistrySettings()
		{
			TransferRegistrySettings(RegistryTransferKey.TransferMode.Write);
			return;
		}
	}
}
