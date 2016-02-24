namespace Virgil.Mail.Integration
{
    using System.Runtime.InteropServices;

    using Outlook = Microsoft.Office.Interop.Outlook;

    internal static class ComInteropExtensions
    {
        internal static void ReleaseCom(this Outlook.MailItem comObject)
        {
            InternalReleaseCom(comObject);
        }
        
        internal static void ReleaseCom(this Outlook.Selection comObject)
        {
            InternalReleaseCom(comObject);
        }

        internal static void ReleaseCom(this Outlook.NameSpace comObject)
        {
            InternalReleaseCom(comObject);
        }
        
        internal static void ReleaseCom(this Outlook.Accounts comObject)
        {
            InternalReleaseCom(comObject);
        }
        
        internal static void ReleaseCom(this Outlook.Account comObject)
        {
            InternalReleaseCom(comObject);
        }

        internal static void ReleaseCom(this Outlook.Items comObject)
        {
            InternalReleaseCom(comObject);
        }

        private static void InternalReleaseCom(object comObject)
        {
            if (comObject != null)
            {
                Marshal.ReleaseComObject(comObject);
            }
        }
    }
}
