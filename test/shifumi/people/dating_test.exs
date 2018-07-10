defmodule Shifumi.People.DatingTest do
  use Shifumi.DataCase
  alias Shifumi.People.Dating

  @server DatingTest
  @online_topic Shifumi.online_topic()
  @inactive_limit Shifumi.inactive_limit()
  @p1 Ecto.UUID.generate()
  @p2 Ecto.UUID.generate()
  @p3 Ecto.UUID.generate()

  defp start_dating() do
    # We supervise a Dating GenServer different from the web app one to control its state
    start_supervised({Dating, [name: @server]})
  end

  describe "find_partner/2" do
    test "tells the player to wait if no one is available" do
      start_dating()
      assert :waiting === Dating.find_partner(@server, @p2)
    end

    test "tells the player to wait if others are busy" do
      start_dating()
      Dating.find_partner(@server, @p1)
      Dating.busy(@server, @p1)
      assert :waiting === Dating.find_partner(@server, @p3)
    end

    test "tells the player to wait if others are offline" do
      start_dating()
      Dating.find_partner(@server, @p1)

      ShifumiWeb.Endpoint.broadcast(@online_topic, "presence_diff", %{
        leaves: %{@p1 => %{metas: []}}
      })

      _wait_for_broadcast = :sys.get_state(@server)
      assert :waiting === Dating.find_partner(@server, @p2)
    end

    test "tells the player to wait if she was already waiting" do
      start_dating()
      Dating.find_partner(@server, @p1)
      assert :waiting === Dating.find_partner(@server, @p1)
    end

    test "finds ready player if any" do
      start_dating()
      Dating.find_partner(@server, @p1)
      assert @p1 = Dating.find_partner(@server, @p2)
    end

    # DEPRECATED tests: Dating rules have been simplified
    # 2 players may now play several consecutive times
    #
    # test "does not pair player with previous winner" do
    #   start_dating()
    #   # p1 wins 1st match
    #   Dating.find_partner(@server, @p1)
    #   Dating.find_partner(@server, @p2)
    #   Dating.log_defeat(@server, @p2)
    #   # 2nd match not authorized
    #   Dating.find_partner(@server, @p1)
    #   assert :waiting = Dating.find_partner(@server, @p2)
    # end
    #
    # test "does not pair player with previous loser" do
    #   start_dating()
    #   # p2 1st match
    #   Dating.find_partner(@server, @p1)
    #   Dating.find_partner(@server, @p2)
    #   Dating.log_defeat(@server, @p1)
    #   # 2nd match not authorized
    #   Dating.find_partner(@server, @p1)
    #   assert :waiting = Dating.find_partner(@server, @p2)
    # end
    #
    # test "may pair a previous winner that has lost in the mean time" do
    #   start_dating()
    #   # p1 wins against p2
    #   Dating.find_partner(@server, @p1)
    #   Dating.find_partner(@server, @p2)
    #   Dating.log_defeat(@server, @p2)
    #   # p3 wins against p1
    #   Dating.find_partner(@server, @p1)
    #   Dating.find_partner(@server, @p3)
    #   Dating.log_defeat(@server, @p1)
    #   # p1 and p2 can play again
    #   assert :waiting === Dating.find_partner(@server, @p1)
    #   assert @p1 === Dating.find_partner(@server, @p2)
    # end
    #
    # test "finds unplayed opponent" do
    #   start_dating()
    #   # p3 wins against p1
    #   Dating.find_partner(@server, @p1)
    #   Dating.find_partner(@server, @p3)
    #   Dating.log_defeat(@server, @p1)
    #   # p1 wins against p2
    #   Dating.find_partner(@server, @p1)
    #   Dating.find_partner(@server, @p2)
    #   Dating.log_defeat(@server, @p2)
    #   # p1 and p2 will wait
    #   assert :waiting === Dating.find_partner(@server, @p1)
    #   assert :waiting === Dating.find_partner(@server, @p2)
    #   # p3 should partner p2 and not p1
    #   assert @p2 = Dating.find_partner(@server, @p3)
    # end
    #
    # test "loads player history from players persisted table" do
    #   start_dating()
    #
    #   player1 = seed!(:player)
    #   player2 = seed!(:player_with_sheet, %{series: [player1.id]})
    #
    #   assert :waiting = Dating.find_partner(@server, player1.id)
    #   assert :waiting = Dating.find_partner(@server, player2.id)
    # end
  end

  describe "log_tie/2" do
    test "enable players to meet again" do
      start_dating()
      # p2 and p3 wins against p1
      Dating.find_partner(@server, @p1)
      Dating.find_partner(@server, @p2)
      Dating.log_defeat(@server, @p1)
      Dating.find_partner(@server, @p1)
      Dating.find_partner(@server, @p3)
      Dating.log_defeat(@server, @p1)

      # p2 and p3 meet
      Dating.find_partner(@server, @p2)
      assert @p2 = Dating.find_partner(@server, @p3)
      # A tie occurs
      Dating.log_tie(@server, @p2)
      Dating.log_tie(@server, @p3)
      # They can meet again (but not p1)
      Dating.find_partner(@server, @p2)
      assert @p2 = Dating.find_partner(@server, @p3)
    end
  end

  describe "get_size/1" do
    test "counts ready and busy players" do
      start_dating()
      # p1 is waiting and ready
      Dating.find_partner(@server, @p1)
      assert {1, 0, 0} = Dating.get_size(@server)

      # p1 goes busy
      Dating.busy(@server, @p1)
      assert {0, 1, 0} = Dating.get_size(@server)

      # p2 is waiting and ready, p1 remains
      Dating.find_partner(@server, @p2)
      assert {1, 1, 0} = Dating.get_size(@server)

      # p3 and p2 go for a match, everyone is then busy
      Dating.find_partner(@server, @p3)
      assert {0, 3, 0} = Dating.get_size(@server)
      Dating.log_defeat(@server, @p3)

      # p2 is waiting and ready, p1 and p3 are busy
      Dating.find_partner(@server, @p2)
      assert {1, 2, 0} = Dating.get_size(@server)

      # DEPRECATED behaviour
      # p2 and p3 can not play a second match for the moment, they are both waiting
      # Dating.find_partner(@server, @p3)
      # assert {2, 1, 0} = Dating.get_size(@server)
    end

    test "counts leaving players (when going offline)" do
      start_dating()
      Dating.find_partner(@server, @p1)

      # p1 clients disconnect, s/he's considered leaving, but busy cache remains
      ShifumiWeb.Endpoint.broadcast(@online_topic, "presence_diff", %{
        leaves: %{@p1 => %{metas: []}}
      })

      _wait_for_broadcast_effect = :sys.get_state(@server)
      assert {0, 1, 1} = Dating.get_size(@server)

      # p1 went offline, and is removed from the Dating cache
      :timer.sleep(@inactive_limit + 50)
      assert {0, 0, 0} = Dating.get_size(@server)
    end

    test "counts leaving when coming back just in time" do
      start_dating()
      Dating.find_partner(@server, @p1)

      # p1 clients disconnect, s/he's considered leaving, but busy cache remains
      ShifumiWeb.Endpoint.broadcast(@online_topic, "presence_diff", %{
        leaves: %{@p1 => %{metas: []}}
      })

      _wait_for_broadcast = :sys.get_state(@server)
      assert {0, 1, 1} = Dating.get_size(@server)

      # p1 soon comes back
      ShifumiWeb.Endpoint.broadcast(@online_topic, "presence_diff", %{
        joins: %{@p1 => %{metas: []}}
      })

      assert {0, 1, 0} = Dating.get_size(@server)

      # p1 did not go offline, her status is maintained
      :timer.sleep(@inactive_limit + 50)
      assert {0, 1, 0} = Dating.get_size(@server)
    end
  end

  describe "reset/1" do
    test "empties ready and busy tables" do
      start_dating()
      # p1 is waiting and ready
      Dating.find_partner(@server, @p1)
      Dating.reset(@server)
      assert {0, 0, 0} = Dating.get_size(@server)

      # p1 goes busy
      Dating.find_partner(@server, @p1)
      Dating.busy(@server, @p1)
      Dating.reset(@server)
      assert {0, 0, 0} = Dating.get_size(@server)
    end

    test "emptis leaving table" do
      start_dating()
      Dating.find_partner(@server, @p1)

      # p1 clients disconnect, s/he's considered leaving, but busy cache remains
      ShifumiWeb.Endpoint.broadcast(@online_topic, "presence_diff", %{
        leaves: %{@p1 => %{metas: []}}
      })

      _wait_for_broadcast_effect = :sys.get_state(@server)
      Dating.reset(@server)
      assert {0, 0, 0} = Dating.get_size(@server)
    end
  end
end
