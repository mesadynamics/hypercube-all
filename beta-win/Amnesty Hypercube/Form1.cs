using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

using System.IO;
using System.IO.IsolatedStorage;
using System.Xml.Serialization;

using ExtendedWebBrowser2;
using gma.System.Windows;

namespace Amnesty_Hypercube
{
    public partial class Form1 : Form
    {
        UserActivityHook actHook = new UserActivityHook();
        private Point mouse;

        bool tracking = false;
        int track;
        int trackDelta;
        int trackDistance;

        int dragFloorIndex = -1;
        private Rectangle dragBoxFromMouseDown1 = Rectangle.Empty;
        private int rowIndexFromMouseDown1 = -1;
        private int rowIndexOfItemUnderMouseToDrop1 = -1;
        private Rectangle dragBoxFromMouseDown2 = Rectangle.Empty;
        private int rowIndexFromMouseDown2 = -1;
        private int rowIndexOfItemUnderMouseToDrop2 = -1;

        DataGridViewCell currentProvider = null;
        Keys providerKeyCode = 0;
        Boolean ignoreProviderSelect = false;
        string saveProviderTitle = null;

        ExtendedWebBrowser2.ExtendedWebBrowser browser = null;

        string providerInfoKey = null;
        string providerURLString = null;
        string browserURLString = null;
        string destinationLinkKey = null;

        public Form1()
        {
            InitializeComponent();

            if (System.Environment.OSVersion.Version.Major < 6)
            {
                panel2.Width += 8;
                splitContainer1.Width += 8;
            }

            actHook.OnMouseActivity += new MouseEventHandler(global_MouseActivity);

            int x = Amnesty_Hypercube.Properties.Settings.Default.MainWindowLocation.X;
            int y = Amnesty_Hypercube.Properties.Settings.Default.MainWindowLocation.Y;
            int w = Amnesty_Hypercube.Properties.Settings.Default.MainWindowWidth;
            int h = Amnesty_Hypercube.Properties.Settings.Default.MainWindowHeight;

            this.WindowState = FormWindowState.Normal;
            this.SetDesktopBounds(x, y, w, h);

            if (Amnesty_Hypercube.Properties.Settings.Default.MainWindowMaximized)
                this.WindowState = FormWindowState.Maximized;
            if (Amnesty_Hypercube.Properties.Settings.Default.MainWindowMinimized)
                this.WindowState = FormWindowState.Minimized;

            if (Amnesty_Hypercube.Properties.Settings.Default.SourcePanelWidth != 0)
                splitContainer1.SplitterDistance = Amnesty_Hypercube.Properties.Settings.Default.SourcePanelWidth;

            splitContainer2.Panel2Collapsed = !Amnesty_Hypercube.Properties.Settings.Default.InfoPanelVisible;

            RestoreColumnWidth();
            RestoreColumnOrder();

            ToolTip tips = new ToolTip();
            tips.SetToolTip(button1, Amnesty_Hypercube.Properties.Resources.TipLaunch);
            tips.SetToolTip(button2, Amnesty_Hypercube.Properties.Resources.TipExplore);
            tips.SetToolTip(button3, Amnesty_Hypercube.Properties.Resources.TipShowAll);
            tips.SetToolTip(button4, Amnesty_Hypercube.Properties.Resources.TipHideAll);
            tips.SetToolTip(button5, Amnesty_Hypercube.Properties.Resources.TipCloseAll);
            tips.SetToolTip(button6, Amnesty_Hypercube.Properties.Resources.TipInfo);
            tips.SetToolTip(button7, Amnesty_Hypercube.Properties.Resources.TipFull);

            button8.MouseDown += new MouseEventHandler(button8_MouseDown);
            button8.MouseUp += new MouseEventHandler(button8_MouseUp);

            button9.MouseDown += new MouseEventHandler(button9_MouseDown);
            button9.MouseUp += new MouseEventHandler(button9_MouseUp);
            button9.MouseClick += new MouseEventHandler(button9_MouseClick);

            button10.MouseDown += new MouseEventHandler(button10_MouseDown);
            button10.MouseUp += new MouseEventHandler(button10_MouseUp);
            button10.MouseMove += new MouseEventHandler(button10_MouseMove);

            contextMenuStrip2.Opening += new CancelEventHandler(contextMenuStrip2_Opening);
            contextMenuStrip2.Closing += new ToolStripDropDownClosingEventHandler(contextMenuStrip2_Closing);

            dataGridView1.MouseDown +=new MouseEventHandler(dataGridView1_MouseDown);
            dataGridView1.MouseMove += new MouseEventHandler(dataGridView1_MouseMove);

            dataGridView2.CellBeginEdit += new DataGridViewCellCancelEventHandler(dataGridView2_CellBeginEdit);
            dataGridView2.CellEndEdit += new DataGridViewCellEventHandler(dataGridView2_CellEndEdit);
            dataGridView2.CellPainting += new DataGridViewCellPaintingEventHandler(dataGridView2_CellPainting);
            dataGridView2.MouseDown += new MouseEventHandler(dataGridView2_MouseDown);
            dataGridView2.MouseMove += new MouseEventHandler(dataGridView2_MouseMove);
            dataGridView2.DragOver += new DragEventHandler(dataGridView2_DragOver);
            dataGridView2.DragDrop += new DragEventHandler(dataGridView2_DragDrop);
            dataGridView2.KeyDown += new KeyEventHandler(dataGridView2_KeyDown);
            dataGridView2.SelectionChanged += new EventHandler(dataGridView2_SelectionChanged);

            splitContainer1.SplitterMoved += new SplitterEventHandler(splitContainer1_SplitterMoved);

            this.LocationChanged += new EventHandler(Form1_LocationChanged);
            this.Shown += new EventHandler(Form1_Shown);
            this.DoubleBuffered = true;
        }

        private void InitBrowser()
        {
            if(browser != null)
                return;

            browser = new ExtendedWebBrowser2.ExtendedWebBrowser();
            browser.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                | System.Windows.Forms.AnchorStyles.Left)
                | System.Windows.Forms.AnchorStyles.Right)));
            browser.IsWebBrowserContextMenuEnabled = false;
            browser.Location = new System.Drawing.Point(0, 0);
            browser.Margin = new System.Windows.Forms.Padding(0);
            browser.MinimumSize = new System.Drawing.Size(20, 20);
            browser.ScriptErrorsSuppressed = true;
            browser.Size = splitContainer1.Panel2.Bounds.Size;
            browser.TabIndex = 1;
            browser.Url = new System.Uri("", System.UriKind.Relative);
            browser.Visible = false;

            splitContainer1.Panel2.Controls.Add(browser);
        }

        public void OpenStore()
        {
        }

        public void CloseStore()
        {
        }

        public void OpenProvider(string urlString)
        {
            providerURLString = urlString;

            OpenBrowser(urlString, null);
        }

        public void OpenBrowser(string urlString, string destination)
        {
            if (browser == null)
                InitBrowser();

            if(destination != null)
                destinationLinkKey = destination;

            if (browser.Visible == false)
            {
                label2.Hide();
                button6.Enabled = false;

                browser.Show();
                splitContainer2.Hide();
            }

            if (urlString != null)
            {
                if(urlString.Equals(browserURLString))
                    return;

                browserURLString = urlString;

                browser.Url = new Uri(urlString);
            }
            else
                browser.Url = new Uri(browserURLString);
        }

        public void CloseBrowser()
        {
            if (browser != null && browser.Visible)
            {
                label2.Show();
                button6.Enabled = true;

                splitContainer2.Show();
                browser.Hide();
            }
        }

        void dataGridView1_MouseDown(object sender, MouseEventArgs e)
        {
            dataGridView1.Focus();

            providerKeyCode = 0;

            if ((e.Button & MouseButtons.Right) == MouseButtons.Right)
            {
                DataGridView.HitTestInfo hti = dataGridView1.HitTest(e.X, e.Y);
                if (hti.RowIndex >= 0 && hti.RowIndex < dataGridView1.Rows.Count)
                {
                    DataGridViewCell c = dataGridView1.Rows[hti.RowIndex].Cells[0];

                    if (dataGridView1.CurrentCell.Equals(c) == false)
                        dataGridView1.CurrentCell = c;
                }

                return;
            }

            // Get the index of the item the mouse is below.
            rowIndexFromMouseDown1 = dataGridView1.HitTest(e.X, e.Y).RowIndex;
            if (rowIndexFromMouseDown1 != -1)
            {
                // Remember the point where the mouse down occurred. 
                // The DragSize indicates the size that the mouse can move 
                // before a drag event should be started.                
                Size dragSize = SystemInformation.DragSize;
                // Create a rectangle using the DragSize, with the mouse position being
                // at the center of the rectangle.
                dragBoxFromMouseDown1 = new Rectangle(new Point(e.X - (dragSize.Width / 2), e.Y - (dragSize.Height / 2)), dragSize);
            }
            else
                // Reset the rectangle if the mouse is not over an item in the ListBox.
                dragBoxFromMouseDown1 = Rectangle.Empty;
        }

        void dataGridView1_MouseMove(object sender, MouseEventArgs e)
        {
            if ((e.Button & MouseButtons.Left) == MouseButtons.Left)
            {
                // If the mouse moves outside the rectangle, start the drag.
                if (dragBoxFromMouseDown1 != Rectangle.Empty && !dragBoxFromMouseDown1.Contains(e.X, e.Y))
                {
                    // Proceed with the drag and drop, passing in the list item.                    
                    Widget.WidgetsRow row = (Widget.WidgetsRow)widget.Widgets.Rows[rowIndexFromMouseDown1];
                    DragDropEffects dropEffect = dataGridView1.DoDragDrop(row, DragDropEffects.Copy);
                }
            }
        }

        void dataGridView2_CellPainting(object sender, DataGridViewCellPaintingEventArgs e)
        {
            if (e.Value.ToString().EndsWith("  "))
            {
                Font f = new Font(e.CellStyle.Font, FontStyle.Bold);
                e.CellStyle.Font = f;
                e.CellStyle.ForeColor = Color.FromArgb(59, 69, 82);
 
                e.PaintContent(e.ClipBounds);
            }
            else
            {
                bool selected = ((e.State & DataGridViewElementStates.Selected) != 0 ? true : false);
                if(selected) {
                    Font f = new Font(e.CellStyle.Font, FontStyle.Bold);
                    e.CellStyle.Font = f;
                }

                e.PaintBackground(e.ClipBounds, true);

                String s = dataGridView2.Rows[e.RowIndex].Cells[3].Value.ToString();
                Image i = (Image) Amnesty_Hypercube.Properties.Resources.ResourceManager.GetObject(s);
                Point p = new Point(e.CellBounds.Location.X + 34, e.CellBounds.Location.Y + 4);
                try
                {
                    e.Graphics.DrawImage(i, new Rectangle(p, new Size(16, 16)));
                }

                catch
                {
                }

                //if (selected)
                //    e.Graphics.DrawLine(new Pen(Color.FromArgb(69, 128, 199)), new Point(e.CellBounds.X, e.CellBounds.Y), new Point(e.CellBounds.X + e.CellBounds.Width, e.CellBounds.Y));

                e.CellStyle.Padding = new Padding(53, 0, 0, 0);
                e.PaintContent(e.ClipBounds);
 
                e.Handled = true;
            }
       }

        void dataGridView2_MouseDown(object sender, MouseEventArgs e)
        {
            dataGridView2.Focus();

            providerKeyCode = 0;

            if ((e.Button & MouseButtons.Right) == MouseButtons.Right)
            {
                DataGridView.HitTestInfo hti = dataGridView2.HitTest(e.X, e.Y);
                if (hti.RowIndex >= 0 && hti.RowIndex < dataGridView2.Rows.Count)
                {
                    DataGridViewCell c = dataGridView2.Rows[hti.RowIndex].Cells[0];

                    if (c.Value.ToString().EndsWith("  ") == false && dataGridView2.CurrentCell.Equals(c) == false) 
                       dataGridView2.CurrentCell = c;

                   Boolean canEdit = (Boolean)dataGridView2.Rows[hti.RowIndex].Cells[4].Value;
                   contextMenuStrip1.Enabled = canEdit;
               }

               return;
            }

            // Get the index of the item the mouse is below.
            rowIndexFromMouseDown2 = dataGridView2.HitTest(e.X, e.Y).RowIndex;
            if (rowIndexFromMouseDown2 != -1 && rowIndexFromMouseDown2 >= dragFloorIndex)
            {
                // Remember the point where the mouse down occurred. 
                // The DragSize indicates the size that the mouse can move 
                // before a drag event should be started.                
                Size dragSize = SystemInformation.DragSize;
                // Create a rectangle using the DragSize, with the mouse position being
                // at the center of the rectangle.
                dragBoxFromMouseDown2 = new Rectangle(new Point(e.X - (dragSize.Width / 2), e.Y - (dragSize.Height / 2)), dragSize);
            }
            else
                // Reset the rectangle if the mouse is not over an item in the ListBox.
                dragBoxFromMouseDown2 = Rectangle.Empty;
        }

        void dataGridView2_MouseMove(object sender, MouseEventArgs e)
        {
            if ((e.Button & MouseButtons.Left) == MouseButtons.Left)
            {
                // If the mouse moves outside the rectangle, start the drag.
                if (dragBoxFromMouseDown2 != Rectangle.Empty && !dragBoxFromMouseDown2.Contains(e.X, e.Y))
                {
                    // Proceed with the drag and drop, passing in the list item.                    
                    Provider.ProvidersRow row = (Provider.ProvidersRow)provider.Providers.Rows[rowIndexFromMouseDown2];
                    DragDropEffects dropEffect = dataGridView2.DoDragDrop(row, DragDropEffects.Move);
                }
            }
        }
 
        void dataGridView2_DragDrop(object sender, DragEventArgs e)
        {
            // The mouse locations are relative to the screen, so they must be 
            // converted to client coordinates.
            Point clientPoint = dataGridView2.PointToClient(new Point(e.X, e.Y));
            // Get the row index of the item the mouse is below. 
            rowIndexOfItemUnderMouseToDrop2 = dataGridView2.HitTest(clientPoint.X, clientPoint.Y).RowIndex;
            // If the drag operation was a move then remove and insert the row.
            if (e.Effect == DragDropEffects.Move)
            {
                rowIndexOfItemUnderMouseToDrop2++;

                Provider.ProvidersRow row = e.Data.GetData(typeof(Provider.ProvidersRow)) as Provider.ProvidersRow;
                Provider.ProvidersRow copy = CopyProvider(row);
                InsertNewProvider(copy, rowIndexOfItemUnderMouseToDrop2);
                provider.Providers.RemoveProvidersRow(row);
            }
        }

        void dataGridView2_DragOver(object sender, DragEventArgs e)
        {
            Point clientPoint = dataGridView2.PointToClient(new Point(e.X, e.Y));
            int dropIndex = dataGridView2.HitTest(clientPoint.X, clientPoint.Y).RowIndex;

            e.Effect = DragDropEffects.None;

            if (e.AllowedEffect == DragDropEffects.Move)
            {
                if (dropIndex >= dragFloorIndex - 1 && dropIndex != rowIndexFromMouseDown2 && dropIndex != rowIndexFromMouseDown2 - 1)
                    e.Effect = DragDropEffects.Move;
                else
                    e.Effect = DragDropEffects.None;
            }
            else if (e.AllowedEffect == DragDropEffects.Copy)
            {
                if (dataGridView2.CurrentCell.RowIndex == dropIndex)
                    return;

                Boolean canDrop = (Boolean)dataGridView2.Rows[dropIndex].Cells[6].Value;
                if(canDrop)
                    e.Effect = DragDropEffects.Copy;
            }
        }
       
        void dataGridView2_KeyDown(object sender, KeyEventArgs e)
        {
            providerKeyCode = e.KeyCode;

            if (providerKeyCode == Keys.Delete)
                DeleteSelectedProvider();
        }

        void dataGridView2_SelectionChanged(object sender, EventArgs e)
        {
            if (dataGridView2.SelectedCells.Count == 0)
            {
                contextMenuStrip2.Items[2].Enabled = false;
                contextMenuStrip2.Items[4].Enabled = false;
                contextMenuStrip2.Items[5].Enabled = false;
                return;
            }

            DataGridViewCell c = dataGridView2.SelectedCells[0];

            Boolean canEdit = (Boolean)dataGridView2.Rows[c.RowIndex].Cells[4].Value;
            if (canEdit)
            {
                contextMenuStrip2.Items[2].Enabled = true;
                contextMenuStrip2.Items[4].Enabled = true;
                contextMenuStrip2.Items[5].Enabled = true;
            }
            else
            {
                contextMenuStrip2.Items[2].Enabled = false;
                contextMenuStrip2.Items[4].Enabled = false;
                contextMenuStrip2.Items[5].Enabled = false;
            }

            if (ignoreProviderSelect)
                return;

            ignoreProviderSelect = true;

            if (c.Value.ToString().EndsWith("  ") == false)
            {
                currentProvider = c;
                HandleProviderSelection(c.RowIndex);

                string key = (string)dataGridView2.Rows[c.RowIndex].Cells[1].Value;
                SwitchInfo(key);
            }
            else
            {
                if (providerKeyCode == Keys.Up)
                {
                    if (c.RowIndex > 1)
                        dataGridView2.CurrentCell = dataGridView2.Rows[c.RowIndex - 1].Cells[0];
                    else
                        dataGridView2.CurrentCell = dataGridView2.Rows[1].Cells[0];

                    currentProvider = dataGridView2.CurrentCell;
                }
                else if (providerKeyCode == Keys.Down)
                {
                    if (c.RowIndex + 1 < dataGridView2.Rows.Count)
                        dataGridView2.CurrentCell = dataGridView2.Rows[c.RowIndex + 1].Cells[0];
                    else
                        dataGridView2.CurrentCell = dataGridView2.Rows[c.RowIndex - 1].Cells[0];

                    currentProvider = dataGridView2.CurrentCell;
                }
                else if (currentProvider != null)
                    dataGridView2.CurrentCell = currentProvider;

                HandleProviderSelection(dataGridView2.CurrentCell.RowIndex);
            }

            providerKeyCode = 0;
            ignoreProviderSelect = false;
        }

        private void AddNewProvider()
        {
            Provider.ProvidersRow row = provider.Providers.NewProvidersRow();

            row.title = "Untitled";
            row.key = "";
            row.icon = "IconCube";
            row.canEdit = true;
            row.canSelect = true;
            row.canDrop = true;
            row.canLink = false;
            row.status = 0;
            row.index = 32767;

            provider.Providers.AddProvidersRow(row);

            ReindexProviders();

            dataGridView2.CurrentCell = dataGridView2.Rows[dataGridView2.Rows.Count - 1].Cells[0];
            dataGridView2.Focus();
        }

        private Provider.ProvidersRow CopyProvider(Provider.ProvidersRow row)
        {
            Provider.ProvidersRow copy = provider.Providers.NewProvidersRow();

            copy.title = row.title;
            copy.key = "";
            copy.type = "widgets";
            copy.icon = "IconCube";
            copy.canEdit = true;
            copy.canSelect = true;
            copy.canDrop = true;
            copy.canLink = false;
            copy.status = 0;
            copy.index = 32767;

            return copy;
        }

        private void InsertNewProvider(Provider.ProvidersRow row, int rowIndex)
        {
            provider.Providers.Rows.InsertAt(row, rowIndex);
            ReindexProviders();
        }

        private void ReindexProviders()
        {
            for (int i = dragFloorIndex; i < provider.Providers.Rows.Count; i++)
            {
                Provider.ProvidersRow row = (Provider.ProvidersRow)provider.Providers.Rows[i];
                row.index = 32768 + i;
            }

            for (int i = dragFloorIndex; i < provider.Providers.Rows.Count; i++)
            {
                Provider.ProvidersRow row = (Provider.ProvidersRow)provider.Providers.Rows[i];
                row.index = i;
            }
        }

        private void RenameSelectedProvider()
        {
            if (dataGridView2.SelectedCells.Count == 1)
            {
                DataGridViewCell c = dataGridView2.SelectedCells[0];

                Boolean canEdit = (Boolean)dataGridView2.Rows[c.RowIndex].Cells[4].Value;
                if (canEdit)
                {
                    dataGridView2.BeginEdit(true);
                 }
            }
         }

        private void DeleteSelectedProvider()
        {
            if (dataGridView2.SelectedCells.Count == 1)
            {
                DataGridViewCell c = dataGridView2.SelectedCells[0];

                Boolean canEdit = (Boolean)dataGridView2.Rows[c.RowIndex].Cells[4].Value;
                if (canEdit)
                {
                    string title = (string)dataGridView2.Rows[c.RowIndex].Cells[0].Value;
                    string msg = String.Format(Amnesty_Hypercube.Properties.Resources.ConfirmDeleteProvider, title);
                    DialogResult dr = MessageBox.Show(msg, Amnesty_Hypercube.Properties.Resources.ConfirmDeleteTitle, MessageBoxButtons.YesNo);
                    if (dr == DialogResult.Yes)
                    {
                        int nextRow = c.RowIndex;

                        Provider.ProvidersRow row = (Provider.ProvidersRow) provider.Providers.Rows[c.RowIndex];
                        provider.Providers.RemoveProvidersRow(row);
 
                        if (nextRow < dataGridView2.Rows.Count)
                            dataGridView2.CurrentCell = dataGridView2.Rows[nextRow].Cells[0];
                        else
                        {
                            nextRow--;

                            canEdit = (Boolean)dataGridView2.Rows[nextRow].Cells[4].Value;
                            if(canEdit)
                                dataGridView2.CurrentCell = dataGridView2.Rows[nextRow].Cells[0];
                            else
                                dataGridView2.CurrentCell = dataGridView2.Rows[1].Cells[0];
                        }

                        dataGridView2.Focus();
                    }
                }
                else
                    System.Media.SystemSounds.Exclamation.Play();
            }
        }

        private void HandleProviderSelection(int rowIndex)
        {
            Boolean canLink = (Boolean) dataGridView2.Rows[rowIndex].Cells[7].Value;
            string key = dataGridView2.Rows[rowIndex].Cells[1].Value.ToString();
            if (key.Equals("_Store"))
                OpenStore();
            else
                CloseStore();

            if (key.Equals("_Showcase"))
                OpenBrowser("http://www.amnestywidgets.com/hypercube/winhost/fidget.php", null);
            else if (key.Equals("_Widgetbox"))
                OpenBrowser("http://www.widgetbox.com/cgallery/hypercube/home", null);
            else if (key.Equals("_Store"))
            {
                if (providerURLString != null)
                    OpenBrowser(providerURLString, null);
                else
                    CloseBrowser();
            }
            else if (canLink.Equals(true))
            {
                if (key != null)
                {
                    string destination = key.Substring(1);
                    string linkURL = String.Format("http://www.amnestywidgets.com/hypercube/deskhost/link_{0}.html", destination);
                    OpenBrowser(linkURL, destination);
                }
                else
                    CloseBrowser();
            }
            else
                CloseBrowser();
        }

        private void SwitchInfo(string key)
        {
            if (providerInfoKey != null && providerInfoKey.Equals(key))
                return;

            providerInfoKey = key;

            // todo: switch info views here

            //this.widgetsTableAdapter.ClearBeforeFill = true;
            this.widgetsTableAdapter.Fill(this.widget.Widgets, key);
        }

        private void SaveColumnOrder()
        {
            IsolatedStorageFile isoFile = IsolatedStorageFile.GetUserStoreForAssembly();
            using (IsolatedStorageFileStream isoStream = new IsolatedStorageFileStream("ColumnOrder", FileMode.Create, isoFile))
            {
                int[] displayIndices = new int[dataGridView1.ColumnCount];
                for (int i = 0; i < dataGridView1.ColumnCount; i++)
                    displayIndices[i] = dataGridView1.Columns[i].DisplayIndex;

                XmlSerializer ser = new XmlSerializer(typeof(int[]));
                ser.Serialize(isoStream, displayIndices);
            }
        }

        private void SaveColumnWidth()
        {
            IsolatedStorageFile isoFile = IsolatedStorageFile.GetUserStoreForAssembly();
            using (IsolatedStorageFileStream isoStream = new IsolatedStorageFileStream("ColumnWidth", FileMode.Create, isoFile))
            {
                int[] displayIndices = new int[dataGridView1.ColumnCount];
                for (int i = 0; i < dataGridView1.ColumnCount; i++)
                    displayIndices[i] = dataGridView1.Columns[i].Width;

                XmlSerializer ser = new XmlSerializer(typeof(int[]));
                ser.Serialize(isoStream, displayIndices);
            }
        }

        private void RestoreColumnOrder()
        {
            IsolatedStorageFile isoFile = IsolatedStorageFile.GetUserStoreForAssembly();
            if (UserStoreExists(isoFile, "ColumnOrder") == false)
                return;

            using (IsolatedStorageFileStream isoStream = new IsolatedStorageFileStream("ColumnOrder", FileMode.Open, isoFile))
            {
                try
                {
                    XmlSerializer ser = new XmlSerializer(typeof(int[]));

                    int[] displayIndicies = (int[])ser.Deserialize(isoStream);
                    for (int i = 0; i < displayIndicies.Length; i++)
                        dataGridView1.Columns[i].DisplayIndex = displayIndicies[i];
                }

                catch
                {
                }
            }
        }

        private void RestoreColumnWidth()
        {
            IsolatedStorageFile isoFile = IsolatedStorageFile.GetUserStoreForAssembly();
            if (UserStoreExists(isoFile, "ColumnWidth") == false)
                return;

            using (IsolatedStorageFileStream isoStream = new IsolatedStorageFileStream("ColumnWidth", FileMode.Open, isoFile))
            {
                try
                {
                    XmlSerializer ser = new XmlSerializer(typeof(int[]));

                    int[] displayIndicies = (int[])ser.Deserialize(isoStream);
                    for (int i = 0; i < displayIndicies.Length; i++)
                        dataGridView1.Columns[i].Width = displayIndicies[i];
                }

                catch
                {
                }
            }
        }

        private bool UserStoreExists(IsolatedStorageFile isoFile, string name)
        {
            string[] fileNames = isoFile.GetFileNames("*");
            foreach (string fileName in fileNames)
            {
                if (fileName.Equals(name))
                    return true;
            }

            return false;
        }

        void Form1_LocationChanged(object sender, EventArgs e)
        {
            if (this.WindowState == FormWindowState.Normal)
            {
                Amnesty_Hypercube.Properties.Settings.Default.MainWindowLocation = this.Location;
             }
        }

        void Form1_Shown(object sender, EventArgs e)
        {
            Point mainWindowLocation = Amnesty_Hypercube.Properties.Settings.Default.MainWindowLocation;
            if (mainWindowLocation.X == 0 && mainWindowLocation.Y == 0)
                this.CenterToScreen();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            // TODO: This line of code loads data into the 'widget.Widgets' table. You can move, or remove it, as needed.
            this.widgetsBindingSource.Sort = "title ASC";
 
            // TODO: This line of code loads data into the 'provider.Providers' table. You can move, or remove it, as needed.
            {
                try
                {
                    this.provider.Providers.ReadXml("ProviderLibrary.xml");
                }

                catch
                {
                    this.providersTableAdapter.Fill(this.provider.Providers);
                }
            }

            {
                providerInfoKey = "_Web";
                this.widgetsTableAdapter.Fill(this.widget.Widgets, "_Web");

                try
                {
                    if (this.widget.Widgets.Rows.Count == 0)
                    {
                        bool loadDefaultLibrary = true;

                        if (Amnesty_Hypercube.Properties.Settings.Default.FirstLaunch == true)
                            loadDefaultLibrary = true;
                        else
                        {
                            DialogResult dr = MessageBox.Show(Amnesty_Hypercube.Properties.Resources.LoadDefault, Amnesty_Hypercube.Properties.Resources.LoadDefaultTitle, MessageBoxButtons.YesNo);
                            if (dr == DialogResult.Yes)
                                loadDefaultLibrary = true;
                        }

                        if (loadDefaultLibrary)
                            this.widget.Widgets.ReadXml("HypercubeLibrary.xml");
                    }
                }

                catch
                {
                }
            }

            dataGridView2.CurrentCell = dataGridView2.Rows[1].Cells[0];

            dragFloorIndex = 0;
            foreach (Provider.ProvidersRow r in provider.Providers.Rows)
            {
                if (r.canEdit)
                {
                    break;
                }

                dragFloorIndex++;
            }

            ReindexProviders();
        }

        protected override void OnClosing(CancelEventArgs e)
        {
            SaveColumnOrder();
            SaveColumnWidth();

            this.provider.AcceptChanges();
            this.provider.WriteXml("ProviderLibrary.xml");

            this.widgetsTableAdapter.Update(this.widget.Widgets);

            //this.widget.AcceptChanges();
            //this.widget.WriteXml("HypercubeLibrary.xml");
            Amnesty_Hypercube.Properties.Settings.Default.InfoPanelVisible = !splitContainer2.Panel2Collapsed;
            Amnesty_Hypercube.Properties.Settings.Default.SourcePanelWidth = splitContainer1.SplitterDistance;

            Amnesty_Hypercube.Properties.Settings.Default.MainWindowMaximized = (this.WindowState == FormWindowState.Maximized ? true : false);
            Amnesty_Hypercube.Properties.Settings.Default.MainWindowMinimized = (this.WindowState == FormWindowState.Minimized ? true : false);

            if (this.WindowState == FormWindowState.Normal)
            {
                Amnesty_Hypercube.Properties.Settings.Default.MainWindowWidth = this.Size.Width;
                Amnesty_Hypercube.Properties.Settings.Default.MainWindowHeight = this.Size.Height;
            }

            Amnesty_Hypercube.Properties.Settings.Default.FirstLaunch = false;
            Amnesty_Hypercube.Properties.Settings.Default.Save();

            base.OnClosing(e);
        }

        void dataGridView2_CellBeginEdit(object sender, DataGridViewCellCancelEventArgs e)
        {
            saveProviderTitle = dataGridView2[e.ColumnIndex, e.RowIndex].Value.ToString();
        }

        void dataGridView2_CellEndEdit(object sender, DataGridViewCellEventArgs e)
        {
            string trim = dataGridView2[e.ColumnIndex, e.RowIndex].Value.ToString().Trim();
            dataGridView2[e.ColumnIndex, e.RowIndex].Value = trim;

            if (dataGridView2[e.ColumnIndex, e.RowIndex].Value.ToString().Length == 0)
                dataGridView2[e.ColumnIndex, e.RowIndex].Value = saveProviderTitle;
        }

        private void button6_Click(object sender, EventArgs e)
        {
            splitContainer2.Panel2Collapsed = !splitContainer2.Panel2Collapsed;
        }


        void splitContainer1_SplitterMoved(object sender, SplitterEventArgs e)
        {
            if (splitContainer1.SplitterDistance > 400)
                splitContainer1.SplitterDistance = 400;
        }

        void button10_MouseDown(object sender, MouseEventArgs e)
        {
            tracking = true;
            track = this.mouse.X;
            trackDistance = splitContainer1.SplitterDistance;
        }

        void button10_MouseUp(object sender, MouseEventArgs e)
        {
            tracking = false;
        }

        void button10_MouseMove(object sender, MouseEventArgs e)
        {
            if (tracking)
            {
                int newDistance = trackDistance - (track - this.mouse.X);
                if (newDistance < splitContainer1.Panel1MinSize)
                    newDistance = splitContainer1.Panel1MinSize;
                if (newDistance > 400)
                    newDistance = 400;

                if (splitContainer1.SplitterDistance != newDistance)
                    splitContainer1.SplitterDistance = newDistance;
            }
        }

        void contextMenuStrip2_Opening(object sender, CancelEventArgs e)
        {
            button9.BackgroundImage = Amnesty_Hypercube.Properties.Resources.Action_Pressed;
        }

        void contextMenuStrip2_Closing(object sender, ToolStripDropDownClosingEventArgs e)
        {
            button9.BackgroundImage = Amnesty_Hypercube.Properties.Resources.Action;
        }

        void button8_MouseDown(object sender, MouseEventArgs e)
        {
            button8.BackgroundImage = Amnesty_Hypercube.Properties.Resources.Add_Pressed;
        }

        void button8_MouseUp(object sender, MouseEventArgs e)
        {
            button8.BackgroundImage = Amnesty_Hypercube.Properties.Resources.Add;
        }

        void button9_MouseDown(object sender, MouseEventArgs e)
        {
            button9.BackgroundImage = Amnesty_Hypercube.Properties.Resources.Action_Pressed;
        }

        void button9_MouseUp(object sender, MouseEventArgs e)
        {
            if (contextMenuStrip2.Visible == false)
                button9.BackgroundImage = Amnesty_Hypercube.Properties.Resources.Action;
        }

        void button9_MouseClick(object sender, MouseEventArgs e)
        {
            contextMenuStrip2.Show(button9, e.Location);
        }

        private void button8_Click(object sender, EventArgs e)
        {
            AddNewProvider();
         }

        void global_MouseActivity(object sender, MouseEventArgs e)
        {
            mouse = e.Location;
        }

        private void deleteToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            DeleteSelectedProvider();
        }

        private void deleteToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DeleteSelectedProvider();
        }

        private void newCollectionToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            AddNewProvider();
        }

        private void renameToolStripMenuItem2_Click(object sender, EventArgs e)
        {
            RenameSelectedProvider();
        }

        private void renameToolStripMenuItem_Click(object sender, EventArgs e)
        {
            RenameSelectedProvider();
        }

        private void closeToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}