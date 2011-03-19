using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using EVE.ISXEVE;
using LavishScriptAPI;
using LavishVMAPI;

namespace ISXEVE_Example
{
    public partial class Form1 : Form
    {
        /* Our Me reference */
        private EVE.ISXEVE.Me _me;

        /* EventHandler for OnFrame */
        private EventHandler<LSEventArgs> OnFrame;

        public Form1()
        {
            InitializeComponent();
            /* Attach Pulse to our OnFrame event handler */
            OnFrame = new EventHandler<LSEventArgs>(Pulse);
        }

        /* Attach our OnFrame event handler to the LavishScript OnFrame event, in order to power our Pulse */
        private void button_attachEvent_Click(object sender, EventArgs e)
        {
            LavishScript.Events.AttachEventTarget("ISXEVE_OnFrame", OnFrame);
        }

        /* Pulse method that will execute on our OnFrame, which in turn executes on the lavishscript OnFrame */
        void Pulse(object sender, LSEventArgs e)
        {
            using (new FrameLock(true))
            {
                /* Update my Me reference */
                /* Note that this is being updated both OnFrame and in a FrameLock, this is how it has to be done. */
                _me = new EVE.ISXEVE.Me();

                /* Do whatever the hell we wanted to do here */
                InnerSpaceAPI.InnerSpace.Echo(String.Format("Im in ur innrspacez, echoin ur consolez! You  are {0}", _me.Name));
            }
        }

        /* Detach from the LS Event */
        private void button_detachEvent_Click(object sender, EventArgs e)
        {
            LavishScript.Events.DetachEventTarget("ISXEVE_OnFrame", OnFrame);
        }
    }

    /* EventArgs class for updating character info */
    public class UpdateCharInfoEventArgs : EventArgs
    {
        /* Properties for my Event args */
        public string CharacterName { get; set; }
        public string CorporationName { get; set; }
        public string AllianceName { get; set; }

        /* Constructor for EventArgs class */
        public UpdateCharInfoEventArgs(string characterName, string corporationName, string allianceName)
        {
            CharacterName = characterName;
            CorporationName = corporationName;
            AllianceName = allianceName;
        }
    }
}
