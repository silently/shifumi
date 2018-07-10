defmodule ShifumiWeb.AvatarController do
  @moduledoc """
  Avatar controller for the singleton resource corresponding to the logged player.
  """
  use ShifumiWeb, :controller

  alias Shifumi.People
  alias Shifumi.People.Avatar

  @upload_at Shifumi.upload_at()

  action_fallback(ShifumiWeb.FallbackController)

  def show(%{assigns: %{player: player}} = conn, _params) do
    avatar = People.get_player_avatar!(player)
    render(conn, "show.json", avatar: avatar)
  end

  def update(%{assigns: %{player: %{id: player_id}}}, %{"id" => param_id})
      when player_id !== param_id do
    {:error, :unauthorized}
  end

  def update(%{assigns: %{player: player}} = conn, params) do
    avatar = People.get_player_avatar!(player)

    params =
      if !!params["file"] do
        process_picture(player.id, params["file"].path)
        Map.put(params, "picture", true)
      else
        params
      end

    with {:ok, %Avatar{} = avatar} <- People.update_avatar(avatar, params) do
      render(conn, "show.json", avatar: avatar)
    end
  end

  defp process_picture(id, path) do
    Mogrify.open(path)
    |> Mogrify.gravity("Center")
    |> Mogrify.resize_to_fill("200x200")
    |> Mogrify.format("jpg")
    |> Mogrify.save(path: @upload_at <> "/#{id}.jpg")
  end
end
