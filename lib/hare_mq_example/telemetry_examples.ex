defmodule HareMqExample.TelemetryExamples do
  @moduledoc """
  Example telemetry attachers for hare_mq observability.

  Use in your application start:

      HareMqExample.TelemetryExamples.attach()

  """

  require Logger

  @doc "Attach telemetry handlers used in USE_CASES.md."
  def attach do
    :telemetry.attach_many(
      "haremq-connection",
      [
        [:hare_mq, :connection, :connected],
        [:hare_mq, :connection, :disconnected],
        [:hare_mq, :connection, :reconnecting]
      ],
      &__MODULE__.handle_connection/4,
      nil
    )

    :telemetry.attach_many(
      "haremq-consumer",
      [
        [:hare_mq, :consumer, :message, :start],
        [:hare_mq, :consumer, :message, :stop]
      ],
      &__MODULE__.handle_consumer/4,
      nil
    )

    :ok
  end

  def handle_connection([:hare_mq, :connection, :connected], measurements, metadata, _config) do
    Logger.info("[Telemetry][HareMq] connected to #{metadata[:host]} in #{measurements[:duration] || 0}ms")
  end

  def handle_connection([:hare_mq, :connection, :disconnected], _measurements, metadata, _config) do
    Logger.warn("[Telemetry][HareMq] disconnected from #{metadata[:host]}: #{inspect(metadata[:reason])}")
  end

  def handle_connection([:hare_mq, :connection, :reconnecting], measurements, metadata, _config) do
    Logger.warn("[Telemetry][HareMq] reconnecting to #{metadata[:host]} in #{measurements[:retry_delay_ms]}ms, reason: #{inspect(metadata[:reason])}")
  end

  def handle_consumer([:hare_mq, :consumer, :message, :start], _measurements, metadata, _config) do
    Logger.debug("[Telemetry][HareMq] consumer #{metadata[:consumer_tag]} start message #{inspect(metadata[:message_id] || metadata[:delivery_tag])}")
  end

  def handle_consumer([:hare_mq, :consumer, :message, :stop], measurements, metadata, _config) do
    Logger.info("[Telemetry][HareMq] consumer #{metadata[:consumer_tag]} done in #{measurements[:duration]}ns")
  end
end
