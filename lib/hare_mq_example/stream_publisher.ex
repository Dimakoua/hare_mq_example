defmodule HareMqExample.StreamPublisher do
  use HareMq.Publisher,
    exchange: "stream_exchange",
    routing_key: "stream_routing_key",
    connection_name: {:global, :hare_mq_connection}
end
