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
		public static readonly DependencyProperty s_IDProperty;
		public static readonly DependencyProperty s_IncludeInDefaultViewProperty;

		/***************************************************************************/
		static NamedGridViewColumn()
		{
			s_IDProperty = DependencyProperty.Register(
				"ID",
				typeof(string),
				typeof(NamedGridViewColumn),
				new FrameworkPropertyMetadata(string.Empty, FrameworkPropertyMetadataOptions.None, OnIDChanged),
				OnValidateID);

			s_IncludeInDefaultViewProperty = DependencyProperty.Register(
				"IncludeInDefaultView",
				typeof(bool),
				typeof(NamedGridViewColumn),
				new FrameworkPropertyMetadata(true, OnIncludeInDefaultViewChanged));

			return;
		}

		/***************************************************************************/
		protected static bool OnValidateID(object objValue)
		{
			string strValue = (objValue as string);

			/// This doesn't work because default value is string.Empty and there's no way to enforce unique keying.
			/*if (string.IsNullOrEmpty(strValue))
				return false;*/

			foreach (char chThis in strValue)
				if (!char.IsLetterOrDigit(chThis))
					return false;

			return true;
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
			get { return (string)GetValue(s_IDProperty); }
			set { SetValue(s_IDProperty, value); }
		}

		/***************************************************************************/
		public bool IncludeInDefaultView
		{
			get { return (bool)GetValue(s_IncludeInDefaultViewProperty); }
			set { SetValue(s_IncludeInDefaultViewProperty, value); }
		}
	}
}
