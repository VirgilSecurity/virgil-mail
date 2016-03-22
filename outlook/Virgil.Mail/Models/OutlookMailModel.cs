namespace Virgil.Mail.Models
{
    public class OutlookMailModel
    {
        public string EntryID { get; set; }
        public string From { get; set; }
        public string To { get; set; }
        public string Body { get; set; }
        public bool IsJunk { get; set; }
    }
}