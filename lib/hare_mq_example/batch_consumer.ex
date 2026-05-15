defmodule HareMqExample.BatchConsumer do
  use HareMq.Consumer,
    queue_name: "batch_queue",
    routing_key: "batch_routing_key",
    exchange: "batch_exchange",
    batch_size: 10,
    batch_timeout_ms: 2_000,
    connection_name: {:global, :hare_mq_connection}

  @impl true
  def consume(messages, :batch) do
    IO.puts("BatchConsumer received batch of #{length(messages)} messages")
    IO.inspect(messages, label: "BatchConsumer batch")
    :ok
  end
end
