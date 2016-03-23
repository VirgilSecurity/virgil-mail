namespace Virgil.Mail
{
    using Autofac;

    using Virgil.Mail.Accounts;
    using Virgil.Mail.Common;
    using Virgil.Mail.Dialogs;
    using Virgil.Mail.Integration;
    using Virgil.Mail.Storage;
    using Virgil.Mail.Viewer;
    using Virgil.SDK.Infrastructure;

    using Outlook = Microsoft.Office.Interop.Outlook;

    internal class Bootstraper
    {
        private static IContainer container;

        internal static void Initialize(Outlook.Application application)
        {
            // initialize SDK instances with staging environment.

            var config = VirgilConfig.UseAccessToken(Constants.VirgilAccessToken);
            var virgilHub = VirgilHub.Create(config);

            // register types

            var builder = new ContainerBuilder();
            builder.RegisterInstance(new OutlookInteraction(application)).As<IOutlookInteraction>();
            builder.RegisterInstance(new MailObserver(application)).As<IMailObserver>();
            builder.RegisterInstance(virgilHub).As<VirgilHub>();
            builder.RegisterType<IsolatedStorageProvider>().As<IStorageProvider>();
            builder.RegisterType<AccountsManager>().As<IAccountsManager>().SingleInstance();
            builder.RegisterType<PrivateKeysStorage>().As<IPrivateKeysStorage>();
            builder.RegisterType<EncryptedKeyValueStorage>().As<IEncryptedKeyValueStorage>();
            builder.RegisterType<PasswordHolder>().As<IPasswordHolder>();
            builder.RegisterType<MailSender>().As<IMailSender>();
            builder.RegisterType<PasswordExactor>().As<IPasswordExactor>();
            builder.RegisterType<RecipientsService>().As<IRecipientsService>().SingleInstance();

            builder.RegisterType<RegisterAccountView>();
            builder.RegisterType<RegisterAccountViewModel>();
            builder.RegisterType<AccountsView>();
            builder.RegisterType<AccountsViewModel>();
            builder.RegisterType<AccountSettingsView>();
            builder.RegisterType<AccountSettingsViewModel>();
            builder.RegisterType<AccountKeyPasswordView>();
            builder.RegisterType<AccountKeyPasswordViewModel>();
            builder.RegisterType<EncryptedMailView>();
            builder.RegisterType<EncryptedMailViewModel>();

            container = builder.Build();

            // workaround to register instances that require
            // ioc container.

            builder = new ContainerBuilder();

            var dialogPresenter = new DialogPresenter(container);
            var viewBuilder = new ViewBuilder(container);

            builder.RegisterInstance(dialogPresenter).As<IDialogPresenter>();
            builder.RegisterInstance(viewBuilder).As<IViewBuilder>();

            builder.Update(container);

            // initialize service locator

            ServiceLocator.SetContainer(container);
        }
    }
}
