namespace Virgil.Mail.Common.Models
{
    using System;

    public class VirgilRecipientModel
    {
        public Guid CardId { get; set; }
        public byte[] PublicKey { get; set; }
    }
}
