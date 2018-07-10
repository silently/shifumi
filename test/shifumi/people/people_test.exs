defmodule Shifumi.PeopleTest do
  use Shifumi.DataCase
  alias Shifumi.People
  alias Shifumi.People.{Avatar, Player}

  # We do not to use Fixtures.seed!/1 here, since the purpose of this test suite
  # is to focus on Repo interaction through the People context

  describe "enter/2" do
    test "finds existing player" do
      {provider, uid} = {"fake", Ecto.UUID.generate()}
      %Player{id: created_player_id} = People.create_player!(%{provider: provider, uid: uid})
      {:ok, found_player_id} = People.enter(provider, uid)

      assert created_player_id == found_player_id
    end

    test "creates new player" do
      {provider, uid} = {"fake", Ecto.UUID.generate()}
      assert {:ok, _player_id} = People.enter(provider, uid)
    end
  end

  describe "create_player!/1" do
    test "creates player with sheet but no avatar" do
      %Player{id: id} = People.create_player!(%{provider: "fake", uid: Ecto.UUID.generate()})
      full_player = People.get_full_player!(id)

      refute nil == full_player.sheet
      assert nil == full_player.avatar
    end

    test "creates player with 1 well" do
      player = People.create_player!(%{provider: "fake", uid: Ecto.UUID.generate()})
      assert 1 == player.sheet.wells
    end
  end

  describe "get players" do
    setup do
      # Setup: create player *with* avatar
      player = People.create_player!(%{provider: "fake", uid: Ecto.UUID.generate()})
      People.create_player_avatar(player, %{nickname: "tomato"})
      [player_with_avatar: player]
    end

    test "get_player!/1 returns the player with given id without associations", %{
      player_with_avatar: player
    } do
      player = People.get_player!(player.id)
      refute Ecto.assoc_loaded?(player.avatar)
      refute Ecto.assoc_loaded?(player.sheet)
    end

    test "get_full_player!/1 returns the player with given id with associations", %{
      player_with_avatar: player
    } do
      full_player = People.get_full_player!(player.id)

      assert full_player.avatar.nickname == "tomato"
      avatar = People.get_player_avatar!(player)
      assert full_player.avatar == avatar
      assert Ecto.assoc_loaded?(full_player.avatar)
      assert Ecto.assoc_loaded?(full_player.sheet)
    end

    test "delete_player/1 deletes the player", %{
      player_with_avatar: player
    } do
      assert {:ok, %Player{}} = People.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> People.get_player!(player.id) end
    end
  end

  describe "avatars" do
    setup do
      # Setup: create player *without* avatar
      player = People.create_player!(%{provider: "fake", uid: Ecto.UUID.generate()})
      [player_without_avatar: player]
    end

    test "create_player_avatar/2 with valid data creates the avatar", %{
      player_without_avatar: player
    } do
      assert {:ok, %Avatar{}} = People.create_player_avatar(player, %{nickname: "tomato"})
    end

    test "create_player_avatar/2 with no data returns error changeset", %{
      player_without_avatar: player
    } do
      assert {:error, %Ecto.Changeset{}} = People.create_player_avatar(player, %{})
    end

    test "create_player_avatar/2 without a nickname returns error changeset", %{
      player_without_avatar: player
    } do
      assert {:error, %Ecto.Changeset{}} = People.create_player_avatar(player, %{roar: "rrr"})
    end

    test "create_player_avatar/2 with invalid data returns error changeset", %{
      player_without_avatar: player
    } do
      assert {:error, %Ecto.Changeset{}} =
               People.create_player_avatar(player, %{
                 nickname: "tomato",
                 roar: "roar is too long, really too long, Joe, don't you think?"
               })
    end

    test "create_player_avatar/2 twice for the same player returns error changeset", %{
      player_without_avatar: player
    } do
      assert {:ok, %Avatar{}} = People.create_player_avatar(player, %{nickname: "tomato"})

      assert {:error, %Ecto.Changeset{}} =
               People.create_player_avatar(player, %{nickname: "potatoe"})
    end

    test "get_player_avatar!/1 return all fields", %{
      player_without_avatar: player
    } do
      {:ok, avatar} = People.create_player_avatar(player, %{nickname: "tomato"})

      update_attrs = %{
        location: "location",
        mantra: "mantra",
        nickname: "nickname",
        picture: true,
        roar: "roar"
      }

      assert {:ok, %Avatar{} = _} = People.update_avatar(avatar, update_attrs)
      avatar = People.get_player_avatar!(player)
      assert avatar.nickname == update_attrs.nickname
      assert avatar.location == update_attrs.location
      assert avatar.mantra == update_attrs.mantra
      assert avatar.picture == update_attrs.picture
      assert avatar.roar == update_attrs.roar
    end

    test "update_avatar/2 with valid data updates the player", %{
      player_without_avatar: player
    } do
      {:ok, avatar} = People.create_player_avatar(player, %{nickname: "tomato"})

      update_attrs = %{nickname: "sunflower", mantra: "good to go", location: "ocean"}
      assert {:ok, %Avatar{} = avatar} = People.update_avatar(avatar, update_attrs)
      assert ^update_attrs = Map.take(avatar, [:nickname, :mantra, :location])
    end

    test "update_avatar/2 with invalid data returns error changeset", %{
      player_without_avatar: player
    } do
      {:ok, avatar} = People.create_player_avatar(player, %{nickname: "tomato"})

      invalid_attrs = %{roar: "roar is too long, really too long, Joe, don't you think?"}
      assert {:error, %Ecto.Changeset{}} = People.update_avatar(avatar, invalid_attrs)
    end
  end
end
