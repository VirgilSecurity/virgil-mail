namespace Virgil.Mail.Models
{
    public class VirgilMailModel
    {
        public byte[] EmailData { get; set; }
        public byte[] Sign { get; set; }
    }

    public class EncryptedMailModel
    {
        public string UniqueId { get; set; }
        public string Body { get; set; }
        public string HtmlBody { get; set; }
        public string Subject { get; set; }
    }
}