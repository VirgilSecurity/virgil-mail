namespace Virgil.Mail.Accounts
{
    using System.ComponentModel.DataAnnotations;
    using System.Security;
    using System.Text.RegularExpressions;

    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Mvvm;
    using Virgil.Mail.Models;
    using Virgil.SDK.Infrastructure;
    using Virgil.SDK.TransferObject;

    public class RegisterAccountViewModel : ViewModel
    {
        private readonly IOutlookInteraction outlook;
        private readonly IAccountsManager accountsManager;
        private readonly IVirgilCryptoProvider cryptoProvider;
        private readonly IMailObserver mailObserver;
        private readonly VirgilHub virgilHub;

        private AccountModel currentAccount;
        private bool hasPassword;
        private bool isVirgilStorage;
        private SecureString password;
        private SecureString confirmPassword;
        private string confirmationCode;

        public RegisterAccountViewModel
        (
            IOutlookInteraction outlook, 
            IAccountsManager accountsManager,
            IVirgilCryptoProvider cryptoProvider, 
            IMailObserver mailObserver,
            VirgilHub virgilHub
        )
        {
            this.outlook = outlook;
            this.accountsManager = accountsManager;
            this.cryptoProvider = cryptoProvider;
            this.mailObserver = mailObserver;
            this.virgilHub = virgilHub;

            this.CreateCommand = new RelayCommand(this.Create);
        }
        
        public RelayCommand CreateCommand { get; private set; }
        
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
                this.hasPassword = value;
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

        [Required]
        public string ConfirmationCode
        {
            get
            {
                return this.confirmationCode;
            }
            set
            {
                this.confirmationCode = value;
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
                this.confirmPassword = value;
                this.RaisePropertyChanged();
            }
        }
        
        public void Initialize(AccountModel accountModel)
        {
            this.CurrentAccount = accountModel;
            
            this.ChangeState(RegisterAccountState.GenerateKeyPair);
            this.IsVirgilStorage = true;
        }
        
        private async void Create()
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

            this.ChangeStateText("Publishing public key...");

            this.accountsManager.UpdateAccount(this.CurrentAccount.OutlookAccountEmail, createdCard.Id, 
                createdCard.Hash, createdCard.CustomData);

            if (this.IsVirgilStorage)
            {
                this.ChangeStateText("Uploading private key...");
                await this.virgilHub.PrivateKeys.Stash(createdCard.Id, keyPair.PrivateKey, keyPassword);
            }
        }
    }
}