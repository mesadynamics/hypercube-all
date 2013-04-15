//
//  Amnesty Hypercube for Windows
//
//  Created by Danny Espinoza on 3/29/07.
//  Copyright 2007-2008 Mesa Dynamics, LLC. All rights reserved.
//

using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Runtime.InteropServices;

namespace Amnesty_Hypercube
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            System.Diagnostics.Process[] RunningProcesses = System.Diagnostics.Process.GetProcessesByName("Amnesty Hypercube");

            if (RunningProcesses.Length == 1)
                Application.Run(new Form1());
        }
    }
}