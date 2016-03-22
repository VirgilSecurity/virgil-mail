namespace Virgil.Mail.Common
{
    using System.Collections.Generic;
    using Virgil.Mail.Integration;

    public interface IOutlookInteraction : IService
    {
        IEnumerable<AccountIntegrationModel> GetOutlookAccounts();
        void MarkMailAsRead(string mailId);
        void DeleteMail(string mailId);
        void DeleteAttachment(Microsoft.Office.Interop.Outlook.MailItem mail, string attachmentName);
        void UnJunkMailById(string mailId);
    }
}
