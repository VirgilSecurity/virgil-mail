using Microsoft.Office.Tools.Ribbon;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using Virgil.Mail.Common;
using Office = Microsoft.Office.Core;


namespace Virgil.Mail
{
    [ComVisible(true)]
    public class Ribbon : Office.IRibbonExtensibility
    {
        private Office.IRibbonUI ribbon;
        public bool isEncryptButtonToggled { get; private set; }

        public Ribbon()
        {
        }

        #region IRibbonExtensibility Members

        public string GetCustomUI(string ribbonID)
        {
            /*
              string ribbonXML = String.Empty;

            if (ribbonID == "Microsoft.Outlook.Mail.Compose")
            {
                ribbonXML = GetResourceText("Trin_RibbonOutlookBasic.Ribbon1.xml");
            }

            return ribbonXML;
             */
            return GetResourceText("Virgil.Mail.Ribbon.xml");
        }

        #endregion

        #region Helpers

        private static string GetResourceText(string resourceName)
        {
            Assembly asm = Assembly.GetExecutingAssembly();
            string[] resourceNames = asm.GetManifestResourceNames();
            for (int i = 0; i < resourceNames.Length; ++i)
            {
                if (string.Compare(resourceName, resourceNames[i], StringComparison.OrdinalIgnoreCase) == 0)
                {
                    using (StreamReader resourceReader = new StreamReader(asm.GetManifestResourceStream(resourceNames[i])))
                    {
                        if (resourceReader != null)
                        {
                            return resourceReader.ReadToEnd();
                        }
                    }
                }
            }
            return null;
        }

        #endregion

        #region Ribbon Callbacks

        public void Ribbon_Load(Office.IRibbonUI ribbonUI)
        {
            this.ribbon = ribbonUI;
            this.isEncryptButtonToggled = Properties.Settings.Default.AutoEncryptEmails;
        }



        public void EncryptButton_Toggle(Office.IRibbonControl control, bool pressed)
        {
            this.isEncryptButtonToggled = pressed;
            Properties.Settings.Default.AutoEncryptEmails = isEncryptButtonToggled;
            Properties.Settings.Default.Save();

            this.ribbon.Invalidate();
        }


        public bool EncryptButton_GetPressed(Office.IRibbonControl control)
        {
            return this.isEncryptButtonToggled;
        }

        public void MailKeysButton_Click(Office.IRibbonControl control)
        {
            ServiceLocator.Dialogs.ShowAccounts();
        }

        public System.Drawing.Bitmap mailKeysButtonImage(Office.IRibbonControl control)
        {
            return global::Virgil.Mail.Properties.Resources.icon_512x512_2x;
        }

        #endregion
    }
}
