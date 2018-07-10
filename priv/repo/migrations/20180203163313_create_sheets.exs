defmodule Shifumi.Repo.Migrations.CreateSheets do
  use Ecto.Migration

  def change do
    create table(:sheets, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:series, {:array, :binary_id})
      add(:wells, :integer)
      add(:score, :integer)
      add(:game_count, :integer)
      add(:game_win_count, :integer)
      add(:high_score, :integer)
      add(:high_score_at, :naive_datetime)
      add(:paper_count, :integer)
      add(:paper_win_count, :integer)
      add(:rock_count, :integer)
      add(:rock_win_count, :integer)
      add(:scissors_count, :integer)
      add(:scissors_win_count, :integer)
      add(:round_count, :integer)
      add(:round_tie_count, :integer)
      add(:round_win_count, :integer)
      add(:well_count, :integer)
      add(:well_win_count, :integer)
      add(:player_id, references(:players, on_delete: :delete_all, type: :binary_id), null: false)

      timestamps()
    end

    create(index(:sheets, [:player_id]))
    create(index(:sheets, [:high_score]))
    create(index(:sheets, [:high_score, :high_score_at]))
  end
end
