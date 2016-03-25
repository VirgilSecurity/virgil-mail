namespace Virgil.Mail.Accounts
{
    using System;
    using System.Linq;
    using System.Collections.ObjectModel;
    using System.Diagnostics;
    using System.IO;
    using System.Reflection;
    using log4net;
    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Mvvm;
    using Virgil.Mail.Models;
    using Virgil.Mail.Mvvm;

    public class AccountsViewModel : ViewModel
    {
        private static readonly ILog Logger = LogManager.GetLogger(typeof(AccountsViewModel));

        private readonly IAccountsManager accountsManager;
        private readonly IDialogPresenter dialogPresenter;

        public AccountsViewModel(IAccountsManager accountsManager, IDialogPresenter dialogPresenter)
        {
            this.accountsManager = accountsManager;
            this.dialogPresenter = dialogPresenter;

            this.Accounts = new ObservableCollection<AccountModel>();

            this.ManageAccountCommand = new RelayCommand<AccountModel>(this.ManageAccount);
            this.CompanyRedirectCommand = new RelayCommand(this.CompanyRedirect);
            this.CheckForUpdatesCommand = new RelayCommand(this.CheckForUpdates);
        }
        
        public RelayCommand CheckForUpdatesCommand { get; private set; }
        public RelayCommand CompanyRedirectCommand { get; private set; }
        public RelayCommand<AccountModel> ManageAccountCommand { get; private set; }

        public ObservableCollection<AccountModel> Accounts { get; set; }

        public string Version
        {
            get
            {
                var assembly = Assembly.GetExecutingAssembly();

                var fvi = FileVersionInfo.GetVersionInfo(assembly.Location);
                var version = fvi.FileVersion;
                
                return version;
            }
        }

        internal void Initialize()
        {
            this.Accounts.Clear();
            
            var accounts = this.accountsManager.GetAccounts().ToList();
            accounts.ForEach(this.Accounts.Add);
        }

        private void CompanyRedirect()
        {
            
            Process.Start("https://www.virgilsecurity.com/");
        }

        private void CheckForUpdates()
        {
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

                Process.Start(Path.Combine(clickOnceLocation, "VirgilMailUpdater.exe"));
            }
            catch (Exception ex)
            {
                Logger.ErrorFormat("Updating failure: {0}", ex.Message);
            }
        }

        private void ManageAccount(AccountModel accountModel)
        {
            if (!accountModel.IsRegistered)
            {
                this.dialogPresenter.ShowRegisterAccount(accountModel);
            }
            else
            {
                this.dialogPresenter.ShowAccountSettings(accountModel);
            }
            
            this.Initialize();
        }
    }
}
