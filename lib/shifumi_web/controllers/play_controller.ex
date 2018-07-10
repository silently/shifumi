defmodule ShifumiWeb.PlayController do
  @moduledoc """
  Game pages controller.
  """

  use ShifumiWeb, :controller

  #######
  # GET #
  #######

  def index(%{assigns: %{player: player}} = conn, _params) do
    conn
    |> assign(:player_token, Phoenix.Token.sign(conn, "player_socket_ns", player.id))
    |> assign(:csrf_token, get_csrf_token())
    |> render("index.html")
  end
end
