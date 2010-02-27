using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Controls;
using System.Windows;

namespace EQ2SuiteLib
{
	/// <summary>
	/// http://geekswithblogs.net/kobush/archive/2007/04/08/CloseableTabItem.aspx
	/// </summary>
	public class CloseableTabItem : TabItem
	{
		/************************************************************************************/
		static CloseableTabItem()
		{
			/// "The instruction in static constructor informs the system that this element wants to use different style than it's parent.
			/// Since we are creating the default theme for the custom control it would be defined in generic\themes.xaml."
			DefaultStyleKeyProperty.OverrideMetadata(typeof(CloseableTabItem), new FrameworkPropertyMetadata(typeof(CloseableTabItem)));
			return;
		}

		/************************************************************************************/
		public static readonly RoutedEvent CloseTabEvent = EventManager.RegisterRoutedEvent("CloseTab", RoutingStrategy.Bubble, typeof(RoutedEventHandler), typeof(CloseableTabItem));
		public event RoutedEventHandler CloseTab
		{
			add { AddHandler(CloseTabEvent, value); }
			remove { RemoveHandler(CloseTabEvent, value); }
		}

		/************************************************************************************/
		public override void OnApplyTemplate()
		{
			base.OnApplyTemplate();

			Button wndCloseButton = base.GetTemplateChild("PART_Close") as Button;
			if (wndCloseButton != null)
				wndCloseButton.Click += new System.Windows.RoutedEventHandler(OnCloseButtonClick);
		}

		/************************************************************************************/
		void OnCloseButtonClick(object sender, System.Windows.RoutedEventArgs e)
		{
			this.RaiseEvent(new RoutedEventArgs(CloseTabEvent, this));
			return;
		}
	}
}
