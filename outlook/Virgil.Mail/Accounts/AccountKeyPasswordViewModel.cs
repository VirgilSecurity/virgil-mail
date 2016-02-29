namespace Virgil.Mail.Accounts
{
    using System.Text;
    using System.Windows.Input;

    using Virgil.Mail.Mvvm;
    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Mvvm;
    using Virgil.Mail.Models;

    public class AccountKeyPasswordViewModel : ViewModel
    {
        private readonly IPrivateKeysStorage privateKeysStorage;
        private AccountModel account;
        private string password;

        public AccountKeyPasswordViewModel(IPrivateKeysStorage privateKeysStorage)
        {
            this.privateKeysStorage = privateKeysStorage;

            this.AcceptCommand = new RelayCommand(this.Accept);
            this.CancelCommand = new RelayCommand(this.Cancel);
        }

        public ICommand AcceptCommand { get; set; }
        public ICommand CancelCommand { get; set; }

        public string Password
        {
            get { return this.password; }
            set
            {
                this.password = value;
                this.RaisePropertyChanged();
            }
        }

        public void Initialize(byte[] privateKey)
        {
            // this.account = accountModel;
        }

        private void Cancel()
        {
            this.Close();
        }

        private void Accept()
        {
            //var passwordBytes = Encoding.UTF8.GetBytes(this.Password);
            //var privateKey = this.privateKeysStorage.GetPrivateKey(this)

            //var isMatch = Virgil.Crypto.VirgilKeyPair.CheckPrivateKeyPassword(passwordBytes);
        }
    }
}