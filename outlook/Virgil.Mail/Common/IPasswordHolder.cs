namespace Virgil.Mail.Common
{
    public interface IPasswordHolder : IService
    {
        void Keep(string id, string password);
        string Get(string id);
        void Remove(string outlookAccountEmail);
    }
}
