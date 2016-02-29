namespace Virgil.Mail.Storage
{
    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Exceptions;
    using Virgil.Mail.Models;

    public class PasswordHolder : IPasswordHolder
    {
        private readonly IEncryptedKeyValueStorage keysStorage;

        public PasswordHolder(IEncryptedKeyValueStorage keysStorage)
        {
            this.keysStorage = keysStorage;
        }
        
        public void Keep(string identity, string password)
        {
            this.keysStorage.Set($"password_{identity}".ToUpper(), new PasswordStorageModel { Password = password });
        }

        public void Remove(string identity)
        {
            this.keysStorage.Delete($"password_{identity}".ToUpper());
        }

        public string Get(string identity)
        {
            var passwordModel = this.keysStorage.Get<PasswordStorageModel>($"password_{identity}".ToUpper());
            if (passwordModel == null)
            {
                throw new PrivateKeyPasswordIsNotFoundException();
            }

            return passwordModel.Password;
        }
    }
}