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
      check_interval_ms: 5_000
    ],
    connection_name: {:global, :hare_mq_connection}

  @impl true
  def consume(message) do
    consumer_pid = inspect(self())
    start_ts = DateTime.utc_now() |> DateTime.to_iso8601()
    IO.puts("[#{start_ts}] AutoScaleConsumer (#{consumer_pid}) start processing")
    IO.inspect(message, label: "AutoScaleConsumer (#{consumer_pid}) received")

    sleep_ts = DateTime.utc_now() |> DateTime.to_iso8601()
    IO.puts("[#{sleep_ts}] AutoScaleConsumer (#{consumer_pid}) sleeping 1000ms")
    Process.sleep(1000)

    done_ts = DateTime.utc_now() |> DateTime.to_iso8601()
    IO.puts("[#{done_ts}] AutoScaleConsumer (#{consumer_pid}) done processing")
    :ok
  end
end
