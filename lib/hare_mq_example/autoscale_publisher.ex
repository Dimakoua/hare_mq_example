defmodule HareMqExample.AutoScalePublisher do
  use HareMq.Publisher,
    exchange: "autoscale_exchange",
    routing_key: "autoscale_routing_key",
    connection_name: {:global, :hare_mq_connection}
end
