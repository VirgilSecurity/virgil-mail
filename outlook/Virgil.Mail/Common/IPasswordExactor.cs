namespace Virgil.Mail.Common
{
    public interface IPasswordExactor : IService
    {
        string ExactOrAlarm(string accountSmtpAddress);
    }
}