namespace Virgil.Mail.Integration
{
    using System;
    using System.Threading;
    using System.Threading.Tasks;

    using Virgil.Mail.Common;
    using Virgil.Mail.Models;

    using Outlook = Microsoft.Office.Interop.Outlook;

    public class MailObserver : IMailObserver
    {
        private readonly Outlook.Application application;
        

        public MailObserver(Outlook.Application application)
        {
            this.application = application;
        }

        public async Task<OutlookMailModel> WaitFor(string accountSmtpAddress, string from, CancellationToken cancellationToken)
        {
            cancellationToken.ThrowIfCancellationRequested();
            Outlook.NameSpace nameSpace = this.application.GetNamespace("MAPI");

            try
            {
                var inbox = this.application.Session.Folders[accountSmtpAddress]
                    .Store.GetDefaultFolder(Outlook.OlDefaultFolders.olFolderInbox);

                var junk = this.application.Session.Folders[accountSmtpAddress]
                        .Store.GetDefaultFolder(Outlook.OlDefaultFolders.olFolderJunk);

                inbox.InAppFolderSyncObject = true;
                junk.InAppFolderSyncObject = true;

                nameSpace.SyncObjects.AppFolders.Start();
                                
                var attempts = 0;

                while (attempts <= 240)
                {
                    attempts++;

                    await Task.Delay(1000);

                    cancellationToken.ThrowIfCancellationRequested();

                    Outlook.Items unreadItems = inbox.Items.Restrict("[Unread]=true");

                    foreach (var unreadItem in unreadItems)
                    {
                        var itemModel = ExtractIsMatch(@from, unreadItem);
                        if (itemModel != null)
                        {
                            return itemModel;
                        }
                    }

                    Outlook.Items junkItems = junk.Items; //.Restrict("[Unread]=true");
                    foreach (var unreadItem in junkItems)
                    {
                        var itemModel = ExtractIsMatch(@from, unreadItem);
                        if (itemModel != null)
                        {
                            itemModel.IsJunk = true;
                            return itemModel;
                        }
                    }
                }

                return null;
            }
            finally
            {
                nameSpace.SyncObjects.AppFolders.Stop();
                nameSpace.ReleaseCom();
            }
        }
        
        private static OutlookMailModel ExtractIsMatch(string @from, object unreadItem)
        {
            Outlook.MailItem mail = unreadItem as Outlook.MailItem;
            if (mail == null || !mail.SenderEmailAddress.Equals(@from, StringComparison.CurrentCultureIgnoreCase))
            {
                return null;
            }

            var mailModel = new OutlookMailModel
            {
                EntryID = mail.EntryID,
                From = mail.SenderEmailAddress,
                Body = mail.HTMLBody
            };

            mail.ReleaseCom();
            return mailModel;
        }


    }
}