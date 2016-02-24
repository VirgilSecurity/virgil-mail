namespace Virgil.Mail.Common
{
    using System;
    using System.Collections.Generic;
    
    using Virgil.Mail.Models;

    public interface IAccountsManager : IService
    {
        IEnumerable<AccountModel> GetAccounts();
        void UpdateAccount(string indentity, Guid cardId, string cardHash, Dictionary<string, string> cardCustomData);
        AccountModel GetAccount(string identity);
    }
}
