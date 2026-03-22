defmodule HareMqExample.MessageConsumer do
  use HareMq.Consumer,
    queue_name: "example_queue",
    routing_key: "example_routing_key",
    exchange: "example_exchange",
    connection_name: {:global, :hare_mq_connection}

  @impl true
  def consume(message) do
    IO.inspect(message, label: "HareMqExample.MessageConsumer received")
    :ok
  end
end
