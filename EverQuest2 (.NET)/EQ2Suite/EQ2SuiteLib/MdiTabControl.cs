using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Controls;
using System.Windows.Markup;
using System.ComponentModel;

namespace EQ2SuiteLib
{
	//[ContentProperty("Tabs")]
	public class MdiTabControl : TabControl
	{
/*
protected TabControl m_wndTabs = new TabControl();

[TypeConverter()]
public TabControl Tabs
{
	get
	{
		return m_wndTabs;
	}
	set
	{
	}
}
<TabControl>
	<local:CloseableTabItem Header="Blackburrow.Icedaze">
		<local:ParseStatisticsControl />
	</local:CloseableTabItem>
	<local:CloseableTabItem Header="Blackburrow.Aleraku">
		<local:ParseStatisticsControl />
	</local:CloseableTabItem>
	<TabItem Header="Dummy Tab Item 2"></TabItem>
</TabControl>
*/
		public MdiTabControl()
		{
			return;
		}

		protected override void OnInitialized(EventArgs e)
		{
			base.OnInitialized(e);
			return;
		}
	}
}
