using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using EQ2.ISXEQ2;
using LavishVMAPI;
using InnerSpaceAPI;
using LavishScriptAPI;

namespace ISXEQ2DotNet
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
            Extension Ext = new Extension();
            using (new FrameLock(true))
            {
                NameLabel.Text = "The first ability in your Abilities array is: " + Ext.Me().Ability(1).Name;
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Extension Ext = new Extension();
            using (new FrameLock(true))
            {
                NameLabel.Text = "Your Name is: " + Ext.Me().Name + " " + Ext.Me().ToActor().LastName;
            }
            button1.Visible = false;
            button2.Visible = true;
        }

        private void button2_Click(object sender, EventArgs e)
        {
            Extension Ext = new Extension();
            using (new FrameLock(true))
            {
                NameLabel.Text = "Your Level is: " + Ext.Me().Level.ToString();
            }
            button2.Visible = false;
            button3.Visible = true;
        }

        private void button3_Click(object sender, EventArgs e)
        {
            Extension Ext = new Extension();
            using (new FrameLock(true))
            {
                NameLabel.Text = "Your Health is: " + Ext.Me().Health.ToString();
            }
            button3.Visible = false;
            button4.Visible = true;
        }

        private void button4_Click(object sender, EventArgs e)
        {
            EQ2LocationsForm LocationsForm = new EQ2LocationsForm();
            LocationsForm.ShowDialog();

            button4.Visible = false;
            button1.Visible = true;
        }
    }
}