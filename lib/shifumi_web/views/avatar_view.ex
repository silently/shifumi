defmodule ShifumiWeb.AvatarView do
  use ShifumiWeb, :view

  def render("show.json", %{avatar: avatar}) do
    %{
      player_id: avatar.player_id,
      location: avatar.location,
      mantra: avatar.mantra,
      nickname: avatar.nickname,
      roar: avatar.roar,
      picture: avatar.picture
    }
  end
end
