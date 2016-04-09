namespace ISXEVE_Bot_Framework.Forms
{
    partial class EditCharacter
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
            this.textBox_username = new System.Windows.Forms.TextBox();
            this.textBox_password = new System.Windows.Forms.TextBox();
            this.groupBox_accountSettings = new System.Windows.Forms.GroupBox();
            this.comboBox_defaultCharacter = new System.Windows.Forms.ComboBox();
            this.groupBox_characterSettings = new System.Windows.Forms.GroupBox();
            this.textBox_identifier = new System.Windows.Forms.TextBox();
            this.textBox_charName = new System.Windows.Forms.TextBox();
            this.textBox_charId = new System.Windows.Forms.TextBox();
            this.button_addCharacter = new System.Windows.Forms.Button();
            this.comboBox_characters = new System.Windows.Forms.ComboBox();
            this.button_removeCharacter = new System.Windows.Forms.Button();
            this.groupBox_accountSettings.SuspendLayout();
            this.groupBox_characterSettings.SuspendLayout();
            this.SuspendLayout();
            // 
            // textBox_username
            // 
            this.textBox_username.Location = new System.Drawing.Point(6, 19);
            this.textBox_username.Name = "textBox_username";
            this.textBox_username.Size = new System.Drawing.Size(100, 20);
            this.textBox_username.TabIndex = 0;
            this.textBox_username.Text = "Username";
            this.textBox_username.TextChanged += new System.EventHandler(this.textBox_username_TextChanged);
            // 
            // textBox_password
            // 
            this.textBox_password.Location = new System.Drawing.Point(191, 19);
            this.textBox_password.Name = "textBox_password";
            this.textBox_password.Size = new System.Drawing.Size(100, 20);
            this.textBox_password.TabIndex = 1;
            this.textBox_password.Text = "Password";
            this.textBox_password.TextChanged += new System.EventHandler(this.textBox_password_TextChanged);
            // 
            // groupBox_accountSettings
            // 
            this.groupBox_accountSettings.Controls.Add(this.comboBox_defaultCharacter);
            this.groupBox_accountSettings.Controls.Add(this.textBox_username);
            this.groupBox_accountSettings.Controls.Add(this.textBox_password);
            this.groupBox_accountSettings.Location = new System.Drawing.Point(12, 12);
            this.groupBox_accountSettings.Name = "groupBox_accountSettings";
            this.groupBox_accountSettings.Size = new System.Drawing.Size(506, 45);
            this.groupBox_accountSettings.TabIndex = 2;
            this.groupBox_accountSettings.TabStop = false;
            this.groupBox_accountSettings.Text = "Account Settings";
            // 
            // comboBox_defaultCharacter
            // 
            this.comboBox_defaultCharacter.FormattingEnabled = true;
            this.comboBox_defaultCharacter.Location = new System.Drawing.Point(376, 18);
            this.comboBox_defaultCharacter.Name = "comboBox_defaultCharacter";
            this.comboBox_defaultCharacter.Size = new System.Drawing.Size(121, 21);
            this.comboBox_defaultCharacter.TabIndex = 2;
            this.comboBox_defaultCharacter.SelectedIndexChanged += new System.EventHandler(this.comboBox_defaultCharacter_SelectedIndexChanged);
            // 
            // groupBox_characterSettings
            // 
            this.groupBox_characterSettings.Controls.Add(this.textBox_charName);
            this.groupBox_characterSettings.Controls.Add(this.textBox_charId);
            this.groupBox_characterSettings.Location = new System.Drawing.Point(12, 92);
            this.groupBox_characterSettings.Name = "groupBox_characterSettings";
            this.groupBox_characterSettings.Size = new System.Drawing.Size(506, 164);
            this.groupBox_characterSettings.TabIndex = 3;
            this.groupBox_characterSettings.TabStop = false;
            this.groupBox_characterSettings.Text = "Character Settings";
            // 
            // textBox_identifier
            // 
            this.textBox_identifier.Location = new System.Drawing.Point(127, 67);
            this.textBox_identifier.Name = "textBox_identifier";
            this.textBox_identifier.Size = new System.Drawing.Size(100, 20);
            this.textBox_identifier.TabIndex = 2;
            this.textBox_identifier.Text = "Identifier";
            // 
            // textBox_charName
            // 
            this.textBox_charName.Location = new System.Drawing.Point(6, 45);
            this.textBox_charName.Name = "textBox_charName";
            this.textBox_charName.Size = new System.Drawing.Size(100, 20);
            this.textBox_charName.TabIndex = 1;
            this.textBox_charName.Text = "Character Name";
            this.textBox_charName.TextChanged += new System.EventHandler(this.textBox_charName_TextChanged);
            // 
            // textBox_charId
            // 
            this.textBox_charId.Location = new System.Drawing.Point(6, 19);
            this.textBox_charId.Name = "textBox_charId";
            this.textBox_charId.Size = new System.Drawing.Size(100, 20);
            this.textBox_charId.TabIndex = 0;
            this.textBox_charId.Text = "Character ID";
            this.textBox_charId.TextChanged += new System.EventHandler(this.textBox_charId_TextChanged);
            // 
            // button_addCharacter
            // 
            this.button_addCharacter.Location = new System.Drawing.Point(12, 65);
            this.button_addCharacter.Name = "button_addCharacter";
            this.button_addCharacter.Size = new System.Drawing.Size(83, 23);
            this.button_addCharacter.TabIndex = 3;
            this.button_addCharacter.Text = "Add Character";
            this.button_addCharacter.UseVisualStyleBackColor = true;
            this.button_addCharacter.Click += new System.EventHandler(this.button_addCharacter_Click);
            // 
            // comboBox_characters
            // 
            this.comboBox_characters.FormattingEnabled = true;
            this.comboBox_characters.Location = new System.Drawing.Point(259, 67);
            this.comboBox_characters.Name = "comboBox_characters";
            this.comboBox_characters.Size = new System.Drawing.Size(121, 21);
            this.comboBox_characters.TabIndex = 3;
            this.comboBox_characters.SelectedIndexChanged += new System.EventHandler(this.comboBox_characters_SelectedIndexChanged);
            // 
            // button_removeCharacter
            // 
            this.button_removeCharacter.Location = new System.Drawing.Point(412, 65);
            this.button_removeCharacter.Name = "button_removeCharacter";
            this.button_removeCharacter.Size = new System.Drawing.Size(104, 23);
            this.button_removeCharacter.TabIndex = 4;
            this.button_removeCharacter.Text = "Remove Character";
            this.button_removeCharacter.UseVisualStyleBackColor = true;
            this.button_removeCharacter.Click += new System.EventHandler(this.button_removeCharacter_Click);
            // 
            // EditCharacter
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(530, 264);
            this.Controls.Add(this.textBox_identifier);
            this.Controls.Add(this.button_removeCharacter);
            this.Controls.Add(this.comboBox_characters);
            this.Controls.Add(this.button_addCharacter);
            this.Controls.Add(this.groupBox_characterSettings);
            this.Controls.Add(this.groupBox_accountSettings);
            this.Name = "EditCharacter";
            this.Text = "EditCharacter";
            this.groupBox_accountSettings.ResumeLayout(false);
            this.groupBox_accountSettings.PerformLayout();
            this.groupBox_characterSettings.ResumeLayout(false);
            this.groupBox_characterSettings.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox textBox_username;
        private System.Windows.Forms.TextBox textBox_password;
        private System.Windows.Forms.GroupBox groupBox_accountSettings;
        private System.Windows.Forms.GroupBox groupBox_characterSettings;
        private System.Windows.Forms.ComboBox comboBox_defaultCharacter;
        private System.Windows.Forms.Button button_addCharacter;
        private System.Windows.Forms.ComboBox comboBox_characters;
        private System.Windows.Forms.Button button_removeCharacter;
        private System.Windows.Forms.TextBox textBox_identifier;
        private System.Windows.Forms.TextBox textBox_charName;
        private System.Windows.Forms.TextBox textBox_charId;
    }
}