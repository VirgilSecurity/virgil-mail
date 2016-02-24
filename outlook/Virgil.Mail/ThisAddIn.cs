﻿namespace Virgil.Mail
{
    using System;
    using System.Windows;

    using Virgil.Mail.Common;
    using Virgil.Mail.Integration;

    using Outlook = Microsoft.Office.Interop.Outlook;

    public partial class ThisAddIn
    {
        private string previousMailId;

        private Outlook.Explorer ActiveExplorer => this.Application.ActiveExplorer();

        private void OnApplicationMailSend(object item, ref bool cancel)
        {
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

                // ensure that selected item is Outlook Mail.

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

                // ensure that the message class has been set as virgil mail,
                // this requires to display custom reading pane for the mail item.               

                if (mail.MessageClass == Constants.VirgilMessageClass)
                {
                    return;
                }

                mail.MarkAsVirgilMail();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Fatal Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            finally
            {
                selection.ReleaseCom();
                mail.ReleaseCom();
            }
        }

        private void OnAddInStartup(object sender, EventArgs e)
        {
            // initialize bootstrapper.

            Bootstraper.Initialize(this.Application);

            // subscrube to outlook events

            this.Application.ItemSend += OnApplicationMailSend;
            this.ActiveExplorer.SelectionChange += this.OnExplorerSelectionChange;
        }

        private void OnAddInShutdown(object sender, EventArgs e)
        {
            // Note: Outlook no longer raises this event. If you have code that 
            // must run when Outlook shuts down, see http://go.microsoft.com/fwlink/?LinkId=506785
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