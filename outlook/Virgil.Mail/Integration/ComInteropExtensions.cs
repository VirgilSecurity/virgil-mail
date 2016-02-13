namespace Virgil.Mail.Integration
{
    using System.Runtime.InteropServices;

    using Outlook = Microsoft.Office.Interop.Outlook;

    internal static class ComInteropExtensions
    {
        /// <summary>
        /// Releases the Outlook Mail object.
        /// </summary>
        internal static void ReleaseCom(this Outlook.MailItem comObject)
        {
            InternalReleaseCom(comObject);
        }

        /// <summary>
        /// Releases the Outlook Selection object.
        /// </summary>
        internal static void ReleaseCom(this Outlook.Selection comObject)
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
