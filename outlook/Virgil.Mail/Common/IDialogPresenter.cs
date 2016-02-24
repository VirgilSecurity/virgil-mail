namespace Virgil.Mail.Common
{
    using Virgil.Mail.Models;

    public interface IDialogPresenter : IService
    {
        void ShowRegisterAccount(AccountModel accountModel);
        void ShowAccounts();
        void ShowAccountSettings(AccountModel accountModel);
    }
}
