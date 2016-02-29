namespace Virgil.Mail.Accounts
{
    using System.Text;
    using System.Windows.Controls;
    using System.Windows.Input;

    using Virgil.Mail.Mvvm;
    using Virgil.Mail.Common.Mvvm;

    public class AccountKeyPasswordViewModel : ViewModel
    {
        private string password;
        private byte[] privateKey;

        public AccountKeyPasswordViewModel()
        {
            this.AcceptCommand = new RelayCommand(this.Accept);
            this.CancelCommand = new RelayCommand(this.Cancel);
        }

        public ICommand AcceptCommand { get; set; }
        public ICommand CancelCommand { get; set; }
        
        public void Initialize(byte[] checkingPrivateKey)
        {
            this.privateKey = checkingPrivateKey;
        }

        private void Cancel()
        {
            this.Close();
        }

        private void Accept(object parameter)
        {
            var passwordBox = (PasswordBox)parameter;
            var password = passwordBox.Password;
            
            var passwordBytes = Encoding.UTF8.GetBytes(password);
            var isMatch = Crypto.VirgilKeyPair.CheckPrivateKeyPassword(this.privateKey, passwordBytes);
            if (!isMatch)
            {
                passwordBox.Clear();
                return;
            }

            this.Result = password;
            this.Close();
        }
    }
}