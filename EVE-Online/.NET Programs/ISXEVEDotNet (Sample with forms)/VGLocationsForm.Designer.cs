namespace ISXEVEDotNet
{
    partial class VGLocationsForm
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
            this.VGLocationsList = new System.Windows.Forms.ListBox();
            this.label1 = new System.Windows.Forms.Label();
            this.NameLabel = new System.Windows.Forms.Label();
            this.ChunkLabel = new System.Windows.Forms.Label();
            this.XYZLabel = new System.Windows.Forms.Label();
            this.SectorXYLabel = new System.Windows.Forms.Label();
            this.NotesLabel = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // VGLocationsList
            // 
            this.VGLocationsList.FormattingEnabled = true;
            this.VGLocationsList.Location = new System.Drawing.Point(12, 7);
            this.VGLocationsList.MultiColumn = true;
            this.VGLocationsList.Name = "VGLocationsList";
            this.VGLocationsList.Size = new System.Drawing.Size(551, 251);
            this.VGLocationsList.TabIndex = 0;
            this.VGLocationsList.DoubleClick += new System.EventHandler(this.VGLocationsList_DoubleClick);
            this.VGLocationsList.Click += new System.EventHandler(this.VGLocationsList_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.ForeColor = System.Drawing.Color.Maroon;
            this.label1.Location = new System.Drawing.Point(26, 270);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(175, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "Highlight a row for more information.";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // NameLabel
            // 
            this.NameLabel.AutoSize = true;
            this.NameLabel.Location = new System.Drawing.Point(26, 297);
            this.NameLabel.Name = "NameLabel";
            this.NameLabel.Size = new System.Drawing.Size(0, 13);
            this.NameLabel.TabIndex = 2;
            // 
            // ChunkLabel
            // 
            this.ChunkLabel.AutoSize = true;
            this.ChunkLabel.Location = new System.Drawing.Point(26, 322);
            this.ChunkLabel.Name = "ChunkLabel";
            this.ChunkLabel.Size = new System.Drawing.Size(0, 13);
            this.ChunkLabel.TabIndex = 3;
            // 
            // XYZLabel
            // 
            this.XYZLabel.AutoSize = true;
            this.XYZLabel.Location = new System.Drawing.Point(26, 347);
            this.XYZLabel.Name = "XYZLabel";
            this.XYZLabel.Size = new System.Drawing.Size(0, 13);
            this.XYZLabel.TabIndex = 4;
            // 
            // SectorXYLabel
            // 
            this.SectorXYLabel.AutoSize = true;
            this.SectorXYLabel.Location = new System.Drawing.Point(26, 371);
            this.SectorXYLabel.Name = "SectorXYLabel";
            this.SectorXYLabel.Size = new System.Drawing.Size(0, 13);
            this.SectorXYLabel.TabIndex = 6;
            // 
            // NotesLabel
            // 
            this.NotesLabel.AutoSize = true;
            this.NotesLabel.Location = new System.Drawing.Point(26, 393);
            this.NotesLabel.Name = "NotesLabel";
            this.NotesLabel.Size = new System.Drawing.Size(0, 13);
            this.NotesLabel.TabIndex = 7;
            // 
            // VGLocationsForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(575, 522);
            this.Controls.Add(this.NotesLabel);
            this.Controls.Add(this.SectorXYLabel);
            this.Controls.Add(this.XYZLabel);
            this.Controls.Add(this.ChunkLabel);
            this.Controls.Add(this.NameLabel);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.VGLocationsList);
            this.Name = "VGLocationsForm";
            this.Text = "VGLocations";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ListBox VGLocationsList;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label NameLabel;
        private System.Windows.Forms.Label ChunkLabel;
        private System.Windows.Forms.Label XYZLabel;
        private System.Windows.Forms.Label SectorXYLabel;
        private System.Windows.Forms.Label NotesLabel;
    }
}