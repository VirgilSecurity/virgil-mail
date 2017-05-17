namespace Virgil.Mail.Common
{
    using System.Threading;
    using System.Threading.Tasks;
    using Virgil.Mail.Models;

    public interface IMailObserver : IService
    {
        Task<OutlookMailModel> WaitFor(string accountSmtpAddress, string from, CancellationToken cancellationToken);
    }
}