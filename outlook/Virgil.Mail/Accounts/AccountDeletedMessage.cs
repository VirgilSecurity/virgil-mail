namespace Virgil.Mail.Accounts
{
    using Virgil.Mail.Common.Messaging;

    public class AccountDeletedMessage : IMessage
    {
        public AccountDeletedMessage(string cardId)
        {
            this.CardId = cardId;
        }

        public string CardId { get; private set; }
    }
}