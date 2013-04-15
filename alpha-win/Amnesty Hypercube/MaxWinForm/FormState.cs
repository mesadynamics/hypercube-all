using System;
using System.Drawing;
using System.Windows.Forms;
using System.Runtime.InteropServices;

namespace Org.Vesic.WinForms
{
    /// <summary>
    /// Selected Win AI Function Calls
    /// </summary>
    
    public class WinApi
    {
        [DllImport("user32.dll", EntryPoint = "GetSystemMetrics")]
        public static extern int GetSystemMetrics(int which);

        [DllImport("user32.dll")]
        public static extern void 
            SetWindowPos(IntPtr hwnd, IntPtr hwndInsertAfter,
                         int X, int Y, int width, int height, uint flags);        
        
        private const int SM_CXSCREEN = 0;
	    private const int SM_CYSCREEN = 1;
        private static IntPtr HWND_TOP = IntPtr.Zero;
        private static IntPtr HWND_BOTTOM = (IntPtr) (1);
        private static IntPtr HWND_TOPMOST = (IntPtr) (-1);
        private static IntPtr HWND_NOTTOPMOST = (IntPtr) (-2);
        private const int SWP_NOSIZE = 0x0001;
        private const int SWP_NOMOVE = 0x0002;
        private const int SWP_SHOWWINDOW = 0x0040;
        
        public static int ScreenX
        {
            get { return GetSystemMetrics(SM_CXSCREEN);}
        }
        
        public static int ScreenY
        {
            get { return GetSystemMetrics(SM_CYSCREEN);}
        }

        public static void SetWinFullScreen(IntPtr hwnd)
        {
            //SetWindowPos(hwnd, HWND_TOP, 0, 0, ScreenX, ScreenY, SWP_SHOWWINDOW);
            SetWindowPos(hwnd, HWND_NOTTOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
        }

        public static void SetWinFullScreenTop(IntPtr hwnd)
        {
            //SetWindowPos(hwnd, HWND_TOP, 0, 0, ScreenX, ScreenY, SWP_SHOWWINDOW);
            SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
        }

        public static void SetWinNotFullScreen(IntPtr hwnd)
        {
            SetWindowPos(hwnd, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
        }

        public static void SetWinTop(IntPtr hwnd)
        {
            SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
        }

        public static void SetWinNotTop(IntPtr hwnd)
        {
            SetWindowPos(hwnd, HWND_NOTTOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
        }
    }
    
    /// <summary>
    /// Class used to preserve / restore state of the form
    /// </summary>
    public class FormState
    {
        private FormWindowState winState;
        //private FormBorderStyle brdStyle;
        private bool topMost;
        //private Rectangle bounds;

        private bool IsMaximized = false;

        public void Float(Form targetForm)
        {
            targetForm.TopMost = true;
            WinApi.SetWinTop(targetForm.Handle);
        }

        public void FloatUnder(Form targetForm)
        {
            targetForm.TopMost = true;
            WinApi.SetWinNotTop(targetForm.Handle);
        }

        public void DontFloat(Form targetForm)
        {
            targetForm.TopMost = false;
        }

        public void Maximize(Form targetForm)
        {
            if (!IsMaximized)
            {
                IsMaximized = true;
                Save(targetForm);
                if (System.Environment.OSVersion.Version.Major >= 6)
                    targetForm.WindowState = FormWindowState.Maximized;
                //targetForm.FormBorderStyle = FormBorderStyle.None;
                targetForm.TopMost = true;
                WinApi.SetWinFullScreen(targetForm.Handle);
            }
        }

        public void MaximizeTop(Form targetForm)
        {
            if (!IsMaximized)
            {
                IsMaximized = true;
                Save(targetForm);
                if (System.Environment.OSVersion.Version.Major >= 6)
                    targetForm.WindowState = FormWindowState.Maximized;
                //targetForm.FormBorderStyle = FormBorderStyle.None;
                targetForm.TopMost = true;
                WinApi.SetWinFullScreenTop(targetForm.Handle);
            }
        }

        public void ReMaximize(Form targetForm)
        {
            if (IsMaximized)
            {
                WinApi.SetWinFullScreenTop(targetForm.Handle);
            }
        }

        public void Save(Form targetForm)
        {
            winState = targetForm.WindowState;
            //brdStyle = targetForm.FormBorderStyle;
            topMost = targetForm.TopMost;
            //bounds = targetForm.Bounds;
        }

        public void Restore(Form targetForm)
        {
            WinApi.SetWinNotFullScreen(targetForm.Handle);
            if (System.Environment.OSVersion.Version.Major >= 6)
                targetForm.WindowState = winState;
            //targetForm.FormBorderStyle = brdStyle;
            targetForm.TopMost = topMost;
            //targetForm.Bounds = bounds;
            IsMaximized = false;
        }
    }
}
