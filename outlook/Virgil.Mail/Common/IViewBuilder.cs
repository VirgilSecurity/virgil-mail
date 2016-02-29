namespace Virgil.Mail.Common
{
    using System.Windows.Controls;
    using Virgil.Mail.Mvvm;

    public interface IViewBuilder : IService
    {
        UserControl Build<TView, TViewModel>()
            where TView : UserControl
            where TViewModel : ViewModel;
    }
}