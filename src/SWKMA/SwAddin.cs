using System;
using System.Runtime.InteropServices;
using SolidWorks.Interop.sldworks;
using SolidWorks.Interop.swpublished;

namespace SWKMA
{
    [ComVisible(true)]
    [Guid("64D84459-B29E-495C-9DD2-25F8E7A5EEF1")]
    public class SwAddin : ISwAddin
    {
        private SldWorks _solidWorks;
        private int _addinCookie;

        public bool ConnectToSW(object ThisSW, int Cookie)
        {
            _solidWorks = ThisSW as SldWorks;
            _addinCookie = Cookie;

            return true;
        }

        public bool DisconnectFromSW()
        {
            _solidWorks = null;
            _addinCookie = 0;

            return true;
        }
    }
}
