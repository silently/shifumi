defmodule ShifumiWeb.GameChannelTest do
  use ShifumiWeb.ChannelCase, async: false
  import Shifumi.Fixtures
  alias ShifumiWeb.GameChannel
  alias Shifumi.Engine.GameServer

  # Helpers

  defp create_assigned_socket(player) do
    socket(ShifumiWeb.PlayerSocket, "player_socket:" <> player.id, %{player_id: player.id})
  end

  # Set up a game with 2 players
  setup do
    player1 = seed!(:player_with_avatar, %{nickname: "player1"})
    player2 = seed!(:player_with_avatar, %{nickname: "player2"})
    {:ok, pid} = start_supervised({GameServer, {player1.id, player2.id}})
    %{id: game_id} = GameServer.get_state(pid)
    [player1: player1, player2: player2, game_id: game_id]
  end

  describe "join/3" do
    test "allows player 1 to join a game channel s/he's in", %{
      player1: player1,
      game_id: game_id
    } do
      # Creates socket
      socket = create_assigned_socket(player1)
      # Tries to connect to the game channel
      assert {:ok, _reply, _socket} =
               subscribe_and_join(socket, GameChannel, "game:" <> game_id, %{})
    end

    test "allows player 2 to join a game channel s/he's in", %{
      player2: player2,
      game_id: game_id
    } do
      # Creates socket
      socket = create_assigned_socket(player2)
      # Tries to connect to the game channel
      assert {:ok, _reply, _socket} =
               subscribe_and_join(socket, GameChannel, "game:" <> game_id, %{})
    end

    test "denies player to join a game channel s/he's NOT in", %{game_id: game_id} do
      player3 = seed!(:player)
      # Creates socket
      socket = create_assigned_socket(player3)
      # Tries to connect to the game channel
      assert {:error, _reply} = subscribe_and_join(socket, GameChannel, "game:" <> game_id, %{})
    end

    test "denies player to join an unexisting game", %{player1: player1} do
      # Creates socket
      socket = create_assigned_socket(player1)
      # Tries to connect to the game channel
      assert {:error, _reply} =
               subscribe_and_join(socket, GameChannel, "game:" <> Ecto.UUID.generate(), %{})
    end
  end

  test "handle_in/3(\"fetch\", ...) replies with game and opponent", %{
    player1: %{id: player1_id} = player1,
    player2: %{id: player2_id, avatar: %{nickname: player2_nickname}},
    game_id: game_id
  } do
    # Creates sockets
    socket = create_assigned_socket(player1)
    # Connects to the game channel
    {:ok, _reply, socket} = subscribe_and_join(socket, GameChannel, "game:" <> game_id, %{})

    ref = push(socket, "fetch")

    assert_reply(ref, :ok, %{
      game: %{
        id: ^game_id,
        player1_id: ^player1_id,
        player2_id: ^player2_id,
        round: 0
      },
      opponent: %{
        avatar: %{
          nickname: ^player2_nickname,
          mantra: _
        },
        sheet: %{
          wells: _,
          game_count: _,
          paper_pct: _
        }
      }
    })
  end

  test "handle_in/3(\"guess\", ...) broadcasts event", %{player1: player1, game_id: game_id} do
    # Creates sockets
    socket = create_assigned_socket(player1)
    # Connects to the game channel
    {:ok, _reply, socket} = subscribe_and_join(socket, GameChannel, "game:" <> game_id, %{})

    push(socket, "guess", %{"shape" => "s"})
    assert_broadcast("guess", %{"shape" => "s"})
  end

  test "handle_in/3(\"throw\", ...) acknowledges event", %{player1: player1, game_id: game_id} do
    # Creates sockets
    socket = create_assigned_socket(player1)
    # Connects to the game channel
    {:ok, _reply, socket} = subscribe_and_join(socket, GameChannel, "game:" <> game_id, %{})

    ref = push(socket, "throw", %{"shape" => "s"})
    assert_reply(ref, :ok)
  end
end
