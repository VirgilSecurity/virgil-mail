namespace Virgil.Mail.Common
{
    using System.Collections.Generic;
    using Virgil.Mail.Integration;

    using Outlook = Microsoft.Office.Interop.Outlook;

    public interface IOutlookInteraction : IService
    {
        IEnumerable<AccountIntegrationModel> GetOutlookAccounts();
        void MarkMailAsRead(string mailId);
        void DeleteMail(string mailId);
        void DeleteAttachment(Outlook.MailItem mail, string attachmentName);
        void UnJunkMailById(string mailId);
        string GetCurrentOutlookAccountEmail();
        void SendEmail(string from, string emailTo, string subject, string body, Outlook.OlImportance importance = Outlook.OlImportance.olImportanceNormal);
        string GetOutlookAccountEmailForCurrentFolder();
    }
}
