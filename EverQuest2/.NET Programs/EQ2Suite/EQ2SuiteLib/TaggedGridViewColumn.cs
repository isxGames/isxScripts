using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Controls;
using System.Windows;

namespace EQ2SuiteLib
{
	public class TaggedGridViewColumn : GridViewColumn
	{
		public static readonly DependencyProperty s_TagProperty = DependencyProperty.Register(
			"Tag",
			typeof(string),
			typeof(TaggedGridViewColumn),
			new FrameworkPropertyMetadata(string.Empty, FrameworkPropertyMetadataOptions.None, OnTagChanged),
			OnValidateTag);

		public static readonly DependencyProperty s_IncludeInDefaultViewProperty = DependencyProperty.Register(
			"IncludeInDefaultView",
			typeof(bool),
			typeof(TaggedGridViewColumn),
			new FrameworkPropertyMetadata(true, OnIncludeInDefaultViewChanged));

		public static readonly DependencyProperty s_IsPrimaryKeyProperty = DependencyProperty.Register(
			"IsPrimaryKey",
			typeof(bool),
			typeof(TaggedGridViewColumn),
			new FrameworkPropertyMetadata(true, OnIsPrimaryKeyChanged));

		/***************************************************************************/
		static TaggedGridViewColumn()
		{
			return;
		}

		/***************************************************************************/
		protected static bool OnValidateTag(object objValue)
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
		private static void OnTagChanged(DependencyObject obj, DependencyPropertyChangedEventArgs e)
		{
			return;
		}

		/***************************************************************************/
		private static void OnIncludeInDefaultViewChanged(DependencyObject obj, DependencyPropertyChangedEventArgs e)
		{
			return;
		}

		/***************************************************************************/
		private static void OnIsPrimaryKeyChanged(DependencyObject obj, DependencyPropertyChangedEventArgs e)
		{
			return;
		}

		/***************************************************************************/
		/// <summary>
		/// GridViewColumnHeader has a Tag property but it is by no means convenient.
		/// </summary>
		public string Tag
		{
			get { return (string)GetValue(s_TagProperty); }
			set { SetValue(s_TagProperty, value); }
		}

		/***************************************************************************/
		public bool IncludeInDefaultView
		{
			get { return (bool)GetValue(s_IncludeInDefaultViewProperty); }
			set { SetValue(s_IncludeInDefaultViewProperty, value); }
		}

		/***************************************************************************/
		public bool IsPrimaryKey
		{
			get { return (bool)GetValue(s_IsPrimaryKeyProperty); }
			set { SetValue(s_IsPrimaryKeyProperty, value); }
		}

		
	}
}
