namespace ISXEVE_Bot_Framework.Forms
{
    partial class SelectCharacter
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
            this.listBox_accounts = new System.Windows.Forms.ListBox();
            this.listBox_characters = new System.Windows.Forms.ListBox();
            this.button_addAccount = new System.Windows.Forms.Button();
            this.button_removeAccount = new System.Windows.Forms.Button();
            this.button_editAccount = new System.Windows.Forms.Button();
            this.button_select = new System.Windows.Forms.Button();
            this.button_setAsDefault = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // listBox_accounts
            // 
            this.listBox_accounts.FormattingEnabled = true;
            this.listBox_accounts.Location = new System.Drawing.Point(12, 12);
            this.listBox_accounts.Name = "listBox_accounts";
            this.listBox_accounts.Size = new System.Drawing.Size(589, 95);
            this.listBox_accounts.TabIndex = 0;
            // 
            // listBox_characters
            // 
            this.listBox_characters.FormattingEnabled = true;
            this.listBox_characters.Location = new System.Drawing.Point(12, 113);
            this.listBox_characters.Name = "listBox_characters";
            this.listBox_characters.Size = new System.Drawing.Size(589, 95);
            this.listBox_characters.TabIndex = 1;
            // 
            // button_addAccount
            // 
            this.button_addAccount.Location = new System.Drawing.Point(12, 214);
            this.button_addAccount.Name = "button_addAccount";
            this.button_addAccount.Size = new System.Drawing.Size(75, 23);
            this.button_addAccount.TabIndex = 2;
            this.button_addAccount.Text = "Add";
            this.button_addAccount.UseVisualStyleBackColor = true;
            this.button_addAccount.Click += new System.EventHandler(this.button_addAccount_Click);
            // 
            // button_removeAccount
            // 
            this.button_removeAccount.Location = new System.Drawing.Point(140, 214);
            this.button_removeAccount.Name = "button_removeAccount";
            this.button_removeAccount.Size = new System.Drawing.Size(75, 23);
            this.button_removeAccount.TabIndex = 3;
            this.button_removeAccount.Text = "Remove";
            this.button_removeAccount.UseVisualStyleBackColor = true;
            this.button_removeAccount.Click += new System.EventHandler(this.button_removeAccount_Click);
            // 
            // button_editAccount
            // 
            this.button_editAccount.Location = new System.Drawing.Point(268, 214);
            this.button_editAccount.Name = "button_editAccount";
            this.button_editAccount.Size = new System.Drawing.Size(75, 23);
            this.button_editAccount.TabIndex = 4;
            this.button_editAccount.Text = "Edit";
            this.button_editAccount.UseVisualStyleBackColor = true;
            this.button_editAccount.Click += new System.EventHandler(this.button_editAccount_Click);
            // 
            // button_select
            // 
            this.button_select.Location = new System.Drawing.Point(396, 214);
            this.button_select.Name = "button_select";
            this.button_select.Size = new System.Drawing.Size(75, 23);
            this.button_select.TabIndex = 5;
            this.button_select.Text = "Select";
            this.button_select.UseVisualStyleBackColor = true;
            this.button_select.Click += new System.EventHandler(this.button_select_Click);
            // 
            // button_setAsDefault
            // 
            this.button_setAsDefault.Location = new System.Drawing.Point(524, 214);
            this.button_setAsDefault.Name = "button_setAsDefault";
            this.button_setAsDefault.Size = new System.Drawing.Size(75, 23);
            this.button_setAsDefault.TabIndex = 6;
            this.button_setAsDefault.Text = "Set Default";
            this.button_setAsDefault.UseVisualStyleBackColor = true;
            this.button_setAsDefault.Click += new System.EventHandler(this.button_setAsDefault_Click);
            // 
            // SelectCharacter
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(613, 243);
            this.Controls.Add(this.button_setAsDefault);
            this.Controls.Add(this.button_select);
            this.Controls.Add(this.button_editAccount);
            this.Controls.Add(this.button_removeAccount);
            this.Controls.Add(this.button_addAccount);
            this.Controls.Add(this.listBox_characters);
            this.Controls.Add(this.listBox_accounts);
            this.Name = "SelectCharacter";
            this.Text = "SelectCharacter";
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ListBox listBox_accounts;
        private System.Windows.Forms.ListBox listBox_characters;
        private System.Windows.Forms.Button button_addAccount;
        private System.Windows.Forms.Button button_removeAccount;
        private System.Windows.Forms.Button button_editAccount;
        private System.Windows.Forms.Button button_select;
        private System.Windows.Forms.Button button_setAsDefault;
    }
}