namespace Virgil.Mail.Accounts
{
    using System;
    using Virgil.Mail.Common.Messaging;

    public class AccountUpdatedMessage : IMessage
    {
        public AccountUpdatedMessage(String cardId)
        {
            this.CardId = cardId;
        }

        public String CardId { get; private set; }
    }
}