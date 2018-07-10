defmodule Shifumi.Fixtures do
  @moduledoc """
  Fixtures factory bypassing model changesets, to ease forging specific test data.
  """
  alias Shifumi.Repo

  @doc """
  Seed various schema-based struct and "Repo.insert!" it without triggering changesets
  """
  def seed!(kind, attrs \\ %{}), do: build(kind, attrs) |> Repo.insert!()

  @doc """
  Build schema-based struct without persisting it
  """
  def build(:player_with_avatar, avatar_attrs) do
    build(:player) |> Map.put(:avatar, build(:avatar, avatar_attrs))
  end

  def build(:player_with_sheet, sheet_attrs) do
    build(:player) |> Map.put(:sheet, build(:sheet, sheet_attrs))
  end

  def build(:full_player, %{avatar: avatar_attrs, sheet: sheet_attrs}) do
    build(:player)
    |> Map.put(:avatar, build(:avatar, avatar_attrs))
    |> Map.put(:sheet, build(:sheet, sheet_attrs))
  end

  def build(kind, attrs), do: build(kind) |> struct(attrs)

  def build(:player) do
    %Shifumi.People.Player{
      provider: "fake",
      uid: Ecto.UUID.generate(),
      sheet: build(:sheet)
    }
  end

  def build(:avatar) do
    %Shifumi.People.Avatar{
      location: Faker.Address.city(),
      mantra: Faker.Superhero.power(),
      nickname: Faker.Name.first_name(),
      roar: Faker.Lorem.Shakespeare.hamlet(),
      picture: :rand.uniform(2) === 1
    }
  end

  def build(:sheet) do
    %Shifumi.Records.Sheet{}
  end

  def build(:score) do
    %Shifumi.Records.Score{
      count: :rand.uniform(100),
      live: :rand.uniform(4) === 1
    }
  end

  def build(:log) do
    %Shifumi.Records.Log{
      game_id: Ecto.UUID.generate(),
      winner_id: Ecto.UUID.generate(),
      loser_id: Ecto.UUID.generate(),
      history: "rrr,sss",
      rounds: 5,
      loser_score: 0
    }
  end
end
