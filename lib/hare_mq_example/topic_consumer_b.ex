defmodule HareMqExample.TopicConsumerB do
  use HareMq.Consumer,
    queue_name: "topic_queue_B",
    routing_key: "topic.#",
    exchange: "topic_exchange",
    connection_name: {:global, :hare_mq_connection}

  @impl true
  def consume(message) do
    IO.inspect(message, label: "TopicConsumerB received")
    :ok
  end
end
