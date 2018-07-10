defmodule Shifumi.Engine.RulesTest do
  use ExUnit.Case, async: true

  alias Shifumi.Engine.Rules

  describe "solve_round/2" do
    test "declares tie when throws are identical" do
      assert 0 === Rules.solve_round("p", "p")
      assert 0 === Rules.solve_round("s", "s")
      assert 0 === Rules.solve_round("r", "r")
      assert 0 === Rules.solve_round("w", "w")
      assert 0 === Rules.solve_round("n", "n")
    end

    test "player loses when s/he does not play" do
      assert 1 === Rules.solve_round("w", "n")
      assert 2 === Rules.solve_round("n", "p")
    end

    test "rock < paper < scissors < rock" do
      assert 1 === Rules.solve_round("p", "r")
      assert 2 === Rules.solve_round("p", "s")
      assert 1 === Rules.solve_round("r", "s")
    end

    test "rock & scissors < well < paper" do
      assert 1 === Rules.solve_round("w", "r")
      assert 2 === Rules.solve_round("s", "w")
      assert 1 === Rules.solve_round("p", "w")
    end
  end

  test "solve_game/2 game goes til the best of 3 rounds" do
    assert 1 === Rules.solve_game(3, 0)
    assert 1 === Rules.solve_game(3, 1)
    assert 1 === Rules.solve_game(3, 2)
    assert 2 === Rules.solve_game(0, 3)
    assert 2 === Rules.solve_game(1, 3)
    assert 2 === Rules.solve_game(2, 3)
    assert 0 === Rules.solve_game(0, 0)
    assert 0 === Rules.solve_game(1, 0)
    assert 0 === Rules.solve_game(0, 1)
    assert 0 === Rules.solve_game(1, 1)
    assert 0 === Rules.solve_game(2, 1)
    assert 0 === Rules.solve_game(1, 2)
    assert 0 === Rules.solve_game(2, 2)
  end

  test "score_diff/3 updates score according to new round" do
    assert %{score1: 1} === Rules.score_diff(0, 0, 1)
    assert %{score2: 3} === Rules.score_diff(2, 2, 2)
    assert %{} === Rules.score_diff(2, 2, 0)
  end
end
