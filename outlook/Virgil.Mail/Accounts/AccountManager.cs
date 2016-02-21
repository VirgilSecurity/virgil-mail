namespace Virgil.Mail.Services
{
    using System;
    using System.Collections.Generic;

    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Models;

    internal class AccountsManager : IAccountsManager
    {
        private readonly IOutlookInteraction outlook;
        private readonly IAccountsStorage storage;

        public AccountsManager(IAccountsStorage storage, IOutlookInteraction outlook)
        {
            this.storage = storage; 
            this.outlook = outlook;
        }   

        public IEnumerable<VirgilAccountModel> GetAccounts()
        {
            var outlookAccounts = this.outlook.GetOutlookAccounts();
            outlookAccounts.Select(oa => new {
                OutlookAccount = oa,
                VirgilAccount = this.storage.HasAccount this.storage.GetAccounts()
            })
        }
    }
}
