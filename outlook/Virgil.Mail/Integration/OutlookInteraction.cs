namespace Virgil.Mail.Integration
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Runtime.InteropServices;

    using Outlook = Microsoft.Office.Interop.Outlook;
    
    using Virgil.Mail.Common;

    internal class OutlookInteraction : IOutlookInteraction
    {
        private readonly Outlook.Application application;

        public OutlookInteraction(Outlook.Application application)
        {
            this.application = application;
        }

        public void MarkMailAsRead(string mailId)
        {
            Outlook.NameSpace nameSpace = this.application.GetNamespace("MAPI");
            Outlook.MailItem mail = (Outlook.MailItem)nameSpace.GetItemFromID(mailId);
            
            mail.UnRead = false;
            mail.Save();

            nameSpace.ReleaseCom();
            mail.ReleaseCom();
        }

        public void DeleteMail(string mailId)
        {
            Outlook.NameSpace nameSpace = this.application.GetNamespace("MAPI");
            Outlook.MailItem mail = (Outlook.MailItem)nameSpace.GetItemFromID(mailId);

            mail.Delete();

            nameSpace.ReleaseCom();
            mail.ReleaseCom();
        }

        public void DeleteAttachment(Outlook.MailItem mail, string attachmentName)
        {
            var attachemnt = mail.Attachments.Cast<Outlook.Attachment>()
                .SingleOrDefault(a => a.FileName.Equals(attachmentName,StringComparison.CurrentCultureIgnoreCase));

            attachemnt?.Delete();
        }

        public void UnJunkMailById(string mailId)
        {
            Outlook.NameSpace nameSpace = this.application.GetNamespace("MAPI");
            Outlook.MailItem mail = (Outlook.MailItem)nameSpace.GetItemFromID(mailId);

            var accountSmtpAddress =  mail.ExtractReciverEmailAddress();

            var inbox = this.application.Session.Folders[accountSmtpAddress]
                        .Store.GetDefaultFolder(Outlook.OlDefaultFolders.olFolderInbox);

            mail.UnRead = true;
            mail.Move(inbox);
        }

        public void SendEmail(string emailTo, string subject, string body, Outlook.OlImportance importance = Outlook.OlImportance.olImportanceNormal)
        {
            Outlook.MailItem mailItem = (Outlook.MailItem)this.application.CreateItem(Outlook.OlItemType.olMailItem);
            mailItem.Subject = subject;
            mailItem.To = emailTo;
            mailItem.HTMLBody = body;
            mailItem.Importance = Outlook.OlImportance.olImportanceHigh;
            mailItem.Send();

            mailItem.ReleaseCom();
        }

        public IEnumerable<AccountIntegrationModel> GetOutlookAccounts()
        {
            Outlook.NameSpace ns = null;
            Outlook.Accounts accounts = null;
            Outlook.Account account = null;
            
            var result = new List<AccountIntegrationModel>();

            try
            {
                ns = this.application.Session;
                accounts = ns.Accounts;
                for (int i = 1; i <= accounts.Count; i++)
                {
                    account = accounts[i];

                    if (result.All(it => it.Email != account.SmtpAddress))
                    {
                        result.Add(new AccountIntegrationModel
                        {
                            Email = account.SmtpAddress,
                            Description = account.UserName
                        });
                    }

                    if (account != null)
                        Marshal.ReleaseComObject(account);
                }

                return result;
            }
            finally
            {
                accounts.ReleaseCom();
                account.ReleaseCom();
                ns.ReleaseCom();
            }
        }
    }
}
