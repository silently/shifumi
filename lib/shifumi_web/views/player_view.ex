defmodule ShifumiWeb.PlayerView do
  use ShifumiWeb, :view

  def render("full.json", %{player: %{id: id, avatar: avatar, sheet: sheet}}) do
    formatted_sheet = ShifumiWeb.SheetView.render("show.json", %{sheet: sheet})

    filtered_avatar =
      if avatar do
        Map.take(avatar, [:location, :mantra, :nickname, :picture, :roar])
      else
        %{}
      end

    %{id: id, avatar: filtered_avatar, sheet: formatted_sheet}
  end
end
