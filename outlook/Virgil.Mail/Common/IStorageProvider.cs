namespace Virgil.Mail.Common
{
    public interface IStorageProvider : IService
    {
        bool Remove(string key);
        string this[string key] { get; set; }
        void Add(string key, string value);
    }
}
