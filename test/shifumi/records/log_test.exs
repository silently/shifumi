defmodule Shifumi.Records.LogTest do
  use Shifumi.DataCase
  alias Shifumi.Records.Log

  test "from_game/1 converts %Game to %Log" do
    game = %Shifumi.Engine.Game{
      id: Ecto.UUID.generate(),
      player1_id: Ecto.UUID.generate(),
      player2_id: Ecto.UUID.generate(),
      history1: "rrr",
      history2: "sss",
      round: 3,
      empty_rounds: 0,
      score1: 3,
      score2: 0
    }

    assert %Log{
             game_id: game.id,
             winner_id: game.player1_id,
             loser_id: game.player2_id,
             history: game.history1 <> "," <> game.history2,
             rounds: 3
           } == Log.from_game(game)
  end
end
