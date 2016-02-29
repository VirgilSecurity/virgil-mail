using System.Linq;

namespace Virgil.Mail.Viewer
{
    using System;
    using System.Text;
    using System.Windows.Input;
    using System.Windows.Controls;
    using HtmlAgilityPack;

    using Newtonsoft.Json;

    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Mvvm;
    using Virgil.Mail.Integration;
    using Virgil.Mail.Models;
    using Virgil.Mail.Mvvm;
    using Virgil.Crypto;
    using Virgil.Mail.Common.Exceptions;

    using Outlook = Microsoft.Office.Interop.Outlook;

    public class EncryptedMailViewModel : ViewModel
    {
        private readonly IPrivateKeysStorage privateKeysStorage;
        private readonly IAccountsManager accountsManager;
        private readonly IDialogPresenter dialogPresenter;
        private readonly IPasswordHolder passwordHolder;

        private string body;
        private Outlook.MailItem mailItem;
        private AccountModel account;
        private string @from;
        private DateTime date;
        private string to;
        private string subject;

        public EncryptedMailViewModel(
            IPrivateKeysStorage privateKeysStorage, 
            IAccountsManager accountsManager,
            IDialogPresenter dialogPresenter,
            IPasswordHolder passwordHolder)
        {
            this.privateKeysStorage = privateKeysStorage;
            this.accountsManager = accountsManager;
            this.dialogPresenter = dialogPresenter;
            this.passwordHolder = passwordHolder;

            this.DecryptCommand = new RelayCommand(this.Decrypt);
            this.RegisterCommand = new RelayCommand(this.Register);
            this.RedecryptCommand = new RelayCommand(this.Redecrypt);
        }
        

        public ICommand RegisterCommand { get; set; }
        public ICommand DecryptCommand { get; set; }
        public ICommand RedecryptCommand { get; set; }

        public string Subject
        {
            get { return subject; }
            set
            {
                subject = value;
                this.RaisePropertyChanged();
            }
        }

        public string Body
        {
            get { return this.body; }
            set
            {
                this.body = value;
                this.RaisePropertyChanged();
            }
        }

        public string From
        {
            get { return @from; }
            set
            {
                @from = value;
                this.RaisePropertyChanged();
            }
        }

        public DateTime Date
        {
            get { return date; }
            set
            {
                date = value;
                this.RaisePropertyChanged();
            }
        }

        public string To
        {
            get { return to; }
            set
            {
                to = value;
                this.RaisePropertyChanged();
            }
        }

        public void Initialize(Outlook.MailItem mail)
        {
            this.mailItem = mail;

            var reciverEmailAddress = mail.ExtractReciverEmailAddress();
            this.account = this.accountsManager.GetAccount(reciverEmailAddress);
            
            if (!this.account.IsRegistered)
            {
                this.ChangeState(EncryptedMailState.NotRegistered);
                return;
            }

            var privateKey = this.privateKeysStorage.GetPrivateKey(account.VirgilCardId);
            var isKeyEncrypted = VirgilKeyPair.IsPrivateKeyEncrypted(privateKey);

            if (isKeyEncrypted && !this.account.IsPrivateKeyPasswordNeedToStore)
            {
                this.ChangeState(EncryptedMailState.WaitPassword);
                return;
            }

            string keyPassword = null; 
            if (isKeyEncrypted)
            {
                try
                {
                    keyPassword = this.passwordHolder.Get(this.account.OutlookAccountEmail);
                }
                catch (PrivateKeyPasswordIsNotFoundException)
                {
                    this.ChangeState(EncryptedMailState.WaitPassword);
                    return;
                }
            }

            InternalDecrypt(keyPassword);
        }

        private void Register()
        {
            this.dialogPresenter.ShowRegisterAccount(this.account);
            this.Initialize(this.mailItem);
        }

        private void Redecrypt()
        {
            this.Initialize(this.mailItem);
        }

        private void Decrypt(object parameter)
        {
            var passwordBox = (PasswordBox)parameter;
            var password = passwordBox.Password;

            var privateKey = this.privateKeysStorage.GetPrivateKey(account.VirgilCardId);
            if (this.account.IsPrivateKeyPasswordNeedToStore)
            {
                this.passwordHolder.Keep(this.account.OutlookAccountEmail, password);
            }

            var passwordBytes = Encoding.UTF8.GetBytes(password);
            var isMatch = VirgilKeyPair.CheckPrivateKeyPassword(privateKey, passwordBytes);
            if (!isMatch)
            {
                passwordBox.Clear();
                return;
            }

            this.InternalDecrypt(password);
        }

        private void InternalDecrypt(string keyPassword)
        {
            try
            {
                var privateKey = this.privateKeysStorage.GetPrivateKey(this.account.VirgilCardId);

                var mailData = DecryptMailData(this.mailItem,
                    this.account.VirgilCardId, privateKey, keyPassword);

                this.Subject = mailData.Subject;
                this.Body = mailData.HtmlBody;
                this.From = this.mailItem.ExtractSenderEmailAddress();
                this.To = string.Join("; ", this.mailItem.Recipients
                    .Cast<Outlook.Recipient>().Select(it => it.Address));

                this.Date = this.mailItem.CreationTime;

                this.ChangeState(EncryptedMailState.ReadMail);
            }
            catch (Exception)
            {
                this.ChangeState(EncryptedMailState.EncryptionFailed);
            }
        }

        private static EncryptedMailModel DecryptMailData(Outlook._MailItem mail, Guid cardId, byte[] privateKey, string keyPassword)
        {
            var mailModel = ExtractVirgilMailModel(mail);
            var data = mailModel.EmailData;

            using (var crypto = new VirgilCipher())
            {
                var cardIdBytes = Encoding.UTF8.GetBytes(cardId.ToString());

                var decryptedData = keyPassword == null
                    ? crypto.DecryptWithKey(data, cardIdBytes, privateKey)
                    : crypto.DecryptWithKey(data, cardIdBytes, privateKey, Encoding.UTF8.GetBytes(keyPassword));

                var attachmentData = Encoding.UTF8.GetString(decryptedData);
                var mailData = JsonConvert.DeserializeObject<EncryptedMailModel>(attachmentData);

                return mailData;
            }
        }

        private static VirgilMailModel ExtractVirgilMailModel(Outlook._MailItem mail)
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
    }
}