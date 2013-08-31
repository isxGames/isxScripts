namespace ISXEQ2DotNet
{
    partial class EQ2LocationsForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.EQ2LocationsList = new System.Windows.Forms.ListBox();
            this.label1 = new System.Windows.Forms.Label();
            this.NameLabel = new System.Windows.Forms.Label();
            this.ZoneLabel = new System.Windows.Forms.Label();
            this.NotesLabel = new System.Windows.Forms.Label();
            this.LocLabel = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // EQ2LocationsList
            // 
            this.EQ2LocationsList.FormattingEnabled = true;
            this.EQ2LocationsList.Location = new System.Drawing.Point(11, 18);
            this.EQ2LocationsList.Name = "EQ2LocationsList";
            this.EQ2LocationsList.Size = new System.Drawing.Size(421, 212);
            this.EQ2LocationsList.TabIndex = 0;
            this.EQ2LocationsList.SelectedIndexChanged += new System.EventHandler(this.EQ2LocationsList_SelectedIndexChanged);
            this.EQ2LocationsList.DoubleClick += new System.EventHandler(this.EQ2LocationsList_DoubleClick);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.ForeColor = System.Drawing.Color.Maroon;
            this.label1.Location = new System.Drawing.Point(20, 242);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(175, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "Highlight a row for more information.";
            // 
            // NameLabel
            // 
            this.NameLabel.AutoSize = true;
            this.NameLabel.Location = new System.Drawing.Point(20, 269);
            this.NameLabel.Name = "NameLabel";
            this.NameLabel.Size = new System.Drawing.Size(0, 13);
            this.NameLabel.TabIndex = 2;
            // 
            // ZoneLabel
            // 
            this.ZoneLabel.AutoSize = true;
            this.ZoneLabel.Location = new System.Drawing.Point(20, 294);
            this.ZoneLabel.Name = "ZoneLabel";
            this.ZoneLabel.Size = new System.Drawing.Size(0, 13);
            this.ZoneLabel.TabIndex = 3;
            // 
            // NotesLabel
            // 
            this.NotesLabel.AutoSize = true;
            this.NotesLabel.Location = new System.Drawing.Point(20, 344);
            this.NotesLabel.Name = "NotesLabel";
            this.NotesLabel.Size = new System.Drawing.Size(0, 13);
            this.NotesLabel.TabIndex = 4;
            // 
            // LocLabel
            // 
            this.LocLabel.AutoSize = true;
            this.LocLabel.Location = new System.Drawing.Point(20, 319);
            this.LocLabel.Name = "LocLabel";
            this.LocLabel.Size = new System.Drawing.Size(0, 13);
            this.LocLabel.TabIndex = 5;
            // 
            // EQ2LocationsForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(447, 422);
            this.Controls.Add(this.LocLabel);
            this.Controls.Add(this.NotesLabel);
            this.Controls.Add(this.ZoneLabel);
            this.Controls.Add(this.NameLabel);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.EQ2LocationsList);
            this.Name = "EQ2LocationsForm";
            this.Text = "EQ2LocationsForm";
            this.Load += new System.EventHandler(this.EQ2LocationsForm_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ListBox EQ2LocationsList;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label NameLabel;
        private System.Windows.Forms.Label ZoneLabel;
        private System.Windows.Forms.Label NotesLabel;
        private System.Windows.Forms.Label LocLabel;
    }
}