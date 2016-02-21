namespace Virgil.Mail.Settings
{
    using System.Linq;
    using System.Security;
    using System.Collections.ObjectModel;
    using System.ComponentModel.DataAnnotations;

    using Virgil.Mail.Integration;
    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Mvvm;
    using Virgil.SDK.Infrastructure;
    using Virgil.SDK.TransferObject;
    
    public class RegisterAccountViewModel : ViewModel
    {
        private readonly IOutlookInteraction outlook;
        private readonly VirgilHub virgilHub;

        private AccountIntegrationModel currentAccount;
        private bool hasPassword;
        private bool isVirgilStorage;
        private SecureString password;
        private SecureString confirmPassword;
        private string confirmationCode;

        private VirgilVerifyResponse verifyResponse;

        public RegisterAccountViewModel(IOutlookInteraction outlook, VirgilHub virgilHub)
        {
            this.outlook = outlook;
            this.virgilHub = virgilHub;

            this.Accounts = new ObservableCollection<AccountIntegrationModel>();

            this.RegisterCommand = new RelayCommand(this.Register);
            this.CreateCommand = new RelayCommand(this.Create);
            this.ConfirmCommand = new RelayCommand(this.Confirm);
        }
        
        public RelayCommand RegisterCommand { get; private set; }
        public RelayCommand CreateCommand { get; private set; }
        public RelayCommand ConfirmCommand { get; private set; }

        public ObservableCollection<AccountIntegrationModel> Accounts { get; private set; }
        public AccountIntegrationModel CurrentAccount
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
        
        public void Initialize()
        {
            var accounts = this.outlook.GetOutlookAccounts().ToList();
            accounts.ForEach(this.Accounts.Add);

            if (accounts.Any())
            {
                this.CurrentAccount = accounts.First();
            }
            
            this.ChangeState(RegisterAccountState.EmailAccountSelection);
            this.IsVirgilStorage = true;
        }

        private async void Register()
        {
            this.ChangeState(RegisterAccountState.Processing, "Sending verification request...");

            this.verifyResponse = await this.virgilHub.Identity
                 .Verify(this.CurrentAccount.Email, IdentityType.Email);

            this.ChangeState(RegisterAccountState.VerifyIdentity);
        }

        private async void Create()
        {
        }

        private async void Confirm()
        {
            this.Validate();

            if (this.HasErrors)
            {
                return;
            }

            this.ChangeState(RegisterAccountState.Processing, "Loading information...");

            var cards = await this.virgilHub.Cards.Search(this.CurrentAccount.Email);
            if (cards.Any())
            {
                this.ChangeState(RegisterAccountState.DownloadPrivateKeys);
                return;
            }
        }
    }
}