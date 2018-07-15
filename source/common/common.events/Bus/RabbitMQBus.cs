using System;
using System.Threading.Tasks;
using EasyNetQ;
using Microsoft.Extensions.Logging;

namespace common.events.Bus
{
    public class RabbitMQBus : IMessageBus
    {
        private readonly IBus _bus;
        public RabbitMQBus(IBus bus, ILogger<RabbitMQBus> logger)
        {
            if (bus == null)
                throw new ArgumentNullException(nameof(bus));

            _bus = bus;
            logger.LogDebug("{0} created", this.GetType().FullName);
        }

        public void Publish<E>(E @event) where E : EventInfo
        {
            _bus.PublishAsync<E>(@event, (cfg) => { cfg.WithQueueName(typeof(E).Namespace).WithTopic(typeof(E).Name); });
        }

        public void Subscribe<E>(Func<E, Task> handler) where E : EventInfo
        {
            _bus.SubscribeAsync<E>(typeof(E).Name,
                eventInfo => handler.Invoke(eventInfo).ContinueWith(task =>
                {
                    if (task.IsCompleted && !task.IsFaulted)
                    {
                        // Everything worked out ok
                    }
                    else
                    {
                        // Dont catch this, it is caught further up the heirarchy and results in being sent to the default error queue
                        // on the broker
                        throw new EasyNetQException("Message processing exception - look in the default error queue (broker)");
                    }
                }));
        }
    }
}