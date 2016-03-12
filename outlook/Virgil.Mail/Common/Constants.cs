namespace Virgil.Mail.Common
{
    internal class Constants
    {

        internal const string VirgilHtmlBodyElementId = "virgil-info";
        internal const string VirgilAttachmentName = "virgilsecurity.mailinfo";
        internal const string VirgilMessageClass = "IPM.Note.VirgilMail";
        internal const string VirgilAccessToken = "eyJpZCI6IjU4Y2YxMTQzLTNhOTEtNGEzOS04Y2RkLTI2N2FlNWFiZTliMiIsImFwcGxpY2F0aW9uX2NhcmRfaWQiOiI0Mjc3ZDNjYy05YzdmLTQzNWMtYmNmYy0wNjE1YzkxZTg4ZmUiLCJ0dGwiOi0xLCJjdGwiOi0xLCJwcm9sb25nIjowfQ==.MIGZMA0GCWCGSAFlAwQCAgUABIGHMIGEAkBzWJSyG43LBzfPusOg4XG4xYG5xPqXjfOi+/ax1xgzMNqrVhTxrNWoeOFh8FnAqcD5vkakSqqMPB7oztd2Fsw9AkAJCa5DAxNvbwL9fpT88VKNPAmrVClKj8n8lJbZWSIIpNBrbY/bDze3pmY/7YyJsgo9JdzGq8B8FXk2d3BZXowM";
        internal const string VirgilMailFormRegionName = "Virgil.Mail.FormRegion";
        internal const string EmailFinderRegex = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum)\b";
        internal const string EmailHtmlBodyTemplate = @"
            <html>
            <body>
            	<p>The message has been encrypted with Virgil Mail Add-In.</p>
            	<a href='https://virgilsecurity.com/demos' >Download Virgil Mail Add-In.</a>    
            </body>
            </html>";
        internal const string OutlookAttachmentDataBin = @"http://schemas.microsoft.com/mapi/proptag/0x37010102";
    }
}   