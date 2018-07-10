defmodule ShifumiWeb.MenuController do
  @moduledoc """
  Menu pages controller.
  """

  use ShifumiWeb, :controller

  plug(:assign_csrf)

  def index(conn, _params) do
    conn =
      with player_id when not is_nil(player_id) <- get_session(conn, :player_id),
           player when not is_nil(player) <- Shifumi.People.get_player(player_id) do
        conn
        |> assign(:player, player)
        |> assign(:player_token, Phoenix.Token.sign(conn, "player_socket_ns", player.id))
      else
        nil ->
          conn
      end

    flash = get_flash(conn)["info"]
    conn = if flash, do: assign(conn, :flash, flash), else: conn

    render(conn, "index.html")
  end

  ###########
  # Private #
  ###########

  defp assign_csrf(conn, _options) do
    assign(conn, :csrf_token, get_csrf_token())
  end
end
