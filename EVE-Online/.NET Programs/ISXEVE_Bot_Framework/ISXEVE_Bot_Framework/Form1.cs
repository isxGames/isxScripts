using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Threading;

namespace ISXEVE_Bot_Framework
{
    public partial class Form1 : Form
    {
        /* New instance of Main, which indirectly provides the majority of our capabilities */
        Main _main = new Main();

        /* Thread for autostart */
        Thread _autoLoadThread;

        public Form1()
        {
            InitializeComponent();
            /* Attach our UI logging to the Logging event */
            Logging.LogMessage += new EventHandler<LogMessageEventArgs>(Logging_LogMessage);

            checkBox_autoStart.Checked = Config.Instance.AutoStart;

            if (Config.Instance.AutoStart)
            {
                _autoLoadThread = new Thread(new ThreadStart(DoAutoLoad));
                _autoLoadThread.Start();
            }

            FormClosing += new FormClosingEventHandler(Form1_FormClosing);
        }

        void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            Config.Instance.Save();
        }

        void DoAutoLoad()
        {
            for (int x = 5; x > 0; x--)
            {
                Logging.OnLogMessage(this, "Form1.DoAutoLoad(): Waiting " + x + " second(s) before loading characters.");
                Thread.Sleep(1000);
            }

            _main.LoadCharacters();
        }

        /* Clean up the event */
        ~Form1()
        {
            Logging.LogMessage -= new EventHandler<LogMessageEventArgs>(Logging_LogMessage);
        }

        /* Invoke the UI logging on the thread that owns the controls */
        void Logging_LogMessage(object sender, LogMessageEventArgs e)
        {
            if (InvokeRequired)
                Invoke(new EventHandler<LogMessageEventArgs>(Logging_LogMessage), sender, e);
            else
                UpdateListBox(e.Message);
        }

        /* Do the actual UI logging */
        void UpdateListBox(string message)
        {
            listBox_logging.Items.Add(message);
            listBox_logging.SelectedIndex = listBox_logging.Items.Count - 1;
        }

        /* Start the framework */
        private void button_start_Click(object sender, EventArgs e)
        {
            _main.Start();
        }

        private void button_loadCharacters_Click(object sender, EventArgs e)
        {
            _main.LoadCharacters();
        }

        private void checkBox_autoStart_CheckedChanged(object sender, EventArgs e)
        {
            Config.Instance.AutoStart = checkBox_autoStart.Checked;

            if (!checkBox_autoStart.Checked && _autoLoadThread.ThreadState == ThreadState.Running)
            {
                Logging.OnLogMessage(this, "CheckedChanged(): Aborting autostart.");
                _autoLoadThread.Abort();
            }
        }

        private void button_openCharacterSettings_Click(object sender, EventArgs e)
        {
            _main.LoadCharacters();
        }
    }
}
