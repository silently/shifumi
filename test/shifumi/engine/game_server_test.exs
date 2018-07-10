defmodule Shifumi.Engine.GameServerTest do
  use Shifumi.DataCase
  import Shifumi.Fixtures
  alias Shifumi.Engine.GameServer

  @beat Shifumi.beat()

  # Helpers

  # Creates game and players, subscribe and starts intro
  defp launch_game_with_players() do
    player1 = seed!(:player_with_avatar, %{nickname: "player1"})
    player2 = seed!(:player_with_avatar, %{nickname: "player2"})
    {:ok, pid} = start_supervised({GameServer, {player1.id, player2.id}})
    %{id: game_id} = GameServer.get_state(pid)

    ShifumiWeb.Endpoint.subscribe("game:" <> game_id)
    GameServer.start_intro(pid)

    %{pid: pid, game_id: game_id, player1: player1, player2: player2}
  end

  # n is the number of turns to wait for, based on the config beat duration
  # and adding an extra delay so that events are received by tests
  # and the fact the introductory step is a bit longer (* 0.5)
  defp wait_for(n) do
    n * @beat + round(@beat * 0.5) + 50
  end

  defp autoplay(pid, player1_id, player2_id, throws) do
    throws
    |> Enum.reduce(0, fn [shape1, shape2], step ->
      Task.start_link(fn ->
        # Play after the right amount of time
        :timer.sleep(wait_for(step))
        GameServer.throw(pid, player1_id, shape1)
        GameServer.throw(pid, player2_id, shape2)
      end)

      step + 1
    end)
  end

  defp assert_sequence(game_id, expecteds) do
    expecteds
    |> Enum.reduce(1, fn {event, payload}, step ->
      assert_receive(
        %Phoenix.Socket.Broadcast{
          event: ^event,
          payload: ^payload,
          topic: "game:" <> ^game_id
        },
        wait_for(step)
      )

      step + 1
    end)

    # No more messages
    refute_received(%Phoenix.Socket.Broadcast{})
  end

  describe "get_state/1" do
    test "returns correct initial state" do
      %{
        pid: pid,
        game_id: game_id,
        player1: player1,
        player2: player2
      } = launch_game_with_players()

      {player1_id, player2_id} = {player1.id, player2.id}

      assert %{
               id: ^game_id,
               player1_id: ^player1_id,
               player2_id: ^player2_id,
               round: 0,
               score1: 0,
               score2: 0,
               history1: "",
               history2: ""
             } = GameServer.get_state(pid)
    end

    test "returns timed state" do
      %{pid: pid} = launch_game_with_players()

      # HACK? since testing timing
      :timer.sleep(150)
      %{elapsed: elapsed} = GameServer.get_state(pid)
      assert elapsed > 140
      assert elapsed < 160
    end

    test "returns correct history" do
      %{
        pid: pid,
        game_id: game_id,
        player1: player1,
        player2: player2
      } = launch_game_with_players()

      {player1_id, player2_id} = {player1.id, player2.id}

      # Programmed play section, after intro
      :timer.sleep(wait_for(1))

      autoplay(pid, player1_id, player2_id, [
        ["r", "s"],
        ["p", "s"],
        ["r", "w"],
        ["r", "w"]
      ])

      # Wait for 4 rounds
      :timer.sleep(wait_for(4))

      # Note the nullified second well played by player 2
      assert %{
               id: ^game_id,
               player1_id: ^player1_id,
               player2_id: ^player2_id,
               round: 5,
               score1: 2,
               score2: 2,
               history1: "rprr",
               history2: "sswn"
             } = GameServer.get_state(pid)
    end
  end

  test "throw/2: ignored during introduction" do
    %{
      pid: pid,
      game_id: game_id,
      player1: player1
    } = launch_game_with_players()

    :timer.sleep(div(@beat, 2))
    # Thrown during introduction (round 0)
    GameServer.throw(pid, player1.id, "r")

    # Wait till the beginning of round 2 to check round 1 has not been affected
    refute_receive(
      %Phoenix.Socket.Broadcast{
        event: "game_new_round",
        payload: %{prev_winner: 1},
        topic: "game:" <> ^game_id
      },
      wait_for(2)
    )
  end

  test "aborted when users are idle (max_empty_rounds reached)" do
    %{
      pid: pid,
      game_id: game_id,
      player1: player1
    } = launch_game_with_players()

    # ...Players are almost sleeping...
    :timer.sleep(wait_for(4))
    # Thrown during introduction (round 0)
    GameServer.throw(pid, player1.id, "r")

    # Game needs to be aborted
    # If Shifumi.max_empty_rounds is 10
    # Then 12 rounds needed since = 1 for intro + 1 played by player 1 + 10 idles
    # Already sleeped for 4 rounds (see :timer above), so 8 are remaining
    assert_receive(
      %Phoenix.Socket.Broadcast{
        event: "game_abort",
        topic: "game:" <> ^game_id
      },
      wait_for(Shifumi.max_empty_rounds() - 2)
    )
  end

  @tag :skip
  test "aborted after max_rounds" do
    %{
      pid: pid,
      game_id: game_id,
      player1: player1,
      player2: player2
    } = launch_game_with_players()

    # ...Players are stubborn...
    max_rounds = Shifumi.max_rounds()
    seq = Enum.map(1..max_rounds, fn _ -> ["r", "r"] end)
    autoplay(pid, player1.id, player2.id, seq)

    # Game needs to be aborted after max_rounds + 1 (for intro) + 1 for ??
    assert_receive(
      %Phoenix.Socket.Broadcast{
        event: "game_tie",
        topic: "game:" <> ^game_id
      },
      wait_for(max_rounds + 2)
    )
  end

  test "throw/3 rock > scissors > paper > rock ~ rock" do
    %{
      pid: pid,
      game_id: game_id,
      player1: player1,
      player2: player2
    } = launch_game_with_players()

    assert_receive(
      %Phoenix.Socket.Broadcast{
        event: "game_new_round",
        payload: %{round: 1},
        topic: "game:" <> ^game_id
      },
      wait_for(1)
    )

    # Programmed play section
    autoplay(pid, player1.id, player2.id, [
      ["r", "s"],
      ["p", "s"],
      ["r", "r"],
      ["p", "r"],
      ["p", "p"],
      ["p", "r"]
    ])

    assert_sequence(game_id, [
      {"game_new_round", %{prev_shapes: ["r", "s"], prev_winner: 1, round: 2, score1: 1}},
      {"game_new_round", %{prev_shapes: ["p", "s"], prev_winner: 2, round: 3, score2: 1}},
      {"game_new_round", %{prev_shapes: ["r", "r"], prev_winner: 0, round: 4}},
      {"game_new_round", %{prev_shapes: ["p", "r"], prev_winner: 1, round: 5, score1: 2}},
      {"game_new_round", %{prev_shapes: ["p", "p"], prev_winner: 0, round: 6}},
      {"game_end", %{prev_shapes: ["p", "r"], prev_winner: 1, score1: 3, winner: 1}}
    ])
  end

  test "throw/3 ignores wells if players don't have any (client-side cheat)" do
    %{
      pid: pid,
      game_id: game_id,
      player1: player1,
      player2: player2
    } = launch_game_with_players()

    assert_receive(
      %Phoenix.Socket.Broadcast{
        event: "game_new_round",
        payload: %{round: 1},
        topic: "game:" <> ^game_id
      },
      wait_for(1)
    )

    autoplay(pid, player1.id, player2.id, [
      ["w", "s"],
      ["w", "w"],
      ["r", "w"],
      ["r", "s"]
    ])

    assert_sequence(game_id, [
      {"game_new_round", %{prev_shapes: ["w", "s"], prev_winner: 1, round: 2, score1: 1}},
      {"game_new_round", %{prev_shapes: ["n", "w"], prev_winner: 2, round: 3, score2: 1}},
      {"game_new_round", %{prev_shapes: ["r", "n"], prev_winner: 1, round: 4, score1: 2}},
      {"game_end", %{prev_shapes: ["r", "s"], prev_winner: 1, score1: 3, winner: 1}}
    ])
  end
end
