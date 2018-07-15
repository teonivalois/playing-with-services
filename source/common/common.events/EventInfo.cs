using System;

namespace common.events
{
    public class EventInfo
    {
        public string Name { get; private set; }
        public string Payload { get; private set; }
        public EventInfo(string name, string payload)
        {
            Name = name;
            Payload = payload;
        }
    }
}
