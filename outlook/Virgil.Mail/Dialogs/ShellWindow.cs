namespace Virgil.Mail.Dialogs
{
    using System.Drawing;
    using System.Windows.Forms;

    public partial class ShellWindow : Form
    {
        public ShellWindow()
        {
            this.InitializeComponent();

            this.AutoScaleMode = AutoScaleMode.Font;
            this.AutoScaleDimensions = new SizeF(6F, 13F);
        }
    }
}
