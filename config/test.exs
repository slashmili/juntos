import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :junto, Junto.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "junto_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :junto, JuntoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "nmF0+jCt9ItzLzmChLdhoh9H8eji2jbO92FkA5twMIiK0MYTQ+AEUz35hhRNML+v",
  server: false

# In test we don't send emails.
config :junto, Junto.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

config :junto, JuntoWeb.UserAuth, auth_provider: Junto.Accounts.AuthProvider.Mock

config :junto, Junto.Accounts.AuthProvider,
  github: [
    client_id: "github_client_id",
    client_secret: "github_client_secret"
  ],
  google: [
    client_id: "google_client_id",
    client_secret: "google_client_secret"
  ]

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
