defmodule HareMqExample.DelayPublisher do
  use HareMq.Publisher,
    exchange: "delay_exchange",
    routing_key: "delay_routing_key",
    connection_name: {:global, :hare_mq_connection}
end
