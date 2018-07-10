defmodule Shifumi.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:provider, :string, null: false)
      add(:uid, :string, null: false)

      timestamps()
    end

    create(index(:players, [:provider, :uid]))
  end
end
