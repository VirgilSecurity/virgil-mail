namespace Virgil.Mail.Common
{
    using Virgil.Mail.Models;

    public interface IVirgilCryptoProvider : IService
    {
        VirgilKeyPairModel CreateKeyPair(string identity, string password = null);
    }
}
