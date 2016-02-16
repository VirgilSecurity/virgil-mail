namespace Virgil.Mail.Viewer
{
    using System.Windows.Controls;
    
    public partial class Shell : UserControl
    {
        public Shell()
        {
            this.InitializeComponent();
            var dialog = new Settings.RegisterAccount();
            dialog.ShowDialog();
        }
    }
}
