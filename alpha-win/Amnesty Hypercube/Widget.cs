using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Runtime.InteropServices;

using ExtendedWebBrowser2;
using ASFTBase.Graphic;

namespace Amnesty_Hypercube
{
    //[ComVisible(true)]
    public partial class Widget : Form //, COMInterfaces.IOleClientSite
    {        
        Timer controlTimer = new Timer();

        bool ready = false;
        bool mouseIn = false;
        bool ignoreClick = false;
        bool ignoreInfoClick = false;
        bool willBeVisible = true;
        bool shouldHideOnReady = false;
        bool checkThumbnail = true;
        //bool isHandlingScriptErrors = false;
        bool didPause = false;

        Point moveStart;
        Point docMoveStart;
        Form1 widgetManager;
        string domain = null;
        string groupName = null;
        string widgetCode = null;

        bool isInHypercube = false;
        bool isInGallery = false;

        bool allowBrowserSpawning = false;

        bool initFill = false;
        bool initSize = true;
        bool initCallbacks = true;

        int saveWidth = 0;
        int saveHeight = 0;
        Panel visiblePanel = null;

        WidgetLevel optionLevel = WidgetLevel.levelFloating;
        WidgetDrag optionDrag = WidgetDrag.dragWidget;
        WidgetFill optionBackground = WidgetFill.fillTransparent;
        int optionOpacity = 100;

        bool allowSleeping = true;
        bool allowPausing = true;
        bool allowHosting = true;
        bool foundGlobals = false;

        Point topLeft;
  
        [Flags]
        internal enum WindowStyles : int
        {
            ExToolWindow = 0x00000080,
            ExAppWindow = 0x00040000
        };

        internal enum WidgetLevel
        {
            levelNone,
            levelFloating,
            levelStandard,
            levelEmbedded
        };

        internal enum WidgetDrag
        {
            dragNone,
            dragWidget,
            dragControl,
            dragOff
        };

        internal enum WidgetFill
        {
            fillNone,
            fillTransparent,
            fillWhite,
            fillBlack
        };

        public Widget()
        {
            InitializeComponent();
            topLeft.X = 0;
            topLeft.Y = 0;

            pushIntoSideabarToolStripMenuItem.Enabled = false;

            this.MouseDown += new MouseEventHandler(Widget_MouseDown);
            this.MouseMove += new MouseEventHandler(Widget_MouseMove);
            button1.MouseDown += new MouseEventHandler(Widget_MouseDown);
            button1.MouseMove += new MouseEventHandler(Widget_MouseMove);

            panel1.MouseDown += new MouseEventHandler(Widget_MouseDown);
            panel1.MouseMove += new MouseEventHandler(Widget_MouseMove);
            panel2.MouseDown += new MouseEventHandler(Widget_MouseDown);
            panel2.MouseMove += new MouseEventHandler(Widget_MouseMove);
            panel3.MouseDown += new MouseEventHandler(Widget_MouseDown);
            panel3.MouseMove += new MouseEventHandler(Widget_MouseMove);

            contextMenuStrip1.Opening += new CancelEventHandler(contextMenuStrip1_Opening);

            extendedWebBrowser1.Navigating += new WebBrowserNavigatingEventHandler(extendedWebBrowser1_Navigating);

            controlTimer.Enabled = true;
            controlTimer.Interval = 100;
            controlTimer.Tick += new EventHandler(controlTimer_Tick);
            controlTimer.Start();

            this.DoubleBuffered = true;
            this.Owner = null;
        }

        public void DoShow()
        {
            if (didPause)
            {
                // in Google we lose initial CSS loads when we resume, so we HandleReload() instead
                //if(extendedWebBrowser1.Document != null)
                //   extendedWebBrowser1.Document.InvokeScript("HCResume");

                HandleReload();

                didPause = false;
            }

            Refresh();

            if (willBeVisible)
                shouldHideOnReady = false;
            else
                Show();
        }

        public void DoHide()
        {
            if (allowPausing && didPause == false)
            {
                if (extendedWebBrowser1.Document != null)
                    extendedWebBrowser1.Document.InvokeScript("HCPause");

                if (initCallbacks == false)
                {
                    extendedWebBrowser1.Document.MouseDown -= new HtmlElementEventHandler(Document_MouseDown);
                    extendedWebBrowser1.Document.MouseMove -= new HtmlElementEventHandler(Document_MouseMove);
                    extendedWebBrowser1.Document.MouseUp -= new HtmlElementEventHandler(Document_MouseUp);

                    extendedWebBrowser1.StartNavigate -= new EventHandler<BrowserExtendedNavigatingEventArgs>(extendedWebBrowser1_StartNavigate);
                    extendedWebBrowser1.StartNewWindow -= new EventHandler<BrowserExtendedNavigatingEventArgs>(extendedWebBrowser1_StartNewWindow);

                    initCallbacks = true;
                }

                didPause = true;
            }

            if (willBeVisible)
                shouldHideOnReady = true;
            else
                Hide();
        }

        public void LoadSnippet(string code, bool syndicate)
        {
            bool foundSyndication = false;

            if(syndicate) {
                if (code.Contains("gmodules.com"))
                {
                    if (code.Contains("synd=open"))
                    {
                        widgetCode = code.Replace("synd=open", "synd=amnesty");
                        foundSyndication = true;
                    }
                }
            }

            if(foundSyndication == false)
                widgetCode = code;

            //COMInterfaces.IOleObject oleObject = (COMInterfaces.IOleObject)this.extendedWebBrowser1.ActiveXInstance;
            //oleObject.SetClientSite(this);

            //extendedWebBrowser1.DownloadComplete += new EventHandler(extendedWebBrowser1_DownloadComplete);
            //extendedWebBrowser1.Navigated += new WebBrowserNavigatedEventHandler(extendedWebBrowser1_Navigated);

            extendedWebBrowser1.DocumentCompleted += new WebBrowserDocumentCompletedEventHandler(extendedWebBrowser1_DocumentCompleted);
            extendedWebBrowser1.DocumentTitleChanged += new EventHandler(extendedWebBrowser1_DocumentTitleChanged);

            HandleReload();
        }

        public void SetIdentifier(string identifier)
        {
            groupName = identifier;
        }

        public string GetIdentifier()
        {
            return groupName;
        }

        public void SetDomain(string value)
        {
            HidePanel();

            domain = value;
        }

        public string GetDomain()
        {
            return domain;
        }

        public void SetHypercube(bool value)
        {
            isInHypercube = value;
        }

        public bool GetHypercube()
        {
            return isInHypercube;
        }

        public void SetGallery(bool value)
        {
            isInGallery = value;
        }

        public bool GetGallery()
        {
            return isInGallery;
        }

        public void SetWidgetManager(Form1 set)
        {
            widgetManager = set;
        }

        public bool IsReady()
        {
            return ready;
        }

        public bool IsOrWillBeVisible()
        {
            return (willBeVisible || this.Visible);
        }

        public void ReadOptions()
        {
            if (groupName == null)
                return;
            
            string path = widgetManager.GetUserDataPath() + domain + ".cube\\" + groupName + ".xml";

            if (System.IO.File.Exists(path))
            {
               DataSet options = new DataSet("Widget");
               DataTable otable = options.Tables.Add("Options");
               otable.Columns.Add("Level");
               otable.Columns.Add("Drag");
               otable.Columns.Add("OriginX");
               otable.Columns.Add("OriginY");
               otable.Columns.Add("Opacity");
               otable.Columns.Add("Background");

               try
               {
                   options.ReadXml(path);

                   DataRow row = otable.Rows[0];

                   string level = (string)row["Level"];
                   if (level.Equals("levelFloating"))
                       SetOptionLevel(WidgetLevel.levelFloating);
                   else if (level.Equals("levelStandard"))
                       SetOptionLevel(WidgetLevel.levelStandard);
                   else if (level.Equals("levelEmbedded"))
                       SetOptionLevel(WidgetLevel.levelEmbedded);

                   string drag = (string)row["Drag"];
                   if (drag.Equals("dragWidget"))
                       optionDrag = WidgetDrag.dragWidget;
                   else if (drag.Equals("dragControl"))
                       optionDrag = WidgetDrag.dragControl;
                   else if (drag.Equals("dragOff"))
                       optionDrag = WidgetDrag.dragOff;

                   string x = (string)row["OriginX"];
                   topLeft.X = int.Parse(x);

                   string y = (string)row["OriginY"];
                   topLeft.Y = int.Parse(y);

                   string opacity = (string)row["Opacity"];
                   SetOptionOpacity(int.Parse(opacity));

                   string fill = (string)row["Background"];
                   if (fill.Equals("fillTransparent"))
                       SetOptionBackground(WidgetFill.fillTransparent);
                   else if (fill.Equals("fillWhite"))
                       SetOptionBackground(WidgetFill.fillWhite);
                   else if (fill.Equals("fillBlack"))
                       SetOptionBackground(WidgetFill.fillBlack);

                   if (ready)
                   {
                       if (topLeft.X != 0 && topLeft.Y != 0)
                           this.SetDesktopLocation(topLeft.X, topLeft.Y);
                       else
                           this.CenterToScreen();
                   }
               }

               catch
               {
               }
           }
           else if(ready)
           {
               if (optionLevel.Equals(WidgetLevel.levelFloating) == false)
               {
                   optionLevel = WidgetLevel.levelNone;
                   SetOptionLevel(WidgetLevel.levelFloating);
               }

               if (optionDrag.Equals(WidgetDrag.dragWidget) == false)
               {
                   optionDrag = WidgetDrag.dragNone;
                   SetOptionDrag(WidgetDrag.dragWidget);
               }

               if (optionBackground.Equals(WidgetFill.fillTransparent) == false)
               {
                   optionBackground = WidgetFill.fillNone;
                   SetOptionBackground(optionBackground);
               }

               if (optionOpacity != 100)
               {
                   optionOpacity = 0;
                   SetOptionOpacity(100);
               }

               this.CenterToScreen();
           }

           ReadGlobals();

           widgetManager.LoadWidget();
        }

        public void WriteOptions()
        {
            if (ready == false)
                return;

            if (groupName == null)
                return;
           
            DataSet options = new DataSet("Widget");
            DataTable otable = options.Tables.Add("Options");
            otable.Columns.Add("Level");
            otable.Columns.Add("Drag");
            otable.Columns.Add("OriginX");
            otable.Columns.Add("OriginY");
            otable.Columns.Add("Opacity");
            otable.Columns.Add("Background");
           
            Object[] obj = new Object[6];
            obj[0] = String.Format("{0}", optionLevel);
            obj[1] = String.Format("{0}", optionDrag);
            obj[2] = String.Format("{0}", this.Location.X);
            obj[3] = String.Format("{0}", this.Location.Y);
            obj[4] = String.Format("{0}", optionOpacity);
            obj[5] = String.Format("{0}", optionBackground);
            otable.Rows.Add(obj);

            string path = widgetManager.GetUserDataPath() + domain + ".cube\\" + groupName + ".xml";
            options.WriteXml(path);

            WriteGlobals();
        }

        void ReadGlobals()
        {
            string path = widgetManager.GetUserDataPath() + "_Globals\\" + groupName + ".xml";

            if (System.IO.File.Exists(path))
            {
                foundGlobals = true;

                DataSet options = new DataSet("Widget");
                DataTable otable = options.Tables.Add("Options");
                otable.Columns.Add("AllowSleeping");
                otable.Columns.Add("AlowSuspending");
                otable.Columns.Add("AllowHosting");

                try
                {
                    options.ReadXml(path);

                    DataRow row = otable.Rows[0];

                    string o1 = (string)row["AllowSleeping"];
                    if (o1.Equals("True"))
                        allowSleeping = true;
                    else
                        allowSleeping = false;

                    string o2 = (string)row["AlowSuspending"];
                    if (o2.Equals("True"))
                        allowPausing = true;
                    else
                        allowPausing = false;

                    string o3 = (string)row["AllowHosting"];
                    if (o3.Equals("True"))
                        allowHosting = true;
                    else
                        allowHosting = false;
                }

                catch
                {
                }
            }
            else
                foundGlobals = false;
        }

        void WriteGlobals()
        {
            DataSet options = new DataSet("Widget");
            DataTable otable = options.Tables.Add("Options");
            otable.Columns.Add("AllowSleeping");
            otable.Columns.Add("AlowSuspending");
            otable.Columns.Add("AllowHosting");

            Object[] obj = new Object[3];
            obj[0] = String.Format("{0}", allowSleeping);
            obj[1] = String.Format("{0}", allowPausing);
            obj[2] = String.Format("{0}", allowHosting);
            otable.Rows.Add(obj);

            string path = widgetManager.GetUserDataPath() + "_Globals\\" + groupName + ".xml";
            options.WriteXml(path);
        }

        void SetOptionOpacity(int opacity)
        {
            if (optionOpacity != opacity)
            {
                optionOpacity = opacity;

                if (optionOpacity == 100)
                    this.Opacity = 1.0;
                else
                    this.Opacity = (double)opacity / 100.0;
            }
        }

        void SetOptionLevel(WidgetLevel level)
        {
            if (optionLevel.Equals(level) == false)
            {
                optionLevel = level;

                if (isInGallery)
                {
                    this.Owner = widgetManager.gallery;
                    this.TopMost = true;
                     return;
                }
                else if (isInHypercube)
                {
                    this.Owner = widgetManager;
                    this.TopMost = true;
                    return;
                }
                else
                    this.Owner = null;

                switch (optionLevel)
                {
                    case WidgetLevel.levelFloating:
                        this.TopMost = true;
                    break;

                    case WidgetLevel.levelStandard:
                        this.TopMost = false;
                        break;

                    case WidgetLevel.levelEmbedded:
                    break;
                }
            }
        }

        void SetOptionDrag(WidgetDrag drag)
        {
            if (optionDrag.Equals(drag) == false)
            {
                optionDrag = drag;
            }
        }

        void SetOptionBackground(WidgetFill fill)
        {
            if (optionBackground.Equals(fill) == false)
            {
                optionBackground = fill;

                if (extendedWebBrowser1.Document == null)
                {
                    initFill = true;
                    return;
                }

                switch (optionBackground)
                {
                    case WidgetFill.fillTransparent:
                        extendedWebBrowser1.Document.InvokeScript("HCSetBackground", new object[] { "#FEFFFE" });
                        break;

                    case WidgetFill.fillWhite:
                         extendedWebBrowser1.Document.InvokeScript("HCSetBackground", new object[] { "#FFFFFF" });
                        break;

                    case WidgetFill.fillBlack:
                        extendedWebBrowser1.Document.InvokeScript("HCSetBackground", new object[] { "#000000" });
                        break;
                }
            }
        }

        public void ResetOptionLevel()
        {
            WidgetLevel saveOptionLevel = optionLevel;
            optionLevel = WidgetLevel.levelNone;
            SetOptionLevel(saveOptionLevel);
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

        void HandleReload()
        {
            bool hostRemotely = (allowHosting ? false : true);

            if (hostRemotely)
            {
                string postData = String.Format(
                    "id={0}&version={1}&code={2}",
                    groupName,
                    widgetManager.MarkerFromCode(groupName),
                    Uri.EscapeDataString(widgetCode));

                try
                {
                    extendedWebBrowser1.Navigate(
                         "http://www.amnestywidgets.com/hypercube/winhost/widget.php",
                         "",
                         UTF8Encoding.UTF8.GetBytes(postData.ToCharArray()),
                         "Content-Type: application/x-www-form-urlencoded\nAccept: application/x-www-form-urlencoded\n");
                }

                catch
                {
                    hostRemotely = false;
                }
            }
            
            if(hostRemotely == false)
            {
                string html = Amnesty_Hypercube.Properties.Resources.Widget;
                string widgetHtml = html.Replace("^snippet", widgetCode);

                extendedWebBrowser1.DocumentText = widgetHtml;
            }
        }

        void ShowPanel(ref Panel panel)
        {
            if (visiblePanel == null)
            {
                visiblePanel = panel;
                
                button1.Hide();
                mouseIn = false;
                
                extendedWebBrowser1.Anchor = AnchorStyles.None;

                saveWidth = this.Width;
                saveHeight = this.Height;

                this.Width += 250;
                if (this.Height < 175)
                    this.Height = 175;

                extendedWebBrowser1.Location = new Point(0, 0);
                panel.Location = new Point(extendedWebBrowser1.Size.Width, 0);
                panel.Visible = true;
                panel.Focus();

                this.Refresh();
            }
        }

        void HidePanel()
        {
            if (visiblePanel != null)
            {
                visiblePanel.Visible = false;
                visiblePanel.Location = new Point(-250,0);

                this.Width = saveWidth;
                this.Height = saveHeight;

                extendedWebBrowser1.Location = new Point(0, 0);
                extendedWebBrowser1.Anchor = AnchorStyles.Left | AnchorStyles.Top | AnchorStyles.Right | AnchorStyles.Bottom;

                this.Refresh();

                visiblePanel = null;
            }
        }

        void contextMenuStrip1_Opening(object sender, CancelEventArgs e)
        {
            closeWidgetToolStripMenuItem.Text = Amnesty_Hypercube.Properties.Resources.RemoveDesktop;

            if (System.Environment.OSVersion.Version.Major < 6 && Amnesty_Hypercube.Properties.Settings.Default.SidebarXP == false)
                pushIntoSideabarToolStripMenuItem.Enabled = false;
            else
                pushIntoSideabarToolStripMenuItem.Enabled = (isInGallery ? false : true);

            if (isInHypercube)
                closeWidgetToolStripMenuItem.Text = Amnesty_Hypercube.Properties.Resources.RemoveHypercube;
            else
                closeWidgetToolStripMenuItem.Text = Amnesty_Hypercube.Properties.Resources.RemoveDesktop;
        }

        void controlTimer_Tick(object sender, EventArgs e)
        {
            if (this.Visible == false || contextMenuStrip1.Visible || visiblePanel != null)
                return;

            if (this.Bounds.Contains(Cursor.Position))
            {
                if (mouseIn == false)
                {
                    //if (sender.Equals(floatingToolStripMenuItem))
                    //    this.Activate();

                    //extendedWebBrowser1.Focus();
  
                    button1.Show();
                    mouseIn = true;
                }
            }
            else
            {
                if (mouseIn)
                {
                    button1.Hide();
                    mouseIn = false;
                }
            }
        }

        /*
        void extendedWebBrowser1_Navigated(object sender, WebBrowserNavigatedEventArgs e)
        {
            if (isHandlingScriptErrors == false && extendedWebBrowser1.Document != null)
            {
                extendedWebBrowser1.Document.Window.Error += new HtmlElementErrorEventHandler(ScriptError);
                isHandlingScriptErrors = true;
            }
         }

        void extendedWebBrowser1_DownloadComplete(object sender, EventArgs e)
        {
             if (isHandlingScriptErrors == false && extendedWebBrowser1.Document != null)
            {
                extendedWebBrowser1.Document.Window.Error += new HtmlElementErrorEventHandler(ScriptError);
                isHandlingScriptErrors = true;
            }
        }*/

        void ScriptError(object sender, HtmlElementErrorEventArgs e)
        {
            // We got a script error, record it
            //ScriptErrorManager.Instance.RegisterScriptError(e.Url, e.Description, e.LineNumber);

            // Let the browser know we handled this error.
            e.Handled = true;
        }

        void extendedWebBrowser1_DocumentCompleted(object sender, WebBrowserDocumentCompletedEventArgs e)
        {
            //COMInterfaces.IOleControl oleControl = (COMInterfaces.IOleControl)this.extendedWebBrowser1.ActiveXInstance;
            //oleControl.OnAmbientPropertyChange(-5513);

            willBeVisible = false;

            if (initFill)
            {
                if (optionBackground != WidgetFill.fillTransparent)
                {
                    WidgetFill saveFill = optionBackground;
                    optionBackground = WidgetFill.fillNone;
                    SetOptionBackground(saveFill);
                }
            }

            if (initSize)
            {
                Rectangle r = extendedWebBrowser1.Document.Body.ScrollRectangle;
                this.SetBounds(this.Bounds.X, this.Bounds.Y, r.Width + 20, r.Height);

                if (topLeft.X != 0 && topLeft.Y != 0)
                    this.SetDesktopLocation(topLeft.X, topLeft.Y);
                else
                    this.CenterToScreen();
                
                if(shouldHideOnReady == false)
                    DoShow();

                if (widgetManager.isInGallery && isInGallery == false)
                {
                    this.TopMost = false;
                    widgetManager.gallery.TopMost = true;
                }

                initSize = false;
            }

            if(initCallbacks) {
                extendedWebBrowser1.Document.MouseDown += new HtmlElementEventHandler(Document_MouseDown);
                extendedWebBrowser1.Document.MouseMove += new HtmlElementEventHandler(Document_MouseMove);
                extendedWebBrowser1.Document.MouseUp += new HtmlElementEventHandler(Document_MouseUp);
               
                extendedWebBrowser1.StartNavigate += new EventHandler<BrowserExtendedNavigatingEventArgs>(extendedWebBrowser1_StartNavigate);
                extendedWebBrowser1.StartNewWindow += new EventHandler<BrowserExtendedNavigatingEventArgs>(extendedWebBrowser1_StartNewWindow);

                extendedWebBrowser1.Focus();
              
                initCallbacks = false;
            }

            if (shouldHideOnReady == false)
                Refresh();

            /*if (checkThumbnail == true)
            {
                object imageObject = widgetManager.GetInfoForWidget(groupName, "Image");
                Image image = null;
                if (imageObject.Equals(DBNull.Value))
                {
                    try {
                        ScreenCapture sc = new ScreenCapture();
                        Bitmap b = sc.Capture(this);
                        if(b != null)
                            widgetManager.SetInfoForWidget(groupName, "Image", b);
                    }

                    catch {
                    }
                }

                checkThumbnail = false;
            }*/

            ready = true;
        }

        void extendedWebBrowser1_Navigating(object sender, WebBrowserNavigatingEventArgs e)
        {
            string url = e.Url.ToString();
            if (url.Contains("http://talkgadget.google.com/talkgadget/"))
            {
                allowBrowserSpawning = true;

                if (foundGlobals == false)
                {
                    allowPausing = false;
                }
            }
        }

        void extendedWebBrowser1_StartNavigate(object sender, BrowserExtendedNavigatingEventArgs e)
        {
            if (ignoreClick)
            {
                ignoreClick = false;
                e.Cancel = true;
                return;
            }

            string url = e.Url.ToString();
            string frame = e.Frame;
 
            if (frame == null || frame.Length == 0)
            {
                if (url.StartsWith("http://") && url.EndsWith(".php") == false)
                {
 
                    if (url.Contains("google.com/ig/ifpc_relay"))
                    {
                         return;
                    }

                    if (this.Owner != null && this.Owner.Equals(widgetManager))
                        widgetManager.CloseCube();

                    System.Diagnostics.Process p = new System.Diagnostics.Process();
                    p.StartInfo.Verb = "open";
                    p.StartInfo.FileName = url;
                    p.Start();

                    e.Cancel = true;
                }
            }
        }

        void extendedWebBrowser1_StartNewWindow(object sender, BrowserExtendedNavigatingEventArgs e)
        {
            if (allowBrowserSpawning)
            {
                Browser browser = new Browser();
                browser.LoadPage(e.Url.ToString());
                browser.Show();

                this.AddOwnedForm(browser);

                e.Cancel = true;
            }
            else
            {
                if (this.Owner != null && this.Owner.Equals(widgetManager))
                    widgetManager.CloseCube();
            }
        }

        void extendedWebBrowser1_DocumentTitleChanged(object sender, EventArgs e)
        {
            this.Text = extendedWebBrowser1.DocumentTitle;
        }

        void Document_MouseDown(object sender, HtmlElementEventArgs e)
        {
            if (optionDrag == WidgetDrag.dragWidget)
            {
                if (e.MouseButtonsPressed == MouseButtons.Left)
                {
                    docMoveStart = new Point(e.ClientMousePosition.X, e.ClientMousePosition.Y);
                }
            }

            extendedWebBrowser1.Focus();
        }

        void Document_MouseMove(object sender, HtmlElementEventArgs e)
        {
            if (optionDrag == WidgetDrag.dragWidget)
            {
                if ((e.MouseButtonsPressed & MouseButtons.Left) != 0)
                {
                    Point deltaPos = new Point(e.ClientMousePosition.X - docMoveStart.X, e.ClientMousePosition.Y - docMoveStart.Y);
                    this.Location = new Point(this.Location.X + deltaPos.X, this.Location.Y + deltaPos.Y);
                    if (deltaPos.X != 0 || deltaPos.Y != 0)
                    {
                        ignoreClick = true;
                    }
                }
            }
        }

        void Document_MouseUp(object sender, HtmlElementEventArgs e)
        {
            HtmlElement elem = extendedWebBrowser1.Document.GetElementFromPoint(e.MousePosition);
            if (elem != null)
            {
                if (elem.TagName.Equals("EMBED") || elem.TagName.Equals("OBJECT"))
                {
                    this.Focus();

                    extendedWebBrowser1.Focus();
                }
            }
        }

        private void Widget_MouseDown(object sender, System.Windows.Forms.MouseEventArgs e)
        {
            if (optionDrag == WidgetDrag.dragWidget || optionDrag == WidgetDrag.dragControl)
            {
                if (e.Button == MouseButtons.Left)
                {
                    moveStart = new Point(e.X, e.Y);
                 }
            }
        }

        private void Widget_MouseMove(object sender, System.Windows.Forms.MouseEventArgs e)
        {
            if (optionDrag == WidgetDrag.dragWidget || optionDrag == WidgetDrag.dragControl)
            {
                if ((e.Button & MouseButtons.Left) != 0)
                {
                    Point deltaPos = new Point(e.X - moveStart.X, e.Y - moveStart.Y);
                    this.Location = new Point(this.Location.X + deltaPos.X, this.Location.Y + deltaPos.Y);

                    if (deltaPos.X != 0 || deltaPos.Y != 0)
                    {
                        ignoreClick = true;
                        ignoreInfoClick = true;
                    }
                 }
            }
        }

        private void hideToolStripMenuItem_Click(object sender, EventArgs e)
        {
            IEnumerator enumerator = this.OwnedForms.GetEnumerator();
            while (enumerator.MoveNext())
            {
                Form form = (Form)enumerator.Current;
                form.Close();
            }
            
            DoHide();
            WriteOptions();
        }

        private void closeWidgetToolStripMenuItem_Click(object sender, EventArgs e)
        {
            isInHypercube = false;
            isInGallery = false;

            IEnumerator enumerator = this.OwnedForms.GetEnumerator();
            while (enumerator.MoveNext())
            {
                Form form = (Form)enumerator.Current;
                form.Close();
            }
                
            this.Hide();

            widgetManager.ForgetWidget(groupName, domain);
        }

        private void copyCodeToClipboardToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string code = (string)widgetManager.GetInfoForWidget(groupName, "Code");
            Clipboard.SetText(code);
        }

        private void redrawToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Refresh();
        }

        private void reloadToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (initCallbacks == false)
            {
                extendedWebBrowser1.Document.MouseDown -= new HtmlElementEventHandler(Document_MouseDown);
                extendedWebBrowser1.Document.MouseMove -= new HtmlElementEventHandler(Document_MouseMove);
                extendedWebBrowser1.Document.MouseUp -= new HtmlElementEventHandler(Document_MouseUp);

                extendedWebBrowser1.StartNavigate -= new EventHandler<BrowserExtendedNavigatingEventArgs>(extendedWebBrowser1_StartNavigate);
                extendedWebBrowser1.StartNewWindow -= new EventHandler<BrowserExtendedNavigatingEventArgs>(extendedWebBrowser1_StartNewWindow);

                initCallbacks = true;
            }

            HandleReload();
        }

        private void uninstallWidgetToolStripMenuItem_Click(object sender, EventArgs e)
        {
            ShowPanel(ref panel3);
        }

        private void button2_Click(object sender, EventArgs e)
        {
            WidgetLevel newLevel = optionLevel;
            switch (comboBox1.SelectedIndex)
            {
                case 0:
                    newLevel = WidgetLevel.levelFloating;
                    break;

                case 1:
                    newLevel = WidgetLevel.levelStandard;
                    break;
            }
            SetOptionLevel(newLevel);

            WidgetDrag newDrag = optionDrag;
            switch (comboBox2.SelectedIndex)
            {
                case 0:
                    newDrag = WidgetDrag.dragWidget;
                    break;

                case 1:
                    newDrag = WidgetDrag.dragControl;
                    break;

                case 2:
                    newDrag = WidgetDrag.dragOff;
                    break;
            }
            SetOptionDrag(newDrag);

            HidePanel();
        }

        private void button3_Click(object sender, EventArgs e)
        {
            HidePanel();

            string name = (string)widgetManager.GetInfoForWidget(groupName, "Title");
            if (name.Equals(textBox1.Text) == false)
            {
                widgetManager.SetInfoForWidget(groupName, "Title", textBox1.Text);
            }

            allowSleeping = checkBox1.Checked;
            allowPausing = checkBox2.Checked;
            allowHosting = checkBox3.Checked;
        }

        private void button4_Click(object sender, EventArgs e)
        {
            HidePanel();
        }

        private void button5_Click(object sender, EventArgs e)
        {
            this.Owner = null;

            Hide();
            widgetManager.RemoveWidget(groupName);
            Close();
        }

        private void displaySettingsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (isInHypercube)
                comboBox1.Enabled = false;
            else
                comboBox1.Enabled = true;

            switch (optionLevel)
            {
                case WidgetLevel.levelFloating:
                    comboBox1.SelectedIndex = 0;
                    break;

                case WidgetLevel.levelStandard:
                    comboBox1.SelectedIndex = 1;
                    break;
            }

            switch (optionDrag)
            {
                case WidgetDrag.dragWidget:
                    comboBox2.SelectedIndex = 0;
                    break;

                case WidgetDrag.dragControl:
                    comboBox2.SelectedIndex = 1;
                    break;

                case WidgetDrag.dragOff:
                    comboBox2.SelectedIndex = 2;
                    break;
            }

            comboBox3.Enabled = false;
            switch (optionBackground)
            {
                case WidgetFill.fillTransparent:
                    comboBox3.SelectedIndex = 0;
                    break;

                case WidgetFill.fillWhite:
                    comboBox3.SelectedIndex = 1;
                    break;

                case WidgetFill.fillBlack:
                    comboBox3.SelectedIndex = 2;
                    break;
            }
            comboBox3.Enabled = true;

            trackBar1.Value = optionOpacity;

            ShowPanel(ref panel1);
        }

        private void globalPropertiesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string name = (string)widgetManager.GetInfoForWidget(groupName, "Title");
            textBox1.Text = name;

            checkBox1.Checked = allowSleeping;
            checkBox2.Checked = allowPausing;
            checkBox3.Checked = allowHosting;

            ShowPanel(ref panel2);
        }

        private void comboBox3_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (comboBox3.Enabled == false)
                return;

            switch (comboBox3.SelectedIndex)
            {
                case 0:
                    SetOptionBackground(WidgetFill.fillTransparent);
                    break;

                case 1:
                    SetOptionBackground(WidgetFill.fillWhite);
                    break;

                case 2:
                    SetOptionBackground(WidgetFill.fillBlack);
                    break;
            }
         }

        private void trackBar1_Scroll(object sender, EventArgs e)
        {
            SetOptionOpacity(trackBar1.Value);
        }

        private void pushIntoSideabarToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string name = (string)widgetManager.GetInfoForWidget(groupName, "Title");

            string confirm = String.Format(Amnesty_Hypercube.Properties.Resources.SidebarInstall, name);
            DialogResult dr = MessageBox.Show(confirm, "", MessageBoxButtons.YesNo);
            if (dr == DialogResult.Yes)
            {
                DoHide();
                widgetManager.AddToSidebar(groupName, widgetCode, name, this.Bounds.Width - 20, this.Bounds.Height);
            }           
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (ignoreInfoClick)
            {
                ignoreInfoClick = false;
                return;
            }

            Point p = this.Location;
            MouseEventArgs m = (MouseEventArgs)e;
            p.X += (this.Size.Width - 20) + m.X;
            p.Y += m.Y;
            contextMenuStrip1.Show(p, ToolStripDropDownDirection.BelowRight);
        }

        /*
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

        #endregion */
     }
 }