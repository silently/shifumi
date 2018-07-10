defmodule Shifumi.Repo.Migrations.CreateScores do
  use Ecto.Migration

  def change do
    create table(:scores, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:count, :integer)
      add(:live, :boolean, default: false, null: false)
      add(:player_id, references(:players, on_delete: :delete_all, type: :binary_id), null: false)

      timestamps()
    end

    # To find a given player scores
    create(index(:scores, [:player_id]))
    # To find a given player high score
    create(index(:scores, [:player_id, :count]))
    # To find a given player current/live score
    create(index(:scores, [:player_id, :live]))
    # To find a highest scores
    create(index(:scores, [:count]))
    # To find a highest current/live scores
    create(index(:scores, [:live, :count]))
    # To find a highest scores by date
    create(index(:scores, [:updated_at, :count]))
  end
end
