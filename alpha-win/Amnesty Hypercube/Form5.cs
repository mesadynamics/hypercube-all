using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

using Org.Vesic.WinForms;

namespace Amnesty_Hypercube
{
    public partial class Form5 : Form
    {
        FormState formState = new FormState();

        [Flags]
        internal enum WindowStyles : int
        {
            ExToolWindow = 0x00000080,
            ExAppWindow = 0x00040000
        };

        public Form5()
        {
            InitializeComponent();

            Rectangle screen = Screen.PrimaryScreen.Bounds;
            screen.Y = screen.Height;
            this.Bounds = screen;

            this.DoubleBuffered = true;
        }

        public void DoShow()
        {
            formState.Float(this);
            this.Show();
        }

        public void DoHide()
        {
            formState.DontFloat(this);
            this.Hide();
        }

        protected override CreateParams CreateParams
        {
            get
            {
                CreateParams cp = base.CreateParams;
                cp.ExStyle |= (int)WindowStyles.ExToolWindow;
                return cp;
            }
        }
    }
}