namespace Virgil.Mail.Accounts
{
    using System.Collections.Generic;
    using System.Linq;
    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Models;
    using Virgil.Mail.Models;

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
            var virgilAccountModels = outlookAccounts.Select(it => new VirgilAccountModel
            {
                OutlookAccountDescription = it.Description,
                OutlookAccountEmail = it.Email
            });

            return virgilAccountModels;
        }
    }
}
