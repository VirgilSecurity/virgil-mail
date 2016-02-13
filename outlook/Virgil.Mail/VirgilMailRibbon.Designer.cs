namespace Virgil.Mail
{
    partial class VirgilMailRibbon : Microsoft.Office.Tools.Ribbon.RibbonBase
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        public VirgilMailRibbon()
            : base(Globals.Factory.GetRibbonFactory())
        {
            InitializeComponent();
        }

        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Component Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.newMailTab = this.Factory.CreateRibbonTab();
            this.encryptionGroup = this.Factory.CreateRibbonGroup();
            this.button1 = this.Factory.CreateRibbonButton();
            this.encryptButton = this.Factory.CreateRibbonToggleButton();
            this.mainTabMail = this.Factory.CreateRibbonTab();
            this.mainEncryptionGroup = this.Factory.CreateRibbonGroup();
            this.mailKeysButton = this.Factory.CreateRibbonButton();
            this.newMailTab.SuspendLayout();
            this.encryptionGroup.SuspendLayout();
            this.mainTabMail.SuspendLayout();
            this.mainEncryptionGroup.SuspendLayout();
            this.SuspendLayout();
            // 
            // newMailTab
            // 
            this.newMailTab.ControlId.ControlIdType = Microsoft.Office.Tools.Ribbon.RibbonControlIdType.Office;
            this.newMailTab.ControlId.OfficeId = "TabNewMailMessage";
            this.newMailTab.Groups.Add(this.encryptionGroup);
            this.newMailTab.Label = "TabNewMailMessage";
            this.newMailTab.Name = "newMailTab";
            // 
            // encryptionGroup
            // 
            this.encryptionGroup.Items.Add(this.button1);
            this.encryptionGroup.Items.Add(this.encryptButton);
            this.encryptionGroup.Label = "Encryption";
            this.encryptionGroup.Name = "encryptionGroup";
            this.encryptionGroup.Position = this.Factory.RibbonPosition.AfterOfficeId("GroupBasicText");
            // 
            // button1
            // 
            this.button1.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.button1.Description = "sdadasd asdasdasd";
            this.button1.Label = "Virgil Keys";
            this.button1.Name = "button1";
            this.button1.ShowImage = true;
            this.button1.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.mailKeysButton_Click);
            // 
            // encryptButton
            // 
            this.encryptButton.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.encryptButton.Label = "Encrypt Mail";
            this.encryptButton.Name = "encryptButton";
            this.encryptButton.OfficeImageId = "FileDocumentEncrypt";
            this.encryptButton.ShowImage = true;
            this.encryptButton.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.encryptButton_Click);
            // 
            // mainTabMail
            // 
            this.mainTabMail.ControlId.ControlIdType = Microsoft.Office.Tools.Ribbon.RibbonControlIdType.Office;
            this.mainTabMail.ControlId.OfficeId = "TabMail";
            this.mainTabMail.Groups.Add(this.mainEncryptionGroup);
            this.mainTabMail.Label = "TabMail";
            this.mainTabMail.Name = "mainTabMail";
            // 
            // mainEncryptionGroup
            // 
            this.mainEncryptionGroup.Items.Add(this.mailKeysButton);
            this.mainEncryptionGroup.Label = "Encryption";
            this.mainEncryptionGroup.Name = "mainEncryptionGroup";
            this.mainEncryptionGroup.Position = this.Factory.RibbonPosition.AfterOfficeId("GroupMailNew");
            // 
            // mailKeysButton
            // 
            this.mailKeysButton.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.mailKeysButton.Label = "Virgil Keys";
            this.mailKeysButton.Name = "mailKeysButton";
            this.mailKeysButton.ShowImage = true;
            this.mailKeysButton.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.mailKeysButton_Click);
            // 
            // VirgilMailRibbon
            // 
            this.Name = "VirgilMailRibbon";
            this.RibbonType = "Microsoft.Outlook.Explorer, Microsoft.Outlook.Mail.Compose, Microsoft.Outlook.Mai" +
    "l.Read, Microsoft.Outlook.Post.Compose, Microsoft.Outlook.Resend";
            this.Tabs.Add(this.newMailTab);
            this.Tabs.Add(this.mainTabMail);
            this.Load += new Microsoft.Office.Tools.Ribbon.RibbonUIEventHandler(this.VirgilOutlookRibbon_Load);
            this.newMailTab.ResumeLayout(false);
            this.newMailTab.PerformLayout();
            this.encryptionGroup.ResumeLayout(false);
            this.encryptionGroup.PerformLayout();
            this.mainTabMail.ResumeLayout(false);
            this.mainTabMail.PerformLayout();
            this.mainEncryptionGroup.ResumeLayout(false);
            this.mainEncryptionGroup.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        internal Microsoft.Office.Tools.Ribbon.RibbonTab newMailTab;
        internal Microsoft.Office.Tools.Ribbon.RibbonGroup encryptionGroup;
        private Microsoft.Office.Tools.Ribbon.RibbonTab mainTabMail;
        internal Microsoft.Office.Tools.Ribbon.RibbonGroup mainEncryptionGroup;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton button1;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton mailKeysButton;
        internal Microsoft.Office.Tools.Ribbon.RibbonToggleButton encryptButton;
    }

    partial class ThisRibbonCollection
    {
        internal VirgilMailRibbon VirgilMailRibbon
        {
            get { return this.GetRibbon<VirgilMailRibbon>(); }
        }
    }
}
