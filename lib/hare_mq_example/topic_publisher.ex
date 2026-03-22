defmodule HareMqExample.TopicPublisher do
  use HareMq.Publisher,
    exchange: "topic_exchange",
    routing_key: "topic.event.create",
    connection_name: {:global, :hare_mq_connection}
end
