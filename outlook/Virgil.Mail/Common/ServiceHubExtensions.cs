namespace Virgil.SDK.Cards
{
    using System.Linq;
    using System.Threading.Tasks;

    using Virgil.SDK.Identities;
    using Virgil.SDK.Models;

    public static class ServiceHubExtensions
    {
        public static async Task<CardModel> SearchLatestOrDefault(this ICardsClient cardsClient, string emailAddress)
        {
            var cards = await cardsClient.Search(emailAddress, IdentityType.Email);
            var orderedCards = cards.OrderBy(it => it.CreatedAt);

            return orderedCards.LastOrDefault();
        }
    }
}