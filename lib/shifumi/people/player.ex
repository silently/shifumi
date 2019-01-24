defmodule Shifumi.People.Player do
  @moduledoc """
  In-game players public identity.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Shifumi.People.Player

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :naive_datetime_usec]

  schema "players" do
    # Associations
    has_many(:wins, Shifumi.Records.Log, foreign_key: :winner_id)
    has_many(:losses, Shifumi.Records.Log, foreign_key: :loser_id)
    has_many(:scores, Shifumi.Records.Score)
    has_one(:avatar, Shifumi.People.Avatar)
    has_one(:sheet, Shifumi.Records.Sheet)

    # Provider among facebook, github, google, twitter
    field(:provider, :string)
    # Provider unique id
    field(:uid, :string)

    timestamps()
  end

  ##############
  # Changesets #
  ##############

  @attrs ~w(provider uid)a

  @doc false
  def changeset(%Player{} = player, attrs) do
    player
    |> cast(attrs, @attrs)
    |> cast_assoc(:sheet, required: true)
  end
end
