namespace Virgil.Mail.Dialogs
{
    using System.Windows;
    using System.Windows.Input;

    /// <summary>
    /// Represents a shell template for all user dialog windows.
    /// </summary>
    public partial class ShellView
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ShellView"/> class.
        /// </summary>
        public ShellView()
        {
            this.InitializeComponent();
            this.MouseDown += this.OnMouseDown;
        }

        /// <summary>
        /// Called when mouse down.
        /// </summary>
        private void OnMouseDown(object sender, MouseButtonEventArgs args)
        {
            if (args.ChangedButton == MouseButton.Left)
            {
                this.DragMove();
            }
        }

        /// <summary>
        /// Called when close button click.
        /// </summary>
        private void OnCloseButtonClick(object sender, RoutedEventArgs e)
        {
            this.Close();
        }
    }
}
