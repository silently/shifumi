defmodule ShifumiWeb.AvatarViewTest do
  use ShifumiWeb.ConnCase, async: true
  import Shifumi.Fixtures
  alias ShifumiWeb.AvatarView

  test "render/2(\"show.json\", ...)" do
    avatar = %{build(:avatar) | player_id: Ecto.UUID.generate()}
    rendered = AvatarView.render("show.json", %{avatar: avatar})

    assert rendered.player_id == avatar.player_id
    assert rendered.location == avatar.location
    assert rendered.mantra == avatar.mantra
    assert rendered.nickname == avatar.nickname
    assert rendered.picture == avatar.picture
    assert rendered.roar == avatar.roar
  end
end
