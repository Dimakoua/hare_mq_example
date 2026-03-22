defmodule HareMqExample.AutoScaleConsumer do
  use HareMq.DynamicConsumer,
    queue_name: "autoscale_queue",
    routing_key: "autoscale_routing_key",
    exchange: "autoscale_exchange",
    consumer_count: 2,
    auto_scaling: [
      min_consumers: 1,
      max_consumers: 5,
      messages_per_consumer: 1,
      check_interval: 5_000
    ],
    connection_name: {:global, :hare_mq_connection}

  @impl true
  def consume(message) do
    IO.inspect(message, label: "HareMqExample.AutoScaleConsumer received")
    Process.sleep(1000)
    :ok
  end
end
