namespace Virgil.Mail.Mvvm
{
    using System;

    public class ValidationRule
    {
        public Func<bool> Validator { get; set; }
        public string ErrorMessage { get; set; }
    }
}