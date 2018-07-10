defmodule Shifumi.Records.SheetTest do
  use Shifumi.DataCase
  import Shifumi.Fixtures
  alias Shifumi.Records.Sheet
  alias Ecto.Changeset

  @max_wells Shifumi.max_wells()

  describe "changeset/2" do
    test "initial wells value is 1" do
      sheet = Sheet.changeset(%Sheet{}, %{})
      assert 1 == sheet.data.wells
    end
  end

  describe "log_changeset/3" do
    test "caps wells" do
      winner_sheet_attrs = %{wells: @max_wells, score: 5}
      winner = seed!(:player_with_sheet, winner_sheet_attrs)

      # we don't need the log to be persisted
      log = build(:log, %{winner_id: winner.id})

      %Changeset{changes: winner_sheet_changes} = Sheet.log_changeset(true, winner.sheet, log)
      refute Map.has_key?(winner_sheet_changes, :wells)
    end

    test "increments wells after a win" do
      winner_sheet_attrs = %{score: 0, wells: 0}
      loser_sheet_attrs = %{score: 1, wells: 0}
      winner = seed!(:player_with_sheet, winner_sheet_attrs)
      loser = seed!(:player_with_sheet, loser_sheet_attrs)

      # we don't need the log to be persisted
      log = build(:log, %{winner_id: winner.id, loser_id: loser.id})

      %Changeset{changes: winner_sheet_changes} = Sheet.log_changeset(true, winner.sheet, log)
      %Changeset{changes: loser_sheet_changes} = Sheet.log_changeset(false, loser.sheet, log)

      assert winner_sheet_changes.wells === winner_sheet_attrs.wells + 1
      refute Map.has_key?(loser_sheet_changes, :wells)
    end

    test "consumes wells (but winner wins 1)" do
      winner_sheet_attrs = %{wells: 2}
      loser_sheet_attrs = %{wells: 4}
      winner = seed!(:player_with_sheet, winner_sheet_attrs)
      loser = seed!(:player_with_sheet, loser_sheet_attrs)

      # we don't need the log to be persisted
      log = build(:log, %{winner_id: winner.id, loser_id: loser.id, history: "wrrp,wssw"})

      %Changeset{changes: winner_sheet_changes} = Sheet.log_changeset(true, winner.sheet, log)
      %Changeset{changes: loser_sheet_changes} = Sheet.log_changeset(false, loser.sheet, log)

      refute Map.has_key?(winner_sheet_changes, :wells)
      assert loser_sheet_changes.wells === loser_sheet_attrs.wells - 2
    end

    test "handles both wells bonus and consumption" do
      winner_sheet_attrs = %{score: 0, wells: 2}
      winner = seed!(:player_with_sheet, winner_sheet_attrs)
      loser = seed!(:player)

      # we don't need the log to be persisted
      log = build(:log, %{winner_id: winner.id, loser_id: loser.id, history: "wrrp,srsr"})

      %Changeset{changes: winner_sheet_changes} = Sheet.log_changeset(true, winner.sheet, log)
      # Won one, consumed one
      refute Map.has_key?(winner_sheet_changes, :wells)
    end

    test "processes game logs" do
      winner_sheet_attrs = %{
        score: 0,
        game_count: 10,
        game_win_count: 5,
        high_score: 2,
        paper_count: 20,
        paper_win_count: 15,
        rock_count: 10,
        rock_win_count: 5,
        round_count: 50,
        round_win_count: 30,
        round_tie_count: 10,
        scissors_count: 10,
        scissors_win_count: 5,
        series: [Ecto.UUID.generate()],
        well_count: 10,
        well_win_count: 5
      }

      loser_sheet_attrs = %{
        score: 3
      }

      winner = seed!(:player_with_sheet, winner_sheet_attrs)
      loser = seed!(:player_with_sheet, loser_sheet_attrs)

      log =
        build(:log, %{
          winner_id: winner.id,
          loser_id: loser.id,
          history: "rrppwss,rrssspp",
          rounds: 7,
          loser_score: 2
        })

      %Changeset{changes: winner_sheet_changes} = Sheet.log_changeset(true, winner.sheet, log)
      %Changeset{changes: loser_sheet_changes} = Sheet.log_changeset(false, loser.sheet, log)

      assert winner_sheet_changes.score === winner_sheet_attrs.score + 1
      assert winner_sheet_changes.game_count === winner_sheet_attrs.game_count + 1
      refute Map.has_key?(winner_sheet_changes, :high_score)
      assert winner_sheet_changes.paper_count === winner_sheet_attrs.paper_count + 2
      assert winner_sheet_changes.rock_count === winner_sheet_attrs.rock_count + 2
      assert winner_sheet_changes.scissors_count === winner_sheet_attrs.scissors_count + 2
      assert winner_sheet_changes.round_tie_count === winner_sheet_attrs.round_tie_count + 2
      assert winner_sheet_changes.well_count === winner_sheet_attrs.well_count + 1
      assert winner_sheet_changes.game_win_count === winner_sheet_attrs.game_win_count + 1
      assert winner_sheet_changes.round_count === winner_sheet_attrs.round_count + 7
      refute Map.has_key?(winner_sheet_changes, :paper_win_count)
      refute Map.has_key?(winner_sheet_changes, :rock_win_count)
      assert winner_sheet_changes.round_win_count === winner_sheet_attrs.round_win_count + 3
      assert winner_sheet_changes.scissors_win_count === winner_sheet_attrs.scissors_win_count + 2
      assert length(winner_sheet_changes.series) === 2
      assert List.first(winner_sheet_changes.series) === loser.id
      assert winner_sheet_changes.well_win_count === winner_sheet_attrs.well_win_count + 1

      assert loser_sheet_changes.score === 0
    end
  end
end
