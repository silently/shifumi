defmodule ShifumiWeb.Router do
  @moduledoc """
  Web router.
  """

  use ShifumiWeb, :router

  pipeline :browser do
    plug(:accepts, ~w(html json))
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :logged do
    plug(:browser)
    plug(:authenticate)
  end

  scope "/", ShifumiWeb do
    pipe_through(:browser)
    pipe_through(:assign_players_count)

    get("/", MenuController, :index)
    get("/rules", MenuController, :index)
    get("/about", MenuController, :index)
    get("/terms", MenuController, :index)

    post("/enter", MenuController, :enter)
  end

  scope "/auth", ShifumiWeb do
    pipe_through([:browser])

    get("/:provider", AuthController, :request)
    get("/:provider/callback", AuthController, :callback)
    post("/exit", AuthController, :exit)
  end

  scope "/", ShifumiWeb do
    pipe_through(:logged)
    pipe_through(:assign_players_count)

    get("/play", PlayController, :index)
    get("/avatar", MenuController, :index)
  end

  scope "/api", ShifumiWeb do
    pipe_through(:logged)

    # singleton resources
    resources("/avatar", AvatarController, singleton: true, only: [:show, :update])
    resources("/player", PlayerController, singleton: true, only: [:delete])
  end

  defp authenticate(conn, _options) do
    with player_id when not is_nil(player_id) <- get_session(conn, :player_id),
         player when not is_nil(player) <- Shifumi.People.get_player(player_id) do
      assign(conn, :player, player)
    else
      nil ->
        conn
        |> Phoenix.Controller.redirect(to: "/")
        |> halt()
    end
  end

  defp assign_players_count(conn, _options) do
    presence_list = Map.keys(ShifumiWeb.Presence.list("presence"))

    players_count =
      if Enum.member?(presence_list, get_session(conn, :player_id)),
        do: length(presence_list),
        else: length(presence_list) + 1

    assign(conn, :players_count, players_count)
  end
end
