defmodule HareMqExample.BatchPublisher do
  use HareMq.Publisher,
    exchange: "batch_exchange",
    routing_key: "batch_routing_key",
    connection_name: {:global, :hare_mq_connection}
end
