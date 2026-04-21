using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using SolidWorks.Interop.sldworks;
using SolidWorks.Interop.swconst;
using SolidWorks.Interop.swpublished;

namespace SWKMA
{
    [ComVisible(true)]
    [Guid("64D84459-B29E-495C-9DD2-25F8E7A5EEF1")]
    [ProgId("SWKMA.SwAddin")]
    public class SwAddin : ISwAddin
    {
        private SldWorks _solidWorks;
        private int _addinCookie;
        private ICommandManager _cmdManager;

        private const int CmdGroupId = 1;
        private const int CmdOpenMprop = 0;

        public bool ConnectToSW(object ThisSW, int Cookie)
        {
            _solidWorks = (SldWorks)ThisSW;
            _addinCookie = Cookie;

            _solidWorks.SetAddinCallbackInfo2(0, this, _addinCookie);
            AddCommandMgr();

            return true;
        }

        public bool DisconnectFromSW()
        {
            RemoveCommandMgr();
            _solidWorks = null;
            _addinCookie = 0;

            return true;
        }

        private void AddCommandMgr()
        {
            _cmdManager = _solidWorks.GetCommandManager(_addinCookie);

            int registryIDs = 0;
            ICommandGroup cmdGroup = _cmdManager.CreateCommandGroup2(
                CmdGroupId,
                "SWKMA",
                "SWKMA — автоматизация конструктора",
                "SWKMA",
                -1,
                true,
                ref registryIDs);

            cmdGroup.AddCommandItem2(
                "Редактор свойств",
                -1,
                "Открыть редактор свойств SWKMA",
                "Редактор свойств",
                0,
                "OpenMprop",
                "EnableMprop",
                CmdOpenMprop,
                (int)(swCommandItemType_e.swMenuItem | swCommandItemType_e.swToolbarItem));

            cmdGroup.HasToolbar = true;
            cmdGroup.HasMenu = true;
            cmdGroup.Activate();
        }

        private void RemoveCommandMgr()
        {
            if (_cmdManager != null)
            {
                _cmdManager.RemoveCommandGroup(CmdGroupId);
                _cmdManager = null;
            }
        }

        public void OpenMprop()
        {
            MessageBox.Show(
                "SWKMA — Редактор свойств\n\nВ следующем шаге здесь откроется окно Mprop.",
                "SWKMA",
                MessageBoxButtons.OK,
                MessageBoxIcon.Information);
        }

        public int EnableMprop()
        {
            return 1; // команда всегда доступна
        }
    }
}
