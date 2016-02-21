namespace Virgil.Mail.Storage
{
    using System.IO;
    using System.IO.IsolatedStorage;

    using Virgil.Mail.Common;

    public class IsolatedStorageProvider : IStorageProvider
    {
        private const string FolderName = "VirgilSecurity";
        private const string FileName = "keys";

        private readonly string FilePath = string.Format("{0}/{1}", FolderName, FileName);

        public void Save(string data)
        {
            using (var storage = GetIsolatedStorage())
            using (var stream = new IsolatedStorageFileStream(this.FilePath, FileMode.Create, storage))
            {
                using (var writer = new StreamWriter(stream))
                {
                    writer.Write(data);
                }
            }
        }

        public string Load()
        {
            this.EnsureFileExists();

            using (var storage = GetIsolatedStorage())
            using (var stream = new IsolatedStorageFileStream(this.FilePath, FileMode.OpenOrCreate, storage))
            {
                using (var reader = new StreamReader(stream))
                {
                    var data = reader.ReadToEnd();
                    return data;
                }
            }
        }

        private void EnsureFileExists()
        {
            using (var storage = GetIsolatedStorage())
            {
                if (!storage.FileExists(this.FilePath))
                {
                    storage.CreateDirectory(FolderName);
                    using (var stream = storage.CreateFile(this.FilePath))
                    using (var writer = new StreamWriter(stream))
                    {
                        writer.Write(string.Empty);
                    }
                }
            }
        }

        private static IsolatedStorageFile GetIsolatedStorage()
        {
            return IsolatedStorageFile.GetStore(IsolatedStorageScope.User | IsolatedStorageScope.Assembly, null, null);
        }
    }
}
