using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Media;
using PInvoke;
using System.Windows.Interop;
using System.Windows.Input;

namespace EQ2SuiteLib
{
	public class CustomBaseWindow : Window
	{
		protected IntPtr m_hWin32Window = IntPtr.Zero;
		protected bool m_bCloseOnEscape = true;
		protected bool m_bShowMinimizeButton = false;
		protected bool m_bShowSystemMenu = false;
		protected SavedWindowLocation m_SavedWindowLocation = null;
		protected SavedWindowLocation m_LastSavedWindowLocation = null;

		/************************************************************************************/
		static CustomBaseWindow()
		{
			//DefaultStyleKeyProperty.OverrideMetadata(typeof(StandardWindow), new FrameworkPropertyMetadata(typeof(StandardWindow)));
			return;
		}

		/************************************************************************************/
		public CustomBaseWindow()
		{
			SharedConstructor();
			return;
		}

		/************************************************************************************/
		public CustomBaseWindow(SavedWindowLocation ThisSavedLocation)
		{
			m_SavedWindowLocation = ThisSavedLocation;
			SharedConstructor();
			return;
		}

		/************************************************************************************/
		protected void SharedConstructor()
		{
			/// Oddly, there isn't a class override for this.
			SizeChanged += new SizeChangedEventHandler(OnSizeChanged);
			return;
		}

		/************************************************************************************/
		public bool CloseOnEscape
		{
			set
			{
				m_bCloseOnEscape = value;
				return;
			}
		}

		/************************************************************************************/
		/// <summary>
		/// This property doesn't work.
		/// </summary>
		public bool ShowMinimizeButton
		{
			set
			{
				m_bShowMinimizeButton = value;
				/// TODO: If window is live, apply the style immediately.
				return;
			}
		}

		/************************************************************************************/
		public bool ShowSystemMenu
		{
			set
			{
				m_bShowSystemMenu = value;
				/// TODO: If window is live, apply the style immediately.
				return;
			}
		}

		/************************************************************************************/
		public double Scale
		{
			set
			{
				/// Get the first child. Lucky us, Window can have ONLY one child.
				FrameworkElement FirstChild = null; 
				foreach (var ThisChild in LogicalTreeHelper.GetChildren(this))
				{
					if (ThisChild is FrameworkElement)
					{
						FirstChild = (ThisChild as FrameworkElement);
						break;
					}
				}

				if (FirstChild != null)
				{
					if (value == 1.0)
						FirstChild.LayoutTransform = Transform.Identity;
					else
						FirstChild.LayoutTransform = new ScaleTransform(value, value);
				}

				if (m_SavedWindowLocation != null)
					m_SavedWindowLocation.m_fScale = value;
				return;
			}
			get
			{
				if (m_SavedWindowLocation != null)
					return m_SavedWindowLocation.m_fScale;
				else
					return 1.0;
			}
		}

		/************************************************************************************/
		protected override void OnInitialized(EventArgs e)
		{
			base.OnInitialized(e);

			if (m_SavedWindowLocation != null && !m_SavedWindowLocation.m_rcBounds.IsEmpty)
			{
				Left = m_SavedWindowLocation.m_rcBounds.X;
				Top = m_SavedWindowLocation.m_rcBounds.Y;

				if (ResizeMode != ResizeMode.NoResize)
				{
					Width = m_SavedWindowLocation.m_rcBounds.Width;
					Height = m_SavedWindowLocation.m_rcBounds.Height;
				}

				if (ResizeMode == ResizeMode.CanResize)
				{
					if (m_SavedWindowLocation.m_bMaximized)
						WindowState = WindowState.Maximized;
					else
						WindowState = WindowState.Normal;
				}

				/// Feed the scale back into itself.
				Scale = m_SavedWindowLocation.m_fScale;
			}

			return;
		}

		/************************************************************************************/
		protected override void OnSourceInitialized(EventArgs e)
		{
			base.OnSourceInitialized(e);

			/// This value is constant for the life of the window.
			m_hWin32Window = new WindowInteropHelper(this).Handle;

			/// This doesn't work. I don't know why.
			/*
			if (m_bShowMinimizeButton)
				ChangeStyle(USER32.WindowStyles.MinimizeBox, 0);
			else
				ChangeStyle(0, USER32.WindowStyles.MinimizeBox);
			*/

			if (m_bShowSystemMenu)
				ChangeExStyle(0, USER32.WindowStylesEx.DialogModalFrame);
			else
				ChangeExStyle(USER32.WindowStylesEx.DialogModalFrame, 0);

			const USER32.SetWindowPosFlags eSetWindowPosFlags =
				USER32.SetWindowPosFlags.NoMove |
				USER32.SetWindowPosFlags.NoSize |
				USER32.SetWindowPosFlags.NoZOrder |
				USER32.SetWindowPosFlags.FrameChanged;
			USER32.SetWindowPos(m_hWin32Window, IntPtr.Zero, 0, 0, 0, 0, eSetWindowPosFlags);
			return;
		}

		/************************************************************************************/
		protected override void OnLocationChanged(EventArgs e)
		{
			base.OnLocationChanged(e);

			if (WindowState != WindowState.Maximized)  /// If the location changes because of maximize, this lies.
			{
				if (m_SavedWindowLocation != null)
				{
					m_LastSavedWindowLocation = m_SavedWindowLocation.Copy();
					m_SavedWindowLocation.m_rcBounds.X = (float)Left;
					m_SavedWindowLocation.m_rcBounds.Y = (float)Top;
				}
			}
			return;
		}

		/************************************************************************************/
		protected void OnSizeChanged(object sender, SizeChangedEventArgs e)
		{
			if (WindowState != WindowState.Maximized)
			{
				if (m_SavedWindowLocation != null)
				{
					m_SavedWindowLocation.m_rcBounds.Height = (float)e.NewSize.Height;
					m_SavedWindowLocation.m_rcBounds.Width = (float)e.NewSize.Width;
				}
			}
			return;
		}

		/************************************************************************************/
		protected override void OnStateChanged(EventArgs e)
		{
			base.OnStateChanged(e);

			if (m_SavedWindowLocation != null)
			{
				m_SavedWindowLocation.m_bMaximized = (WindowState == WindowState.Maximized);

				/// OnLocationChanged was called first and fed a faulty WindowState value so we have to restore the old coordinates.
				if (WindowState == WindowState.Maximized || WindowState == WindowState.Minimized)
				{
					m_SavedWindowLocation.m_rcBounds = m_LastSavedWindowLocation.m_rcBounds;
				}
			}

			return;
		}

		/************************************************************************************/
		protected override void OnKeyDown(KeyEventArgs e)
		{
			if (m_bCloseOnEscape && (e.Key == Key.Escape))
			{
				e.Handled = true;
				Close();
			}

			base.OnKeyDown(e);
			return;
		}

		/***************************************************************************/
		public void ChangeStyle(USER32.WindowStyles eAddedStyles, USER32.WindowStyles eRemovedStyles)
		{
			USER32.WindowStyles eExtendedStyle = (USER32.WindowStyles)USER32.GetWindowLong(m_hWin32Window, USER32.GWL_EXSTYLE);

			eExtendedStyle |= eAddedStyles;
			eExtendedStyle &= ~(eRemovedStyles);

			USER32.SetWindowLong(m_hWin32Window, USER32.GWL_EXSTYLE, (int)eExtendedStyle);
			return;
		}

		/***************************************************************************/
		public void ChangeExStyle(USER32.WindowStylesEx eAddedStyles, USER32.WindowStylesEx eRemovedStyles)
		{
			USER32.WindowStylesEx eExtendedStyle = (USER32.WindowStylesEx)USER32.GetWindowLong(m_hWin32Window, USER32.GWL_EXSTYLE);

			eExtendedStyle |= eAddedStyles;
			eExtendedStyle &= ~(eRemovedStyles);

			USER32.SetWindowLong(m_hWin32Window, USER32.GWL_EXSTYLE, (int)eExtendedStyle);
			return;
		}
	}
}
