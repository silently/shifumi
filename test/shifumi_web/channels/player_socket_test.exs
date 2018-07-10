defmodule ShifumiWeb.PlayerSocketTest do
  use ShifumiWeb.ChannelCase, async: true
  import Shifumi.Fixtures
  alias ShifumiWeb.{Endpoint, PlayerSocket}

  describe "connect/2" do
    test "accepts player with valid token" do
      %{id: player_id} = seed!(:player)
      player_token = Phoenix.Token.sign(Endpoint, "player_socket_ns", player_id)
      assert {:ok, socket} = connect(PlayerSocket, %{"player_token" => player_token})
      assert ^player_id = socket.assigns.player_id
    end

    test "denies player with invalid token" do
      %{id: player_id} = seed!(:player)
      player_token = Phoenix.Token.sign(Endpoint, "bad_salt", player_id)
      assert :error = connect(PlayerSocket, %{"player_token" => player_token})
    end
  end
end
