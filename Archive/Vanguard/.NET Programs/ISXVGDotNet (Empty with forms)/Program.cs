using System;
using System.Collections.Generic;
using System.Windows.Forms;
using Vanguard.ISXVG;
using LavishVMAPI;
using InnerSpaceAPI;
using LavishScriptAPI;

namespace ISXVGDotNet
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