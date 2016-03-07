namespace Virgil.Mail.Accounts
{
    using System;
    using System.Text;
    using System.Windows.Input;

    using Newtonsoft.Json;

    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Mvvm;
    using Virgil.Mail.Models;
    using Virgil.Mail.Mvvm;
    using Virgil.SDK.Infrastructure;

    public class AccountSettingsViewModel : ViewModel
    {
        private readonly IDialogPresenter dialogPresenter;
        private readonly IPrivateKeysStorage cryptoProvider;
        private readonly IPasswordHolder passwordHolder;
        private readonly IAccountsManager accountsManager;
        private readonly IPasswordExactor passwordExactor;
        private readonly VirgilHub virgilHub;

        private AccountModel account;
        private bool isPrivateKeyPasswordNeedToStore;
        private bool isPrivateKeyHasPassword;
        private bool canUploadToCloud;

        public AccountSettingsViewModel
        (
            IDialogPresenter dialogPresenter, 
            IPrivateKeysStorage cryptoProvider,
            IPasswordHolder passwordHolder,
            IAccountsManager accountsManager,
            IPasswordExactor passwordExactor,
            VirgilHub virgilHub
        )
        {
            this.dialogPresenter = dialogPresenter;
            this.cryptoProvider = cryptoProvider;
            this.passwordHolder = passwordHolder;
            this.accountsManager = accountsManager;
            this.passwordExactor = passwordExactor;
            this.virgilHub = virgilHub;

            this.ExportCommand = new RelayCommand(this.Export);
            this.RemoveCommand = new RelayCommand(this.Remove);
            this.RemovePrivateKeyFromCloudCommand = new RelayCommand(this.RemovePrivateKeyFromCloud);
            this.UploadPrivateKeyToCloudCommand = new RelayCommand(this.UploadPrivateKeyToCloud);
        }

        public ICommand RemovePrivateKeyFromCloudCommand { get; set; }
        public ICommand UploadPrivateKeyToCloudCommand { get; set; }
        public ICommand ExportCommand { get; private set; }
        public ICommand RemoveCommand { get; private set; }

        public bool IsPrivateKeyPasswordNeedToStore
        {
            get { return this.isPrivateKeyPasswordNeedToStore; }
            set
            {
                this.isPrivateKeyPasswordNeedToStore = value;
                
                if (this.account.IsPrivateKeyPasswordNeedToStore != value)
                {
                    this.account.IsPrivateKeyPasswordNeedToStore = value;
                    this.accountsManager.UpdateAccount(this.account);

                    if (!value)
                    {
                        this.passwordHolder.Remove(this.account.OutlookAccountEmail);
                    }
                }

                this.RaisePropertyChanged();
            }
        }

        public bool IsPrivateKeyHasPassword
        {
            get { return this.isPrivateKeyHasPassword; }
            set
            {
                this.RaisePropertyChanged();
                this.isPrivateKeyHasPassword = value;
            }
        }

        public bool CanUploadToCloud
        {
            get { return this.canUploadToCloud; }
            set
            {
                
                this.canUploadToCloud = value;
                this.RaisePropertyChanged();
            }
        }
        
        public void Initialize(AccountModel accountModel)
        {
            this.account = accountModel;

            this.ChangeState(AccountSettingsState.Settings);

            this.IsPrivateKeyHasPassword = this.cryptoProvider.HasPrivateKeyPassword(this.account.VirgilCardId);
            this.IsPrivateKeyPasswordNeedToStore = this.account.IsPrivateKeyPasswordNeedToStore;

            if (this.account.IsVirgilPrivateKeyStorage && !this.account.LastPrivateKeySyncDateTime.HasValue)
            {
                this.CanUploadToCloud = true;
                return;
            }

            if (!this.account.IsVirgilPrivateKeyStorage)
            {
                this.CanUploadToCloud = true;
            }
        }

        private void Remove()
        {
            var result = this.dialogPresenter.ShowConfirmation("Delete Account Keys",
                "Are you sure you want to delete an account's key?");
            
            if (result)
            {
                this.accountsManager.Remove(this.account.OutlookAccountEmail);
                this.Close();
            }
        }

        private async void UploadPrivateKeyToCloud()
        {
            this.ClearErrors();

            try
            {
                this.ChangeState(AccountSettingsState.Processing, "Uploading Private Key....");

                var privateKey = this.cryptoProvider.GetPrivateKey(this.account.VirgilCardId);

                var privateKeyPassword = this.passwordExactor.ExactOrAlarm(this.account.OutlookAccountEmail);

                await this.virgilHub.PrivateKeys.Stash(this.account.VirgilCardId, privateKey, privateKeyPassword);

                this.CanUploadToCloud = false;

                this.account.IsVirgilPrivateKeyStorage = true;
                this.account.LastPrivateKeySyncDateTime = DateTime.Now;

                this.accountsManager.UpdateAccount(this.account);
            }
            catch (Exception ex)
            {
                this.AddCustomError(ex.Message);
            }
            finally
            {
                this.ChangeState(AccountSettingsState.Settings);
            }
        }

        private async void RemovePrivateKeyFromCloud()
        {
            this.ClearErrors();

            try
            {
                this.ChangeState(AccountSettingsState.Processing, "Removing Private Key....");

                var privateKey = this.cryptoProvider.GetPrivateKey(this.account.VirgilCardId);
                var privateKeyPassword = this.passwordExactor.ExactOrAlarm(this.account.OutlookAccountEmail);

                await this.virgilHub.PrivateKeys.Destroy(this.account.VirgilCardId, privateKey, privateKeyPassword);

                this.CanUploadToCloud = true;

                this.account.IsVirgilPrivateKeyStorage = false;
                this.account.LastPrivateKeySyncDateTime = null;

                this.accountsManager.UpdateAccount(this.account);
            }
            catch (Exception ex)
            {
                this.AddCustomError(ex.Message);
            }
            finally
            {
                this.ChangeState(AccountSettingsState.Settings);
            }
        }

        private void Export()
        {
            var exportObject = new
            {
                card = new
                {
                    id = this.account.VirgilCardId,
                    idenity = new
                    {
                        value = this.account.OutlookAccountEmail.ToLower(),
                        type = "email"
                    },
                    public_key = new
                    {
                        id = this.account.VirgilPublicKeyId,
                        value = this.account.VirgilPublicKey
                    }
                },
                private_key = this.cryptoProvider.GetPrivateKey(this.account.VirgilCardId)
            };

            var exportJson = JsonConvert.SerializeObject(exportObject);
            var exportBytes = Encoding.UTF8.GetBytes(exportJson);
            var exportBase64 = Convert.ToBase64String(exportBytes);

            var fileName = this.account.OutlookAccountDescription.ToLower().Replace(" ", "_");
            this.dialogPresenter.SaveFile(fileName, exportBase64, "vcard");
        }
    }
}