namespace Virgil.Mail.Dialogs
{
    using System.Windows;
    using System.Windows.Forms;
    using System.Windows.Interop;
    using System.Windows.Media;

    using Virgil.Mail.Mvvm;

    public class DialogBuilder
    {
        public static Dialog Build
        (
            System.Windows.Controls.UserControl view,
            ViewModel viewModel,
            string title, 
            int width, 
            int height,
            bool showIcon = true,
            bool showInTaskbar = false
        )
        {
            view.DataContext = viewModel;
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

            var dialog = new Dialog(shell, view, viewModel);
            return dialog;
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