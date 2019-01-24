defmodule ShifumiWeb.PlayerSocket do
  @moduledoc """
  Per-player socket configuration.
  """

  use Phoenix.Socket

  @online_topic Shifumi.online_topic()

  ## Channels
  channel(@online_topic, ShifumiWeb.PlayerChannel)
  channel("player:*", ShifumiWeb.PlayerChannel)
  channel("game:*", ShifumiWeb.GameChannel)

  # Socket params are passed from the client and can
  # be used to verify and authenticate a player. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :player_id, verified_player_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"player_token" => player_token}, socket) do
    with {:ok, player_id} <-
           Phoenix.Token.verify(socket, "player_socket_ns", player_token, max_age: 1_209_600),
         player when not is_nil(player) <- Shifumi.People.get_player!(player_id) do
      {:ok, assign(socket, :player_id, player_id)}
    else
      _ ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given player:
  #
  #     def id(socket), do: "player_socket:#{socket.assigns.player_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given player:
  #
  #     ShifumiWeb.Endpoint.broadcast("player_socket:#{player.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(socket), do: "player_socket:#{socket.assigns.player_id}"
end
