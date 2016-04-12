namespace Virgil.Mail.Dialogs
{
    using System.IO;
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

        public void ShowDialog<TViewModel>() where TViewModel : IShellContentViewModel
        {
            var shellView = this.container.Resolve<ShellView>();
            var shellViewModel = this.container.Resolve<ShellViewModel>();

            shellView.DataContext = shellViewModel;

            var contentModel = this.container.Resolve<TViewModel>();
            shellViewModel.SetContentModel(contentModel);

            contentModel.Initialize(null);

            shellView.Show();
        }

        public string ShowPrivateKeyPassword(string accountEmail, byte[] privateKey)
        {
            var view = this.container.Resolve<AccountKeyPasswordView>();
            var viewModel = this.container.Resolve<AccountKeyPasswordViewModel>();

            viewModel.Initialize(accountEmail, privateKey);

            var dialog = DialogBuilder.Build(view, viewModel, $"Account ({accountEmail})", 290, 250, false);
            var passwordObject = dialog.Show();

            return passwordObject?.ToString();
        }

        public void ShowRegisterAccount(AccountModel accountModel)
        {
            var view = this.container.Resolve<RegisterAccountView>();
            var viewModel = this.container.Resolve<RegisterAccountViewModel>();

            viewModel.Initialize(accountModel);

            var dialog = DialogBuilder.Build(view, viewModel, "Register Account", 290, 420, false);

            dialog.Show();
        }

        public void ShowAccounts()
        {
            var view = this.container.Resolve<AccountsView>();
            var viewModel = this.container.Resolve<AccountsViewModel>();

            viewModel.Initialize();

            var dialog = DialogBuilder.Build(view, viewModel, "Virgil Mail Keys", 370, 450);
            
            dialog.Show();
        }

        public void ShowAccountSettings(AccountModel accountModel)
        {
            var view = this.container.Resolve<AccountSettingsView>();
            var viewModel = this.container.Resolve<AccountSettingsViewModel>();

            viewModel.Initialize(accountModel);

            var dialog = DialogBuilder.Build(view, viewModel, "Settings", 290, 430, false);

            dialog.Show();
        }

        public void SaveFile(string fileName, string content, string extension)
        {
            var saveFileDialog = new SaveFileDialog
            {
                RestoreDirectory = true,
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

        public void SaveFile(string fileName, byte[] content, string extension)
        {
            var saveFileDialog = new SaveFileDialog
            {
                RestoreDirectory = true,
                FileName = $"{fileName}.{extension}",
                Filter = $"{extension} files (*.{extension})|*.{extension}|All files (*.*)|*.*"
            };
            
            if (saveFileDialog.ShowDialog() != DialogResult.OK)
            {
                return;
            }
            
            var stream = saveFileDialog.OpenFile();
            var streamWriter = new BinaryWriter(stream);

            streamWriter.Write(content);
            streamWriter.Close();
        }

        public string OpenFile(string extension)
        {
            var openFileDialog = new OpenFileDialog
            {
                Filter = $"{extension} files (*.{extension})|*.{extension}|All files (*.*)|*.*"
            };
            
            if (openFileDialog.ShowDialog() != DialogResult.OK)
            {
                return null;
            }

            return openFileDialog.FileName;
        }

        public void ShowAlert(string message)
        {
            MessageBox.Show(message, @"Warning", MessageBoxButtons.OK);
        }

        public bool ShowConfirmation(string caption, string message)
        {
            return MessageBox.Show(message, caption, MessageBoxButtons.YesNo) == DialogResult.Yes;
        }
    }
}