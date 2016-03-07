namespace Virgil.Mail.Accounts
{
    using System.Linq;
    using System.Collections.ObjectModel;
    using System.Diagnostics;
    using System.Reflection;
    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Mvvm;
    using Virgil.Mail.Models;
    using Virgil.Mail.Mvvm;

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

        public string Version
        {
            get
            {
                var assembly = Assembly.GetExecutingAssembly();

                var fvi = FileVersionInfo.GetVersionInfo(assembly.Location);
                var version = fvi.FileVersion;
                
                return version;
            }
        }

        internal void Initialize()
        {
            this.Accounts.Clear();
            
            var accounts = this.accountsManager.GetAccounts().ToList();
            accounts.ForEach(this.Accounts.Add);
        }

        private void ManageAccount(AccountModel accountModel)
        {
            if (!accountModel.IsRegistered)
            {
                this.dialogPresenter.ShowRegisterAccount(accountModel);
            }
            else
            {
                this.dialogPresenter.ShowAccountSettings(accountModel);
            }
            
            this.Initialize();
        }
    }
}
