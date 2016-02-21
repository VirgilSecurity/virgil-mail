namespace Virgil.Mail.Storage
{
    using System;
    using System.Linq;
    using System.Collections.Generic;
    using System.Security.Cryptography;

    using Newtonsoft.Json;

    using Virgil.Mail.Common;

    internal class AccountsStorage : IAccountsStorage
    {   
        private readonly IStorageProvider storageProvider;
        private static readonly byte[] Entropy = { 91, 83, 7, 36, 1, 15, 123 };

        internal AccountsStorage(IStorageProvider storageProvider)
        {
            this.storageProvider = storageProvider;
        }

        public IEnumerable<AccountStorageModel> GetAccounts()
        {
            var storageModel = this.Load();

            var accounts = storageModel.Accounts;
            
            return accounts;
        }

        public bool HasAccount(string email)
        {
            var storageModel = this.Load();

            var hasAccount = storageModel.Accounts.Any(a =>
                a.Email.Equals(email, StringComparison.InvariantCultureIgnoreCase));

            return hasAccount;
        }

        public void AddAccount(AccountStorageModel account)
        {
            var storageModel = this.Load();

            var isAlreadyExists = storageModel.Accounts.Any(a => a.CardId == account.CardId);
            if (isAlreadyExists)
            {
                throw new ArgumentException("Account keys are already storing.");
            }

            storageModel.Accounts = storageModel.Accounts.Concat(new[] { account });

            this.Save(storageModel);
        }
        
        private void Save(StorageModel storageModel)
        {
            var stringData = JsonConvert.SerializeObject(storageModel);
            var data = System.Text.Encoding.UTF8.GetBytes(stringData);
            
            var encryptedData = ProtectedData.Protect(data, Entropy, DataProtectionScope.CurrentUser);
            var base64EncryptedData = Convert.ToBase64String(encryptedData);

            this.storageProvider.Save(base64EncryptedData);
        }

        private StorageModel Load()
        {
            var base64EncryptedData = this.storageProvider.Load();
            if (string.IsNullOrWhiteSpace(base64EncryptedData))
            {
                return new StorageModel { Accounts = new List<AccountStorageModel>() };
            }

            var encryptedData = Convert.FromBase64String(base64EncryptedData);

            var decryptedData = ProtectedData.Unprotect(encryptedData, Entropy, DataProtectionScope.CurrentUser);
            var stringData = System.Text.Encoding.UTF8.GetString(decryptedData);

            var storageModel = JsonConvert.DeserializeObject<StorageModel>(stringData);
            return storageModel;
        }
    }
}   
