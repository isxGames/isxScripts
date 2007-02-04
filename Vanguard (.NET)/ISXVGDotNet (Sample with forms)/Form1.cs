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
        public Form1()
        {
            InitializeComponent();
            Character Me = new Character();
            Ability tmp = Me.Ability(1);
            NameLabel.Text = "The first ability in your AbilitiesArray is: " + tmp.Name;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Character Me = new Character();
            NameLabel.Text = "Your Name is: " + Me.FName + Me.LName;
            button1.Visible = false;
            button2.Visible = true;
        }

        private void button2_Click(object sender, EventArgs e)
        {
            Character Me = new Character();
            NameLabel.Text = "Your Level is: " + Me.Level.ToString();
            button2.Visible = false;
            button3.Visible = true;
        }

        private void button3_Click(object sender, EventArgs e)
        {
            Character Me = new Character();
            NameLabel.Text = "Your Health is: " + Me.HealthStr;
            button3.Visible = false;
            button4.Visible = true;
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