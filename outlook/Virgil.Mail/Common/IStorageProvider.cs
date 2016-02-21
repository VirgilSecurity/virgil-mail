namespace Virgil.Mail.Common
{
    public interface IStorageProvider : IService
    {
        string Load();
        void Save(string data);
    }
}
