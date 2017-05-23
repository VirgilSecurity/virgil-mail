using Virgil.SDK;

namespace Virgil.Mail.Models
{
    public class VirgilMailModel
    {
        public VirgilBuffer EmailData { get; set; }
        public VirgilBuffer Sign { get; set; }
    }
}