namespace Virgil.Mail.Common
{
    using Autofac;

    internal class ServiceLocator
    {
        private static IContainer container;

        internal IOutlookInteraction Outlook => Get<IOutlookInteraction>();
        internal IViewBuilder ViewBuilder => Get<IViewBuilder>();

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
