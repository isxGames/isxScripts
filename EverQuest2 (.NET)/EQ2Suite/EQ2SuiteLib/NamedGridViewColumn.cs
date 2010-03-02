using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Controls;
using System.Windows;

namespace EQ2SuiteLib
{
	public class NamedGridViewColumn : GridViewColumn
	{
		public static readonly DependencyProperty IDProperty;
		public static readonly DependencyProperty IncludeInDefaultViewProperty;

		/***************************************************************************/
		static NamedGridViewColumn()
		{
			IDProperty = DependencyProperty.Register(
				"ID",
				typeof(string),
				typeof(NamedGridViewColumn),
				new FrameworkPropertyMetadata(string.Empty, OnIDChanged));

			IncludeInDefaultViewProperty = DependencyProperty.Register(
				"IncludeInDefaultView",
				typeof(bool),
				typeof(NamedGridViewColumn),
				new FrameworkPropertyMetadata(true, OnIncludeInDefaultViewChanged));
		}

		/***************************************************************************/
		private static void OnIDChanged(DependencyObject obj, DependencyPropertyChangedEventArgs e)
		{
			return;
		}

		/***************************************************************************/
		private static void OnIncludeInDefaultViewChanged(DependencyObject obj, DependencyPropertyChangedEventArgs e)
		{
			return;
		}

		/***************************************************************************/
		public string ID
		{
			get { return (string)GetValue(IDProperty); }
			set { SetValue(IDProperty, value); }
		}

		/***************************************************************************/
		public bool IncludeInDefaultView
		{
			get { return (bool)GetValue(IncludeInDefaultViewProperty); }
			set { SetValue(IncludeInDefaultViewProperty, value); }
		}
	}
}
