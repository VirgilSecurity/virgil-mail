namespace Virgil.Mail.Mvvm
{
    using System;
    using System.Linq;
    using System.Collections;
    using System.Collections.Concurrent;
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.ComponentModel.DataAnnotations;
    using System.Runtime.CompilerServices;
    using System.Threading.Tasks;
    using Virgil.Mail.Properties;

    public class ValidatableModel : INotifyDataErrorInfo, INotifyPropertyChanged
    {
        private readonly ConcurrentDictionary<string, List<string>> errors =
            new ConcurrentDictionary<string, List<string>>();

        private readonly ConcurrentStack<ValidationRule> validationRules = 
            new ConcurrentStack<ValidationRule>();

        private readonly object @lock = new object();

        public event EventHandler<DataErrorsChangedEventArgs> ErrorsChanged;
        
        public IEnumerable GetErrors(string propertyName)
        {
            List<string> errorsForName;
            this.errors.TryGetValue(propertyName, out errorsForName);

            return errorsForName;
        }
        
        public bool HasErrors
        {
            get { return this.errors.Any(kv => kv.Value != null && kv.Value.Count > 0); }
        }

        public string FirstErrorMessage
        {
            get
            {
                if (this.errors.Any())
                {
                    return this.errors[this.errors.Keys.First()][0];
                }

                return null;
            }
        }

        public void AddValidationRule(Func<bool> rule, string errorMessage)
        {
            this.validationRules.Push(new ValidationRule
            {
                Validator = rule,
                ErrorMessage = errorMessage
            });
        }

        public void AddCustomError(string errorMessage)
        {
            this.errors.TryAdd($"CustomError", new List<string> { errorMessage });
            this.RaisePropertyChanged("HasErrors");
            this.RaisePropertyChanged("FirstErrorMessage");
        }

        public Task ValidateAsync()
        {
            return Task.Run(() => this.Validate());
        }
        
        public void Validate()
        {
            lock (this.@lock)
            {
                this.ClearErrors();

                var validationContext = new ValidationContext(this, null, null);
                var validationResults = new List<ValidationResult>();

                Validator.TryValidateObject(this, validationContext, validationResults, true);

                foreach (var kv in this.errors.ToList())
                {
                    if (validationResults.All(r => r.MemberNames.All(m => m != kv.Key)))
                    {
                        List<string> outLi;
                        this.errors.TryRemove(kv.Key, out outLi);
                        this.OnErrorsChanged(kv.Key);
                    }
                }

                var q = from r in validationResults
                        from m in r.MemberNames
                        group r by m into g
                        select g;

                foreach (var prop in q)
                {
                    var messages = prop.Select(r => r.ErrorMessage).ToList();

                    if (this.errors.ContainsKey(prop.Key))
                    {
                        List<string> outLi;
                        this.errors.TryRemove(prop.Key, out outLi);
                    }
                    this.errors.TryAdd(prop.Key, messages);
                    this.OnErrorsChanged(prop.Key);
                    this.RaisePropertyChanged("HasErrors");
                    this.RaisePropertyChanged("FirstErrorMessage");
                }

                foreach (var validationRule in this.validationRules)
                {
                    if (!validationRule.Validator())
                    {
                        var ruleNumber = this.validationRules.ToList().IndexOf(validationRule);
                        this.errors.TryAdd($"ValidationRule{ruleNumber}", new List<string> { validationRule.ErrorMessage });

                        this.RaisePropertyChanged("HasErrors");
                        this.RaisePropertyChanged("FirstErrorMessage");
                    }
                }
            }
        }

        public void ClearErrors()
        {
            this.errors.Clear();
            this.RaisePropertyChanged("HasErrors");
            this.RaisePropertyChanged("FirstErrorMessage");
        }

        public void OnErrorsChanged(string propertyName)
        {
            var handler = this.ErrorsChanged;
            handler?.Invoke(this, new DataErrorsChangedEventArgs(propertyName));
        }

        public event PropertyChangedEventHandler PropertyChanged;

        [NotifyPropertyChangedInvocator]
        protected virtual void RaisePropertyChanged([CallerMemberName] string propertyName = null)
        {
            var handler = this.PropertyChanged;
            handler?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}