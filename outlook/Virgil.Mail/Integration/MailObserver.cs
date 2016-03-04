﻿namespace Virgil.Mail.Integration
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

        public async Task<OutlookMailModel> WaitFor(string accountSmtpAddress, string from)
        {
            Outlook.NameSpace nameSpace = this.application.GetNamespace("MAPI");

            try
            {
                nameSpace.SendAndReceive(false);
                var attempts = 0;

                while (attempts <= 40)
                {
                    attempts++;

                    await Task.Delay(1000);

                    var inbox = this.application.Session.Folders[accountSmtpAddress]
                        .Store.GetDefaultFolder(Outlook.OlDefaultFolders.olFolderInbox);

                    Outlook.Items unreadItems = inbox.Items.Restrict("[Unread]=true");

                    foreach (var unreadItem in unreadItems)
                    {
                        Outlook.MailItem mail = unreadItem as Outlook.MailItem;
                        if (mail != null && mail.SenderEmailAddress.Equals(from, StringComparison.CurrentCultureIgnoreCase))
                        {
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

                return null;
            }
            finally
            {
                nameSpace.ReleaseCom();
            }
        }
    }
}