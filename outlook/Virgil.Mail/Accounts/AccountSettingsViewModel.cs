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
    using Virgil.Mail.Properties;
    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Mvvm;
    using Virgil.Mail.Models;
    using Virgil.Mail.Mvvm;
    
    public class AccountSettingsViewModel : ViewModel
    {
        private readonly IDialogPresenter dialogPresenter;
        private readonly IPasswordHolder passwordHolder;
        private readonly IAccountsManager accountsManager;
        private readonly IPasswordExactor passwordExactor;
        private readonly IOutlookInteraction outlook;
        private readonly IMailObserver mailObserver;
        private readonly VirgilApi virgilApi;
        private readonly IMessageBus messageBus;

        private AccountModel account;
        private bool isPrivateKeyPasswordNeedToStore;
        private bool isPrivateKeyHasPassword;

        private AccountSettingsState? doneReturnState;

        public AccountSettingsViewModel
        (
            IDialogPresenter dialogPresenter, 
            IPasswordHolder passwordHolder,
            IAccountsManager accountsManager,
            IPasswordExactor passwordExactor,
            IOutlookInteraction outlook,
            IMailObserver mailObserver,
            IMessageBus messageBus
        )
        {
            this.dialogPresenter = dialogPresenter;
            this.passwordHolder = passwordHolder;
            this.accountsManager = accountsManager;
            this.passwordExactor = passwordExactor;
            this.outlook = outlook;
            this.mailObserver = mailObserver;
            this.virgilApi = new VirgilApi();
            this.messageBus = messageBus;

            this.ExportCommand = new RelayCommand(this.Export);
            this.RemoveCommand = new RelayCommand(this.Remove);

            this.CancelDeleteCommand = new RelayCommand(this.CancelDelete);
            this.AcceptDeleteCommand = new RelayCommand(this.AcceptDelete);

            this.DoneCommand = new RelayCommand(this.Done);
        }
        
        public ICommand DoneCommand { get; set; }
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

        
        private void Export()
        {
            var password = this.account.IsPrivateKeyHasPassword ?
            this.passwordExactor.ExactOrAlarm(this.account.OutlookAccountEmail) : null;
            

            var exportedKey = this.virgilApi.Keys.Load(this.account.VirgilCardId, password).Export();
            
            var exportObject = new
            {
                id = this.account.VirgilCardId,
                private_key = exportedKey.GetBytes(),
                is_private_key_has_password = this.account.IsPrivateKeyHasPassword
            };

            var exportJson = JsonConvert.SerializeObject(new[] { exportObject });
            var exportBytes = Encoding.UTF8.GetBytes(exportJson);
            var exportBase64 = Convert.ToBase64String(exportBytes);


            var fileName = this.account.OutlookAccountDescription.ToLower().Replace(" ", "_");
            this.dialogPresenter.SaveFile(fileName, exportBase64, "virgilkey");
        }

        private void UpdateProperties()
        {
            this.IsPrivateKeyHasPassword = this.account.IsPrivateKeyHasPassword;
            this.IsPrivateKeyPasswordNeedToStore = this.account.IsPrivateKeyPasswordNeedToStore;

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


            if (this.IsDeletePrivateKeyFromLocalStorage)
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


                if (this.IsDeletePrivateKeyFromLocalStorage)
                {
                    DeletePrivateKeyAndOutlookAccount();
                    this.ChangeState(AccountSettingsState.Done, Resources.Label_PrivateKeyRemovedFromLocalStorageSuccessfully);
                    this.messageBus.Publish(new AccountDeletedMessage(this.account.VirgilCardId));
                }
            }
            catch (Exception ex)
            {
                this.AddCustomError(ex.Message);
                this.ChangeState(AccountSettingsState.DeletePrivateKey);
            }
        }

        private void DeletePrivateKeyAndOutlookAccount()
        {
            this.virgilApi.Keys.Destroy(this.account.VirgilCardId);
            this.passwordHolder.Remove(this.account.OutlookAccountEmail);
            this.accountsManager.Remove(this.account.OutlookAccountEmail);

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

            var virgilCard = await virgilApi.Cards.GetAsync(this.account.VirgilCardId);

            var attemptId = Guid.NewGuid().ToString();
            var option = new IdentityVerificationOptions();

            //TODO upgrade SDK version
            option.TimeToLive = TimeSpan.FromSeconds(3600);
            option.CountToLive = 1;
            //TODO upgrade SDK version

            option.ExtraFields = new Dictionary<string, string> {
                    { "attempt_id", attemptId.ToString() }
                };

            var attempt = await virgilCard.CheckIdentityAsync(option);

            this.ChangeStateText(Resources.Label_WaitingForConfirmationEmail);

            var code = await this.ExtractConfirmationCode(this.account.OutlookAccountEmail, 
                attemptId.ToString());

            this.ChangeStateText(Resources.Label_ConfirmingEmailAccount);

            var token = await attempt.ConfirmAsync(new EmailConfirmation(code));

            this.ChangeStateText(Resources.Label_RevokingPublicKeyFromVirgilServices);

            var virgilKey = virgilApi.Keys.Load(virgilCard.Id, password);
            await virgilApi.Cards.RevokeGlobalAsync(virgilCard, virgilKey, token);

            DeletePrivateKeyAndOutlookAccount();
        }


        private async Task<string> ExtractConfirmationCode(string accountSmtpAddress, string waitingAttemptId)
        {
            while (true)
            {
                var mail = await this.mailObserver.WaitFor(accountSmtpAddress, "no-reply@virgilsecurity.com", this.cancallationTokenSource.Token);
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