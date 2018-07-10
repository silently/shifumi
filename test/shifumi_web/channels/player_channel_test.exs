defmodule ShifumiWeb.PlayerChannelTest do
  use ShifumiWeb.ChannelCase, async: false
  import Shifumi.Fixtures
  alias Shifumi.Engine.{GameServer, GameRegistry}
  alias Shifumi.People.Dating

  @online_topic Shifumi.online_topic()

  # Returns {:ok, socket} if ok
  defp connect_player(player_id) do
    # We use connect/1 rather than socket/2 since we don't want to bypass the connection mechanism
    # In other test suites (GameChannel for instance) we use directly socket/2 to assign the player_id
    player_token = Phoenix.Token.sign(ShifumiWeb.Endpoint, "player_socket_ns", player_id)
    connect(ShifumiWeb.PlayerSocket, %{"player_token" => player_token})
  end

  setup do
    Dating.reset(Dating)
    %{id: player1_id} = seed!(:player)
    %{id: player2_id} = seed!(:player)
    [player1_id: player1_id, player2_id: player2_id]
  end

  describe "join/3(\"player:player_id\")" do
    test "grants player to join to his own channel", %{player1_id: player1_id} do
      {:ok, socket} = connect_player(player1_id)
      assert {:ok, _reply, _socket} = subscribe_and_join(socket, "player:" <> player1_id, %{})
    end

    test "denies player to join to someone else channel", %{
      player1_id: player1_id,
      player2_id: player2_id
    } do
      {:ok, socket} = connect_player(player1_id)
      assert {:error, _reply} = subscribe_and_join(socket, "player:" <> player2_id, %{})
    end
  end

  describe "join/3(\" " <> @online_topic <> "\")" do
    # Tests the side effect of handle_info/3(:after_join, ...)
    test "presence event is triggered after join", %{player1_id: player1_id} do
      ShifumiWeb.Endpoint.subscribe(@online_topic)
      {:ok, socket} = connect_player(player1_id)
      {:ok, _reply, _socket} = subscribe_and_join(socket, @online_topic, %{})

      # assert_receive %Phoenix.Socket.Broadcast{event: "presence_state"}
      assert_receive %Phoenix.Socket.Broadcast{event: "presence_diff"}
    end
  end

  test "handle_in/3(\"fetch\", ...) replies with player data" do
    player = seed!(:player_with_avatar, %{nickname: "tomato"})
    {:ok, socket} = connect_player(player.id)
    assert {:ok, _reply, socket} = subscribe_and_join(socket, "player:" <> player.id, %{})

    ref = push(socket, "fetch", %{})

    # See view tests for full unit testing of fields
    assert_reply(ref, :ok, %{
      avatar: %{
        nickname: "tomato"
      },
      sheet: %{
        score: 0,
        game_count: 0,
        win_pct: 0
      }
    })
  end

  describe "handle_in/3(\"best_live\", ...)" do
    test "replies with 10 best live scores", %{player1_id: player1_id} do
      {:ok, socket} = connect_player(player1_id)
      {:ok, _reply, socket} = subscribe_and_join(socket, "player:" <> player1_id, %{})

      # Creates 20 different players with score 11/12/13, then 21/22/23... 201/202/203
      0..19
      |> Enum.each(fn player_index ->
        player =
          seed!(:player_with_avatar, %{nickname: "player" <> Integer.to_string(player_index)})

        0..2
        |> Enum.each(&seed!(:score, %{player: player, count: player_index * 10 + &1, live: true}))
      end)

      ref = push(socket, "best_live", %{})

      assert_reply(ref, :ok, %{data: data})
      assert length(data) == 10
      assert %{nickname: "player19", count: 192} = List.first(data)
    end
  end

  describe "handle_in/3(\"best\", ...)" do
    test "replies with 10 best ever scores", %{player1_id: player1_id} do
      {:ok, socket} = connect_player(player1_id)
      {:ok, _reply, socket} = subscribe_and_join(socket, "player:" <> player1_id, %{})

      seed!(:full_player, %{
        avatar: %{nickname: "player9"},
        sheet: %{high_score: 10, high_score_at: ~N[2018-02-02 20:00:00]}
      })

      seed!(:full_player, %{
        avatar: %{nickname: "player10"},
        sheet: %{high_score: 10, high_score_at: ~N[2018-02-02 19:00:00]}
      })

      1..8
      |> Enum.each(fn player_index ->
        seed!(:full_player, %{
          avatar: %{nickname: "player" <> Integer.to_string(player_index)},
          sheet: %{high_score: player_index, high_score_at: NaiveDateTime.utc_now()}
        })
      end)

      ref = push(socket, "best", %{})

      assert_reply(ref, :ok, %{data: data})
      assert length(data) == 10
      assert %{nickname: "player10", count: 10} = List.first(data)
      assert %{nickname: "player1", count: 1} = List.last(data)
    end
  end

  describe "handle_in/3(\"init_nickname\", ...)" do
    test "denies nickname if already used", %{player1_id: player1_id} do
      _other_player = seed!(:player_with_avatar, %{nickname: "tomato"})
      {:ok, socket} = connect_player(player1_id)
      {:ok, _reply, socket} = subscribe_and_join(socket, "player:" <> player1_id, %{})
      ref = push(socket, "init_nickname", "tomato")

      assert_reply(ref, :error, %{errors: %{nickname: ["has already been taken"]}})
    end

    test "denies invalid nickname", %{player1_id: player1_id} do
      {:ok, socket} = connect_player(player1_id)
      {:ok, _reply, socket} = subscribe_and_join(socket, "player:" <> player1_id, %{})
      ref = push(socket, "init_nickname", "this_nickname_is_way_too_long_dont_you_think")

      assert_reply(ref, :error, %{errors: %{nickname: ["should be at most 20 character(s)"]}})
    end

    test "sets valid nickname", %{player1_id: player1_id} do
      nickname = "cherry"
      {:ok, socket} = connect_player(player1_id)
      {:ok, _reply, socket} = subscribe_and_join(socket, "player:" <> player1_id, %{})

      ref = push(socket, "init_nickname", nickname)
      assert_reply(ref, :ok, %{nickname: ^nickname})

      ref = push(socket, "fetch", %{})
      assert_reply(ref, :ok, %{avatar: %{nickname: ^nickname}})
    end
  end

  describe "handle_in/3(\"ready\", ...)" do
    test "pairs players when both are ready", %{player1_id: player1_id, player2_id: player2_id} do
      parent = self()

      t1 =
        Task.async(fn ->
          {:ok, socket1} = connect_player(player1_id)
          {:ok, _reply, socket1} = subscribe_and_join(socket1, "player:" <> player1_id, %{})
          ref = push(socket1, "ready", %{})
          assert_reply(ref, :waiting)

          send(parent, :p1_ready)
          # Waits for player 2
          receive do
            :p2_ready -> nil
          end

          assert_push("trigger_join", %{})
        end)

      # Ensure t2 happens after t1 (needed for "waiting test")
      receive do
        :p1_ready -> nil
      end

      t2 =
        Task.async(fn ->
          {:ok, socket2} = connect_player(player2_id)
          {:ok, _reply, socket2} = subscribe_and_join(socket2, "player:" <> player2_id, %{})
          push(socket2, "ready", %{})
          send(t1.pid, :p2_ready)
          assert_push("trigger_join", %{})
        end)

      Enum.map([t1, t2], &Task.await/1)
      # Clean up, since the Game process has not been started with start_supervised
      [{game_pid, _}] = GameRegistry.lookup(player1_id)
      Process.exit(game_pid, :normal)
    end

    # Tests the side effect of handle_info/3(:send_reconnect, ...)
    test "queries player client to reconnect if GameServer exists before join", %{
      player1_id: player1_id,
      player2_id: player2_id
    } do
      {:ok, socket1} = connect_player(player1_id)
      # Create a game under the hood *before joining*
      start_supervised({GameServer, {player1_id, player2_id}})
      {:ok, _reply, _socket1} = subscribe_and_join(socket1, "player:" <> player1_id, %{})
      assert_push("trigger_reconnect", %{})
    end

    # Tests the side effect of handle_info/3(:send_reconnect, ...)
    test "queries player client to reconnect if GameServer exists before ready", %{
      player1_id: player1_id,
      player2_id: player2_id
    } do
      {:ok, socket1} = connect_player(player1_id)
      {:ok, _reply, socket1} = subscribe_and_join(socket1, "player:" <> player1_id, %{})
      # Create a game under the hood *before ready*
      start_supervised({GameServer, {player1_id, player2_id}})
      push(socket1, "ready", %{})
      assert_push("trigger_reconnect", %{})
    end
  end
end
