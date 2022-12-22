import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :greenhouse, Greenhouse.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "greenhouse_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server  option below.
config :greenhouse, GreenhouseWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4002],
  secret_key_base: "K9mNGqYoIt6tJLKzOeZkovuqG+m7RTBsRldeGSbEg3EZis7ipxy32hG8oZxX9wlB",
  server: false

# In test we don't send emails.
# config :greenhouse, Greenhouse.Mailer, adapter: Bamboo.TestAdapter
config :greenhouse, Greenhouse.Shared.Mailer, adapter: Bamboo.TestAdapter

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
