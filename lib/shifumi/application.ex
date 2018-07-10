defmodule Shifumi.Application do
  @moduledoc false

  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Ecto
      supervisor(Shifumi.Repo, []),
      # Web
      supervisor(ShifumiWeb.Endpoint, []),
      supervisor(ShifumiWeb.Presence, []),
      # Game server logic
      supervisor(Shifumi.Engine.GameSupervisor, []),
      worker(Shifumi.Engine.GameRegistry, []),
      worker(Shifumi.People.Dating, [])
      # worker(Shifumi.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Shifumi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ShifumiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
