using System;
using System.Collections.Generic;
using System.Text;
using EVE.ISXEVE;
using LavishVMAPI;
using InnerSpaceAPI;
using LavishScriptAPI;

namespace ISXEVEDotNet
{
    public class EveEvents
    {
        Globals Globals = Globals.Instance;

        public EveEvents()
        {
            Globals.Ext.EVE().ActivateChannelMessageEvents();

            LavishScript.Events.AttachEventTarget("EVE_OnChannelMessage", event_EVE_OnChannelMessage);
        }

        ~EveEvents()
        {
            Globals.Ext.EVE().ActivateChannelMessageEvents();
        }

        public void event_EVE_OnChannelMessage(object sender, LSEventArgs e)
        {
            string Output = "Incoming Text -> [";
            foreach (string arg in e.Args)
            {
                Output += arg + ",";
            }
            Output = Output.Substring(0,Output.Length - 1) + "]";

            // Uncomment this line if you wish to see it in action.
            InnerSpace.Echo(Output);

            return;
        }

    }
}
