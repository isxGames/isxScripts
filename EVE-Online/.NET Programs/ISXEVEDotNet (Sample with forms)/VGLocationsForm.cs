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
    public partial class VGLocationsForm : System.Windows.Forms.Form
    {

        public VGLocationsForm()
        {
            InitializeComponent();
            Extension Ext = new Extension();
            LavishVMAPI.Frame.Lock();
            ISXVG isxvg = Ext.ISXVG();


            for (int i = 1; i < isxvg.VGLocsCount; i++)
            {
                VGLocation Loc = new VGLocation(i);

                if (Loc.Label.Length == 0) continue;

                VGLocationsList.Items.Add(i.ToString() + ". " + Loc.Label);
            }
            VGLocationsList.Items.Add("---");
            VGLocationsList.Items.Add("Total Locations: " + isxvg.VGLocsCount.ToString());
            LavishVMAPI.Frame.Unlock();
        }

        private void VGLocationsList_DoubleClick(object sender, EventArgs e)
        {
            InnerSpace.Echo(VGLocationsList.SelectedItem.ToString());
        }

        private void VGLocationsList_Click(object sender, EventArgs e)
        {
            Extension Ext = new Extension();
            LavishVMAPI.Frame.Lock();
            string buf = VGLocationsList.SelectedItem.ToString();
            int PeriodLoc = buf.IndexOf(".") + 2;
            string Label = buf.Substring(PeriodLoc);
            VGLocation Loc = Ext.VGLoc(Label);
            NameLabel.Text = "Name: " + Loc.Label;
            ChunkLabel.Text = "Chunk: " + Loc.MapDisplayName + "(" + Loc.ChunkX + " x " + Loc.ChunkY + ")";
            XYZLabel.Text = "Coordinates: " + Loc.X + ", " + Loc.Y + ", " + Loc.Z;
            SectorXYLabel.Text = "Sector: " + Loc.SectorX + " x " + Loc.SectorY;
            NotesLabel.Text = "Notes: " + Loc.Notes;
            LavishVMAPI.Frame.Unlock();
        }
    }
}