namespace Virgil.Mail.Common
{
    using SDK;
    using Virgil.Mail.Models;

    public interface IDialogPresenter : IService
    {
        string ShowPrivateKeyPassword(string accountEmail, string keyName);
        string ShowImportedPrivateKeyPassword(string accountEmail, string keyName, VirgilBuffer keyValue);
        void ShowRegisterAccount(AccountModel accountModel);
        void ShowAccounts();
        void ShowAccountSettings(AccountModel accountModel);
        bool ShowConfirmation(string caption, string message);

        void SaveFile(string fileName, string content, string extension);
        string OpenFile(string extension);
        void ShowAlert(string message);
        void SaveFile(string fileName, byte[] content, string extension);
    }
}
