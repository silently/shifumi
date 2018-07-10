defmodule Shifumi.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs) do
      add(:game_id, :binary_id, null: false)
      add(:loser_score, :integer, null: false)
      add(:rounds, :integer, null: false)
      add(:history, :text, null: false)
      add(:winner_id, references(:players, on_delete: :nothing, type: :binary_id), null: false)
      add(:loser_id, references(:players, on_delete: :nothing, type: :binary_id), null: false)

      timestamps()
    end

    create(index(:logs, [:winner_id]))
    create(index(:logs, [:loser_id]))
  end
end
