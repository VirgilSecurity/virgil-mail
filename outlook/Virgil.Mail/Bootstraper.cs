namespace Virgil.Mail
{
    using Autofac;

    using Virgil.Mail.Accounts;
    using Virgil.Mail.Common;
    using Virgil.Mail.Integration;
    using Virgil.Mail.Services;
    using Virgil.Mail.Settings;
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
            builder.RegisterInstance(virgilHub).As<VirgilHub>();
            builder.RegisterType<IsolatedStorageProvider>().As<IStorageProvider>();
            builder.RegisterType<AccountsManager>().As<IAccountsManager>();
            builder.RegisterType<AccountsStorage>().As<IAccountsStorage>();



            builder.RegisterType<RegisterAccountView>();
            builder.RegisterType<RegisterAccountViewModel>();

            builder.RegisterType<AccountsView>();
            builder.RegisterType<AccountsViewModel>();

            container = builder.Build();

            // workaround to register instances that require
            // ioc container.

            builder = new ContainerBuilder();

            var viewBuilder = new WindowPresenter(container);
            builder.RegisterInstance(viewBuilder).As<IWindowPresenter>();

            builder.Update(container);

            // initialize service locator

            ServiceLocator.SetContainer(container);
        }
    }
}
