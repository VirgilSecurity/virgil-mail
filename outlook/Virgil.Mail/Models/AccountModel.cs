namespace Virgil.Mail.Models
{
    using System;
    using System.Collections.Generic;

    public class AccountModel
    {
        public Guid VirgilCardId { get; set; }
        public string VirgilCardHash { get; set; }
        public Guid VirgilPublicKeyId { get; set; }
        public byte[] VirgilPublicKey { get; set; }
        public IDictionary<string, string> VirgilCardCustomData { get; set; }

        public string OutlookAccountDescription { get; set; }
        public string OutlookAccountEmail { get; set; }

        public bool IsRegistered => default(Guid) != this.VirgilCardId;
    }
}   
    