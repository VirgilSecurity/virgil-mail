namespace Virgil.Mail.Common
{
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading.Tasks;
    using SDK;
    using Models;

    public class RecipientsService : IRecipientsService
    {
        private readonly VirgilApi virgilApi;
        private readonly List<RecipientSearchResultModel> cache;

        public RecipientsService()
        {
            this.virgilApi = new VirgilApi();
            this.cache = new List<RecipientSearchResultModel>();
        }
        
        /// <summary>
        /// Searches the specified recipients by identity.
        /// </summary>
        public async Task<IEnumerable<RecipientSearchResultModel>> Search(string[] identities)
        {
            var cachedRecipients = this.cache
                .Where(it => identities.Contains(it.Identity))
                .ToList();

            var identitiesToLoad = identities
                .Except(cachedRecipients.Select(it => it.Identity))
                .ToList();

            var tasks = identitiesToLoad
                .Select(r => this.virgilApi.Cards.FindGlobalAsync(r))
                .ToList();

            await Task.WhenAll(tasks);
            var searchResults = tasks.Select(it => it.Result).ToList();

            var recipients = new List<RecipientSearchResultModel>();
            foreach (var identity in identitiesToLoad)
            {
                var recipient = new RecipientSearchResultModel { Identity = identity };
                var searchResult = searchResults.SingleOrDefault(sr => sr.Any(c => c.Identity.Equals(identity)));

                if (searchResult != null)
                {
                    recipient.virgilCard = searchResult.Last(); //OrderBy(it => it.CreatedAt)
                }

                // add to cache the found recipient.
                if (!this.cache.Exists(it => it.virgilCard.Id == recipient.virgilCard.Id) && recipient.IsFound)
                {
                    this.cache.Add(recipient);
                }

                recipients.Add(recipient);
            }
            
            recipients.AddRange(cachedRecipients);
            return recipients;
        }
    }
}