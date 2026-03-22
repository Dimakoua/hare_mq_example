# HareMqExample and hare_mq use cases

This file documents real-life use cases for each hare_mq feature that is showcased in this example app.

## 1. Basic publish/consume (MessagePublisher + MessageConsumer)

### Feature
- `HareMq.Publisher` + `HareMq.Consumer`
- Exchange direct routing with queue binding via topics/routing_key.

### Use case
- Simple transactional event stream: order created events, user signup events, or log notifications.
- One publisher microservice sends events; one consumer service handles events (e.g., send email, update stat store).

### Example
1. User signs up in `accounts` service.
2. `accounts` publishes  `{user_id: 123, event: "signup"}` to `example_exchange` via `MessagePublisher`.
3. `message_consumer` service reads from `example_queue`.
4. `MessageConsumer.consume/1` triggers welcome email or analytics insert.

## 2. Stream publish/consume (StreamPublisher + StreamConsumer)

### Feature
- `stream: true`, `stream_offset` for replay semantics.
- RabbitMQ stream queue (append-only, durable message log).

### Use case
- Event sourcing: store every business event, rehydrate projections.
- Audit trails and analytics pipelines where replay of historical events is needed.
- Late join consumers that need to reprocess prior data.

### Example
- App sends event log to `stream_exchange`. `StreamConsumer` configured with `stream_offset: "next"` for normal runtime.
- For a bulk backfill, set `stream_offset: "first"` to replay all events and rebuild a materialized view.

## 3. Delay/Retry pattern (DelayPublisher + DelayConsumer)

### Feature
- Delay/TTL and retriable consumption with `delay_in_ms`, `retry_limit`, `delay_cascade_in_ms`.
- Dead-letter queue for failed messages after retries.

### Use case
- Tasks are idempotent but may transiently fail (external API timeout, 3rd-party service throttling).
- Payment retries, shipment status push, weak network call fallback.

### Example
1. Publish `payment_intent` to `delay_exchange`.
2. If `DelayConsumer` returns `:error` the first time, the message waits (1s, 5s, 15s, 30s) and retries.
3. After `retry_limit`, it lands in `delay_queue.dead` for manual investigation.

## 4. Autoscaling consumer (AutoScalePublisher + AutoScaleConsumer)

### Feature
- `HareMq.DynamicConsumer` + `auto_scaling` settings (`min_consumers`, `max_consumers`, `messages_per_consumer`, `check_interval`).
- Auto scale up and down based on queue depth.

### Use case
- Varying load services (batch ETL, peak traffic event processing) with variable processing time.
- 24/7 service that should minimize resources at low load and scale out during peaks.

### Example
1. ETL jobs produce bursty traffic: 500 events in 30 seconds at 3AM, then nearly zero.
2. `AutoScaleConsumer` starts 2 workers; during the burst it ramps to max 5.
3. When backlog clears, it scales back to 1.
4. Use distributed auto-scaling to reduce infra cost.

## 5. Topic routing (TopicPublisher + TopicConsumerA/B)

### Feature
- `topic` exchange with routing_key patterns `topic.event.*` and `topic.#`.

### Use case
- Multitenant event delivery where different consumers subscribe to event categories.
- Analytics vs metrics service, and audit workflow both consume the same base stream.

### Example
1. Publish `topic.event.create`, `topic.event.update`.
2. Consumer A gets only `topic.event.*` and processes entity changes.
3. Consumer B gets all `topic.#` and triggers global notifications.

## 6. Global connection manager

### Feature
- `HareMq.Connection` starter process, reconnection/backoff, `:global` name registration.

### Use case
- Centralized connection pool for all producers and consumers in one node.
- When running in _multi-node cluster_, multiple named connections for different vhosts.

### Example
- `config.exs` sets `url: System.get_env("RABBITMQ_URL", "amqp://guest:guest@rabbitmq:5672")`
- Start app child: `{HareMq.Connection, name: {:global, :hare_mq_connection}}`
- All publishers/consumers use that connection_name.

## 7. Observability: Telemetry & logging

### Feature
- `:telemetry` events for `[:hare_mq, :connection, :connected]`, `[:hare_mq, :consumer, :message, :stop]`.
- Consumer debug logs in this sample.

### Use case
- Production alerting (connection lost, retry storm).
- Performance monitoring (consumption latency, backlog processing rate).

### Example
- Add handler in your app to forward to monitoring service:
  - `:telemetry.attach_many("haremq-tracing", [[:hare_mq, :consumer, :message, :stop]], &...)`

## How to use this example

Start RabbitMQ and the app:
```bash
RABBITMQ_URL=amqp://guest:guest@rabbitmq:5672 mix phx.server
```

In `iex` test each scenario with provided publishers.

## Contributing use cases

- Add new use cases for `HareMq.StreamConsumer` with retention policy.
- Add upstream error handling design pattern (DLQ + alert + manual retry).
