namespace Virgil.Mail.Common.Mvvm
{
    using System;
    using System.ComponentModel;
    using System.Runtime.CompilerServices;

    using Virgil.Mail.Properties;

    public class ViewModel : ValidatableModel, INotifyPropertyChanged
    {
        private Enum state;
        private string stateText;

        public event PropertyChangedEventHandler PropertyChanged;

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

        public void ChangeStateText(string stateText)
        {
            this.StateText = stateText;
        }

        public void ChangeState(Enum state, string stateText = null)
        {
            this.State = state;
            this.StateText = stateText;
        }

        [NotifyPropertyChangedInvocator]
        protected virtual void RaisePropertyChanged([CallerMemberName] string propertyName = null)
        {
            var handler = this.PropertyChanged;
            if (handler != null)
            {
                handler(this, new PropertyChangedEventArgs(propertyName));
            }
        }
    }
}