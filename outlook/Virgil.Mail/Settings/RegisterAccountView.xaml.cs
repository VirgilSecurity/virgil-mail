namespace Virgil.Mail.Settings
{
    using System.Windows.Controls;
    
    public partial class RegisterAccountView : UserControl
    {
        public RegisterAccountView()
        {
            this.InitializeComponent();
            this.password.PasswordChanged += OnPasswordChanged;
            this.confirmPassword.PasswordChanged += OnConfirmPasswordChanged;
        }

        private void OnPasswordChanged(object sender, System.Windows.RoutedEventArgs e)
        {
            this.watermarkPassword.Visibility = System.Windows.Visibility.Hidden;

            ((RegisterAccountViewModel)this.DataContext).Password = this.password.SecurePassword;
            if (this.password.Password.Length == 0)
            {
                this.watermarkPassword.Visibility = System.Windows.Visibility.Visible;
            }
        }

        private void OnConfirmPasswordChanged(object sender, System.Windows.RoutedEventArgs e)
        {
            this.watermarkConfirmPassword.Visibility = System.Windows.Visibility.Hidden;

            ((RegisterAccountViewModel)this.DataContext).ConfirmPassword = this.confirmPassword.SecurePassword;
            if (this.confirmPassword.Password.Length == 0)
            {
                this.watermarkConfirmPassword.Visibility = System.Windows.Visibility.Visible;
            }
        }
    }
}
