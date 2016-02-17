namespace Virgil.Mail.Models
{
    public class VirgilMailModel
    {
        public string Id { get; set; }
        public byte[] EmailData { get; set; }
        public byte[] Sign { get; set; }
    }
}