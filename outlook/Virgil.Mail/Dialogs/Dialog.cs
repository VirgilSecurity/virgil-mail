namespace Virgil.Mail.Dialogs
{
    using System.Windows.Controls;
    using Virgil.Mail.Mvvm;

    public class Dialog
    {
        private readonly ShellWindow shellWindow;
        private readonly UserControl view;
        private readonly ViewModel viewModel;

        public Dialog(ShellWindow shellWindow, UserControl view, ViewModel viewModel)
        {
            this.shellWindow = shellWindow;

            this.view = view;
            this.viewModel = viewModel;

            shellWindow.Closing += viewModel.OnMandatoryClosing;

            viewModel.SetCloseAction(this.OnViewModelClose);
        }

        private void OnViewModelClose()
        {
            this.shellWindow.Close();
        }

        public object Show()
        {
            this.shellWindow.ShowDialog();
            this.shellWindow.Closing -= viewModel.OnMandatoryClosing;

            return this.viewModel.Result;
        }
    }
}