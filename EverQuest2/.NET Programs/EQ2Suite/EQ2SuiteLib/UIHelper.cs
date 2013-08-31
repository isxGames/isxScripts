using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Markup;
using System.IO;
using System.Xml;
using System.Windows;

namespace EQ2SuiteLib
{
	public static class UIHelper
	{
		/// <summary>
		/// Ingenious!
		/// http://geekswithblogs.net/razan/archive/2009/09/18/how-can-we-make-a-deep-copy-of-a-wpf.aspx
		/// </summary>
		/// <param name="objElement"></param>
		/// <returns></returns>
		public static object DeepCopyXamlObject(object objElement)
		{
			string strXamlBody = XamlWriter.Save(objElement);
			StringReader stringReader = new StringReader(strXamlBody);
			XmlTextReader xmlTextReader = new XmlTextReader(stringReader);
			object objCopy = XamlReader.Load(xmlTextReader);

			return objCopy;
		}
}
}
