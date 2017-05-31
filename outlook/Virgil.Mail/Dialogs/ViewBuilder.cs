namespace Virgil.Mail.Dialogs
{
    using System.Windows.Controls;
    using Autofac;
    using Common;
    using Mvvm;

    public class ViewBuilder : IViewBuilder
    {
        private readonly IContainer container;

        public ViewBuilder(IContainer container)
        {
            this.container = container;
        }

        public UserControl Build<TView, TViewModel>()
            where TView : UserControl 
            where TViewModel : ViewModel
        {
            var view = this.container.Resolve<TView>();
            var viewModel = this.container.Resolve<TViewModel>();

            view.DataContext = viewModel;

            return view;
        }
    }
}