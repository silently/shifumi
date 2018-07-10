defmodule Shifumi.Engine.GameRegistry do
  @moduledoc """
  Registry of Shifumi.Engine.GameServer processes.
  """

  #######
  # API #
  #######

  def start_link do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  def lookup(player) do
    Registry.lookup(__MODULE__, player)
  end

  def register(player, id) do
    Registry.register(__MODULE__, player, id)
  end

  def unregister(player) do
    Registry.unregister(__MODULE__, player)
  end

  #################
  # Configuration #
  #################

  @doc false
  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end
