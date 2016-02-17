namespace Virgil.Mail.Common
{
    using System.Collections.Generic;
    using Virgil.Mail.Models;

    internal interface IOutlookInteraction : IService
    {
        IEnumerable<OutlookAccountModel> GetOutlookAccounts();
    }
}
