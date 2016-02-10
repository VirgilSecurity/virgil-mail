namespace Virgil.Mail
{
    using Autofac;

    internal class Bootstraper
    {
        private static IContainer container;

        public static void Launch()
        {
            var builder = new ContainerBuilder();
            container = builder.Build();
        }
    }
}