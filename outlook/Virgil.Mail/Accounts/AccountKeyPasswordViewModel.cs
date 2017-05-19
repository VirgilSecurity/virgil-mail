namespace Virgil.Mail.Accounts
{
    using System.Text;
    using System.Windows.Controls;
    using System.Windows.Input;

    using Virgil.Mail.Common;
    using Virgil.Mail.Mvvm;
    using Virgil.Mail.Common.Mvvm;
    using Virgil.Mail.Properties;
    using SDK;

    public class AccountKeyPasswordViewModel : ViewModel
    {
        private readonly IPasswordHolder passwordHolder;
        private readonly IAccountsManager accountsManager;
        
        private string keyName;
        private string accountEmail;
        private bool isStorePassword;

        public AccountKeyPasswordViewModel(IPasswordHolder passwordHolder, IAccountsManager accountsManager)
        {
            this.passwordHolder = passwordHolder;
            this.accountsManager = accountsManager;
            this.AcceptCommand = new RelayCommand(this.Accept);
            this.CancelCommand = new RelayCommand(this.Cancel);
        }

        public ICommand AcceptCommand { get; set; }
        public ICommand CancelCommand { get; set; }

        public bool IsStorePassword
        {
            get { return this.isStorePassword; }
            set
            {
                this.isStorePassword = value;
                this.RaisePropertyChanged();
            }
        }

        public void Initialize(string accountSmtpAddress, string checkingKeyName)
        {
            this.accountEmail = accountSmtpAddress;
            this.keyName = checkingKeyName;
        }

        private void Cancel()
        {
            this.Close();
        }

        private void Accept(object parameter)
        {
            this.ClearErrors();

            var passwordBox = (PasswordBox)parameter;
            var password = passwordBox.Password;
            
            var passwordBytes = Encoding.UTF8.GetBytes(password);


            try
            {
                var virgil = new VirgilApi();
                virgil.Keys.Load(keyName, password);
            }
            catch
            {

                passwordBox.Clear();
                this.AddCustomError(Resources.Error_IncorrectPrivateKeyPassword);
                return;
            }
          

            if (this.IsStorePassword)
            {
                var account = this.accountsManager.GetAccount(this.accountEmail);
                this.passwordHolder.Keep(this.accountEmail, password);

                account.IsPrivateKeyPasswordNeedToStore = true;
                this.accountsManager.UpdateAccount(account);
            }

            this.Result = password;
            this.Close();
        }
    }
}