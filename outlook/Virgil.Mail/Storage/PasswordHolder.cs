namespace Virgil.Mail.Storage
{
    using Virgil.Mail.Common;
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

        public string Get(string identity)
        {
            var password = this.keysStorage.Get<PasswordStorageModel>($"password_{identity}".ToUpper()).Password;
            return password;
        }
    }
}