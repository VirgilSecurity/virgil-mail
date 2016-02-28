using System.IO;
using System.Text;
using System.Threading.Tasks;
using Virgil.Crypto;

namespace Virgil.Mail.Accounts
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.ComponentModel;
    using System.Text.RegularExpressions;

    using Newtonsoft.Json;
    
    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Mvvm;
    using Virgil.Mail.Models;
    using Virgil.Mail.Mvvm;
    using Virgil.SDK.Infrastructure;
    using Virgil.SDK.TransferObject;

    public class RegisterAccountViewModel : ViewModel
    {
        private readonly IOutlookInteraction outlook;
        private readonly IAccountsManager accountsManager;
        private readonly IPrivateKeysStorage privateKeyStorage;
        private readonly IDialogPresenter dialogs;
        private readonly IMailObserver mailObserver;
        private readonly VirgilHub virgilHub;

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
            VirgilHub virgilHub
        )
        {
            this.outlook = outlook;
            this.accountsManager = accountsManager;
            this.privateKeyStorage = privateKeyStorage;
            this.dialogs = dialogs;
            this.mailObserver = mailObserver;
            this.virgilHub = virgilHub;

            this.CreateCommand = new RelayCommand(this.Create);
            this.BrowseFileCommand = new RelayCommand(this.BrowseFile);
            this.ImportCommand = new RelayCommand(this.Import);

            this.AddValidationRules();
       }

        public RelayCommand CreateCommand { get; private set; }
        public RelayCommand ImportCommand { get; private set; }
        public RelayCommand BrowseFileCommand { get; private set; }
        
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
            this.CurrentAccount = accountModel;

            this.ChangeState(RegisterAccountState.Processing, "Search account information...");

            var foundCards = await this.virgilHub.Cards.Search(accountModel.OutlookAccountEmail, IdentityType.Email);
            
            this.ChangeState(foundCards.Any()
                ? RegisterAccountState.DownloadKeyPair
                : RegisterAccountState.GenerateKeyPair);
             
            this.IsVirgilStorage = true;
        }
        
        private void BrowseFile()
        {
            this.FilePath = this.dialogs.OpenFile("vcard");
        }

        private async void Import()
        {
            this.ClearErrors();

            try
            {
                this.ChangeState(RegisterAccountState.Processing, "Extracting Private Key information...");

                if (!this.IsVirgilStorage)
                {
                    var exportObject = new
                    {
                        card = new { id = default(Guid) },
                        private_key = default(byte[])
                    };

                    var fileKeyBase64 = File.ReadAllText(this.FilePath);
                    var fileKeyBytes = Convert.FromBase64String(fileKeyBase64);
                    var fileKeyJson = Encoding.UTF8.GetString(fileKeyBytes);
                    var result = JsonConvert.DeserializeAnonymousType(fileKeyJson, exportObject);

                    if (result?.card == null || result.private_key == null)
                    {
                        throw new NullReferenceException();
                    }

                    ChangeStateText("Loading Public Key details...");

                    var card = await this.virgilHub.Cards.Get(result.card.id);

                    this.CurrentAccount.VirgilCardId = card.Id;
                    this.CurrentAccount.VirgilCardHash = card.Hash;
                    this.CurrentAccount.VirgilCardCustomData = card.CustomData;
                    this.CurrentAccount.VirgilPublicKey = card.PublicKey.PublicKey;
                    this.CurrentAccount.VirgilPublicKeyId = card.PublicKey.Id;
                    this.CurrentAccount.IsVirgilPrivateKeyStorage = this.IsVirgilStorage;
                    this.CurrentAccount.IsPrivateKeyHasPassword = this.HasPassword;
                    this.CurrentAccount.IsPrivateKeyPasswordNeedToStore = true;

                    this.privateKeyStorage.StorePrivateKey(this.CurrentAccount.VirgilCardId, result.private_key);
                    this.accountsManager.UpdateAccount(this.CurrentAccount);

                    this.ChangeState(RegisterAccountState.Done, "Private Key has been successfully imported");
                }
                else
                {
                    var foundCards = await this.virgilHub.Cards.Search(this.CurrentAccount.OutlookAccountEmail);
                    var card = foundCards.SingleOrDefault();

                    
                }
            }
            catch (Exception ex)
            {
                this.AddCustomError("Uploading file is invalid or has wrong format");
                this.ChangeState(RegisterAccountState.DownloadKeyPair);
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

                this.ChangeState(RegisterAccountState.Processing, "Sending verification request...");

                var verifyResponse = await this.virgilHub.Identity
                    .Verify(this.CurrentAccount.OutlookAccountEmail, IdentityType.Email);

                this.ChangeStateText("Waiting for confirmation email...");

                var mail = await this.mailObserver.WaitFor("no-reply@virgilsecurity.com");

                var matches = Regex.Match(mail.Body, @"Your confirmation code is[\s\S]*<b[\s\S]*>(?<code>[\s\S]*)<\/b>");
                var code = matches.Groups["code"].Value;

                this.outlook.MarkMailAsRead(mail.EntryID);

                this.ChangeStateText("Confirming email account...");

                var validationToken = await this.virgilHub.Identity.Confirm(verifyResponse.ActionId, code);

                this.ChangeStateText("Generating public/private key pair...");

                var keyPair = this.HasPassword
                    ? VirgilKeyPair.Generate(VirgilKeyPair.Type.Default, Encoding.UTF8.GetBytes(this.Password))
                    : VirgilKeyPair.Generate(VirgilKeyPair.Type.Default);
                
                this.ChangeStateText("Publishing public key...");

                var createdCard = await this.virgilHub.Cards
                    .Create(validationToken, keyPair.PublicKey(), keyPair.PrivateKey(), keyPassword);

                this.privateKeyStorage.StorePrivateKey(createdCard.Id, keyPair.PrivateKey());

                this.CurrentAccount.VirgilCardId = createdCard.Id;
                this.CurrentAccount.VirgilCardHash = createdCard.Hash;
                this.CurrentAccount.VirgilCardCustomData = createdCard.CustomData;
                this.CurrentAccount.VirgilPublicKey = createdCard.PublicKey.PublicKey;
                this.CurrentAccount.VirgilPublicKeyId = createdCard.PublicKey.Id;
                this.CurrentAccount.IsVirgilPrivateKeyStorage = this.IsVirgilStorage;
                this.CurrentAccount.IsPrivateKeyHasPassword = this.HasPassword;
                this.CurrentAccount.IsPrivateKeyPasswordNeedToStore = true;

                this.accountsManager.UpdateAccount(this.CurrentAccount);

                if (this.IsVirgilStorage)
                {
                    this.ChangeStateText("Uploading private key...");
                    await this.virgilHub.PrivateKeys.Stash(createdCard.Id, keyPair.PrivateKey(), keyPassword);

                    this.CurrentAccount.LastPrivateKeySyncDateTime = DateTime.Now;
                }

                this.ChangeState(RegisterAccountState.Done, "Account's keys has been successfully generated and published.");
            }
            catch (Exception ex)
            {
                this.AddCustomError(ex.Message);
                this.ChangeState(RegisterAccountState.GenerateKeyPair);
            }
        }
        
        public override void OnMandatoryClosing(object sender, CancelEventArgs cancelEventArgs)
        {
            cancelEventArgs.Cancel = this.State.Equals(RegisterAccountState.Processing);
        }
        
        #region Validation Rules

        private void AddValidationRules()
        {
            this.AddValidationRule(this.ValidatePasswordsMatches, "Your passwords don't match. Please retype your passwords to confirm it.");
            this.AddValidationRule(this.ValidatePassword, "Password must be 4 - 15 characters. Only letters (a-z), digits (0-9) and special characters are allowed.");
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