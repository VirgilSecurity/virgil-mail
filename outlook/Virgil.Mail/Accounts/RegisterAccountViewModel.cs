namespace Virgil.Mail.Accounts
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.IO;
    using System.Text;
    using System.ComponentModel;
    using System.Threading.Tasks;
    using System.Text.RegularExpressions;
    using System.Windows.Input;
    using HtmlAgilityPack;
    using Newtonsoft.Json;
    using SDK.Cards;
    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Mvvm;
    using Virgil.Mail.Models;
    using Virgil.Mail.Mvvm;
    using Virgil.Mail.Properties;
    using Crypto;
    using SDK;
    using System.Threading;

    public class RegisterAccountViewModel : ViewModel
    {
        private readonly IOutlookInteraction outlook;
        private readonly IAccountsManager accountsManager;
        private readonly IPrivateKeysStorage privateKeyStorage;
        private readonly IDialogPresenter dialogs;
        private readonly IMailObserver mailObserver;
        private readonly IPasswordHolder passwordHolder;
        private readonly ServiceHub virgilHub;
        private readonly IMessageBus messageBus;

        private AccountModel currentAccount;
        private bool hasPassword;
        private bool isVirgilStorage;
        private string password;
        private string confirmPassword;
        private string filePath;

        public RegisterAccountViewModel
        (
            IOutlookInteraction outlook, 
            IAccountsManager accountsManager,
            IPrivateKeysStorage privateKeyStorage, 
            IDialogPresenter dialogs,
            IMailObserver mailObserver,
            IPasswordHolder passwordHolder,
            ServiceHub virgilHub,
            IMessageBus messageBus
        )
        {
            this.outlook = outlook;
            this.accountsManager = accountsManager;
            this.privateKeyStorage = privateKeyStorage;
            this.dialogs = dialogs;
            this.mailObserver = mailObserver;
            this.passwordHolder = passwordHolder;
            this.virgilHub = virgilHub;
            this.messageBus = messageBus;

            this.CreateCommand = new RelayCommand(this.Create);
            this.BrowseFileCommand = new RelayCommand(this.BrowseFile);
            this.ImportCommand = new RelayCommand(this.Import);
            this.DoneCommand = new RelayCommand(this.Close);

            this.AddValidationRules();
        }

        public RelayCommand CreateCommand { get; private set; }
        public RelayCommand ImportCommand { get; private set; }
        public RelayCommand BrowseFileCommand { get; private set; }
        public ICommand DoneCommand { get; private set; }

        public AccountModel CurrentAccount
        {
            get
            {
                return this.currentAccount;
            }
            set
            {
                this.currentAccount = value;
                this.RaisePropertyChanged();
            }
        }

        public bool HasPassword
        {
            get
            {
                return this.hasPassword;
            }
            set
            {
                this.ClearErrors();
                this.hasPassword = value;
                this.RaisePropertyChanged();
            }
        }

        public string FilePath
        {
            get
            {
                return this.filePath;
            }
            set
            {
                this.filePath = value;
                this.RaisePropertyChanged();
            }
        }

        public bool IsVirgilStorage
        {
            get
            {
                return this.isVirgilStorage;
            }
            set
            {
                this.isVirgilStorage = value;
                this.RaisePropertyChanged();
            }
        }

        public string Password
        {
            get
            {
                return this.password;
            }
            set
            {
                this.ClearErrors();
                this.password = value;
                this.RaisePropertyChanged();
            }
        }

        public string ConfirmPassword
        {
            get
            {
                return this.confirmPassword;
            }
            set
            {
                this.ClearErrors();
                this.confirmPassword = value;
                this.RaisePropertyChanged();
            }
        }
        
        public async void Initialize(AccountModel accountModel)
        {
            try
            {
                this.CurrentAccount = accountModel;

                this.ChangeState(RegisterAccountState.Processing, Resources.Label_SearchAccountInformation);

                var card = await this.virgilHub.Cards
                    .SearchLatestOrDefault(accountModel.OutlookAccountEmail);

                this.ChangeState(card != null
                    ? RegisterAccountState.DownloadKeyPair
                    : RegisterAccountState.GenerateKeyPair);

                this.IsVirgilStorage = true;
            }
            catch (Exception)
            {
                this.Close();
            }
        }
        
        private void BrowseFile()
        {
            this.FilePath = this.dialogs.OpenFile("vcard");
        }

        private async void Import()
        {
            this.ClearErrors();

            if (!this.IsVirgilStorage)
            {
                await this.ImportFromFile();
            }
            else
            {
                await this.ImportFromVirgilServices();
            }
        }

        private async void Create()
        {
            this.Validate();
            if (this.HasErrors)
            {
                return;
            }

            try
            {
                var keyPassword = this.HasPassword ? this.Password : null;

                this.ChangeState(RegisterAccountState.Processing, Resources.Label_SendingVerificationRequest);

                var attemptId = Guid.NewGuid().ToString();

                cancallationTokenSource.Token.ThrowIfCancellationRequested();

                var emailVerifier = await this.virgilHub.Identity.VerifyEmail(this.CurrentAccount.OutlookAccountEmail, 
                    new Dictionary<string, string> { { "attempt_id", attemptId } });

                this.ChangeStateText(Resources.Label_WaitingForConfirmationEmail);

                var code = await this.ExtractConfirmationCode(this.CurrentAccount.OutlookAccountEmail, attemptId);

                cancallationTokenSource.Token.ThrowIfCancellationRequested();

                this.ChangeStateText(Resources.Label_ConfirmingEmailAccount);

                var identityInfo = await emailVerifier.Confirm(code);

                cancallationTokenSource.Token.ThrowIfCancellationRequested();

                this.ChangeStateText(Resources.Label_GeneratingPublicAndPrivateKeyPair);

                var keyPair = this.HasPassword
                    ? VirgilKeyPair.Generate(VirgilKeyPair.Type.Default, Encoding.UTF8.GetBytes(this.Password))
                    : VirgilKeyPair.Generate(VirgilKeyPair.Type.Default);
                
                this.ChangeStateText(Resources.Label_PublishingPublicKey);

                cancallationTokenSource.Token.ThrowIfCancellationRequested();

                var createdCard = await this.virgilHub.Cards
                    .Create(identityInfo, keyPair.PublicKey(), keyPair.PrivateKey(), keyPassword);

                this.privateKeyStorage.StorePrivateKey(createdCard.Id, keyPair.PrivateKey());

                this.CurrentAccount.VirgilCardId = createdCard.Id;
                this.CurrentAccount.VirgilCardHash = createdCard.Hash;
                this.CurrentAccount.VirgilCardCustomData = createdCard.CustomData;
                this.CurrentAccount.VirgilPublicKey = createdCard.PublicKey.Value;
                this.CurrentAccount.VirgilPublicKeyId = createdCard.PublicKey.Id;
                this.CurrentAccount.IsVirgilPrivateKeyStorage = this.IsVirgilStorage;

                if (VirgilKeyPair.IsPrivateKeyEncrypted(keyPair.PrivateKey()))
                {
                    this.passwordHolder.Keep(this.CurrentAccount.OutlookAccountEmail, keyPassword);
                    this.CurrentAccount.IsPrivateKeyPasswordNeedToStore = true;
                }

                this.accountsManager.UpdateAccount(this.CurrentAccount);

                if (this.IsVirgilStorage)
                {
                    this.ChangeStateText(Resources.Label_UploadingPrivateKey);
                    await this.virgilHub.PrivateKeys.Stash(createdCard.Id, keyPair.PrivateKey(), keyPassword);

                    this.CurrentAccount.LastPrivateKeySyncDateTime = DateTime.Now;
                    this.accountsManager.UpdateAccount(this.CurrentAccount);
                }

                this.ChangeState(RegisterAccountState.Done, Resources.Label_AccountsKeysHasBeenSuccessfullyGenerated);
                this.messageBus.Publish(new AccountUpdatedMessage(createdCard.Id));
            }
            catch (Exception ex)
            {
                if (!cancallationTokenSource.Token.IsCancellationRequested)
                    cancallationTokenSource.Cancel();
                this.AddCustomError(ex.Message);
                this.ChangeState(RegisterAccountState.GenerateKeyPair);
            }
        }

        private async Task<string> ExtractConfirmationCode(string accountSmtpAddress, string waitingAttemptId)
        {
            while (true)
            {
                var mail = await this.mailObserver.WaitFor(accountSmtpAddress, "no-reply@virgilsecurity.com", this.cancallationTokenSource.Token);
                if (mail == null)
                {
                    throw new Exception(Resources.Error_ConfirmationCodeIsNotArrived);
                }

                if (mail.IsJunk)
                {
                    this.outlook.UnJunkMailById(mail.EntryID);
                    continue;
                }

                var htmlDoc = new HtmlDocument();
                htmlDoc.LoadHtml(mail.Body);

                var attemptIdElem = htmlDoc.GetElementbyId("attempt_id");
                if (attemptIdElem == null)
                {
                    this.outlook.DeleteMail(mail.EntryID);
                    continue;
                }

                var attemptId = attemptIdElem.GetAttributeValue("value", "");

                if (!attemptId.Equals(waitingAttemptId, StringComparison.CurrentCultureIgnoreCase))
                {
                    this.outlook.DeleteMail(mail.EntryID);
                    continue;
                }

                var virgilElem = htmlDoc.GetElementbyId("confirmation_code");
                var code = virgilElem?.GetAttributeValue("value", "");

                this.outlook.DeleteMail(mail.EntryID);
                return code;
            }
        }

        private async Task ImportFromFile()
        {
            try
            {
                this.ChangeState(RegisterAccountState.Processing, Resources.Label_ExtractingPrivateKeyInfo);

                var exportObject = new
                {
                    card = new { id = default(Guid) },
                    private_key = default(byte[])
                };

                var fileKeyBase64 = File.ReadAllText(this.FilePath);
                var fileKeyBytes = Convert.FromBase64String(fileKeyBase64);
                var fileKeyJson = Encoding.UTF8.GetString(fileKeyBytes);
                var result = JsonConvert.DeserializeAnonymousType(fileKeyJson, new[] { exportObject }).First();

                if (result?.card == null || result.private_key == null)
                {
                    throw new NullReferenceException();
                }

                this.ChangeStateText(Resources.Label_LoadingPublicKeyDetails);

                string enteredPassword = null;

                if (VirgilKeyPair.IsPrivateKeyEncrypted(result.private_key))
                {
                    enteredPassword = this.dialogs.ShowPrivateKeyPassword(this.CurrentAccount.OutlookAccountEmail, result.private_key);
                    if (enteredPassword == null)
                    {
                        this.ChangeState(RegisterAccountState.DownloadKeyPair);
                        return;
                    }
                }
                
                var card = await this.virgilHub.Cards
                    .SearchLatestOrDefault(this.CurrentAccount.OutlookAccountEmail);

                var isPrivateKeyTrue = string.IsNullOrEmpty(enteredPassword)
                    ? VirgilKeyPair.IsKeyPairMatch(card.PublicKey.Value, result.private_key)
                    : VirgilKeyPair.IsKeyPairMatch(card.PublicKey.Value, result.private_key, Encoding.UTF8.GetBytes(enteredPassword));

                if (!isPrivateKeyTrue)
                {
                    this.AddCustomError(Resources.Label_UploadedPrivateKeyDoesnIsNotMatch);
                    this.ChangeState(RegisterAccountState.DownloadKeyPair);
                    return;
                }

                this.CurrentAccount.VirgilCardId = card.Id;
                this.CurrentAccount.VirgilCardHash = card.Hash;
                this.CurrentAccount.VirgilCardCustomData = card.CustomData;
                this.CurrentAccount.VirgilPublicKey = card.PublicKey.Value;
                this.CurrentAccount.VirgilPublicKeyId = card.PublicKey.Id;
                this.CurrentAccount.IsVirgilPrivateKeyStorage = this.IsVirgilStorage;
                this.CurrentAccount.IsPrivateKeyPasswordNeedToStore = true;
                
                this.privateKeyStorage.StorePrivateKey(this.CurrentAccount.VirgilCardId, result.private_key);
                this.accountsManager.UpdateAccount(this.CurrentAccount);

                this.ChangeState(RegisterAccountState.Done, Resources.Label_PrivateKeyImportedSuccessfully);
                this.messageBus.Publish(new AccountUpdatedMessage(card.Id));
            }
            catch (Exception)
            {
                this.AddCustomError(Resources.Error_UploadedFileInvalid);
                this.ChangeState(RegisterAccountState.DownloadKeyPair);
            }
        }

        private async Task ImportFromVirgilServices()
        {
            try
            {
                this.ChangeState(RegisterAccountState.Processing, Resources.Label_LoadingPublicKeyDetails);

                var card = await this.virgilHub.Cards
                    .SearchLatestOrDefault(this.CurrentAccount.OutlookAccountEmail);

                this.ChangeState(RegisterAccountState.Processing, Resources.Label_SendingVerificationRequest);

                var attemptId = Guid.NewGuid().ToString();
                var emailVerifier = await this.virgilHub.Identity.VerifyEmail(this.CurrentAccount.OutlookAccountEmail, 
                    new Dictionary<string, string> { { "attempt_id", attemptId } });

                this.ChangeStateText(Resources.Label_WaitingForConfirmationEmail);

                var code = await this.ExtractConfirmationCode(this.CurrentAccount.OutlookAccountEmail, attemptId);

                this.ChangeStateText(Resources.Label_ConfirmingEmailAccount);

                var validationToken = await emailVerifier.Confirm(code);
                var response = await this.virgilHub.PrivateKeys.Get(card.Id, validationToken);

                var privateKey = response.PrivateKey;

                if (VirgilKeyPair.IsPrivateKeyEncrypted(privateKey))
                {
                    var enteredPassword = this.dialogs.ShowPrivateKeyPassword(this.CurrentAccount.OutlookAccountEmail, privateKey);
                    if (enteredPassword == null)
                    {
                        this.ChangeState(RegisterAccountState.DownloadKeyPair);
                        return;
                    }

                    this.passwordHolder.Keep(this.CurrentAccount.OutlookAccountEmail, enteredPassword);
                    this.CurrentAccount.IsPrivateKeyPasswordNeedToStore = true;
                }

                this.CurrentAccount.VirgilCardId = card.Id;
                this.CurrentAccount.VirgilCardHash = card.Hash;
                this.CurrentAccount.VirgilCardCustomData = card.CustomData;
                this.CurrentAccount.VirgilPublicKey = card.PublicKey.Value;
                this.CurrentAccount.VirgilPublicKeyId = card.PublicKey.Id;
                this.CurrentAccount.IsVirgilPrivateKeyStorage = this.IsVirgilStorage;
                this.CurrentAccount.IsPrivateKeyPasswordNeedToStore = true;
                this.CurrentAccount.LastPrivateKeySyncDateTime = DateTime.Now;
                
                this.privateKeyStorage.StorePrivateKey(card.Id, privateKey);
                this.accountsManager.UpdateAccount(this.CurrentAccount);
                
                this.ChangeState(RegisterAccountState.Done, Resources.Label_PrivateKeyImportedSuccessfully);
                this.messageBus.Publish(new AccountUpdatedMessage(card.Id));
            }
            catch (Exception ex)
            {
                this.AddCustomError(Resources.Error_UploadingPrivateKeyFailed + $". {ex.Message}");
                this.ChangeState(RegisterAccountState.DownloadKeyPair);
            }
        }

        public override void OnMandatoryClosing(object sender, CancelEventArgs cancelEventArgs)
        {
            this.cancallationTokenSource.Cancel();
            cancelEventArgs.Cancel = false;
        }


        #region Validation Rules

        private void AddValidationRules()
        {
            this.AddValidationRule(this.ValidatePasswordsMatches, Resources.Error_PasswordNotMatchWithConfirmation);
            this.AddValidationRule(this.ValidatePassword, Resources.Error_PasswordRulesAreNotComplied);
        }

        private bool ValidatePassword()
        {
            if (RegisterAccountState.GenerateKeyPair != (RegisterAccountState)this.State)
            {
                return true;
            }

            if (!this.HasPassword)
            {
                return true;
            }

            if (this.Password == null)
            {
                return false;
            }

            var isValid = Regex.IsMatch(this.Password, @"^[a-zA-Z\d\!\#\$\%\&\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\\\]\^\{\|\}\~]{4,15}$");
            return isValid;
        }

        private bool ValidatePasswordsMatches()
        {
            if (RegisterAccountState.GenerateKeyPair != (RegisterAccountState)this.State)
            {
                return true;
            }

            if (!this.HasPassword)
            {
                return true;
            }

            if (this.Password == null || this.ConfirmPassword == null)
            {
                return false;
            }

            var validatingPassword = this.Password;
            var validatingConfirmPassword = this.ConfirmPassword;

            return validatingPassword.Equals(validatingConfirmPassword);
        }

        #endregion
    }
}