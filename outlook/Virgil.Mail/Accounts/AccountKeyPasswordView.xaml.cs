namespace Virgil.Mail.Accounts
{
    /// <summary>
    /// Interaction logic for AccountKeyPasswordView.xaml
    /// </summary>
    public partial class AccountKeyPasswordView
    {
        public AccountKeyPasswordView()
        {
            this.InitializeComponent();
            this.password.PasswordChanged += this.OnPasswordChanged;
        }

        private void OnPasswordChanged(object sender, System.Windows.RoutedEventArgs e)
        {
            this.watermarkPassword.Visibility = System.Windows.Visibility.Hidden;
            if (this.password.Password.Length == 0)
            {
                this.watermarkPassword.Visibility = System.Windows.Visibility.Visible;
            }
        }
    }
}
