# HareMqExample

This example app demonstrates how to use `hare_mq` (from `Dimakoua/hare_mq` branch `dev`) in a Phoenix-based project.

## Setup

1. Ensure RabbitMQ is running (default AMQP URL: `amqp://guest:guest@localhost:5672`).
2. Run the server:
   ```bash
   mix phx.server
   ```

> Note: the app only needs RabbitMQ for the HareMq parts; the Phoenix web UI is optional.

## hare_mq integration

### Dependency

In `mix.exs`, this app uses:
```elixir
{:hare_mq, github: "Dimakoua/hare_mq", branch: "dev"}
```

### Configuration

In `config/config.exs`:
```elixir
config :hare_mq, :amqp,
  url: System.get_env("RABBITMQ_URL", "amqp://guest:guest@localhost:5672")
```

### Application supervision

In [lib/hare_mq_example/application.ex](lib/hare_mq_example/application.ex), the example starts:
- `{HareMq.Connection, name: {:global, :hare_mq_connection}}` — the connection manager (must be started first)
- `HareMqExample.MessagePublisher`
- `HareMqExample.MessageConsumer`
- And other publishers/consumers

### Publisher implementation

[message_publisher.ex](lib/hare_mq_example/message_publisher.ex):
```elixir
defmodule HareMqExample.MessagePublisher do
  use HareMq.Publisher,
    exchange: "example_exchange",
    routing_key: "example_routing_key",
    connection_name: {:global, :hare_mq_connection}
end
```

### Consumer implementation

[message_consumer.ex](lib/hare_mq_example/message_consumer.ex):
```elixir
defmodule HareMqExample.MessageConsumer do
  use HareMq.Consumer,
    queue_name: "example_queue",
    routing_key: "example_routing_key",
    exchange: "example_exchange",
    connection_name: {:global, :hare_mq_connection}

  def consume(message) do
    IO.inspect(message, label: "HareMqExample.MessageConsumer received")
    :ok
  end
end
```

## Testing all modules from iex

Start an interactive shell:
```bash
iex -S mix phx.server
```

Then run these commands to test each module:

### Basic message publishing/consuming

```elixir
# Publish a test message
HareMqExample.MessagePublisher.publish_message(%{sample: "message", ts: DateTime.utc_now()})

# Expected output in logs:
# HareMqExample.MessageConsumer received: %{sample: "message", ts: ...}
```

### Stream publisher/consumer

```elixir
# Publish to stream (messages are retained)
HareMqExample.StreamPublisher.publish_message(%{event: "stream_event_1", ts: DateTime.utc_now()})
HareMqExample.StreamPublisher.publish_message(%{event: "stream_event_2", ts: DateTime.utc_now()})

# Expected output in logs:
# HareMqExample.StreamConsumer received: %{event: "stream_event_1", ts: ...}
# HareMqExample.StreamConsumer received: %{event: "stream_event_2", ts: ...}
```

`HareMqExample.StreamConsumer` is configured with:
- `stream: true` — uses RabbitMQ stream queue (append-only log)
- `stream_offset: "next"` — only consume new messages (not replay existing ones)

**Stream offset options:**
- `"next"` (default) — consume only new messages from now on
- `"first"` — replay all retained messages from the beginning on startup
- `"last"` — start consuming from the most recent message
- An integer — specific offset position
- A `%DateTime{}` — messages after a specific timestamp
```

### Auto-scale consumer

```elixir
# Publish multiple messages (auto-scaler will adjust worker count)
for i <- 1..200000 do
  HareMqExample.AutoScalePublisher.publish_message(%{id: i, message: "autoscale_test_#{i}", ts: DateTime.utc_now()})
end

# Expected output in logs:
# - Auto-scaler starts with 2 workers (consumer_count: 2)
# - As queue messages increase, it scales up to max 5 workers
# - As queue empties, it scales back down to min 1 worker
# HareMqExample.AutoScaleConsumer received: %{id: 1, message: "autoscale_test_1", ts: ...}
# HareMqExample.AutoScaleConsumer received: %{id: 2, message: "autoscale_test_2", ts: ...}
# ...
```

### Delay cascade consumer (with retries)

```elixir
# Publish a message that will be retried
HareMqExample.DelayPublisher.publish_message(%{event: "delay_test", ts: DateTime.utc_now()})

# Expected behavior:
# - Consumer receives message and returns :error (intentional for demo)
# - Message is retried with delays: 1s, 5s, 15s, 30s (delay_cascade_in_ms)
# - After 5 retries (retry_limit: 5), message is dead-lettered
# - Check logs for retry attempts:
#   [debug] Retrying message after 1000ms (attempt 1)
#   [debug] Retrying message after 5000ms (attempt 2)
#   ...
# - Dead-lettered message ends up in "delay_queue.dead"
```

### Topic routing publishers + consumers

```elixir
# Publish to topic exchange
HareMqExample.TopicPublisher.publish_message(%{event: "topic_test", ts: DateTime.utc_now()})

# Expected output in logs (both consumers receive the message):
# HareMqExample.TopicConsumerA received: %{event: "topic_test", ts: ...}
# HareMqExample.TopicConsumerB received: %{event: "topic_test", ts: ...}

# Topic patterns:
# - TopicConsumerA binds to: "topic.event.*"
# - TopicConsumerB binds to: "topic.#" (all topic events)
```

### Batch testing all modules

Run this to test all publishers at once:
```elixir
# Test all publishers in sequence
HareMqExample.MessagePublisher.publish_message(%{test: "basic_message", ts: DateTime.utc_now()})
HareMqExample.StreamPublisher.publish_message(%{test: "stream_message", ts: DateTime.utc_now()})
HareMqExample.AutoScalePublisher.publish_message(%{test: "autoscale_message", ts: DateTime.utc_now()})
HareMqExample.DelayPublisher.publish_message(%{test: "delay_message", ts: DateTime.utc_now()})
HareMqExample.TopicPublisher.publish_message(%{test: "topic_message", ts: DateTime.utc_now()})

# All consumers should log their received messages
```

### Monitoring connection status

```elixir
# Check if HareMQ connection is active
HareMq.Connection.get_connection({:global, :hare_mq_connection})
# Returns: {:ok, %AMQP.Connection{...}} when connected
```

## Telemetry

Add telemetry handlers to observe:
- `[:hare_mq, :connection, :connected]`
- `[:hare_mq, :consumer, :message, :stop]`

## Running tests

```bash
RABBITMQ_URL=amqp://guest:guest@localhost:5672 mix test
```

### Docker Compose

Run with:

```bash
docker compose up --build
```

- RabbitMQ UI: http://localhost:15672 (guest/guest)
- Phoenix app: http://localhost:4000

The app is started with:
`RABBITMQ_URL=amqp://guest:guest@rabbitmq:5672 mix phx.server`
---

## Phoenix quick reminder (existing content)

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix"}]}
