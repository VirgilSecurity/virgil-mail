namespace Virgil.Mail.Models
{
    using System;

    public class RecipientSearchResultModel
    {
        public string Identity  { get; set; }
        public bool IsFound => this.CardId.HasValue && this.PublicKeyId.HasValue && this.PublicKey != null;
        public Guid? CardId      { get; set; }
        public Guid? PublicKeyId { get; set; }
        public byte[] PublicKey { get; set; }
    }
}