using System.Threading.Tasks;
using common.events;
using common.events.Bus;
using Microsoft.Extensions.Logging;

namespace service1.Service
{
    public class SampleService : ISampleService
    {
        private readonly IMessageBus bus;
        private readonly ILogger logger;
        public SampleService(IMessageBus bus, ILogger<SampleService> logger)
        {
            this.logger = logger;
            this.bus = bus;
        }

        public void AddItem(string item)
        {
            this.bus.Publish(new EventInfo("AddItem", item));
        }
    }
}