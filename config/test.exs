import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :juntos, Juntos.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "juntos_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :juntos, JuntosWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "6isbZ7ygtA35j3muxiabUiRDS41Ou7tfvAmy43jgtk7BoKu9SEIpZH3gN3chkz6I",
  server: true

# In test we don't send emails
config :juntos, Juntos.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :juntos, Juntos.Accounts.ExternalAuthProvider,
  github: [
    client_id: "github_client_id",
    client_secret: "github_client_secret"
  ],
  google: [
    client_id: "google_client_id",
    client_secret: "google_client_secret"
  ]

config :waffle,
  storage: Waffle.Storage.Local,
  storage_dir_prefix: "priv/waffle/test",
  asset_host: "localhost:4000"

config :juntos, sql_sandbox: true
config :phoenix_test, otp_app: :juntos
config :phoenix_test, :endpoint, JuntosWeb.Endpoint

config :phoenix_test,
  otp_app: :juntos,
  playwright: [
    cli: "assets/node_modules/playwright/cli.js",
    browser: :chromium,
    headless: System.get_env("PW_HEADLESS", "true") in ~w(t true),
    js_logger: false,
    screenshot: System.get_env("PW_SCREENSHOT", "false") in ~w(t true),
    trace: System.get_env("PW_TRACE", "false") in ~w(t true),
    timeout: :timer.seconds(5)
  ],
  timeout_ms: 2000

config :juntos, Juntos.Accounts.OtpSession,
  otp_generator: fn user ->
    if user.email =~ "otp" do
      {"123456", "1234567890"}
    else
      Juntos.Accounts.OtpSession.do_generate_otp_token(user)
    end
  end
