namespace Virgil.Mail.Crypto
{
    using System.Text;
    using Virgil.Crypto;

    using Virgil.Mail.Common;
    using Virgil.Mail.Models;

    public class VirgilCryptoProvider : IVirgilCryptoProvider
    {
        private readonly IEncryptedKeyValueStorage keysStorage;

        public VirgilCryptoProvider(IEncryptedKeyValueStorage keysStorage)
        {
            this.keysStorage = keysStorage;
        }

        public VirgilKeyPairModel CreateKeyPair(string identity, string password = null)
        {
            var keyPair = string.IsNullOrEmpty(password)
                ? VirgilKeyPair.Generate(VirgilKeyPair.Type.Default)
                : VirgilKeyPair.Generate(VirgilKeyPair.Type.Default, Encoding.UTF8.GetBytes(password));

            var keyPairModel = new VirgilKeyPairModel
            {
                Identity = identity,
                PublicKey = keyPair.PublicKey(),
                PrivateKey = keyPair.PrivateKey()
            };

            this.keysStorage.Set(identity, keyPairModel);
            return keyPairModel;
        }
    }
}