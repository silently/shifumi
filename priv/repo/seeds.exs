# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Shifumi.Repo.insert!(%Shifumi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# alias Shifumi.People
#
# People.create_player!(%{provider: "fake", uid: "1"})
# |> People.create_player_avatar(%{nickname: "player1"})
#
# People.create_player!(%{provider: "fake", uid: "2"})
# |> People.create_player_avatar(%{nickname: "player2"})
1..3
|> Enum.each(fn player_index ->
  player =
    Shifumi.People.create_player!(%{
      provider: "fake",
      uid: "fake" <> Integer.to_string(player_index)
    })

  Shifumi.Records.Sheet.changeset(player.sheet, %{
    high_score: 2 - rem(player_index, 2),
    high_score_at: NaiveDateTime.utc_now()
  })
  |> Shifumi.Repo.update()

  Shifumi.People.create_player_avatar(player, %{
    nickname: "player" <> Integer.to_string(player_index)
  })

  Shifumi.Records.create_player_score(player.id, %{count: 2 - rem(player_index, 2), live: true})
end)
