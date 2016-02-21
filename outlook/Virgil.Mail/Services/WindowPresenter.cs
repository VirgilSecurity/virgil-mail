namespace Virgil.Mail.Services
{
    using Autofac;

    using Virgil.Mail.Settings;
    using Virgil.Mail.Common;
    using Virgil.Mail.Accounts;

    internal class WindowPresenter : IWindowPresenter
    {
        private IContainer container;

        public WindowPresenter(IContainer container)
        {
            this.container = container;
        }

        public void ShowRegisterAccount()
        {
            var view = this.container.Resolve<RegisterAccountView>();
            var viewModel = this.container.Resolve<RegisterAccountViewModel>();

            viewModel.Initialize();
            view.DataContext = viewModel;
             
            var dialog = new RegisterAccount();
            dialog.ElementHost.Child = view;

            dialog.ShowDialog();
        }

        public void ShowAccounts()
        {
            var view = this.container.Resolve<AccountsView>();
            var viewModel = this.container.Resolve<AccountsViewModel>();

            viewModel.Initialize();
            view.DataContext = viewModel;

            var dialog = new AccountsWindow();
            dialog.ElementHost.Child = view;

            dialog.ShowDialog();
        }
    }
}
