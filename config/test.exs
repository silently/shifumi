use Mix.Config

# General application configuration
config :shifumi,
  beat: 300,
  splash_duration: 150,
  inactive_limit: 300

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :shifumi, ShifumiWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :shifumi, Shifumi.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "dev",
  password: "dev",
  database: "shifumi_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
