namespace Virgil.Mail.Dialogs
{
    using Virgil.Crypto;
    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Exceptions;

    public class PasswordExactor : IPasswordExactor
    {
        private readonly IPasswordHolder passwordHolder;
        private readonly IDialogPresenter presenter;
        private readonly IAccountsManager accountsManager;
        private readonly IPrivateKeysStorage privateKeysStorage;

        public PasswordExactor(
            IPasswordHolder passwordHolder, 
            IDialogPresenter presenter, 
            IAccountsManager accountsManager,
            IPrivateKeysStorage privateKeysStorage)
        {
            this.passwordHolder = passwordHolder;
            this.presenter = presenter;
            this.accountsManager = accountsManager;
            this.privateKeysStorage = privateKeysStorage;
        }
        
        public string ExactOrAlarm(string accountSmtpAddress)
        {
            var account = this.accountsManager.GetAccount(accountSmtpAddress);
            var privateKey = this.privateKeysStorage.GetPrivateKey(account.VirgilCardId);

            if (!VirgilKeyPair.IsPrivateKeyEncrypted(privateKey))
            {
                return null;
            }

            var isNotSet = false;

            // check if password can be extracted from password storage.

            if (account.IsPrivateKeyPasswordNeedToStore)
            {
                try
                {
                    return this.passwordHolder.Get(accountSmtpAddress);
                }
                catch (PrivateKeyPasswordIsNotFoundException)
                {
                    isNotSet = true;
                }
            }

            var enteredPassword = this.presenter.ShowPrivateKeyPassword(account.OutlookAccountEmail, privateKey);

            if (string.IsNullOrEmpty(enteredPassword))
            {
                throw new PasswordExactionException();
            }

            if (isNotSet)
            {
                this.passwordHolder.Keep(accountSmtpAddress, enteredPassword);
            }

            return enteredPassword;
        }
    }
}