namespace Virgil.Mail.Common.Exceptions
{
    public class PasswordExactionException : VirgilMailException
    {
        public PasswordExactionException() : base("Private Key password is not provided")
        {
        }
    }
}