namespace Virgil.Mail.Common
{
    using System.Collections.Generic;
    
    using Virgil.Mail.Models;

    public interface IAccountsManager : IService
    {
        AccountModel GetAccount(string identity);
        IEnumerable<AccountModel> GetAccounts();
        void UpdateAccount(AccountModel accountModel);
        void Remove(string outlookAccountEmail);
    }
}
