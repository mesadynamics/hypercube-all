using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace Amnesty_Hypercube
{
    public partial class Form2 : Form
    {
        Form1 widgetManager;
        Point moveStart;
        Point resizeStart;
        Size resizeSize;
        
        public Form2()
        {
            InitializeComponent();
            
            this.MouseDown += new MouseEventHandler(Form2_MouseDown);
            this.MouseMove += new MouseEventHandler(Form2_MouseMove);
            panel1.MouseDown += new MouseEventHandler(Form2_MouseDown);
            panel1.MouseMove += new MouseEventHandler(Form2_MouseMove);
            panel2.MouseDown += new MouseEventHandler(Form2_MouseDown);
            panel2.MouseMove += new MouseEventHandler(Form2_MouseMove);
            label1.MouseDown += new MouseEventHandler(Form2_MouseDown);
            label1.MouseMove += new MouseEventHandler(Form2_MouseMove);

            button3.MouseDown += new MouseEventHandler(button3_MouseDown);
            button3.MouseMove += new MouseEventHandler(button3_MouseMove);

            textBox1.KeyDown += new KeyEventHandler(textBox1_KeyDown);

            Rectangle mainScreen = Screen.PrimaryScreen.WorkingArea;
            this.SetDesktopLocation(mainScreen.Width - 400, mainScreen.Height - 220);

            this.DoubleBuffered = true;
        }

        public void SetWidgetManager(Form1 set)
        {
            widgetManager = set;
        }

        public void SetString(string set)
        {
            textBox1.Text = set;
        }

        void textBox1_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                e.SuppressKeyPress = true;
                button1.PerformClick();
            }
        }

        void Form2_MouseMove(object sender, MouseEventArgs e)
        {
            if ((e.Button & MouseButtons.Left) != 0)
            {
                Point deltaPos = new Point(e.X - moveStart.X, e.Y - moveStart.Y);
                this.Location = new Point(this.Location.X + deltaPos.X,
                  this.Location.Y + deltaPos.Y);
            }
        }

        void Form2_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                moveStart = new Point(e.X, e.Y);
            }
        }

        void button3_MouseMove(object sender, MouseEventArgs e)
        {
            if ((e.Button & MouseButtons.Left) != 0)
            {
                Point deltaPos = new Point(e.X - resizeStart.X, e.Y - resizeStart.Y);
                this.SetDesktopBounds(this.Location.X, this.Location.Y, resizeSize.Width + deltaPos.X, resizeSize.Height + deltaPos.Y);
            }
        }

        void button3_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                resizeStart = new Point(e.X, e.Y);
                resizeSize = this.Size;
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if(widgetManager.InstallWidgetWithCode(textBox1.Text, true, true))
               textBox1.Text = "";
        }

        private void button2_Click(object sender, EventArgs e)
        {
            this.Hide();
        }
    }
}