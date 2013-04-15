using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace Amnesty_Hypercube
{
    public partial class Form4 : Form
    {
        int page = 1;

        public Form4()
        {
            InitializeComponent();

            this.DoubleBuffered = true;
        }

        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            this.Visible = false;
            e.Cancel = true;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            switch (page)
            {
                case 1:
                    pictureBox1.Image = Amnesty_Hypercube.Properties.Resources.SplashHypercube2;
                    button1.Text = Amnesty_Hypercube.Properties.Resources.CreditsDone;
                    page = 2;
                    break;

                case 2:
                    pictureBox1.Image = Amnesty_Hypercube.Properties.Resources.SplashHypercube;
                    button1.Text = Amnesty_Hypercube.Properties.Resources.CreditsMore;
                    page = 1;
                    break;
            }

       }
    }
}