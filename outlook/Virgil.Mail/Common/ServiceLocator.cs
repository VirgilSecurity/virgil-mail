namespace Virgil.Mail.Common
{
    using Autofac;

    internal class ServiceLocator
    {
        private static IContainer container;

        internal static IOutlookInteraction Outlook => Get<IOutlookInteraction>();
        internal static IDialogPresenter Dialogs => Get<IDialogPresenter>();
        internal static IViewBuilder ViewBuilder => Get<IViewBuilder>();
        internal static IMailSender MailSender => Get<IMailSender>();
        internal static IAccountsManager Accounts => Get<IAccountsManager>();
        internal static IPasswordExactor PasswordExactor => Get<IPasswordExactor>();
        internal static IMessageBus MessageBus => Get<IMessageBus>();

        internal static void SetContainer(IContainer serviceContainer)
        {
            container = serviceContainer;
        }

        private static TService Get<TService>() where TService : IService
        {
            return container.Resolve<TService>();
        }
    }
}
