defmodule HareMqExample.MessagePublisher do
  use HareMq.Publisher,
    exchange: "example_exchange",
    routing_key: "example_routing_key",
    connection_name: {:global, :hare_mq_connection}
end
