namespace Virgil.Mail.Common.Models
{
    using System;

    public class VirgilAccountModel
    {
        public Guid CardId { get; set; }
        public string OutlookAccountDescription { get; set; }
        public string OutlookAccountEmail { get; set; }
        public string CreatedAt { get; set; }
        public byte[] PublicKey { get; set; }
    }
}   
    