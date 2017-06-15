namespace Virgil.Mail.Models
{
    using SDK;
    using System.Collections.Generic;

    public class RecipientSearchResultModel
    {
        public string Identity  { get; set; }
        public VirgilCard[] VirgilCards { get; set; }
        public bool IsFound => (this.VirgilCards.Length > 0);
    }
}