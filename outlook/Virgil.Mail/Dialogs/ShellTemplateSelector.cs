namespace Virgil.Mail.Dialogs
{
    using System;
    using System.Windows;
    using System.Windows.Controls;
    
    using Virgil.Mail.Common;

    using Autofac;

    public class ShellTemplateSelector : DataTemplateSelector, IShellTemplateSelector
    {
        private readonly IContainer container;

        public ShellTemplateSelector(IContainer container)
        {
            this.container = container;
        }

        public override DataTemplate SelectTemplate(object item, DependencyObject dependencyObject)
        {
            var contentModel = item as IShellContentViewModel;
            if (contentModel == null)
            {
                return null;
            }
            
            var viewTypeName = contentModel.GetType().FullName; 
            var viewType = Type.GetType(viewTypeName.Replace("Model", ""), true);

            var dataTemplate = new DataTemplate { VisualTree = new FrameworkElementFactory(viewType) };
            return dataTemplate;
        }
    }
}