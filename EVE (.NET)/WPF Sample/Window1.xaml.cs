using System;
using System.Collections.Generic;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using EVE.ISXEVE;
using LavishVMAPI;


namespace wpf_sample
{
    public sealed class Globals
    {
        public static readonly Globals Instance = new Globals();

        public EVE.ISXEVE.Extension Ext = new EVE.ISXEVE.Extension();

        private Globals() { }
    }
    
    /// <summary>
    /// Interaction logic for Window1.xaml
    /// </summary>

    public partial class Window1 : System.Windows.Window
    {
        Globals Globals = Globals.Instance;

        public Window1()
        {
            InitializeComponent();

            btn2.Visibility = Visibility.Hidden;
            btn3.Visibility = Visibility.Hidden;
            btn4.Visibility = Visibility.Hidden;

            using (new FrameLock(true))
            {
                tbOutput.Text = "Name: " + Globals.Ext.Me().Name;
            }
        }

        void btn1_click(object sender, RoutedEventArgs e)
        {
            btn1.Visibility = Visibility.Hidden;
            btn2.Visibility = Visibility.Visible;
            using (new FrameLock(true))
            {
                tbOutput.Text = "High Slots: " + Globals.Ext.Me().Ship().HighSlots;
            }
        }
        void btn2_click(object sender, RoutedEventArgs e)
        {
            btn2.Visibility = Visibility.Hidden;
            btn3.Visibility = Visibility.Visible;
            using (new FrameLock(true))
            {
                tbOutput.Text = "Mid Slots: " + Globals.Ext.Me().Ship().MediumSlots;
            }
        }
        void btn3_click(object sender, RoutedEventArgs e)
        {
            btn3.Visibility = Visibility.Hidden;
            btn4.Visibility = Visibility.Visible;
            using (new FrameLock(true))
            {
                tbOutput.Text = "Low Slots: " + Globals.Ext.Me().Ship().LowSlots;
            }
        }
        void btn4_click(object sender, RoutedEventArgs e)
        {
            btn4.Visibility = Visibility.Hidden;
            btn1.Visibility = Visibility.Visible;
            using (new FrameLock(true))
            {
                if (Globals.Ext.Me().InStation)
                {
                    tbOutput.Text = "Undocking...";
                    Globals.Ext.EVE().Execute(ExecuteCommand.CmdExitStation);
                }
                else
                {
                    tbOutput.Text = "You are in space.";
                }
            }
        }
    }
}