defmodule ShifumiWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """
  use ShifumiWeb, :controller
  alias Ueberauth.Strategy.Helpers

  plug(Ueberauth)

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def exit(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> send_resp(:ok, "")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    auth_failure(conn)
  end

  def callback(
        %{assigns: %{ueberauth_auth: %Ueberauth.Auth{provider: provider, uid: uid}}} = conn,
        _params
      ) do
    # github strategy returns an integer uid
    uid = if is_integer(uid), do: Integer.to_string(uid), else: uid

    case Shifumi.People.enter(Atom.to_string(provider), uid) do
      {:ok, player_id} ->
        player_token = Phoenix.Token.sign(conn, "player_socket_ns", player_id)
        assign(conn, :player_token, player_token)

        conn
        |> put_session("player_id", player_id)
        |> configure_session(renew: true)
        |> redirect(to: "/play")

      {:error, :unauthorized} ->
        auth_failure(conn)
    end
  end

  defp auth_failure(conn) do
    conn
    |> put_flash(:info, "Authentication failed")
    |> redirect(to: "/")
  end
end
