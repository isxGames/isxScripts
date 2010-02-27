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
		protected bool m_bCloseOnEscape = true;
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
		public bool CloseOnEscape
		{
			set
			{
				m_bCloseOnEscape = value;
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
					/*if (ResizeMode == ResizeMode.NoResize)
					{
						double fRescale = value / m_SavedWindowLocation.m_fScale;
						Height = FirstChild.ActualHeight * fRescale;
						Width = FirstChild.ActualWidth * fRescale;
					}*/

					if (value == 1.0)
						FirstChild.LayoutTransform = null;//Transform.Identity;
					else
						FirstChild.LayoutTransform = new ScaleTransform(value, value);
				}

				m_SavedWindowLocation.m_fScale = value;
				return;
			}
			get
			{
				return m_SavedWindowLocation.m_fScale;
			}
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
		protected override void OnInitialized(EventArgs e)
		{
			base.OnInitialized(e);

			if (m_SavedWindowLocation != null)
			{
				m_LastSavedWindowLocation = m_SavedWindowLocation.Copy();

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

		/***************************************************************************/
		public void ChangeExStyle(int iAddedStyles, int iRemovedStyles, uint? uiSetWindowPosFlags)
		{
			// Get this window's handle.
			IntPtr hwnd = new WindowInteropHelper(this).Handle;

			int iExtendedStyle = USER32.GetWindowLong(hwnd, USER32.GWL_EXSTYLE);

			iExtendedStyle = iExtendedStyle | iAddedStyles;
			iExtendedStyle = iExtendedStyle & ~(iRemovedStyles);

			USER32.SetWindowLong(hwnd, USER32.GWL_EXSTYLE, iExtendedStyle);

			if (uiSetWindowPosFlags != null)
				USER32.SetWindowPos(hwnd, IntPtr.Zero, 0, 0, 0, 0, uiSetWindowPosFlags.Value);

			return;
		}

		/***************************************************************************/
		public static void RemoveSystemMenu(Window wndWindow)
		{
			// Get this window's handle
			IntPtr hwnd = new WindowInteropHelper(wndWindow).Handle;

			int iExtendedStyle = USER32.GetWindowLong(hwnd, USER32.GWL_EXSTYLE);
			USER32.SetWindowLong(hwnd, USER32.GWL_EXSTYLE, iExtendedStyle | USER32.WS_EX_DLGMODALFRAME);

			// Update the window's non-client area to reflect the changes
			USER32.SetWindowPos(hwnd, IntPtr.Zero, 0, 0, 0, 0, USER32.SWP_NOMOVE | USER32.SWP_NOSIZE | USER32.SWP_NOZORDER | USER32.SWP_FRAMECHANGED);
			return;
		}

		/************************************************************************************/
		protected override void OnSourceInitialized(EventArgs e)
		{
			base.OnSourceInitialized(e);

			const uint uiSetWindowPosFlags = USER32.SWP_NOMOVE | USER32.SWP_NOSIZE | USER32.SWP_NOZORDER | USER32.SWP_FRAMECHANGED;
			if (m_bShowSystemMenu)
				ChangeExStyle(0, USER32.WS_EX_DLGMODALFRAME, uiSetWindowPosFlags);
			else
				ChangeExStyle(USER32.WS_EX_DLGMODALFRAME, 0, uiSetWindowPosFlags);
			return;
		}

		/************************************************************************************/
		protected override void OnLocationChanged(EventArgs e)
		{
			base.OnLocationChanged(e);

			if (WindowState != WindowState.Maximized)  /// If the location changes because of maximize, this lies.
			{
				m_LastSavedWindowLocation = m_SavedWindowLocation.Copy();
				m_SavedWindowLocation.m_rcBounds.X = (float)Left;
				m_SavedWindowLocation.m_rcBounds.Y = (float)Top;
			}
			return;
		}

		/************************************************************************************/
		protected void OnSizeChanged(object sender, SizeChangedEventArgs e)
		{
			if (WindowState != WindowState.Maximized)
			{
				m_LastSavedWindowLocation = m_SavedWindowLocation.Copy();
				m_SavedWindowLocation.m_rcBounds.Height = (float)e.NewSize.Height;
				m_SavedWindowLocation.m_rcBounds.Width = (float)e.NewSize.Width;
			}
			return;
		}

		/************************************************************************************/
		protected override void OnStateChanged(EventArgs e)
		{
			base.OnStateChanged(e);

			m_SavedWindowLocation.m_bMaximized = (WindowState == WindowState.Maximized);

			/// OnLocationChanged was called first and fed a faulty WindowState value so we have to restore the old coordinates.
			if (WindowState == WindowState.Maximized || WindowState == WindowState.Minimized)
			{
				m_SavedWindowLocation.m_rcBounds = m_LastSavedWindowLocation.m_rcBounds;
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

	}
}
