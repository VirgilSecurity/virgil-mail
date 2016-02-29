namespace Virgil.Mail.Common
{
    using Autofac;

    internal class ServiceLocator
    {
        private static IContainer container;

        internal static IOutlookInteraction Outlook => Get<IOutlookInteraction>();
        internal static IDialogPresenter Dialogs => Get<IDialogPresenter>();
        internal static IMailSender MailSender => Get<IMailSender>();
        internal static IAccountsManager Accounts => Get<IAccountsManager>();
        internal static IPasswordExactor PasswordExactor => Get<IPasswordExactor>();

        private static TService Get<TService>() where TService : IService
        {
            return container.Resolve<TService>();
        }

        internal static void SetContainer(IContainer serviceContainer)
        {
            container = serviceContainer;
        }
    }
}
