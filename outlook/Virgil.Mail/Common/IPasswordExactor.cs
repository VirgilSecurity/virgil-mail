namespace Virgil.Mail.Common
{
    public interface IPasswordExactor : IService
    {
        string Exact(string accountSmtpAddress);
        string ExactOrAlarm(string accountSmtpAddress);
    }
}