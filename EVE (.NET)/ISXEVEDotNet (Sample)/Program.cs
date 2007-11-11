using System;
using System.Collections.Generic;
using System.Text;
using EVE.ISXEVE;
using LavishVMAPI;
using InnerSpaceAPI;
using LavishScriptAPI;

namespace ISXEVEDotNet
{
    static class Program
    {
        static void Main()
        {
            LavishVMAPI.Frame.Lock();

            Me me = new Me();
            string MyNameIs = "My Name is " + me.Name;
            InnerSpace.Echo(MyNameIs);

            LavishVMAPI.Frame.Unlock();
            return;
        }
    }
}
