namespace Virgil.Mail.Integration
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using System.Text;

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
                .ToList();

            var senderSmtpAddress = mailItem.ExtractSenderEmailAddress();
            recipients.Add(senderSmtpAddress);

            recipients = recipients.Distinct().ToList();


            var tasks = recipients
                .Select(r => this.virgilHub.Cards.Search(r))
                .ToList();
            
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
            
            EncryptMail(mailItem, recipientsDictionary, privateKey, password);

            mailItem.MessageClass = Constants.VirgilMessageClass;
            mailItem.HTMLBody = Constants.EmailHtmlBodyTemplate;
        }

        private static void EncryptMail(Outlook._MailItem mail, IDictionary<string, byte[]> recipients, byte[] privateKey, string privateKeyPassword)
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
            
            AddEncryptedBodyAttachment(mail, mailModel);
        }

        private static void AddEncryptedBodyAttachment(Outlook._MailItem mail, VirgilMailModel mailData)
        {
            var mailInfoJson = JsonConvert.SerializeObject(mailData);
            var encodedInfo  = Encoding.UTF8.GetBytes(mailInfoJson);
            var base64String = Convert.ToBase64String(encodedInfo);

            File.WriteAllText(Constants.VirgilAttachmentName, base64String);

            mail.Attachments.Add(Constants.VirgilAttachmentName, Outlook.OlAttachmentType.olByValue);

            File.Delete(Constants.VirgilAttachmentName);
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