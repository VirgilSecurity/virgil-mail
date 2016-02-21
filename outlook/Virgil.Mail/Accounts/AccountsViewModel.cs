namespace Virgil.Mail.Accounts
{
    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Mvvm;

    public class AccountsViewModel : ViewModel
    {
        private readonly IOutlookInteraction outlook;

        public AccountsViewModel(IOutlookInteraction outlook)
        {
            this.outlook = outlook;
        }

        internal void Initialize()
        {
        }
    }
}
