using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Runtime.InteropServices;

namespace Amnesty_Hypercube
{
    //[ComVisible(true)]
    public partial class Browser : Form //, COMInterfaces.IOleClientSite
    {
        public Browser()
        {
            InitializeComponent();

            extendedWebBrowser1.DocumentTitleChanged += new EventHandler(extendedWebBrowser1_DocumentTitleChanged);
            extendedWebBrowser1.DocumentCompleted += new WebBrowserDocumentCompletedEventHandler(extendedWebBrowser1_DocumentCompleted);
            extendedWebBrowser1.StartNewWindow += new EventHandler<ExtendedWebBrowser2.BrowserExtendedNavigatingEventArgs>(extendedWebBrowser1_StartNewWindow);
        }

        void extendedWebBrowser1_DocumentCompleted(object sender, WebBrowserDocumentCompletedEventArgs e)
        {
            //COMInterfaces.IOleControl oleControl = (COMInterfaces.IOleControl)this.extendedWebBrowser1.ActiveXInstance;
            //oleControl.OnAmbientPropertyChange(-5513);
        }

        void extendedWebBrowser1_DocumentTitleChanged(object sender, EventArgs e)
        {
            this.Text = extendedWebBrowser1.DocumentTitle;
        }

        void extendedWebBrowser1_StartNewWindow(object sender, ExtendedWebBrowser2.BrowserExtendedNavigatingEventArgs e)
        {
            Browser browser = new Browser();
            browser.LoadPage(e.Url.ToString());
            browser.Show();

            this.AddOwnedForm(browser);

            e.Cancel = true;
        }
        
        public void LoadPage(string url)
        {
            //COMInterfaces.IOleObject oleObject = (COMInterfaces.IOleObject)this.extendedWebBrowser1.ActiveXInstance;
            //oleObject.SetClientSite(this);
            
            string html = Amnesty_Hypercube.Properties.Resources.Browser;
            string widgetHtml = html.Replace("^url", url);
            extendedWebBrowser1.DocumentText = widgetHtml;
        }

        [DispId(-5513)]
        public virtual string IDispatch_Invoke_Handler()
        {
            return "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.1) Gecko/20061204 Firefox/2.0.0.1";
        }

        #region IOleClientSite Members

        public int SaveObject()
        {
            return 0;
        }

        public int GetMoniker(int dwAssign, int dwWhichMoniker, out object moniker)
        {
            moniker = this;
            return 0;
        }

        public int GetContainer(out object container)
        {
            container = this;
            return 0;
        }

        public int ShowObject()
        {
            return 0;
        }

        public int OnShowWindow(int fShow)
        {
            return 0;
        }

        public int RequestNewObjectLayout()
        {
            return 0;
        }

        #endregion
    }
}