using System;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;

namespace ISXEVEDotNet
{
    // ExceptionHandler class by Karye
    public class ExceptionHandler
    {
        public ExceptionHandler()
            : base()
        {

        }

        public void WriteOutput(Exception ex)
        {
            string msg;

            Debug.WriteLine(ex.TargetSite.Name);
            Debug.WriteLine(ex.Message);
            Debug.WriteLine(ex.StackTrace);

            msg = String.Format("An error occurred: {0} {1} {2} {3}", ex.Message, ex.TargetSite.Name, ex.Source, ex.StackTrace);
            System.Windows.Forms.MessageBox.Show(msg);
        }
    }
}
