namespace Virgil.Mail.Common
{
    using System.Threading.Tasks;
    using Virgil.Mail.Models;

    public interface IMailObserver : IService
    {
        Task<OutlookMailModel> WaitFor(string from);
    }
}