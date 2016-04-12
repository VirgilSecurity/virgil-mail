namespace Virgil.Mail.Dialogs
{
    using System.Collections.Generic;

    public interface IShellContentViewModel
    {
        void Initialize(IDictionary<string, object> args);
    }
}