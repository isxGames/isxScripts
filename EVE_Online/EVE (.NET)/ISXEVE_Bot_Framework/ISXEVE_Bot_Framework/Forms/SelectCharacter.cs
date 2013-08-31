using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Xml.Serialization;

namespace ISXEVE_Bot_Framework.Forms
{
    public partial class SelectCharacter : Form
    {
        public SelectCharacter()
        {
            InitializeComponent();
            setAccounts();
        }

        void setAccounts()
        {
            /* Temporarily detach event */
            listBox_accounts.SelectedIndexChanged -= new EventHandler(listBox_accounts_SelectedIndexChanged);

            /* Clear the listbox */
            listBox_accounts.Items.Clear();

            /* Populate accounts list box */
            foreach (string s in Directory.GetFiles(Settings.FilePath + "\\"))
                listBox_accounts.Items.Add(s);

            /* Attach a handler to the IndexChanged event to update Characters on Account change */
            listBox_accounts.SelectedIndexChanged += new EventHandler(listBox_accounts_SelectedIndexChanged);

            /* If we're autostarting... */
            if (Config.Instance.AutoStart)
            {
                /* And we can find the default account... */
                if (Config.Instance.DefaultAccount != String.Empty)
                {
                    for (int x = 1; x <= listBox_accounts.Items.Count; x++)
                    {
                        string[] temp = listBox_accounts.Items[x].ToString().Split("\\".ToCharArray());
                        if (temp[temp.Length - 1].Contains(Config.Instance.DefaultAccount))
                        {
                            Logging.OnLogMessage(this, "SelectCharacter(): Autoselecting account " + listBox_accounts.Items[x].ToString());
                            listBox_accounts.SelectedIndex = x - 1;
                            break;
                        }
                    }
                }
                else
                {
                    Logging.OnLogMessage(this, "SelectCharacter(): Autostarting but couldn't get default account");
                    return;
                }

                /* And we can get a default charcter... */
                if (Settings.ActiveSettings.DefaultCharIdentifier != null)
                {
                    for (int x = 1; x <= listBox_characters.Items.Count; x++)
                    {
                        if (listBox_characters.Items[x].ToString() == Settings.ActiveSettings.DefaultCharIdentifier)
                        {
                            Logging.OnLogMessage(this, "SelectCharacter(): Selecting default character");
                            listBox_characters.SelectedIndex = x - 1;
                            button_select_Click(this, EventArgs.Empty);
                            return;
                        }
                    }
                }
                else
                {
                    Logging.OnLogMessage(this, "SelectCharacter(): AutoStarting but can't get a default character");
                    return;
                }
            }

            if (listBox_accounts.Items.Count == 0)
            {
                button_addAccount_Click(this, EventArgs.Empty);
            }
        }

        void listBox_accounts_SelectedIndexChanged(object sender, EventArgs e)
        {
            /* Make sure we selected something */
            if (listBox_accounts.SelectedItem == null)
                return;

            /* Clear any existing items in the listbox */
            listBox_characters.Items.Clear();
            /* Use a filestream and XML deserializer to load Settings for an account */
            using (FileStream fs = new FileStream(listBox_accounts.SelectedItem.ToString(),
                FileMode.Open))
            {
                XmlSerializer xs = new XmlSerializer(typeof(Settings));
                Settings s = (Settings)xs.Deserialize(fs);
                foreach (CharacterSettings c in s.Characters)
                {
                    listBox_characters.Items.Add(c.Identifier);
                }
            }
        }

        private void button_addAccount_Click(object sender, EventArgs e)
        {
            Logging.OnLogMessage(this, "SelectCharacter.Add(): Launching an edit form for a new account.");
            EditCharacter f_EC = new EditCharacter();
            f_EC.CharacterEdited += new EventHandler(f_EC_CharacterEdited);
            f_EC.Show();
        }

        /* On account edit, save the account and update our list box */
        void f_EC_CharacterEdited(object sender, EventArgs e)
        {
            Logging.OnLogMessage(this, "SelectCharacter.CE(): Character edited; reloading accounts list.");
            setAccounts();
        }

        /* Remove an account */
        private void button_removeAccount_Click(object sender, EventArgs e)
        {
            if (listBox_accounts.SelectedItem != null)
            {
                Logging.OnLogMessage(this, "SelectCharacter.Remove(): Removing selected account");
                /* Check current settings AccountName against selected AccountName, search for file matches */
                /* Check for and delete the .xml */
                if (File.Exists(listBox_accounts.SelectedItem.ToString()))
                {
                    Logging.OnLogMessage(this, "SelectCharacter.Remove(): Deleting selected account settings");
                    File.Delete(listBox_accounts.SelectedItem.ToString());
                }

                /* Remove the account from the list */
                listBox_accounts.SelectedIndexChanged -= new EventHandler(listBox_accounts_SelectedIndexChanged);
                listBox_accounts.Items.Remove(listBox_accounts.SelectedItem);
                listBox_accounts.SelectedIndexChanged += new EventHandler(listBox_accounts_SelectedIndexChanged);
            }
        }

        /* Edit an existing account */
        private void button_editAccount_Click(object sender, EventArgs e)
        {
            if (listBox_accounts.SelectedItem != null)
            {
                using (FileStream fs = new FileStream(listBox_accounts.SelectedItem.ToString(), FileMode.Open))
                {
                    XmlSerializer xs = new XmlSerializer(typeof(Settings));
                    Forms.EditCharacter f_EC = new EditCharacter((Settings)xs.Deserialize(fs));
                    f_EC.CharacterEdited += new EventHandler(f_EC_CharacterEdited);
                    Logging.OnLogMessage(this, "SelectCharacter.Add(): Launching an edit form for selected account.");
                    f_EC.Show();
                }
            }
        }

        private void button_select_Click(object sender, EventArgs e)
        {
            if (listBox_accounts.SelectedItem == null)
            {
                MessageBox.Show("You must specify an account to make active");
                return;
            }
            if (listBox_characters.SelectedItem == null)
            {
                MessageBox.Show("You must specify a character to make active");
                return;
            }

            using (FileStream fs = new FileStream(listBox_accounts.SelectedItem.ToString(), FileMode.Open))
            {
                XmlSerializer xs = new XmlSerializer(typeof(Settings));
                Settings.ActiveSettings = (Settings)xs.Deserialize(fs);
                Logging.OnLogMessage(this, "SelectCharacter.Select(): Deserializing and setting active account.");
            }

            foreach (CharacterSettings c in Settings.ActiveSettings.Characters)
            {
                if (listBox_characters.SelectedItem.ToString() == c.Identifier)
                {
                    Settings.ActiveSettings.ActiveCharacter = c;
                    Logging.OnLogMessage(this, "SelectCharacter.Select(): Setting active character.");
                }
            }
        }

        private void button_setAsDefault_Click(object sender, EventArgs e)
        {
            if (listBox_accounts.SelectedItem.ToString() == null)
            {
                MessageBox.Show("You must select an account to set as default!");
                return;
            }

            Config.Instance.DefaultAccount = listBox_accounts.SelectedItem.ToString();
            Config.Instance.Save();
            Logging.OnLogMessage(this, "SelectCharacter.SetDefault(): Setting selected account to default and saving config.");
        }
    }
}
