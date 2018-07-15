using System.Threading;
using System.Threading.Tasks;
using common.events;
using common.events.Bus;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace service2.Handlers
{
    public class SampleEventHandler : IHostedService
    {
        private readonly IMessageBus bus;
        private readonly ILogger logger;
        public SampleEventHandler(IMessageBus bus, ILogger<SampleEventHandler> logger)
        {
            this.logger = logger;
            this.bus = bus;
        }

        public Task StartAsync(CancellationToken cancellationToken)
        {
            this.bus.Subscribe<EventInfo>(Handle);
            return Task.CompletedTask;
        }

        public Task StopAsync(CancellationToken cancellationToken)
        {
            return Task.CompletedTask;
        }

        private async Task Handle(EventInfo @event)
        {
            logger.LogDebug($"{@event.Name} => {@event.Payload}");
            await Task.CompletedTask;
        }
    }
}