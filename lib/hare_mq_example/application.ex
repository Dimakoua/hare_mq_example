defmodule HareMqExample.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HareMqExampleWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:hare_mq_example, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: HareMqExample.PubSub},
      {HareMq.Connection, name: {:global, :hare_mq_connection}},
      HareMqExample.MessagePublisher,
      HareMqExample.MessageConsumer,
      HareMqExample.StreamPublisher,
      HareMqExample.StreamConsumer,
      HareMqExample.AutoScalePublisher,
      HareMqExample.AutoScaleConsumer,
      HareMqExample.DelayPublisher,
      HareMqExample.DelayConsumer,
      HareMqExample.TopicPublisher,
      HareMqExample.TopicConsumerA,
      HareMqExample.TopicConsumerB,
      HareMqExample.BatchPublisher,
      HareMqExample.BatchConsumer,
      # Start a worker by calling: HareMqExample.Worker.start_link(arg)
      # {HareMqExample.Worker, arg},
      # Start to serve requests, typically the last entry
      HareMqExampleWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HareMqExample.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HareMqExampleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
