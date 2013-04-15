namespace Amnesty_Hypercube
{
    partial class Browser
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
            this.extendedWebBrowser1 = new ExtendedWebBrowser2.ExtendedWebBrowser();
            this.SuspendLayout();
            // 
            // extendedWebBrowser1
            // 
            this.extendedWebBrowser1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.extendedWebBrowser1.Location = new System.Drawing.Point(0, 0);
            this.extendedWebBrowser1.MinimumSize = new System.Drawing.Size(20, 20);
            this.extendedWebBrowser1.Name = "extendedWebBrowser1";
            this.extendedWebBrowser1.ScriptErrorsSuppressed = true;
            this.extendedWebBrowser1.Size = new System.Drawing.Size(584, 364);
            this.extendedWebBrowser1.TabIndex = 0;
            // 
            // Browser
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(584, 364);
            this.Controls.Add(this.extendedWebBrowser1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.SizableToolWindow;
            this.Name = "Browser";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.TopMost = true;
            this.ResumeLayout(false);

        }

        #endregion

        private ExtendedWebBrowser2.ExtendedWebBrowser extendedWebBrowser1;
    }
}