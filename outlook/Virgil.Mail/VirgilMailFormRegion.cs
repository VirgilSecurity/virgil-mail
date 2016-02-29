namespace Virgil.Mail
{
    using Microsoft.Office.Tools.Outlook;
    using Virgil.Mail.Common;
    using Virgil.Mail.Viewer;

    using Office = Microsoft.Office.Core;
    using Outlook = Microsoft.Office.Interop.Outlook;

    partial class VirgilMailFormRegion
    {
        private EncryptedMailViewModel viewModel;
        
        #region Form Region Factory

        [Microsoft.Office.Tools.Outlook.FormRegionMessageClass(Constants.VirgilMessageClass)]
        [Microsoft.Office.Tools.Outlook.FormRegionName(Constants.VirgilMailFormRegionName)]
        public partial class VirgilMailFormRegionFactory
        {
            // Occurs before the form region is initialized.
            // To prevent the form region from appearing, set e.Cancel to true.
            // Use e.OutlookItem to get a reference to the current Outlook item.
            private void VirgilMailFormRegionFactory_FormRegionInitializing(object sender, FormRegionInitializingEventArgs e)
            {
            }
        }

        #endregion
        
        private void VirgilMailFormRegion_FormRegionShowing(object sender, System.EventArgs e)
        {
            var mail = this.OutlookItem as Outlook.MailItem;
            if (mail == null)
            {
                return;
            }

            if (this.viewModel == null)
            {
                var view = ServiceLocator.ViewBuilder.Build<EncryptedMailView, EncryptedMailViewModel>();
                this.viewModel = (EncryptedMailViewModel) view.DataContext;

                this.mailViewerHost.Child = view;
            }

            this.viewModel.Initialize(mail);
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
