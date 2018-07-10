defmodule Shifumi.Engine.GameSupervisor do
  @moduledoc """
  Supervisor for dynamically managed Shifumi.Engine.GameServer processes.
  """

  use DynamicSupervisor
  alias Shifumi.Engine.GameServer

  #######
  # API #
  #######

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_game(player1_id, player2_id) do
    DynamicSupervisor.start_child(__MODULE__, {GameServer, {player1_id, player2_id}})
  end

  #############
  # Callbacks #
  #############

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
