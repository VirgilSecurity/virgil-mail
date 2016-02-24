namespace Virgil.Mail
{
    using Autofac;

    using Virgil.Mail.Accounts;
    using Virgil.Mail.Common;
    using Virgil.Mail.Crypto;
    using Virgil.Mail.Dialogs;
    using Virgil.Mail.Integration;
    using Virgil.Mail.Storage;
    using Virgil.SDK.Infrastructure;

    using Outlook = Microsoft.Office.Interop.Outlook;

    internal class Bootstraper
    {
        private static IContainer container;

        internal static void Initialize(Outlook.Application application)
        {
            // initialize SDK instances with staging environment.

            var config = VirgilConfig.UseAccessToken(Constants.VirgilAccessToken)
                .WithCustomIdentityServiceUri(new System.Uri("https://identity-stg.virgilsecurity.com"))
                .WithCustomPublicServiceUri(new System.Uri("https://keys-stg.virgilsecurity.com"))
                .WithCustomPrivateServiceUri(new System.Uri("https://private-keys-stg.virgilsecurity.com"));

            var virgilHub = VirgilHub.Create(config);

            // register types

            var builder = new ContainerBuilder();
            builder.RegisterInstance(new OutlookInteraction(application)).As<IOutlookInteraction>();
            builder.RegisterInstance(new MailObserver(application)).As<IMailObserver>();
            builder.RegisterInstance(virgilHub).As<VirgilHub>();
            builder.RegisterType<IsolatedStorageProvider>().As<IStorageProvider>();
            builder.RegisterType<AccountsManager>().As<IAccountsManager>();
            builder.RegisterType<VirgilCryptoProvider>().As<IVirgilCryptoProvider>();
            builder.RegisterType<EncryptedKeyValueStorage>().As<IEncryptedKeyValueStorage>();

            builder.RegisterType<RegisterAccountView>();
            builder.RegisterType<RegisterAccountViewModel>();
            builder.RegisterType<AccountsView>();
            builder.RegisterType<AccountsViewModel>();
            builder.RegisterType<AccountSettingsView>();
            builder.RegisterType<AccountSettingsViewModel>();

            container = builder.Build();

            // workaround to register instances that require
            // ioc container.

            builder = new ContainerBuilder();

            var viewBuilder = new DialogPresenter(container);
            builder.RegisterInstance(viewBuilder).As<IDialogPresenter>();

            builder.Update(container);

            // initialize service locator

            ServiceLocator.SetContainer(container);
        }
    }
}
