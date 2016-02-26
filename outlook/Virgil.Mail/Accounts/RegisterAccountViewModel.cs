namespace Virgil.Mail.Accounts
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.Linq;
    using System.Security;
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
        private readonly IVirgilCryptoProvider cryptoProvider;
        private readonly IDialogPresenter dialogs;
        private readonly IMailObserver mailObserver;
        private readonly VirgilHub virgilHub;

        private AccountModel currentAccount;
        private bool hasPassword;
        private bool isVirgilStorage;
        private SecureString password;
        private SecureString confirmPassword;
        private string confirmationCode;
        private string filePath;

        public RegisterAccountViewModel
        (
            IOutlookInteraction outlook, 
            IAccountsManager accountsManager,
            IVirgilCryptoProvider cryptoProvider, 
            IDialogPresenter dialogs,
            IMailObserver mailObserver,
            VirgilHub virgilHub
        )
        {
            this.outlook = outlook;
            this.accountsManager = accountsManager;
            this.cryptoProvider = cryptoProvider;
            this.dialogs = dialogs;
            this.mailObserver = mailObserver;
            this.virgilHub = virgilHub;

            this.CreateCommand = new RelayCommand(this.Create);
            this.BrowseFileCommand = new RelayCommand(this.BrowseFile);
            this.ImportCommand = new RelayCommand(this.Import);

            this.AddValidationRule(this.ValidatePasswordsMatches, "Your passwords don't match. Please retype your passwords to confirm it.");
            this.AddValidationRule(this.ValidatePassword, "Password must be 6 - 15 characters. Include at least 1 number or symbol.");
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

        public SecureString Password
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

        public SecureString ConfirmPassword
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
            var exportObject = new
            {
                card = new
                {
                    id = new Guid()
                },
                private_key = new List<byte>()
            };

            var fileKeyBase64 = System.IO.File.ReadAllText(this.FilePath);
            var result = JsonConvert.DeserializeAnonymousType(fileKeyBase64, exportObject);

            //var card = this.virgilHub.Cards.Search()

            //if (result.card.idenity.value.Equals(this.currentAccount.OutlookAccountEmail,
            //    StringComparison.CurrentCultureIgnoreCase))
            //{
            //    this.AddCustomError("This key is not match with current account.");
            //    return;
            //}
            
            //this.accountsManager.AddAccount();
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
                var keyPassword = this.HasPassword ? this.Password.ToString() : null;

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

                var keyPair = this.cryptoProvider.CreateKeyPair(this.CurrentAccount.OutlookAccountEmail, keyPassword);

                this.ChangeStateText("Publishing public key...");

                var createdCard = await this.virgilHub.Cards
                    .Create(validationToken, keyPair.PublicKey, keyPair.PrivateKey, keyPassword);

                this.CurrentAccount.VirgilCardId = createdCard.Id;
                this.CurrentAccount.VirgilCardHash = createdCard.Hash;
                this.CurrentAccount.VirgilCardCustomData = createdCard.CustomData;
                this.CurrentAccount.VirgilPublicKey = createdCard.PublicKey.PublicKey;
                this.CurrentAccount.VirgilPublicKeyId = createdCard.PublicKey.Id;

                this.accountsManager.UpdateAccount(this.CurrentAccount);

                if (this.IsVirgilStorage)
                {
                    this.ChangeStateText("Uploading private key...");
                    await this.virgilHub.PrivateKeys.Stash(createdCard.Id, keyPair.PrivateKey, keyPassword);
                }

                this.ChangeState(RegisterAccountState.Done);
            }
            catch (Exception ex)
            {
                this.AddCustomError(ex.Message);
            }
        }

        private bool ValidatePassword()
        {
            if (!this.HasPassword)
            {
                return true;
            }

            if (this.Password == null)
            {
                return false;
            }

            var isValid = Regex.IsMatch(this.Password.ToString(), "^([a-zA-Z0-9@*#]{8,15})$");
            return isValid;
        }

        private bool ValidatePasswordsMatches()
        {
            if (!this.HasPassword)
            {
                return true;
            }

            if (this.Password == null || this.ConfirmPassword == null)
            {
                return false;
            }
            
            var validatingPassword = this.Password.ToString();
            var validatingConfirmPassword = this.ConfirmPassword.ToString();

            return validatingPassword.Equals(validatingConfirmPassword);
        }
    }
}