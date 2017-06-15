[assembly: log4net.Config.XmlConfigurator(Watch = false)]
namespace Virgil.Mail
{
    using System;
    using System.Diagnostics;
    using System.IO;
    using System.Threading.Tasks;
    using System.Windows;
    using log4net;
    using Common;
    using Integration;
    using Outlook = Microsoft.Office.Interop.Outlook;
    using Common.Exceptions;

    public partial class ThisAddIn
    {
        private string previousMailId;

        private static readonly ILog Logger = LogManager.GetLogger(typeof(ThisAddIn));

        private Outlook.Explorer ActiveExplorer;
        private Outlook.Folders FoldersMAPI;
        private Outlook.Stores StoresMAPI;

        protected override Microsoft.Office.Core.IRibbonExtensibility CreateRibbonExtensibilityObject()
          {
              return new Ribbon();
         }

        /// <summary>
        /// Occurs when outlook tries to send new message.
        /// </summary>
        private void OnApplicationMailSend(object item, ref bool cancel)
        {
            Outlook.MailItem mail = null;

            try
            {
                mail = (Outlook.MailItem)item;

                if (!Properties.Settings.Default.AutoEncryptEmails)
                {
                    return;
                }

                var senderAccount = mail.ExtractSenderEmailAddress();
                if (!ServiceLocator.Accounts.IsRegistered(senderAccount))
                {
                    var accountModel = ServiceLocator.Accounts.GetAccount(senderAccount);

                    ServiceLocator.Dialogs.ShowRegisterAccount(accountModel);

                    if (!ServiceLocator.Accounts.IsRegistered(senderAccount))
                    {
                        cancel = true;
                        return;
                    }
                }

                if (!ServiceLocator.MailSender.EncryptAndSend(mail))
                {
                    cancel = true;
                }
            }
            catch(PasswordExactionException ex)
            {
                MessageBox.Show(ex.Message,
                                      @"Warning", MessageBoxButton.OK);
                cancel = true;

            }
            catch (Exception)
            {
                cancel = true;
                MessageBox.Show("Please restart the Outlook to use this account with the Virgil Mail Add-In.",
                                      @"Warning", MessageBoxButton.OK);
            }
            finally
            {
                mail.ReleaseCom();
            }
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

        /// <summary>
        /// Called when add-in stared up.
        /// </summary>
        private void OnAddInStartup(object sender, EventArgs e)
        {
            // Initialize log4net
            // XmlConfigurator.Configure();

            this.ActiveExplorer = this.Application.ActiveExplorer();
            
            // initialize bootstrapper.

            Bootstraper.Initialize(this.Application);

            // subscrube to outlook events
            this.Application.ItemSend += this.OnApplicationMailSend;
            this.ActiveExplorer.SelectionChange += this.OnExplorerSelectionChange;

            var ns = this.Application.GetNamespace("MAPI");

            this.FoldersMAPI = ns.Folders;
            this.StoresMAPI = ns.Stores;

            this.StoresMAPI.StoreAdd += new Outlook.StoresEvents_12_StoreAddEventHandler(this.OnFolderAdded);
            this.FoldersMAPI.FolderRemove += new Outlook.FoldersEvents_FolderRemoveEventHandler(this.OnFolderRemoved);

            CreateRibbonExtensibilityObject();

            this.CheckUpdates();
        }
        
        private void OnFolderAdded(object folder)
        {
            ServiceLocator.MessageBus.Publish(new Accounts.OutlookAccountsListUpdatedMessage());
        }

        private void OnFolderRemoved()
        {
            ServiceLocator.MessageBus.Publish(new Accounts.OutlookAccountsListUpdatedMessage());
        }

        /// <summary>
        /// Occurs when add-in shouted down.
        /// </summary>
        private void OnAddInShutdown(object sender, EventArgs e)
        {
            this.Application.ItemSend -= this.OnApplicationMailSend;
            this.ActiveExplorer.SelectionChange -= this.OnExplorerSelectionChange;

            this.StoresMAPI.StoreAdd -= new Outlook.StoresEvents_12_StoreAddEventHandler(this.OnFolderAdded);
            this.FoldersMAPI.FolderRemove -= new Outlook.FoldersEvents_FolderRemoveEventHandler(this.OnFolderRemoved);
        }

        private void CheckUpdates()
        {
            Task.Factory.StartNew(async () =>
            {
                await Task.Delay(30000);

                try
                {
                    //Get the assembly informationSystem.Reflection.Assembly
                    var assemblyInfo = System.Reflection.Assembly.GetExecutingAssembly();

                    //CodeBase is the location of the ClickOnce deployment files
                    var uriCodeBase = new Uri(assemblyInfo.CodeBase);
                    var clickOnceLocation = Path.GetDirectoryName(uriCodeBase.LocalPath);

                    if (clickOnceLocation == null)
                    {
                        throw new Exception("Application folder is not found.");
                    }

                    Process.Start(Path.Combine(clickOnceLocation, "VirgilMailUpdater.exe"), "/silent");
                }
                catch (Exception ex)
                {
                    Logger.ErrorFormat("Updating failure: {0}", ex.Message);
                }
            });
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
