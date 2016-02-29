namespace Virgil.Mail.Viewer
{
    using System;
    using System.Text;
    using System.Windows.Input;
    using HtmlAgilityPack;

    using Newtonsoft.Json;

    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Mvvm;
    using Virgil.Mail.Integration;
    using Virgil.Mail.Models;
    using Virgil.Mail.Mvvm;

    using Outlook = Microsoft.Office.Interop.Outlook;

    public class EncryptedMailViewModel : ViewModel
    {
        private readonly IPrivateKeysStorage privateKeysStorage;
        private readonly IAccountsManager accountsManager;

        private string body;

        public EncryptedMailViewModel(
            IPrivateKeysStorage privateKeysStorage, 
            IAccountsManager accountsManager)
        {
            this.privateKeysStorage = privateKeysStorage;
            this.accountsManager = accountsManager;

            this.DecryptCommand = new RelayCommand(this.Decrypt);
        }
        
        public ICommand DecryptCommand { get; set; }

        public string Body
        {
            get { return this.body; }
            set
            {
                this.body = value;
                this.RaisePropertyChanged();
            }
        }

        public void MailChanged(Outlook.MailItem mail)
        {
            this.ChangeState(EncryptedMailStatus.Processing);
            
            var reciverEmailAddress = mail.ExtractReciverEmailAddress();
            var account = this.accountsManager.GetAccount(reciverEmailAddress);
            
            var privateKey = this.privateKeysStorage.GetPrivateKey(account.VirgilCardId);

            if (Crypto.VirgilKeyPair.IsPrivateKeyEncrypted(privateKey))
            {
                this.ChangeState(EncryptedMailStatus.WaitPassword);
                return;
            }

            var decryptedMail = this.DecryptMailData(mail, account.VirgilCardId, privateKey);

            this.ChangeState(EncryptedMailStatus.ReadMail);

            this.Body = decryptedMail.HtmlBody;
        }

        public EncryptedMailModel DecryptMailData(Outlook.MailItem mail, Guid cardId, byte[] privateKey)
        {
            var mailModel = this.ExtractVirgilMailModel(mail);
            var data = mailModel.EmailData;

            var decryptedData = Crypto.CryptoHelper.Decrypt(data, cardId.ToString(), privateKey);
            var attachmentData = Encoding.UTF8.GetString(decryptedData);

            var mailData = JsonConvert.DeserializeObject<EncryptedMailModel>(attachmentData);

            return mailData;
        }

        private VirgilMailModel ExtractVirgilMailModel(Outlook._MailItem mail)
        {
            var htmlDoc = new HtmlDocument();
            htmlDoc.LoadHtml(mail.HTMLBody);

            var virgilElem = htmlDoc.GetElementbyId("virgil-info");
            var valueBase64 = virgilElem?.GetAttributeValue("value", "");

            if (!string.IsNullOrWhiteSpace(valueBase64))
            {
                var value = Convert.FromBase64String(valueBase64);
                var json = Encoding.UTF8.GetString(value);
                var messageInfo = JsonConvert.DeserializeObject<VirgilMailModel>(json);

                return messageInfo;
            }

            return null;
        }

        private void Decrypt()
        {

        }
    }
}