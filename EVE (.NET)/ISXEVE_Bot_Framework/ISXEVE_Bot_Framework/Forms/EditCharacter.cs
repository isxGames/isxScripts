using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;

namespace ISXEVE_Bot_Framework.Forms
{
    internal partial class EditCharacter : Form
    {
        public event EventHandler CharacterEdited;

        Settings temp;
        string account = string.Empty;

        public EditCharacter()
        {
            Logging.OnLogMessage(this, "EditCharacter(): Loading form for creating an account and characters");
            InitializeComponent();
            temp = new Settings();
            this.FormClosing += new FormClosingEventHandler(EditCharacter_FormClosing);
        }

        void EditCharacter_FormClosing(object sender, FormClosingEventArgs e)
        {
            Logging.OnLogMessage(this, "EditCharacter.FormClosing(): Saving " + temp.UserName);
            temp.Save();
            /* Clean up after ourselves, delete any extra config files */
            if (account != String.Empty && account != temp.UserName)
            {
                if (File.Exists(Settings.FilePath + "\\" + account + ".xml"))
                {
                    File.Delete(Settings.FilePath + "\\" + account + ".xml");
                    Logging.OnLogMessage(this, "EditCharacterFormClosing(): Deleting orphaned config file " + account + ".xml.");
                }
            }
            if (CharacterEdited != null)
                CharacterEdited(this, EventArgs.Empty);
        }

        public EditCharacter(Settings settings)
        {
            InitializeComponent();
            Logging.OnLogMessage(this, "EditCharacter(): Loading form for editing existing account and characters");
            temp = settings;
            account = settings.UserName;
            this.FormClosing += new FormClosingEventHandler(EditCharacter_FormClosing);

            comboBox_characters.SelectedIndexChanged -= new EventHandler(comboBox_characters_SelectedIndexChanged);
            comboBox_defaultCharacter.SelectedIndexChanged -= new EventHandler(comboBox_defaultCharacter_SelectedIndexChanged);
            
            foreach (CharacterSettings c in temp.Characters)
            {
                comboBox_characters.Items.Add(c.Identifier);
                comboBox_defaultCharacter.Items.Add(c.Identifier);
            }

            for (int x = 0; x < comboBox_defaultCharacter.Items.Count; x++)
            {
                if (((string)comboBox_defaultCharacter.Items[x]) == temp.DefaultCharIdentifier)
                {
                    comboBox_defaultCharacter.SelectedIndex = x;
                    break;
                }
            }

            comboBox_characters.SelectedIndexChanged += new EventHandler(comboBox_characters_SelectedIndexChanged);
            comboBox_characters.SelectedIndex = 0;
            comboBox_defaultCharacter.SelectedIndexChanged += new EventHandler(comboBox_defaultCharacter_SelectedIndexChanged);

        }

        void OnCharacterEdited()
        {
            Logging.OnLogMessage(this, "EditCharacter.EC_FC(): Firing CharacterEdited. Test: " + temp.UserName + ", " + Settings.ActiveSettings.UserName);
            if (CharacterEdited != null)
                CharacterEdited(this, EventArgs.Empty);
        }

        private void button_addCharacter_Click(object sender, EventArgs e)
        {
            if (temp.Characters.Count < 3 && textBox_identifier.Text.Length > 0)
            {
                CharacterSettings tcs = new CharacterSettings(textBox_identifier.Text);
                foreach (CharacterSettings c in temp.Characters)
                {
                    if (c.Identifier == tcs.Identifier)
                    {
                        MessageBox.Show("Cannot add the same ID twice");
                        return;
                    }
                } 
                temp.Characters.Add(tcs);
                comboBox_characters.Items.Add(tcs.Identifier);
                if (comboBox_characters.Items.Count == 1)
                    comboBox_characters.SelectedIndex = 0;
                if (comboBox_defaultCharacter.SelectedIndex == 1)
                    comboBox_defaultCharacter.SelectedIndex = 0;
                comboBox_defaultCharacter.Items.Add(tcs.Identifier);
            }
        }

        private void detachEventTargets()
        {
            Logging.OnLogMessage(this, "EditCharacter.DetachEvents(): Detaching events");
            comboBox_characters.TextChanged -= new EventHandler(comboBox_characters_SelectedIndexChanged);
            comboBox_defaultCharacter.TextChanged -= new EventHandler(comboBox_defaultCharacter_SelectedIndexChanged);
        }

        private void attachEventTargets()
        {
            Logging.OnLogMessage(this, "EditCharacter.AttachEvents(): Attaching events");
            comboBox_characters.TextChanged += new EventHandler(comboBox_characters_SelectedIndexChanged);
            comboBox_defaultCharacter.TextChanged += new EventHandler(comboBox_defaultCharacter_SelectedIndexChanged);
        }

        private void comboBox_characters_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (comboBox_characters.SelectedItem == null)
            {
                MessageBox.Show("You must select a character.");
                return;
            }

            foreach (CharacterSettings s in temp.Characters)
            {
                /* If a character's ID == the selected one */
                if (s.Identifier == comboBox_characters.SelectedItem.ToString())
                {
                    /* Set it to active */
                    temp.ActiveCharacter = s;
                    Logging.OnLogMessage(this, "EditCharacter.SIC(): Set " + s.CharId + " as active temp character.");
                    break;
                }
            }
            /* Temporarily detach update events */
            detachEventTargets();

            /* Set the values */
            textBox_charId.Text = temp.ActiveCharacter.CharId.ToString();
            textBox_charName.Text = temp.ActiveCharacter.CharName;
            textBox_identifier.Text = temp.ActiveCharacter.Identifier;

            /* Re-attach the events */
            attachEventTargets();
        }

        /* Set default character */
        private void comboBox_defaultCharacter_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (comboBox_defaultCharacter.SelectedItem == null)
            {
                MessageBox.Show("You must have a character available to make one the default.");
                return;
            }

            /* do the actual set */
            temp.DefaultCharIdentifier = comboBox_defaultCharacter.SelectedItem.ToString();
        }

        /* Remove a character */
        private void button_removeCharacter_Click(object sender, EventArgs e)
        {
            if (comboBox_characters.Items.Count == 0)
            {
                MessageBox.Show("You must first have a character to remove a character!");
                return;
            }

            /* Remove the character from the list */
            for (int x = 0; x < temp.Characters.Count; x++)
            {
                if (temp.Characters[x].Identifier == comboBox_characters.SelectedItem.ToString())
                {
                    Logging.OnLogMessage(this, "EditCharacter(): Removing character: " + comboBox_characters.SelectedItem.ToString());
                    temp.Characters.Remove(temp.Characters[x]);
                    break;
                }
            }

            /* Remove the character from the two lists */
            /* Temporarily detach events */
            detachEventTargets();

            /* Clear text on comboboxes */
            comboBox_characters.Text = String.Empty;
            if (comboBox_defaultCharacter.SelectedItem.ToString() == comboBox_characters.SelectedItem.ToString())
                comboBox_defaultCharacter.Text = String.Empty;
            
            /* If this was the default, make sure it isn't */
            if (temp.DefaultCharIdentifier == comboBox_characters.SelectedItem.ToString())
                temp.DefaultCharIdentifier = string.Empty;

            /* Do the removal */
            comboBox_defaultCharacter.Items.Remove(comboBox_characters.SelectedItem.ToString());
            comboBox_characters.Items.Remove(comboBox_characters.SelectedItem.ToString());
            textBox_identifier.Text = String.Empty;
            textBox_charName.Text = String.Empty;
            textBox_charId.Text = String.Empty;
            comboBox_characters.Text = String.Empty;

            /* Re-attach the events */
            attachEventTargets();

            /* Check for possible characters to switch to */
            if (comboBox_characters.Items.Count > 0)
            {
                comboBox_characters.SelectedIndex = 0;
                comboBox_defaultCharacter.SelectedIndex = 0;
            }
        }

        private void textBox_charName_TextChanged(object sender, EventArgs e)
        {
            temp.ActiveCharacter.CharName = textBox_charName.Text;
        }

        private void textBox_charId_TextChanged(object sender, EventArgs e)
        {
            int t = 0;
            if (int.TryParse(textBox_charId.Text, out t))
                temp.ActiveCharacter.CharId = t;
            else
                textBox_charId.Text = "0";
        }

        private void textBox_username_TextChanged(object sender, EventArgs e)
        {
            temp.UserName = textBox_username.Text;
        }

        private void textBox_password_TextChanged(object sender, EventArgs e)
        {
            temp.PassWord = textBox_password.Text;
        }
    }
}
