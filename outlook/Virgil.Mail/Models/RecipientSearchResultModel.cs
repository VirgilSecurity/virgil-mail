namespace Virgil.Mail.Models
{
    using SDK;
    using System;

    public class RecipientSearchResultModel
    {
        public string Identity  { get; set; }
        public VirgilCard virgilCard { get; set; }
        public bool IsFound => this.virgilCard != null;
    }
}