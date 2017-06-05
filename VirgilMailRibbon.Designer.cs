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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(VirgilMailRibbon));
            this.mainTabMail = this.Factory.CreateRibbonTab();
            this.mainEncryptionGroup = this.Factory.CreateRibbonGroup();
            this.mailKeysButton = this.Factory.CreateRibbonButton();
            this.newMailTab = this.Factory.CreateRibbonTab();
            this.encryptionGroup = this.Factory.CreateRibbonGroup();
            this.virgilKeysButton = this.Factory.CreateRibbonButton();
            this.encryptButton = this.Factory.CreateRibbonToggleButton();
            this.mainTabDraft = this.Factory.CreateRibbonTab();
            this.draftEncryptionGroup = this.Factory.CreateRibbonGroup();
            this.virgilKeysButtonForDraft = this.Factory.CreateRibbonButton();
            this.encryptButtonForDraft = this.Factory.CreateRibbonToggleButton();
            this.mainTabMail.SuspendLayout();
            this.mainEncryptionGroup.SuspendLayout();
            this.newMailTab.SuspendLayout();
            this.encryptionGroup.SuspendLayout();
            this.mainTabDraft.SuspendLayout();
            this.draftEncryptionGroup.SuspendLayout();
            this.SuspendLayout();
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
            this.mailKeysButton.Image = global::Virgil.Mail.Properties.Resources.icon_512x512_2x;
            this.mailKeysButton.Label = "Virgil Keys";
            this.mailKeysButton.Name = "mailKeysButton";
            this.mailKeysButton.ShowImage = true;
            this.mailKeysButton.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.mailKeysButton_Click);
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
            this.encryptionGroup.Items.Add(this.virgilKeysButton);
            this.encryptionGroup.Items.Add(this.encryptButton);
            this.encryptionGroup.Label = "Encryption";
            this.encryptionGroup.Name = "encryptionGroup";
            this.encryptionGroup.Position = this.Factory.RibbonPosition.AfterOfficeId("GroupBasicText");
            // 
            // virgilKeysButton
            // 
            this.virgilKeysButton.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.virgilKeysButton.Description = "sdadasd asdasdasd";
            this.virgilKeysButton.Image = global::Virgil.Mail.Properties.Resources.icon_512x512_2x;
            this.virgilKeysButton.Label = "Virgil Keys";
            this.virgilKeysButton.Name = "virgilKeysButton";
            this.virgilKeysButton.ShowImage = true;
            this.virgilKeysButton.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.mailKeysButton_Click);
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
            // mainTabDraft
            // 
            this.mainTabDraft.ControlId.ControlIdType = Microsoft.Office.Tools.Ribbon.RibbonControlIdType.Office;
            this.mainTabDraft.ControlId.OfficeId = "TabMessage";
            this.mainTabDraft.Groups.Add(this.draftEncryptionGroup);
            this.mainTabDraft.Label = "TabMessage";
            this.mainTabDraft.Name = "mainTabDraft";
            // 
            // draftEncryptionGroup
            // 
            this.draftEncryptionGroup.Items.Add(this.virgilKeysButtonForDraft);
            this.draftEncryptionGroup.Items.Add(this.encryptButtonForDraft);
            this.draftEncryptionGroup.Label = "Encryption";
            this.draftEncryptionGroup.Name = "draftEncryptionGroup";
            this.draftEncryptionGroup.Position = this.Factory.RibbonPosition.AfterOfficeId("GroupBasicText");
            // 
            // virgilKeysButtonForDraft
            // 
            this.virgilKeysButtonForDraft.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.virgilKeysButtonForDraft.Description = "sdadasd asdasdasd aaaa";
            this.virgilKeysButtonForDraft.Image = global::Virgil.Mail.Properties.Resources.icon_512x512_2x;
            this.virgilKeysButtonForDraft.Label = "Virgil Keys";
            this.virgilKeysButtonForDraft.Name = "virgilKeysButtonForDraft";
            this.virgilKeysButtonForDraft.ShowImage = true;
            this.virgilKeysButtonForDraft.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.mailKeysButton_Click);
            // 
            // encryptButtonForDraft
            // 
            this.encryptButtonForDraft.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.encryptButtonForDraft.Label = "Encrypt Mail";
            this.encryptButtonForDraft.Name = "encryptButtonForDraft";
            this.encryptButtonForDraft.OfficeImageId = "FileDocumentEncryptDraft";
            this.encryptButtonForDraft.ShowImage = true;
            this.encryptButtonForDraft.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.encryptButton_Click);
            // 
            // VirgilMailRibbon
            // 
            this.Name = "VirgilMailRibbon";
            this.RibbonType = resources.GetString("$this.RibbonType");
            this.Tabs.Add(this.newMailTab);
            this.Tabs.Add(this.mainTabMail);
            this.Tabs.Add(this.mainTabDraft);
            this.Load += new Microsoft.Office.Tools.Ribbon.RibbonUIEventHandler(this.VirgilOutlookRibbon_Load);
            this.mainTabMail.ResumeLayout(false);
            this.mainTabMail.PerformLayout();
            this.mainEncryptionGroup.ResumeLayout(false);
            this.mainEncryptionGroup.PerformLayout();
            this.newMailTab.ResumeLayout(false);
            this.newMailTab.PerformLayout();
            this.encryptionGroup.ResumeLayout(false);
            this.encryptionGroup.PerformLayout();
            this.mainTabDraft.ResumeLayout(false);
            this.mainTabDraft.PerformLayout();
            this.draftEncryptionGroup.ResumeLayout(false);
            this.draftEncryptionGroup.PerformLayout();
            this.ResumeLayout(false);

        }

        private void InitializeMainMenuItem()
        {
            this.mainTabMail = this.Factory.CreateRibbonTab();
            this.mainEncryptionGroup = this.Factory.CreateRibbonGroup();
            this.mailKeysButton = this.Factory.CreateRibbonButton();

            this.mainEncryptionGroup.SuspendLayout();
            this.mainTabMail.SuspendLayout();
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
            this.mailKeysButton.Image = global::Virgil.Mail.Properties.Resources.icon_512x512_2x;
            this.mailKeysButton.Label = "Virgil Keys";
            this.mailKeysButton.Name = "mailKeysButton";
            this.mailKeysButton.ShowImage = true;
            this.mailKeysButton.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.mailKeysButton_Click);

            this.mainTabMail.ResumeLayout(false);
            this.mainTabMail.PerformLayout();
            this.mainEncryptionGroup.ResumeLayout(false);
            this.mainEncryptionGroup.PerformLayout();
        }

        private void InitializeNewEmailMenuItem()
        {
            this.newMailTab = this.Factory.CreateRibbonTab();
            this.encryptionGroup = this.Factory.CreateRibbonGroup();

            this.virgilKeysButton = this.Factory.CreateRibbonButton();
            this.encryptButton = this.Factory.CreateRibbonToggleButton();
           
            this.newMailTab.SuspendLayout();
            this.encryptionGroup.SuspendLayout();

            // 
            // newMailTab
            // 
            this.newMailTab.ControlId.ControlIdType = Microsoft.Office.Tools.Ribbon.RibbonControlIdType.Office;
            this.newMailTab.ControlId.OfficeId = "TabNewMailMessage";
            this.newMailTab.Groups.Add(this.encryptionGroup);
            this.newMailTab.Label = "TabNewMailMessage";
            this.newMailTab.Name = "newMailTab";

            // 
            // virgilKeysButton
            // 
            this.virgilKeysButton.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.virgilKeysButton.Description = "sdadasd asdasdasd";
            this.virgilKeysButton.Image = global::Virgil.Mail.Properties.Resources.icon_512x512_2x;
            this.virgilKeysButton.Label = "Virgil Keys";
            this.virgilKeysButton.Name = "virgilKeysButton";
            this.virgilKeysButton.ShowImage = true;
            this.virgilKeysButton.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.mailKeysButton_Click);
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
            // encryptionGroup
            // 
            this.encryptionGroup.Items.Add(this.virgilKeysButton);
            this.encryptionGroup.Items.Add(this.encryptButton);
            this.encryptionGroup.Label = "Encryption";
            this.encryptionGroup.Name = "encryptionGroup";
            this.encryptionGroup.Position = this.Factory.RibbonPosition.AfterOfficeId("GroupBasicText");

            this.newMailTab.ResumeLayout(false);
            this.newMailTab.PerformLayout();
            this.encryptionGroup.ResumeLayout(false);
            this.encryptionGroup.PerformLayout();


        }

        private void InitializeDraftPreviewMenuItem()
        {
            this.mainTabDraft = this.Factory.CreateRibbonTab();
            this.draftEncryptionGroup = this.Factory.CreateRibbonGroup();
            this.virgilKeysButtonForDraft = this.Factory.CreateRibbonButton();
            this.encryptButtonForDraft = this.Factory.CreateRibbonToggleButton();
            this.mainTabDraft.SuspendLayout();
            this.draftEncryptionGroup.SuspendLayout();

            // 
            // mainTabDraft
            // 
            this.mainTabDraft.ControlId.ControlIdType = Microsoft.Office.Tools.Ribbon.RibbonControlIdType.Office;
            this.mainTabDraft.ControlId.OfficeId = "DraftTab";
            this.mainTabDraft.Groups.Add(this.draftEncryptionGroup);
            this.mainTabDraft.Label = "TabDraftMessage";
            this.mainTabDraft.Name = "mainTabDraft";


            // 
            // virgilKeysButtonForDraft
            // 
            this.virgilKeysButtonForDraft.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.virgilKeysButtonForDraft.Description = "sdadasd asdasdasd aaaa";
            this.virgilKeysButtonForDraft.Image = global::Virgil.Mail.Properties.Resources.icon_512x512_2x;
            this.virgilKeysButtonForDraft.Label = "Virgil Keys";
            this.virgilKeysButtonForDraft.Name = "virgilKeysButtonDraft";
            this.virgilKeysButtonForDraft.ShowImage = true;
            this.virgilKeysButtonForDraft.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.mailKeysButton_Click);
            // 
            // encryptButtonForDraft
            // 
            this.encryptButtonForDraft.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.encryptButtonForDraft.Label = "Encrypt Mail";
            this.encryptButtonForDraft.Name = "encryptButton";
            this.encryptButtonForDraft.OfficeImageId = "FileDocumentEncryptDraft";
            this.encryptButtonForDraft.ShowImage = true;
            this.encryptButtonForDraft.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.encryptButton_Click);

            // 
            // draftEncryptionGroup
            // 
            this.draftEncryptionGroup.Label = "Encryption";
            this.draftEncryptionGroup.Name = "draftEncryptionGroup";
            this.draftEncryptionGroup.Position = this.Factory.RibbonPosition.AfterOfficeId("GroupBasicText");
            this.draftEncryptionGroup.Items.Add(virgilKeysButtonForDraft);
            this.draftEncryptionGroup.Items.Add(encryptButtonForDraft);


            this.mainTabDraft.ResumeLayout(false);
            this.mainTabDraft.PerformLayout();

            this.draftEncryptionGroup.ResumeLayout(false);
            this.draftEncryptionGroup.PerformLayout();
        }

        #endregion

        internal Microsoft.Office.Tools.Ribbon.RibbonTab newMailTab;
        internal Microsoft.Office.Tools.Ribbon.RibbonGroup encryptionGroup;
        private Microsoft.Office.Tools.Ribbon.RibbonTab mainTabMail;
        internal Microsoft.Office.Tools.Ribbon.RibbonGroup mainEncryptionGroup;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton virgilKeysButton;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton mailKeysButton;
        internal Microsoft.Office.Tools.Ribbon.RibbonToggleButton encryptButton;
        internal Microsoft.Office.Tools.Ribbon.RibbonGroup draftEncryptionGroup;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton virgilKeysButtonForDraft;
        internal Microsoft.Office.Tools.Ribbon.RibbonToggleButton encryptButtonForDraft;
        internal Microsoft.Office.Tools.Ribbon.RibbonTab mainTabDraft;
    }

    partial class ThisRibbonCollection
    {
        internal VirgilMailRibbon VirgilMailRibbon
        {
            get { return this.GetRibbon<VirgilMailRibbon>(); }
        }
    }
}
