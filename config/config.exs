# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :hare_mq_example,
  generators: [timestamp_type: :utc_datetime]

# Configure the endpoint
config :hare_mq_example, HareMqExampleWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: HareMqExampleWeb.ErrorHTML, json: HareMqExampleWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: HareMqExample.PubSub,
  live_view: [signing_salt: "Hsyw8hEI"]

# Configure the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :hare_mq_example, HareMqExample.Mailer, adapter: Swoosh.Adapters.Local

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# HareMq configuration
config :hare_mq, :amqp, url: System.get_env("RABBITMQ_URL", "amqp://guest:guest@rabbitmq:5672")

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
