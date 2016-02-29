namespace Virgil.Mail.Models
{
    using System;

    public class VirgilRecipientModel
    {
        public Guid CardId { get; set; }
        public byte[] PublicKey { get; set; }
    }
}
