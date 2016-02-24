namespace Virgil.Mail.Accounts
{
    using System.Linq;
    using System.Collections.ObjectModel;

    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Mvvm;
    using Virgil.Mail.Models;

    public class AccountsViewModel : ViewModel
    {
        private readonly IAccountsManager accountsManager;
        private readonly IDialogPresenter dialogPresenter;

        public AccountsViewModel(IAccountsManager accountsManager, IDialogPresenter dialogPresenter)
        {
            this.accountsManager = accountsManager;
            this.dialogPresenter = dialogPresenter;

            this.Accounts = new ObservableCollection<AccountModel>();

            this.ManageAccountCommand = new RelayCommand<AccountModel>(this.ManageAccount);
        }
        
        public RelayCommand<AccountModel> ManageAccountCommand { get; private set; }

        public ObservableCollection<AccountModel> Accounts { get; set; }

        internal void Initialize()
        {
            var accounts = this.accountsManager.GetAccounts().ToList();
            accounts.ForEach(this.Accounts.Add);
        }
        
        private void ManageAccount(AccountModel accountModel)
        {
            if (!accountModel.IsRegistered)
            {
                this.dialogPresenter.ShowRegisterAccount(accountModel);
                return;
            }

            this.dialogPresenter.ShowAccountSettings(accountModel);
        }
    }
}
