defmodule Shifumi.Records.Score do
  @moduledoc """
  A score describes the number of successive wins of a player.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Shifumi.Records.Score

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "scores" do
    belongs_to(:player, Shifumi.People.Player)
    field(:count, :integer)
    field(:live, :boolean, default: true)

    timestamps()
  end

  @doc false
  def changeset_with_player(%Score{} = score, attrs) do
    score
    |> cast(attrs, [:player_id, :count, :live])
    |> validate_required([:player_id, :count, :live])
    |> unique_constraint(:player_id)
  end
end
