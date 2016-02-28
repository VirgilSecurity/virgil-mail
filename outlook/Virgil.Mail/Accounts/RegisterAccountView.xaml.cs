namespace Virgil.Mail.Accounts
{
    public partial class RegisterAccountView
    {
        public RegisterAccountView()
        {
            this.InitializeComponent();
            this.password.PasswordChanged += this.OnPasswordChanged;
            this.confirmPassword.PasswordChanged += this.OnConfirmPasswordChanged;
        }

        private void OnPasswordChanged(object sender, System.Windows.RoutedEventArgs e)
        {
            this.watermarkPassword.Visibility = System.Windows.Visibility.Hidden;

            ((RegisterAccountViewModel)this.DataContext).Password = this.password.Password;
            if (this.password.Password.Length == 0)
            {
                this.watermarkPassword.Visibility = System.Windows.Visibility.Visible;
            }
        }

        private void OnConfirmPasswordChanged(object sender, System.Windows.RoutedEventArgs e)
        {
            this.watermarkConfirmPassword.Visibility = System.Windows.Visibility.Hidden;

            ((RegisterAccountViewModel)this.DataContext).ConfirmPassword = this.confirmPassword.Password;
            if (this.confirmPassword.Password.Length == 0)
            {
                this.watermarkConfirmPassword.Visibility = System.Windows.Visibility.Visible;
            }
        }
    }
}
