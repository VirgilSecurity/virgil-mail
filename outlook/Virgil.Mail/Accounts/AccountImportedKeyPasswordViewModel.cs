using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Virgil.Mail.Common;
using Virgil.SDK;

namespace Virgil.Mail.Accounts
{
    class AccountImportedKeyPasswordViewModel : AccountKeyPasswordViewModel
    {
        protected VirgilBuffer keyValue;


        public AccountImportedKeyPasswordViewModel(IPasswordHolder passwordHolder, IAccountsManager accountsManager) : base(passwordHolder, accountsManager)
        {
        }

        public void Initialize(string accountSmtpAddress, string checkingKeyName, VirgilBuffer keyValue)
        {
            base.Initialize(accountSmtpAddress, checkingKeyName);
            this.keyValue = keyValue;
        }


        protected new void TryPassword(string password)
        {
            var virgil = new VirgilApi();
            virgil.Keys.Import(this.keyValue, password);
        }


    }
}
