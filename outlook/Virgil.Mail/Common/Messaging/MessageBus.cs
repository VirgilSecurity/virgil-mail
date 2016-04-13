namespace Virgil.Mail.Common.Messaging
{
    using System;
    using System.Collections.Concurrent;
    using System.Linq;

    public class MessageBus : IMessageBus
    {
        private readonly ConcurrentDictionary<object, object> handlers;

        public MessageBus()
        {
             this.handlers = new ConcurrentDictionary<object, object>();
        }

        public void Publish<TMessage>(TMessage message) where TMessage : IMessage
        {
            foreach (var handler in this.handlers.Keys)
            {
                var messageHandler = handler as Action<TMessage>;
                messageHandler?.Invoke(message);
            }
        }

        public void Subscribe<TMessage>(object instance, Action<TMessage> handler) where TMessage : IMessage
        {
            this.handlers.TryAdd(handler, instance);
        }

        public void Unsubscribe(object instance)
        {
            var handlersToDelete = this.handlers.Where(it => it.Value == instance).ToList();
            foreach (var handler in handlersToDelete)
            {
                object removedObject;
                this.handlers.TryRemove(handler.Key, out removedObject);
            }
        }
    }
}