namespace Virgil.Mail.Common
{
    using Outlook = Microsoft.Office.Interop.Outlook;

    public interface IMailSender : IService
    {
        void EncryptAndSend(Outlook.MailItem mailItem);
    }
}