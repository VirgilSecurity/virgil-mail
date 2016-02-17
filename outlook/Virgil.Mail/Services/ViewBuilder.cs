namespace Virgil.Mail.Services
{
    using Autofac;
    using Virgil.Mail.Common;

    internal class ViewBuilder : IViewBuilder
    {
        private IContainer container;

        public ViewBuilder(IContainer container)
        {
            this.container = container;
        }
    }
}
