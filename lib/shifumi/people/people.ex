defmodule Shifumi.People do
  @moduledoc """
  The People context.
  """

  import Ecto.Query, warn: false
  alias Shifumi.People.{Avatar, Player}
  alias Shifumi.Repo

  @doc """
  Creates or get a player from trusted/authentified parameters
  """
  def enter(provider, uid) do
    query = from(p in Player, where: p.provider == ^provider and p.uid == ^uid, select: p.id)

    case Repo.one(query) do
      nil ->
        player = create_player!(%{provider: provider, uid: uid})
        {:ok, player.id}

      player_id ->
        {:ok, player_id}
    end
  end

  @doc """
  Creates a player with auth attributes (provider and provider uid)
  """
  def create_player!(attrs) do
    Player.changeset(%Player{}, Map.put(attrs, :sheet, %{}))
    |> Repo.insert!()
  end

  @doc """
  Gets! a single player struct
  """
  def get_player!(id), do: Repo.get!(Player, id)

  @doc """
  Gets a single player struct
  """
  def get_player(id), do: Repo.get(Player, id)

  @doc """
  Gets a single player with preloaded assoc
  """
  def get_full_player!(id) do
    Player |> preload([:avatar, :sheet]) |> Repo.get!(id)
  end

  @doc """
  Deletes a Player
  """
  def delete_player(%Player{} = player) do
    Repo.delete(player)
  end

  @doc """
  Creates a player avatar
  """
  def create_player_avatar(%Player{} = player, attrs) do
    Ecto.build_assoc(player, :avatar)
    |> Avatar.changeset_with_player(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a player avatar
  """
  def get_player_avatar!(player) do
    Repo.get_by!(Avatar, player_id: player.id)
  end

  @doc """
  Updates an avatar
  """
  def update_avatar(%Avatar{} = avatar, attrs) do
    avatar
    |> Avatar.changeset(attrs)
    |> Repo.update()
  end
end
