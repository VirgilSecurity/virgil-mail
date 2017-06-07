namespace Virgil.Mail.Common
{
    using System.Collections.Generic;
    using System.Threading.Tasks;

    using Virgil.Mail.Models;

    public interface IRecipientsService
    {
        /// <summary>
        /// Searches the specified recipients by identity.
        /// </summary>
        IEnumerable<RecipientSearchResultModel> Search(string[] identities);
    }
}