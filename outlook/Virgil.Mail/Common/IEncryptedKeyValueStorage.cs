namespace Virgil.Mail.Common
{
    public interface IEncryptedKeyValueStorage
    {
        TValue Get<TValue>(string key) where TValue : class;
        void Set<TValue>(string key, TValue value);
    }
}