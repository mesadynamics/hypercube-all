using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;
using System.Media;
using System.IO;
using System.Net;
using System.Threading;

using Org.Vesic.WinForms;
//using gma.System.Windows;

namespace Amnesty_Hypercube
{
    public partial class Form1 : Form
    {
        Form2 creator = new Form2();
        Form4 splash = new Form4();
        public Form3 gallery = new Form3();
        FormState formState = new FormState();
        ArrayList blotters = new ArrayList();

        //UserActivityHook actHook = new UserActivityHook(); // used for tracking mouse for right click 
        //private Point mouse;

        String userDataPath = null;
        public Flipper flipper = new Flipper();

        public DataSet widgets = new DataSet("Library");
        public DataSet instances = new DataSet("Instances");
        ArrayList desktop = new ArrayList();
        ArrayList hypercube = new ArrayList();

        public Hashtable providers = null;
        public Hashtable coders = null;
        public Hashtable tags = null;

        public ImageList images = new ImageList();  // generic image library
        //public Hashtable tempImages = new Hashtable();  // generic image library (when images are locked)

        int imageSessionCount = 0;
        System.Windows.Forms.Timer imageSessionTimer = new System.Windows.Forms.Timer();
        Hashtable imageSessions = new Hashtable();

        public ArrayList providersFeatured = new ArrayList();
        public ArrayList providersHidden = new ArrayList();
        public ArrayList providersSpoofed = new ArrayList();

        SoundPlayer createSound = new SoundPlayer(Amnesty_Hypercube.Properties.Resources.Create);
        SoundPlayer enterSound = new SoundPlayer(Amnesty_Hypercube.Properties.Resources.Enter);
        SoundPlayer clickSound = new SoundPlayer(Amnesty_Hypercube.Properties.Resources.Click);
        SoundPlayer switchSound = new SoundPlayer(Amnesty_Hypercube.Properties.Resources.Switch);

        public bool isInHypercube = false;
        public bool isInGallery = false;
        bool isUpdating = false;
        bool didReadData = false;

        bool usingDefaultLibrary = false;

        bool didHideCreator = false;
        String cubeDomain = "_Cube1";

        System.Windows.Forms.Timer pasteTimer = new System.Windows.Forms.Timer();
        System.Windows.Forms.Timer updateTimer = new System.Windows.Forms.Timer();
        string pasteBuffer = null;

        string createTitle = null;
        bool createTitleCustom = false;
        string createThumbnail = null;
        bool createThumbnailCustom = false;
        bool didSwitchOutOfCube = false;

        int updateHash = 0;

        [Flags]
        internal enum WindowStyles : int {
            ExToolWindow = 0x00000080,
            ExAppWindow = 0x00040000
        };

        public enum INTERNETFEATURELIST
        {
            FEATURE_WEBLOC_POPUPMANAGEMENT = 5,
            FEATURE_LOCALMACHINE_LOCKDOWN = 8,
            FEATURE_DISABLE_NAVIGATION_SOUNDS = 21
            //FEATURE_BLOCK_LMZ_IMG = 0,
            //FEATURE_BLOCK_LMZ_OBJECT = 1,
            //FEATURE_BLOCK_LMZ_SCRIPT = 2
        }

        private const int SET_FEATURE_ON_THREAD = 0x00000001;
        private const int SET_FEATURE_ON_PROCESS = 0x00000002;
        private const int SET_FEATURE_IN_REGISTRY = 0x00000004;
        private const int SET_FEATURE_ON_THREAD_LOCALMACHINE = 0x00000008;
        private const int SET_FEATURE_ON_THREAD_INTRANET = 0x00000010;
        private const int SET_FEATURE_ON_THREAD_TRUSTED = 0x00000020;
        private const int SET_FEATURE_ON_THREAD_INTERNET = 0x00000040;
        private const int SET_FEATURE_ON_THREAD_RESTRICTED = 0x00000080;

        [DllImport("urlmon.dll")]
        [PreserveSig]
        [return: MarshalAs(UnmanagedType.Error)]
        static extern int CoInternetSetFeatureEnabled(
             INTERNETFEATURELIST FeatureEntry,
             [MarshalAs(UnmanagedType.U4)] int dwFlags,
             bool fEnable);

        public Form1()
        {
            InitializeComponent();
            InitializeData();

            if(Amnesty_Hypercube.Properties.Settings.Default.LocalMachineLockdown)
                CoInternetSetFeatureEnabled(INTERNETFEATURELIST.FEATURE_LOCALMACHINE_LOCKDOWN, SET_FEATURE_ON_PROCESS, true);

            CoInternetSetFeatureEnabled(INTERNETFEATURELIST.FEATURE_WEBLOC_POPUPMANAGEMENT, SET_FEATURE_ON_PROCESS, true);
            CoInternetSetFeatureEnabled(INTERNETFEATURELIST.FEATURE_DISABLE_NAVIGATION_SOUNDS, SET_FEATURE_ON_PROCESS, true);

            images.ImageSize = new Size(100, 100);
            images.ColorDepth = ColorDepth.Depth32Bit;
            images.Images.Add("DEFAULT(Blank)", Amnesty_Hypercube.Properties.Resources.Blank);
            images.Images.Add("DEFAULT(LargeWorld)", flipper.FlipImage(Amnesty_Hypercube.Properties.Resources.LargeWorld));
            images.Images.Add("DEFAULT(LargeGear)", flipper.FlipImage(Amnesty_Hypercube.Properties.Resources.LargeGear));
            images.Images.Add("DEFAULT(LargeCube)", flipper.FlipImage(Amnesty_Hypercube.Properties.Resources.LargeCube));

            createSound.Load();
            enterSound.Load();
            clickSound.Load();
            switchSound.Load();

            /*Microsoft.Win32.RegistryKey key = Microsoft.Win32.Registry.LocalMachine.OpenSubKey("SOFTWARE\\Microsoft\\Internet Explorer\\Main\\FeatureControl\\FEATURE_BLOCK_LMZ_SCRIPT");
            if (key == null)
            {
                MessageBox.Show("missing key");
                key = Microsoft.Win32.Registry.LocalMachine.CreateSubKey("SOFTWARE\\Microsoft\\Internet Explorer\\Main\\FeatureControl\\FEATURE_BLOCK_LMZ_SCRIPT");
                if (key != null)
                {
                    key.SetValue("Amnesty Hypercube.exe", 0);
                    key.Close();
                }
            }
            else
            {
                key.Close();
                Microsoft.Win32.Registry.LocalMachine.DeleteSubKey("SOFTWARE\\Microsoft\\Internet Explorer\\Main\\FeatureControl\\FEATURE_BLOCK_LMZ_SCRIPT");
            }
            */

            int provisionalHash = Amnesty_Hypercube.Properties.Settings.Default.LibraryImageHash;
            int verifier = Amnesty_Hypercube.Properties.Settings.Default.LibraryCodeHash;
            if (provisionalHash > 0  && verifier > 0)
            {
                provisionalHash -= verifier;
                verifier -= 983;
                if (provisionalHash > 0  && (provisionalHash % 1423) == 0 && (provisionalHash % 223) == verifier)
                    updateHash = provisionalHash / 1423;
            }

            creator.SetWidgetManager(this);
            gallery.SetWidgetManager(this);

            //actHook.OnMouseActivity += new MouseEventHandler(global_MouseActivity);

            notifyIcon1.MouseClick += new MouseEventHandler(notifyIcon1_MouseClick);
            notifyIcon1.MouseDoubleClick += new MouseEventHandler(notifyIcon1_MouseDoubleClick);

            SetupButton(
                button1,
                Amnesty_Hypercube.Properties.Resources.Close,
                Amnesty_Hypercube.Properties.Resources.CloseDown,
                Amnesty_Hypercube.Properties.Resources.CloseOver);

            SetupButton(
                button2,
                Amnesty_Hypercube.Properties.Resources.Help,
                Amnesty_Hypercube.Properties.Resources.HelpDown,
                Amnesty_Hypercube.Properties.Resources.HelpOver);

            SetupButton(
                button3,
                Amnesty_Hypercube.Properties.Resources.Providers,
                Amnesty_Hypercube.Properties.Resources.ProvidersDown,
                Amnesty_Hypercube.Properties.Resources.ProvidersOver);

            SetupButton(
                button4,
                Amnesty_Hypercube.Properties.Resources.Cube,
                Amnesty_Hypercube.Properties.Resources.CubeDown,
                Amnesty_Hypercube.Properties.Resources.CubeOver);

            SetupButton(
                button5,
                Amnesty_Hypercube.Properties.Resources.Library,
                Amnesty_Hypercube.Properties.Resources.LibraryDown,
                Amnesty_Hypercube.Properties.Resources.LibraryOver);

            contextMenuStrip1.Opening += new CancelEventHandler(contextMenuStrip1_Opening);
            contextMenuStrip3.Opening += new CancelEventHandler(contextMenuStrip3_Opening);

            if (Clipboard.ContainsText())
                pasteBuffer = Clipboard.GetText();

            imageSessionTimer.Enabled = true;
            imageSessionTimer.Interval = 10;
            imageSessionTimer.Tick += new EventHandler(imageSessionTimer_Tick);
            imageSessionTimer.Start();

            pasteTimer.Enabled = true;
            pasteTimer.Interval = 250;
            pasteTimer.Tick += new EventHandler(pasteTimer_Tick);
            pasteTimer.Start();

            Rectangle screen = Screen.PrimaryScreen.Bounds;
            screen.Y = screen.Height;
            this.Bounds = screen;

            foreach (Screen s in Screen.AllScreens)
            {
                if (s.Equals(Screen.PrimaryScreen) == false)
                {
                    Form5 blotter = new Form5();
                    blotter.Bounds = s.Bounds;
                    blotters.Add(blotter);
                }
            }

            this.DoubleBuffered = true;

            ApplicationDidFinishLaunching();
        }

        protected override void WndProc(ref Message m)
        {
            if (m.Msg == (int)0x1C && isInHypercube)
            {
                if(m.WParam == (IntPtr)0)
                {
                    if (didSwitchOutOfCube == false)
                    {
                        foreach(Form f in this.OwnedForms)
                            f.Hide();

                        this.Hide();
                        didSwitchOutOfCube = true;
                    }
                }
                else if (m.WParam == (IntPtr)1)
                {
                    if (didSwitchOutOfCube)
                    {
                        this.Show();

                        foreach(Form f in this.OwnedForms)
                            f.Show();

                        didSwitchOutOfCube = false;
                    }
                }
            }

            base.WndProc(ref m);
        }

        void SetupButton(Button button, Image i1, Image i2, Image i3)
        {
            button.Click += new EventHandler(button_Click);

            ImageList b = new ImageList();
            b.ImageSize = new Size(48, 48);
            b.ColorDepth = ColorDepth.Depth32Bit;
            b.Images.Add(i1);
            b.Images.Add(i2);
            b.Images.Add(i3);
            button.ImageList = b;
            button.ImageIndex = 0;
            button.MouseEnter += new EventHandler(button_MouseEnter);
            button.MouseLeave += new EventHandler(button_MouseLeave);
            button.MouseDown += new MouseEventHandler(button_MouseDown);
            button.MouseUp += new MouseEventHandler(button_MouseUp);
        }

        void button_MouseEnter(object sender, EventArgs e)
        {
            if (Amnesty_Hypercube.Properties.Settings.Default.PrefUISound)
                enterSound.Play();

            Button b = (Button)sender;
            b.ImageIndex = 2;
        }

        void button_MouseLeave(object sender, EventArgs e)
        {
            Button b = (Button)sender;
            b.ImageIndex = 0;
        }

        void button_MouseDown(object sender, MouseEventArgs e)
        {
            Button b = (Button)sender;
            b.ImageIndex = 1;
        }

        void button_MouseUp(object sender, MouseEventArgs e)
        {
            Button b = (Button)sender;
            b.ImageIndex = 0;
        }

        void InitializeDesktop()
        {
            ReadDomain("_Desktop");

            if (Amnesty_Hypercube.Properties.Settings.Default.PrefLaunchHidden)
                return;

            IEnumerator enumerator = desktop.GetEnumerator();
            while (enumerator.MoveNext())
            {
                string identifier = (string)enumerator.Current;

                DataTable wtable = widgets.Tables["Widgets"];
                if (wtable.Rows.Contains(identifier))
                {
                    DataRow row = wtable.Rows.Find(identifier);
                    string rowCode = (string)row["Code"];
                    CreateWidget(rowCode, identifier, "_Desktop");
                }
            }
       }

        void InitializeData()
        {
            DataTable wtable = widgets.Tables.Add("Widgets");
            DataColumn[] wkeys = new DataColumn[1];
            wkeys[0] = wtable.Columns.Add("Identifier");
            wtable.Columns.Add("Code");
            wtable.Columns.Add("Title");
            wtable.Columns.Add("Image");
            wtable.PrimaryKey = wkeys;

            DataTable itable = instances.Tables.Add("Widgets");
            DataColumn[] ikeys = new DataColumn[1];
            ikeys[0] = itable.Columns.Add("Identifier");
            itable.Columns.Add("Widget", typeof(Widget));
            itable.PrimaryKey = ikeys;
        }

        void WriteData()
        {
            WriteDomain("_Desktop");

            string path = userDataPath + "WidgetLibrary.xml";
            widgets.WriteXml(path);

            if (updateHash > 0)
            {
                int calculatedHash = updateHash * 1423;
                int verifier = 983 + (calculatedHash % 223);
                calculatedHash += verifier;

                Amnesty_Hypercube.Properties.Settings.Default.LibraryImageHash = calculatedHash;
                Amnesty_Hypercube.Properties.Settings.Default.LibraryCodeHash = verifier;
            }
            else
            {
                Amnesty_Hypercube.Properties.Settings.Default.LibraryImageHash = 0;
                Amnesty_Hypercube.Properties.Settings.Default.LibraryCodeHash = 0;
            }

            Amnesty_Hypercube.Properties.Settings.Default.DefaultCube = cubeDomain;

            Amnesty_Hypercube.Properties.Settings.Default.Save();
        }

        void ReadData()
        {
            if (didReadData)
                return;

            didReadData = true;

            string path = userDataPath + "WidgetLibrary.xml";
            if (File.Exists(path))
            {
                try
                {
                    widgets.ReadXml(path);

                    IEnumerator enumerator = widgets.Tables["Widgets"].Rows.GetEnumerator();
                    while (enumerator.MoveNext())
                    {
                        DataRow row = (DataRow)enumerator.Current;
                        string identifier = (string)row["Identifier"];
                        string code = (string)row["Code"];
                        string title = (string)row["Title"];
                        object imageObject = row["Image"];
                        Image image = null;
                        if (imageObject.Equals(DBNull.Value) == false)
                        {
                            try
                            {
                                String i = (String)imageObject;
                                byte[] ibuffer = Convert.FromBase64String(i);
                                image = new Bitmap(new MemoryStream(ibuffer));
                            }

                            catch
                            {
                                image = null;
                            }
                        }

                        AddMenuItem(identifier, title, image);
                    }
                }

                catch
                {
                }
            }
            else
            {
                bool canConnect = true;

                if (System.Net.NetworkInformation.NetworkInterface.GetIsNetworkAvailable() == false)
                    canConnect = false;

                //RequestObjectState os = new RequestObjectState();
                //os.widgetManager = this;

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create("http://www.amnestywidgets.com/hypercube/widgets/default.xml");
                req.Timeout = 20000;

                req.CachePolicy = new System.Net.Cache.HttpRequestCachePolicy(System.Net.Cache.HttpRequestCacheLevel.Revalidate);

                if (canConnect == false)
                    req.CachePolicy = new System.Net.Cache.HttpRequestCachePolicy(System.Net.Cache.HttpRequestCacheLevel.CacheOnly);

                //os.request = req;
                //os.identifier = "DEFAULT:WGT";
                //ThreadPool.QueueUserWorkItem(new WaitCallback(RequestThread), os);

                HttpWebResponse res = (HttpWebResponse)req.GetResponse();
                StreamReader stream = new StreamReader(res.GetResponseStream(), Encoding.UTF8);
                string xml = stream.ReadToEnd();

                res.Close();
                stream.Close();

                Cursor = Cursors.Arrow;

                ParseWidgets(xml);
            }
        }

        void WriteDomain(string domain)
        {
            ArrayList visibleWidgets = new ArrayList();

            IEnumerator enumerator = instances.Tables["Widgets"].Rows.GetEnumerator();

            if (domain.Equals("_Desktop"))
            {
                while (enumerator.MoveNext())
                {
                    DataRow row = (DataRow)enumerator.Current;
                    string identifier = (string)row["Identifier"];
                    Widget w = (Widget)row["Widget"];

                    if (w.IsOrWillBeVisible() && desktop.Contains(w.GetIdentifier()))
                    {
                        w.WriteOptions();
                        visibleWidgets.Add(w.GetIdentifier());
                    }
                }
            }
            else
            {
                while (enumerator.MoveNext())
                {
                    DataRow row = (DataRow)enumerator.Current;
                    string identifier = (string)row["Identifier"];
                    Widget w = (Widget)row["Widget"];

                    if (w.IsOrWillBeVisible() && hypercube.Contains(w.GetIdentifier()))
                    {
                        w.WriteOptions();
                        visibleWidgets.Add(w.GetIdentifier());
                    }
                }
            }

            DataSet data = new DataSet(domain);
            DataTable dtable = data.Tables.Add("Array");
            dtable.Columns.Add("Values");

            IEnumerator enumerator2 = visibleWidgets.GetEnumerator();
            while (enumerator2.MoveNext())
            {
                dtable.Rows.Add(enumerator2.Current);
            }

            string path = userDataPath + domain + ".cube\\CubeSettings.xml";
            data.WriteXml(path);
        }

        void ReadDomain(string domain)
        {
            bool didReadDomain = false;

            DataSet data = new DataSet(domain);
            DataTable dtable = data.Tables.Add("Array");
            dtable.Columns.Add("Values");

            string path = userDataPath + domain + ".cube\\CubeSettings.xml";
            if (File.Exists(path))
            {
                try
                {
                    data.ReadXml(path);

                    if (domain.Equals("_Desktop"))
                    {
                        desktop = new ArrayList();

                        IEnumerator enumerator = dtable.Rows.GetEnumerator();
                        while (enumerator.MoveNext())
                        {
                            DataRow row = (DataRow)enumerator.Current;
                            desktop.Add(row["Values"]);
                        }

                        didReadDomain = true;
                    }
                    else
                    {
                        hypercube = new ArrayList();

                        IEnumerator enumerator = dtable.Rows.GetEnumerator();
                        while (enumerator.MoveNext())
                        {
                            DataRow row = (DataRow)enumerator.Current;
                            hypercube.Add(row["Values"]);
                        }

                        didReadDomain = true;
                    }
                }

                catch
                {
                }
            }

            if (didReadDomain == false)
            {
                 if (domain.Equals("_Desktop"))
                     desktop = new ArrayList();
                 else
                     hypercube = new ArrayList();
             }
        }

        void ApplicationDidFinishLaunching()
        {
            bool newLibrary = false;

            string appDataPath = Application.UserAppDataPath;
            string appVersion = Application.ProductVersion;
 
            userDataPath = appDataPath.Substring(0, appDataPath.Length - appVersion.Length);

            string dir = userDataPath + "FirstRun";
            if (File.Exists(dir) == false)
            {
                File.Create(dir);
                newLibrary = true;
            }

            dir = userDataPath + "_Desktop.cube";
            if (Directory.Exists(dir) == false)
                Directory.CreateDirectory(dir);

            if (newLibrary)
            {
                dir = userDataPath + "_Cube1.cube";
                if (Directory.Exists(dir) == false)
                    Directory.CreateDirectory(dir);

                dir = userDataPath + "_Cube2.cube";
                if (Directory.Exists(dir) == false)
                    Directory.CreateDirectory(dir);

                dir = userDataPath + "_Cube3.cube";
                if (Directory.Exists(dir) == false)
                    Directory.CreateDirectory(dir);
            }
            else
            {
                dir = userDataPath + Amnesty_Hypercube.Properties.Settings.Default.DefaultCube + ".cube";
                if (Directory.Exists(dir) == false)
                    Directory.CreateDirectory(dir);
            }

            dir = userDataPath + "_Globals";
            if (Directory.Exists(dir) == false)
                Directory.CreateDirectory(dir);

            cubeDomain = Amnesty_Hypercube.Properties.Settings.Default.DefaultCube;

            
            if (Amnesty_Hypercube.Properties.Settings.Default.HypercubeVersion < 15)
            {
                OpenCube();
                OpenGallery(Form3.GalleryModes.galleryWelcome);
            }
            else
                ReadData();
           
            if(newLibrary == false)
                InitializeDesktop();

            LoadLibrary();
         }

        protected override void OnClosing(CancelEventArgs e)
        {
            base.OnClosing(e);

            if(e.Cancel == true)
                return;

            WriteData();
        }

        protected override CreateParams CreateParams {
            get {
                CreateParams cp = base.CreateParams;
                cp.ExStyle |= (int) WindowStyles.ExToolWindow;
                cp.ExStyle &= (int) WindowStyles.ExAppWindow;
                return cp;
            }
        }
        
        void imageSessionTimer_Tick(object sender, EventArgs e)
        {
            if (imageSessions.Count > 0)
            {
                if (imageSessionCount < 8)
                {
                    IDictionaryEnumerator enumerator = imageSessions.GetEnumerator();
                    enumerator.MoveNext();

                    string sessionKey = (string)enumerator.Key;
                    RequestObjectState os = (RequestObjectState)enumerator.Value;

                    HttpWebRequest req = (HttpWebRequest)WebRequest.Create(os.url);
                    req.Timeout = os.timeout;
                    req.CachePolicy = os.policy;
                    os.request = req;

                    ThreadPool.QueueUserWorkItem(new WaitCallback(RequestThread), os);
                    imageSessionCount++;

                    imageSessions.Remove(sessionKey);
                }
            }

            /*
            if (tempImages.Count > 0 && (isInGallery == false || gallery.GetGalleryMode() != Form3.GalleryModes.galleryProviders))
            {
                IDictionaryEnumerator enumerator = tempImages.GetEnumerator();
                enumerator.MoveNext();

                string imageKey = (string)enumerator.Key;
                Image imageValue = (Image)enumerator.Value;

                images.Images.Add(imageKey, imageValue);

                tempImages.Remove(imageKey);
            }*/
        }

        void pasteTimer_Tick(object sender, EventArgs e)
        {
            if (Clipboard.ContainsText())
            {
                string pasteString = Clipboard.GetText();
                if (pasteString.Length > 0)
                {
                    if (pasteBuffer == null || pasteString.Equals(pasteBuffer) == false)
                    {
                        if (
                            (Amnesty_Hypercube.Properties.Settings.Default.PrefNoClickImport && creator.Visible == false) ||
                            // check for application frontmost down here
                            (isInGallery)
                        )
                        {
                            if (Amnesty_Hypercube.Properties.Settings.Default.PrefCreateSound)
                                createSound.Play();

                           InstallWidgetWithCode(pasteString, true, false);
                        }
                        else if (TestWidgetWithCode(pasteString))
                            creator.SetString(pasteString);
  
                        pasteBuffer = pasteString;
                    }
                }
            }
        }

        void updateTimer_Tick(object sender, EventArgs e)
        {
            UpdateLibrary(false);
        }

        public void LoadWidget()
        {
            updateHash++;
        }

        public void CloseWidget(string identifier)
        {
            DataTable itable = instances.Tables["Widgets"];
            if (itable.Rows.Contains(identifier))
            {
                DataRow row = itable.Rows.Find(identifier);
  
                Widget w = (Widget)row["Widget"];
                w.Close();

                itable.Rows.Remove(row);
            }

            desktop.Remove(identifier);
            hypercube.Remove(identifier);
        }

        public void RemoveWidget(string identifier)
        {
            CloseWidget(identifier);

            DataTable wtable = widgets.Tables["Widgets"];
            if (wtable.Rows.Contains(identifier))
            {
                DataRow row = wtable.Rows.Find(identifier);
                wtable.Rows.Remove(row);
            }

            IEnumerator enumerator = contextMenuStrip2.Items.GetEnumerator();
            while (enumerator.MoveNext())
            {
                object menu = enumerator.Current;
                if (menu.GetType() == typeof(ToolStripMenuItem))
                {
                    ToolStripMenuItem i = (ToolStripMenuItem)menu;
                    
                    if (identifier.Equals(i.Tag)) {
                        contextMenuStrip2.Items.Remove(i);
                        break;
                    }
                }
                else
                    break;
            }

            string path = userDataPath;
            string[] dirs = Directory.GetDirectories(path);
            foreach (string dir in dirs)
            {
                if (dir.EndsWith("\\_Globals") || dir.EndsWith(".cube"))
                {
                    string options = dir + "\\" + identifier + ".xml";
                    if (File.Exists(options))
                        File.Delete(options);
                }
            }

            if (isInGallery && gallery.GetGalleryMode() == Form3.GalleryModes.galleryLibrary)
                gallery.SetupGallery(Form3.GalleryModes.galleryLibrary);
        }

        public void ForgetWidget(string identifier, string domain)
        {
            if (domain.Equals("_Desktop"))
                RemoveFromDesktop(identifier);
            else
                RemoveFromHypercube(identifier);

            string dir = null;
            if (domain == null)
            {
                if (isInHypercube)
                    dir = userDataPath + cubeDomain + ".cube";
                else
                    dir = userDataPath + "_Desktop.cube";
            }
            else
                dir = userDataPath + domain + ".cube";

            if (Directory.Exists(dir) == false)
                Directory.CreateDirectory(dir);
            else
            {
                string options = dir + "\\" + identifier + ".xml";

                if (File.Exists(options))
                    File.Delete(options);
            }

            if (domain.Equals("_Desktop"))
            {
                // kludge to stop menu from shrinking during opening via resize due to mass delete
                RefreshMenu();
            }
        }

        public void SetInfoForWidget(string identifier, string key, object info)
        {
            DataTable wtable = widgets.Tables["Widgets"];
            if (wtable.Rows.Contains(identifier))
            {
                DataRow row = wtable.Rows.Find(identifier);

                if(key.Equals("Image")) {
                    try
                    {
                        Image i = (Image)info;
                        Bitmap b = new Bitmap(i);
                        
                        MemoryStream ibuffer = new MemoryStream();
                        b.Save(ibuffer, ImageFormat.Tiff);
                        row[key] = Convert.ToBase64String(ibuffer.GetBuffer());
                    }

                    catch
                    {
                    }
                }
                else
                    row[key] = info;
            }

            if(key.Equals("Image")) {
                IEnumerator enumerator = contextMenuStrip2.Items.GetEnumerator();
                while (enumerator.MoveNext())
                {
                    object menu = enumerator.Current;
                    if (menu.GetType() == typeof(ToolStripMenuItem))
                    {
                        ToolStripMenuItem i = (ToolStripMenuItem)menu;

                        if (identifier.Equals(i.Tag))
                        {
                            i.Image = (Image)info;
                            break;
                        }
                    }
                    else
                        break;
                }
            }
            else if (key.Equals("Title"))
            {
                IEnumerator enumerator = contextMenuStrip2.Items.GetEnumerator();
                while (enumerator.MoveNext())
                {
                    object menu = enumerator.Current;
                    if (menu.GetType() == typeof(ToolStripMenuItem))
                    {
                        ToolStripMenuItem i = (ToolStripMenuItem)menu;

                        if (identifier.Equals(i.Tag))
                        {
                            i.Text = (string)info;
                            break;
                        }
                    }
                    else
                        break;
                }

                if (isInGallery && gallery.GetGalleryMode() == Form3.GalleryModes.galleryLibrary)
                    gallery.SetupGallery(Form3.GalleryModes.galleryLibrary);
            }
        }

        public object GetInfoForWidget(string identifier, string key)
        {
            DataTable wtable = widgets.Tables["Widgets"];
            if (wtable.Rows.Contains(identifier))
            {
                DataRow row = wtable.Rows.Find(identifier);
                return row[key];
            }

            return null;
        }

        public string GetUserDataPath()
        {
            return userDataPath;
        }

        public void AddToDesktop(string identifier)
        {
            if (desktop.Contains(identifier) == false)
                desktop.Add(identifier);
        }

        public void AddToHypercube(string identifier)
        {
            if (hypercube.Contains(identifier) == false)
                hypercube.Add(identifier);
        }

        public void RemoveFromDesktop(string identifier)
        {
            if (desktop.Contains(identifier))
                desktop.Remove(identifier);
        }

        public void RemoveFromHypercube(string identifier)
        {
            if (hypercube.Contains(identifier))
                hypercube.Remove(identifier);
        }

        public void AddToSidebar(string identifier, string code, string name, int width, int height)
        {
            if (isInGallery)
                gallery.CloseGallery();

            if (isInHypercube)
                CloseCube();

            string d = System.Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            string d2 = Path.Combine(d, "Microsoft");
            string d3 = Path.Combine(d2, "Windows Sidebar");
            string d4 = Path.Combine(d3, "Gadgets");
            string folder = name + ".gadget";
            string target = Path.Combine(d4, folder);

            if (Directory.Exists(target))
            {
                String msg = String.Format(Amnesty_Hypercube.Properties.Resources.SidebarConfirm, name);
                DialogResult dr = MessageBox.Show(msg, "", MessageBoxButtons.YesNo);
                if (dr == DialogResult.Yes)
                {
                    Directory.Delete(target, true);
                    System.Threading.Thread.Sleep(250);
                }
                else
                    return;
            }

            object imageObject = GetInfoForWidget(identifier, "Image");
            Image image = null;
            if (imageObject.Equals(DBNull.Value) == false)
            {
                try
                {
                    String i = (String)imageObject;
                    byte[] ibuffer = Convert.FromBase64String(i);
                    image = new Bitmap(new MemoryStream(ibuffer));
                }

                catch
                {
                    image = null;
                }
            }

            DirectoryInfo di = Directory.CreateDirectory(target);
            if (di.Exists == true)
            {
                Bitmap frontImage = Amnesty_Hypercube.Properties.Resources.gfront;
                frontImage.Save(Path.Combine(target, "front.png"));

                Bitmap logoImage = Amnesty_Hypercube.Properties.Resources.glogo;
                logoImage.Save(Path.Combine(target, "logo.png"));

                if (image == null)
                {
                    Bitmap iconImage = Amnesty_Hypercube.Properties.Resources.gicon;
                    iconImage.Save(Path.Combine(target, "icon.png"));
                }
                else
                {
                    try
                    {
                        image.Save(Path.Combine(target, "icon.png"));
                    }

                    catch
                    {
                        Bitmap iconImage = Amnesty_Hypercube.Properties.Resources.gicon;
                        iconImage.Save(Path.Combine(target, "icon.png"));
                    }
                }

                string js = Amnesty_Hypercube.Properties.Resources.gjs;
                File.WriteAllText(Path.Combine(target, "generator.js"), js);

                string css = Amnesty_Hypercube.Properties.Resources.gcss;
                string css2 = css.Replace("320", String.Format("{0}", width));
                string css3 = css2.Replace("240", String.Format("{0}", height));
                File.WriteAllText(Path.Combine(target, "generator.css"), css3);

                string htm = Amnesty_Hypercube.Properties.Resources.ghtm;
                string htm2 = htm.Replace("</div>", code + "</div>");
                File.WriteAllText(Path.Combine(target, "generator.htm"), htm2);

                string e1 = name.Replace("&", "&amp;");
                string e2 = e1.Replace("<", "&lt;");
                string ename = e2.Replace(">", "&gt;");

                string xml = Amnesty_Hypercube.Properties.Resources.gxml;
                string xml2 = xml.Replace("Generator</name>", ename + "</name>");
                string xml3 = xml2.Replace("Generator</namespace>", ename + "</namespace>");
                File.WriteAllText(Path.Combine(target, "gadget.xml"), xml3);

                {

                    System.Diagnostics.Process p = new System.Diagnostics.Process();
                    p.StartInfo.FileName = "sidebar.exe";
                    p.Start();

                    System.Threading.Thread.Sleep(250);

                    System.Windows.Forms.SendKeys.SendWait("{ENTER}");
                    System.Windows.Forms.SendKeys.SendWait("{ESC}");

                    System.Threading.Thread.Sleep(250);
                }

                {
                    System.Diagnostics.Process p = new System.Diagnostics.Process();
                    p.StartInfo.FileName = "sidebar.exe";
                    p.Start();

                    System.Threading.Thread.Sleep(250);

                    System.Windows.Forms.SendKeys.SendWait("{ENTER}");
                }
            }
        }

        public void OpenCube()
        {
            if (isInHypercube)
                return;

            if (Amnesty_Hypercube.Properties.Settings.Default.PrefUISound)
                switchSound.Play();

            isInHypercube = true;

            if (creator.Visible)
            {
                creator.Hide();
                didHideCreator = true;
            }
            else
                didHideCreator = false;

            notifyIcon1.ContextMenuStrip = contextMenuStrip3;

            WriteDomain("_Desktop");
            ReadDomain(cubeDomain);

            string cubeName = cubeDomain;
            if (cubeName.StartsWith("_"))
                cubeName = cubeDomain.Substring(1, cubeDomain.Length - 1);
            label1.Text = Amnesty_Hypercube.Properties.Resources.Hypercube + " > " + cubeName;

            foreach (Form5 f in blotters)
            {
                f.DoShow();
            }

            Rectangle screen = Screen.PrimaryScreen.Bounds;
            if(this.Bounds.Y != screen.Y)
                this.Bounds = screen;
            else
            {
                this.Show();
            }
            formState.Maximize(this);

            DataTable itable = instances.Tables["Widgets"];

            IEnumerator enumerator = desktop.GetEnumerator();
            while (enumerator.MoveNext())
            {
                string identifier = (string)enumerator.Current;
                if (hypercube.Contains(identifier) == false)
                {
                    if (itable.Rows.Contains(identifier))
                    {
                        DataRow row = itable.Rows.Find(identifier);
                        Widget w = (Widget)row["Widget"];
                        w.DoHide();
                    }
               }
            }

            IEnumerator enumerator2 = hypercube.GetEnumerator();
            while (enumerator2.MoveNext())
            {
                string identifier = (string)enumerator2.Current;
                if (itable.Rows.Contains(identifier))
                {
                    DataRow row = itable.Rows.Find(identifier);
                    Widget w = (Widget)row["Widget"];

                    w.SetDomain(cubeDomain);
                    w.ReadOptions();

                    w.SetHypercube(true);
                    w.ResetOptionLevel();
                    w.DoShow();
                }
                else {
                    DataTable wtable = widgets.Tables["Widgets"];
                    if (wtable.Rows.Contains(identifier))
                    {
                        DataRow row = wtable.Rows.Find(identifier);
                        string rowCode = (string)row["Code"];
                        Widget w = CreateWidget(rowCode, identifier, cubeDomain);

                        w.SetHypercube(true);
                        w.ResetOptionLevel();
                    }
                }
            }

            Focus();

            //if (isInGallery)
            //   gallery.Show();
        }

        public void CloseCube()
        {
            if (isInHypercube == false)
                return;

            isInHypercube = false;

            if (didHideCreator)
            {
                creator.Show();
                didHideCreator = false;
            }

            notifyIcon1.ContextMenuStrip = contextMenuStrip1;

            WriteDomain(cubeDomain);
            ReadDomain("_Desktop");

            if (isInGallery)
                 gallery.CloseGallery();
 
            DataTable itable = instances.Tables["Widgets"];

            IEnumerator enumerator = hypercube.GetEnumerator();
            while (enumerator.MoveNext())
            {
                string identifier = (string)enumerator.Current;
                if (desktop.Contains(identifier) == false)
                {
                    if (itable.Rows.Contains(identifier))
                    {
                        DataRow row = itable.Rows.Find(identifier);
                        Widget w = (Widget)row["Widget"];
                        w.DoHide();
                    }
                }
            }

            IEnumerator enumerator2 = desktop.GetEnumerator();
            while (enumerator2.MoveNext())
            {
                string identifier = (string)enumerator2.Current;
                if (itable.Rows.Contains(identifier))
                {
                    DataRow row = itable.Rows.Find(identifier);
                    Widget w = (Widget)row["Widget"];

                    w.SetDomain("_Desktop");
                    w.ReadOptions();

                    w.SetHypercube(false);
                    w.ResetOptionLevel();
                    w.DoShow();
                }
                else
                {
                    DataTable wtable = widgets.Tables["Widgets"];
                    if (wtable.Rows.Contains(identifier))
                    {
                        DataRow row = wtable.Rows.Find(identifier);
                        string rowCode = (string)row["Code"];
                        Widget w = CreateWidget(rowCode, identifier, "_Desktop");
                     }
                }
            }
            
            formState.Restore(this);
            this.Hide();

            foreach (Form5 f in blotters)
            {
                f.DoHide();
            }
        }

        void OpenGallery(Form3.GalleryModes mode)
        {
            if (isInGallery)
                return;

            isInGallery = true;

            creator.TopMost = false;
            notifyIcon1.ContextMenuStrip = contextMenuStrip3;
 
            gallery.OpenGallery(mode);
        }

        public void CloseGallery()
        {
            if (isInGallery == false)
                return;

            isInGallery = false;

            if (isInHypercube == false)
            {
                creator.TopMost = true;
                notifyIcon1.ContextMenuStrip = contextMenuStrip1;
            }

            if (Amnesty_Hypercube.Properties.Settings.Default.HypercubeVersion < 15)
            {
                ReadData();

                Amnesty_Hypercube.Properties.Settings.Default.HypercubeVersion = 15;
                Amnesty_Hypercube.Properties.Settings.Default.Save();
            }
        }

        public bool TestWidgetWithCode(string code)
        {
            string trimmedCode = code.Trim();
            string cleanedCode = trimmedCode.Replace("&amp;", "&");

            if (cleanedCode.StartsWith("<") == false || cleanedCode.EndsWith(">") == false)
                return false;

            return VerifyCode(code);
        }

       public bool InstallWidgetWithCode(string code, bool create, bool force)
        {
            bool didCreate = false;

            string trimmedCode = code.Trim();
            string cleanedCode = trimmedCode.Replace("&amp;", "&");

            if (force)
            {
                 if (cleanedCode.StartsWith("<") == false || cleanedCode.EndsWith(">") == false)
                 {
                    System.Media.SystemSounds.Beep.Play();
                    force = false;
                 }
            }

            if (VerifyCode(cleanedCode) || force)
            {
                string identifier = IdentifierFromCode(code);
                if (AddWidget(cleanedCode, null, null, identifier))
                {
                    if (create) {
                        Widget w = null;

                        if (isInHypercube)
                        {
                            w = CreateWidget(cleanedCode, identifier, cubeDomain);
                            w.SetHypercube(true);
                        }
                        else
                            w = CreateWidget(cleanedCode, identifier, "_Desktop");

                        if (w != null)
                        {
                            if (isInGallery && gallery.GetGalleryMode() != Form3.GalleryModes.galleryLibrary)
                            {
                                gallery.SetupGallery(Form3.GalleryModes.galleryProviders);
                                w.SetGallery(true);
                            }

                            w.ResetOptionLevel();

                            didCreate = true;
                        }
                    }
                }
            }

            return didCreate;
        }

        bool AddWidget(string code, string title, Image image, string identifier)
        {
            if (code == null)
                return false;

            string fullIdentifier = identifier;
            if(fullIdentifier == null)
                fullIdentifier = IdentifierFromCode(code);

            DataTable wtable = widgets.Tables["Widgets"];
            if (wtable.Rows.Contains(fullIdentifier))
            {
                DataTable itable = instances.Tables["Widgets"];
                if (itable.Rows.Contains(fullIdentifier))
                {
                    //DataRow row = itable.Rows.Find(fullIdentifier);
                    //Widget w = (Widget)row["Widget"];
                    //w.DoShow();
                }
                else
                {
                    DataRow row = wtable.Rows.Find(fullIdentifier);
                    string rowCode = (string) row["Code"];
                    CreateWidget(rowCode, fullIdentifier, "_Desktop");
                }
                 
                return false;
            }

            string fullTitle = title;
            if (fullTitle == null)
            {
                if (createTitleCustom)
                    fullTitle = createTitle;
                else
                {
                    if (createTitle == null)
                        fullTitle = Amnesty_Hypercube.Properties.Resources.UnknownWidget;
                    else
                        fullTitle = String.Format("{0} {1}", createTitle, Amnesty_Hypercube.Properties.Resources.WidgetTitle);
                }
            }

            Image fullImage = image;
            if (fullImage == null)
            {
                if(createThumbnailCustom) {
                    RequestObjectState os = new RequestObjectState();
                    os.widgetManager = this;

                    HttpWebRequest req = (HttpWebRequest)WebRequest.Create(createThumbnail);
                    req.Timeout = 20000;
                    req.CachePolicy = new System.Net.Cache.HttpRequestCachePolicy(System.Net.Cache.HttpRequestCacheLevel.Default);

                    os.request = req;
                    os.identifier = String.Format("{0}:XML.GGL", fullIdentifier);
                    ThreadPool.QueueUserWorkItem(new WaitCallback(RequestThread), os);
                }
            }

            Object[] obj = new Object[4];
            obj[0] = fullIdentifier;
            obj[1] = code;
            obj[2] = fullTitle;
            obj[3] = fullImage;
            widgets.Tables["Widgets"].Rows.Add(obj);

            AddMenuItem(fullIdentifier, fullTitle, fullImage);
 
            return true;
        }

        void AddMenuItem(string identifier, string title, Image image)
        {
            if (image == null)
                image = Amnesty_Hypercube.Properties.Resources.SmallGear;

            EventHandler menuHandler = new EventHandler(contextMenuStrip1_Select);
            ToolStripMenuItem item = new ToolStripMenuItem(title, image, menuHandler);
            item.Tag = identifier;

            int index = 0;
            IEnumerator enumerator = contextMenuStrip2.Items.GetEnumerator();
            while (enumerator.MoveNext())
            {
                object menu = enumerator.Current;
                if (menu.GetType() == typeof(ToolStripMenuItem))
                {
                    ToolStripMenuItem i = (ToolStripMenuItem)menu;

                    if (String.Compare(title, i.Text) < 0)
                        break;

                    index++;
                }
                else
                    break;
            }

            contextMenuStrip2.Items.Insert(index, item);
        }

        void LoadLibrary()
        {
            UpdateLibrary(true);

            updateTimer.Enabled = true;
            updateTimer.Interval = 1000 * 60 * 60;
            updateTimer.Tick += new EventHandler(updateTimer_Tick);
            updateTimer.Start();
        }

        void UpdateLibrary(bool force)
        {
            if (isInGallery && gallery.GetGalleryMode() == Form3.GalleryModes.galleryProviders)
                return;

            if (isUpdating)
                return;

            bool loadLocal = false;
            bool canConnect = true;

            DateTime now = DateTime.Now;
            if (now.Day == Amnesty_Hypercube.Properties.Settings.Default.LibraryUpdate)
            {
                if (force)
                    loadLocal = true;
                else if(usingDefaultLibrary == false)
                    return;
            }

            isUpdating = true;

            if (System.Net.NetworkInformation.NetworkInterface.GetIsNetworkAvailable() == false)
                canConnect = false;

            RequestObjectState os = new RequestObjectState();
            os.widgetManager = this;

            HttpWebRequest req = (HttpWebRequest)WebRequest.Create("http://www.amnestywidgets.com/hypercube/providers/default.xml");
            req.Timeout = 20000;

            req.CachePolicy = new System.Net.Cache.HttpRequestCachePolicy(System.Net.Cache.HttpRequestCacheLevel.Default);

            if (canConnect && loadLocal == false)
                req.CachePolicy = new System.Net.Cache.HttpRequestCachePolicy(System.Net.Cache.HttpRequestCacheLevel.Revalidate);
            else
            {
                if (canConnect == false)
                    req.CachePolicy = new System.Net.Cache.HttpRequestCachePolicy(System.Net.Cache.HttpRequestCacheLevel.CacheOnly);
                else if (loadLocal)
                    req.CachePolicy = new System.Net.Cache.HttpRequestCachePolicy(System.Net.Cache.HttpRequestCacheLevel.CacheIfAvailable);
             }

            req.UserAgent = "Amnesty Hypercube/0.2a (Windows)";

            if (canConnect && loadLocal == false && updateHash > 0)
            {
                int calculatedHash = updateHash * 1423;
                int verifier = 983 + (calculatedHash % 223);
                calculatedHash += verifier;

                req.UserAgent = String.Format("Amnesty Hypercube/0.2a (Windows; I{0}; C{1})", calculatedHash, verifier);
 
                updateHash = 0;
            }
            
            os.request = req;
            os.identifier = "UPDATE:LIB";
            ThreadPool.QueueUserWorkItem(new WaitCallback(RequestThread), os);
        }

        void BuildDefaultLibrary()
        {
            if (providers == null)
            {
                providers = new Hashtable();
                providers.Add("GoogleGadgets", "Google Gadgets");
                providers.Add("YouTube", "YouTube");
            }

            if (coders == null)
            {
                coders = new Hashtable();
                coders.Add("GoogleGadgets", "gmodules.com");
                coders.Add("YouTube", "youtube.com");
            }

            usingDefaultLibrary = true;
        }

        void ParseLibrary(string xml)
        {
            bool loadLocal = false;
            bool canConnect = true;

            DateTime now = DateTime.Now;
            if (now.Day == Amnesty_Hypercube.Properties.Settings.Default.LibraryUpdate)
                loadLocal = true;

            isUpdating = true;

            if (System.Net.NetworkInformation.NetworkInterface.GetIsNetworkAvailable() == false)
                canConnect = false;

            Hashtable provisionalProviders = new Hashtable();
            Hashtable provisionalCoders = new Hashtable();
            Hashtable provisionalTags = new Hashtable();

            System.Net.Cache.RequestCachePolicy policy = new System.Net.Cache.HttpRequestCachePolicy(System.Net.Cache.HttpRequestCacheLevel.Default);

            if (canConnect && loadLocal == false)
                policy = new System.Net.Cache.HttpRequestCachePolicy(System.Net.Cache.HttpRequestCacheLevel.Revalidate);
            else
            {
                if (canConnect == false)
                    policy = new System.Net.Cache.HttpRequestCachePolicy(System.Net.Cache.HttpRequestCacheLevel.CacheOnly);
                else if (loadLocal)
                    policy = new System.Net.Cache.HttpRequestCachePolicy(System.Net.Cache.HttpRequestCacheLevel.CacheIfAvailable);
            }

            try
            {
                int start = xml.IndexOf("<provider");

                while(start > 0)
                {
                    int end = xml.IndexOf("</provider>", start);
                    if (end <= 0)
                        break;

                    string siteXML = xml.Substring(start, end - start);

                    int ts = siteXML.IndexOf("<title>") + 7;
                    int te = siteXML.IndexOf("</title>");
                    string title = siteXML.Substring(ts, te - ts);

                    int ks = siteXML.IndexOf("<key>") + 5;
                    int ke = siteXML.IndexOf("</key>");
                    string key = siteXML.Substring(ks, ke - ks);

                    int ds = siteXML.IndexOf("<domain>") + 8;
                    int de = siteXML.IndexOf("</domain>");
                    string domain = siteXML.Substring(ds, de - ds);

                    int gs = siteXML.IndexOf("tags=\"") + 6;
                    int ge = siteXML.IndexOf("\">");
                    string tagList = siteXML.Substring(gs, ge - gs);

                    if (siteXML.Contains("featured="))
                        providersFeatured.Add(key);

                    if (siteXML.Contains("hidden="))
                        providersHidden.Add(key);
                    else
                    {
                        String imageKey = String.Format("PROVIDER({0})", key);
                        String sessionKey = String.Format("{0}:IMG", imageKey);

                        if (images.Images.ContainsKey(imageKey) == false /*&& tempImages.ContainsKey(imageKey) == false*/ && imageSessions.Contains(sessionKey) == false)
                        {
                            RequestObjectState os = new RequestObjectState();
                            os.widgetManager = this;
                            os.url = String.Format("http://www.amnestywidgets.com/hypercube/providers/images/{0}.png", key);
                            os.timeout = 20000;
                            os.policy = policy;
                            os.identifier = sessionKey;

                            imageSessions.Add(sessionKey, os);
                        }
                    }

                    if (siteXML.Contains("spoof="))
                        providersSpoofed.Add(key);

                    provisionalProviders.Add(key, title);
                    provisionalCoders.Add(key, domain);
                    provisionalTags.Add(key, tagList);

                    start = xml.IndexOf("<provider", end);
                }
            }

            catch
            {
            }

            if (provisionalProviders.Count > 0)
            {
                providers = provisionalProviders;
 
                Amnesty_Hypercube.Properties.Settings.Default.LibraryUpdate = DateTime.Now.Day;

                if(providersSpoofed.Contains("GoogleGadgets"))
                    Amnesty_Hypercube.Properties.Settings.Default.Syndicate = false;
                else
                    Amnesty_Hypercube.Properties.Settings.Default.Syndicate = true;

                Amnesty_Hypercube.Properties.Settings.Default.Save();

                usingDefaultLibrary = false;
            }

            if (provisionalCoders.Count > 0)
                coders = provisionalCoders;

            if (provisionalTags.Count > 0)
                tags = provisionalTags;

            if (providers == null)
                BuildDefaultLibrary();
        }

        void ParseWidgets(string xml)
        {
            try
            {
                int start = xml.IndexOf("<widget");

                while(true)
                {
                    int end = xml.IndexOf("</widget>", start);

                    string siteXML = xml.Substring(start, end - start);

                    int cs = siteXML.IndexOf("<![CDATA[") + 9;
                    int ce = siteXML.IndexOf("]]>");
                    string code = siteXML.Substring(cs, ce - cs);

                    string trimmedCode = code.Trim();

                    bool create = false;
                    if (siteXML.Contains("create="))
                        create = true;

                    bool exclude = false;
                    if (siteXML.Contains("exclude=\"win\""))
                        exclude = true;

                    if (exclude == false)
                        InstallWidgetWithCode(trimmedCode, create, true);

                    start = xml.IndexOf("<widget", end);
                }
            }

            catch
            {
            }
        }

        void RefreshMenu()
        {
            ToolStripItem x = (ToolStripItem)contextMenuStrip1.Items[0];
            while (x.GetType() == typeof(ToolStripMenuItem))
            {
                contextMenuStrip1.Items.RemoveAt(0);
                x = (ToolStripItem)contextMenuStrip1.Items[0];
            }
       }

        void contextMenuStrip1_Opening(object sender, CancelEventArgs e)
        {
            ToolStripItem x = (ToolStripItem)contextMenuStrip1.Items[0];
            while (x.GetType() == typeof(ToolStripMenuItem))
            {
                contextMenuStrip1.Items.RemoveAt(0);
                x = (ToolStripItem)contextMenuStrip1.Items[0];
            }

            int index = 0;

            IEnumerator enumerator = contextMenuStrip2.Items.GetEnumerator();
            while (enumerator.MoveNext())
            {
               object menu = enumerator.Current;
               if (menu.GetType() == typeof(ToolStripMenuItem))
               {
                   ToolStripMenuItem i = (ToolStripMenuItem)menu;

                   i.Checked = false;
                   i.CheckState = CheckState.Unchecked;

                   string identifier = (string)i.Tag;

                   if(identifier != null && identifier.Length > 0)
                   {
                       DataTable itable = instances.Tables["Widgets"];
                       if (itable.Rows.Contains(identifier))
                       {
                           DataRow row = itable.Rows.Find(identifier);
                           Widget w = (Widget)row["Widget"];
                           if (w.IsReady() == false)
                           {
                               i.Checked = true;
                               i.CheckState = CheckState.Indeterminate;
                           }
                           else if(w.Visible) {
                               i.Checked = true;
                               i.CheckState = CheckState.Checked;
                           }
                       }

                        string path = GetUserDataPath() + "_Desktop.cube\\" + identifier + ".xml";
                        if (File.Exists(path) || desktop.Contains(identifier))
                        {
                            EventHandler menuHandler = new EventHandler(contextMenuStrip1_Select);
                            ToolStripMenuItem item = new ToolStripMenuItem(i.Text, i.Image, menuHandler);
                            item.Tag = identifier;
                            item.Checked = i.Checked;
                            item.CheckState = i.CheckState;
                            contextMenuStrip1.Items.Insert(index++, item);
                        }
                   }
               }
           }
       }

        void contextMenuStrip3_Opening(object sender, CancelEventArgs e)
        {
            closeGalleryToolStripMenuItem.Enabled = isInGallery;
            exitHypercubeToolStripMenuItem.Enabled = isInHypercube;
        }

        void contextMenuStrip1_Select(object sender, EventArgs e)
        {
            ToolStripMenuItem item = (ToolStripMenuItem)sender;
            string identifier = (string)item.Tag;

            if (identifier != null && identifier.Length > 0)
            {
                DataTable itable = instances.Tables["Widgets"];
                if (itable.Rows.Contains(identifier))
                {
                    // on the Mac, we "focus" (force reveal desktop or bring to front) if shift is held down, not 100% sure if
                    // there is an analog here.  We can bring to front if in the standard layer, so maybe that's enough.  But
                    // how do we check for current keys down?

                    DataRow row = itable.Rows.Find(identifier);
                    Widget w = (Widget)row["Widget"];
                    if (w.Visible)
                    {
                        RemoveFromDesktop(identifier);

                        w.DoHide();
                        w.WriteOptions();

                        return;
                    }
                    else
                    {
                        if (w.GetHypercube())
                        {
                            w.SetDomain("_Desktop");
                            w.ReadOptions();

                            w.SetHypercube(false);
                            w.ResetOptionLevel();
                        }
                        else
                            w.ReadOptions();

                        w.DoShow();
                        w.Focus();
                    }

                    AddToDesktop(identifier);
                }
                else
                {
                    DataTable wtable = widgets.Tables["Widgets"];
                    if (wtable.Rows.Contains(identifier))
                    {
                        DataRow row = wtable.Rows.Find(identifier);
                        string rowCode = (string)row["Code"];
                        CreateWidget(rowCode, identifier, "_Desktop");
                    }
                }
            }
        }
       
        public void DoLibraryAction(string identifier)
        {
            if (identifier == null || identifier.Length == 0)
                return;

            DataTable itable = instances.Tables["Widgets"];
            if (itable.Rows.Contains(identifier))
            {
                DataRow row = itable.Rows.Find(identifier);
                Widget w = (Widget)row["Widget"];
                if (w.Visible)
                {
                    if (w.GetGallery())
                    {
                        if (isInHypercube == false)
                            RemoveFromDesktop(identifier);
                        else
                        {
                            w.SetHypercube(false);
                            RemoveFromHypercube(identifier);
                        }

                        w.SetGallery(false);
                        w.ResetOptionLevel();

                        w.DoHide();
                        w.WriteOptions();
                    }
                    else
                    {
                        w.SetGallery(true);
                        w.ResetOptionLevel();
                    }
                }
                else
                {
                    if (isInHypercube == false)
                    {
                        if (w.GetHypercube())
                        {
                            w.SetDomain("_Desktop");
                            w.ReadOptions();

                            w.SetHypercube(false);
                        }
                        else
                            w.ReadOptions();

                        w.SetGallery(true);
                        w.ResetOptionLevel();

                        w.DoShow();

                        AddToDesktop(identifier);
                    }
                    else
                    {
                        w.DoShow();

                        if (w.GetHypercube() == false || cubeDomain.Equals(w.GetDomain()) == false)
                        {
                            w.SetDomain(cubeDomain);
                            w.ReadOptions();

                            w.SetHypercube(true);
                        }
                        else
                            w.ReadOptions();

                        w.SetGallery(true);
                        w.ResetOptionLevel();

                        AddToHypercube(identifier);
                    }
                }
            }
            else
            {
                DataTable wtable = widgets.Tables["Widgets"];
                if (wtable.Rows.Contains(identifier))
                {
                    DataRow row = wtable.Rows.Find(identifier);
                    string rowCode = (string)row["Code"];
                    Widget w = null;

                    if (isInHypercube)
                    {
                        w = CreateWidget(rowCode, identifier, cubeDomain);
                        w.SetHypercube(true);
                    }
                    else
                        w = CreateWidget(rowCode, identifier, "_Desktop");

                    w.SetGallery(true);
                    w.ResetOptionLevel();
                }
            }
        }

        public void DoCubeAction(string identifier)
        {
            if (identifier == null || identifier.Length == 0 || identifier.Equals(cubeDomain))
                return;

            if (Amnesty_Hypercube.Properties.Settings.Default.PrefUISound)
                switchSound.Play();

            WriteDomain(cubeDomain);
            cubeDomain = identifier;
            ReadDomain(cubeDomain);

            string cubeName = cubeDomain;
            if (cubeName.StartsWith("_"))
                cubeName = cubeDomain.Substring(1, cubeDomain.Length - 1);
            label1.Text = Amnesty_Hypercube.Properties.Resources.Hypercube + " > " + cubeName;

            DataTable itable = instances.Tables["Widgets"];

            IEnumerator enumerator = itable.Rows.GetEnumerator();
            while (enumerator.MoveNext())
            {
                DataRow row = (DataRow)enumerator.Current;
                string identifier2 = (string)row["Identifier"];

                if (hypercube.Contains(identifier2) == false)
                {
                    Widget w = (Widget)row["Widget"];
                    w.DoHide();
                }
            }

            IEnumerator enumerator2 = hypercube.GetEnumerator();
            while (enumerator2.MoveNext())
            {
                string identifier3 = (string)enumerator2.Current;
                if (itable.Rows.Contains(identifier3))
                {
                    DataRow row = itable.Rows.Find(identifier3);
                    Widget w = (Widget)row["Widget"];

                    w.SetDomain(cubeDomain);
                    w.ReadOptions();

                    w.SetHypercube(true);
                    w.ResetOptionLevel();
                    w.DoShow();
                }
                else
                {
                    DataTable wtable = widgets.Tables["Widgets"];
                    if (wtable.Rows.Contains(identifier3))
                    {
                        DataRow row = wtable.Rows.Find(identifier3);
                        string rowCode = (string)row["Code"];
                        Widget w = CreateWidget(rowCode, identifier3, cubeDomain);
 
                        w.SetHypercube(true);
                        w.ResetOptionLevel();
                    }
                }
            }
        }

        Widget CreateWidget(string code, string identifier, string domain)
        {
            bool canConnect = true;

            if (System.Net.NetworkInformation.NetworkInterface.GetIsNetworkAvailable() == false)
                canConnect = false;

            if (canConnect)
            {
                if (instances.Tables["Widgets"].Rows.Contains(identifier))
                    return null;

                Widget w = new Widget();
                w.SetWidgetManager(this);

                if (domain.Equals("_Desktop"))
                    AddToDesktop(identifier);
                else
                    AddToHypercube(identifier);

                w.SetIdentifier(identifier);
                w.SetDomain(domain);
                w.ReadOptions();

                w.LoadSnippet(code, Amnesty_Hypercube.Properties.Settings.Default.Syndicate);

                Object[] obj = new Object[2];
                obj[0] = identifier;
                obj[1] = w;
                instances.Tables["Widgets"].Rows.Add(obj);

                return w;
            }

            return null;
        }

        bool VerifyCode(string code)
        {
            if (createTitleCustom)
            {
                createTitle = null;
                createTitleCustom = false;
            }

            if (createThumbnailCustom)
            {
                createThumbnail = null;
                createThumbnailCustom = false;
            }

            if (MatchCode(code, "gmodules.com", "<script ", "Google"))
            {
                string iname = GetAttribute(code, "&title=", "&");
                if (iname != null)
                {
                    string name = iname.Replace("+", " ");
                    createTitle = Uri.UnescapeDataString(name);
                    createTitleCustom = true;
                }

                string thumb = GetAttribute(code, "url=", "&");
                if (thumb != null)
                {
                    createThumbnail = Uri.UnescapeDataString(thumb);
                    createThumbnailCustom = true;
                }

                return true;
            }

            // check for iPhone

            if (coders != null)
            {
                IDictionaryEnumerator enumerator = coders.GetEnumerator();
                while (enumerator.MoveNext())
                {
                    string domain = (string)enumerator.Value;
                    if (code.Contains(domain))
                    {
                        string identifier = (string)enumerator.Key;

                        string title = (string)providers[identifier];
                        createTitle = String.Format("{0} {1}", title, Amnesty_Hypercube.Properties.Resources.WidgetTitle);
                        createTitleCustom = true;
                        return true;
                    }
                }
            }

            return false;
        }

        bool MatchCode(string code, string domain, string prefix, string title)
        {
            if (code.Contains(domain))
            {
                if (prefix == null || code.StartsWith(prefix))
                {
                    createTitle = title;
                    return true;
                }
            }

            return false;
        }

        public int MarkerFromCode(string code)
        {
            int base1 = 0;
            int base2 = 0;
            int base3 = 0;
            int base4 = 0;

            char[] bytes = code.ToCharArray();

            int len = bytes.Length;
            int i = 0;
            while (i < len)
            {
                int h = (int)bytes[i];

                base1 += h;
                i++;

                if (i < len)
                {
                    h = (int)bytes[i];

                    base1 += h;
                    base2 += h;
                    i++;
                }

                if (i < len)
                {
                    h = (int)bytes[i];

                    base1 += h;
                    base3 += h;
                    i++;
                }

                if (i < len)
                {
                    h = (int)bytes[i];

                    base1 += h;
                    base2 += h;
                    i++;
                }

                if (i < len)
                {
                    h = (int)bytes[i];

                    base1 += h;
                    base4 += h;
                    i++;
                }

                if (i < len)
                {
                    h = (int)bytes[i];

                    base1 += h;
                    base2 += h;
                    base3 += h;
                    i++;
                }
            }

            return (base1 + (base2 << 8) + (base3 << 16) + (base4 << 24));
        }

        string DomainFromCode(string code)
        {
            string domain = null;

            int start = code.IndexOf("http://");

            while (start > 0)
            {
                start += 7;

                int end = code.IndexOf(".com", start);
                if (end <= 0)
                    end = code.IndexOf(".net", start);
                if (end <= 0)
                    end = code.IndexOf(".org", start);

                if (end <= 0)
                {
                    int slashEnd = code.IndexOf("/", start);
                    int ampEnd = code.IndexOf("&", start);
                    int equalEnd = code.IndexOf("=", start);
                    int closeEnd = code.IndexOf(">", start);
                    int dquoEnd = code.IndexOf("\"", start);
                    int squoEnd = code.IndexOf("'", start);

                    int min = slashEnd;
                    if (min > 0)
                    {
                        if (ampEnd > 0 && ampEnd < min)
                            min = ampEnd;
                        if (equalEnd > 0 && equalEnd < min)
                            min = equalEnd;
                        if (closeEnd > 0 && closeEnd < min)
                            min = closeEnd;
                        if (dquoEnd > 0 && dquoEnd < min)
                            min = dquoEnd;
                        if (squoEnd > 0 && squoEnd < min)
                            min = squoEnd;

                        end = min;
                    }
                }
                else
                    end += 4;

                if (end > 0)
                {
                    string extracted = code.Substring(start, end - start);

                    bool ignore1 = extracted.Contains("macromedia.com");
                    bool ignore2 = extracted.Contains("adobe.com");
                    bool ignore3 = extracted.Contains("gmodules.com");

                    if (ignore1 == false && ignore2 == false && ignore3 == false)
                    {
                        if (domain == null || (domain.StartsWith("www.") == false && extracted.StartsWith("www.") == true))
                            domain = extracted;
                    }
                }
                else
                    end = start;
 
                start = code.IndexOf("http://", end);
            }

            return domain;
        }

        string IdentifierFromCode(string code)
        {
	        int marker = MarkerFromCode(code);
            string domain = DomainFromCode(code);

            int hash = code.GetHashCode();

            string v0 = String.Format("{0,8:X}", marker);
            string v1 = String.Format("{0,8:X}", hash);

            string s0 = String.Format("{0}{1}", v0, v1);
            string s1 = s0.Substring(0, 4);
            string s2 = s0.Substring(4, 4);
            string s3 = s0.Substring(8, 4);
            string s4 = s0.Substring(12, 4);
            string sN = String.Format("{0}-{1}-{2}-{3}", s1, s2, s3, s4);

            string serial = sN.Replace(" ", "0");

	        if (domain == null)
                return String.Format("localhost-{0}", serial);

            return String.Format("{0}-{1}", domain, serial);
        }

        private string GetReverseAttribute(string s, string pre, string post)
        {
            int start = s.IndexOf(pre);
            if (start > 0)
            {
                int end = s.LastIndexOf(post, start);

                if (end > 0)
                {
                    end++;
                    return s.Substring(end, start - end);
                }
            }

            return null;
        }

        private string GetAttribute(string s, string pre, string post)
        {
            int start = s.IndexOf(pre);
            if (start > 0)
            {
                start += pre.Length;
                int end = s.IndexOf(post, start);

                if (end > 0 && end > start)
                    return s.Substring(start, end - start);
            }

            return null;
        }
        
        void notifyIcon1_MouseClick(object sender, MouseEventArgs e)
        {
             //if (e.Button == MouseButtons.Left) // todo: this needs to display the menu in the same location as right click
             //   contextMenuStrip1.Show(mouse, ToolStripDropDownDirection.AboveLeft);

            if (e.Button == MouseButtons.Left)
            {
            }
        }

        void notifyIcon1_MouseDoubleClick(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
            }
       }

        //void global_MouseActivity(object sender, MouseEventArgs e)
        //{
         //   mouse = e.Location;
        //}

        private void exitAmnestyHypercubeToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (isInGallery)
                gallery.CloseGallery();

            if (isInHypercube)
                CloseCube();

            Close();
        }

        private void enterHypercubeToolStripMenuItem_Click(object sender, EventArgs e)
        {
            OpenCube();
        }

        private void createWidgetToolStripMenuItem_Click(object sender, EventArgs e)
        {
            creator.Show();
        }
        private void getMoreWidgetsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            OpenGallery(Form3.GalleryModes.galleryProviders);
        }

        private void addWidgetToDesktopToolStripMenuItem_Click(object sender, EventArgs e)
        {
            OpenGallery(Form3.GalleryModes.galleryLibrary);
        }

        private void button_Click(object sender, EventArgs e)
        {
            if (Amnesty_Hypercube.Properties.Settings.Default.PrefUISound)
                clickSound.Play();
            
            if (sender.Equals(button1))
                CloseCube();
            else if (sender.Equals(button2))
            {
                OpenGallery(Form3.GalleryModes.galleryHelp);
            }
            else if (sender.Equals(button3))
            {
                OpenGallery(Form3.GalleryModes.galleryProviders);
            }
            else if (sender.Equals(button4))
            {
                OpenGallery(Form3.GalleryModes.galleryCubes);
            }
            else if (sender.Equals(button5))
            {
                OpenGallery(Form3.GalleryModes.galleryLibrary);
            }
        }

        private void checkForUpdatesToolStripMenuItem_Click(object sender, EventArgs e)
        {
        }

        private void mesaDynamicsOnlineToolStripMenuItem_Click(object sender, EventArgs e)
        {
        }

        private void contactCustomerSupportToolStripMenuItem_Click(object sender, EventArgs e)
        {
        }

        private void openInfoCenterToolStripMenuItem_Click(object sender, EventArgs e)
        {
            OpenGallery(Form3.GalleryModes.galleryHelp);
        }

        private void hideWidgetsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            WriteDomain("_Desktop");

            DataTable itable = instances.Tables["Widgets"];

            IEnumerator enumerator = itable.Rows.GetEnumerator();
            while (enumerator.MoveNext())
            {
                DataRow row = (DataRow)enumerator.Current;
                string identifier = (string)row["Identifier"];
                
                if (desktop.Contains(identifier))
                {
                    RemoveFromDesktop(identifier);

                    Widget w = (Widget)row["Widget"];
                    w.DoHide();
                }
            }
        }

        private void showWidgetsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DataTable wtable = widgets.Tables["Widgets"];

            IEnumerator enumerator = wtable.Rows.GetEnumerator();
            while (enumerator.MoveNext())
            {
                DataRow row = (DataRow)enumerator.Current;
                string identifier = (string)row["Identifier"];

                string path = GetUserDataPath() + "_Desktop.cube\\" + identifier + ".xml";
                if (File.Exists(path))
                {
                    DataTable itable = instances.Tables["Widgets"];
                    if (itable.Rows.Contains(identifier))
                    {
                        DataRow irow = itable.Rows.Find(identifier);
                        Widget w = (Widget)irow["Widget"];
                        w.DoShow();

                        AddToDesktop(identifier);
                    }
                    else
                    {
                        string rowCode = (string)row["Code"];
                        CreateWidget(rowCode, identifier, "_Desktop");
                    }
                }
            }
        }

        delegate void HandleRequestCallback(RequestObjectState os);
        
        public void TSHandleRequest(RequestObjectState os)
        {
            if (this.InvokeRequired)
            {
                HandleRequestCallback d = new HandleRequestCallback(TSHandleRequest);
                this.Invoke(d, new object[] { os });
            }
            else
                this.HandleRequest(os);
        }

        void HandleRequest(RequestObjectState os)
        {
            if (os.identifier.EndsWith(":LIB"))
            {
                if (os.outputString != null)
                {
                    ParseLibrary(os.outputString);

                    if (os.identifier.StartsWith("GALLERY:") || (isInGallery && gallery.GetGalleryMode() == Form3.GalleryModes.galleryProviders))
                    {
                        gallery.SetupGallery(Form3.GalleryModes.galleryProviders);
                    }
                }

                isUpdating = false;
            }
            else if (os.identifier.EndsWith(":XML.GGL"))
            {
                if (os.outputString != null)
                {
                    string identifier = os.identifier.Substring(0, os.identifier.Length - 8);
                    string extracted = GetAttribute(os.outputString, "thumbnail=\"", "\"");

                    if (extracted == null)
                        extracted = GetAttribute(os.outputString, "screenshot=\"", "\"");

                    if (extracted != null)
                    {
                        if (extracted.StartsWith("http://") == false)
                            extracted = "http://www.google.com" + extracted;

                        RequestObjectState os2 = new RequestObjectState();
                        os2.widgetManager = this;
                        HttpWebRequest req = (HttpWebRequest)WebRequest.Create(extracted);
                        req.Timeout = 20000;

                        req.CachePolicy = new System.Net.Cache.HttpRequestCachePolicy(System.Net.Cache.HttpRequestCacheLevel.Default);

                        os2.request = req;
                        os2.identifier = String.Format("{0}:IMG.WGT", identifier);
                        ThreadPool.QueueUserWorkItem(new WaitCallback(RequestThread), os2);
                    }
                }
            }
            else if (os.identifier.EndsWith(":IMG.WGT"))
            {
                if (os.outputImage != null)
                {
                    string identifier = os.identifier.Substring(0, os.identifier.Length - 8);
                    SetInfoForWidget(identifier, "Image", os.outputImage);
                }
            }
            else if (os.identifier.EndsWith(":IMG"))
            {
                if (os.outputImage != null)
                {
                    os.outputImage = flipper.FlipImage(os.outputImage);
 
                    string key = os.identifier.Substring(0, os.identifier.Length - 4);

                    //if (os.widgetManager.isInGallery && os.widgetManager.gallery.GetGalleryMode() == Form3.GalleryModes.galleryProviders)
                     //   os.widgetManager.tempImages.Add(key, os.outputImage);
                    //else
                    
                    os.widgetManager.images.Images.Add(key, os.outputImage);
                 }

                imageSessionCount--;
            }
            else if (os.identifier.EndsWith(":WGT"))
            {
                if (os.outputString != null)
                {
                    ParseWidgets(os.outputString);
                }
            }
        }

        static void RequestThread(Object stateInfo)
        {
            RequestObjectState os = (RequestObjectState)stateInfo;
            HttpWebRequest req = os.request;

            if (os.identifier.EndsWith(":IMG") || os.identifier.EndsWith(":IMG.WGT"))
            {
                try
                {
                    HttpWebResponse res = (HttpWebResponse)req.GetResponse();
 
                    os.outputImage = Image.FromStream(res.GetResponseStream());
 
                    res.Close();
                }

                catch
                {
                    os.outputImage = null;
                }
            }
            else {
                try
                {
                    HttpWebResponse res = (HttpWebResponse)req.GetResponse();
                    StreamReader stream = new StreamReader(res.GetResponseStream(), Encoding.UTF8);

                    os.outputString = stream.ReadToEnd();

                    res.Close();
                    stream.Close();
                }

                catch
                {
                    os.outputString = null;
                }
            }

            os.widgetManager.TSHandleRequest(os);
        }

        private void welcomeMessageToolStripMenuItem_Click(object sender, EventArgs e)
        {
            OpenGallery(Form3.GalleryModes.galleryWelcome);
        }

        private void exitAmnestyHypercubeToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            if (isInGallery)
                gallery.CloseGallery();

            if (isInHypercube)
                CloseCube();

            Close();
        }

        private void exitHypercubeToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (isInHypercube)
                CloseCube();
        }

        private void closeGalleryToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (isInGallery)
                gallery.CloseGallery();
        }

        private void aboutAmnestyHypercubeToolStripMenuItem_Click(object sender, EventArgs e)
        {
            splash.Show();
        }

        private void notifyIcon1_MouseDoubleClick_1(object sender, MouseEventArgs e)
        {

        }

        private void toolStripMenuItem3_Click(object sender, EventArgs e)
        {

        }

        private void getThePublicBetaToolStripMenuItem_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Process p = new System.Diagnostics.Process();
            p.StartInfo.Verb = "open";
            p.StartInfo.FileName = "http://www.amnestyhypercube.com";
            p.Start();
 
        }

        private void toolStripMenuItem8_Click(object sender, EventArgs e)
        {
            OpenGallery(Form3.GalleryModes.galleryProviders);

        }
    }

    public class Flipper : Object
    {    
        public Image FlipImage(Image i)
        {
            int w = i.Width;
            int h = i.Height;
            if (w > 64 || h > 64)
            {
                w = 64;
                h = 64;

                if (i.Width > i.Height)
                    h = (64 * i.Height) / i.Width;
                 else if (i.Height > i.Width)
                    w = (64 * i.Width) / i.Height;
            }

            Bitmap b = new Bitmap(64, 64, PixelFormat.Format32bppArgb);
            using (Graphics g = Graphics.FromImage(b))
            {
                Rectangle dr = new Rectangle((64 - w) / 2, 64 - h, w, h);
                Rectangle sr = new Rectangle(0, 0, i.Width, i.Height);
                g.DrawImage(i, dr, sr, GraphicsUnit.Pixel);
             }
            
            ACControls.ImageFlip flip = new ACControls.ImageFlip();
            flip.Divider = 2;
            flip.Image = (Image)b;

            Image i2 = flip.FlippedImage;

            Bitmap b2 = new Bitmap(96, 96, PixelFormat.Format32bppArgb);
            using (Graphics g = Graphics.FromImage(b2))
            {
               g.DrawImageUnscaled(i2, 16, 0);
            }

            return (Image)b2;
        }
    }

    public class RequestObjectState : Object
    {
        public Form1 widgetManager = null;

        public string url = null;
        public int timeout;
        public System.Net.Cache.RequestCachePolicy policy = null;
        public HttpWebRequest request = null;

        public string identifier = null;

        public string outputString = null;
        public Image outputImage = null;
    }
}