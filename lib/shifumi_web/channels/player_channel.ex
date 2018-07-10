defmodule ShifumiWeb.PlayerChannel do
  @moduledoc """
  Channel used to manage player events prior to or outside a game context.
  """

  use ShifumiWeb, :channel
  alias Shifumi.Engine.{GameServer, GameRegistry, GameSupervisor}
  alias Shifumi.People
  alias Shifumi.People.Dating
  alias ShifumiWeb.Presence

  @online_topic Shifumi.online_topic()

  def join("player:" <> requested_player_id, _payload, socket) do
    if authorized?(requested_player_id, socket) do
      already_playing_filter(socket)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def join(@online_topic, _params, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, %{assigns: %{player_id: player_id}} = socket) do
    push(socket, "presence_state", Presence.list(socket))
    {:ok, _} = Presence.track(self(), @online_topic, player_id, %{})
    {:noreply, socket}
  end

  def handle_info({:send_reconnect, game_pid}, socket) do
    %{id: game_id} = GameServer.get_state(game_pid)
    push(socket, "trigger_reconnect", %{id: game_id})
    {:noreply, socket}
  end

  def handle_in("fetch", _payload, %{assigns: %{player_id: player_id}} = socket) do
    response =
      ShifumiWeb.PlayerView.render("full.json", %{
        player: Shifumi.People.get_full_player!(player_id)
      })

    {:reply, {:ok, response}, socket}
  end

  def handle_in("best_live", _payload, socket) do
    {:reply, {:ok, %{data: Shifumi.Records.best_live()}}, socket}
  end

  def handle_in("best", _payload, socket) do
    {:reply, {:ok, %{data: Shifumi.Records.best()}}, socket}
  end

  def handle_in("ready", _payload, %{assigns: %{player_id: player_id}} = socket) do
    if !already_playing_filter(socket) do
      case Dating.find_partner(Dating, player_id) do
        :waiting ->
          {:reply, :waiting, socket}

        opponent ->
          {:ok, pid} = GameSupervisor.start_game(player_id, opponent)
          # Send initial state
          %{id: game_id} = GameServer.get_state(pid)
          ShifumiWeb.Endpoint.broadcast("player:" <> opponent, "trigger_join", %{id: game_id})
          push(socket, "trigger_join", %{id: game_id})
          # Start timed game
          GameServer.start_intro(pid)
          {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_in("busy", _payload, %{assigns: %{player_id: player_id}} = socket) do
    # We don't test if player is already in a game since it does not conflict
    # with being busy
    Dating.busy(Dating, player_id)
    {:noreply, socket}
  end

  def handle_in("init_nickname", nickname, %{assigns: %{player_id: player_id}} = socket) do
    case People.get_player!(player_id) |> People.create_player_avatar(%{nickname: nickname}) do
      {:ok, %{nickname: nickname}} ->
        {:reply, {:ok, %{nickname: nickname}}, socket}

      {:error, changeset} ->
        response = ShifumiWeb.ChangesetView.render("error.json", %{changeset: changeset})
        {:reply, {:error, response}, socket}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(requested_player_id, %{assigns: %{player_id: player_id}}),
    do: requested_player_id == player_id

  # Does two things (maybe it's unclear, but it uses the game_pid in place):
  # - return true/false depending on the fact the player is registered in a game
  # - if true, ask to send a reconnect to client
  defp already_playing_filter(%{assigns: %{player_id: player_id}}) do
    case GameRegistry.lookup(player_id) do
      [{game_pid, _}] ->
        send(self(), {:send_reconnect, game_pid})
        true

      _ ->
        false
    end
  end
end
