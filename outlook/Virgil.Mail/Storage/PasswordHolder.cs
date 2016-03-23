namespace Virgil.Mail.Storage
{
    using log4net;
    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Exceptions;
    using Virgil.Mail.Models;
    using Virgil.Mail.Properties;

    public class PasswordHolder : IPasswordHolder
    {
        private static readonly ILog Logger = LogManager.GetLogger(typeof(PasswordHolder));
        private readonly IEncryptedKeyValueStorage keysStorage;

        public PasswordHolder(IEncryptedKeyValueStorage keysStorage)
        {
            this.keysStorage = keysStorage;
        }
        
        public void Keep(string identity, string password)
        {
            Logger.InfoFormat(Resources.Log_Info_PasswordHolder_SetAccountPrivateKeyPassword);

            this.keysStorage.Set($"password_{identity}".ToUpper(), new PasswordStorageModel { Password = password });
        }

        public void Remove(string identity)
        {
            Logger.InfoFormat(Resources.Log_Info_PasswordHolder_RemoveAccountPrivateKeyPassword);

            this.keysStorage.Delete($"password_{identity}".ToUpper());
        }

        public string Get(string identity)
        {
            Logger.InfoFormat(Resources.Log_Info_PasswordHolder_GetAccountPrivateKeyPassword);

            var passwordModel = this.keysStorage.Get<PasswordStorageModel>($"password_{identity}".ToUpper());
            if (passwordModel == null)
            {
                throw new PrivateKeyPasswordIsNotFoundException();
            }

            return passwordModel.Password;
        }
    }
}