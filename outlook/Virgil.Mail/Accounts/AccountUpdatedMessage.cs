namespace Virgil.Mail.Accounts
{
    using System;
    using Virgil.Mail.Common.Messaging;

    public class AccountUpdatedMessage : IMessage
    {
        public AccountUpdatedMessage(Guid cardId)
        {
            this.CardId = cardId;
        }

        public Guid CardId { get; private set; }
    }
}