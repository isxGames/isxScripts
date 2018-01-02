namespace LSProfilingParser
{
    partial class Form1
    {
        /// <summary>
        /// Требуется переменная конструктора.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Освободить все используемые ресурсы.
        /// </summary>
        /// <param name="disposing">истинно, если управляемый ресурс должен быть удален; иначе ложно.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Код, автоматически созданный конструктором форм Windows

        /// <summary>
        /// Обязательный метод для поддержки конструктора - не изменяйте
        /// содержимое данного метода при помощи редактора кода.
        /// </summary>
        private void InitializeComponent()
        {
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
			System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
			System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
			System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle();
			System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle();
			System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle5 = new System.Windows.Forms.DataGridViewCellStyle();
			System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle6 = new System.Windows.Forms.DataGridViewCellStyle();
			System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle7 = new System.Windows.Forms.DataGridViewCellStyle();
			System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle8 = new System.Windows.Forms.DataGridViewCellStyle();
			System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle9 = new System.Windows.Forms.DataGridViewCellStyle();
			System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle10 = new System.Windows.Forms.DataGridViewCellStyle();
			System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle11 = new System.Windows.Forms.DataGridViewCellStyle();
			System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle12 = new System.Windows.Forms.DataGridViewCellStyle();
			this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
			this.button1 = new System.Windows.Forms.Button();
			this.statusStrip1 = new System.Windows.Forms.StatusStrip();
			this.toolStripStatusLabel1 = new System.Windows.Forms.ToolStripStatusLabel();
			this.textBox1 = new System.Windows.Forms.TextBox();
			this.dataGridView1 = new System.Windows.Forms.DataGridView();
			this.id = new System.Windows.Forms.DataGridViewTextBoxColumn();
			this.AtomName = new System.Windows.Forms.DataGridViewTextBoxColumn();
			this.Calls = new System.Windows.Forms.DataGridViewTextBoxColumn();
			this.CPUPerCall = new System.Windows.Forms.DataGridViewTextBoxColumn();
			this.CPUTime = new System.Windows.Forms.DataGridViewTextBoxColumn();
			this.MEM = new System.Windows.Forms.DataGridViewTextBoxColumn();
			this.splitContainer1 = new System.Windows.Forms.SplitContainer();
			this.tabControl1 = new System.Windows.Forms.TabControl();
			this.tabPage1 = new System.Windows.Forms.TabPage();
			this.tabPage2 = new System.Windows.Forms.TabPage();
			this.dataGridView2 = new System.Windows.Forms.DataGridView();
			this.ParsedNum = new System.Windows.Forms.DataGridViewTextBoxColumn();
			this.ParsedCalls = new System.Windows.Forms.DataGridViewTextBoxColumn();
			this.ParsedCPUCnt = new System.Windows.Forms.DataGridViewTextBoxColumn();
			this.ParsedCPUTime = new System.Windows.Forms.DataGridViewTextBoxColumn();
			this.ParsedMemCnt = new System.Windows.Forms.DataGridViewTextBoxColumn();
			this.ParsedMemSize = new System.Windows.Forms.DataGridViewTextBoxColumn();
			this.ParsedCommand = new System.Windows.Forms.DataGridViewTextBoxColumn();
			this.LicenseLogo = new System.Windows.Forms.PictureBox();
			this.statusStrip1.SuspendLayout();
			((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
			((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
			this.splitContainer1.Panel1.SuspendLayout();
			this.splitContainer1.Panel2.SuspendLayout();
			this.splitContainer1.SuspendLayout();
			this.tabControl1.SuspendLayout();
			this.tabPage1.SuspendLayout();
			this.tabPage2.SuspendLayout();
			((System.ComponentModel.ISupportInitialize)(this.dataGridView2)).BeginInit();
			((System.ComponentModel.ISupportInitialize)(this.LicenseLogo)).BeginInit();
			this.SuspendLayout();
			// 
			// openFileDialog1
			// 
			this.openFileDialog1.Filter = "Text files|*.txt|All|*.*";
			this.openFileDialog1.InitialDirectory = "D:\\Program Files\\InnerSpace\\Scripts";
			this.openFileDialog1.FileOk += new System.ComponentModel.CancelEventHandler(this.openFileDialog1_FileOk);
			// 
			// button1
			// 
			this.button1.Location = new System.Drawing.Point(12, 9);
			this.button1.Name = "button1";
			this.button1.Size = new System.Drawing.Size(75, 23);
			this.button1.TabIndex = 0;
			this.button1.Text = "Load dump";
			this.button1.UseVisualStyleBackColor = true;
			this.button1.Click += new System.EventHandler(this.button1_Click);
			// 
			// statusStrip1
			// 
			this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripStatusLabel1});
			this.statusStrip1.Location = new System.Drawing.Point(0, 579);
			this.statusStrip1.Name = "statusStrip1";
			this.statusStrip1.Size = new System.Drawing.Size(1469, 22);
			this.statusStrip1.TabIndex = 1;
			this.statusStrip1.Text = "statusStrip1";
			// 
			// toolStripStatusLabel1
			// 
			this.toolStripStatusLabel1.Name = "toolStripStatusLabel1";
			this.toolStripStatusLabel1.Size = new System.Drawing.Size(0, 17);
			// 
			// textBox1
			// 
			this.textBox1.AcceptsTab = true;
			this.textBox1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
			this.textBox1.Font = new System.Drawing.Font("Lucida Console", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
			this.textBox1.Location = new System.Drawing.Point(6, 6);
			this.textBox1.Multiline = true;
			this.textBox1.Name = "textBox1";
			this.textBox1.ScrollBars = System.Windows.Forms.ScrollBars.Both;
			this.textBox1.Size = new System.Drawing.Size(1063, 494);
			this.textBox1.TabIndex = 2;
			this.textBox1.Text = resources.GetString("textBox1.Text");
			this.textBox1.WordWrap = false;
			// 
			// dataGridView1
			// 
			this.dataGridView1.AllowUserToAddRows = false;
			this.dataGridView1.AllowUserToDeleteRows = false;
			this.dataGridView1.AllowUserToResizeRows = false;
			this.dataGridView1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
			this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
			this.dataGridView1.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.id,
            this.AtomName,
            this.Calls,
            this.CPUPerCall,
            this.CPUTime,
            this.MEM});
			this.dataGridView1.Location = new System.Drawing.Point(3, 0);
			this.dataGridView1.MultiSelect = false;
			this.dataGridView1.Name = "dataGridView1";
			this.dataGridView1.ReadOnly = true;
			this.dataGridView1.RowHeadersVisible = false;
			this.dataGridView1.Size = new System.Drawing.Size(374, 532);
			this.dataGridView1.TabIndex = 3;
			this.dataGridView1.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dataGridView1_CellContentClick);
			this.dataGridView1.CellStateChanged += new System.Windows.Forms.DataGridViewCellStateChangedEventHandler(this.dataGridView1_CellStateChanged);
			this.dataGridView1.SortCompare += new System.Windows.Forms.DataGridViewSortCompareEventHandler(this.dataGridView1_SortCompare);
			// 
			// id
			// 
			this.id.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
			this.id.HeaderText = "id";
			this.id.Name = "id";
			this.id.ReadOnly = true;
			this.id.Visible = false;
			// 
			// AtomName
			// 
			this.AtomName.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
			dataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.TopLeft;
			this.AtomName.DefaultCellStyle = dataGridViewCellStyle1;
			this.AtomName.HeaderText = "Name";
			this.AtomName.Name = "AtomName";
			this.AtomName.ReadOnly = true;
			this.AtomName.Width = 60;
			// 
			// Calls
			// 
			this.Calls.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
			dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleRight;
			dataGridViewCellStyle2.Format = "N0";
			dataGridViewCellStyle2.NullValue = null;
			this.Calls.DefaultCellStyle = dataGridViewCellStyle2;
			this.Calls.HeaderText = "Calls";
			this.Calls.Name = "Calls";
			this.Calls.ReadOnly = true;
			this.Calls.Width = 54;
			// 
			// CPUPerCall
			// 
			this.CPUPerCall.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
			dataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleRight;
			dataGridViewCellStyle3.Format = "N3";
			dataGridViewCellStyle3.NullValue = null;
			this.CPUPerCall.DefaultCellStyle = dataGridViewCellStyle3;
			this.CPUPerCall.HeaderText = "CPU Per Call";
			this.CPUPerCall.Name = "CPUPerCall";
			this.CPUPerCall.ReadOnly = true;
			this.CPUPerCall.Width = 93;
			// 
			// CPUTime
			// 
			this.CPUTime.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
			dataGridViewCellStyle4.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleRight;
			dataGridViewCellStyle4.Format = "N0";
			dataGridViewCellStyle4.NullValue = null;
			this.CPUTime.DefaultCellStyle = dataGridViewCellStyle4;
			this.CPUTime.HeaderText = "CPU Time";
			this.CPUTime.Name = "CPUTime";
			this.CPUTime.ReadOnly = true;
			this.CPUTime.Width = 80;
			// 
			// MEM
			// 
			this.MEM.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
			dataGridViewCellStyle5.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleRight;
			dataGridViewCellStyle5.Format = "N4";
			dataGridViewCellStyle5.NullValue = null;
			this.MEM.DefaultCellStyle = dataGridViewCellStyle5;
			this.MEM.HeaderText = "MEM";
			this.MEM.Name = "MEM";
			this.MEM.ReadOnly = true;
			this.MEM.Width = 57;
			// 
			// splitContainer1
			// 
			this.splitContainer1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
			this.splitContainer1.Location = new System.Drawing.Point(0, 41);
			this.splitContainer1.Name = "splitContainer1";
			// 
			// splitContainer1.Panel1
			// 
			this.splitContainer1.Panel1.Controls.Add(this.dataGridView1);
			// 
			// splitContainer1.Panel2
			// 
			this.splitContainer1.Panel2.Controls.Add(this.tabControl1);
			this.splitContainer1.Size = new System.Drawing.Size(1469, 535);
			this.splitContainer1.SplitterDistance = 376;
			this.splitContainer1.TabIndex = 4;
			// 
			// tabControl1
			// 
			this.tabControl1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
			this.tabControl1.Controls.Add(this.tabPage1);
			this.tabControl1.Controls.Add(this.tabPage2);
			this.tabControl1.Location = new System.Drawing.Point(3, 3);
			this.tabControl1.Name = "tabControl1";
			this.tabControl1.SelectedIndex = 0;
			this.tabControl1.Size = new System.Drawing.Size(1083, 532);
			this.tabControl1.TabIndex = 3;
			// 
			// tabPage1
			// 
			this.tabPage1.Controls.Add(this.textBox1);
			this.tabPage1.Location = new System.Drawing.Point(4, 22);
			this.tabPage1.Name = "tabPage1";
			this.tabPage1.Padding = new System.Windows.Forms.Padding(3);
			this.tabPage1.Size = new System.Drawing.Size(1075, 506);
			this.tabPage1.TabIndex = 0;
			this.tabPage1.Text = "Raw";
			this.tabPage1.UseVisualStyleBackColor = true;
			// 
			// tabPage2
			// 
			this.tabPage2.Controls.Add(this.dataGridView2);
			this.tabPage2.Location = new System.Drawing.Point(4, 22);
			this.tabPage2.Name = "tabPage2";
			this.tabPage2.Padding = new System.Windows.Forms.Padding(3);
			this.tabPage2.Size = new System.Drawing.Size(1075, 506);
			this.tabPage2.TabIndex = 1;
			this.tabPage2.Text = "Parsed";
			this.tabPage2.UseVisualStyleBackColor = true;
			// 
			// dataGridView2
			// 
			this.dataGridView2.AllowUserToAddRows = false;
			this.dataGridView2.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
			this.dataGridView2.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
			this.dataGridView2.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.ParsedNum,
            this.ParsedCalls,
            this.ParsedCPUCnt,
            this.ParsedCPUTime,
            this.ParsedMemCnt,
            this.ParsedMemSize,
            this.ParsedCommand});
			this.dataGridView2.Cursor = System.Windows.Forms.Cursors.Default;
			this.dataGridView2.Location = new System.Drawing.Point(6, 6);
			this.dataGridView2.MultiSelect = false;
			this.dataGridView2.Name = "dataGridView2";
			this.dataGridView2.ReadOnly = true;
			this.dataGridView2.RowHeadersVisible = false;
			this.dataGridView2.RowTemplate.Resizable = System.Windows.Forms.DataGridViewTriState.False;
			this.dataGridView2.Size = new System.Drawing.Size(1063, 494);
			this.dataGridView2.TabIndex = 0;
			// 
			// ParsedNum
			// 
			this.ParsedNum.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
			dataGridViewCellStyle6.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleCenter;
			dataGridViewCellStyle6.Format = "N0";
			dataGridViewCellStyle6.NullValue = null;
			this.ParsedNum.DefaultCellStyle = dataGridViewCellStyle6;
			this.ParsedNum.HeaderText = "num";
			this.ParsedNum.Name = "ParsedNum";
			this.ParsedNum.ReadOnly = true;
			this.ParsedNum.Width = 52;
			// 
			// ParsedCalls
			// 
			dataGridViewCellStyle7.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleRight;
			dataGridViewCellStyle7.Format = "N0";
			dataGridViewCellStyle7.NullValue = null;
			this.ParsedCalls.DefaultCellStyle = dataGridViewCellStyle7;
			this.ParsedCalls.HeaderText = "calls";
			this.ParsedCalls.Name = "ParsedCalls";
			this.ParsedCalls.ReadOnly = true;
			// 
			// ParsedCPUCnt
			// 
			dataGridViewCellStyle8.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleRight;
			dataGridViewCellStyle8.Format = "N0";
			dataGridViewCellStyle8.NullValue = null;
			this.ParsedCPUCnt.DefaultCellStyle = dataGridViewCellStyle8;
			this.ParsedCPUCnt.HeaderText = "cpu cnt";
			this.ParsedCPUCnt.Name = "ParsedCPUCnt";
			this.ParsedCPUCnt.ReadOnly = true;
			// 
			// ParsedCPUTime
			// 
			dataGridViewCellStyle9.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleRight;
			dataGridViewCellStyle9.Format = "N3";
			dataGridViewCellStyle9.NullValue = null;
			this.ParsedCPUTime.DefaultCellStyle = dataGridViewCellStyle9;
			this.ParsedCPUTime.HeaderText = "cpu time";
			this.ParsedCPUTime.Name = "ParsedCPUTime";
			this.ParsedCPUTime.ReadOnly = true;
			// 
			// ParsedMemCnt
			// 
			dataGridViewCellStyle10.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleRight;
			this.ParsedMemCnt.DefaultCellStyle = dataGridViewCellStyle10;
			this.ParsedMemCnt.HeaderText = "mem cnt";
			this.ParsedMemCnt.Name = "ParsedMemCnt";
			this.ParsedMemCnt.ReadOnly = true;
			// 
			// ParsedMemSize
			// 
			dataGridViewCellStyle11.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleRight;
			this.ParsedMemSize.DefaultCellStyle = dataGridViewCellStyle11;
			this.ParsedMemSize.HeaderText = "mem size";
			this.ParsedMemSize.Name = "ParsedMemSize";
			this.ParsedMemSize.ReadOnly = true;
			// 
			// ParsedCommand
			// 
			this.ParsedCommand.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
			dataGridViewCellStyle12.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
			this.ParsedCommand.DefaultCellStyle = dataGridViewCellStyle12;
			this.ParsedCommand.HeaderText = "command";
			this.ParsedCommand.Name = "ParsedCommand";
			this.ParsedCommand.ReadOnly = true;
			// 
			// LicenseLogo
			// 
			this.LicenseLogo.Image = global::LSProfilingParser.Properties.Resources.CC_License_88x31;
			this.LicenseLogo.ImageLocation = "";
			this.LicenseLogo.InitialImage = global::LSProfilingParser.Properties.Resources.CC_License_88x31;
			this.LicenseLogo.Location = new System.Drawing.Point(1380, -2);
			this.LicenseLogo.Name = "LicenseLogo";
			this.LicenseLogo.Size = new System.Drawing.Size(89, 29);
			this.LicenseLogo.TabIndex = 6;
			this.LicenseLogo.TabStop = false;
			this.LicenseLogo.Click += new System.EventHandler(this.LicenseLogo_Click);
			// 
			// Form1
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(1469, 601);
			this.Controls.Add(this.LicenseLogo);
			this.Controls.Add(this.splitContainer1);
			this.Controls.Add(this.statusStrip1);
			this.Controls.Add(this.button1);
			this.Name = "Form1";
			this.Text = "LavishScript Profile Data Parser by St!ff & CyberTech (Build 10.0.0.0)";
			this.statusStrip1.ResumeLayout(false);
			this.statusStrip1.PerformLayout();
			((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
			this.splitContainer1.Panel1.ResumeLayout(false);
			this.splitContainer1.Panel2.ResumeLayout(false);
			((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
			this.splitContainer1.ResumeLayout(false);
			this.tabControl1.ResumeLayout(false);
			this.tabPage1.ResumeLayout(false);
			this.tabPage1.PerformLayout();
			this.tabPage2.ResumeLayout(false);
			((System.ComponentModel.ISupportInitialize)(this.dataGridView2)).EndInit();
			((System.ComponentModel.ISupportInitialize)(this.LicenseLogo)).EndInit();
			this.ResumeLayout(false);
			this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.OpenFileDialog openFileDialog1;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.StatusStrip statusStrip1;
        private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabel1;
        private System.Windows.Forms.TextBox textBox1;
        private System.Windows.Forms.DataGridView dataGridView1;
		private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.TabControl tabControl1;
        private System.Windows.Forms.TabPage tabPage1;
        private System.Windows.Forms.TabPage tabPage2;
		private System.Windows.Forms.DataGridView dataGridView2;
		private System.Windows.Forms.PictureBox LicenseLogo;
		private System.Windows.Forms.DataGridViewTextBoxColumn id;
		private System.Windows.Forms.DataGridViewTextBoxColumn AtomName;
		private System.Windows.Forms.DataGridViewTextBoxColumn Calls;
		private System.Windows.Forms.DataGridViewTextBoxColumn CPUPerCall;
		private System.Windows.Forms.DataGridViewTextBoxColumn CPUTime;
		private System.Windows.Forms.DataGridViewTextBoxColumn MEM;
		private System.Windows.Forms.DataGridViewTextBoxColumn ParsedNum;
		private System.Windows.Forms.DataGridViewTextBoxColumn ParsedCalls;
		private System.Windows.Forms.DataGridViewTextBoxColumn ParsedCPUCnt;
		private System.Windows.Forms.DataGridViewTextBoxColumn ParsedCPUTime;
		private System.Windows.Forms.DataGridViewTextBoxColumn ParsedMemCnt;
		private System.Windows.Forms.DataGridViewTextBoxColumn ParsedMemSize;
		private System.Windows.Forms.DataGridViewTextBoxColumn ParsedCommand;

    }
}

