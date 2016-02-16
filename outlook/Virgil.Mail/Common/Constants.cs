namespace Virgil.Mail.Common
{
    internal class Constants
    {
        internal const string VirgilHtmlBodyElementId = "virgil-info";
        internal const string VirgilMessageClass = "IPM.Note.VirgilMail";
        internal const string VirgilMailFormRegionName = "Virgil.Mail.FormRegion";
        internal const string EmailFinderRegex = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum)\b";
        internal const string EmailHtmlBodyTemplate = @"
            <html>
            <body>
            	<p>The message has been encrypted with Virgil Mail Add-In.</p>
            	<a href='https://virgilsecurity.com/downloads/' >Download Virgil Mail Add-In.</a>            	
            	<input id='virgil-info' type='hidden' value='{0}' />
            </body>
            </html>";

    }
}   