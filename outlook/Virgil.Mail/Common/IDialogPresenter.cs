namespace Virgil.Mail.Common
{
    using Virgil.Mail.Models;

    public interface IDialogPresenter : IService
    {
        void ShowRegisterAccount(AccountModel accountModel);
        void ShowAccounts();
        void ShowAccountSettings(AccountModel accountModel);
        bool ShowConfirmation(string caption, string message);

        void SaveFile(string fileName, string content, string extension);
        string OpenFile(string extension);
    }
}
