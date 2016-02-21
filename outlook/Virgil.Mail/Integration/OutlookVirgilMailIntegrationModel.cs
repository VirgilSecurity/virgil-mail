namespace Virgil.Mail.Integration
{
    public class OutlookVirgilMailIntegrationModel
    {
        public string Id { get; set; }
        public byte[] EmailData { get; set; }
        public byte[] Sign { get; set; }
    }
}