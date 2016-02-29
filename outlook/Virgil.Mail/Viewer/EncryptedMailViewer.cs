namespace Virgil.Mail.Viewer
{
    using System.Diagnostics;
    using System.Windows;
    using System.Windows.Controls;
    using System.Windows.Navigation;

    using HtmlAgilityPack;

    public class EncryptedMailViewer : UserControl
    {
        public static readonly DependencyProperty HtmlProperty = DependencyProperty.Register(
            "Html", typeof (string), typeof (EncryptedMailViewer), new PropertyMetadata(default(string), HtmlPropertyChangedCallback));

        private readonly WebBrowser webBrowser;

        public EncryptedMailViewer()
        {
            this.webBrowser = new WebBrowser();
            this.Content = this.webBrowser;

            this.webBrowser.Navigating += this.WebBrowserOnNavigating;
        }
        
        public string Html
        {
            get { return (string)this.GetValue(HtmlProperty); }
            set { this.SetValue(HtmlProperty, value); }
        }

        private void WebBrowserOnNavigating(object sender, NavigatingCancelEventArgs args)
        {
            if (args.Uri != null)
            {
                Process.Start(args.Uri.ToString());
                args.Cancel = true;
            }
        }

        private static void HtmlPropertyChangedCallback(DependencyObject dependencyObject, DependencyPropertyChangedEventArgs args)
        {
            var viewer = (EncryptedMailViewer) dependencyObject;

            if (args.NewValue == null)
            {
                viewer.webBrowser.NavigateToString("");
                return;
            }

            var document = new HtmlDocument();

            document.LoadHtml(args.NewValue.ToString());
            var head = document.DocumentNode.SelectSingleNode("/html/head");
            var encodingNode = HtmlNode.CreateNode("<meta http-equiv='Content-Type' content='text/html;charset=UTF-8'>");
            head?.AppendChild(encodingNode);

            document.DocumentNode.SelectSingleNode("/html/body").Attributes.Add("oncontextmenu", "return false;");
            var processedHtml = document.DocumentNode.InnerHtml;

            viewer.webBrowser.NavigateToString(processedHtml);
        }
    }
}