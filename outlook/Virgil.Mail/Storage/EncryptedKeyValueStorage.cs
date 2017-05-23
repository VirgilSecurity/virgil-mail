namespace Virgil.Mail.Storage
{
    using System;
    using System.Security.Cryptography;
    using System.Text;

    using Newtonsoft.Json;

    using Virgil.Mail.Common;

    public class EncryptedKeyValueStorage : IEncryptedKeyValueStorage
    {
        private readonly IStorageProvider storageProvider;
        private static readonly byte[] Entropy = { 91, 83, 7, 36, 1, 15, 123 };

        public EncryptedKeyValueStorage(IStorageProvider storageProvider)
        {
            this.storageProvider = storageProvider;
        }

        public TValue Get<TValue>(string key) where TValue : class
        {
            var hashedKey = this.GetHash(key);

            var keyData = this.storageProvider[hashedKey];
            if (string.IsNullOrEmpty(keyData))
            {
                return default(TValue);
            }

            var encryptedData = Convert.FromBase64String(keyData);
            var decryptedData = ProtectedData.Unprotect(encryptedData, Entropy, DataProtectionScope.CurrentUser);

            var keyPairJson = Encoding.UTF8.GetString(decryptedData);
            var keyPairModel = JsonConvert.DeserializeObject<TValue>(keyPairJson);

            return keyPairModel;
        }

        public void Set<TValue>(string key, TValue value)
        {
            var hashedKey = this.GetHash(key);

            var stringData = JsonConvert.SerializeObject(value);
            var data = Encoding.UTF8.GetBytes(stringData);

            var encryptedData = ProtectedData.Protect(data, Entropy, DataProtectionScope.CurrentUser);
            var base64EncryptedData = Convert.ToBase64String(encryptedData);

            this.storageProvider.Add(hashedKey, base64EncryptedData);
        }

        public void Delete(string key)
        {
            this.storageProvider.Remove(this.GetHash(key));
        }

        private string GetHash(string value)
        {
            var hasher = new Crypto.Foundation.VirgilHash(Crypto.Foundation.VirgilHash.Algorithm.SHA384);
            var keyBytes = hasher.Hash(Encoding.UTF8.GetBytes(value));

            return Convert.ToBase64String(keyBytes).Replace("/", "");
        }
    }
}