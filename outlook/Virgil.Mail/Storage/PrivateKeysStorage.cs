namespace Virgil.Mail.Storage
{
    using System;

    using Virgil.Crypto;
    using Virgil.Mail.Common;
    using Virgil.Mail.Models;

    public class PrivateKeysStorage : IPrivateKeysStorage
    {
        private readonly IEncryptedKeyValueStorage keysStorage;

        public PrivateKeysStorage(IEncryptedKeyValueStorage keysStorage)
        {
            this.keysStorage = keysStorage;
        }

        public void StorePrivateKey(Guid id, byte[] privateKey)
        {
            this.keysStorage.Set(id.ToString(), new PrivateKeyStorageModel { PrivateKey = privateKey });
        }

        public byte[] GetPrivateKey(Guid id)
        {
            var privateKey = this.keysStorage.Get<PrivateKeyStorageModel>(id.ToString()).PrivateKey;
            return privateKey;
        }

        public bool HasPrivateKeyPassword(Guid id)
        {
            var privateKey = this.GetPrivateKey(id);
            return VirgilKeyPair.IsPrivateKeyEncrypted(privateKey);
        }
    }
}