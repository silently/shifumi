defmodule Shifumi.Records.Log do
  @moduledoc """
  Game logs when games have ended.
  """

  use Ecto.Schema
  alias Shifumi.Records.Log

  schema "logs" do
    # Associations
    belongs_to(:winner, Shifumi.People.Player, type: :binary_id)
    belongs_to(:loser, Shifumi.People.Player, type: :binary_id)
    # DB fields
    # association won't necessarily persist
    field(:game_id, :binary_id)
    field(:history, :string, default: "")
    field(:rounds, :integer, default: 0)
    field(:loser_score, :integer, default: 0)

    timestamps()
  end

  #######
  # API #
  #######

  @doc """
  From %Game{} to %Log{} struct: changes semantics and concatenates history
  """
  def from_game(%Shifumi.Engine.Game{} = game) do
    winner = Shifumi.Engine.Rules.solve_game(game.score1, game.score2)

    {winner_id, loser_id, loser_score} =
      case winner do
        1 -> {game.player1_id, game.player2_id, game.score2}
        2 -> {game.player2_id, game.player1_id, game.score1}
      end

    history =
      case winner do
        1 -> game.history1 <> "," <> game.history2
        2 -> game.history2 <> "," <> game.history1
      end

    %Log{
      game_id: game.id,
      winner_id: winner_id,
      loser_id: loser_id,
      history: history,
      rounds: game.round,
      loser_score: loser_score
    }
  end
end
