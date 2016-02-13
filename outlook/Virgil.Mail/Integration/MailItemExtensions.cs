namespace Virgil.Mail.Integration
{
    using System;
    using System.Text;
    using System.Text.RegularExpressions;
    using System.Linq;

    using HtmlAgilityPack;
    using Newtonsoft.Json;

    using Virgil.Mail.Models;
    using Virgil.Mail.Common;

    using Outlook = Microsoft.Office.Interop.Outlook;

    /// <summary>
    /// Provides extension methods for <see cref="Outlook.MailItem"/> item.
    /// </summary>
    internal static class MailItemExtensions
    {
        private static readonly Regex EmailFinder = new Regex(Constants.EmailFinderRegex, RegexOptions.Compiled);
        
        /// <summary>
        /// Checks if the Outlook Mail is contain the body with Virgil structure.
        /// </summary>
        /// <param name="mailItem">The Outlook Mail to be checked.</param>
        /// <returns>True, if mail has been sent with Virgil Mail plugin.</returns>
        internal static bool IsVirgilMail(this Outlook.MailItem mailItem)
        {
            var htmlDoc = new HtmlDocument();
            htmlDoc.LoadHtml(mailItem.HTMLBody);

            var virgilElem = htmlDoc.GetElementbyId(Constants.VirgilHtmlBodyElementId);
            return virgilElem != null;
        }

        /// <summary>
        /// Parses the Outlook <see cref="Outlook.MailItem"/> to intermediate model <see cref="VirgilMail"/>
        /// that represents a Virgil Mail required properties.
        /// </summary>
        /// <param name="mailItem">The Outlook mail to be parsed.</param>
        /// <returns>Instance of <see cref="VirgilMail"/> object.</returns>
        internal static VirgilMail Parse(this Outlook.MailItem mailItem)
        {
            var htmlDoc = new HtmlDocument();
            htmlDoc.LoadHtml(mailItem.HTMLBody);

            var virgilElem = htmlDoc.GetElementbyId(Constants.VirgilHtmlBodyElementId);
            if (virgilElem != null)
            {
                var valueBase64 = virgilElem.GetAttributeValue("value", "");
                if (!string.IsNullOrWhiteSpace(valueBase64))
                {
                    var value = Convert.FromBase64String(valueBase64);
                    var json = Encoding.UTF8.GetString(value);
                    var messageInfo = JsonConvert.DeserializeObject<VirgilMail>(json);

                    return messageInfo;
                }
            }

            return null;
        }
        
        /// <summary>
        /// Sets the SMTP header value by given name. If propery doesn't exists it will create it.
        /// </summary>
        internal static void MarkAsVirgilMail(this Outlook.MailItem mailItem)
        {
            if (!mailItem.MessageClass.Equals(Constants.VirgilMessageClass))
            {
                // check if an email contains a body that represents a virgil mail
                // encrypted structure.

                if (mailItem.IsVirgilMail())
                {
                    mailItem.MessageClass = Constants.VirgilMessageClass;
                    mailItem.Save();
                }
            }
        }
                
        /// <summary>
        /// Extracts the mail outlook account address.
        /// </summary>
        internal static string ExtractOutlookAccountEmailAddress(this Outlook.MailItem mail)
        {
            var folder = mail.Parent as Outlook.Folder;

            if (folder != null)
            {
                var path = folder.FullFolderPath;
                var ourEmail = path.Substring(2);
                var match = EmailFinder.Match(ourEmail);

                var captureCollection = match.Groups.Cast<Group>().FirstOrDefault();
                var capture = captureCollection?.Captures.Cast<Capture>().FirstOrDefault();
                if (capture != null)
                {
                    return capture.Value;
                }
            }

            return mail.To;
        }
    }
}