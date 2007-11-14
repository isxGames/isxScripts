using System;
using System.Collections.Generic;
using System.Text;
using EVE.ISXEVE;
using LavishVMAPI;
using InnerSpaceAPI;
using LavishScriptAPI;

namespace ISXEVEDotNet
{
    public sealed class Globals
    {
        public static readonly Globals Instance = new Globals();

        public EVE.ISXEVE.Extension Ext = new EVE.ISXEVE.Extension();

        private Globals() { }
    }

    static class Program
    {
        static void Main()
        {
            Globals Globals = Globals.Instance;

            using (new FrameLock(true))
            {
                InnerSpace.Echo("Your character's name is " + Globals.Ext.Me().Name);
                InnerSpace.Echo("Your active ship has " + Globals.Ext.Me().Ship().HighSlots + " high slots.");
                InnerSpace.Echo("Your active ship has " + Globals.Ext.Me().Ship().MediumSlots + " medium slots.");
                InnerSpace.Echo("Your active ship has " + Globals.Ext.Me().Ship().LowSlots + " low slots.");
                if (Globals.Ext.Me().InStation)
                {
                    InnerSpace.Echo("Undocking...");
                    Globals.Ext.EVE().Execute(ExecuteCommand.CmdExitStation);
                }
                else
                {
                    InnerSpace.Echo("You are in space.");
                }

            }

            return;
        }
    }
}
