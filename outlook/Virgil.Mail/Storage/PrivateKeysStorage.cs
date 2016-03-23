namespace Virgil.Mail.Storage
{
    using System;
    using log4net;
    using Virgil.Crypto;
    using Virgil.Mail.Common;
    using Virgil.Mail.Models;
    using Virgil.Mail.Properties;

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
            Logger.InfoFormat(Resources.Log_Info_PrivateKeysStorage_StorePrivateKey);

            this.keysStorage.Set(id.ToString(), new PrivateKeyStorageModel { PrivateKey = privateKey });
        }

        public byte[] GetPrivateKey(Guid id)
        {
            Logger.InfoFormat(Resources.Log_Info_PrivateKeysStorage_GetPrivateKey);

            var privateKey = this.keysStorage.Get<PrivateKeyStorageModel>(id.ToString()).PrivateKey;
            return privateKey;
        }

        public bool HasPrivateKeyPassword(Guid id)
        {
            Logger.InfoFormat(Resources.Log_Info_PrivateKeysStorage_HasPrivateKeyPassword);

            var privateKey = this.GetPrivateKey(id);
            return VirgilKeyPair.IsPrivateKeyEncrypted(privateKey);
        }

        public void RemovePrivateKey(Guid id)
        {
            this.keysStorage.Delete(id.ToString());
        }
    }
}