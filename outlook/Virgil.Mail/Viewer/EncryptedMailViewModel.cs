namespace Virgil.Mail.Viewer
{
    using System;
    using System.Linq;
    using System.Text;
    using System.Windows.Input;
    using System.Windows.Controls;

    using log4net;

    using Newtonsoft.Json;
    
    using Virgil.Crypto;

    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Mvvm;
    using Virgil.Mail.Common.Exceptions;
    using Virgil.Mail.Integration;
    using Virgil.Mail.Models;
    using Virgil.Mail.Mvvm;

    using Outlook = Microsoft.Office.Interop.Outlook;

    public class EncryptedMailViewModel : ViewModel
    {
        private static readonly ILog Logger = LogManager.GetLogger(typeof (EncryptedMailViewModel));

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
        private bool isStorePassword;

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

        public bool IsStorePassword
        {
            get { return this.isStorePassword; }
            set
            {
                this.isStorePassword = value;
                this.RaisePropertyChanged();
            }
        }

        public string Subject
        {
            get { return this.subject; }
            set
            {
                this.subject = value;
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
            get { return this.@from; }
            set
            {
                this.@from = value;
                this.RaisePropertyChanged();
            }
        }

        public DateTime Date
        {
            get { return this.date; }
            set
            {
                this.date = value;
                this.RaisePropertyChanged();
            }
        }

        public string To
        {
            get { return this.to; }
            set
            {
                this.to = value;
                this.RaisePropertyChanged();
            }
        }

        public void Initialize(Outlook.MailItem mail)
        {
            this.mailItem = mail;

            var senderEmailAddress = mail.ExtractSenderEmailAddress();
            var reciverEmailAddress = mail.ExtractReciverEmailAddress();
            
            Logger.InfoFormat("Start loading encrypted mail - From: {0}, To: {1}, Subject: '{2}'", 
                senderEmailAddress, reciverEmailAddress, this.mailItem.Subject);
            
            this.account = this.accountsManager.GetAccount(reciverEmailAddress);
            
            if (!this.account.IsRegistered)
            {
                Logger.InfoFormat("The mail decryption is stoped becuase of accoout '{0}' private key is not registered", reciverEmailAddress);

                this.ChangeState(EncryptedMailState.NotRegistered);
                return;
            }
            
            var privateKey = this.privateKeysStorage.GetPrivateKey(this.account.VirgilCardId);
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

            this.InternalDecrypt(keyPassword);
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

            var privateKey = this.privateKeysStorage.GetPrivateKey(this.account.VirgilCardId);

            if (this.IsStorePassword && !this.account.IsPrivateKeyPasswordNeedToStore)
            {
                this.account.IsPrivateKeyPasswordNeedToStore = true;
                this.passwordHolder.Keep(this.account.OutlookAccountEmail, password);
                this.accountsManager.UpdateAccount(this.account);
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

                Logger.InfoFormat("Decrypt mail with account's '{0}' private key.", this.account.OutlookAccountEmail);

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
            catch (Exception ex)
            {
                Logger.ErrorFormat("Error occured on mail decryption: {0}\nStackTrace:\n{1}", ex.Message, ex.StackTrace);
                this.ChangeState(EncryptedMailState.EncryptionFailed);
            }
        }

        private static EncryptedMailModel DecryptMailData(Outlook.MailItem mail, Guid cardId, byte[] privateKey, string keyPassword)
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
        
        private static VirgilMailModel ExtractVirgilMailModel(Outlook.MailItem mail)
        {
            var attachment = mail.Attachments.Cast<Outlook.Attachment>()
                .SingleOrDefault(it => it.FileName == Constants.VirgilAttachmentName);

            VirgilMailModel virgilMail;

            if (attachment == null)
            {
                virgilMail = mail.Parse();
                return virgilMail;
            }

            var attachmentBytes = (byte[])attachment.PropertyAccessor.GetProperty(Constants.OutlookAttachmentDataBin);
            var attachmentBase64 = Encoding.UTF8.GetString(attachmentBytes);
            var attachmentJsonBytes = Convert.FromBase64String(attachmentBase64);
            var attachmentJson = Encoding.UTF8.GetString(attachmentJsonBytes);

            virgilMail = JsonConvert.DeserializeObject<VirgilMailModel>(attachmentJson);

            return virgilMail;
        }
    }
}