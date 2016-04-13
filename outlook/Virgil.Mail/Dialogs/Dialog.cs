namespace Virgil.Mail.Dialogs
{
    using System;
    using System.Windows.Forms;
    using Virgil.Mail.Common;
    using Virgil.Mail.Mvvm;
    using UserControl = System.Windows.Controls.UserControl;

    public class Dialog
    {
        private readonly UserControl view;
        private readonly ViewModel viewModel;
        private readonly bool isModal;
        
        public Dialog(ShellWindow shellWindow, UserControl view, ViewModel viewModel, bool isModal)
        {
            this.Shell = shellWindow;

            this.view = view;
            this.viewModel = viewModel;
            this.isModal = isModal;

            shellWindow.Closing += viewModel.OnMandatoryClosing;

            shellWindow.Closed += this.ShellWindowOnClosed;
            shellWindow.Shown += this.ShellWindowOnShown;

            viewModel.SetCloseAction(this.OnViewModelClose);
        }
        
        public bool IsShown { get; private set; }
        public ShellWindow Shell { get; }

        private void ShellWindowOnShown(object sender, EventArgs eventArgs)
        {
            this.IsShown = true;
        }

        private void ShellWindowOnClosed(object sender, EventArgs eventArgs)
        {
            this.Shell.Closing -= this.viewModel.OnMandatoryClosing;
            this.Shell.Closed -= this.ShellWindowOnClosed;
            this.Shell.Shown -= this.ShellWindowOnShown;

            var vm = ((UserControl) this.Shell.ElementHost.Child).DataContext;
            ServiceLocator.MessageBus.Unsubscribe(vm);
        }
        
        private void OnViewModelClose()
        {
            this.Shell.Close();
        }

        public object Show()
        {
            if (this.IsShown)
            {
                if (this.Shell.WindowState == FormWindowState.Minimized)
                {
                    this.Shell.WindowState = FormWindowState.Normal;
                }

                this.Shell.Activate();
                this.Shell.TopMost = true;
                this.Shell.TopMost = false;
                this.Shell.Focus();
                this.Shell.Activate();

                return null;
            }

            if (this.isModal)
            {
                this.Shell.ShowDialog();
            }
            else
            {
                this.Shell.Show();
            }

            return this.viewModel.Result;
        }
    }
}