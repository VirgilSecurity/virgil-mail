namespace Virgil.Mail.Mvvm
{
    using System;

    public class ViewModel : ValidatableModel
    {
        private Enum state;
        private string stateText;
        
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

        public void ChangeStateText(string newStateText)
        {
            this.StateText = newStateText;
        }

        public void ChangeState(Enum newState, string newStateText = null)
        {
            this.State = newState;
            this.StateText = newStateText;
        }
    }
}