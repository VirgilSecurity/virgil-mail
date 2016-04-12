namespace Virgil.Mail
{
    using System;

    using Microsoft.Office.Tools.Ribbon;
    using Virgil.Mail.Accounts;
    using Virgil.Mail.Common;

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
            ServiceLocator.Dialogs.ShowDialog<AccountsViewModel>();
            // ServiceLocator.Dialogs.ShowAccounts();
        }

        private void ExceptionHandler(Exception exception)
        {
        }
    }
}
