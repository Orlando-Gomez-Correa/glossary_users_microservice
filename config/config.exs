# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :greenhouse,
  ecto_repos: [Greenhouse.Repo],
  generators: [binary_id: true]

config :greenhouse, Greenhouse.Repo,
  migration_primary_key: [type: :uuid],
  migration_timestamps: [type: :naive_datetime_usec]

# Configures the endpoint
config :greenhouse, GreenhouseWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: GreenhouseWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Greenhouse.PubSub,
  live_view: [signing_salt: "Pn46gKM/"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :greenhouse, Greenhouse.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# Configures Mailer
config :greenhouse, Greenhouse.Shared.EmailServer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.sendgrid.net",
  hostname: "smtp.sendgrid.net",
  port: 587,
  username: System.get_env("SENDGRID_USER"),
  password: System.get_env("SENDGRID_PASSWORD"),
  tls: :if_available,
  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"],
  ssl: false,
  retries: 1,
  no_mx_lookups: false,
  auth: :if_available

# Configures Guardian
config :greenhouse, GreenhouseWeb.Auth.Guardian.Guardian,
  issuer: System.get_env("GUARDIAN_ISSUER"),
  secret_key: System.get_env("GUARDIAN_SECRET_KEY")

# Configures Waffle
config :waffle,
  storage: Waffle.Storage.Local

# Configures Swagger
config :greenhouse, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: GreenhouseWeb.Router,
      endpoint: GreenhouseWeb.Endpoint
    ]
  }

config :phoenix_swagger, json_library: Jason
