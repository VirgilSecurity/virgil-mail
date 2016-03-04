namespace Virgil.Mail.Common
{
    internal class Constants
    {

        internal const string VirgilHtmlBodyElementId = "virgil-info";
        internal const string VirgilAttachmentName = "virgilsecurity.mailinfo";
        internal const string VirgilMessageClass = "IPM.Note.VirgilMail";
        internal const string VirgilAccessToken = "eyJpZCI6Ijc1MmMyMzM3LTM0YTYtNGRhOS04NzUwLTZhMjZlYWUzOWU2NSIsImFwcGxpY2F0aW9uX2NhcmRfaWQiOiIxMDEwMDBiNS02MDRlLTQ1ZWMtODMzMi00MWFmOTE1MGYzYWUiLCJ0dGwiOi0xLCJjdGwiOi0xLCJwcm9sb25nIjowfQ==.MIGZMA0GCWCGSAFlAwQCAgUABIGHMIGEAkBd0GMYg9I2H/cQz7jbL1EPJLLUnWePpGfc5LyjNgidAq9z/4rYDFRYyv6wPKJDx6KysCqLIWgH2YfmMTCtBYL1AkArX14rnAYP63brY3QMP01z2c/zf3K06O+jr9eDshETGRxIoumhqTcbRP/00KjBlEGb8Ip7KX0wo/vPYNpzqf91";
        internal const string VirgilMailFormRegionName = "Virgil.Mail.FormRegion";
        internal const string EmailFinderRegex = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum)\b";
        internal const string EmailHtmlBodyTemplate = @"
            <html>
            <body>
            	<p>The message has been encrypted with Virgil Mail Add-In.</p>
            	<a href='https://virgilsecurity.com/demos' >Download Virgil Mail Add-In.</a>    
            </body>
            </html>";
        internal const string OutlookAttachmentDataBin = "http://schemas.microsoft.com/mapi/proptag/0x37010102";
    }
}   