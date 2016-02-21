namespace Virgil.Mail.Common
{
    using System.Collections.Generic;
    using Virgil.Mail.Integration;

    public interface IOutlookInteraction : IService
    {
        IEnumerable<AccountIntegrationModel> GetOutlookAccounts();
    }
}
