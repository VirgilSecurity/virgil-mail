namespace Virgil.Mail
{
    //using Virgil.Mail.Presentation.Mail;

    using Office = Microsoft.Office.Core;
    using Outlook = Microsoft.Office.Interop.Outlook;

    partial class VirgilMailFormRegion
    {
        //private MailViewModel viewModel;

        #region Form Region Factory

        [Microsoft.Office.Tools.Outlook.FormRegionMessageClass("IPM.Note.VirgilMail")]
        [Microsoft.Office.Tools.Outlook.FormRegionName("VirgilOutlook.VirgilMailFormRegion")]
        public partial class VirgilMailFormRegionFactory
        {
            // Occurs before the form region is initialized.
            // To prevent the form region from appearing, set e.Cancel to true.
            // Use e.OutlookItem to get a reference to the current Outlook item.
            private void VirgilMailFormRegionFactory_FormRegionInitializing(object sender, Microsoft.Office.Tools.Outlook.FormRegionInitializingEventArgs e)
            {
            }
        }

        #endregion
        
        // Occurs before the form region is displayed.
        // Use this.OutlookItem to get a reference to the current Outlook item.
        // Use this.OutlookFormRegion to get a reference to the form region.
        private void VirgilMailFormRegion_FormRegionShowing(object sender, System.EventArgs e)
        {
            var mail = this.OutlookItem as Outlook.MailItem;
            if (mail == null)
            {
                return;
            }
            
            //this.viewModel = new MailViewModel(ref mail);
            //this.mailViewer.DataContext = this.viewModel;
        }
        // Occurs when the form region is closed.
        // Use this.OutlookItem to get a reference to the current Outlook item.
        // Use this.OutlookFormRegion to get a reference to the form region.
        private void VirgilMailFormRegion_FormRegionClosed(object sender, System.EventArgs e)
        {
            //this.viewModel.Release();
        }
    }
}
