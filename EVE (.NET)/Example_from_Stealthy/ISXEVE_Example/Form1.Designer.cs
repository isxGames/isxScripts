namespace ISXEVE_Example
{
    partial class Form1
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
            this.button_attachEvent = new System.Windows.Forms.Button();
            this.button_detachEvent = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // button_attachEvent
            // 
            this.button_attachEvent.Location = new System.Drawing.Point(12, 229);
            this.button_attachEvent.Name = "button_attachEvent";
            this.button_attachEvent.Size = new System.Drawing.Size(75, 23);
            this.button_attachEvent.TabIndex = 1;
            this.button_attachEvent.Text = "Attach";
            this.button_attachEvent.UseVisualStyleBackColor = true;
            this.button_attachEvent.Click += new System.EventHandler(this.button_attachEvent_Click);
            // 
            // button_detachEvent
            // 
            this.button_detachEvent.Location = new System.Drawing.Point(197, 229);
            this.button_detachEvent.Name = "button_detachEvent";
            this.button_detachEvent.Size = new System.Drawing.Size(75, 23);
            this.button_detachEvent.TabIndex = 4;
            this.button_detachEvent.Text = "Detach";
            this.button_detachEvent.UseVisualStyleBackColor = true;
            this.button_detachEvent.Click += new System.EventHandler(this.button_detachEvent_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(284, 264);
            this.Controls.Add(this.button_detachEvent);
            this.Controls.Add(this.button_attachEvent);
            this.Name = "Form1";
            this.Text = "Form1";
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button button_attachEvent;
        private System.Windows.Forms.Button button_detachEvent;
    }
}

