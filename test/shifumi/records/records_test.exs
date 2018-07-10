defmodule Shifumi.RecordsTest do
  use Shifumi.DataCase
  import Shifumi.Fixtures
  alias Shifumi.Records
  alias Shifumi.Records.Log

  describe "process_game/1" do
    test "deals with aborted game" do
      sheet1_attrs = %{
        score: 3,
        game_count: 23,
        game_win_count: 11,
        high_score: 3,
        series: [Ecto.UUID.generate()]
      }

      sheet2_attrs = %{
        score: 2,
        game_count: 22,
        game_win_count: 10,
        high_score: 5,
        series: [Ecto.UUID.generate()]
      }

      player1 = seed!(:player_with_sheet, sheet1_attrs)
      player2 = seed!(:player_with_sheet, sheet2_attrs)

      game = %Shifumi.Engine.Game{player1_id: player1.id, player2_id: player2.id, aborted: true}

      Records.process_game(game)
      # Refetch records
      sheet1 = Records.get_player_sheet(player1.id)
      sheet2 = Records.get_player_sheet(player2.id)

      assert sheet1.score === 0
      assert sheet1.game_count === sheet1_attrs.game_count
      assert sheet1.game_win_count === sheet1_attrs.game_win_count
      assert sheet1.high_score === sheet1_attrs.high_score
      assert length(sheet1.series) === 0

      assert sheet2.score === 0
      assert sheet2.game_count === sheet2_attrs.game_count
      assert sheet2.game_win_count === sheet2_attrs.game_win_count
      assert sheet2.high_score === sheet2_attrs.high_score
      assert length(sheet2.series) === 0
    end
  end

  describe "insert_log!/1" do
    test "creates a log with valid data" do
      log = %Log{
        game_id: Ecto.UUID.generate(),
        winner_id: seed!(:player).id,
        loser_id: seed!(:player).id,
        history: "rsppsprs"
      }

      assert %Log{} = Records.insert_log!(log)
    end

    test "returns error changeset with invalid data" do
      # Missing associations
      log = %Log{
        game_id: Ecto.UUID.generate(),
        history: "rsppsprs"
      }

      assert_raise Postgrex.Error, fn ->
        Records.insert_log!(log)
      end
    end
  end

  describe "series" do
    test "update_sheet/3 processes game logs" do
      winner_sheet_attrs = %{
        score: 3,
        game_count: 23,
        game_win_count: 11,
        high_score: 3,
        paper_count: 25,
        paper_win_count: 15,
        rock_count: 25,
        rock_win_count: 12,
        round_count: 100,
        round_win_count: 55,
        round_tie_count: 10,
        scissors_count: 25,
        scissors_win_count: 13,
        series: [Ecto.UUID.generate()],
        well_count: 25,
        well_win_count: 9
      }

      loser_sheet_attrs = %{
        score: 2,
        game_count: 22,
        game_win_count: 10,
        high_score: 5,
        paper_count: 25,
        paper_win_count: 10,
        rock_count: 25,
        rock_win_count: 15,
        round_count: 99,
        round_win_count: 51,
        round_tie_count: 11,
        scissors_count: 25,
        scissors_win_count: 12,
        series: [Ecto.UUID.generate()],
        well_count: 25,
        well_win_count: 9
      }

      winner = seed!(:player_with_sheet, winner_sheet_attrs)
      loser = seed!(:player_with_sheet, loser_sheet_attrs)

      log = %Log{
        winner_id: winner.id,
        loser_id: loser.id,
        history: "rrppw,sssps"
      }

      {:ok, winner_sheet} = Records.update_sheet(true, winner.sheet, log)
      {:ok, loser_sheet} = Records.update_sheet(false, loser.sheet, log)

      assert winner_sheet.score === winner_sheet_attrs.score + 1
      assert winner_sheet.game_count === winner_sheet_attrs.game_count + 1
      assert winner_sheet.high_score === winner_sheet_attrs.high_score + 1
      assert winner_sheet.paper_count === winner_sheet_attrs.paper_count + 2
      assert winner_sheet.rock_count === winner_sheet_attrs.rock_count + 2
      assert winner_sheet.scissors_count === winner_sheet_attrs.scissors_count
      assert winner_sheet.round_tie_count === winner_sheet_attrs.round_tie_count + 1
      assert winner_sheet.well_count === winner_sheet_attrs.well_count + 1
      assert winner_sheet.game_win_count === winner_sheet_attrs.game_win_count + 1
      assert winner_sheet.round_count === winner_sheet_attrs.round_count + 5
      assert winner_sheet.paper_win_count === winner_sheet_attrs.paper_win_count
      assert winner_sheet.rock_win_count === winner_sheet_attrs.rock_win_count + 2
      assert winner_sheet.round_win_count === winner_sheet_attrs.round_win_count + 3
      assert winner_sheet.scissors_win_count === winner_sheet_attrs.scissors_win_count
      assert length(winner_sheet.series) === 2
      assert List.first(winner_sheet.series) === loser.id
      assert winner_sheet.well_win_count === winner_sheet_attrs.well_win_count + 1

      assert loser_sheet.score === 0
      assert loser_sheet.game_count === loser_sheet_attrs.game_count + 1
      assert loser_sheet.high_score === loser_sheet_attrs.high_score
      assert loser_sheet.paper_count === loser_sheet_attrs.paper_count + 1
      assert loser_sheet.rock_count === loser_sheet_attrs.rock_count
      assert loser_sheet.scissors_count === loser_sheet_attrs.scissors_count + 4
      assert loser_sheet.round_tie_count === loser_sheet_attrs.round_tie_count + 1
      assert loser_sheet.well_count === loser_sheet_attrs.well_count
      assert loser_sheet.game_win_count === loser_sheet_attrs.game_win_count
      assert loser_sheet.round_count === loser_sheet_attrs.round_count + 5
      assert loser_sheet.paper_win_count === loser_sheet_attrs.paper_win_count
      assert loser_sheet.rock_win_count === loser_sheet_attrs.rock_win_count
      assert loser_sheet.round_win_count === loser_sheet_attrs.round_win_count + 1
      assert loser_sheet.scissors_win_count === loser_sheet_attrs.scissors_win_count + 1
      assert length(loser_sheet.series) === 0
      assert loser_sheet.well_win_count === loser_sheet_attrs.well_win_count
    end

    test "get_series/1 returns the right series" do
      series = 1..5 |> Enum.map(fn _ -> Ecto.UUID.generate() end)
      # We need Shifumi.Fixtures.seed! since *series* can not be set in default changeset
      player = seed!(:player_with_sheet, %{series: series})
      assert series === Records.get_player_series(player.id)
    end
  end

  describe "scores" do
    alias Shifumi.Records.Score

    setup do
      [player: seed!(:player)]
    end

    def get_score!(id), do: Repo.get!(Score, id)

    test "best/0 returns first 10 best ever scores of different players" do
      # Creates 20 different players with score 11/12/13, then 21/22/23... 201/202/203
      0..19
      |> Enum.each(fn player_index ->
        seed!(:full_player, %{
          avatar: %{nickname: "player" <> Integer.to_string(player_index)},
          sheet: %{high_score: player_index}
        })
      end)

      best = Records.best()
      assert length(best) === 10
      assert %{nickname: "player19", count: 19} = List.first(best)
      assert %{nickname: "player10", count: 10} = List.last(best)
    end

    test "best/0 returns latest scores first" do
      seed!(:full_player, %{
        avatar: %{nickname: "player1"},
        sheet: %{high_score: 5, high_score_at: ~N[2018-02-02 20:00:00]}
      })

      seed!(:full_player, %{
        avatar: %{nickname: "player2"},
        sheet: %{high_score: 5, high_score_at: ~N[2018-02-02 19:00:00]}
      })

      best = Records.best()
      assert %{nickname: "player2"} = List.first(best)
    end

    test "best_live/0 returns first 10 best scores of different players" do
      # Creates 20 different players with score 11/12/13, then 21/22/23... 201/202/203
      0..19
      |> Enum.each(fn player_index ->
        player =
          seed!(:player_with_avatar, %{nickname: "player" <> Integer.to_string(player_index)})

        0..2
        |> Enum.each(&seed!(:score, %{player: player, count: player_index * 10 + &1, live: true}))
      end)

      best_live = Records.best_live()
      assert length(best_live) === 10
      assert %{nickname: "player19", count: 192} = List.first(best_live)
      assert %{nickname: "player10", count: 102} = List.last(best_live)
    end

    test "best_live/0 returns at most 10 scores and only live ones" do
      # Creates 10 different players with 10 scores each,
      # but odd index player scores are not live
      0..9
      |> Enum.each(fn player_index ->
        player =
          seed!(:player_with_avatar, %{nickname: "player" <> Integer.to_string(player_index)})

        0..9
        |> Enum.each(
          &seed!(:score, %{
            player: player,
            count: player_index * 10 + &1,
            live: rem(player_index, 2) == 0
          })
        )
      end)

      best_live = Records.best_live()
      assert length(best_live) === 5
      assert %{nickname: "player8", count: 89} = List.first(best_live)
      assert %{nickname: "player0", count: 9} = List.last(best_live)
    end

    test "best_live/0 returns identical scores for different players in chronological order" do
      0..7
      |> Enum.each(fn player_index ->
        player =
          seed!(:player_with_avatar, %{nickname: "player" <> Integer.to_string(player_index)})

        0..1 |> Enum.each(fn _ -> seed!(:score, %{player: player, count: 100, live: true}) end)
      end)

      8..15
      |> Enum.each(fn player_index ->
        player =
          seed!(:player_with_avatar, %{nickname: "player" <> Integer.to_string(player_index)})

        0..3 |> Enum.each(&seed!(:score, %{player: player, count: 50 + &1, live: true}))
      end)

      best_live = Records.best_live()
      assert length(best_live) === 10
      assert %{count: 100} = List.first(best_live)
      assert %{count: 53} = List.last(best_live)
      # eight 100 and two 53 scores
      assert best_live |> Enum.reduce(0, &(&1.count + &2)) == 906
    end

    test "create_player_score/1 with valid data creates a score", %{player: player} do
      valid_attrs = %{count: 11, live: true}
      assert {:ok, %Score{} = score} = Records.create_player_score(player.id, valid_attrs)
      assert score.count === 11
      assert score.live == true
    end

    test "create_player_score/1 with invalid data returns error changeset", %{player: player} do
      assert {:error, %Ecto.Changeset{}} =
               Records.create_player_score(%Shifumi.People.Player{}, %{count: 12, live: true})

      assert {:error, %Ecto.Changeset{}} =
               Records.create_player_score(player, %{count: nil, live: true})

      assert {:error, %Ecto.Changeset{}} =
               Records.create_player_score(player, %{count: 12, live: nil})
    end

    test "inc_score/1 increments a live score", %{player: player} do
      count = 23
      score = seed!(:score, %{player: player, count: count, live: true})
      Records.inc_score(player.id)
      assert get_score!(score.id).live == true
      assert get_score!(score.id).count === count + 1
    end

    test "inc_score/1 has no effect on an inactive (!live) score", %{player: player} do
      count = 23
      score = seed!(:score, %{player: player, count: count, live: false})
      Records.inc_score(player.id)
      assert get_score!(score.id).live == false
      assert get_score!(score.id).count === count
    end

    test "stop_score/1 sets live as false", %{player: player} do
      count = 23
      score = seed!(:score, %{player: player, count: count, live: true})
      Records.stop_score(player.id)
      assert get_score!(score.id).count === count
      assert get_score!(score.id).live == false
    end
  end
end
