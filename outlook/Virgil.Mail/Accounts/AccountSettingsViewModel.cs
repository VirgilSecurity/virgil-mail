namespace Virgil.Mail.Accounts
{
    using System;
    using System.Collections.Generic;
    using System.Text;
    using System.Threading.Tasks;
    using System.Windows.Input;
    using HtmlAgilityPack;
    using Newtonsoft.Json;

    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Mvvm;
    using Virgil.Mail.Models;
    using Virgil.Mail.Mvvm;
    using Virgil.SDK.Infrastructure;
    using Virgil.SDK.TransferObject;

    public class AccountSettingsViewModel : ViewModel
    {
        private readonly IDialogPresenter dialogPresenter;
        private readonly IPrivateKeysStorage privateKeysStorage;
        private readonly IPasswordHolder passwordHolder;
        private readonly IAccountsManager accountsManager;
        private readonly IPasswordExactor passwordExactor;
        private readonly IOutlookInteraction outlook;
        private readonly IMailObserver mailObserver;
        private readonly VirgilHub virgilHub;

        private AccountModel account;
        private bool isPrivateKeyPasswordNeedToStore;
        private bool isPrivateKeyHasPassword;
        private bool canUploadToCloud;

        public AccountSettingsViewModel
        (
            IDialogPresenter dialogPresenter, 
            IPrivateKeysStorage privateKeysStorage,
            IPasswordHolder passwordHolder,
            IAccountsManager accountsManager,
            IPasswordExactor passwordExactor,
            IOutlookInteraction outlook,
            IMailObserver mailObserver,
            VirgilHub virgilHub
        )
        {
            this.dialogPresenter = dialogPresenter;
            this.privateKeysStorage = privateKeysStorage;
            this.passwordHolder = passwordHolder;
            this.accountsManager = accountsManager;
            this.passwordExactor = passwordExactor;
            this.outlook = outlook;
            this.mailObserver = mailObserver;
            this.virgilHub = virgilHub;

            this.ExportCommand = new RelayCommand(this.Export);
            this.RemoveCommand = new RelayCommand(this.Remove);
            this.UploadPrivateKeyToCloudCommand = new RelayCommand(this.UploadPrivateKeyToCloud);

            this.CancelDeleteCommand = new RelayCommand(this.CancelDelete);
            this.AcceptDeleteCommand = new RelayCommand(this.AcceptDelete);

            this.DoneCommand = new RelayCommand(this.Close);
        }

        public ICommand DoneCommand { get; set; }
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

            this.UpdateProperties();
        }

        private void Remove()
        {
            this.ChangeState(AccountSettingsState.DeletePrivateKey);

            this.IsDeleteAccount = false;
            this.IsDeletePrivateKeyFromLocalStorage = false;
            this.IsDeletePrivateKeyFromVirgilServices = false;
        }

        private async void UploadPrivateKeyToCloud()
        {
            this.ClearErrors();

            try
            {
                this.ChangeState(AccountSettingsState.Processing, "Uploading Private Key....");

                var privateKey = this.privateKeysStorage.GetPrivateKey(this.account.VirgilCardId);

                var privateKeyPassword = this.passwordExactor.ExactOrAlarm(this.account.OutlookAccountEmail);
                
                await this.virgilHub.PrivateKeys.Stash(this.account.VirgilCardId, privateKey, privateKeyPassword);
                
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
                this.UpdateProperties();
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
                private_key = this.privateKeysStorage.GetPrivateKey(this.account.VirgilCardId)
            };

            var exportJson = JsonConvert.SerializeObject(exportObject);
            var exportBytes = Encoding.UTF8.GetBytes(exportJson);
            var exportBase64 = Convert.ToBase64String(exportBytes);

            var fileName = this.account.OutlookAccountDescription.ToLower().Replace(" ", "_");
            this.dialogPresenter.SaveFile(fileName, exportBase64, "vcard");
        }

        private void UpdateProperties()
        {
            this.IsPrivateKeyHasPassword = this.privateKeysStorage.HasPrivateKeyPassword(this.account.VirgilCardId);
            this.IsPrivateKeyPasswordNeedToStore = this.account.IsPrivateKeyPasswordNeedToStore;

            this.CanUploadToCloud = !this.account.IsVirgilPrivateKeyStorage;
        }

        #region Delete Private Key 
        
        private string deleteWarningMessage;
        private bool isDeleteAccount;
        private bool isDeletePrivateKeyFromVirgilServices;
        private bool isDeletePrivateKeyFromLocalStorage;

        public ICommand AcceptDeleteCommand { get; set; }
        public ICommand CancelDeleteCommand { get; set; }

        public bool IsDeleteAccount
        {
            get { return this.isDeleteAccount; }
            set
            {
                this.isDeleteAccount = value;
                this.RaisePropertyChanged();
                this.RaisePropertyChanged(nameof(this.IsAnyDeleteOperation));

                this.SetSuitableWarningMessage();
            }
        }

        public bool IsDeletePrivateKeyFromVirgilServices
        {
            get { return this.isDeletePrivateKeyFromVirgilServices; }
            set
            {
                this.isDeletePrivateKeyFromVirgilServices = value;
                this.RaisePropertyChanged();
                this.RaisePropertyChanged(nameof(this.IsAnyDeleteOperation));

                this.SetSuitableWarningMessage();
            }
        }

        public bool IsDeletePrivateKeyFromLocalStorage
        {
            get { return this.isDeletePrivateKeyFromLocalStorage; }
            set
            {
                this.isDeletePrivateKeyFromLocalStorage = value;
                this.RaisePropertyChanged();
                this.RaisePropertyChanged(nameof(this.IsAnyDeleteOperation));

                this.SetSuitableWarningMessage();
            }
        }

        public bool IsAnyDeleteOperation
        {
            get
            {
                return this.IsDeleteAccount || 
                       this.IsDeletePrivateKeyFromVirgilServices ||
                       this.IsDeletePrivateKeyFromLocalStorage;
            }
        }

        public string DeleteWarningMessage
        {
            get { return this.deleteWarningMessage; }
            set
            {
                this.deleteWarningMessage = value;
                this.RaisePropertyChanged();
            }
        }

        private void SetSuitableWarningMessage()
        {
            if (this.IsDeleteAccount)
            {
                this.DeleteWarningMessage = "Once you delete your account, there is no going back. Please be certain.";
                return;
            }

            if (this.IsDeletePrivateKeyFromVirgilServices && !this.IsDeletePrivateKeyFromLocalStorage)
            {
                this.DeleteWarningMessage = "Your private key won’t be synchronised from Virgil Cloud. You will have to upload your key from local storage manually on other devices.";
                return;
            }

            if (this.IsDeletePrivateKeyFromVirgilServices && this.IsDeletePrivateKeyFromLocalStorage)
            {
                this.DeleteWarningMessage = "The private key will be deleted permanently. Make sure you have saved it in some secure place.";
                return;
            }

            this.DeleteWarningMessage = "";
        }

        private async void AcceptDelete()
        {
            this.ClearErrors();

            try
            {
                this.ChangeState(AccountSettingsState.Processing);

                if (this.IsDeleteAccount)
                {
                    await this.RemoveAccount();
                    this.ChangeState(AccountSettingsState.Done, "The Account has been deleted successfully.");
                    return;
                }

                if (this.IsDeletePrivateKeyFromVirgilServices && !this.IsDeletePrivateKeyFromLocalStorage)
                {
                    await this.RemovePrivateKeyFromVirgilServices();
                    this.ChangeState(AccountSettingsState.Settings);
                    return;
                }

                if (this.IsDeletePrivateKeyFromVirgilServices && this.IsDeletePrivateKeyFromLocalStorage)
                {
                    await this.RemovePrivateKeyFromVirgilServices();
                    this.accountsManager.Remove(this.account.OutlookAccountEmail);
                    this.ChangeState(AccountSettingsState.Done, "The private key has been deleted from Virgil Services and local storage successfully.");
                    return;
                }

                if (this.IsDeletePrivateKeyFromLocalStorage)
                {
                    this.privateKeysStorage.RemovePrivateKey(this.account.VirgilCardId);
                    this.passwordHolder.Remove(this.account.OutlookAccountEmail);
                    this.accountsManager.Remove(this.account.OutlookAccountEmail);
                    this.ChangeState(AccountSettingsState.Done, "The private key has been deleted successfully. You can upload it at any moment again.");
                }
            }
            catch (Exception ex)
            {
                this.AddCustomError(ex.Message);
                this.ChangeState(AccountSettingsState.DeletePrivateKey);
            }
        }
        
        private void CancelDelete()
        {
            this.ClearErrors();
            this.ChangeState(AccountSettingsState.Settings);
        }

        private async Task RemoveAccount()
        {
            var password = this.passwordExactor.ExactOrAlarm(this.account.OutlookAccountEmail);

            this.ChangeStateText("Sending verification request...");

            var attemptId = Guid.NewGuid().ToString();
            var verifyResponse = await this.virgilHub.Identity.Verify(this.account.OutlookAccountEmail,
                IdentityType.Email, new Dictionary<string, string> { { "attempt_id", attemptId } });

            this.ChangeStateText("Waiting for confirmation email...");

            var code = await this.ExtractConfirmationCode(this.account.OutlookAccountEmail, attemptId);

            this.ChangeStateText("Confirming email account...");
            
            var validationToken = await this.virgilHub.Identity.Confirm(verifyResponse.ActionId, code);

            var privateKey = this.privateKeysStorage.GetPrivateKey(this.account.VirgilCardId);

            try
            {
                this.ChangeStateText("Deleting private key from Virgil Services...");

                await this.virgilHub.PrivateKeys.Destroy(this.account.VirgilCardId, privateKey, password);
            }
            catch (SDK.Exceptions.VirgilPrivateServicesException)
            {
                // TODO: We need to check if private key exists first.
            }

            this.ChangeStateText("Revoking public key from Virgil Services...");

            await this.virgilHub.PublicKeys.Revoke(this.account.VirgilPublicKeyId, new[] {validationToken},
                this.account.VirgilCardId, privateKey, password);

            this.privateKeysStorage.RemovePrivateKey(this.account.VirgilCardId);
            this.passwordHolder.Remove(this.account.OutlookAccountEmail);
            this.accountsManager.Remove(this.account.OutlookAccountEmail);
        }

        private async Task RemovePrivateKeyFromVirgilServices()
        {
            this.ChangeState(AccountSettingsState.Processing, "Removing Private Key....");

            var privateKey = this.privateKeysStorage.GetPrivateKey(this.account.VirgilCardId);
            var privateKeyPassword = this.passwordExactor.ExactOrAlarm(this.account.OutlookAccountEmail);

            await this.virgilHub.PrivateKeys.Destroy(this.account.VirgilCardId, privateKey, privateKeyPassword);

            this.account.IsVirgilPrivateKeyStorage = false;
            this.account.LastPrivateKeySyncDateTime = null;

            this.accountsManager.UpdateAccount(this.account);
            this.UpdateProperties();
        }

        private async Task<string> ExtractConfirmationCode(string accountSmtpAddress, string waitingAttemptId)
        {
            while (true)
            {
                var mail = await this.mailObserver.WaitFor(accountSmtpAddress, "no-reply@virgilsecurity.com");
                if (mail == null)
                {
                    throw new Exception("The message with confirmation code is not arrived. Try again later.");
                }

                var htmlDoc = new HtmlDocument();
                htmlDoc.LoadHtml(mail.Body);

                var attemptIdElem = htmlDoc.GetElementbyId("attempt_id");
                var attemptId = attemptIdElem.GetAttributeValue("value", "");

                if (!attemptId.Equals(waitingAttemptId, StringComparison.CurrentCultureIgnoreCase))
                {
                    this.outlook.DeleteMail(mail.EntryID);
                    continue;
                }

                var virgilElem = htmlDoc.GetElementbyId("confirmation_code");
                var code = virgilElem?.GetAttributeValue("value", "");

                this.outlook.DeleteMail(mail.EntryID);
                return code;
            }
        }

        #endregion
    }
}