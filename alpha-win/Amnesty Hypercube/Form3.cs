using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Imaging;
using System.Text;
using System.Windows.Forms;
using System.Media;
using System.Runtime.InteropServices;
using System.IO;

using Org.Vesic.WinForms;

namespace Amnesty_Hypercube
{
    public partial class Form3 : Form
    {
        Form1 widgetManager;
        FormState formState = new FormState();
        ArrayList blotters = new ArrayList();

        SoundPlayer playSound = new SoundPlayer(Amnesty_Hypercube.Properties.Resources.Welcome);
        SoundPlayer enterSound = new SoundPlayer(Amnesty_Hypercube.Properties.Resources.Enter);
        SoundPlayer clickSound = new SoundPlayer(Amnesty_Hypercube.Properties.Resources.Click);

        String home = null;

        public enum GalleryModes : int
        {
            galleryLibrary = 10,
            galleryCubes = 20,
            galleryProviders = 30,
            galleryBrowser = 40,
            galleryHelp = 50,
            galleryWelcome = 60
        };

        public enum ProviderPresets : int
        {
            presetAll = 1000,
            presetLibraries = 1001,
            presetGames = 1002,
            presetVideo = 1003,
            presetPhotos = 1004,
            presetMusic = 1005,
            presetOther = 1006
        };

        [Flags]
        internal enum WindowStyles : int
        {
            ExToolWindow = 0x00000080,
            ExAppWindow = 0x00040000
        };

        GalleryModes galleryMode;
        ProviderPresets providerPreset = ProviderPresets.presetAll;
        Button presetButton;

        delegate void SetImageCallback(string key, Image image); 

        bool isInGallery = false;

        /*
        internal struct Margins
        {
            public int Left, Right, Top, Bottom;
        }

        [DllImport("dwmapi.dll")]
        static extern void DwmIsCompositionEnabled(ref bool pfEnabled);
        [DllImport("dwmapi.dll")]
        static extern void DwmExtendFrameIntoClientArea(System.IntPtr hWnd, ref Margins pMargins);
        */

        public Form3()
        {
            InitializeComponent();

            playSound.Load();
            enterSound.Load();
            clickSound.Load();

            SetupButton(
                button1,
                Amnesty_Hypercube.Properties.Resources.Close,
                Amnesty_Hypercube.Properties.Resources.CloseDown,
                Amnesty_Hypercube.Properties.Resources.CloseOver);

            SetupButton(
                button2,
                Amnesty_Hypercube.Properties.Resources.Down,
                Amnesty_Hypercube.Properties.Resources.DownDown,
                Amnesty_Hypercube.Properties.Resources.DownOver);

            SetupButton(
                button3,
                Amnesty_Hypercube.Properties.Resources.Up,
                Amnesty_Hypercube.Properties.Resources.UpDown,
                Amnesty_Hypercube.Properties.Resources.UpOver);

            SetupButton(
                button4,
                Amnesty_Hypercube.Properties.Resources.PreAll,
                Amnesty_Hypercube.Properties.Resources.PreAllDown,
                Amnesty_Hypercube.Properties.Resources.PreAllOver);

            presetButton = button4;
            button4.Tag = "<disabled>";
            button4.ImageIndex = 1;

            SetupButton(
                button5,
                Amnesty_Hypercube.Properties.Resources.PreDirectory,
                Amnesty_Hypercube.Properties.Resources.PreDirectoryDown,
                Amnesty_Hypercube.Properties.Resources.PreDirectoryOver);

            SetupButton(
                button6,
                Amnesty_Hypercube.Properties.Resources.PreGames,
                Amnesty_Hypercube.Properties.Resources.PreGamesDown,
                Amnesty_Hypercube.Properties.Resources.PreGamesOver);

            SetupButton(
                button7,
                Amnesty_Hypercube.Properties.Resources.PreVideo,
                Amnesty_Hypercube.Properties.Resources.PreVideoDown,
                Amnesty_Hypercube.Properties.Resources.PreVideoOver);

            SetupButton(
                button8,
                Amnesty_Hypercube.Properties.Resources.PrePhotos,
                Amnesty_Hypercube.Properties.Resources.PrePhotosDown,
                Amnesty_Hypercube.Properties.Resources.PrePhotosOver);

            SetupButton(
                button9,
                Amnesty_Hypercube.Properties.Resources.PreMusic,
                Amnesty_Hypercube.Properties.Resources.PreMusicDown,
                Amnesty_Hypercube.Properties.Resources.PreMusicOver);

            SetupButton(
                button10,
                Amnesty_Hypercube.Properties.Resources.PreOther,
                Amnesty_Hypercube.Properties.Resources.PreOtherDown,
                Amnesty_Hypercube.Properties.Resources.PreOtherOver);

            SetupButton(
                button11,
                Amnesty_Hypercube.Properties.Resources.Providers,
                Amnesty_Hypercube.Properties.Resources.ProvidersDown,
                Amnesty_Hypercube.Properties.Resources.ProvidersOver);

            SetupButton(
                button12,
                Amnesty_Hypercube.Properties.Resources.Back,
                Amnesty_Hypercube.Properties.Resources.BackDown,
                Amnesty_Hypercube.Properties.Resources.BackOver);

            SetupButton(
                button13,
                Amnesty_Hypercube.Properties.Resources.Forward,
                Amnesty_Hypercube.Properties.Resources.ForwardDown,
                Amnesty_Hypercube.Properties.Resources.ForwardOver);

            button11.Bounds = button4.Bounds;
            button12.Bounds = button5.Bounds;
            button13.Bounds = button6.Bounds;

            extendedWebBrowser1.StartNewWindow += new EventHandler<ExtendedWebBrowser2.BrowserExtendedNavigatingEventArgs>(extendedWebBrowser1_StartNewWindow);

            listView1.SelectedIndexChanged += new EventHandler(listView1_SelectedIndexChanged);

            this.TransparencyKey = Color.FromArgb(254, 255, 254);
            this.BackColor = Color.FromArgb(254, 255, 254);

            Rectangle screen = Screen.PrimaryScreen.Bounds;
            screen.Y = screen.Height;
            this.Bounds = screen;

            Rectangle frame = screen;
            frame.Inflate(-100, -100);

            if (screen.Width > screen.Height)
                frame.Width = (screen.Width + screen.Height) / 2;
            else if (screen.Height > screen.Height)
                frame.Height = (screen.Width + screen.Height) / 2;

            if (frame.Width < 832)
                frame.Width = 832;

            Rectangle newFrame = panel1.Bounds;
            newFrame.Inflate(frame.Width - newFrame.Width, frame.Height - newFrame.Height);
            panel1.Bounds = newFrame;

            foreach (Screen s in Screen.AllScreens)
            {
                Form5 blotter = new Form5();
                blotter.Bounds = s.Bounds;
                blotter.Opacity = .40;
                blotter.BackColor = Color.Black;

                blotters.Add(blotter);

                if (s.Equals(Screen.PrimaryScreen))
                    this.Owner = blotter;
            }

            this.DoubleBuffered = true;
            this.Show();

            //InitializeGlass();
        }

        void extendedWebBrowser1_StartNewWindow(object sender, ExtendedWebBrowser2.BrowserExtendedNavigatingEventArgs e)
        {
            if (galleryMode == GalleryModes.galleryHelp)
            {
                if (isInGallery)
                    CloseGallery();

                if (widgetManager.isInHypercube)
                    widgetManager.CloseCube();

                System.Diagnostics.Process p = new System.Diagnostics.Process();
                p.StartInfo.Verb = "open";
                p.StartInfo.FileName = e.Url.ToString();
                p.Start();
            }

            e.Cancel = true;
        }

        public void SetWidgetManager(Form1 set)
        {
            widgetManager = set;

            listView1.LargeImageList = widgetManager.images;
        }

        public void SetHome(string set)
        {
            home = set;
        }

        public void SetGalleryTitle(string set)
        {
            label1.Text = set;
        }

        public GalleryModes GetGalleryMode()
        {
            return galleryMode;
        }

        public void OpenGallery(GalleryModes mode)
        {
            if (isInGallery)
                return;

            isInGallery = true;

            SetupGallery(mode);

            foreach (Form5 f in blotters)
            {
                f.DoShow();
            }

            Rectangle screen = Screen.PrimaryScreen.Bounds;
            if (this.Bounds.Y != screen.Y)
                this.Bounds = screen;
            else
            {
                this.Show();
            }
            formState.MaximizeTop(this);

            //this.Show();
            //formState.MaximizeTop(this);
        }

        public void SetupGallery(GalleryModes mode)
        {
            button2.Hide();
            button3.Hide();
            button4.Hide();
            button5.Hide();
            button6.Hide();
            button7.Hide();
            button8.Hide();
            button9.Hide();
            button10.Hide();
            button11.Hide();
            button12.Hide();
            button13.Hide();

            extendedWebBrowser1.Hide();
            extendedWebBrowser1.DocumentText = "";

            listView1.Hide();
            
            galleryMode = mode;

            switch (mode)
            {
                case GalleryModes.galleryLibrary:
                    SetGalleryTitle(Amnesty_Hypercube.Properties.Resources.WidgetGallery);

                    SetupGalleryLibrary();
                    break;

                case GalleryModes.galleryCubes:
                    SetGalleryTitle(Amnesty_Hypercube.Properties.Resources.CubeGallery);

                    SetupGalleryCubes();
                    break;

                case GalleryModes.galleryProviders:
                    button4.Show();
                    button5.Show();
                    button6.Show();
                    button7.Show();
                    button8.Show();
                    button9.Show();
                    button10.Show();

                    SetupGalleryProviders();
                    break;

                case GalleryModes.galleryBrowser:
                    button11.Show();
                    button12.Show();
                    button13.Show();

                    if (home != null)
                        extendedWebBrowser1.Navigate(home);
                    extendedWebBrowser1.Show();
                    extendedWebBrowser1.Focus();

                    break;

                case GalleryModes.galleryHelp:
                    SetGalleryTitle(Amnesty_Hypercube.Properties.Resources.InfoCenter);

                    extendedWebBrowser1.Navigate("http://www.amnestywidgets.com/hypercube/wininfo/home.html");
                    extendedWebBrowser1.Show();
                    extendedWebBrowser1.Focus();
                    break;

                case GalleryModes.galleryWelcome:
                    SetGalleryTitle(Amnesty_Hypercube.Properties.Resources.WelcomeTitle);

                    extendedWebBrowser1.Navigate("http://www.amnestywidgets.com/hypercube/wininfo/welcome.html");
                    extendedWebBrowser1.Show();
                    extendedWebBrowser1.Focus();

                    if (Amnesty_Hypercube.Properties.Settings.Default.PrefUISound)
                        playSound.Play();
                    break;
            }

            this.Refresh();
        }

        void SetupGalleryLibrary()
        {
            listView1.Items.Clear();

            DataTable wtable = widgetManager.widgets.Tables["Widgets"];

            IEnumerator enumerator = wtable.Rows.GetEnumerator();
            while (enumerator.MoveNext())
            {
                DataRow row = (DataRow)enumerator.Current;
                string identifier = (string)row["Identifier"];
                string title = (string)row["Title"];

                int imageIndex = widgetManager.images.Images.IndexOfKey("DEFAULT(LargeGear)");

                String imageKey = String.Format("WIDGET({0})", identifier);
                if (listView1.LargeImageList.Images.ContainsKey(imageKey))
                    imageIndex = listView1.LargeImageList.Images.IndexOfKey(imageKey);
                else
                {
                    object imageObject = widgetManager.GetInfoForWidget(identifier, "Image");
                    if (imageObject != null)
                    {
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

                        if (image != null)
                        {
                            image = widgetManager.flipper.FlipImage(image);

                            SetImage(imageKey, image);

                            if (listView1.LargeImageList.Images.ContainsKey(imageKey))
                                imageIndex = listView1.LargeImageList.Images.IndexOfKey(imageKey);
                        }
                    }
                }

                listView1.Items.Add(identifier, title, imageIndex);
            }

            listView1.Show();
            listView1.Focus();
        }

        void SetupGalleryCubes()
        {
            listView1.Items.Clear();

            string path = widgetManager.GetUserDataPath();
            string[] dirs = System.IO.Directory.GetDirectories(path);
            foreach (string dir in dirs)
            {
                if (dir.EndsWith(".cube") && dir.EndsWith("\\_Desktop.cube") == false)
                {
                    int index = dir.LastIndexOf("\\") + 1;
                    string key = dir.Substring(index, dir.Length - (index + 5));
                    string title = null;
                    if (key.StartsWith("_"))
                        title = key.Substring(1);
                    else
                        title = key;

                    if(key.StartsWith("_Cube")) {
                        string suffix = key.Substring(5);
                        title = String.Format("{0} {1}", Amnesty_Hypercube.Properties.Resources.CubeTitle, suffix);
                    }

                    int imageIndex = listView1.LargeImageList.Images.IndexOfKey("DEFAULT(LargeCube)");
                    listView1.Items.Add(key, title, imageIndex);
                }
            }
          

            listView1.Show();
            listView1.Focus();
        }

        ArrayList FilteredProviders()
        {
            ArrayList filtered = new ArrayList(widgetManager.providers.Count);
 
            IDictionaryEnumerator enumerator = widgetManager.providers.GetEnumerator();
            while (enumerator.MoveNext())
            {
                string identifier = (string)enumerator.Key;

                bool add = true;

                if (widgetManager.providersHidden.Contains(identifier))
                    add = false;

                if (providerPreset != ProviderPresets.presetAll && widgetManager.tags != null)
                {
                    string tags = (string)widgetManager.tags[identifier];

                    switch (providerPreset)
                    {
                        case ProviderPresets.presetLibraries:
                            if (tags.Contains("library") == false)
                                add = false;
                            break;

                        case ProviderPresets.presetGames:
                            if (tags.Contains("games") == false)
                                add = false;
                            break;

                        case ProviderPresets.presetVideo:
                            if (tags.Contains("video") == false)
                                add = false;
                            break;

                        case ProviderPresets.presetPhotos:
                            if (tags.Contains("photos") == false)
                                add = false;
                            break;

                        case ProviderPresets.presetMusic:
                            if (tags.Contains("music") == false)
                                add = false;
                            break;

                        case ProviderPresets.presetOther:
                            if (tags.Contains("custom") == false)
                                add = false;
                            break;
                    }
                }

                if(add)
                    filtered.Add(identifier);
            }

            return filtered;
        }

        void SetupGalleryProviders()
        {
            listView1.Items.Clear();

            int featuredCount = 0;
            int ix = -1;

            ArrayList filtered = FilteredProviders();
            foreach (string identifier in filtered)
            {
                string title = " " + (string) widgetManager.providers[identifier];
                
                if(widgetManager.providersFeatured.Contains(identifier))
                {
                    int imageIndex = listView1.LargeImageList.Images.IndexOfKey("DEFAULT(LargeWorld)");

                    String imageKey = String.Format("PROVIDER({0})", identifier);
                    if (listView1.LargeImageList.Images.ContainsKey(imageKey))
                        imageIndex = listView1.LargeImageList.Images.IndexOfKey(imageKey);

                    listView1.Items.Add(identifier, title, imageIndex);
                    featuredCount++;
                }
            }

            foreach (string identifier in filtered)
            {
                string title = (string) widgetManager.providers[identifier];
                
                if(widgetManager.providersFeatured.Contains(identifier) == false) {
                    int imageIndex = listView1.LargeImageList.Images.IndexOfKey("DEFAULT(LargeWorld)");

                    String imageKey = String.Format("PROVIDER({0})", identifier);
                    if (listView1.LargeImageList.Images.ContainsKey(imageKey))
                        imageIndex = listView1.LargeImageList.Images.IndexOfKey(imageKey);

                    ListViewItem i = listView1.Items.Add(identifier, title, imageIndex);
                    if(ix == -1)
                        ix = i.Position.X - listView1.TileSize.Width;
                }
            }

            if (featuredCount > 0)
            {
                int imageIndex = listView1.LargeImageList.Images.IndexOfKey("DEFAULT(Blank)");

                int area = (listView1.Bounds.Width - 20) - ix;
                int mod = area % listView1.TileSize.Width;
                area -= mod;

                int padding = area / listView1.TileSize.Width;
                while (padding > 0)
                {
                    ListViewItem j = listView1.Items.Add("<ignore>", " zzz", imageIndex);
                    j.ForeColor = panel1.BackColor;
                    padding--;
                }
            }

            string presetTitle = Amnesty_Hypercube.Properties.Resources.TipPresetAll;

            switch (providerPreset)
            {
                case ProviderPresets.presetLibraries:
                    presetTitle = Amnesty_Hypercube.Properties.Resources.TipPresetLibraries;
                    break;

                case ProviderPresets.presetGames:
                    presetTitle = Amnesty_Hypercube.Properties.Resources.TipPresetGames;
                    break;

                case ProviderPresets.presetVideo:
                    presetTitle = Amnesty_Hypercube.Properties.Resources.TipPresetVideo;
                    break;

                case ProviderPresets.presetPhotos:
                    presetTitle = Amnesty_Hypercube.Properties.Resources.TipPresetPhotos;
                    break;

                case ProviderPresets.presetMusic:
                    presetTitle = Amnesty_Hypercube.Properties.Resources.TipPresetMusic;
                    break;

                case ProviderPresets.presetOther:
                    presetTitle = Amnesty_Hypercube.Properties.Resources.TipPresetOther;
                    break;
            }

            String galleryTitle = String.Format("{0} > {1}", Amnesty_Hypercube.Properties.Resources.ProviderGallery, presetTitle);
            SetGalleryTitle(galleryTitle);

            listView1.Show();
            listView1.Focus();
        }

        void GalleryLibraryAction(String key)
        {
            widgetManager.DoLibraryAction(key);
        }

        void GalleryCubeAction(String key)
        {
            widgetManager.DoCubeAction(key);
        }

        void GalleryProviderAction(String key, String title)
        {
            home = String.Format("http://www.amnestywidgets.com/hypercube/providers/pages/{0}.html", key);

            bool spoofFlag = false;
            if (widgetManager.providersSpoofed.Contains(key))
                spoofFlag = true;

            label1.Text = String.Format("{0} > {1}", Amnesty_Hypercube.Properties.Resources.ProviderGallery, title);

            SetupGallery(GalleryModes.galleryBrowser);
        }

        public void CloseGallery()
        {
            if (isInGallery == false)
                return;

            isInGallery = false;

            if(galleryMode == GalleryModes.galleryBrowser)
                extendedWebBrowser1.DocumentText = "";

            DataTable itable = widgetManager.instances.Tables["Widgets"];

            IEnumerator enumerator = itable.Rows.GetEnumerator();
            while (enumerator.MoveNext())
            {
                DataRow row = (DataRow)enumerator.Current;
                Widget w = (Widget)row["Widget"];
                w.SetGallery(false);
                w.ResetOptionLevel();
            }

            formState.Restore(this);
            this.Hide();

            foreach (Form5 f in blotters)
            {
                f.DoHide();
            }

            widgetManager.CloseGallery();
        }

        public void SetImage(string key, Image image)
        {
            if (listView1.InvokeRequired)
            {
                SetImageCallback d = new SetImageCallback(SetImage);
                this.Invoke(d, new object[] { key, image });
             }
            else
                widgetManager.images.Images.Add(key, image);
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

            button.Tag = null;
      }

        void button_MouseEnter(object sender, EventArgs e)
        {
            Button b = (Button)sender;
            if (b.Tag != null)
                return;

            if (Amnesty_Hypercube.Properties.Settings.Default.PrefUISound)
                enterSound.Play();

            b.ImageIndex = 2;
        }

        void button_MouseLeave(object sender, EventArgs e)
        {
            Button b = (Button)sender;
            if (b.Tag != null)
                return;
 
            b.ImageIndex = 0;
        }

        void button_MouseDown(object sender, MouseEventArgs e)
        {
            Button b = (Button)sender;
            if (b.Tag != null)
                return;

            b.ImageIndex = 1;
        }

        void button_MouseUp(object sender, MouseEventArgs e)
        {
            Button b = (Button)sender;
            if (b.Tag != null)
                return;

            b.ImageIndex = 0;
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

        void listView1_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (listView1.SelectedItems.Count > 0 && listView1.Visible)
            {
                String key = (String)listView1.SelectedItems[0].Name;

                String title = (String)listView1.SelectedItems[0].Text;
                listView1.SelectedItems.Clear();

                if (key.Equals("<ignore>"))
                    return;

                if (Amnesty_Hypercube.Properties.Settings.Default.PrefUISound)
                    clickSound.Play();
                
                switch (galleryMode)
                {
                    case GalleryModes.galleryLibrary:
                        GalleryLibraryAction(key);
                        break;

                    case GalleryModes.galleryCubes:
                        GalleryCubeAction(key);
                        break;

                    case GalleryModes.galleryProviders:
                        GalleryProviderAction(key, title);
                        break;
                }
            }
        }

        private void button_Click(object sender, EventArgs e)
        {
            Button b = (Button)sender;
            if (b.Tag != null)
                return;

            if (Amnesty_Hypercube.Properties.Settings.Default.PrefUISound)
                clickSound.Play();
            
            bool updateGallery = false;

            if (sender.Equals(button1))
                CloseGallery();

            else if (sender.Equals(button4))
            {
                providerPreset = ProviderPresets.presetAll;
                updateGallery = true;
            }
            else if (sender.Equals(button5))
            {
                providerPreset = ProviderPresets.presetLibraries;
                updateGallery = true;
            }
            else if (sender.Equals(button6))
            {
                providerPreset = ProviderPresets.presetGames;
                updateGallery = true;
            }
            else if (sender.Equals(button7))
            {
                providerPreset = ProviderPresets.presetVideo;
                updateGallery = true;
            }
            else if (sender.Equals(button8))
            {
                providerPreset = ProviderPresets.presetPhotos;
                updateGallery = true;
            }
            else if (sender.Equals(button9))
            {
                providerPreset = ProviderPresets.presetMusic;
                updateGallery = true;
            }
            else if (sender.Equals(button10))
            {
                providerPreset = ProviderPresets.presetOther;
                updateGallery = true;
            }
 
            else if (sender.Equals(button11))
                SetupGallery(GalleryModes.galleryProviders);
            else if (sender.Equals(button12))
                extendedWebBrowser1.GoBack();
            else if (sender.Equals(button13))
                extendedWebBrowser1.GoForward();

            if (updateGallery)
            {
                presetButton.Tag = null;
                presetButton.ImageIndex = 0;
                presetButton = (Button)sender;
                presetButton.Tag = "<disabled>";
                presetButton.ImageIndex = 1;

                SetupGalleryProviders();
            }
        }

        /*
        private void InitializeGlass()
        {
            bool isGlassSupported = false;

            if (Environment.OSVersion.Version.Major >= 6)
                DwmIsCompositionEnabled(ref isGlassSupported);

            if (isGlassSupported == false)
            {
                this.TransparencyKey = Color.FromArgb(254, 255, 254);
                this.BackColor = Color.FromArgb(254, 255, 254);
                return;
            }

            Margins marg;
            marg.Left = -1;
            marg.Top = -1;
            marg.Right = -1;
            marg.Bottom = -1;
            DwmExtendFrameIntoClientArea(this.Handle, ref marg);

           // this.Paint += new PaintEventHandler(this.Form3_Paint);
        }

        private void Form3_Paint(object sender, PaintEventArgs e)
        {
            SolidBrush blackBrush = new SolidBrush(Color.Black);
            e.Graphics.FillRectangle(blackBrush, 0, 0, this.ClientSize.Width, this.ClientSize.Height);
            blackBrush.Dispose();
        }
        */
        
    }
}