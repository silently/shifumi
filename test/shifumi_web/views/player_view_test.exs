defmodule ShifumiWeb.PlayerViewTest do
  use ShifumiWeb.ConnCase, async: true
  import Shifumi.Fixtures
  alias ShifumiWeb.PlayerView

  test "render/2(\"full.json\", ...) includes id, avatar and sheet" do
    sheet_attrs = %{
      wells: 11,
      game_count: 20,
      high_score: 7,
      score: 4,
      game_win_count: 10
    }

    avatar_attrs = %{
      nickname: "tomato",
      mantra: "I am growing",
      location: "garden",
      picture: false,
      roar: "you are rotten"
    }

    player = seed!(:full_player, %{avatar: avatar_attrs, sheet: sheet_attrs})
    %{id: id, avatar: avatar, sheet: sheet} = PlayerView.render("full.json", %{player: player})

    # See sheet_view_test for unit test of all sheet fields
    assert id == player.id
    assert sheet.wells == sheet_attrs.wells
    assert sheet.game_count == sheet_attrs.game_count
    assert sheet.high_score == sheet_attrs.high_score
    assert sheet.score == sheet_attrs.score
    assert sheet.win_pct == 50
    assert avatar.nickname == avatar_attrs.nickname
    assert avatar.mantra == avatar_attrs.mantra
    assert avatar.location == avatar_attrs.location
    assert avatar.picture == avatar_attrs.picture
    assert avatar.roar == avatar_attrs.roar
  end

  test "render/2(\"full.json\", ...) only includes sheet if avatar is not set" do
    sheet_attrs = %{
      wells: 11,
      game_count: 20,
      high_score: 7,
      score: 4,
      game_win_count: 10
    }

    player = seed!(:player_with_sheet, sheet_attrs)
    %{avatar: avatar, sheet: sheet} = PlayerView.render("full.json", %{player: player})

    # See sheet_view_test for unit test of all sheet fields
    assert sheet.wells == sheet_attrs.wells
    assert sheet.game_count == sheet_attrs.game_count
    assert sheet.high_score == sheet_attrs.high_score
    assert sheet.score == sheet_attrs.score
    assert sheet.win_pct == 50
    assert !Map.has_key?(avatar, :nickname)
  end
end
