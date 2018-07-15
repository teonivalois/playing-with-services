using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using common.events.Bus;
using EasyNetQ;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using service2.Handlers;

namespace service2
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            string rabbitMQConnectionString = Environment.GetEnvironmentVariable("RabbitMQConnectionString");
            if (string.IsNullOrEmpty(rabbitMQConnectionString))
                rabbitMQConnectionString = Configuration.GetValue("RabbitMQConnectionString", "host=localhost");

            services.AddMvc().SetCompatibilityVersion(CompatibilityVersion.Version_2_1);

            services.AddSingleton<IBus>(RabbitHutch.CreateBus(rabbitMQConnectionString));
            services.AddSingleton<IMessageBus, RabbitMQBus>();

            services.AddHostedService<SampleEventHandler>();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseHsts();
            }

            app.UseHttpsRedirection();
            app.UseMvc();
        }
    }
}
