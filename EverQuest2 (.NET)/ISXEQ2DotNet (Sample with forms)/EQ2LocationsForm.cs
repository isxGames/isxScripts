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
    public partial class EQ2LocationsForm : Form
    {
        public EQ2LocationsForm()
        {
            InitializeComponent();
            Extension Ext = new Extension();
            using (new FrameLock(true))
            {
                ISXEQ2 isxeq2 = Ext.ISXEQ2();

                for (int i = 1; i < isxeq2.EQ2LocsCountAllZones; i++)
                {
                    EQ2Location Loc = new EQ2LocationAllZones(i);
                    if (Loc.Label.Length == 0) continue;

                    EQ2LocationsList.Items.Add(i.ToString() + ". " + Loc.Label);
                }
                EQ2LocationsList.Items.Add("---");
                EQ2LocationsList.Items.Add("Total Locations: " + isxeq2.EQ2LocsCountAllZones.ToString());
            }
        }


        private void EQ2LocationsForm_Load(object sender, EventArgs e)
        {
        }

        private void EQ2LocationsList_DoubleClick(object sender, EventArgs e)
        {
            InnerSpace.Echo(EQ2LocationsList.SelectedItem.ToString());
        }

        private void EQ2LocationsList_LeftClick(object Sender, EventArgs e)
        {
        }

        private void EQ2LocationsList_SelectedIndexChanged(object sender, EventArgs e)
        {
            Extension Ext = new Extension();
            using (new FrameLock(true))
            {
                string buf = EQ2LocationsList.SelectedItem.ToString();
                int PerioidLoc = buf.IndexOf(".") + 2;
                string Label = buf.Substring(PerioidLoc);
                EQ2Location Loc = Ext.EQ2LocAllZones(Label);
                NameLabel.Text = "Name: " + Loc.Label;
                ZoneLabel.Text = "Zone: " + Loc.Zone;
                LocLabel.Text = "Coordinates: " + Loc.X + ", " + Loc.Y + ", " + Loc.Z;
                NotesLabel.Text = "Notes: " + Loc.Notes;
            }
        }
    }
}