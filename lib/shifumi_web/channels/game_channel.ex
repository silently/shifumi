defmodule ShifumiWeb.GameChannel do
  @moduledoc """
  Channel used to manage in-game communication between players and Shifumi.Engine.GameServer process.
  """

  use ShifumiWeb, :channel
  alias Shifumi.Engine.GameServer

  def join("game:" <> game_id, _payload, %{assigns: %{player_id: player_id}} = socket) do
    case Registry.lookup(Shifumi.Engine.GameRegistry, player_id) do
      [{pid, ^game_id}] ->
        {:ok, assign(socket, :game_pid, pid)}

      _ ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in(
        "fetch",
        _payload,
        %{assigns: %{player_id: player_id, game_pid: game_pid}} = socket
      ) do
    game = GameServer.get_state(game_pid)

    # Build opponent
    %{player1_id: player1_id, player2_id: player2_id} = game
    opponent_id = if player_id == player1_id, do: player2_id, else: player1_id

    opponent =
      ShifumiWeb.PlayerView.render("full.json", %{
        player: Shifumi.People.get_full_player!(opponent_id)
      })

    {:reply, {:ok, %{game: game, opponent: opponent}}, socket}
  end

  @doc """
  Simply forward the message to the GameServer
  """
  def handle_in(
        "throw",
        %{"shape" => shape},
        %{assigns: %{player_id: player_id, game_pid: game_pid}} = socket
      ) do
    GameServer.throw(game_pid, player_id, shape)
    {:reply, :ok, socket}
  end

  @doc """
  Bluff/influence event used only to make believe the opponent we have a guess
  about his/her next shape
  """
  def handle_in("guess", %{"shape" => shape}, socket) do
    broadcast_from(socket, "guess", %{"shape" => shape})
    {:noreply, socket}
  end
end
