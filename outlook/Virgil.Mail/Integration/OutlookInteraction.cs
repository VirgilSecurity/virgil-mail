namespace Virgil.Mail.Integration
{
    using System.Collections.Generic;
    using System.Linq;
    using System.Runtime.InteropServices;

    using Outlook = Microsoft.Office.Interop.Outlook;

    using Virgil.Mail.Integration;
    using Virgil.Mail.Common;

    internal class OutlookInteraction : IOutlookInteraction
    {
        private readonly Outlook.Application application;

        public OutlookInteraction(Outlook.Application application)
        {
            this.application = application;
        }

        public IEnumerable<AccountIntegrationModel> GetOutlookAccounts()
        {
            Outlook.NameSpace ns = null;
            Outlook.Accounts accounts = null;
            Outlook.Account account = null;

            var result = new List<AccountIntegrationModel>();

            try
            {
                ns = this.application.Session;
                accounts = ns.Accounts;
                for (int i = 1; i <= accounts.Count; i++)
                {
                    account = accounts[i];

                    if (result.All(it => it.Email != account.SmtpAddress))
                    {
                        result.Add(new AccountIntegrationModel
                        {
                            Email = account.SmtpAddress,
                            Description = account.UserName
                        });
                    }

                    if (account != null)
                        Marshal.ReleaseComObject(account);
                }

                return result;
            }
            finally
            {
                accounts.ReleaseCom();
                account.ReleaseCom();
                ns.ReleaseCom();
            }
        }
    }
}
