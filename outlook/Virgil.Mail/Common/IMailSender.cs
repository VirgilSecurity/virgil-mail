namespace Virgil.Mail.Common
{
    using Outlook = Microsoft.Office.Interop.Outlook;

    public interface IMailSender : IService
    {
        bool EncryptAndSend(Outlook.MailItem mailItem);
    }
}