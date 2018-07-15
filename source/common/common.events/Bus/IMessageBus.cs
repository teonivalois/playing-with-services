using System;
using System.Threading.Tasks;

namespace common.events.Bus
{
    public interface IMessageBus
    {
        void Publish<E>(E @event) where E : EventInfo;
        void Subscribe<E>(Func<E, Task> handler) where E : EventInfo;
    }
}