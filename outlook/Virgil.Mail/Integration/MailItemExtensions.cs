﻿namespace Virgil.Mail.Integration
{
    using System;
    using System.Text;
    using System.Text.RegularExpressions;
    using System.Linq;

    using HtmlAgilityPack;
    using Newtonsoft.Json;
    
    using Virgil.Mail.Common;
    using Virgil.Mail.Models;

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
            var isVirgilMail = mailItem.Attachments
                .Cast<Outlook.Attachment>()
                .ToList()
                .Any(it => it.FileName.Equals(Constants.VirgilAttachmentName));

            if (isVirgilMail)
            {
                return true;
            }

            var htmlDoc = new HtmlDocument();
            htmlDoc.LoadHtml(mailItem.HTMLBody);

            var virgilElem = htmlDoc.GetElementbyId(Constants.VirgilHtmlBodyElementId);
            return virgilElem != null;
        }

        /// <summary>
        /// Parses the Outlook <see cref="Outlook.MailItem"/> to intermediate model <see cref="VirgilMailModel"/>
        /// that represents a Virgil Mail required properties.
        /// </summary>
        /// <param name="mailItem">The Outlook mail to be parsed.</param>
        /// <returns>Instance of <see cref="VirgilMailModel"/> object.</returns>
        internal static VirgilMailModel Parse(this Outlook.MailItem mailItem)
        {
            var htmlDoc = new HtmlDocument();
            htmlDoc.LoadHtml(mailItem.HTMLBody);

            var virgilElem = htmlDoc.GetElementbyId(Constants.VirgilHtmlBodyElementId);
            var valueBase64 = virgilElem?.GetAttributeValue("value", "");

            if (!string.IsNullOrWhiteSpace(valueBase64))
            {
                var value = Convert.FromBase64String(valueBase64);
                var json = Encoding.UTF8.GetString(value);
                var messageInfo = JsonConvert.DeserializeObject<VirgilMailModel>(json);

                return messageInfo;
            }

            return null;
        }
        
        /// <summary>
        /// Sets the SMTP header value by given name. If propery doesn't exists it will create it.
        /// </summary>
        internal static void MarkAsVirgilMail(this Outlook.MailItem mailItem)
        {
            if (mailItem.MessageClass.Equals(Constants.VirgilMessageClass))
            {
                return;
            }

            // check if an email contains a body that represents a virgil mail
            // encrypted structure.

            if (mailItem.IsVirgilMail())
            {
                mailItem.MessageClass = Constants.VirgilMessageClass;
                mailItem.Save();
            }
        }

        /// <summary>
        /// Extracts the mail outlook account address.
        /// </summary>
        internal static string ExtractReciverEmailAddress(this Outlook.MailItem mail)
        {
            var propertyValue = mail.PropertyAccessor.GetProperty("http://schemas.microsoft.com/mapi/proptag/0x0076001F") as string;
            return propertyValue;
        }

        internal static string ExtractSenderEmailAddress(this Outlook.MailItem mail)
        {
            var PR_SMTP_ADDRESS = @"http://schemas.microsoft.com/mapi/proptag/0x39FE001E";

            if (mail == null)
            {
                throw new ArgumentNullException();
            }

            if (mail.SenderEmailType == "EX")
            {
                Outlook.AddressEntry sender =
                    mail.Sender;
                if (sender != null)
                {
                    //Now we have an AddressEntry representing the Sender
                    if (sender.AddressEntryUserType == Outlook.OlAddressEntryUserType.olExchangeUserAddressEntry || sender.AddressEntryUserType == Outlook.OlAddressEntryUserType.
                        olExchangeRemoteUserAddressEntry)
                    {
                        //Use the ExchangeUser object PrimarySMTPAddress
                        Outlook.ExchangeUser exchUser =
                            sender.GetExchangeUser();

                        return exchUser?.PrimarySmtpAddress;
                    }

                    return sender.PropertyAccessor.GetProperty(PR_SMTP_ADDRESS) as string;
                }

                return null;
            }

            return mail.SenderEmailAddress;
        }
    }
}