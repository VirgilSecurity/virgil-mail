namespace Virgil.Mail.Models
{
    using System;
    using System.Collections.Generic;

    public class AccountModel
    {
        public string VirgilCardId { get; set; }

        public string OutlookAccountDescription { get; set; }
        public string OutlookAccountEmail { get; set; }

        public bool IsPrivateKeyPasswordNeedToStore { get; set; }
        public bool IsPrivateKeyHasPassword { get; set; }
        public bool IsVirgilPrivateKeyStorage { get; set; }
        public DateTime? LastPrivateKeySyncDateTime { get; set; }

        public bool IsRegistered => default(string) != this.VirgilCardId;
    }
}
