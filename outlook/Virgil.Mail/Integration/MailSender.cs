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
    using Virgil.Mail.Properties;
    using SDK;

    public class MailSender : IMailSender
    {
        private readonly IDialogPresenter dialog;
        private readonly IRecipientsService recipientsService;
        private readonly IAccountsManager accountsManager;
        private readonly IOutlookInteraction outlook;
        private readonly IPasswordExactor passwordExactor;

        public MailSender(
            IDialogPresenter dialog,
            IRecipientsService recipientsService,
            IAccountsManager accountsManager,
            IOutlookInteraction outlook,
            IPasswordExactor passwordExactor)
        {
            this.dialog = dialog;
            this.recipientsService = recipientsService;
            this.accountsManager = accountsManager;
            this.outlook = outlook;
            this.passwordExactor = passwordExactor;
        }

        public bool EncryptAndSend(Outlook.MailItem mailItem)
        {
           var identites = mailItem.Recipients
                .OfType<Outlook.Recipient>()
                .Select(it => it.Address)
                .ToList();

            var senderSmtpAddress = mailItem.ExtractSenderEmailAddress();
            identites.Add(senderSmtpAddress);

            identites = identites.Distinct().ToList();
            var searchedRecipients = this.recipientsService.Search(identites.ToArray())
                .Result.ToList();

            if (searchedRecipients.Any(it => !it.IsFound))
            {
                var invitationIdentities = searchedRecipients
                    .Where(it => !it.IsFound)
                    .Select(a => a.Identity)
                    .ToList();

                var accountsString = string.Join("\n", invitationIdentities);

                var result = this.dialog.ShowConfirmation(Resources.Caption_AccountsAreNotFoundSendInvitation, 
                    string.Format(Resources.Message_AccoutnsAreNotRegisteredSendInvitation, accountsString));

                if (result)
                {
                    this.SendInvitationEmails(senderSmtpAddress, invitationIdentities.ToArray());

                    var isAnyFound = searchedRecipients
                        .Where(it => !it.Identity.Equals(senderSmtpAddress, StringComparison.CurrentCultureIgnoreCase))
                        .Any(it => it.IsFound);

                    if (!isAnyFound)
                    {
                        return false;
                    }
                }
                else
                {
                    return false;
                }
            }

            var recipients = searchedRecipients
                .Where(it => it.IsFound)
                .Select(it => it.virgilCard).ToList();

            var account = this.accountsManager.GetAccount(senderSmtpAddress);

            string password = null;
            
            if (account.IsPrivateKeyHasPassword)
            {
                password = this.passwordExactor.ExactOrAlarm(senderSmtpAddress);
            }
            var virgilApi = new VirgilApi();
            var virgilKey = virgilApi.Keys.Load(account.VirgilCardId, password);

            mailItem.Save();
            EncryptMail(mailItem, recipients, virgilKey);
            mailItem.Save();

            mailItem.MessageClass = Constants.VirgilMessageClass;
            mailItem.HTMLBody = Constants.EmailHtmlBodyTemplate;

            return true;
        }

        private static void EncryptMail(Outlook._MailItem mail, List<VirgilCard> recipients, VirgilKey virgilKey)
        {
            EncryptAttachments(mail, recipients);

            var encryptedMailData = EncryptMailData(mail, recipients);

            var signature = virgilKey.Sign(encryptedMailData);
          

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

        private static VirgilBuffer EncryptMailData(Outlook._MailItem mail, List<VirgilCard> recipients)
        {
            var mailDataModel = new EncryptedMailModel
            {
                UniqueId = Guid.NewGuid().ToString(),
                Body = mail.Body,
                HtmlBody = mail.HTMLBody,
                Subject = mail.Subject
            };

            var mailData = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(mailDataModel));
            var encryptedMailData = recipients.Encrypt(mailData);
            return encryptedMailData;
        }

        private static void EncryptAttachments(Outlook._MailItem mail, List<VirgilCard> recipients)
        {
            var attachemnts = mail.Attachments
                .Cast<Outlook.Attachment>()
                .Where(a => a.DisplayName != Constants.VirgilAttachmentName)
                .ToList();


            foreach (var attachment in attachemnts)
            {
                var attachemntData = (byte[])attachment.PropertyAccessor.GetProperty(Constants.OutlookAttachmentDataBin);

                var encryptedAttachmentData = recipients.Encrypt(attachemntData);

                attachment.PropertyAccessor.SetProperty(Constants.OutlookAttachmentDataBin, encryptedAttachmentData);
            }
        }

        private void SendInvitationEmails(string senderSmtpAddress, string[] recipients)
        {
            foreach (var recipient in recipients)
            {
                 this.outlook.SendEmail(senderSmtpAddress, recipient, Resources.Email_Subject_Invitation, 
                     Resources.Email_Template_InvitationEmail, Outlook.OlImportance.olImportanceHigh);
            }
        }
    }
}