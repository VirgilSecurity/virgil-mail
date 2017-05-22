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

        public PasswordExactor(
            IPasswordHolder passwordHolder, 
            IDialogPresenter presenter, 
            IAccountsManager accountsManager)
        {
            this.passwordHolder = passwordHolder;
            this.presenter = presenter;
            this.accountsManager = accountsManager;
        }
        
        public string ExactOrAlarm(string accountSmtpAddress)
        {
            var account = this.accountsManager.GetAccount(accountSmtpAddress);
 
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

            var enteredPassword = this.presenter.ShowPrivateKeyPassword(account.OutlookAccountEmail, account.VirgilCardId);

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