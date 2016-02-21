namespace Virgil.Mail.Common
{
    using Autofac;

    internal class ServiceLocator
    {
        private static IContainer container;

        internal static IOutlookInteraction Outlook => Get<IOutlookInteraction>();
        internal static IWindowPresenter Windows => Get<IWindowPresenter>();

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
