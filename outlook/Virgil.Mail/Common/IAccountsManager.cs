namespace Virgil.Mail.Common
{
    using System.Collections.Generic;

    using Virgil.Mail.Common.Models;

    public interface IAccountsManager : IService
    {
        IEnumerable<VirgilAccountModel> GetAccounts();
    }
}
