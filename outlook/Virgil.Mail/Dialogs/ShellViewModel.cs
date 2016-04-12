namespace Virgil.Mail.Dialogs
{
    using Virgil.Mail.Mvvm;
    
    public class ShellViewModel : ViewModel
    {
        private IShellContentViewModel contentModel;

        public IShellContentViewModel ContentModel
        {
            get
            {
                return this.contentModel;
            }
            private set
            {
                this.contentModel = value;
                this.RaisePropertyChanged();
            }
        }

        public void SetContentModel<TViewModel>(TViewModel viewModel) where TViewModel : IShellContentViewModel
        {
            this.ContentModel = viewModel;
        }
    }
}