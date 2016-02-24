namespace Virgil.Mail.Accounts
{
    using System;
    using System.Collections.Generic;
    using System.Linq;

    using Virgil.Mail.Common;
    using Virgil.Mail.Models;

    internal class AccountsManager : IAccountsManager
    {
        private readonly IOutlookInteraction outlook;
        private readonly IEncryptedKeyValueStorage storage;

        public AccountsManager(IOutlookInteraction outlook, IEncryptedKeyValueStorage storage)
        {
            this.outlook = outlook;
            this.storage = storage;
        }

        public AccountModel GetAccount(string identity)
        {
            var accounts = this.GetAccounts();
            var account = accounts
                .SingleOrDefault(a => a.OutlookAccountEmail.Equals(identity, StringComparison.CurrentCultureIgnoreCase));

            return account;
        }

        public IEnumerable<AccountModel> GetAccounts()
        {
            var outlookAccounts = this.outlook.GetOutlookAccounts().ToList();
            var storedAccounts = this.storage.Get<IEnumerable<AccountModel>>("Accounts");

            // ensure that storage has not nullable collection.
            if (storedAccounts == null)
            {
                this.storage.Set("Accounts", new List<AccountModel>());
                storedAccounts = this.storage.Get<IEnumerable<AccountModel>>("Accounts");
            }
            
            var accounts = storedAccounts.ToList();

            foreach (var outlookAccount in outlookAccounts)
            {
                if (accounts.Any(a => a.OutlookAccountEmail.Equals(outlookAccount.Email, 
                    StringComparison.CurrentCultureIgnoreCase)))
                {
                    continue;
                }

                accounts.Add(new AccountModel
                {
                    OutlookAccountEmail = outlookAccount.Email, 
                    OutlookAccountDescription = outlookAccount.Description
                });
            }
            
            return accounts;
        }

        public void UpdateAccount(string identity, Guid cardId, string cardHash, Dictionary<string, string> cardCustomData)
        {
            var storedAccounts = this.storage.Get<IEnumerable<AccountModel>>("Accounts").ToList();
            var updatingAccount = storedAccounts
                .SingleOrDefault(it => it.OutlookAccountEmail.Equals(identity, StringComparison.CurrentCultureIgnoreCase));

            if (updatingAccount == null)
            {
                var outlookAccount = this.outlook.GetOutlookAccounts()
                    .Single(it => it.Email.Equals(identity, StringComparison.CurrentCultureIgnoreCase));

                updatingAccount = new AccountModel
                {
                    OutlookAccountEmail = outlookAccount.Email,
                    OutlookAccountDescription = outlookAccount.Description
                };

                storedAccounts.Add(updatingAccount);
            }

            updatingAccount.VirgilCardId = cardId;
            updatingAccount.VirgilCardHash = cardHash;
            updatingAccount.VirgilCardCustomData = cardCustomData;
            
            this.storage.Set("Accounts", storedAccounts);
        }
    }
}
