namespace Virgil.Mail.Storage
{
    using System;
    using log4net;
    using Virgil.Crypto;
    using Virgil.Mail.Common;
    using Virgil.Mail.Models;

    public class PrivateKeysStorage : IPrivateKeysStorage
    {
        private static readonly ILog Logger = LogManager.GetLogger(typeof(PrivateKeysStorage));
        private readonly IEncryptedKeyValueStorage keysStorage;

        public PrivateKeysStorage(IEncryptedKeyValueStorage keysStorage)
        {
            this.keysStorage = keysStorage;
        }

        public void StorePrivateKey(Guid id, byte[] privateKey)
        {
            Logger.InfoFormat("Storing a Private Key in encrypted storage");

            this.keysStorage.Set(id.ToString(), new PrivateKeyStorageModel { PrivateKey = privateKey });
        }

        public byte[] GetPrivateKey(Guid id)
        {
            Logger.InfoFormat("Getting Private Key from encrypted storage");

            var privateKey = this.keysStorage.Get<PrivateKeyStorageModel>(id.ToString()).PrivateKey;
            return privateKey;
        }

        public bool HasPrivateKeyPassword(Guid id)
        {
            Logger.InfoFormat("Checking if Private Key has a password");

            var privateKey = this.GetPrivateKey(id);
            return VirgilKeyPair.IsPrivateKeyEncrypted(privateKey);
        }
    }
}