namespace Virgil.Mail.Storage
{
    using System;
    
    public class AccountStorageModel
    {
        public Guid CardId { get; set; } 
        public string Email { get; set; }
        public byte[] PublicKey { get; set; }
    }
}
