defmodule HareMqExample.DelayConsumer do
  use HareMq.Consumer,
    queue_name: "delay_queue",
    routing_key: "delay_routing_key",
    exchange: "delay_exchange",
    delay_in_ms: 5_000,
    retry_limit: 5,
    delay_cascade_in_ms: [1_000, 5_000, 15_000, 30_000],
    connection_name: {:global, :hare_mq_connection}

  @impl true
  def consume(message) do
    IO.puts("DelayConsumer got message: #{inspect(message)}")
    # Return :error to trigger retry stack backoff for demo; change to :ok to ack.
    :error
  end
end
