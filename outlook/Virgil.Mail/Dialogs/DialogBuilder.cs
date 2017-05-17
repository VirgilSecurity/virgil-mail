namespace Virgil.Mail.Dialogs
{
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.Linq;
    using System.Windows;
    using System.Windows.Forms;
    using System.Windows.Interop;
    using System.Windows.Media;

    using Virgil.Mail.Mvvm;

    public class DialogBuilder
    {
        public static Dictionary<string, Dialog> dialogs = new Dictionary<string, Dialog>(); 

        public static Dialog Build
        (
            System.Windows.Controls.UserControl view,
            ViewModel viewModel,
            string title, 
            int width, 
            int height,
            bool showIcon = true,
            bool showInTaskbar = false,
            bool isModal = true
        )
        {
            var viewName = view.GetType().FullName;
            view.DataContext = viewModel;

            if (dialogs.ContainsKey(viewName))
            {
                var cachedDialog = dialogs[viewName];
                cachedDialog.Shell.ElementHost.Child = view;
                return cachedDialog;
            }
            
            var shell = new ShellWindow
            {
                ClientSize = GetRealSize(width, height),
                FormBorderStyle = FormBorderStyle.FixedDialog,
                MaximizeBox = false,
                MinimizeBox = false,
                Text = title,
                StartPosition = FormStartPosition.CenterScreen,
                ElementHost = { Child = view },
                ShowIcon = showIcon,
                ShowInTaskbar = showInTaskbar
            };

            shell.Closing += ShellOnClosing;

            var dialog = new Dialog(shell, view, viewModel, isModal);
            dialogs.Add(viewName, dialog);

            return dialog;
        }

        private static void ShellOnClosing(object sender, CancelEventArgs args)
        {
            var dialog = dialogs.Single(it => it.Value.Shell == (ShellWindow)sender);
            
            dialogs.Remove(dialog.Key);
        }

        private static System.Drawing.Size GetRealSize(int width, int height)
        {
            Matrix transformToDevice;

            using (var source = new HwndSource(new HwndSourceParameters()))
            {
                transformToDevice = source.CompositionTarget.TransformToDevice;
            }

            var pixelSize = transformToDevice.Transform(new Vector(width, height));

            return new System.Drawing.Size((int)pixelSize.X, (int)pixelSize.Y);
        }
    }
}