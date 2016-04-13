namespace Virgil.Mail.Common
{
    using System;
    using Virgil.Mail.Common.Messaging;

    public interface IMessageBus : IService
    {
        void Subscribe<TMessage>(object instance, Action<TMessage> handler) where TMessage : IMessage;
        void Unsubscribe(object instance);
        void Publish<TMessage>(TMessage message) where TMessage : IMessage;
    }
}