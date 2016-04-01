namespace Virgil.Mail.Viewer
{
    using System;
    using System.Collections.ObjectModel;
    using System.IO;
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
    using Virgil.Mail.Properties;

    using Outlook = Microsoft.Office.Interop.Outlook;

    public class EncryptedMailViewModel : ViewModel
    {
        private static readonly ILog Logger = LogManager.GetLogger(typeof (EncryptedMailViewModel));

        private readonly IPrivateKeysStorage privateKeysStorage;
        private readonly IAccountsManager accountsManager;
        private readonly IDialogPresenter dialogPresenter;
        private readonly IPasswordExactor passwordExactor;
        private readonly IPasswordHolder passwordHolder;

        private string body;
        private Outlook.MailItem mailItem;
        private AccountModel account;
        private string @from;
        private DateTime date;
        private string to;
        private string subject;
        private bool isStorePassword;
        private ObservableCollection<EncryptedAttachmentViewModel> attachments;

        public EncryptedMailViewModel(
            IPrivateKeysStorage privateKeysStorage, 
            IAccountsManager accountsManager,
            IDialogPresenter dialogPresenter,
            IPasswordExactor passwordExactor,
            IPasswordHolder passwordHolder)
        {
            this.privateKeysStorage = privateKeysStorage;
            this.accountsManager = accountsManager;
            this.dialogPresenter = dialogPresenter;
            this.passwordExactor = passwordExactor;
            this.passwordHolder = passwordHolder;

            this.DecryptCommand = new RelayCommand(this.Decrypt);
            this.RegisterCommand = new RelayCommand(this.Register);
            this.RedecryptCommand = new RelayCommand(this.Redecrypt);
            this.DecryptAttachmentCommand = new RelayCommand<EncryptedAttachmentViewModel>(this.DecryptAttachment);

            this.attachments = new ObservableCollection<EncryptedAttachmentViewModel>();
        }
        
        public ICommand RegisterCommand { get; set; }
        public ICommand DecryptCommand { get; set; }
        public ICommand DecryptAttachmentCommand { get; set; }
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

        public bool HasAttachments => this.attachments.Any();

        public ObservableCollection<EncryptedAttachmentViewModel> Attachments
        {
            get { return this.attachments; }
            set
            {
                this.attachments = value;
                this.RaisePropertyChanged();
            }
        }

        public void Initialize(Outlook.MailItem mail)
        {
            try
            {
                this.mailItem = mail;

                var senderEmailAddress = mail.ExtractSenderEmailAddress();
                var reciverEmailAddress = mail.ExtractReciverEmailAddress();
            
                Logger.InfoFormat(Resources.Log_Info_EncryptedMailViewModel_StartLoadingEmail, 
                    senderEmailAddress, reciverEmailAddress, this.mailItem.Subject);
            
                this.account = this.accountsManager.GetAccount(reciverEmailAddress);
            
                if (!this.account.IsRegistered)
                {
                    Logger.InfoFormat(Resources.Log_Info_EncryptedMailViewModel_DecryptMailCanceledBecauseOfRegistration, reciverEmailAddress);

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

                this.ParseAttachemnts();
                this.InternalDecrypt(keyPassword);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occured: {0}\nStackTrace: {1}", ex.Message, ex.StackTrace);
            }
        }

        private void ParseAttachemnts()
        {
            this.Attachments.Clear();

            var mailAttachments = this.mailItem.Attachments
                .Cast<Outlook.Attachment>()
                .Where(it => it.DisplayName != Constants.VirgilAttachmentName)
                .ToList();

            foreach (var attachment in mailAttachments)
            {
                var attachmentModel = new EncryptedAttachmentViewModel(attachment.DisplayName, attachment.FileName);
                this.Attachments.Add(attachmentModel);
            }

            this.RaisePropertyChanged(@"HasAttachments");
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
            
            var passwordBytes = Encoding.UTF8.GetBytes(password);
            var isMatch = VirgilKeyPair.CheckPrivateKeyPassword(privateKey, passwordBytes);
            if (!isMatch)
            {
                this.ClearErrors();

                passwordBox.Clear();
                this.AddCustomError(Resources.Error_IncorrectPrivateKeyPassword);
                return;
            }
            
            if (this.IsStorePassword && !this.account.IsPrivateKeyPasswordNeedToStore)
            {
                this.account.IsPrivateKeyPasswordNeedToStore = true;
                this.passwordHolder.Keep(this.account.OutlookAccountEmail, password);
                this.accountsManager.UpdateAccount(this.account);
            }

            this.InternalDecrypt(password);
        }

        private void DecryptAttachment(EncryptedAttachmentViewModel attachmentModel)
        {
            var privateKey = this.privateKeysStorage.GetPrivateKey(this.account.VirgilCardId);
            var privateKeyPassword = this.passwordExactor.ExactOrAlarm(this.account.OutlookAccountEmail);

            var attachment = this.mailItem.Attachments
                .Cast<Outlook.Attachment>()
                .Single(it => it.FileName == attachmentModel.FileName);

            var encryptedAttachmentData = (byte[])attachment.PropertyAccessor.GetProperty(Constants.OutlookAttachmentDataBin);

            var decryptedData = CryptoHelper.Decrypt(encryptedAttachmentData, 
                this.account.VirgilCardId.ToString(), privateKey, privateKeyPassword);

            this.dialogPresenter.SaveFile(Path.GetFileNameWithoutExtension(attachmentModel.FileName), 
                decryptedData, Path.GetExtension(attachmentModel.FileName));
        }
        
        private void InternalDecrypt(string keyPassword)
        {
            try
            {
                this.ParseAttachemnts();

                var privateKey = this.privateKeysStorage.GetPrivateKey(this.account.VirgilCardId);

                Logger.InfoFormat(Resources.Log_Info_EncryptedMailViewModel_DecryptMailWithAccountPrivateKey, this.account.OutlookAccountEmail);

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
                Logger.ErrorFormat(Resources.Log_Error_EncryptedMailViewModel_MailDecryptionException, ex.Message, ex.StackTrace);
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