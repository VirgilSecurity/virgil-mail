namespace Virgil.Mail.Common.Models
{
    using System;

    public class VirgilKeyPairModel
    {
        public Guid Id { get; set; }
        public byte[] PublicKey { get; set; }
        public byte[] PrivateKey { get; set; }
    }
}
