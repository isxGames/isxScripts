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
    public partial class VGLocationsForm : System.Windows.Forms.Form
    {
        public VGLocationsForm()
        {
            InitializeComponent();
            ISXVG isxvg = new ISXVG();

            for (int i = 1; i < isxvg.VGLocsCount; i++)
            {
                VGLocation Loc = new VGLocation(i);

                if (Loc.Label.Length == 0) continue;

                VGLocationsList.Items.Add(i.ToString() + ". " + Loc.Label);
            }
            VGLocationsList.Items.Add("---");
            VGLocationsList.Items.Add("Total Locations: " + isxvg.VGLocsCount.ToString());
        }

        private void VGLocationsList_DoubleClick(object sender, EventArgs e)
        {
            InnerSpace.Echo(VGLocationsList.SelectedItem.ToString());
        }

        private void VGLocationsList_Click(object sender, EventArgs e)
        {
            VGLocation Loc = new VGLocation(VGLocationsList.SelectedItem.ToString());
            NameLabel.Text = "Name: " + Loc.Label;
            ChunkLabel.Text = "Chunk: " + Loc.MapDisplayName + "(" + Loc.ChunkX + " x " + Loc.ChunkY + ")";
            XYZLabel.Text = "Coordinates: " + Loc.X + ", " + Loc.Y + ", " + Loc.Z;
            SectorXYLabel.Text = "Sector: " + Loc.SectorX + " x " + Loc.SectorY;
            NotesLabel.Text = "Notes: " + Loc.Notes;
        }
    }
}