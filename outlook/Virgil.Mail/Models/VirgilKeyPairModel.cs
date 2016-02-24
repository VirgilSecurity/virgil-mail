namespace Virgil.Mail.Models
{
    public class VirgilKeyPairModel
    {
        public string Identity { get; set; }
        public byte[] PublicKey { get; set; }
        public byte[] PrivateKey { get; set; }
    }
}
