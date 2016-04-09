using System;
using System.Collections.Generic;
using System.Text;
using Vanguard.ISXVG;
using LavishVMAPI;
using InnerSpaceAPI;
using LavishScriptAPI;

namespace ISXVGDotNet
{
    static class Program
    {
        static void Main()
        {
            LavishVMAPI.Frame.Lock();

            Extension Ext = new Extension();
       
            string MyNameIs = "My Name is " + Ext.Me().FName + " " + Ext.Me().LName;
            InnerSpace.Echo(MyNameIs);

            LavishVMAPI.Frame.Unlock();
            return;
        }
    }
}
