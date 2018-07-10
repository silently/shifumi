defmodule ShifumiWeb.AvatarControllerTest do
  use ShifumiWeb.ConnCase
  import Plug.Test
  import Shifumi.Fixtures

  @create_attrs %{
    location: "some location",
    mantra: "some mantra",
    nickname: "some nickname",
    picture: true,
    roar: "some roar"
  }
  @invalid_attrs %{location: nil, mantra: nil, nickname: nil, picture: nil, roar: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "show/2" do
    setup [:seed_and_auth_player]

    test "sends avatar json", %{conn: conn, player: player} do
      conn = get(conn, avatar_path(conn, :show))
      body = json_response(conn, 200)

      assert body["player_id"] == player.id
      assert body["location"] == @create_attrs.location
      assert body["mantra"] == @create_attrs.mantra
      assert body["nickname"] == @create_attrs.nickname
      assert body["picture"] == @create_attrs.picture
      assert body["roar"] == @create_attrs.roar
    end
  end

  describe "update/2" do
    setup [:seed_and_auth_player]

    test "renders avatar when data is valid", %{conn: conn, player: player} do
      update_attrs = %{
        "location" => "some updated location",
        "mantra" => "some updated mantra",
        # avatar should be < 20 characters
        "nickname" => "updated nickname",
        "picture" => false,
        "roar" => "some updated roar"
      }

      conn = put(conn, avatar_path(conn, :update), update_attrs)
      json_response(conn, 200)
      conn = get(conn, avatar_path(conn, :show))

      update_attrs = Map.put(update_attrs, "player_id", player.id)

      assert ^update_attrs = Map.delete(json_response(conn, 200), "id")
    end

    test "can not update the avatar id", %{conn: conn} do
      bad_id = Ecto.UUID.generate()
      conn = put(conn, avatar_path(conn, :update), %{id: bad_id})
      json_response(conn, 401)
      conn = get(conn, avatar_path(conn, :show))
      assert_raise MatchError, fn -> %{"id" => ^bad_id} = json_response(conn, 200) end
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = put(conn, avatar_path(conn, :update), @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  # HACK cheat session contents to log user in
  defp seed_and_auth_player(%{conn: conn}) do
    player = seed!(:player_with_avatar, @create_attrs)
    conn = conn |> init_test_session(player_id: player.id)

    {:ok, conn: conn, player: player}
  end
end
