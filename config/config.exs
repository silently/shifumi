# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :shifumi,
  namespace: Shifumi,
  ecto_repos: [Shifumi.Repo],
  beat: 8_000,
  splash_duration: 2_500,
  inactive_limit: 10_000,
  upload_at: "priv/uploads"

# Configures the endpoint
config :shifumi, ShifumiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "KOlAtIfAudK37xwiH/DnW9QwUReQicHMBT5bW0ceiaQ5EOQuusA05HaE5pUlmeyv",
  render_errors: [view: ShifumiWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Shifumi.PubSub, adapter: Phoenix.PubSub.PG2]

# In default/dev use Plug.Static to serve uploaded media
config :shifumi, ShifumiWeb.Endpoint, serve_uploads: true

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ueberauth, Ueberauth,
  providers: [
    facebook: {Ueberauth.Strategy.Facebook, [default_scope: "public_profile"]},
    github: {Ueberauth.Strategy.Github, [default_scope: "user:email"]},
    google: {Ueberauth.Strategy.Google, []},
    twitter: {Ueberauth.Strategy.Twitter, []}
  ]

config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: System.get_env("SHIFUMI_FACEBOOK_ID"),
  client_secret: System.get_env("SHIFUMI_FACEBOOK_SECRET")

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("SHIFUMI_GITHUB_ID"),
  client_secret: System.get_env("SHIFUMI_GITHUB_SECRET")

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("SHIFUMI_GOOGLE_ID"),
  client_secret: System.get_env("SHIFUMI_GOOGLE_SECRET")

config :ueberauth, Ueberauth.Strategy.Twitter.OAuth,
  consumer_key: System.get_env("SHIFUMI_TWITTER_KEY"),
  consumer_secret: System.get_env("SHIFUMI_TWITTER_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
