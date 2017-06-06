namespace Virgil.Mail.Accounts
{
    public enum RegisterAccountState
    {
        PrivateKeyPassword,
        GenerateKeyPair,
        DownloadKeyPair,
        DownloadOrGenerateKeyPair,
        Processing,
        Done
    }
}
