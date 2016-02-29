namespace Virgil.Mail.Common.Exceptions
{
    using System;
    using System.Runtime.Serialization;

    public class VirgilMailException : Exception
    {
        public VirgilMailException(string message) : base(message)
        {
        }

        public VirgilMailException(string message, Exception innerException) : base(message, innerException)
        {
        }

        protected VirgilMailException(SerializationInfo info, StreamingContext context) : base(info, context)
        {
        }
    }
}