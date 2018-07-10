defmodule Shifumi.Engine do
  @moduledoc """
  The Engine context.
  """

  alias Shifumi.Engine.Game
  alias Shifumi.Records

  @doc """
  Initializes a game struct for GameServer
  """
  def init_game(player1_id, player2_id) do
    %Game{
      id: Ecto.UUID.generate(),
      player1_id: player1_id,
      player2_id: player2_id,
      wells: [Records.get_player_wells(player1_id), Records.get_player_wells(player2_id)],
      round_start_time: NaiveDateTime.utc_now()
    }
  end
end
