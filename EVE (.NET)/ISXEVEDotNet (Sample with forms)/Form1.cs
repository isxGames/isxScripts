using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using EVE.ISXEVE;
using LavishVMAPI;
using InnerSpaceAPI;
using LavishScriptAPI;

namespace ISXEVEDotNet
{
    public partial class Form1 : System.Windows.Forms.Form
    {
        //private VGEvents Events = new VGEvents();

        public Form1()
        {
            InitializeComponent();
            using (new FrameLock(true))
            {
                NameLabel.Text = "Your character's name is " + Extension.Me().Name;
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            using (new FrameLock(true))
            {
                NameLabel.Text = "Your active ship has " + Extension.Me().Ship().HighSlots + " high slots.";
            }
            button1.Visible = false;
            button2.Visible = true;
        }

        private void button2_Click(object sender, EventArgs e)
        {
            using (new FrameLock(true))
            {
                NameLabel.Text = "Your active ship has " + Extension.Me().Ship().MediumSlots + " medium slots.";
            }
            button2.Visible = false;
            button3.Visible = true;
        }

        private void button3_Click(object sender, EventArgs e)
        {
            using (new FrameLock(true))
            {
                NameLabel.Text = "Your active ship has " + Extension.Me().Ship().LowSlots + " low slots.";
            }
            button3.Visible = false;
            button4.Visible = true;
        }

        private void button4_Click(object sender, EventArgs e)
        {
            using (new FrameLock(true))
            {
                if (Extension.Me().InStation)
                {
                    NameLabel.Text = "Undocking...";
                    Extension.EVE().Execute(ExecuteCommand.CmdExitStation);
                }
                else
                {
                    NameLabel.Text = "You are in space.";
                }
            }

            button4.Visible = false;
            button1.Visible = true;
        }
    }
}