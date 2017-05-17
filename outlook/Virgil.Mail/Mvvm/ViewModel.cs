namespace Virgil.Mail.Mvvm
{
    using System;
    using System.ComponentModel;
    using System.Threading;

    public class ViewModel : ValidatableModel
    {
        private Enum state;
        private string stateText;
        private Action closeAction;
        protected CancellationTokenSource cts = new CancellationTokenSource();


        public Enum State
        {
            get
            {
                return this.state;
            }
            private set
            {
                this.state = value;
                this.RaisePropertyChanged();
            }
        }

        public string StateText
        {
            get
            {
                return this.stateText;
            }
            private set
            {
                this.stateText = value;
                this.RaisePropertyChanged();
            }
        }

        public object Result { get; set; }
        
        public void ChangeStateText(string newStateText)
        {
            this.StateText = newStateText;
        }

        public void ChangeState(Enum newState, string newStateText = null)
        {
            this.State = newState;
            this.StateText = newStateText;
        }

        public void SetCloseAction(Action action)
        {
            this.closeAction = action;
        }

        public void Close()
        {
            this.closeAction?.Invoke();
        }

        public virtual void OnMandatoryClosing(object sender, CancelEventArgs cancelEventArgs)
        {
            cancelEventArgs.Cancel = false;
        }
    }
}