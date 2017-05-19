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

        public bool IsVirgilPrivateKeyStorage { get; set; }
        public DateTime? LastPrivateKeySyncDateTime { get; set; }

        public bool IsRegistered => default(string) != this.VirgilCardId;
    }
}


/*namespace Virgil.Mail.Models
{
    using SDK;
    using System;
    using System.Collections.Generic;

    public class AccountModel
    {
        public VirgilCard VirgilCard { get; set; }

        public string OutlookAccountDescription { get; set; }
        public string OutlookAccountEmail { get; set; }

        public bool IsPrivateKeyPasswordNeedToStore { get; set; }

        public DateTime? LastPrivateKeySyncDateTime { get; set; }

        public bool IsRegistered => default(String) != this.VirgilCard.Id;
    }
}*/
