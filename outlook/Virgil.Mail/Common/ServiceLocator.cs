namespace Virgil.Mail.Common
{
    using Autofac;

    internal class ServiceLocator
    {
        private static IContainer container;

        public static IOutlookInteraction Outlook => Get<IOutlookInteraction>();
        public static IDialogPresenter Dialogs => Get<IDialogPresenter>();
        public static IViewBuilder ViewBuilder => Get<IViewBuilder>();
        public static IMailSender MailSender => Get<IMailSender>();
        public static IAccountsManager Accounts => Get<IAccountsManager>();
        public static IPasswordExactor PasswordExactor => Get<IPasswordExactor>();
        public static IShellTemplateSelector ShellTemplateSelector => Get<IShellTemplateSelector>();

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
