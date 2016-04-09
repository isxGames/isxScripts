using System;
using System.Collections.Generic;
using System.Windows.Forms;
using EVE.ISXEVE;
using LavishVMAPI;
using InnerSpaceAPI;
using LavishScriptAPI;

namespace ISXEVEDotNet
{
    static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new Form1());
        }
    }
}