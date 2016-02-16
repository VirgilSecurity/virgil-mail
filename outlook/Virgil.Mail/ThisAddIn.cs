namespace Virgil.Mail
{
    using System;
    using Virgil.Mail.Common;
    using Virgil.Mail.Integration;

    using Outlook = Microsoft.Office.Interop.Outlook;

    public partial class ThisAddIn
    {
        private string previousMailId;

        private Outlook.Explorer ActiveExplorer => this.Application.ActiveExplorer();

        private void OnAddInStartup(object sender, EventArgs e)
        {
            this.Application.ItemSend += OnApplicationMailSend;
            this.ActiveExplorer.SelectionChange += this.OnExplorerSelectionChange;
        }

        private void OnApplicationMailSend(object item, ref bool cancel)
        {
            Outlook.MailItem mail = (Outlook.MailItem)item;
            mail.MessageClass = Constants.VirgilMessageClass;
            mail.HTMLBody = string.Format(Constants.EmailHtmlBodyTemplate, "Encrypted");
        }

        private void OnAddInShutdown(object sender, EventArgs e)
        {
            // Note: Outlook no longer raises this event. If you have code that 
            // must run when Outlook shuts down, see http://go.microsoft.com/fwlink/?LinkId=506785
        }

        /// <summary>
        /// Occurs when the user selects a different or additional Microsoft Outlook by 
        /// interacting with the user interface.
        /// </summary>
        private void OnExplorerSelectionChange()
        {
            Outlook.Selection selection = null;
            Outlook.MailItem mail = null;

            try
            {
                selection = this.ActiveExplorer.Selection;
                if (selection == null || selection.Count == 0)
                {
                    return;
                }

                mail = selection[1] as Outlook.MailItem;
                if (mail == null)
                {
                    return;
                }

                // workaround to prevent multiple method execution.
                // return if current email already selected.

                // TODO: Damn, better to fix it... people will also be looking at it, maaaaan.

                if (this.previousMailId == mail.EntryID)
                {
                    return;
                }

                this.previousMailId = mail.EntryID;

                // ensure that the message has predefined virgil mail class.

                if (mail.MessageClass == Constants.VirgilMessageClass)
                {
                    return;
                }

                mail.MarkAsVirgilMail();
            }
            catch (Exception)
            {
                // MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            finally
            {
                selection.ReleaseCom();
                mail.ReleaseCom();
            }
        }

        #region VSTO generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InternalStartup()
        {
            this.Startup += this.OnAddInStartup;
            this.Shutdown += this.OnAddInShutdown;
        }
        
        #endregion
    }
}
