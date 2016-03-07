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
        private readonly List<AccountModel> internalAccounts;

        /// <summary>
        /// Initializes a new instance of the <see cref="AccountsManager"/> class.
        /// </summary>
        public AccountsManager(IOutlookInteraction outlook, IEncryptedKeyValueStorage storage)
        {
            this.outlook = outlook;
            this.storage = storage;

            this.internalAccounts = new List<AccountModel>();
        }

        public AccountModel GetAccount(string identity)
        {
            var accounts = this.GetMergedAccounts();
            var account = accounts
                .SingleOrDefault(a => a.OutlookAccountEmail.Equals(identity, StringComparison.CurrentCultureIgnoreCase));

            return account;
        }

        public void Remove(string outlookAccountEmail)
        {
            var accounts = this.GetMergedAccounts();
            var newAccounts = accounts
                .Where(it => !it.OutlookAccountEmail.Equals(outlookAccountEmail, StringComparison.CurrentCultureIgnoreCase))
                .ToList();

            this.AcceptChanges(newAccounts);
            this.internalAccounts.Clear();
        }

        public bool IsRegistered(string accountSmtpAddress)
        {
            var accounts = this.GetMergedAccounts();

            var account = accounts.Single(
                it => it.OutlookAccountEmail.Equals(accountSmtpAddress, StringComparison.CurrentCultureIgnoreCase));

            return account.IsRegistered;
        }

        public void UpdateAccount(AccountModel accountModel)
        {
            var accounts = this.GetMergedAccounts();
            var account = accounts.Single(a => a.OutlookAccountEmail.Equals(accountModel.OutlookAccountEmail, 
                StringComparison.CurrentCultureIgnoreCase));

            account.VirgilCardId = accountModel.VirgilCardId;
            account.VirgilCardHash = accountModel.VirgilCardHash;
            account.VirgilCardCustomData = account.VirgilCardCustomData;
            account.VirgilPublicKey = account.VirgilPublicKey;
            account.VirgilPublicKeyId = account.VirgilPublicKeyId;

            account.IsVirgilPrivateKeyStorage = accountModel.IsVirgilPrivateKeyStorage;
            account.IsPrivateKeyPasswordNeedToStore = accountModel.IsPrivateKeyPasswordNeedToStore;
            account.LastPrivateKeySyncDateTime = accountModel.LastPrivateKeySyncDateTime;

            this.AcceptChanges(accounts);
        }

        public IEnumerable<AccountModel> GetAccounts()
        {
            return this.GetMergedAccounts();
        }
        
        private IList<AccountModel> GetMergedAccounts()
        {
            // getting all Outlook registered accounts from 
            // interaction API
            var outlookAccounts = this.outlook.GetOutlookAccounts().ToList();

            // ensure that storage collaction is not null.
            var storedAccounts = this.storage.Get<IList<AccountModel>>("Accounts") 
                ?? new List<AccountModel>();
            
            var accounts = new List<AccountModel>(storedAccounts);
            
            // merge stored accounts with Outlook accounts
            foreach (var outlookAccount in outlookAccounts)
            {
                if (accounts.Any(a => a.OutlookAccountEmail.Equals(outlookAccount.Email,
                    StringComparison.CurrentCultureIgnoreCase)))
                {
                    continue;
                }
                
                var accountModel = new AccountModel
                {
                    OutlookAccountEmail = outlookAccount.Email,
                    OutlookAccountDescription = outlookAccount.Description
                };

                accounts.Add(accountModel);
            }

            foreach (var accountModel in accounts)
            {
                if (!this.internalAccounts.Any(a => a.OutlookAccountEmail.Equals(accountModel.OutlookAccountEmail,
                    StringComparison.CurrentCultureIgnoreCase)))
                {
                    this.internalAccounts.Add(accountModel);
                }
            }
            
            return this.internalAccounts;
        }

        private void AcceptChanges(IList<AccountModel> accounts)
        {
            this.storage.Set("Accounts", accounts);
        }
    }
}
