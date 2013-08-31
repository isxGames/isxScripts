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

		public EVE.ISXEVE.Me Me;
		
		private Globals() { }
    }

    static class Program
    {
		static Globals Globals = Globals.Instance;
		static EveEvents evt = new EveEvents();

		static void Main()
        {
			InnerSpace.Echo("Attaching to ISXEVE_OnFrame");
			LavishScript.Events.AttachEventTarget("ISXEVE_OnFrame", ISXEVE_OnFrame);

            InnerSpace.Echo("Pausing for 1 minute...");
            System.Threading.Thread.Sleep(60000);
            InnerSpace.Echo("Exiting program.");

            return;
        }

		/* Pulse method that will execute on our OnFrame, which in turn executes on the lavishscript OnFrame */
		static void ISXEVE_OnFrame(object sender, LSEventArgs e)
		{
			using (new FrameLock(true))
			{
				/* Update my Me reference */
				/* Note that this is being updated both OnFrame and in a FrameLock, this is how it has to be done. */
				Globals.Me = new EVE.ISXEVE.Me();

				InnerSpace.Echo("Your character's name is " + Globals.Me.Name);
				InnerSpace.Echo("Your active ship has " + Globals.Me.Ship.HighSlots + " high slots.");
				InnerSpace.Echo("Your active ship has " + Globals.Me.Ship.MediumSlots + " medium slots.");
				InnerSpace.Echo("Your active ship has " + Globals.Me.Ship.LowSlots + " low slots.");
				if (Globals.Me.InStation)
				{
					// Uncomment the line below to actually undock
					//Globals.Me.Execute(ExecuteCommand.CmdExitStation);
				}
				else
				{
					InnerSpace.Echo("You are in space.");
				}

				LavishScript.Events.DetachEventTarget("ISXEVE_OnFrame", ISXEVE_OnFrame);
				InnerSpace.Echo("Detached from ISXEVE_OnFrame");
			}
		}
	
	
	}
}
