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
        string[] AllAtoms = new string[1000];
        
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
            long callCnt = 0;
            long cpuTime = 0;
            long memCnt = 0;
            dataGridView1.Rows.Clear();

            for (int i = 0; i < strAllLines.Length; i++)
            {
                
                if (strAllLines[i].StartsWith("   function") || strAllLines[i].StartsWith("   Atom")) 
                {
                    if (curatom.Length > 0)
                    { 
                        AllAtoms[j] = atomBody.ToString();
                        dataGridView1.Rows.Add(j, curatom, callCnt, cpuTime, memCnt);
                        j++;
                    }

                    sb.Append(curatom);
                    sb.Append("\r\n");
                    curatom = strAllLines[i].Replace("   Atom", "");
                    atomBody.Clear();
                    callCnt = 0;
                    cpuTime = 0;
                    memCnt = 0;
                }
                else if (strAllLines[i].StartsWith("      ["))
                {
                    atomBody.Append(strAllLines[i].Replace("      [", "["));
                    atomBody.Append("\r\n");

                    string[] split = strAllLines[i].Split(new Char[] { '[', ']', ':', '/'});
                    callCnt += Convert.ToInt64(split[1]);
                    //cpuTime += Convert.ToInt64(split[5].Replace("ms", "").Replace(".", ","));
                    cpuTime += Convert.ToInt64(split[4]);
                    memCnt += Convert.ToInt64(split[8].Replace("k", ""));
                }

            }
            textBox1.Text = sb.ToString();
            //Lines
            //textBox1.Text = strAllLines[1];
        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0)
            {
                int indx = (int)dataGridView1.Rows[e.RowIndex].Cells["id"].Value;
                //textBox1.Text = AllAtoms[e.RowIndex];
                textBox1.Text = AllAtoms[indx];
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {

        }

        private void dataGridView1_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0)
            {
                int indx = (int)dataGridView1.Rows[e.RowIndex].Cells["id"].Value;
                //textBox1.Text = AllAtoms[e.RowIndex];
                textBox1.Text = AllAtoms[indx];
            }
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
