using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using Vanguard.ISXVG;
using LavishVMAPI;
using InnerSpaceAPI;
using LavishScriptAPI;

namespace ISXVGDotNet
{
    public partial class Form1 : System.Windows.Forms.Form
    {
        private VGEvents Events = new VGEvents();

        public Form1()
        {
            InitializeComponent();
            Extension Ext = new Extension();
            LavishVMAPI.Frame.Lock();
            NameLabel.Text = "The first ability in your AbilitiesArray is: " + Ext.Me().Ability(1).Name;
            LavishVMAPI.Frame.Unlock();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Extension Ext = new Extension();
            LavishVMAPI.Frame.Lock();
            NameLabel.Text = "Your Name is: " + Ext.Me().FName + " " + Ext.Me().LName;
            LavishVMAPI.Frame.Unlock();
            button1.Visible = false;
            button2.Visible = true;
        }

        private void button2_Click(object sender, EventArgs e)
        {
            Extension Ext = new Extension();
            LavishVMAPI.Frame.Lock();
            NameLabel.Text = "Your Level is: " + Ext.Me().Level.ToString();
            button2.Visible = false;
            button3.Visible = true;
            LavishVMAPI.Frame.Unlock();
        }

        private void button3_Click(object sender, EventArgs e)
        {
            Extension Ext = new Extension();
            LavishVMAPI.Frame.Lock();
            NameLabel.Text = "Your Health is: " + Ext.Me().HealthStr;
            button3.Visible = false;
            button4.Visible = true;
            LavishVMAPI.Frame.Unlock();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            VGLocationsForm LocationsForm = new VGLocationsForm();
            LocationsForm.ShowDialog();

            button4.Visible = false;
            button1.Visible = true;
        }
    }
}