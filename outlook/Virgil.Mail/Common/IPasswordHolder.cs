namespace Virgil.Mail.Common
{
    using System;
    using System.Security;

    public interface IPasswordHolder : IService
    {
        void Keep(Guid id, SecureString password);
        SecureString Get(Guid id);
    }
}
