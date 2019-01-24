defmodule Shifumi.Mixfile do
  use Mix.Project

  def project do
    [
      app: :shifumi,
      version: "0.5.2",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      docs: docs()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Shifumi.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :ueberauth,
        :ueberauth_facebook,
        :ueberauth_github,
        :ueberauth_google,
        :ueberauth_twitter
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.dcm": ["ecto.drop", "ecto.create", "ecto.migrate"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:jason, "~> 1.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:comeonin, "~> 4.0"},
      {:mogrify, "~> 0.5.6"},
      {:ueberauth, "~> 0.5"},
      {:ueberauth_facebook, "~> 0.7"},
      {:ueberauth_github, "~> 0.7"},
      {:ueberauth_google, "~> 0.7"},
      {:ueberauth_twitter, "~> 0.2"},
      {:oauth, github: "tim/erlang-oauth"},
      {:edeliver, "~> 1.5.0"},
      {:distillery, "~> 2.0.12"},
      # comeonin algorithm
      {:argon2_elixir, "~> 1.2"},
      # dev only
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      # test only
      {:faker, "~> 0.9", only: [:test]}
    ]
  end

  defp docs do
    [
      # source_url: "https://github.com/silently/shifumi",
      main: "readme",
      extras: ["README.md"],
      groups_for_modules: [
        "Game engine": [
          Shifumi.Engine,
          Shifumi.Engine.Game,
          Shifumi.Engine.GameRegistry,
          Shifumi.Engine.GameServer,
          Shifumi.Engine.GameSupervisor,
          Shifumi.Engine.Game,
          Shifumi.Engine.Rules
        ],
        People: [
          Shifumi.People,
          Shifumi.People.Avatar,
          Shifumi.People.Dating,
          Shifumi.People.Player
        ],
        Records: [
          Shifumi.Records,
          Shifumi.Records.Log,
          Shifumi.Records.Score,
          Shifumi.Records.Sheet
        ],
        Web: [
          ShifumiWeb.Endpoint,
          ShifumiWeb.Router,
          ShifumiWeb.Router.Helpers,
          ShifumiWeb.AuthController,
          ShifumiWeb.AvatarController,
          ShifumiWeb.MenuController,
          ShifumiWeb.PlayController,
          ShifumiWeb.PlayerSocket,
          ShifumiWeb.PlayerChannel,
          ShifumiWeb.GameChannel,
          ShifumiWeb.Presence
        ]
      ]
    ]
  end
end
