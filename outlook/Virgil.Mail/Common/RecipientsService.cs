namespace Virgil.Mail.Common
{
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading.Tasks;
    using Virgil.Mail.Models;
    using Virgil.SDK.Infrastructure;

    public class RecipientsService : IRecipientsService
    {
        private readonly VirgilHub hub;
        private readonly List<RecipientSearchResultModel> cache;

        public RecipientsService(VirgilHub hub)
        {
            this.hub = hub;
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
                .Select(r => this.hub.Cards.Search(r))
                .ToList();

            await Task.WhenAll(tasks);
            var searchResults = tasks.Select(it => it.Result).ToList();

            var recipients = new List<RecipientSearchResultModel>();
            foreach (var identity in identitiesToLoad)
            {
                var recipient = new RecipientSearchResultModel { Identity = identity };
                var searchResult = searchResults.SingleOrDefault(sr => sr.Any(c => c.Identity.Value.Equals(identity)));

                if (searchResult != null)
                {
                    var recipientCard = searchResult.OrderBy(it => it.CreatedAt).Last();
                    recipient.CardId = recipientCard.Id;
                    recipient.PublicKeyId = recipientCard.PublicKey.Id;
                    recipient.PublicKey = recipientCard.PublicKey.PublicKey;
                }

                // add to cache the found recipient.
                if (!this.cache.Exists(it => it.CardId == recipient.CardId) && recipient.IsFound)
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