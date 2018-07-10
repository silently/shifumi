defmodule Shifumi.Engine.Game do
  @moduledoc """
  Main struct for GameServer state.
  """

  # Fields without default values are meant to be filled by Shifumi.Engine#init_game/2
  defstruct [
    :id,
    :player1_id,
    :player2_id,
    :prev_winner,
    :wells,
    :round_start_time,
    history1: "",
    history2: "",
    round: 0,
    empty_rounds: 0,
    score1: 0,
    score2: 0,
    prev_shapes: ["n", "n"],
    aborted: false,
    tie: false
  ]
end
