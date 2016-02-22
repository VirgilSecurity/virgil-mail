namespace Virgil.Mail.Accounts
{
    using System.Collections.ObjectModel;
    using System.Linq;
    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Models;
    using Virgil.Mail.Common.Mvvm;
    using Virgil.Mail.Models;

    public class AccountsViewModel : ViewModel
    {
        private readonly IAccountsManager accountsManager;

        public AccountsViewModel(IAccountsManager accountsManager)
        {
            this.accountsManager = accountsManager;

            this.Accounts = new ObservableCollection<VirgilAccountModel>();
        }

        public ObservableCollection<VirgilAccountModel> Accounts { get; set; }

        internal void Initialize()
        {
            var accounts = this.accountsManager.GetAccounts().ToList();
            accounts.ForEach(this.Accounts.Add);
        }
    }
}
