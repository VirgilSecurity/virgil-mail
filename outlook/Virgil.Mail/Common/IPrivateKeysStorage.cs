namespace Virgil.Mail.Common
{
    using System;

    public interface IPrivateKeysStorage : IService
    {
        void StorePrivateKey(Guid id, byte[] privateKey);
        byte[] GetPrivateKey(Guid id);
        bool HasPrivateKeyPassword(Guid id);
        void RemovePrivateKey(Guid virgilCardId);
    }
}
