using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;

namespace COMInterfaces
{
    [StructLayout(LayoutKind.Sequential)]
    internal struct RECT
    {
        public int left;
        public int top;
        public int right;
        public int bottom;
    }

    [Serializable, StructLayout(LayoutKind.Sequential)]
    public struct MSG
    {
        public IntPtr hwnd;
        public int message;
        public IntPtr wParam;
        public IntPtr lParam;
        public int time;
        public int pt_x;
        public int pt_y;
    }

    [ComVisible(true), Guid("0000011B-0000-0000-C000-000000000046"),
    InterfaceTypeAttribute(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IOleContainer
    {
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int ParseDisplayName([In, MarshalAs(UnmanagedType.Interface)] Object pbc,
            [In, MarshalAs(UnmanagedType.LPWStr)] String pszDisplayName, [Out,
            MarshalAs(UnmanagedType.LPArray)] int[] pchEaten, [Out,
            MarshalAs(UnmanagedType.LPArray)] Object[] ppmkOut);
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int EnumObjects([In, MarshalAs(UnmanagedType.U4)] uint grfFlags, [Out,
            MarshalAs(UnmanagedType.LPArray)] Object[] ppenum);
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int LockContainer([In, MarshalAs(UnmanagedType.Bool)] Boolean fLock);
    }

    [ComVisible(true), Guid("00000118-0000-0000-C000-000000000046"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IOleClientSite
    {
        [PreserveSig]
        int SaveObject();
        [PreserveSig]
        int GetMoniker([In, MarshalAs(UnmanagedType.U4)] int dwAssign, [In, MarshalAs(UnmanagedType.U4)] int dwWhichMoniker, [MarshalAs(UnmanagedType.Interface)] out object moniker);
        [PreserveSig]
        int GetContainer(out object container);
        [PreserveSig]
        int ShowObject();
        [PreserveSig]
        int OnShowWindow(int fShow);
        [PreserveSig]
        int RequestNewObjectLayout();
    }

    [ComVisible(true), ComImport(),
    Guid("00000112-0000-0000-C000-000000000046"),
    InterfaceTypeAttribute(ComInterfaceType.InterfaceIsIUnknown)]
    internal interface IOleObject
    {
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int SetClientSite([In, MarshalAs(UnmanagedType.Interface)] IOleClientSite
            pClientSite);
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int GetClientSite([Out, MarshalAs(UnmanagedType.Interface)] out IOleClientSite site);
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int SetHostNames([In, MarshalAs(UnmanagedType.LPWStr)] String
            szContainerApp, [In, MarshalAs(UnmanagedType.LPWStr)] String
            szContainerObj);
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int Close([In, MarshalAs(UnmanagedType.U4)] uint dwSaveOption);
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int SetMoniker([In, MarshalAs(UnmanagedType.U4)] uint dwWhichMoniker, [In,
            MarshalAs(UnmanagedType.Interface)] Object pmk);
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int GetMoniker([In, MarshalAs(UnmanagedType.U4)] uint dwAssign, [In,
            MarshalAs(UnmanagedType.U4)] uint dwWhichMoniker, [Out, MarshalAs(UnmanagedType.Interface)] out Object moniker);
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int InitFromData([In, MarshalAs(UnmanagedType.Interface)] Object
            pDataObject, [In, MarshalAs(UnmanagedType.Bool)] Boolean fCreation, [In,
            MarshalAs(UnmanagedType.U4)] uint dwReserved);
        int GetClipboardData([In, MarshalAs(UnmanagedType.U4)] uint dwReserved, out
			Object data);
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int DoVerb([In, MarshalAs(UnmanagedType.I4)] int iVerb, [In] IntPtr lpmsg,
            [In, MarshalAs(UnmanagedType.Interface)] IOleClientSite pActiveSite, [In,
            MarshalAs(UnmanagedType.I4)] int lindex, [In] IntPtr hwndParent, [In] RECT
            lprcPosRect);
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int EnumVerbs(out Object e); // IEnumOLEVERB
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int OleUpdate();
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int IsUpToDate();
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int GetUserClassID([In, Out] ref Guid pClsid);
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int GetUserType([In, MarshalAs(UnmanagedType.U4)] uint dwFormOfType, [Out,
            MarshalAs(UnmanagedType.LPWStr)] out String userType);
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int SetExtent([In, MarshalAs(UnmanagedType.U4)] uint dwDrawAspect, [In]
			Object pSizel); // tagSIZEL
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int GetExtent([In, MarshalAs(UnmanagedType.U4)] uint dwDrawAspect, [Out]
			Object pSizel); // tagSIZEL
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int Advise([In, MarshalAs(UnmanagedType.Interface)] System.Runtime.InteropServices.ComTypes.IAdviseSink pAdvSink, out
			int cookie);
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int Unadvise([In, MarshalAs(UnmanagedType.U4)] int dwConnection);
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int EnumAdvise(out Object e);
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int GetMiscStatus([In, MarshalAs(UnmanagedType.U4)] uint dwAspect, out int
            misc);
        [return: MarshalAs(UnmanagedType.I4)]
        [PreserveSig]
        int SetColorScheme([In] Object pLogpal); // tagLOGPALETTE
    }


    [ComImport, Guid("B196B288-BAB4-101A-B69C-00AA00341D07"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IOleControl
    {
        [PreserveSig]
        int GetControlInfo([Out] object pCI);
        [PreserveSig]
        int OnMnemonic([In] ref MSG pMsg);
        [PreserveSig]
        int OnAmbientPropertyChange(int dispID);
        [PreserveSig]
        int FreezeEvents(int bFreeze);
    }
}
