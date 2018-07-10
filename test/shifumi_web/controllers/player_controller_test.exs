defmodule ShifumiWeb.PlayerControllerTest do
  use ShifumiWeb.ConnCase
  import Plug.Test
  import Shifumi.Fixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "delete/2" do
    setup [:seed_and_auth_player]

    test "deletes singleton player", %{conn: conn} do
      conn = delete(conn, player_path(conn, :delete))
      assert response(conn, 204)

      # Player is deleted, thus unlogged and redirected if trying to access a logged route
      conn = get(conn, avatar_path(conn, :show))
      assert redirected_to(conn, 302) =~ "/"
    end
  end

  # HACK cheat session contents to log user in
  defp seed_and_auth_player(%{conn: conn}) do
    player = seed!(:player)
    conn = conn |> init_test_session(player_id: player.id)

    {:ok, conn: conn, player: player}
  end
end
