using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace LSProfilingParser
{
    public partial class Form1 : Form
    {
        string[] AllAtoms = new string[50000];

		public Form1()
		{
			InitializeComponent();
		}

        private void button1_Click(object sender, EventArgs e)
        {
            openFileDialog1.ShowDialog();
        }

        private void openFileDialog1_FileOk(object sender, CancelEventArgs e)
        {
            StringBuilder sb = new StringBuilder();
            StringBuilder atomBody = new StringBuilder();

            toolStripStatusLabel1.Text= openFileDialog1.FileName;
            string[] strAllLines = System.IO.File.ReadAllLines(openFileDialog1.FileName);
            string curatom = "";
            int j = 0;
            long ParsedCalls = 0;
            long ParsedCPUTime = 0;
            long ParsedMemCnt = 0;
            dataGridView1.Rows.Clear();

            for (int i = 0; i < strAllLines.Length; i++)
            {
                
                if (strAllLines[i].StartsWith("   function") || strAllLines[i].StartsWith("   Atom")) 
                {
                    if (curatom.Length > 0)
                    { 
                        AllAtoms[j] = atomBody.ToString();
						dataGridView1.Rows.Add(j, curatom, ParsedCalls, ParsedCalls > 0 ? ParsedCPUTime/ParsedCalls : ParsedCPUTime, ParsedCPUTime, ParsedMemCnt);
                        j++;
                    }

                    sb.Append(curatom);
                    sb.Append("\r\n");
                    curatom = strAllLines[i].Replace("   Atom", "");
                    atomBody.Clear();
                    ParsedCalls = 0;
                    ParsedCPUTime = 0;
                    ParsedMemCnt = 0;
                }
                else if (strAllLines[i].StartsWith("      ["))
                {
                    atomBody.Append(strAllLines[i].Replace("      [", "["));
                    atomBody.Append("\r\n");

                    string[] split = strAllLines[i].Split(new Char[] { '[', ']', ':', '/'});
                    ParsedCalls += Convert.ToInt64(split[1]);
                    ParsedCPUTime += Convert.ToInt64(split[4]);
                    ParsedMemCnt += Convert.ToInt64(split[8].Replace("k", ""));
                }

            }
            //textBox1.Text = sb.ToString();
            //Lines
            //textBox1.Text = strAllLines[1];
            //textBox1.Text = "Select Atom";
            ShowAtom(0);
        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void dataGridView1_CellStateChanged(object sender, DataGridViewCellStateChangedEventArgs e)
        {
            if (e.Cell.RowIndex >= 0 && dataGridView1.RowCount > 1)
            {
                ShowAtom((int)dataGridView1.Rows[e.Cell.RowIndex].Cells["id"].Value);
            }
        }

        private void ShowAtom(int indx)
        {
            if (AllAtoms[indx].Length > 0)
            {
                textBox1.Text = AllAtoms[indx];
                tabControl1.SelectedIndex = 1;
                dataGridView2.Rows.Clear();

                string[] lines = AllAtoms[indx].Replace("\r", "").Split(new Char[] { '\n' });
                for (int i = 0; i < lines.Length; i++)
                {
                    string[] cmdsplit = lines[i].Split(new string[] { "k]  " }, StringSplitOptions.None);
                    string[] split = cmdsplit[0].Split(new string[] { "[", "]", ":", "/" }, StringSplitOptions.None);
                    if (split.Length>=10)
                    {
                        dataGridView2.Rows.Add(i, split[1], split[4], split[5], split[8], split[9], cmdsplit[1]);
                    }
                }
            }
            else
            {
                if (dataGridView1.RowCount > 1)
                {
                    textBox1.Text = "Empty atom";
                }
                else
                {
                    textBox1.Text = "Please load dump first";
                }
            }
        }

        private void dataGridView1_SortCompare(object sender, DataGridViewSortCompareEventArgs e)
        {
            e.SortResult = sortDots(e.CellValue1.ToString(), e.CellValue2.ToString());
            e.Handled = true;
        }

        private int sortDots(string s1, string s2)
        {
            if (s1.Length > s2.Length)
            {
                return 1;
            }
            else if (s1.Length < s2.Length)
            {
                return -1;
            }
            else
            {
				long i1 = Convert.ToInt64(s1);
				long i2 = Convert.ToInt64(s2);
                if (i1 > i2)
                {
                    return 1;
                }
                else if (i1 < i2)
                {
                    return -1;
                }
                else
                {
                    return 0;
                }
            }
		}

		private void LicenseLogo_Click(object sender, EventArgs e)
		{
			try
			{
				System.Diagnostics.Process.Start("http://creativecommons.org/licenses/by-nc-sa/3.0/");
			}
			catch
				(
				 System.ComponentModel.Win32Exception noBrowser)
			{
				if (noBrowser.ErrorCode == -2147467259)
					MessageBox.Show(noBrowser.Message);
			}
			catch (System.Exception other)
			{
				MessageBox.Show(other.Message);
			}
		}
    }
}
