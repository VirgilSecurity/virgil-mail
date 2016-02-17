namespace Virgil.Mail.Common.Mvvm
{
    using System;
    using System.Windows.Input;

    public class RelayCommand : ICommand
    {
        private readonly Predicate<object> canExecute;
        private readonly Action<object> execute;
        private readonly Action noParamsExecute;
        private readonly bool noParams;

        public RelayCommand(Action execute)
        {
            this.canExecute = param => true;
            this.noParams = true;
            this.noParamsExecute = execute;
        }

        public RelayCommand(Action<object> execute)
        {
            this.canExecute = param => true;
            this.execute = execute;
        }

        public RelayCommand(Predicate<object> canExecute, Action<object> execute)
        {
            this.canExecute = canExecute;
            this.execute = execute;
        }
        
        public bool CanExecute(object parameter)
        {
            return this.canExecute(parameter);
        }

        public void Execute(object parameter)
        {
            if (this.noParams)
                this.noParamsExecute();
            else
                this.execute(parameter);
        }

        public event EventHandler CanExecuteChanged;
    }

    public class RelayCommand<T> : ICommand
    {
        private readonly Predicate<T> canExecute;
        private readonly Action<T> execute;

        public RelayCommand(Action<T> execute)
        {
            this.canExecute = param => true;
            this.execute = execute;
        }

        public RelayCommand(Predicate<T> canExecute, Action<T> execute)
        {
            this.canExecute = canExecute;
            this.execute = execute;
        }

        public bool CanExecute(object parameter)
        {
            return this.canExecute((T)parameter);
        }

        public void Execute(object parameter)
        {
            this.execute((T)parameter);
        }

        public event EventHandler CanExecuteChanged;
    }
}