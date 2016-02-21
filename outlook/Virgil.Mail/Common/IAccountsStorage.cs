namespace Virgil.Mail.Common
{
    using System.Collections.Generic;

    using Virgil.Mail.Storage;

    public interface IAccountsStorage : IService
    {
        IEnumerable<AccountStorageModel> GetAccounts();
    }
}
