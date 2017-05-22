namespace Virgil.Mail
{
    using Autofac;
    using SDK;
    using Virgil.Mail.Accounts;
    using Virgil.Mail.Common;
    using Virgil.Mail.Common.Messaging;
    using Virgil.Mail.Dialogs;
    using Virgil.Mail.Integration;
    using Virgil.Mail.Storage;
    using Virgil.Mail.Viewer;

    using Outlook = Microsoft.Office.Interop.Outlook;

    internal class Bootstraper
    {
        private static IContainer container;

        internal static void Initialize(Outlook.Application application)
        {
            // register types

            var builder = new ContainerBuilder();
            builder.RegisterInstance(new OutlookInteraction(application)).As<IOutlookInteraction>();
            builder.RegisterInstance(new MailObserver(application)).As<IMailObserver>();
            builder.RegisterType<IsolatedStorageProvider>().As<IStorageProvider>();
            builder.RegisterType<AccountsManager>().As<IAccountsManager>().SingleInstance();
            builder.RegisterType<PasswordHolder>().As<IPasswordHolder>();
            builder.RegisterType<MailSender>().As<IMailSender>();
            builder.RegisterType<PasswordExactor>().As<IPasswordExactor>();
            builder.RegisterType<RecipientsService>().As<IRecipientsService>().SingleInstance();
            builder.RegisterType<MessageBus>().As<IMessageBus>().SingleInstance();

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
