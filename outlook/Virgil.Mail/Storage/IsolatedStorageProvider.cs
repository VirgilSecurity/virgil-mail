namespace Virgil.Mail.Storage
{
    using System.IO;
    using System.IO.IsolatedStorage;

    using Virgil.Mail.Common;

    public class IsolatedStorageProvider : IStorageProvider
    {
        public bool Remove(string key)
        {
            using (var storage = GetIsolatedStorage())
            {
                if (!storage.FileExists(key))
                {
                    return false;
                }

                storage.DeleteFile(key);
                return true;
            }
        }

        public string this[string key]
        {
            get { return this.Load(key); }
            set { this.Add(key, value); }
        }

        public void Add(string key, string value)
        {
            using (var storage = GetIsolatedStorage())
            using (var stream = new IsolatedStorageFileStream(key, FileMode.Create, storage))
            {
                using (var writer = new StreamWriter(stream))
                {
                    writer.Write(value);
                }
            }
        }

        private string Load(string key)
        {
            using (var storage = GetIsolatedStorage())
            {
                if (!storage.FileExists(key))
                {
                    return null;
                }

                using (var stream = new IsolatedStorageFileStream(key, FileMode.Open, storage))
                using (var reader = new StreamReader(stream))
                {
                    var data = reader.ReadToEnd();
                    return data;
                }
            }
        }

        private static IsolatedStorageFile GetIsolatedStorage()
        {
            return IsolatedStorageFile.GetStore(IsolatedStorageScope.User | IsolatedStorageScope.Assembly, null, null);
        }
    }
}
