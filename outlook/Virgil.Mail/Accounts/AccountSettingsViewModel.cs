namespace Virgil.Mail.Accounts
{
    using System;
    using System.Collections.Generic;
    using System.Text;
    using System.Threading.Tasks;
    using System.Windows.Input;

    using HtmlAgilityPack;
    using Newtonsoft.Json;
    using SDK;
    using SDK.Identities;
    using Virgil.Mail.Properties;
    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Mvvm;
    using Virgil.Mail.Models;
    using Virgil.Mail.Mvvm;
    
    public class AccountSettingsViewModel : ViewModel
    {
        private readonly IDialogPresenter dialogPresenter;
        private readonly IPrivateKeysStorage privateKeysStorage;
        private readonly IPasswordHolder passwordHolder;
        private readonly IAccountsManager accountsManager;
        private readonly IPasswordExactor passwordExactor;
        private readonly IOutlookInteraction outlook;
        private readonly IMailObserver mailObserver;
        private readonly ServiceHub virgilHub;
        private readonly IMessageBus messageBus;

        private AccountModel account;
        private bool isPrivateKeyPasswordNeedToStore;
        private bool isPrivateKeyHasPassword;
        private bool canUploadToCloud; 

        private AccountSettingsState? doneReturnState;

        public AccountSettingsViewModel
        (
            IDialogPresenter dialogPresenter, 
            IPrivateKeysStorage privateKeysStorage,
            IPasswordHolder passwordHolder,
            IAccountsManager accountsManager,
            IPasswordExactor passwordExactor,
            IOutlookInteraction outlook,
            IMailObserver mailObserver,
            ServiceHub virgilHub,
            IMessageBus messageBus
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
            this.messageBus = messageBus;

            this.ExportCommand = new RelayCommand(this.Export);
            this.RemoveCommand = new RelayCommand(this.Remove);
            this.UploadPrivateKeyToCloudCommand = new RelayCommand(this.UploadPrivateKeyToCloud);

            this.CancelDeleteCommand = new RelayCommand(this.CancelDelete);
            this.AcceptDeleteCommand = new RelayCommand(this.AcceptDelete);

            this.DoneCommand = new RelayCommand(this.Done);
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
                this.ChangeState(AccountSettingsState.Processing, Resources.Label_UploadingPrivateKey);

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

            var exportJson = JsonConvert.SerializeObject(new[] { exportObject });
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

        private void Done()
        {
            if (this.doneReturnState.HasValue)
            {
                this.ChangeState(this.doneReturnState.Value);
                this.doneReturnState = null;
                return;
            }

            this.Close();
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
                this.DeleteWarningMessage = Resources.Warning_RemoveAccount;
                return;
            }

            if (this.IsDeletePrivateKeyFromVirgilServices && !this.IsDeletePrivateKeyFromLocalStorage)
            {
                this.DeleteWarningMessage = Resources.Warning_RemovePrivateKeyFormVirgilServices;
                return;
            }

            if (this.IsDeletePrivateKeyFromVirgilServices && this.IsDeletePrivateKeyFromLocalStorage)
            {
                this.DeleteWarningMessage = Resources.Warning_RemovePrivateKeyFormLocalStorage;
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
                    this.ChangeState(AccountSettingsState.Done, Resources.Label_AccountRemovedSuccessfully);
                    this.messageBus.Publish(new AccountDeletedMessage(this.account.VirgilCardId.ToString()));
                    return;
                }

                if (this.IsDeletePrivateKeyFromVirgilServices && !this.IsDeletePrivateKeyFromLocalStorage)
                {
                    await this.RemovePrivateKeyFromVirgilServices();
                    this.doneReturnState = AccountSettingsState.Settings;
                    this.ChangeState(AccountSettingsState.Done, Resources.Label_PrivateKeyRemovedFromVirgilServicesSuccessfully);
                    return;
                }

                if (this.IsDeletePrivateKeyFromVirgilServices && this.IsDeletePrivateKeyFromLocalStorage)
                {
                    await this.RemovePrivateKeyFromVirgilServices();
                    this.accountsManager.Remove(this.account.OutlookAccountEmail);
                    this.ChangeState(AccountSettingsState.Done, Resources.Label_PrivateKeyRemovedFromLocalStorageAndVirgilServicesSuccessfully);
                    this.messageBus.Publish(new AccountDeletedMessage(this.account.VirgilCardId.ToString()));
                    return;
                }

                if (this.IsDeletePrivateKeyFromLocalStorage)
                {
                    this.privateKeysStorage.RemovePrivateKey(this.account.VirgilCardId);
                    this.passwordHolder.Remove(this.account.OutlookAccountEmail);
                    this.accountsManager.Remove(this.account.OutlookAccountEmail);
                    this.ChangeState(AccountSettingsState.Done, Resources.Label_PrivateKeyRemovedFromLocalStorageSuccessfully);
                    this.messageBus.Publish(new AccountDeletedMessage(this.account.VirgilCardId.ToString()));
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

            this.ChangeStateText(Resources.Label_SendingVerificationRequest);

            var attemptId = Guid.NewGuid().ToString();
            var emailVerifier = await this.virgilHub.Identity.VerifyEmail(this.account.OutlookAccountEmail
                , new Dictionary<string, string> {{"attempt_id", attemptId}});

            this.ChangeStateText(Resources.Label_WaitingForConfirmationEmail);

            var code = await this.ExtractConfirmationCode(this.account.OutlookAccountEmail, attemptId);

            this.ChangeStateText(Resources.Label_ConfirmingEmailAccount);
            
            var identityInfo = await emailVerifier.Confirm(code);

            var privateKey = this.privateKeysStorage.GetPrivateKey(this.account.VirgilCardId);

            try
            {
                this.ChangeStateText(Resources.Label_DeletingPrivateKeyFromVirgilServices);

                await this.virgilHub.PrivateKeys.Destroy(this.account.VirgilCardId, privateKey, password);
            }
            catch (SDK.Exceptions.VirgilPrivateServicesException)
            {
                // TODO: We need to check if private key exists first.
            }

            this.ChangeStateText(Resources.Label_RevokingPublicKeyFromVirgilServices);

            await this.virgilHub.PublicKeys.Revoke(this.account.VirgilPublicKeyId, new[] {identityInfo},
                this.account.VirgilCardId, privateKey, password);

            this.privateKeysStorage.RemovePrivateKey(this.account.VirgilCardId);
            this.passwordHolder.Remove(this.account.OutlookAccountEmail);
            this.accountsManager.Remove(this.account.OutlookAccountEmail);
        }

        private async Task RemovePrivateKeyFromVirgilServices()
        {
            this.ChangeState(AccountSettingsState.Processing, Resources.Label_RemovingPrivateKey);

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
                var mail = await this.mailObserver.WaitFor(accountSmtpAddress, "no-reply@virgilsecurity.com", this.cts.Token);
                if (mail == null)
                {
                    throw new Exception(Resources.Error_ConfirmationCodeIsNotArrived);
                }

                if (mail.IsJunk)
                {
                    this.outlook.UnJunkMailById(mail.EntryID);
                    continue;
                }

                var htmlDoc = new HtmlDocument();
                htmlDoc.LoadHtml(mail.Body);

                var attemptIdElem = htmlDoc.GetElementbyId("attempt_id");
                if (attemptIdElem == null)
                {
                    this.outlook.DeleteMail(mail.EntryID);
                    continue;
                }

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