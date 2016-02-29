namespace Virgil.Mail.Common.Exceptions
{
    public class PrivateKeyPasswordIsNotFoundException : VirgilMailException
    {
        public PrivateKeyPasswordIsNotFoundException() : base("Private Key password is not found")
        {
        }
    }
}