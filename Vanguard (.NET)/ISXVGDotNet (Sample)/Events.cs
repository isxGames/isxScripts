using System;
using System.Collections.Generic;
using System.Text;
using Vanguard.ISXVG;
using LavishVMAPI;
using InnerSpaceAPI;
using LavishScriptAPI;

namespace ISXVGDotNet
{
    // Simple example on how to utilize events that are sent by ISXVG (onIncomingText, in this instance) and how to send a custom event called "MyCustomEvent".
    //
    // You'll notice that this class is created as a part of the Form1 class.  Therefore, the event hooks that it utilizeswill be active when that form (or any class that 
    // creates an object of it is alive and/or active.)
    public class VGEvents
    {
        private VGEvent vgevent = new VGEvent();
        private ExceptionHandler eh = new ExceptionHandler();
        private uint MyCustomEvent;

        public VGEvents()
        {
            try
            {
                // You can get a complete list of events by right clicking on "VGEvent" 8 lines above and choosing "Go to Definition".  Then, you would go to the ISXVG
                // wiki or the ISXVGChanges.txt file to determine the type and amount of arguments that are sent with the event.
                vgevent.IncomingText += new EventHandler<LSEventArgs>(vgevent_IncomingText);

                // for another script or extension to accept this event, it will need to "register" it using the same name that you used in the line below.
                MyCustomEvent = LavishScript.Events.RegisterEvent("MyCustomEvent");
            }
            catch (Exception ex)
            {
                eh.WriteOutput(ex);
            }
        }

        public void vgevent_IncomingText(object sender, LSEventArgs e)
        {
            string Text = e.Args[0];
            string ChannelNumber = e.Args[1];
            string ChannelName = e.Args[2];

            // Uncomment these two lines if you wish to see it in action.
            string Output = "Incoming Text -> [" + Text + "]  {Channel: " + ChannelName + " (" + ChannelNumber + ")}";
            InnerSpace.Echo(Output);

            return;
        }

        public void SendMyCustomEvent(string Name, string Type, string Description, int SomeNumber)
        {
            // this event gets sent with 4 arguments:  Name, Type, Description, and SomeNumber
            //
            // To call this event, you would simply do something like:
            //     VGEvents Events = new VGEvents();
            //     Events.SendMyCustomEvent("Amadeus","God","The Maestro",2007);

            string[] Args = {
                Name,
                Type,
                Description,
                SomeNumber.ToString()
            };

            LavishScript.Events.ExecuteEvent(MyCustomEvent, Args);

            //
            // Also note, if you were going to send an event with no arguments at all, it would be something like:
            // LavishScript.Events.ExecuteEvent(MyCustomEvent,null);

            //
            // Finally, you can call the "ExecuteEvent" anywhere in your code you wish as long as you have the proper ID# for the event (which must be 'registered') as it 
            // is in the constructor above.
        }
    }
}
