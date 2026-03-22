defmodule HareMqExample.TopicConsumerA do
  use HareMq.Consumer,
    queue_name: "topic_queue_A",
    routing_key: "topic.event.*",
    exchange: "topic_exchange",
    connection_name: {:global, :hare_mq_connection}

  @impl true
  def consume(message) do
    IO.inspect(message, label: "TopicConsumerA received")
    :ok
  end
end
