namespace Virgil.Mail
{
    using System;
    using System.Diagnostics;
    using System.Windows;

    //using KeyRing.Domain.Exceptions;

    using Microsoft.Office.Tools.Ribbon;
    //using VirgilOutlook.Services;

    public partial class VirgilMailRibbon
    {
        private void VirgilOutlookRibbon_Load(object sender, RibbonUIEventArgs e)
        {
            this.encryptButton.Checked = Properties.Settings.Default.AutoEncryptEmails;
        }

        private void encryptButton_Click(object sender, RibbonControlEventArgs e)
        {
            Properties.Settings.Default.AutoEncryptEmails = this.encryptButton.Checked;
            Properties.Settings.Default.Save();
        }
        
        private void mailKeysButton_Click(object sender, RibbonControlEventArgs e)
        {
            try
            {
                //ServiceBus.InterProcess.PromptManageKeys();
            }
            catch (Exception ex)
            {
                this.ExceptionHandler(ex);
            }
        }

        private void ExceptionHandler(Exception exception)
        {
            //try
            //{
            //    throw exception;
            //}
            //catch (KeyRingIsNotAvailableException)
            //{
            //    try
            //    {
            //        ServiceBus.InterProcess.TryStartControlPanel();
            //    }
            //    catch (Exception ex)
            //    {
            //        this.ExceptionHandler(ex);
            //    }
            //}
            //catch (KeyRingIsNotInstalledException)
            //{
            //    if (MessageBox.Show(Localization.MessageKeyRingControlPanelIsNotInstalled, "Error", MessageBoxButton.YesNo) == MessageBoxResult.Yes)
            //    {
            //        try
            //        {
            //            Process.Start("https://virgilsecurity.com/downloads");
            //        }
            //        catch (Exception ex)
            //        {
            //            this.ExceptionHandler(ex);
            //        }
            //    }
            //}
            //catch (Exception ex)
            //{
            //    //MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK);
            //}
        }
    }
}
