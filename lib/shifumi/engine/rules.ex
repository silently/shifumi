defmodule Shifumi.Engine.Rules do
  @moduledoc """
  Game rules used by Shifumi.Engine.GameServer to manage its state.
  """

  @win_round_count 3

  @doc """
  Solves round according to facing shapes.

  Returns 0 (tie), 1 (shape1 wins), 2 (shape2 wins).
  """
  def solve_round(shape1, shape2) do
    case {shape1, shape2} do
      {x, x} -> 0
      {not_empty, "n"} when not_empty !== "n" -> 1
      {"n", not_empty} when not_empty !== "n" -> 2
      {"r", "p"} -> 2
      {"r", "s"} -> 1
      {"r", "w"} -> 2
      {"p", "r"} -> 1
      {"p", "s"} -> 2
      {"p", "w"} -> 1
      {"s", "r"} -> 2
      {"s", "p"} -> 1
      {"s", "w"} -> 2
      {"w", "r"} -> 1
      {"w", "p"} -> 2
      {"w", "s"} -> 1
    end
  end

  @doc """
  Has game ended (with winner)?
  """
  def game_has_finished?(score1, score2), do: solve_game(score1, score2) !== 0

  @doc """
  Solves game according to players' scores.

  Returns 0 (no winner for the moment), 1 (player1 wins), 2 (player2 wins).
  """
  def solve_game(@win_round_count, _score2), do: 1
  def solve_game(_score1, @win_round_count), do: 2
  def solve_game(_score1, _score2), do: 0

  @doc """
  Knowing the previous scores of both players and who has won the current round,
  returns the diff of the updated score.

  In case of a tie round (0 as the last parameter), returns an empty diff.
  """
  def score_diff(score1, _score2, 1), do: %{score1: score1 + 1}
  def score_diff(_score1, score2, 2), do: %{score2: score2 + 1}
  def score_diff(_score1, _score2, 0), do: %{}
end
