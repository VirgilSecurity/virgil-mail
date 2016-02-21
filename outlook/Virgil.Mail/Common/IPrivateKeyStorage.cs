namespace Virgil.Mail.Common
{
    using System;

    using Virgil.Mail.Common.Models;

    public interface IVirgilCryptoProvider : IService
    {
        void Store(Guid id, byte[] privateKey);
    }
}
