namespace Virgil.Mail
{
    [System.ComponentModel.ToolboxItemAttribute(false)]
    partial class VirgilMailFormRegion : Microsoft.Office.Tools.Outlook.FormRegionBase
    {
        public VirgilMailFormRegion(Microsoft.Office.Interop.Outlook.FormRegion formRegion)
            : base(Globals.Factory, formRegion)
        {
            this.InitializeComponent();
        }

        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
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
            this.mailViewerHost = new System.Windows.Forms.Integration.ElementHost();
            //this.mailViewer = new MailView();
            this.SuspendLayout();
            // 
            // mailViewerHost
            // 
            this.mailViewerHost.Dock = System.Windows.Forms.DockStyle.Fill;
            this.mailViewerHost.Location = new System.Drawing.Point(0, 0);
            this.mailViewerHost.Name = "mailViewerHost";
            this.mailViewerHost.Size = new System.Drawing.Size(874, 695);
            this.mailViewerHost.TabIndex = 0;
            this.mailViewerHost.Text = "mailViewerHost";
            //this.mailViewerHost.Child = this.mailViewer;
            // 
            // VirgilMailFormRegion
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.Controls.Add(this.mailViewerHost);
            this.Name = "VirgilMailFormRegion";
            this.Size = new System.Drawing.Size(874, 695);
            this.FormRegionShowing += new System.EventHandler(this.VirgilMailFormRegion_FormRegionShowing);
            this.FormRegionClosed += new System.EventHandler(this.VirgilMailFormRegion_FormRegionClosed);
            this.ResumeLayout(false);

        }

        #endregion

        #region Form Region Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private static void InitializeManifest(Microsoft.Office.Tools.Outlook.FormRegionManifest manifest, Microsoft.Office.Tools.Outlook.Factory factory)
        {
            manifest.FormRegionName = "VirgilMailFormRegion";
            manifest.FormRegionType = Microsoft.Office.Tools.Outlook.FormRegionType.ReplaceAll;
            manifest.ShowInspectorCompose = false;
            manifest.Title = "VirgilMailFormRegion";

        }

        #endregion

        private System.Windows.Forms.Integration.ElementHost mailViewerHost;
        //private MailView mailViewer;


        public partial class VirgilMailFormRegionFactory : Microsoft.Office.Tools.Outlook.IFormRegionFactory
        {
            public event Microsoft.Office.Tools.Outlook.FormRegionInitializingEventHandler FormRegionInitializing;

            private Microsoft.Office.Tools.Outlook.FormRegionManifest _Manifest;

            [System.Diagnostics.DebuggerNonUserCodeAttribute()]
            public VirgilMailFormRegionFactory()
            {
                this._Manifest = Globals.Factory.CreateFormRegionManifest();
                VirgilMailFormRegion.InitializeManifest(this._Manifest, Globals.Factory);
                this.FormRegionInitializing += new Microsoft.Office.Tools.Outlook.FormRegionInitializingEventHandler(this.VirgilMailFormRegionFactory_FormRegionInitializing);
            }

            [System.Diagnostics.DebuggerNonUserCodeAttribute()]
            public Microsoft.Office.Tools.Outlook.FormRegionManifest Manifest
            {
                get
                {
                    return this._Manifest;
                }
            }

            [System.Diagnostics.DebuggerNonUserCodeAttribute()]
            Microsoft.Office.Tools.Outlook.IFormRegion Microsoft.Office.Tools.Outlook.IFormRegionFactory.CreateFormRegion(Microsoft.Office.Interop.Outlook.FormRegion formRegion)
            {
                VirgilMailFormRegion form = new VirgilMailFormRegion(formRegion);
                form.Factory = this;
                return form;
            }

            [System.Diagnostics.DebuggerNonUserCodeAttribute()]
            byte[] Microsoft.Office.Tools.Outlook.IFormRegionFactory.GetFormRegionStorage(object outlookItem, Microsoft.Office.Interop.Outlook.OlFormRegionMode formRegionMode, Microsoft.Office.Interop.Outlook.OlFormRegionSize formRegionSize)
            {
                throw new System.NotSupportedException();
            }

            [System.Diagnostics.DebuggerNonUserCodeAttribute()]
            bool Microsoft.Office.Tools.Outlook.IFormRegionFactory.IsDisplayedForItem(object outlookItem, Microsoft.Office.Interop.Outlook.OlFormRegionMode formRegionMode, Microsoft.Office.Interop.Outlook.OlFormRegionSize formRegionSize)
            {
                if (this.FormRegionInitializing != null)
                {
                    Microsoft.Office.Tools.Outlook.FormRegionInitializingEventArgs cancelArgs = Globals.Factory.CreateFormRegionInitializingEventArgs(outlookItem, formRegionMode, formRegionSize, false);
                    this.FormRegionInitializing(this, cancelArgs);
                    return !cancelArgs.Cancel;
                }
                else
                {
                    return true;
                }
            }

            [System.Diagnostics.DebuggerNonUserCodeAttribute()]
            Microsoft.Office.Tools.Outlook.FormRegionKindConstants Microsoft.Office.Tools.Outlook.IFormRegionFactory.Kind
            {
                get
                {
                    return Microsoft.Office.Tools.Outlook.FormRegionKindConstants.WindowsForms;
                }
            }
        }
    }

    partial class WindowFormRegionCollection
    {
        internal VirgilMailFormRegion VirgilMailFormRegion
        {
            get
            {
                foreach (var item in this)
                {
                    if (item.GetType() == typeof(VirgilMailFormRegion))
                        return (VirgilMailFormRegion)item;
                }
                return null;
            }
        }
    }
}
