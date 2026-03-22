defmodule HareMqExample.StreamConsumer do
  use HareMq.Consumer,
    queue_name: "stream_queue",
    routing_key: "stream_routing_key",
    exchange: "stream_exchange",
    stream: true,
    stream_offset: "next",
    connection_name: {:global, :hare_mq_connection}

  @impl true
  def consume(message) do
    IO.inspect(message, label: "HareMqExample.StreamConsumer received")
    :ok
  end
end
