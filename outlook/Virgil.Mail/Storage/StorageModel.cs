namespace Virgil.Mail.Storage
{
    using System.Collections.Generic;

    public class StorageModel
    {
        public IEnumerable<AccountStorageModel> Accounts { get; set; }
    }
}
