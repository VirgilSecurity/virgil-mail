namespace Virgil.Mail.Accounts
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.IO;
    using System.ComponentModel;
    using System.Threading.Tasks;
    using System.Text.RegularExpressions;
    using System.Windows.Input;
    using HtmlAgilityPack;
    using Newtonsoft.Json;
    using Common;
    using Common.Mvvm;
    using Models;
    using Mvvm;
    using Properties;
    using SDK;
    using System.Threading;
    using Crypto;

    public class RegisterAccountViewModel : ViewModel
    {
        private readonly IOutlookInteraction outlook;
        private readonly IAccountsManager accountsManager;
        private readonly IDialogPresenter dialogs;
        private readonly IMailObserver mailObserver;
        private readonly IPasswordHolder passwordHolder;
        private readonly VirgilApi virgilApi;
        private readonly IMessageBus messageBus;

        private AccountModel currentAccount;
        private bool hasPassword;
        private bool isImportSelected;
        private bool isRegisteredPreviously;
        private string password;
        private string confirmPassword;
        private string filePath;

        public RegisterAccountViewModel
        (
            IOutlookInteraction outlook, 
            IAccountsManager accountsManager,
            IDialogPresenter dialogs,
            IMailObserver mailObserver,
            IPasswordHolder passwordHolder,
            IMessageBus messageBus
        )
        {
            this.outlook = outlook;
            this.accountsManager = accountsManager;
            this.dialogs = dialogs;
            this.mailObserver = mailObserver;
            this.passwordHolder = passwordHolder;
            this.virgilApi = new VirgilApi() { };
            this.messageBus = messageBus;

            this.CreateCommand = new RelayCommand(this.Create);
            this.BrowseFileCommand = new RelayCommand(this.BrowseFile);
            this.ImportOrCreateCommand = new RelayCommand(this.ImportOrCreate);
            this.DoneCommand = new RelayCommand(this.Close);

            this.AddValidationRules();
        }

        public RelayCommand CreateCommand { get; private set; }
        public RelayCommand ImportOrCreateCommand { get; private set; }
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

        public bool IsRegisteredPreviously
        {
            get
            {
                return this.isRegisteredPreviously;
            }
            set
            {
                this.isRegisteredPreviously = value;
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

        public bool IsImportSelected
        {
            get
            {
                return this.isImportSelected;
            }
            set
            {
                this.isImportSelected = value;
                this.RaisePropertyChanged();
            }
        }

        public async void Initialize(AccountModel accountModel)
        {
            try
            {
                this.CurrentAccount = accountModel;

                this.ChangeState(RegisterAccountState.Processing, Resources.Label_SearchAccountInformation);

                var cards = await this.virgilApi.Cards.FindGlobalAsync(accountModel.OutlookAccountEmail);

                if (cards.Any())
                {
                    this.IsImportSelected = true;
                    this.IsRegisteredPreviously = true;

                    this.ChangeState(RegisterAccountState.DownloadOrGenerateKeyPair);
                }
                else
                {
                    this.ChangeState(RegisterAccountState.GenerateKeyPair);
                }

   
            }
            catch (Exception)
            {
                this.Close();
            }
        }
        
        private void BrowseFile()
        {
            this.FilePath = this.dialogs.OpenFile("virgilkey");
        }

        private async void ImportOrCreate()
        {
            this.ClearErrors();
            if (this.IsImportSelected)
            {
                await this.ImportFromFile();
            }
            else
            {
                 this.Create();
            }
        }

        private async void Create()
        {
            this.Validate();
            this.cancallationTokenSource = new CancellationTokenSource();

            if (this.HasErrors)
            {
                return;
            }

            try
            {
                var keyPassword = this.HasPassword ? this.Password : null;

                this.ChangeState(RegisterAccountState.Processing, Resources.Label_SendingVerificationRequest);

                this.ChangeStateText(Resources.Label_GeneratingPublicAndPrivateKeyPair);

                var virgilKey = virgilApi.Keys.Generate();

                var createdCard = virgilApi.Cards.CreateGlobal(
                    identity: this.CurrentAccount.OutlookAccountEmail,
                    identityType: IdentityType.Email,
                    ownerKey: virgilKey
                );

                cancallationTokenSource.Token.ThrowIfCancellationRequested();

                this.ChangeStateText(Resources.Label_WaitingForConfirmationEmail);

                var attemptId = Guid.NewGuid().ToString();
                var option = new IdentityVerificationOptions();

                option.ExtraFields = new Dictionary<string, string> {
                    { "attempt_id", attemptId.ToString() }
                };

                var attempt = await createdCard.CheckIdentityAsync(option);
               

                var code = await this.ExtractConfirmationCode(this.CurrentAccount.OutlookAccountEmail,
                    attemptId.ToString());

                cancallationTokenSource.Token.ThrowIfCancellationRequested();

                this.ChangeStateText(Resources.Label_ConfirmingEmailAccount);


                var identityToken = await attempt.ConfirmAsync(new EmailConfirmation(code));

                cancallationTokenSource.Token.ThrowIfCancellationRequested();

                this.ChangeStateText(Resources.Label_PublishingPublicKey);

                await virgilApi.Cards.PublishGlobalAsync(createdCard, identityToken);

                virgilKey.Save(createdCard.Id, this.hasPassword ? this.Password : null);
                this.CurrentAccount.VirgilCardId = createdCard.Id;

                if (this.hasPassword)
                {
                    this.passwordHolder.Keep(this.CurrentAccount.OutlookAccountEmail, keyPassword);                   
                }

                this.CurrentAccount.IsPrivateKeyPasswordNeedToStore = this.hasPassword;
                this.CurrentAccount.IsPrivateKeyHasPassword = this.hasPassword;

                this.accountsManager.UpdateAccount(this.CurrentAccount);

                this.ChangeState(RegisterAccountState.Done, Resources.Label_AccountsKeysHasBeenSuccessfullyGenerated);
                this.messageBus.Publish(new AccountUpdatedMessage(createdCard.Id));
            }
            catch (Exception ex)
            {
                if (!cancallationTokenSource.Token.IsCancellationRequested)
                    cancallationTokenSource.Cancel();
                this.AddCustomError(ex.Message);
                this.ChangeState(this.isRegisteredPreviously ? 
                    RegisterAccountState.DownloadOrGenerateKeyPair : RegisterAccountState.GenerateKeyPair);
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
                    id = default(string),
                    private_key = default(byte[])
                };

                var fileKeyBase64 = File.ReadAllText(this.FilePath);
                var fileKeyJson = VirgilBuffer.From(fileKeyBase64, StringEncoding.Base64).ToString();

                this.ChangeStateText(Resources.Label_LoadingPublicKeyDetails);

                var result = JsonConvert.DeserializeAnonymousType(fileKeyJson, new[] { exportObject }).First();

                if (result?.id == null || result.private_key == null)
                {
                    throw new NullReferenceException();
                }

                string enteredPassword = null;

                VirgilKey virgilKey = null;
                this.ChangeState(RegisterAccountState.DownloadKeyPair);

                try
                {
                    virgilKey = virgilApi.Keys.Import(VirgilBuffer.From(result.private_key));
                }
                catch
                {
                    enteredPassword = this.dialogs.ShowImportedPrivateKeyPassword(
                        this.CurrentAccount.OutlookAccountEmail,
                        result.id,
                        VirgilBuffer.From(result.private_key)
                        );
                    virgilKey = virgilApi.Keys.Import(VirgilBuffer.From(result.private_key), enteredPassword);
                }

                var card = await virgilApi.Cards.GetAsync(result.id);

                if (card != null && card.IsPairFor(virgilKey))
                {
                    virgilKey.Save(result.id, enteredPassword);
                }
                else
                {
                    this.AddCustomError(Resources.Label_UploadedPrivateKeyDoesnIsNotMatch);
                    this.ChangeState(RegisterAccountState.DownloadOrGenerateKeyPair);
                    return;
                }

                if (enteredPassword != null)
                {
                    this.HasPassword = true;
                    this.passwordHolder.Keep(this.CurrentAccount.OutlookAccountEmail, enteredPassword);
                }

                this.CurrentAccount.IsPrivateKeyPasswordNeedToStore = this.CurrentAccount.IsPrivateKeyPasswordNeedToStore;
                this.CurrentAccount.IsPrivateKeyHasPassword = this.CurrentAccount.IsPrivateKeyHasPassword;


                this.CurrentAccount.VirgilCardId = card.Id;
                this.accountsManager.UpdateAccount(this.CurrentAccount);

                this.ChangeState(RegisterAccountState.Done, Resources.Label_PrivateKeyImportedSuccessfully);
                this.messageBus.Publish(new AccountUpdatedMessage(card.Id));
            }
            catch (Exception)
            {
                this.AddCustomError(Resources.Error_UploadedFileInvalid);
                this.ChangeState(RegisterAccountState.DownloadOrGenerateKeyPair);
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

            var isValid = Regex.IsMatch(this.Password, @"^.{3,128}$");

            return isValid;
        }

        private bool ValidatePasswordsMatches()
        {
            if ((RegisterAccountState.GenerateKeyPair != (RegisterAccountState)this.State) && 
                (RegisterAccountState.DownloadOrGenerateKeyPair != (RegisterAccountState)this.State))
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