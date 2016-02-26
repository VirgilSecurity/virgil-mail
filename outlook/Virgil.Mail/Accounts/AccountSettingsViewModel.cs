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
        private readonly IVirgilCryptoProvider cryptoProvider;
        private readonly IAccountsManager accountsManager;
        private readonly VirgilHub virgilHub;

        private AccountModel account;

        public AccountSettingsViewModel
        (
            IDialogPresenter dialogPresenter, 
            IVirgilCryptoProvider cryptoProvider,
            IAccountsManager accountsManager,
            VirgilHub virgilHub
        )
        {
            this.dialogPresenter = dialogPresenter;
            this.cryptoProvider = cryptoProvider;
            this.accountsManager = accountsManager;
            this.virgilHub = virgilHub;

            this.ExportCommand = new RelayCommand(this.Export);
            this.RemoveCommand = new RelayCommand(this.Remove);
        }
        
        public ICommand ExportCommand { get; private set; }
        public ICommand RemoveCommand { get; private set; }

        public void Initialize(AccountModel accountModel)
        {
            this.account = accountModel;
        }

        private void Remove()
        {
            var result = this.dialogPresenter.ShowConfirmation("Delete Account Keys",
                "Are you sure you want to delete an account's key?");

            if (result)
            {
                this.accountsManager.Remove(this.account.OutlookAccountEmail);
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
                private_key = this.cryptoProvider.GetPrivateKey(this.account.OutlookAccountEmail)
            };

            var exportJson = JsonConvert.SerializeObject(exportObject);
            var exportBytes = Encoding.UTF8.GetBytes(exportJson);
            var exportBase64 = Convert.ToBase64String(exportBytes);

            var fileName = this.account.OutlookAccountDescription.ToLower().Replace(" ", "_");
            this.dialogPresenter.SaveFile(fileName, exportBase64, "vcard");}
    }
}