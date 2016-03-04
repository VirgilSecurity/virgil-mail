namespace Virgil.Mail
{
    using System;

    using Virgil.Mail.Common;
    using Virgil.Mail.Viewer;
    using Virgil.Mail.Integration;

    using Tools = Microsoft.Office.Tools.Outlook;
    using Outlook = Microsoft.Office.Interop.Outlook;

    partial class VirgilMailFormRegion
    {
        private EncryptedMailViewModel viewModel;

        private Outlook.MailItem CurrentMail => (Outlook.MailItem)this.OutlookItem;

        private void MailEventsOnForward(object forward, ref bool cancel)
        {
        }

        private void MailEventsOnReplyAll(object response, ref bool cancel)
        {
        }

        /// <summary>
        /// Occurs when Reply action has been triggered for this mail.
        /// </summary>
        private void MailEventsOnReply(object response, ref bool cancel)
        {
            if (!ServiceLocator.Accounts.IsRegistered(this.CurrentMail.ExtractReciverEmailAddress()))
            {
                ServiceLocator.Dialogs.ShowAlert("You can't reply this email because your account is not registered.");
                cancel = true;

                return;
            }

            cancel = true;

            this.CurrentMail.HTMLBody = this.viewModel.Body;

            var replyAllMail = this.CurrentMail.Reply();

            this.CurrentMail.Close(Outlook.OlInspectorClose.olDiscard);
            this.CurrentMail.ReleaseCom();

            replyAllMail.MessageClass = Constants.VirgilMessageClass;
            replyAllMail.Display(true);
            replyAllMail.ReleaseCom();
        }

        /// <summary>
        /// Occures before the control becomes visible for the first time.
        /// </summary>
        private void VirgilMailFormRegion_FormRegionLoad(object sender, EventArgs e)
        {
            var mail = this.OutlookItem as Outlook.MailItem;
            if (mail == null)
            {
                throw new Exception("This form region can show only MailItem object");
            }
            
            var view = ServiceLocator.ViewBuilder.Build<EncryptedMailView, EncryptedMailViewModel>();
            this.viewModel = (EncryptedMailViewModel)view.DataContext;

            this.mailViewerHost.Child = view;

            // initialize view model with mail's account

            //var accountSmtpAddress = mail.ExtractReciverEmailAddress();
            //this.account = ServiceLocator.Accounts.GetAccount(accountSmtpAddress);

            this.viewModel.Initialize(mail);
        }

        /// <summary>
        /// Occurs when the form region is ready to be shown.
        /// </summary>
        private void VirgilMailFormRegion_FormRegionShowing(object sender, EventArgs e)
        {
            // cast to interface that represents Outlook Item events to be able to 
            // subscribe to bunch of events.

            var mailEvents = (Outlook.ItemEvents_Event)this.OutlookItem;

            mailEvents.Reply    += this.MailEventsOnReply;
            mailEvents.ReplyAll += this.MailEventsOnReplyAll;
            mailEvents.Forward  += this.MailEventsOnForward;
        }

        /// <summary>
        /// Occurs when the form region is closed.
        /// </summary>
        private void VirgilMailFormRegion_FormRegionClosed(object sender, EventArgs e)
        {
            // Use this.OutlookItem to get a reference to the current Outlook item.
            // Use this.OutlookFormRegion to get a reference to the form region.

            var mailEvents = (Outlook.ItemEvents_Event)this.OutlookItem;

            mailEvents.Reply    -= this.MailEventsOnReply;
            mailEvents.ReplyAll -= this.MailEventsOnReplyAll;
            mailEvents.Forward  -= this.MailEventsOnForward;

            this.viewModel = null;
        }

        #region Form Region Factory

        [Microsoft.Office.Tools.Outlook.FormRegionMessageClass(Constants.VirgilMessageClass)]
        [Microsoft.Office.Tools.Outlook.FormRegionName(Constants.VirgilMailFormRegionName)]
        public partial class VirgilMailFormRegionFactory
        {
            // Occurs before the form region is initialized.
            // To prevent the form region from appearing, set e.Cancel to true.
            // Use e.OutlookItem to get a reference to the current Outlook item.
            private void VirgilMailFormRegionFactory_FormRegionInitializing(object sender, Tools.FormRegionInitializingEventArgs e)
            {
            }
        }

        #endregion
    }
}
