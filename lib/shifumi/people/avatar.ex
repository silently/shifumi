defmodule Shifumi.People.Avatar do
  use Ecto.Schema
  import Ecto.Changeset
  alias Shifumi.People.Avatar

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "avatars" do
    # Associations
    belongs_to(:player, Shifumi.People.Player)

    field(:location, :string)
    field(:mantra, :string)
    field(:nickname, :string)
    field(:picture, :boolean, default: false)
    field(:roar, :string)

    timestamps()
  end

  #######
  # API #
  #######

  def format(%Avatar{} = avatar) do
    %{
      location: avatar.location,
      mantra: avatar.mantra,
      nickname: avatar.nickname,
      picture: avatar.picture,
      roar: avatar.roar
    }
  end

  ##############
  # Changesets #
  ##############

  @attrs ~w(location mantra nickname picture roar)a

  @doc false
  def changeset_with_player(%Avatar{} = avatar, attrs) do
    avatar
    |> cast(attrs, [:player_id])
    |> unique_constraint(:player_id)
    |> validate_required(:player_id)
    |> changeset(attrs)
  end

  @doc false
  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @attrs)
    |> validate_required(:nickname)
    |> unique_constraint(:nickname)
    |> validate_length(:nickname, max: 20)
    |> validate_length(:location, max: 30)
    |> validate_length(:mantra, max: 30)
    |> validate_length(:roar, max: 30)
  end
end
