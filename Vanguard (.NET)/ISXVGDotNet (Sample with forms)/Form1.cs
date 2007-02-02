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
            //LavishScriptObject ability = Me.Ability(1,true);
            //Ability tmp = new Ability(ability);
            Ability tmp = Me.Ability(1);
            NameLabel.Text = "OUTPUT: " + tmp.Name;
            InnerSpace.Echo(Me.Target.Name);
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Character Me = new Character();
            NameLabel.Text = "Name: " + Me.FName + Me.LName;
            button1.Visible = false;
            button2.Visible = true;
        }

        private void button2_Click(object sender, EventArgs e)
        {
            Character Me = new Character();
            NameLabel.Text = "Level: " + Me.Level.ToString();
            button2.Visible = false;
            button3.Visible = true;
        }

        private void button3_Click(object sender, EventArgs e)
        {
            Character Me = new Character();
            NameLabel.Text = "Health: " + Me.HealthStr;
            button3.Visible = false;
            button1.Visible = true;
        }
    }
}