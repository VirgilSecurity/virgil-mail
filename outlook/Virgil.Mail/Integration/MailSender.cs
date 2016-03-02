namespace Virgil.Mail.Integration
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Threading.Tasks;
    using Newtonsoft.Json;
    using Virgil.Crypto;
    using Outlook = Microsoft.Office.Interop.Outlook;

    using Virgil.Mail.Common;
    using Virgil.Mail.Models;
    using Virgil.SDK.Infrastructure;

    public class MailSender : IMailSender
    {
        private readonly VirgilHub virgilHub;
        private readonly IDialogPresenter dialogs;
        private readonly IAccountsManager accountsManager;
        private readonly IPasswordExactor passwordExactor;
        private readonly IPrivateKeysStorage privateKeysStorage;

        public MailSender(
            VirgilHub virgilHub, 
            IDialogPresenter dialogs,
            IAccountsManager accountsManager,
            IPasswordExactor passwordExactor,
            IPrivateKeysStorage privateKeysStorage)
        {
            this.virgilHub = virgilHub;
            this.dialogs = dialogs;
            this.accountsManager = accountsManager;
            this.passwordExactor = passwordExactor;
            this.privateKeysStorage = privateKeysStorage;
        }

        public void EncryptAndSend(Outlook.MailItem mailItem)
        {
           var recipients = mailItem.Recipients
                .OfType<Outlook.Recipient>()
                .Select(it => it.Address)
                .Distinct()
                .ToList();

            var senderSmtpAddress = mailItem.ExtractSenderEmailAddress();
            recipients.Add(senderSmtpAddress);

            var tasks = recipients
                .Select(r => this.virgilHub.Cards.Search(r))
                .ToList();

            Task.WhenAll(tasks);

            var searchResults = tasks.Select(it => it.Result).ToList();
            var recipientsDictionary = new Dictionary<string, byte[]>();

            foreach (var recipient in recipients)
            {
                var searchResult = searchResults.SingleOrDefault(sr => sr.Any(c => c.Identity.Value.Equals(recipient)));
                var recipientCard = searchResult?.First();

                if (recipientCard != null)
                {
                    recipientsDictionary.Add(recipientCard.Id.ToString(), recipientCard.PublicKey.PublicKey);
                }
            }

            var password = this.passwordExactor.ExactOrAlarm(senderSmtpAddress);

            var account = this.accountsManager.GetAccount(senderSmtpAddress);
            var privateKey = this.privateKeysStorage.GetPrivateKey(account.VirgilCardId);

            mailItem.MessageClass = Constants.VirgilMessageClass;
            mailItem.HTMLBody = EncryptMail(mailItem, recipientsDictionary, privateKey, password);
        }

        private static string EncryptMail(Outlook._MailItem mail, IDictionary<string, byte[]> recipients, byte[] privateKey, string privateKeyPassword)
        {
            EncryptAttachments(mail, recipients);
            var encryptedMailData = EncryptMailData(mail, recipients);
            
            var signature = privateKeyPassword == null 
                ? CryptoHelper.Sign(encryptedMailData, privateKey)
                : CryptoHelper.Sign(encryptedMailData, privateKey, privateKeyPassword);

            var mailModel = new VirgilMailModel
            {
                EmailData = encryptedMailData,
                Sign = signature
            };

            var mailInfoJson = JsonConvert.SerializeObject(mailModel);
            var encodedInfo = Encoding.UTF8.GetBytes(mailInfoJson);

            return string.Format(Constants.EmailHtmlBodyTemplate, Convert.ToBase64String(encodedInfo));
        }

        private static byte[] EncryptMailData(Outlook._MailItem mail, IDictionary<string, byte[]> recipients)
        {
            var mailDataModel = new EncryptedMailModel
            {
                UniqueId = Guid.NewGuid().ToString(),
                Body = mail.Body,
                HtmlBody = mail.HTMLBody,
                Subject = mail.Subject
            };

            var mailData = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(mailDataModel));
            var encryptedMailData = CryptoHelper.Encrypt(mailData, recipients);
            return encryptedMailData;
        }

        private static void EncryptAttachments(Outlook._MailItem mail, IDictionary<string, byte[]> recipients)
        {
            var attachemnts = mail.Attachments.Cast<Outlook.Attachment>().ToList();
            foreach (var attachment in attachemnts)
            {
                var attachemntData = (byte[])attachment.PropertyAccessor.GetProperty(Constants.OutlookAttachmentDataBin);
                var encryptedAttachmentData = CryptoHelper.Encrypt(attachemntData, recipients);
                attachment.PropertyAccessor.SetProperty(Constants.OutlookAttachmentDataBin, encryptedAttachmentData);
            }
        }
    }
}