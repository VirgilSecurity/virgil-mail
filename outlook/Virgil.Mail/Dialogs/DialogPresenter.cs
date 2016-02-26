namespace Virgil.Mail.Dialogs
{
    using System.IO;
    using System.Drawing;
    using System.Windows.Forms;

    using Autofac;

    using Virgil.Mail.Accounts;
    using Virgil.Mail.Common;
    using Virgil.Mail.Models;

    public class DialogPresenter : IDialogPresenter
    {
        private readonly IContainer container;

        public DialogPresenter(IContainer container)
        {
            this.container = container;
        }

        public void ShowRegisterAccount(AccountModel accountModel)
        {
            var view = this.container.Resolve<RegisterAccountView>();
            var viewModel = this.container.Resolve<RegisterAccountViewModel>();

            var shell = new ShellWindow
            {
                ClientSize = new Size(285, 400),
                FormBorderStyle = FormBorderStyle.FixedDialog,
                MaximizeBox = false,
                MinimizeBox = false,
                Text = @"Register Account",
                StartPosition = FormStartPosition.CenterScreen,
                ElementHost = { Child = view },
                ShowIcon = false,
                ShowInTaskbar = false
            };
            
            viewModel.Initialize(accountModel);
            view.DataContext = viewModel;

            shell.ShowDialog();
        }

        public void ShowAccounts()
        {
            var view = this.container.Resolve<AccountsView>();
            var viewModel = this.container.Resolve<AccountsViewModel>();

            var shell = new ShellWindow
            {
                ClientSize = new Size(420, 460),
                FormBorderStyle = FormBorderStyle.FixedDialog,
                MaximizeBox = false,
                MinimizeBox = false,
                Text = @"Virgil Mail Keys",
                StartPosition = FormStartPosition.CenterScreen,
                ElementHost = { Child = view }
            };

            viewModel.Initialize();
            view.DataContext = viewModel;

            shell.ShowDialog();
        }

        public void ShowAccountSettings(AccountModel accountModel)
        {
            var view = this.container.Resolve<AccountSettingsView>();
            var viewModel = this.container.Resolve<AccountSettingsViewModel>();

            var shell = new ShellWindow
            {
                ClientSize = new Size(285, 400),
                FormBorderStyle = FormBorderStyle.FixedDialog,
                MaximizeBox = false,
                MinimizeBox = false,
                Text = @"Settings",
                StartPosition = FormStartPosition.CenterScreen,
                ElementHost = { Child = view },
                ShowIcon = false,
                ShowInTaskbar = false
            };

            viewModel.Initialize(accountModel);
            view.DataContext = viewModel;

            shell.ShowDialog();
        }

        public void SaveFile(string fileName, string content, string extension)
        {
            var saveFileDialog = new SaveFileDialog
            {
                FileName = $"{fileName}.{extension}",
                Filter = $"{extension} files (*.{extension})|*.{extension}|All files (*.*)|*.*"
            };

            if (saveFileDialog.ShowDialog() != DialogResult.OK)
            {
                return;
            }

            var stream = saveFileDialog.OpenFile();
            var streamWriter = new StreamWriter(stream);

            streamWriter.Write(content);
            streamWriter.Close();
        }

        public string OpenFile(string extension)
        {
            var openFileDialog = new OpenFileDialog
            {
                Filter = $"{extension} files (*.{extension})|*.{extension}|All files (*.*)|*.*",
            };
            
            if (openFileDialog.ShowDialog() != DialogResult.OK)
            {
                return null;
            }

            return openFileDialog.FileName;
        }

        public bool ShowConfirmation(string caption, string message)
        {
            return MessageBox.Show(message, caption, MessageBoxButtons.YesNo) == DialogResult.Yes;
        }
    }
}