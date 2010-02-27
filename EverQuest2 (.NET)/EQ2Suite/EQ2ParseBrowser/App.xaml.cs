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
		public static SavedWindowLocation s_MainWindowLocation = new SavedWindowLocation();
		public static SavedWindowLocation s_AboutWindowLocation = new SavedWindowLocation();
		public static SavedWindowLocation s_ScaleInterfaceWindowLocation = new SavedWindowLocation();

		/***************************************************************************/
		protected override void OnStartup(StartupEventArgs e)
		{
			base.OnStartup(e);
			ReadRegistrySettings();

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
		public static void SetCommonWindowScale(double fNewScale)
		{
			App ThisApp = (Application.Current as App);

			s_fInterfaceScaleFactor = fNewScale;

			foreach (Window ThisWindow in ThisApp.Windows)
			{
				if (ThisWindow is CustomBaseWindow)
					(ThisWindow as CustomBaseWindow).Scale = fNewScale;
			}

			return;
		}

		/***************************************************************************/
		protected static void TransferRegistrySettings(RegistryTransferKey.TransferMode eTransferMode)
		{
			try
			{
				RegistryTransferKey RootKey = new RegistryTransferKey(Registry.CurrentUser, @"Software\EQ2Suite\EQ2ParseBrowser", eTransferMode);
				RootKey.TransferDouble("InterfaceScaleFactor", ref s_fInterfaceScaleFactor);
				RootKey.TransferFormLocation("AboutWindow", s_AboutWindowLocation);
				RootKey.TransferFormLocation("MainWindow", s_MainWindowLocation);
				RootKey.TransferFormLocation("ScaleInterfaceWindow", s_ScaleInterfaceWindowLocation);
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
