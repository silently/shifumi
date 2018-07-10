defmodule ShifumiWeb.PlayerController do
  @moduledoc """
  Player controller for the singleton resource corresponding to the logged player.
  """

  use ShifumiWeb, :controller
  alias Shifumi.People
  alias Shifumi.People.Player

  action_fallback(ShifumiWeb.FallbackController)

  def delete(%{assigns: %{player: player}} = conn, _params) do
    with {:ok, %Player{}} <- People.delete_player(player) do
      send_resp(conn, :no_content, "")
    end
  end
end
